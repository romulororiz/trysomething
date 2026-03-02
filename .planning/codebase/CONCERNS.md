# Codebase Concerns

**Analysis Date:** 2026-03-02

## Vercel Deployment Limit — Critical Constraint

**Issue:** Vercel Hobby plan allows maximum 12 serverless functions. Current deployment uses 11 of 12.

**Files:** `server/vercel.json` (routing configuration)

**Impact:**
- Cannot add new standalone endpoints
- All future endpoints (Batches 4-8) must be consolidated into existing handler files
- One more endpoint causes deployment failure

**Current handlers consuming slots:**
- `api/auth/[action].ts` — 4 actions consolidated (register, login, refresh, google)
- `api/users/[path].ts` — Multiple paths consolidated (me, preferences, hobbies*, journal*, notes*, schedule*, shopping*)
- `api/hobbies/index.ts` — List hobbies
- `api/hobbies/[id]/index.ts` — Get single hobby
- `api/hobbies/[id]/[feature].ts` — FAQ, cost, budget features (3 paths)
- `api/hobbies/search.ts` — Search endpoint
- `api/hobbies/combos.ts` — Hobby combos
- `api/hobbies/seasonal.ts` — Seasonal picks
- `api/hobbies/mood.ts` — Mood tags
- `api/categories/index.ts` — List categories
- `api/health.ts` — Health check

**Fix approach:**
- Future endpoints must use route pattern consolidation (e.g., `/api/users/[path].ts` with query parameter handling)
- Refer to `vercel.json` route rules for consolidation pattern
- All Batches 4-8 endpoints (activity, personal tools, social) already mapped to existing `[path].ts` handlers in vercel.json

---

## Data Synchronization — Offline-First Gap

**Issue:** User progress (hobbies, steps, notes, journal, schedule) uses SharedPreferences + fire-and-forget API calls with rollback, but if app crashes during sync, changes may not persist to server.

**Files:**
- `lib/providers/user_provider.dart` (UserHobbiesNotifier._apiCall)
- `lib/providers/feature_providers.dart` (JournalNotifier._apiCall, ScheduleNotifier._apiCall)

**Current pattern (optimistic update):**
```dart
void _apiCall(
  Map<String, UserHobby> snapshot,
  Future<void> Function() call,
) {
  call().catchError((e) {
    debugPrint('[UserHobbies] API call failed, rolling back: $e');
    state = snapshot;
    _save();
  });
}
```

**Problems:**
1. API failures roll back local state but don't retry
2. If network drops before sync returns, changes are lost after app restart
3. No queue of pending changes — single Dio error means data loss
4. Server may receive request after client rollback (orphaned record)

**Impact:**
- Users lose hobby progress (save/try/complete status, completed steps, notes)
- No audit trail of what was attempted vs. what succeeded
- Confusing UX: user sees progress rollback unexpectedly

**Fix approach:**
- Implement pending changes queue: serialize failed mutations to SharedPreferences
- On next API success, flush queued changes
- Add retry logic with exponential backoff
- Validate timestamps server-side (only accept if newer than existing)
- Log sync events to activity log for debugging

---

## Auth Token Refresh — Potential Edge Case with Simultaneous Requests

**Issue:** If multiple requests receive 401 simultaneously, each may independently attempt token refresh, causing race conditions.

**Files:** `lib/core/auth/auth_interceptor.dart` (onError handler)

**Current implementation:**
```dart
try {
  final refreshDio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl, ...));
  final response = await refreshDio.post(ApiConstants.authRefresh, ...);
  // Updates tokens
  await TokenStorage.saveTokens(...);
  // Retries original request
  final retryResponse = await ApiClient.instance.fetch(err.requestOptions);
  handler.resolve(retryResponse);
} catch (_) {
  await TokenStorage.clearTokens();
  handler.next(err);
}
```

**Problems:**
1. No mutex lock — multiple requests in parallel = multiple refresh attempts
2. Each creates separate Dio instance (good for avoiding interceptor loop, but bypasses auth on refresh itself)
3. If refresh succeeds on request A but fails on request B, both get different outcomes
4. Race: Request A refreshes tokens → Request B reads old tokens from storage → Request B's refresh also fires

**Impact:**
- Occasional 401 errors after token expiry despite valid refresh token
- Unusual auth state inconsistencies
- Users may see "session expired" dismissible errors even when session is valid

**Fix approach:**
- Implement token refresh lock (AtomicReference or Semaphore pattern)
- First 401 triggers refresh; others wait for result
- If refresh succeeds, other requests retry with new token
- If refresh fails, all requests propagate error
- Add timeout to prevent deadlock

---

## Error Handling — Swallowed Exceptions

**Issue:** Several catch handlers silently ignore errors without logging meaningful context.

**Files:**
- `lib/providers/user_provider.dart` (line 145-150: `_apiCall` catches all)
- `lib/providers/feature_providers.dart` (lines 59-67, 131-139: JournalNotifier, ScheduleNotifier similar pattern)
- `lib/providers/auth_provider.dart` (line 222: `updateProfile` catches and ignores)

**Examples:**
```dart
// user_provider.dart
call().catchError((e) {
  debugPrint('[UserHobbies] API call failed, rolling back: $e');
  state = snapshot;
  _save();
});

// auth_provider.dart
Future<void> updateProfile({...}) async {
  try { ... } catch (_) {}  // Swallows error silently
}
```

**Problems:**
1. `debugPrint` only visible in debug mode, not in production
2. No error metrics collected (Sentry/Crashlytics)
3. Users see state rollback with no explanation
4. Hard to debug production issues
5. `updateProfile` silently fails — user may think profile updated when it didn't

**Impact:**
- Silent data loss in production
- No alerting on persistent API failures
- Difficult to identify server-side issues

**Fix approach:**
- Replace `debugPrint` with structured logging (Firebase Analytics, Sentry, or similar)
- Create `logError()` helper that includes:
  - Error type and message
  - API endpoint
  - User ID (if available)
  - Timestamp
- Return error state from notifiers so UI can show toasts
- Set up production error monitoring in Batches 7-8

---

## Google Sign-In Platform Differences — Fragile Fallback Chain

**Issue:** Platform-specific differences in Google token availability create a fragile fallback mechanism.

**Files:** `lib/providers/auth_provider.dart` (loginWithGoogle, lines 136-200)

**Current flow:**
1. Try idToken-based flow with serverClientId (Android/iOS ideal path)
2. Catch ApiException 10 (SHA-1 mismatch or propagation delay)
3. Fall back to accessToken-only flow without serverClientId
4. Server verifies token via Google userinfo endpoint
5. On Windows: skip to step 3 (no idToken available)

**Problems:**
1. Exception type detection by message string: `'API exception 10'` — fragile if error message changes
2. No timeout on signOut() — code runs fire-and-forget, ignores 400+ second hangs on Windows/Linux
3. If serverClientId env var not provided, both flows use same path (confusing)
4. Fallback verification via userinfo is one extra HTTP call; if that fails silently, server creates user with incomplete data
5. No retry after fallback fails — user sees generic "check your account configuration" error

**Impact:**
- Debug keystore SHA-1 mismatch causes confusing "sign-in failed" instead of "keystore issue"
- Windows users experience hangs (though non-blocking)
- App startup can lag if Google libraries stall
- Silent incomplete account creation on userinfo endpoint failure

**Fix approach:**
- Create GoogleAuthException type instead of string matching
- Document all exception codes (10 = DEVELOPER_ERROR with specific causes)
- Replace signOut() fire-and-forget with explicit timeout (2s max)
- If userinfo call fails, return error to user instead of creating account
- Add telemetry: log which flow succeeded (idToken vs. accessToken)
- For Batch 8: Implement retry queue for failed sign-ins

---

## Optimistic Updates Without Proper Rollback Cleanup

**Issue:** Failed API calls trigger rollback of local state, but don't clean up temporary data that may have been persisted.

**Files:**
- `lib/providers/user_provider.dart` (UserHobbiesNotifier)
- `lib/providers/feature_providers.dart` (JournalNotifier.addEntry, ScheduleNotifier.addEvent)

**Example (journal):**
```dart
void addEntry(JournalEntry entry) {
  final snapshot = List<JournalEntry>.from(state);
  state = [entry, ...state];  // Optimistic add with temp ID
  _apiCall(snapshot, () async {
    final created = await _repo.createJournalEntry(...);
    // Replace temp entry with server response
    state = [created, ...state.where((e) => e.id != entry.id).toList()];
  });
}
```

**Problems:**
1. Temp entry added to UI immediately with local UUID
2. If API fails and rollback happens, any image URLs or attachments in `photoUrl` field aren't cleaned up
3. Temp ID persists in SharedPreferences cache if rollback happens
4. User deletes temp entry before API responds; API response creates new entry with same data
5. No "pending" flag — UI doesn't indicate which entries haven't synced

**Impact:**
- Orphaned temp IDs in SharedPreferences after failed sync
- Duplicate journal entries if user retries after failed add
- Image URLs pointing to non-existent files (if photo upload happened before entry save)
- Confusing behavior: entry appears briefly, disappears, reappears as different ID

**Fix approach:**
- Add pending/synced flag to all local models (JournalEntry, ScheduleEvent, UserHobby)
- Persist pending changes with "attempts" counter
- On rollback, mark as "pending_sync_failed" not deleted
- Retry failed entries on next app session
- UI shows visual indicator (dimmed, "syncing" spinner) for pending items
- Implement idempotency keys (send same UUID on retry, server deduplicates)

---

## Activity Log — Missing Server Implementation

**Issue:** Activity log endpoint exists in Prisma schema and router, but may not have full CRUD implementation.

**Files:**
- `server/prisma/schema.prisma` (UserActivityLog model defined)
- `server/vercel.json` (route `/api/users/activity` maps to `users/[path].ts`)

**Current state:**
- Flutter client fetches activity log for heatmap: `lib/providers/feature_providers.dart` (activityLogProvider)
- Server routing expects path handler to support activity queries
- Server-side `users/[path].ts` file likely incomplete for activity CRUD

**Impact:**
- Activity heatmap on profile may show no data
- Activity streaks calculated from empty log
- Batch 4 plan depends on this working

**Fix approach:**
- Verify `server/api/users/[path].ts` implements activity path cases:
  - GET `/api/users/activity?days=N` — fetch recent activity
  - POST activity logs when hobby status changes (automatic in UserHobbiesNotifier)
- Add indexes for performance: `@@index([userId, createdAt])`
- Test heatmap end-to-end in Batch 4

---

## Feature Providers — Hard-Coded Seed Data for Non-API Features

**Issue:** Several feature providers still return hardcoded seed data instead of server-backed data.

**Files:** `lib/providers/feature_providers.dart`

**Current issues:**
- `profileProvider` (line 47-49): In-memory only, no persistence
- `challengeProvider` (line 110-112): Returns hardcoded FeatureSeedData.challenges, not server data
- `buddyProfilesProvider` (line 211-213): Hardcoded seed
- `buddyActivitiesProvider` (line 215-217): Hardcoded seed
- `storiesProvider` (line 223-225): Hardcoded seed
- `nearbyUsersProvider` (line 231-233): Hardcoded seed

**Problems:**
1. These features don't scale: data is same for all users
2. No personalization (challenges should be per-user progress)
3. No backend support — can't add/edit challenges, stories, etc.
4. Geo features (nearbyUsers) can't work with seed data
5. Resets on app restart

**Impact:**
- Batch 7 (gamification) can't implement weekly challenges properly
- Batch 6 (social) can't show user-specific activity
- Product teams can't manage content without code changes

**Fix approach:**
- Batch 5: Create PersonalToolsRepository methods for these endpoints
- Batch 6: Add server endpoints for social data (buddies, stories, activity)
- Batch 7: Implement weekly challenge generation and assignment
- Convert providers to FutureProvider with repository calls
- Add caching layer (Hive) for content that doesn't change frequently

---

## Notes Provider — No Server Persistence

**Issue:** Personal notes (per hobby step) are stored in-memory only, not persisted to server.

**Files:**
- `lib/providers/feature_providers.dart` (NotesNotifier, line 185-199)
- `server/vercel.json` (notes route exists: `/api/users/notes/`)

**Current state:**
- `NotesNotifier` is StateNotifierProvider with in-memory Map<stepId, String>
- Has routes in vercel.json for notes endpoints
- No actual server implementation for notes CRUD

**Problems:**
1. Notes lost on app restart
2. User's progress tracking notes not saved
3. Server endpoint defined in router but not implemented
4. No sync between devices

**Impact:**
- Users can't reliably keep step-by-step notes
- No backup of personal progress notes
- Batch 5 (personal tools) depends on this

**Fix approach:**
- Implement NotesRepository (interface + API impl)
- Create server endpoint handler for notes in `users/[path].ts`
- Add database persistence (PersonalNote model already defined in schema)
- Convert NotesNotifier to API-backed with SharedPreferences cache
- Load notes on app start via `loadFromServer()` pattern

---

## Shared Preferences — No Schema Validation

**Issue:** Local persistent state (onboarding, preferences, hobbies, notes) relies on manual JSON serialization with no validation.

**Files:**
- `lib/providers/user_provider.dart` (UserPreferencesNotifier._load, UserHobbiesNotifier._load, lines 56-68, 122-134)
- `lib/providers/feature_providers.dart` (NotesNotifier has no persistence)

**Current pattern:**
```dart
static UserPreferences _load(SharedPreferences prefs) {
  final json = prefs.getString(_key);
  if (json == null) return const UserPreferences();
  try {
    return UserPreferences.fromJson(
      jsonDecode(json) as Map<String, dynamic>,
    );
  } catch (_) {
    return const UserPreferences();  // Silent fallback
  }
}
```

**Problems:**
1. Corrupt SharedPreferences JSON silently discarded, losing user data
2. No migration path if UserPreferences schema changes
3. Unknown whether data loss happens in production
4. Frozen user preferences revert to defaults if deserialization fails

**Impact:**
- Silent data loss if JSON format changes
- Difficult to debug user sync issues ("why did my preferences reset?")
- Can't add new fields without migration logic

**Fix approach:**
- Add schema versioning: `{ "version": 1, "data": {...} }`
- Implement migration functions for version bumps
- Log deserialize failures with timestamp and attempted data
- Add sentry-integration for production error reporting
- Implement data backup to server (sync state on every change)

---

## Testing — No Test Coverage

**Issue:** Codebase has no automated tests despite complex state management and sync logic.

**Files:**
- No `*.test.dart` or `*.spec.dart` files in lib/
- Server has `vitest` setup but no test files

**Critical untested areas:**
- `lib/providers/user_provider.dart` (UserHobbiesNotifier): Optimistic updates, rollback, sync from server
- `lib/core/auth/auth_interceptor.dart` (token refresh, concurrent 401s)
- `lib/providers/auth_provider.dart` (loginWithGoogle fallback chain)
- Server auth endpoints (token generation, validation, Google verification)

**Impact:**
- Regressions undetected
- Refactoring risky
- Batch 4 changes to sync logic have no safety net
- Edge cases (concurrent requests, network failures) not validated

**Fix approach:**
- Batch 8 (production polish) must include testing
- Start with critical paths:
  1. UserHobbiesNotifier optimistic updates + rollback
  2. Token refresh with concurrent 401 requests
  3. Google sign-in fallback chain
  4. Auth endpoint input validation
- Use `test/` directory for Dart, `server/test/` for Node
- Aim for 80% coverage of user-facing features

---

## CORS — Permissive Configuration

**Issue:** CORS allows requests from any origin with wildcard "*".

**Files:** `server/lib/middleware.ts` (setCorsHeaders, line 4-8)

```typescript
export function setCorsHeaders(res: VercelResponse): void {
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
  res.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");
}
```

**Problems:**
1. Allows authenticated requests from any domain
2. Cross-site request forgery risk if session storage vulnerable
3. No origin validation
4. Acceptable for MVP but not production

**Impact:**
- In theory, malicious site can make authenticated requests on behalf of user
- Mitigated somewhat by JWT tokens in Authorization header (not cookies)
- Still exposes to credential leakage if tokens captured

**Fix approach:**
- Whitelist specific origins (Flutter web, iOS app, Android app)
- Remove wildcard in production
- Keep wildcard for dev/localhost
- Set `credentials: false` for non-authenticated endpoints
- Document CORS policy in security guidelines (Batch 8)

---

## Environment Variable Validation — Missing Checks

**Issue:** Server doesn't validate required environment variables at startup.

**Files:** `server/lib/auth.ts`, `server/api/auth/[action].ts`

**Missing validations:**
- `JWT_SECRET` — used in line 24, no check if undefined
- `JWT_REFRESH_SECRET` — line 29, no check
- `DATABASE_URL` — Prisma uses this, but no early validation
- `GOOGLE_CLIENT_IDS` — optional but should warn if missing

**Current code:**
```typescript
export function generateTokenPair(userId: string) {
  const accessToken = jwt.sign({ sub: userId }, process.env.JWT_SECRET!, {
    expiresIn: "15m",
  });
  // Non-null assertion (!) hides missing env vars
}
```

**Problems:**
1. Using `!` non-null assertion hides undefined values
2. Errors occur at first request, not startup
3. Vercel deployment may succeed but crash immediately
4. No helpful error message if env vars misconfigured

**Impact:**
- Deployment appears successful but endpoints fail
- Hard to debug in Vercel logs
- Production incident if env vars accidentally omitted

**Fix approach:**
- Create `validateEnv()` function at server startup
- Check required vars: JWT_SECRET, JWT_REFRESH_SECRET, DATABASE_URL
- Warn if optional vars missing (GOOGLE_CLIENT_IDS)
- Exit with helpful error message if validation fails
- Call validateEnv() before Prisma initialization

---

## Password Validation — Weak Client-Side Only

**Issue:** Password validation is client-side only, with minimal server-side checks.

**Files:**
- `lib/screens/auth/register_screen.dart` (client validation)
- `server/api/auth/[action].ts` (server validation at line 52)

**Server validation:**
```typescript
if (typeof password !== "string" || password.length < 8) {
  errorResponse(res, 400, "Password must be at least 8 characters");
  return;
}
```

**Problems:**
1. Only checks length >= 8, no complexity requirements
2. No check for common patterns (password, 12345678, etc.)
3. No breached password check (haveibeenpwned API)
4. Easy to guess: user123456, password123
5. Dart client doesn't sync validation rules with server

**Impact:**
- Weak passwords accepted
- Account compromise risk
- No defense against bot account creation (with weak passwords)

**Fix approach:**
- Add server-side password strength requirements:
  - Min 10 characters
  - Require mix of uppercase, lowercase, numbers
  - Reject common patterns (password, qwerty, sequential numbers)
  - Optional: check against haveibeenpwned API
- Sync validation rules to client (API endpoint or constants)
- Show password strength meter on registration
- Implement rate limiting on registration endpoint (prevent bot attacks)

---

## Missing Indexes on Frequently Queried Fields

**Issue:** Some Prisma models lack indexes despite frequent queries.

**Files:** `server/prisma/schema.prisma`

**Missing indexes:**
- `UserActivityLog`: Has `@@index([userId, createdAt])` ✓ (good)
- `JournalEntry`: Has `@@index([userId, createdAt])` ✓ (good)
- `User.email`: No index — login query scans full table
- `UserHobby`: No index on `userId` — fetching user's hobbies scans full table
- `PersonalNote`: No index — fetching notes by hobby scans full table

**Queries affected:**
- Login: `findUnique(where: { email })` — slow if table grows
- Fetch user hobbies: `findMany(where: { userId })` — O(n) scan
- Fetch hobby notes: `findMany(where: { userId, hobbyId })` — O(n) scan

**Impact:**
- Slow login as user base grows
- Slow sync from server for user progress
- Database CPU spikes with lots of concurrent users

**Fix approach:**
- Add indexes:
  ```prisma
  model User {
    @@index([email])
  }
  model UserHobby {
    @@index([userId])
  }
  model PersonalNote {
    @@index([userId, hobbyId])
  }
  ```
- Run `prisma migrate dev` to create indexes in database
- Monitor query performance in production (Vercel Analytics + Neon dashboard)

---

## Streak Calculation — Server-Side Only, Not Real-Time

**Issue:** User streaks are computed server-side from activity log, but client has no real-time visibility.

**Files:**
- `server/prisma/schema.prisma` (UserHobby.streakDays field)
- `lib/models/hobby.dart` (UserHobby model)
- `lib/screens/profile/profile_screen.dart` (may display streak)

**Current state:**
- UserHobby.streakDays stored in database
- Server computes on hobby status changes
- Client fetches but doesn't compute locally

**Problems:**
1. Streak becomes stale after last API sync
2. Offline mode shows yesterday's streak
3. User can complete step at 11:59 PM, but streak won't update until next sync
4. No visual feedback that streak was earned

**Impact:**
- UX confusion: streaks look wrong if user offline for hours
- Gamification feedback delayed
- Batch 7 features (achievements, streaks) depend on real-time calculation

**Fix approach:**
- Server: Compute streak as activity count in last N consecutive days (not stored value)
- Client: Cache streak value but recalculate when activity log syncs
- UI: Show "pending" indicator if local activity not yet synced
- Batch 7: Add push notification when streak reaches milestones (7 days, 30 days, etc.)

---

## Router — No Deep Linking Support

**Issue:** GoRouter uses simple path-based routing without deep link handling for app-to-app navigation or notifications.

**Files:** `lib/router.dart`

**Current routes:** All hardcoded paths (e.g., `/hobby/{id}`, `/journal`)

**Missing:**
- Deep link URI scheme (e.g., `app.trysomething.com/hobby/coding`)
- Web subdomain support (e.g., web.trysomething.com)
- Notification payload routing (e.g., `{route: '/hobby', hobbyId: 'xyz'}`)
- Android intent filters

**Impact:**
- Can't share hobby links
- Notifications can't deep link to specific hobby
- Social features (Batch 6) can't share hobby combos
- Web version (if built) can't share URLs

**Fix approach:**
- Batch 8: Add deep link support
- Configure Android intent filters + iOS URL schemes
- Add query parameter support for deep links (e.g., `/hobby?id=xyz`)
- Implement notification click handler to route to specific screen
- Generate shareable links on profile + hobby detail screens

---

## SharedPreferences Keys — No Namespacing

**Issue:** SharedPreferences keys are not namespaced, risking collisions if multiple features use same key names.

**Files:** `lib/providers/user_provider.dart`

**Keys used:**
- `'onboarding_complete'` (line 28)
- `'user_preferences'` (line 54)
- `'user_hobbies'` (line 118)

**Problems:**
1. Generic names: another notifier or feature might use `'user_preferences'`
2. No clear ownership
3. If two features accidentally use same key, data corruption
4. Hard to clear feature-specific data for debugging

**Impact:**
- Risk of collision as more providers added
- Data corruption bug hard to trace

**Fix approach:**
- Use prefixed keys: `'user_provider.onboarding_complete'`, `'user_provider.preferences'`
- Or create constants file: `SharedPreferencesKeys` enum
- Document all keys in one place
- Add migration helper if key names change

---

## Hive Cache — No Eviction Policy

**Issue:** Hive cache for hobby content has no size limits or eviction policy.

**Files:** `lib/core/storage/cache_manager.dart`, `lib/data/repositories/hobby_repository_api.dart`

**Current usage:**
- Caches full hobby list + details
- No TTL
- No size limit
- No eviction on low disk space

**Problems:**
1. Cache grows unbounded on repeated updates
2. No cache invalidation strategy
3. Stale data can be served indefinitely
4. On low-disk devices, cache grows until storage full

**Impact:**
- Device storage bloat
- App becomes sluggish as cache size grows
- Users may need to clear app data to fix performance

**Fix approach:**
- Add TTL: invalidate hobby cache after 24 hours
- Add size limit: keep max 50MB of cached hobby data
- Implement LRU (least recently used) eviction
- Add `clearCache()` method for manual cache clear
- Monitor cache size in profile/settings screen
- Add cache stats for debugging

---

Summary of Priority Fixes:

**Critical (blocks deployment/production):**
1. Vercel 12-function limit — already at max, document consolidation strategy
2. Data sync without persistence — add pending queue
3. Auth token refresh race condition — add mutex

**High (impacts user data/experience):**
4. Error handling swallowed — add logging
5. Optimistic updates without proper cleanup — add pending flags
6. Google sign-in fallback fragility — add exception types

**Medium (affects Batch 4+ implementation):**
7. Activity log server implementation — complete CRUD
8. Notes provider server persistence — implement API
9. Feature providers still using seed data — plan server migration

**Low (technical debt, polish):**
10. Testing missing — add in Batch 8
11. CORS permissive — whitelist origins for prod
12. Password validation weak — add complexity checks
13. Missing database indexes — add for performance
14. Router deep linking — add in Batch 8

---

*Concerns audit: 2026-03-02*
