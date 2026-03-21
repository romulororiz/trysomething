# Architecture Patterns

**Domain:** App store launch readiness — account deletion, data export, webhook verification, rate limiting
**Project:** TrySomething (Flutter + Vercel serverless + Prisma + Neon PostgreSQL)
**Researched:** 2026-03-21

---

## Recommended Architecture

The four new features integrate cleanly into the existing architecture without structural changes. The pattern is: new server-side handlers following the established `users/[path].ts` switch-case style, one new utility function in `server/lib/`, Prisma cascade via existing `onDelete: Cascade` declarations, and a thin Flutter client layer on top of the existing `AuthNotifier.logout()` flow.

### Component Boundaries

| Component | Responsibility | Communicates With |
|-----------|---------------|-------------------|
| `DELETE /api/users/me` | Cascade-delete all user data in one Prisma `$transaction`, return 200 | Prisma (14 tables), `users/[path].ts` handler |
| `GET /api/users/me/export` | Query 11 user tables in parallel via `Promise.all`, serialize to JSON | Prisma (11 tables), `users/[path].ts` handler |
| `handleRevenueCatWebhook` (enhanced) | Validate `Authorization: Bearer {secret}` header strictly (env var required), reject if missing | Existing handler in `users/[path].ts` |
| `checkCoachRateLimit()` in `server/lib/` | Count `GenerationLog` rows for user in rolling 30-day window, return bool | Prisma `GenerationLog`, called from `handleCoachChat` |
| `AuthNotifier.deleteAccount()` in Flutter | Call DELETE endpoint, then run same local cleanup as `logout()` | `auth_repository_api.dart`, `TokenStorage`, Hive boxes |

### Data Flow — Account Deletion

```
User taps "Delete Account" in settings_screen.dart
  → AuthNotifier.deleteAccount()
    → DELETE /api/users/me  (JWT required)
      → requireAuth() extracts userId
      → prisma.$transaction([
          prisma.generationLog.deleteMany({ where: { userId } }),  // no FK, must be explicit
          prisma.user.delete({ where: { id: userId } })            // cascades 13 relations
        ])
      → 200 {}
    ← success
  → TokenStorage.clearTokens()
  → CacheManager clear all Hive boxes
  → AuthState → unauthenticated
  → Router redirects to /login
```

**Why `$transaction` with explicit `generationLog.deleteMany` first:**
`GenerationLog` has no `@relation` to `User` in the schema — `userId` is a plain `String` field, not a foreign key. The database-level `onDelete: Cascade` does not apply to it. All other 13 user-owned tables already have `onDelete: Cascade` declared, so deleting `User` cascades them automatically at the database level. The transaction wraps both operations for atomicity.

**Tables covered by `onDelete: Cascade` on `User`:**
1. `UserPreference`
2. `UserHobby` (which cascades `UserCompletedStep` via its own `onDelete: Cascade`)
3. `UserActivityLog`
4. `JournalEntry`
5. `PersonalNote`
6. `ScheduleEvent`
7. `ShoppingCheck`
8. `CommunityStory` (which cascades `StoryReaction`)
9. `StoryReaction` (direct)
10. `BuddyPair` (requester relation)
11. `BuddyPair` (accepter relation — same table, two FK paths)
12. `UserChallenge`
13. `UserAchievement`

**Table requiring explicit delete:**
14. `GenerationLog` — plain `userId String`, no FK declared in schema

### Data Flow — Data Export

```
User taps "Export my data"
  → GET /api/users/me/export  (JWT required)
    → requireAuth() extracts userId
    → Promise.all([
        prisma.user.findUnique({ where: { id: userId }, include: { preferences: true } }),
        prisma.userHobby.findMany({ where: { userId }, include: { completedSteps: true } }),
        prisma.journalEntry.findMany({ where: { userId }, orderBy: { createdAt: 'asc' } }),
        prisma.personalNote.findMany({ where: { userId } }),
        prisma.scheduleEvent.findMany({ where: { userId } }),
        prisma.shoppingCheck.findMany({ where: { userId } }),
        prisma.userActivityLog.findMany({ where: { userId } }),
        prisma.communityStory.findMany({ where: { userId } }),
        prisma.userChallenge.findMany({ where: { userId } }),
        prisma.userAchievement.findMany({ where: { userId } }),
        prisma.generationLog.findMany({ where: { userId } }),
      ])
    → strip passwordHash, strip any tokens
    → return 200 JSON: { exportedAt, version: "1.0", profile, hobbies, journal, ... }
```

**Strategy: multiple parallel queries, buffered (not streaming).**
User data volume is small (hobby app, not a social network). A typical user has <50 journal entries, <20 hobbies, <100 activity logs. Buffered `Promise.all` over 11 queries is simpler and appropriate. Do not stream. The Vercel free tier function timeout is 10 seconds — parallel queries complete well within that for this data size.

**Response structure convention:**

```typescript
{
  exportedAt: string,       // ISO timestamp
  version: "1.0",
  profile: { ... },         // user + preferences, passwordHash stripped
  hobbies: [ ... ],         // UserHobby + completedSteps
  journal: [ ... ],
  notes: [ ... ],
  schedule: [ ... ],
  shopping: [ ... ],
  activityLog: [ ... ],
  stories: [ ... ],
  challenges: [ ... ],
  achievements: [ ... ],
  generationLog: [ ... ],
}
```

### Data Flow — Webhook Verification

The existing `handleRevenueCatWebhook` implementation in `users/[path].ts` already has the correct structure — it checks `Authorization: Bearer {secret}`. The current code only skips verification if `process.env.REVENUECAT_WEBHOOK_SECRET` is not set (the `if (secret)` guard). This is the gap.

**Current (broken):**
```typescript
if (secret) {
  // only validates if env var is present — silently accepts all traffic if missing
}
```

**Fixed:**
```typescript
const secret = process.env.REVENUECAT_WEBHOOK_SECRET;
if (!secret) {
  console.error('[RC Webhook] REVENUECAT_WEBHOOK_SECRET not configured');
  res.status(500).json({ error: 'Webhook not configured' });
  return;
}
const auth = req.headers.authorization;
if (!auth || auth !== `Bearer ${secret}`) {
  res.status(401).json({ error: 'Unauthorized' });
  return;
}
```

**RevenueCat verification model (MEDIUM confidence — verified via official docs):**
RevenueCat sends a configurable `Authorization` header with every webhook. There is no HMAC signature mechanism — the Authorization header bearer value IS the verification. The existing pattern is architecturally correct; the only fix is making the env var mandatory rather than optional.

### Data Flow — Coach Rate Limiting

The current coach handler has no rate limiting. The existing `GenerationLog` pattern in `handleGenerateHobby` (counting rows in a 24-hour window) is the right model. The coach needs the same pattern applied, but:
- Scope: 30-day rolling window (matches the "3 messages/month" free tier)
- Limit by tier: 3 per 30 days (free), unlimited (pro)
- Log table: reuse `GenerationLog` with `status: 'coach'` query identifier

**Pattern (new `checkCoachRateLimit` utility in `server/lib/`):**

```typescript
// server/lib/rate_limit.ts  (new file)
export async function checkCoachRateLimit(
  userId: string,
  isProUser: boolean
): Promise<{ allowed: boolean; remaining: number }> {
  if (isProUser) return { allowed: true, remaining: Infinity };

  const windowStart = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);
  const count = await prisma.generationLog.count({
    where: {
      userId,
      query: 'coach',          // distinguish from hobby generation
      status: 'success',
      createdAt: { gte: windowStart },
    },
  });

  const limit = 3;
  return { allowed: count < limit, remaining: Math.max(0, limit - count) };
}
```

**Call site in `handleCoachChat`:**
1. Fetch `userHobby.user.subscriptionTier` OR use a separate `prisma.user.findUnique` to get tier
2. Call `checkCoachRateLimit(userId, isPro)`
3. If not allowed: return 429 with `{ error: 'Coach limit reached (3/month on free plan)', remaining: 0 }`
4. On success: log to `GenerationLog` with `query: 'coach'`

**Why reuse `GenerationLog` instead of a new table:**
The table already exists with the right shape (`userId`, `query`, `status`, `createdAt`, `@@index([userId, createdAt])`). Adding a new table for coach rate limiting would require a migration with no benefit. The `query` field distinguishes coach events from hobby generation.

**Why database-backed instead of in-memory:**
Vercel serverless functions share no memory between invocations — even the same user hitting the same endpoint gets a fresh function instance. In-memory rate limiting would be silently ineffective. The `GenerationLog` index `@@index([userId, createdAt])` makes the count query fast (single index scan on a small table per user).

---

## New vs Modified Components

### New (Server)

| File | Type | Purpose |
|------|------|---------|
| `server/lib/rate_limit.ts` | New utility | `checkCoachRateLimit()` — reusable rate limit check against `GenerationLog` |
| `DELETE /api/users/me` handler | New switch case in `users/[path].ts` | Account deletion with cascading transaction |
| `GET /api/users/me/export` handler | New switch case in `users/[path].ts` | GDPR/FADP data export |

### Modified (Server)

| File | Change | Risk |
|------|--------|------|
| `server/api/users/[path].ts` | Add 3 new switch cases: `delete`, `export`, update webhook guard | LOW — additive changes |
| `server/api/generate/[action].ts` `handleCoachChat` | Add rate limit check via `checkCoachRateLimit()` | LOW — adds guard at top of function |
| `server/vercel.json` | Add route for `DELETE /api/users/me`, `GET /api/users/me/export`; add `|apple` to auth regex | LOW — additive routes |

### New (Flutter)

| File | Type | Purpose |
|------|------|---------|
| `lib/data/repositories/auth_repository.dart` | Interface update | Add `deleteAccount()` method signature |
| `lib/data/repositories/auth_repository_api.dart` | Impl update | Add `DELETE /api/users/me` call |
| `lib/core/api/api_constants.dart` | Constants update | Add `usersDelete`, `usersExport` endpoint paths |

### Modified (Flutter)

| File | Change | Risk |
|------|--------|------|
| `lib/providers/auth_provider.dart` `AuthNotifier` | Add `deleteAccount()` method — calls DELETE then runs logout cleanup | LOW — new method, no changes to existing |
| `lib/screens/settings/settings_screen.dart` | Add "Delete account" button → calls `AuthNotifier.deleteAccount()` | LOW — UI addition |

---

## Patterns to Follow

### Pattern 1: Switch Case Addition in `users/[path].ts`

All new user endpoints go into the existing consolidated handler. Follow the established pattern exactly:

```typescript
case "delete":
  return handleDeleteAccount(req, res);
case "export":
  return handleExportData(req, res);
```

Each handler function: `methodNotAllowed` check → `requireAuth` → try/catch with `console.error` → Prisma query → response.

**Why this file:** The project merges handlers to stay within Vercel's 12-function limit (free tier). Adding new files would consume function budget unnecessarily.

### Pattern 2: Prisma `$transaction` for Account Deletion

Use interactive transactions (callback style) rather than sequential array style. This allows referencing results between steps and provides better error messages:

```typescript
await prisma.$transaction(async (tx) => {
  // Must delete GenerationLog first — no FK cascade
  await tx.generationLog.deleteMany({ where: { userId } });
  // Delete user — cascades all 13 FK-linked tables at database level
  await tx.user.delete({ where: { id: userId } });
});
```

Do NOT manually delete the 13 FK-linked tables. They already have `onDelete: Cascade` in the Prisma schema, which generates `ON DELETE CASCADE` in the PostgreSQL migration. The database handles them atomically as part of the `DELETE FROM users WHERE id = ?` statement.

### Pattern 3: `Promise.all` for Data Export

```typescript
const [user, hobbies, journal, ...rest] = await Promise.all([
  prisma.user.findUnique({ ... }),
  prisma.userHobby.findMany({ ... }),
  prisma.journalEntry.findMany({ ... }),
  // ... 8 more
]);
```

Strip `passwordHash` before returning. Never return tokens (they are not persisted in the DB — they are stateless JWTs).

### Pattern 4: Rate Limit Check Pattern

The rate limit check in `handleGenerateHobby` (lines 94-105 of `generate/[action].ts`) is the reference implementation. The coach rate limit follows the same structure: count → compare → reject or proceed → log on success.

### Pattern 5: Flutter `deleteAccount()` Method

Mirror the existing `logout()` method with a server call prepended:

```dart
Future<bool> deleteAccount() async {
  try {
    await _repo.deleteAccount();  // DELETE /api/users/me
  } catch (e) {
    // Log error — account may already be deleted, proceed with local cleanup
    debugPrint('[Auth] deleteAccount server error: $e');
  }
  // Same cleanup as logout()
  _analytics?.trackEvent('account_deleted');
  _analytics?.setUserId(null);
  _subscriptions?.clearUser();
  await TokenStorage.clearTokens();
  await CacheManager.clearAll();  // needs new clearAll() method
  _googleSignIn.signOut().catchError((_) => null);
  state = const AuthState(status: AuthStatus.unauthenticated);
  return true;
}
```

**Note on `CacheManager.clearAll()`:** The existing `CacheManager` has no `clearAll()` method — only `invalidate(key)`. A new static method is needed that calls `_dataBox.clear()` and `_metaBox.clear()`. This is a 3-line addition.

---

## Anti-Patterns to Avoid

### Anti-Pattern 1: Manually Deleting All 14 Tables in Code

**What:** Writing 14 `deleteMany` calls in sequence before deleting User
**Why bad:** The schema already has `onDelete: Cascade` for 13 of them. Manual deletion is redundant, error-prone (wrong order = FK violation), and creates maintenance debt when new tables are added.
**Instead:** One `$transaction` with `generationLog.deleteMany` + `user.delete`. The database handles the rest.

### Anti-Pattern 2: Soft Delete for Account Deletion

**What:** Setting `deletedAt` timestamp instead of actually deleting data
**Why bad:** Apple's App Store requirement (since 2022) mandates actual data deletion, not soft delete. App review can reject for this. FADP Art. 25 also requires erasure.
**Instead:** Hard delete via `prisma.$transaction`. Irreversible. Require explicit confirmation UI before calling.

### Anti-Pattern 3: In-Memory Rate Limiting

**What:** Using a module-level Map or counter for rate limiting
**Why bad:** Vercel serverless functions have no shared memory. Each invocation is isolated. The counter resets on every cold start and is silently bypassed.
**Instead:** `GenerationLog` count query (already indexed). Adds ~2ms database roundtrip — acceptable.

### Anti-Pattern 4: New Vercel Function File for New Endpoints

**What:** Creating `server/api/users/delete.ts` and `server/api/users/export.ts` as separate files
**Why bad:** Vercel free tier hobby plan limits to 12 serverless functions. The project already merges into consolidated handlers for this reason (the comment in `users/[path].ts` line 1090 says "merged to stay within 12-function limit"). New files count against this limit.
**Instead:** Add switch cases to existing `users/[path].ts`.

### Anti-Pattern 5: Optional Webhook Secret

**What:** `if (secret) { /* validate */ }` — skipping validation when env var not set
**Why bad:** The webhook endpoint accepts all traffic silently when `REVENUECAT_WEBHOOK_SECRET` is unset. In production (or if the env var is misconfigured), anyone can trigger subscription state changes.
**Instead:** Fail hard at startup: return 500 if secret is not configured. This forces the env var to be set before the endpoint is reachable.

### Anti-Pattern 6: Streaming Export Response

**What:** Using Node.js streams or chunked transfer encoding for the export endpoint
**Why bad:** Adds complexity, and the data volume doesn't warrant it. A typical user has <500 total records. Vercel free tier functions have 1MB response limit — this is sufficient for a JSON export of hobby app data.
**Instead:** `Promise.all` + `res.json()`. Simple, debuggable, sufficient.

---

## Where New Endpoints Fit in Existing Structure

### `server/vercel.json` additions

```json
{ "src": "/api/users/me", "dest": "/api/users/[path].ts?path=me" },
```

The current `me` route only handles GET/PUT. The DELETE verb for account deletion should be handled by the same `path=me` route by adding `"DELETE"` to the `methodNotAllowed` allowed list, OR by a separate `path=delete` case. Recommended: separate `path=delete` to avoid changing existing `handleMe` logic:

```json
{ "src": "/api/users/delete", "dest": "/api/users/[path].ts?path=delete" },
{ "src": "/api/users/export", "dest": "/api/users/[path].ts?path=export" },
```

Also add `|apple` to the existing auth route regex (known bug from CONCERNS.md):
```json
{ "src": "/api/auth/(register|login|refresh|google|apple)", "dest": "/api/auth/[action].ts?action=$1" }
```

### `lib/core/api/api_constants.dart` additions

```dart
static const usersDelete = '/users/delete';
static const usersExport  = '/users/export';
```

---

## Build Order Rationale

Dependencies constrain this order:

1. **Server: webhook fix** — Smallest change (modify one conditional), no dependencies, blocks production security. Do first.

2. **Server: `rate_limit.ts` utility** — New file, no schema change needed, required by coach rate limit. Do before coach handler change.

3. **Server: coach rate limiting** — Imports `checkCoachRateLimit` from step 2. Requires `GenerationLog` table (already exists).

4. **Server: account deletion endpoint** — No dependencies on above. Schema already supports it (all `onDelete: Cascade` present). Add switch case + transaction.

5. **Server: data export endpoint** — No dependencies. Add switch case + `Promise.all` query.

6. **Server: `vercel.json` route additions** — Add after handlers exist (routes pointing to non-existent handlers fail silently but waste debugging time).

7. **Flutter: `CacheManager.clearAll()`** — Required by `deleteAccount()`. Add before `AuthNotifier` change.

8. **Flutter: `deleteAccount()` in `AuthNotifier`** — Requires CacheManager change (step 7), `auth_repository_api.dart` DELETE call. Add after server endpoint is deployed.

9. **Flutter: settings UI** — Delete account button + confirmation dialog. Requires `deleteAccount()` method (step 8).

10. **Flutter: export UI** — Settings entry that triggers export download / share sheet.

Steps 4-6 (server) and steps 7-9 (Flutter) are independent of each other and can be parallelized. Steps 1-3 (webhook + rate limit) should be done first as they are security-critical.

---

## Scalability Considerations

| Concern | At current scale (free tier) | If scale increases |
|---------|------------------------------|-------------------|
| Deletion cascade | Single transaction, instant | Still fast — Postgres handles cascade. Index on `userId` in all child tables |
| Export query | 11 parallel queries, <50ms | Add pagination param if response exceeds 1MB Vercel limit |
| Coach rate limit | Single count query, indexed | Already efficient. `@@index([userId, createdAt])` is present |
| Webhook security | Authorization header sufficient | If RevenueCat adds HMAC in future, add `x-revenuecat-signature` verification |

---

## Sources

- [Prisma Transactions reference](https://www.prisma.io/docs/orm/prisma-client/queries/transactions) — MEDIUM confidence (official, verified March 2026)
- [Prisma Cascading deletes discussion #5158](https://github.com/prisma/prisma/discussions/5158) — MEDIUM confidence (community, consistent with schema behavior)
- [RevenueCat Webhook docs](https://www.revenuecat.com/docs/integrations/webhooks) — MEDIUM confidence (official, fetched March 2026)
- [Vercel Rate Limiting KB](https://vercel.com/kb/guide/add-rate-limiting-vercel) — MEDIUM confidence (official)
- Schema analysis (`server/prisma/schema.prisma`) — HIGH confidence (direct source inspection)
- Handler analysis (`server/api/users/[path].ts`, `server/api/generate/[action].ts`) — HIGH confidence (direct source inspection)
- `vercel.json` function limit comment (line 1090 of `users/[path].ts`) — HIGH confidence (codebase comment)

---

*Architecture analysis: 2026-03-21*
