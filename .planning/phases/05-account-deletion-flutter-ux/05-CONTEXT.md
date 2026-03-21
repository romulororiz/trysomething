# Phase 5: Account Deletion — Flutter UX - Context

**Gathered:** 2026-03-21
**Status:** Ready for planning

<domain>
## Phase Boundary

Flutter UX for account deletion. Settings screen gets a "Delete Account" option that calls the Phase 4 backend endpoint (`DELETE /api/users/me`), wipes all local data, and navigates to the login screen. No backend changes — Phase 4 delivered the server endpoint.

</domain>

<decisions>
## Implementation Decisions

### Confirmation flow — auth method split
- **D-01:** Email users see a single bottom sheet (`showModalBottomSheet`) with warning text, password field, and "Delete Account" button. Uses the established bottom sheet pattern: `backgroundColor: Colors.transparent`, `isScrollControlled: true`, `barrierColor: Colors.black54`, container with `AppColors.surface`, `BorderRadius.vertical(top: Radius.circular(24))`, padding `fromLTRB(28, 28, 28, 40)`.
- **D-02:** OAuth users (Google/Apple) see `showAppConfirmDialog` — no password field needed. The backend skips password verification for OAuth users (empty `passwordHash`). Detect auth method via `googleId`/`appleId` being non-null on the user model.
- **D-03:** The password field in the email bottom sheet sends `{ "password": "..." }` in the DELETE request body. OAuth users send no body (or `{}`).

### Warning content
- **D-04:** Warning text includes the 30-day timeline: "Your account will be scheduled for deletion. Your data will be permanently removed after 30 days. Active subscriptions are not automatically cancelled — manage them in your device settings."
- **D-05:** A tappable "Manage Subscriptions" link opens the device's native subscription management page via `url_launcher`. iOS: `https://apps.apple.com/account/subscriptions`. Android: `https://play.google.com/store/account/subscriptions`.
- **D-06:** Same warning content appears in both the bottom sheet (email users) and `showAppConfirmDialog` (OAuth users).

### Post-deletion behavior
- **D-07:** After successful deletion, navigate to the login screen (`/login`) and show a snackbar: "Account scheduled for deletion".
- **D-08:** Local cleanup sequence (same as `logout()` plus Hive): clear tokens (`TokenStorage.clearTokens()`), RevenueCat logout (`_subscriptions.clearUser()`), clear analytics identity, clear Hive boxes (`hobbies` + `cache_meta`), clear SharedPreferences keys, invalidate `onboardingCompleteProvider`, set auth state to `unauthenticated`.
- **D-09:** If the DELETE API call fails, show an error snackbar and do NOT wipe any local data. The user stays on the Settings screen.

### Settings screen placement
- **D-10:** "Delete Account" tile placed directly below "Clear local data", before the footer. Uses the same `GestureDetector`/`Container` pattern with `AppColors.surfaceElevated` background. Icon: warning/trash in `AppColors.textMuted`. Text: "Delete account" with subtitle "Permanently delete your data".

### Claude's Discretion
- Loading state during deletion API call (spinner on button, disable interactions)
- Exact snackbar styling and duration
- Password field validation (empty check before submitting)
- Error message wording for API failures
- Platform detection for subscription management URL

</decisions>

<specifics>
## Specific Ideas

- The `showAppConfirmDialog` from `lib/components/app_overlays.dart` is the existing primitive for destructive confirmations — uses `HapticFeedback.mediumImpact()`, `showGeneralDialog` with 82% black barrier
- The logout tile uses `AppColors.rose` for icon/text — "Delete Account" should NOT use rose (reserve that for logout), use `AppColors.textMuted` instead to keep it visually understated
- The backend returns `{ "status": "scheduled", "deletedAt": "...", "purgeAt": "..." }` on success — the purge date could be mentioned in the snackbar but keeping it simple ("Account scheduled for deletion") is preferred

</specifics>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Settings screen (primary modification target)
- `lib/screens/settings/settings_screen.dart` — Current layout, tile patterns, dialog/sheet patterns, logout flow

### Auth system
- `lib/providers/auth_provider.dart` — `AuthNotifier`, `logout()` method (cleanup reference), `AuthMethod` detection
- `lib/data/repositories/auth_repository.dart` — Abstract interface (needs `deleteAccount` method)
- `lib/data/repositories/auth_repository_api.dart` — Dio implementation (needs `deleteAccount` implementation)
- `lib/core/auth/token_storage.dart` — `clearTokens()` for secure storage cleanup

### Local storage (cleanup targets)
- `lib/core/storage/cache_manager.dart` — Hive box access, cache invalidation
- `lib/core/storage/local_storage.dart` — Box names (`hobbyBox`, `cacheMetaBox`)

### Subscription
- `lib/core/subscription/subscription_service.dart` — `clearUser()` method (RevenueCat logout)

### API
- `lib/core/api/api_constants.dart` — `usersMe` constant already exists
- `lib/core/api/api_client.dart` — Dio singleton with AuthInterceptor

### UI components
- `lib/components/app_overlays.dart` — `showAppConfirmDialog` for OAuth flow

### Phase 4 backend contract
- `.planning/phases/04-account-deletion-data-export-backend/04-CONTEXT.md` — Password requirement, response format, OAuth handling

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `showAppConfirmDialog()` — Destructive confirmation dialog with haptic feedback (OAuth deletion flow)
- `showModalBottomSheet` pattern — Used by `_showEditProfileSheet` and `_showAboutSheet` (email deletion flow)
- `logout()` in `AuthNotifier` — Full cleanup sequence to replicate + extend with Hive clearing
- `TokenStorage.clearTokens()` — Secure storage cleanup
- `SubscriptionService.clearUser()` — RevenueCat logout via `Purchases.logOut()`
- `ApiConstants.usersMe` — Already points to `/users/me`

### Established Patterns
- Settings tiles: `GestureDetector` → `Container` with `AppColors.surfaceElevated`, icon + text row
- Destructive actions: `AppColors.rose` for logout, `AppColors.textMuted` for less severe (clear data)
- Bottom sheets: `backgroundColor: Colors.transparent`, `isScrollControlled: true`, rounded top container
- Error handling: try/catch with snackbar on failure, no state change on error

### Integration Points
- `auth_repository.dart` — Add `deleteAccount({String? password})` abstract method
- `auth_repository_api.dart` — Implement with `_dio.delete(ApiConstants.usersMe, data: ...)`
- `auth_provider.dart` — Add `deleteAccount({String? password})` to `AuthNotifier`
- `settings_screen.dart` — Add tile + `_showDeleteAccountSheet` / `showAppConfirmDialog` branch
- `router.dart` — Ensure `/login` redirect works when auth state becomes `unauthenticated`

</code_context>

<deferred>
## Deferred Ideas

- Data export UI (download button in Settings) — could be a future phase
- Account recovery/undo within 30-day window — explicitly rejected (D-03 from Phase 4: no undo)
- Photo/avatar cleanup from external storage — future concern

</deferred>

---

*Phase: 05-account-deletion-flutter-ux*
*Context gathered: 2026-03-21*
