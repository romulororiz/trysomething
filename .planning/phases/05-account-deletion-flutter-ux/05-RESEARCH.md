# Phase 5: Account Deletion -- Flutter UX - Research

**Researched:** 2026-03-21
**Domain:** Flutter account deletion UI, local storage cleanup, Riverpod state reset
**Confidence:** HIGH

## Summary

Phase 5 adds the Flutter client-side UX for account deletion, calling the Phase 4 backend `DELETE /api/users/me` endpoint, wiping all local data (Hive, SharedPreferences, secure storage), logging out of RevenueCat, and navigating to the login screen. The phase covers two requirements: COMP-04 (client-side storage cleanup) and COMP-05 (subscription warning UI).

The implementation is well-constrained by locked decisions from CONTEXT.md. The core challenge is split into three concerns: (1) determining auth method to show the right confirmation flow, (2) making the API call with correct parameters, and (3) executing a comprehensive local data wipe without leaving the app in a broken state. All the building blocks exist in the codebase already -- `showAppSheet`/`showAppConfirmDialog` for overlays, `TokenStorage.clearTokens()` for secure storage, `CacheManager` for Hive, `SubscriptionService.clearUser()` for RevenueCat, and the router redirect chain that sends unauthenticated users to `/login`.

**Primary recommendation:** Add `hasPassword` boolean to the `mapUser()` server response and `AuthUser` Freezed model so the Flutter client can detect email vs OAuth users without exposing sensitive fields. Use `showAppSheet` (not raw `showModalBottomSheet`) for the email user flow to get free keyboard accommodation. Use the existing `showAppConfirmDialog` for OAuth users exactly as the logout dialog does.

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
- **D-01:** Email users see a single bottom sheet (`showModalBottomSheet`) with warning text, password field, and "Delete Account" button. Uses the established bottom sheet pattern: `backgroundColor: Colors.transparent`, `isScrollControlled: true`, `barrierColor: Colors.black54`, container with `AppColors.surface`, `BorderRadius.vertical(top: Radius.circular(24))`, padding `fromLTRB(28, 28, 28, 40)`.
- **D-02:** OAuth users (Google/Apple) see `showAppConfirmDialog` -- no password field needed. The backend skips password verification for OAuth users (empty `passwordHash`). Detect auth method via `googleId`/`appleId` being non-null on the user model.
- **D-03:** The password field in the email bottom sheet sends `{ "password": "..." }` in the DELETE request body. OAuth users send no body (or `{}`).
- **D-04:** Warning text includes the 30-day timeline: "Your account will be scheduled for deletion. Your data will be permanently removed after 30 days. Active subscriptions are not automatically cancelled -- manage them in your device settings."
- **D-05:** A tappable "Manage Subscriptions" link opens the device's native subscription management page via `url_launcher`. iOS: `https://apps.apple.com/account/subscriptions`. Android: `https://play.google.com/store/account/subscriptions`.
- **D-06:** Same warning content appears in both the bottom sheet (email users) and `showAppConfirmDialog` (OAuth users).
- **D-07:** After successful deletion, navigate to the login screen (`/login`) and show a snackbar: "Account scheduled for deletion".
- **D-08:** Local cleanup sequence (same as `logout()` plus Hive): clear tokens (`TokenStorage.clearTokens()`), RevenueCat logout (`_subscriptions.clearUser()`), clear analytics identity, clear Hive boxes (`hobbies` + `cache_meta`), clear SharedPreferences keys, invalidate `onboardingCompleteProvider`, set auth state to `unauthenticated`.
- **D-09:** If the DELETE API call fails, show an error snackbar and do NOT wipe any local data. The user stays on the Settings screen.
- **D-10:** "Delete Account" tile placed directly below "Clear local data", before the footer. Uses the same `GestureDetector`/`Container` pattern with `AppColors.surfaceElevated` background. Icon: warning/trash in `AppColors.textMuted`. Text: "Delete account" with subtitle "Permanently delete your data".

### Claude's Discretion
- Loading state during deletion API call (spinner on button, disable interactions)
- Exact snackbar styling and duration
- Password field validation (empty check before submitting)
- Error message wording for API failures
- Platform detection for subscription management URL

### Deferred Ideas (OUT OF SCOPE)
- Data export UI (download button in Settings) -- could be a future phase
- Account recovery/undo within 30-day window -- explicitly rejected (D-03 from Phase 4: no undo)
- Photo/avatar cleanup from external storage -- future concern
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| COMP-04 | Account deletion clears all client-side storage (Hive, SharedPreferences, secure storage, RevenueCat logout) | Documented all cleanup targets in Architecture Patterns; Hive box names identified (`hobbies`, `cache_meta`); `CacheManager` needs `clearAll()` method per STATE.md |
| COMP-05 | Account deletion UI warns user to cancel subscription manually before proceeding | Warning text locked in D-04/D-05; platform-specific subscription management URLs verified; `url_launcher` already in pubspec |
</phase_requirements>

## Standard Stack

### Core (already in project)
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| flutter_riverpod | 2.6.1 | State management | Project standard; `AuthNotifier` is the auth state owner |
| go_router | 14.8.1 | Navigation | Project standard; router redirect handles unauth -> /login |
| dio | (project) | HTTP client | Project standard; `ApiClient.instance` singleton with interceptors |
| hive_flutter | 1.1.0 | Local key-value storage | Used for hobby cache and metadata |
| hive | 2.2.3 | Hive core | Direct box access for clearing |
| flutter_secure_storage | 9.2.4 | Token storage | Stores access/refresh JWT tokens |
| shared_preferences | 2.3.4 | Simple preferences | Onboarding state, notification prefs, user prefs |
| url_launcher | ^6.3.2 | Open URLs | Already used in settings for legal pages |
| purchases_flutter | 8.0.0 | RevenueCat SDK | `Purchases.logOut()` for subscription cleanup |
| freezed_annotation | (project) | Immutable models | `AuthUser` model needs new `hasPassword` field |

### No New Dependencies Needed
This phase requires zero new packages. Everything needed is already in the project.

## Architecture Patterns

### Critical Gap: Auth Method Detection

**Problem:** CONTEXT.md D-02 says "Detect auth method via `googleId`/`appleId` being non-null on the user model." However, the current `AuthUser` Freezed model does NOT contain `googleId` or `appleId`. The server `mapUser()` function does NOT return these fields -- it only returns `id`, `email`, `displayName`, `bio`, `avatarUrl`, `createdAt`.

**Furthermore:** `AuthMethod loadingMethod` on `AuthState` is transient -- it is set during login/register calls but resets to `AuthMethod.none` after app restart and `tryRestoreSession()`.

**Solution:** Add a `hasPassword` boolean to the server `mapUser()` response. This reveals whether password confirmation is needed without exposing sensitive `googleId`/`appleId`/`passwordHash` values. Then add `hasPassword` to the Flutter `AuthUser` model.

**Alternative (if server change is out of scope for Phase 5):** Always send the DELETE request first without password. If the server returns `400 "Password is required"`, show the password bottom sheet. This is a "try and fallback" approach. It works but adds a wasted round-trip for email users. Since Phase 5 explicitly depends on Phase 4, a small `mapUser()` tweak is acceptable.

**Recommendation:** Use `hasPassword` approach -- minimal server change (1 line in `mapUser()`), clean client logic, no wasted round-trips.

### Modification Pattern: Repository -> Provider -> Screen

```
1. auth_repository.dart       -- add deleteAccount({String? password}) abstract method
2. auth_repository_api.dart   -- implement with _dio.delete(ApiConstants.usersMe, data: ...)
3. auth_provider.dart         -- add deleteAccount({String? password}) on AuthNotifier
4. settings_screen.dart       -- add tile + show confirmation flow
5. server/lib/mappers.ts      -- add hasPassword to mapUser() (1 line)
6. lib/models/auth.dart       -- add hasPassword to AuthUser Freezed model
7. lib/core/storage/cache_manager.dart -- add clearAll() static method
```

### Tile Placement in Settings Screen

The "Delete Account" tile goes at line ~617 in `settings_screen.dart`, directly after the "Clear local data" `GestureDetector` and before the footer (line 619 `SizedBox(height: 32)`). The current layout order is:

```
Log out          (line 552-582)  -- AppColors.rose icon/text
Clear local data (line 587-617)  -- AppColors.textMuted icon, surfaceElevated bg
[INSERT HERE]    -- Delete account tile
App footer       (line 621-641)  -- logo + version
```

### Confirmation Flow Decision Tree

```
User taps "Delete Account"
  |
  +-- Is hasPassword true (email user)?
  |     YES -> showAppSheet with warning + password field
  |            User enters password -> call deleteAccount(password: pwd)
  |     NO  -> showAppConfirmDialog with warning text only
  |            User confirms -> call deleteAccount()
  |
  +-- API call result?
        SUCCESS -> clearAllLocalData() -> navigate /login -> snackbar
        FAILURE -> show error snackbar, change nothing
```

### Local Cleanup Sequence (Order Matters)

```dart
Future<void> _performLocalCleanup(WidgetRef ref) async {
  // 1. Clear secure tokens FIRST (prevents interceptor from using them)
  await TokenStorage.clearTokens();

  // 2. RevenueCat logout
  ref.read(subscriptionProvider).clearUser();

  // 3. Clear analytics identity
  ref.read(analyticsProvider).setUserId(null);

  // 4. Clear Hive boxes (hobby cache + metadata)
  await CacheManager.clearAll();  // NEW METHOD -- clears _dataBox + _metaBox

  // 5. Clear SharedPreferences
  final prefs = ref.read(sharedPreferencesProvider);
  await prefs.clear();

  // 6. Reset onboarding state
  ref.read(onboardingCompleteProvider.notifier).reset();

  // 7. Fire-and-forget Google sign out (same as logout())
  GoogleSignIn().signOut().catchError((_) => null);

  // 8. Set auth state to unauthenticated (triggers router redirect)
  ref.read(authProvider.notifier).logout();
}
```

**Important:** Do NOT call `ref.read(authProvider.notifier).logout()` alone -- it only clears tokens and RevenueCat but does NOT clear Hive boxes or SharedPreferences. The deletion cleanup is a superset of the logout cleanup.

### CacheManager.clearAll() -- New Method Needed

Per STATE.md: "`CacheManager` has no `clearAll()` method -- must be added (clears `_dataBox` and `_metaBox` Hive boxes)."

```dart
// Add to lib/core/storage/cache_manager.dart
static Future<void> clearAll() async {
  if (!_initialized) return;
  await _dataBox.clear();
  await _metaBox.clear();
}
```

### Platform-Specific Subscription Management URLs

```dart
import 'dart:io' show Platform;
import 'package:url_launcher/url_launcher.dart';

Future<void> _openSubscriptionManagement() async {
  final String url;
  if (Platform.isIOS) {
    url = 'https://apps.apple.com/account/subscriptions';
  } else {
    url = 'https://play.google.com/store/account/subscriptions';
  }
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
```

**Note:** `dart:io` `Platform` is already imported in `settings_screen.dart` (line 6: `import 'dart:io';`). The `url_launcher` is also already imported (line 25: `import 'package:url_launcher/url_launcher.dart';`). No new imports needed.

**URL reliability:** The iOS `https://apps.apple.com/account/subscriptions` URL is the documented standard and opens the Settings > Subscriptions page. The Android `https://play.google.com/store/account/subscriptions` opens Google Play's subscription manager. Both are HTTPS URLs that work via `url_launcher` without platform-specific URL schemes.

### Router Redirect -- Already Handles Auth State

The router at `lib/router.dart` line 444 has:
```dart
redirect: (context, state) {
  final auth = ref.read(authProvider);
  // ...
  if (auth.status == AuthStatus.unauthenticated) {
    if (!isAuthRoute && !isPublicRoute) return '/login';
    return null;
  }
```

When `authProvider` state changes to `unauthenticated`, the router redirects to `/login`. This means after calling `logout()` on the notifier, the redirect chain will automatically handle navigation. However, the CONTEXT.md D-07 specifies navigating explicitly to `/login` after deletion, which is fine as a safety measure -- `context.go('/login')` will work correctly alongside the redirect.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Bottom sheet with keyboard handling | Raw `showModalBottomSheet` with manual padding | `showAppSheet` from `app_overlays.dart` | Already handles `viewInsets.bottom` for keyboard, drag handle, consistent styling |
| Confirmation dialog | Custom dialog widget | `showAppConfirmDialog` from `app_overlays.dart` | Existing pattern with haptic feedback, animations, destructive styling |
| Snackbar messages | Raw `ScaffoldMessenger` calls | `showAppSnackbar` from `app_overlays.dart` | Consistent glass styling, proper dismiss behavior, type-based icons |
| Token cleanup | Manual `flutter_secure_storage` calls | `TokenStorage.clearTokens()` | Encapsulates both access and refresh key deletion |
| RevenueCat logout | Direct `Purchases.logOut()` | `SubscriptionService.clearUser()` | Wraps in try/catch, updates cached customer info |

**Key insight:** Every UI primitive needed for this phase already exists in `lib/components/app_overlays.dart`. The coding work is orchestration (calling things in the right order) not creation of new UI primitives.

## Common Pitfalls

### Pitfall 1: Premature Local Data Wipe
**What goes wrong:** App clears local data before confirming the API call succeeded, leaving the user logged out with their account still active.
**Why it happens:** Developers put cleanup logic inside the confirmation handler before the API response.
**How to avoid:** ALWAYS await the DELETE API call, check for success, and ONLY THEN execute the cleanup sequence. If the API call throws, show an error snackbar and return immediately.
**Warning signs:** Code that calls `TokenStorage.clearTokens()` before `await _dio.delete(...)`.

### Pitfall 2: Hive Box.clear() vs Hive.deleteBoxFromDisk()
**What goes wrong:** Using `Hive.deleteBoxFromDisk()` removes the box file, meaning subsequent reads crash with "Box has already been closed" or "Box not found". Using `box.clear()` is safe -- it empties the box but keeps it open for the app's remaining lifecycle.
**Why it happens:** Confusion between clearing data and removing the storage file.
**How to avoid:** Use `_dataBox.clear()` and `_metaBox.clear()` (which `CacheManager.clearAll()` wraps). Never use `Hive.deleteBoxFromDisk()` in a running app.
**Warning signs:** `Hive.deleteBoxFromDisk()` or `Hive.close()` calls outside of app shutdown.

### Pitfall 3: SharedPreferences.clear() Removes ALL Keys
**What goes wrong:** `SharedPreferences.clear()` deletes every key, including ones from third-party SDKs (PostHog, Firebase, etc.) that store internal state.
**Why it happens:** Some SDKs store internal state in SharedPreferences without documenting it.
**How to avoid:** For account deletion, `clear()` is actually the desired behavior -- we want a full reset. But be aware that after `clear()`, the app state should immediately transition to unauthenticated so SDK reinitialization happens on next launch.
**Warning signs:** Mysterious bugs in PostHog/Firebase after deletion -- they reinitialize on next app start.

### Pitfall 4: Bottom Sheet Keyboard Overlap
**What goes wrong:** Password `TextFormField` in a bottom sheet gets hidden behind the keyboard.
**Why it happens:** `showModalBottomSheet` without `isScrollControlled: true` doesn't resize for the keyboard.
**How to avoid:** Use `showAppSheet` which already sets `isScrollControlled: true` and includes `padding: EdgeInsets.only(bottom: bottomInset)` using `MediaQuery.of(context).viewInsets.bottom`. If using raw `showModalBottomSheet` as per CONTEXT.md D-01, wrap content in `Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom))`.
**Warning signs:** Password field not visible when keyboard opens.

### Pitfall 5: AuthUser Model Missing hasPassword
**What goes wrong:** No reliable way to determine if user is email vs OAuth on the client side, leading to incorrect confirmation flow.
**Why it happens:** The server `mapUser()` does not return `googleId`/`appleId`/`passwordHash` -- and shouldn't, as those are sensitive.
**How to avoid:** Add `hasPassword: !!u.passwordHash` to `mapUser()` server response. Add optional `bool? hasPassword` to `AuthUser` Freezed model. Default to `true` (show password field) if field is null for backwards compatibility.
**Warning signs:** `AuthUser` has no way to distinguish email from OAuth users.

### Pitfall 6: Snackbar After Navigation
**What goes wrong:** Calling `showAppSnackbar()` after `context.go('/login')` fails because the context is no longer mounted or the `ScaffoldMessenger` belongs to the old route.
**Why it happens:** Navigation replaces the widget tree, invalidating the old context.
**How to avoid:** Show the snackbar BEFORE navigating, or use `rootNavigatorKey` to get the root scaffold messenger, or use a `Future.microtask` approach where the snackbar is shown from the login screen. The simplest approach: show snackbar first, then navigate with a slight delay.
**Warning signs:** Snackbar never appears after successful deletion.

### Pitfall 7: Missing context.mounted Check
**What goes wrong:** Widget tree may have been disposed between the async API call and the navigation/snackbar call, causing "setState called after dispose" errors.
**Why it happens:** User closes the bottom sheet or navigates away while the DELETE request is in flight.
**How to avoid:** Always check `if (!context.mounted) return;` after every `await` call before accessing `context` or calling `setState`.
**Warning signs:** Red screen error or console warning about calling setState on disposed widget.

## Code Examples

### Repository Method (auth_repository.dart)
```dart
// Add to AuthRepository abstract class
Future<void> deleteAccount({String? password});
```

### Repository Implementation (auth_repository_api.dart)
```dart
@override
Future<void> deleteAccount({String? password}) async {
  await _dio.delete(
    ApiConstants.usersMe,
    data: password != null ? {'password': password} : null,
  );
}
```

### Provider Method (auth_provider.dart)
```dart
Future<bool> deleteAccount({String? password}) async {
  try {
    await _repo.deleteAccount(password: password);
    // Cleanup happens AFTER successful API call
    _analytics?.trackEvent('account_deleted');
    _analytics?.setUserId(null);
    _subscriptions?.clearUser();
    await TokenStorage.clearTokens();
    _googleSignIn.signOut().catchError((_) => null);
    state = const AuthState(status: AuthStatus.unauthenticated);
    return true;
  } catch (e) {
    return false;
  }
}
```

### CacheManager.clearAll() (cache_manager.dart)
```dart
/// Clear all cached data and metadata. Used during account deletion.
static Future<void> clearAll() async {
  if (!_initialized) return;
  await _dataBox.clear();
  await _metaBox.clear();
}
```

### AuthUser Model Update (auth.dart)
```dart
@freezed
class AuthUser with _$AuthUser {
  const factory AuthUser({
    required String id,
    required String email,
    required String displayName,
    @Default('') String bio,
    String? avatarUrl,
    String? createdAt,
    @Default(true) bool hasPassword,  // true for email users, false for OAuth-only
  }) = _AuthUser;

  factory AuthUser.fromJson(Map<String, dynamic> json) =>
      _$AuthUserFromJson(json);
}
```

### Server mapUser Update (mappers.ts)
```typescript
export function mapUser(u: PrismaUser) {
  return {
    id: u.id,
    email: u.email,
    displayName: u.displayName,
    bio: u.bio,
    avatarUrl: u.avatarUrl,
    createdAt: u.createdAt.toISOString(),
    hasPassword: !!u.passwordHash,  // NEW: true if user has password set
  };
}
```

### Settings Tile Pattern (settings_screen.dart)
```dart
// After "Clear local data" tile, before footer
GestureDetector(
  onTap: () => _handleDeleteAccount(context, ref),
  child: Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surfaceElevated,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      children: [
        const Icon(Icons.delete_forever_outlined,
            size: 20, color: AppColors.textMuted),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Delete account',
                style: AppTypography.sansLabel
                    .copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 2),
            Text('Permanently delete your data',
                style: AppTypography.sansTiny
                    .copyWith(color: AppColors.textMuted)),
          ],
        ),
      ],
    ),
  ),
),
```

### Warning Text with Tappable Link
```dart
// Common warning content for both flows
Widget _buildDeletionWarning(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Your account will be scheduled for deletion. Your data will be '
        'permanently removed after 30 days.',
        style: AppTypography.body.copyWith(
          color: AppColors.textSecondary,
          height: 1.5,
        ),
      ),
      const SizedBox(height: 12),
      Text(
        'Active subscriptions are not automatically cancelled.',
        style: AppTypography.body.copyWith(
          color: AppColors.textSecondary,
          height: 1.5,
        ),
      ),
      const SizedBox(height: 8),
      GestureDetector(
        onTap: _openSubscriptionManagement,
        child: Text(
          'Manage Subscriptions',
          style: AppTypography.body.copyWith(
            color: AppColors.accent,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    ],
  );
}
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `showModalBottomSheet` raw | `showAppSheet` wrapper | Sprint C (project-specific) | Handles keyboard insets, consistent styling |
| Check `googleId`/`appleId` on client | `hasPassword` boolean from server | This phase | Avoids exposing sensitive OAuth IDs to client |
| `Hive.deleteBoxFromDisk()` | `box.clear()` | Hive best practice | Keeps box open, prevents crashes |
| `SharedPreferences.remove(key)` per key | `SharedPreferences.clear()` | Account deletion requires full reset | Simpler, catches all keys |

## Open Questions

1. **showAppSheet vs raw showModalBottomSheet for email flow**
   - What we know: CONTEXT.md D-01 specifies the raw `showModalBottomSheet` pattern (matching `_showEditProfileSheet`). But `showAppSheet` in `app_overlays.dart` is the newer standard with built-in keyboard handling.
   - What's unclear: Whether the user strictly wants the raw pattern or would accept `showAppSheet` for better UX.
   - Recommendation: Use `showAppSheet` -- it already handles keyboard accommodation for the password field, has consistent glass styling, and is the established pattern in the codebase. The raw `showModalBottomSheet` approach from `_showEditProfileSheet` is an older pattern. If strict D-01 adherence is required, the raw approach works but needs manual keyboard padding.

2. **mapUser() server change in a Flutter-only phase**
   - What we know: Phase 5 is scoped as "Flutter UX" with no backend changes. But detecting auth method requires server cooperation.
   - What's unclear: Whether adding `hasPassword` to `mapUser()` is acceptable in Phase 5 scope.
   - Recommendation: Include the 1-line server change since it is necessary for correct Flutter behavior and cannot be worked around cleanly without it. Alternative: hardcode `hasPassword: true` as default and catch the 400 error to detect OAuth users at runtime.

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | flutter_test (built-in) |
| Config file | pubspec.yaml (dev_dependencies) |
| Quick run command | `flutter test test/unit/` |
| Full suite command | `flutter test` |

### Phase Requirements -> Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| COMP-04 | deleteAccount clears tokens, Hive, SharedPreferences, RevenueCat | unit | `flutter test test/unit/providers/auth_provider_test.dart -x` | Exists but needs new test cases (Wave 0) |
| COMP-04 | CacheManager.clearAll() empties both boxes | unit | `flutter test test/unit/core/cache_manager_test.dart -x` | Does not exist (Wave 0) |
| COMP-05 | Deletion warning includes subscription text | widget | `flutter test test/widget/screens/settings_deletion_test.dart -x` | Does not exist (Wave 0) |
| COMP-04 | AuthRepository.deleteAccount sends correct HTTP method/body | unit | `flutter test test/unit/repositories/auth_repository_api_test.dart -x` | Exists but needs new test cases (Wave 0) |
| COMP-05 | Platform-specific subscription URL opens correctly | unit | Manual-only -- `url_launcher` requires platform runner | N/A |

### Sampling Rate
- **Per task commit:** `dart analyze lib/path/to/changed_files.dart`
- **Per wave merge:** `flutter test`
- **Phase gate:** Full suite green before verification

### Wave 0 Gaps
- [ ] `test/unit/providers/auth_provider_test.dart` -- add `deleteAccount` test cases (success clears state, failure preserves state)
- [ ] `test/unit/repositories/auth_repository_api_test.dart` -- add `deleteAccount` HTTP method/body test
- [ ] Test for `CacheManager.clearAll()` -- verify both boxes emptied
- [ ] `AuthUser` serialization test update for new `hasPassword` field

## Sources

### Primary (HIGH confidence)
- Codebase inspection -- `lib/providers/auth_provider.dart`, `lib/screens/settings/settings_screen.dart`, `lib/components/app_overlays.dart`, `lib/core/storage/cache_manager.dart`, `lib/core/storage/local_storage.dart`, `lib/core/auth/token_storage.dart`, `lib/core/subscription/subscription_service.dart`, `lib/data/repositories/auth_repository.dart`, `lib/data/repositories/auth_repository_api.dart`, `lib/models/auth.dart`, `lib/router.dart`, `server/api/users/[path].ts`, `server/lib/mappers.ts`, `server/prisma/schema.prisma`
- Phase 4 CONTEXT.md -- backend contract, response format, password handling
- Phase 5 CONTEXT.md -- all locked decisions
- STATE.md -- `CacheManager` gap documented, architecture notes

### Secondary (MEDIUM confidence)
- [Apple Developer Documentation - Subscription Management Links](https://developer.apple.com/documentation/advancedcommerceapi/setupmanagesubscriptions) -- iOS subscription management URL
- [Hive GitHub Issues #219, #839](https://github.com/isar/hive/issues/219) -- Box clearing patterns
- [Flutter Platform Detection](https://www.flutterclutter.dev/flutter/tutorials/how-to-detect-what-platform-a-flutter-app-is-running-on/2020/127/) -- `dart:io` Platform vs defaultTargetPlatform

### Tertiary (LOW confidence)
- None -- all findings verified against codebase or official sources

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH -- all packages already in pubspec, versions verified
- Architecture: HIGH -- all integration points inspected in actual source code
- Pitfalls: HIGH -- derived from actual codebase patterns and Hive/Flutter known behaviors
- Auth method detection gap: HIGH -- verified by reading both `AuthUser` model and `mapUser()` server code

**Research date:** 2026-03-21
**Valid until:** 2026-04-21 (stable -- no fast-moving dependencies)
