---
phase: 05-account-deletion-flutter-ux
plan: 02
subsystem: settings-ui
tags: [account-deletion, settings, bottom-sheet, url-launcher]

requires:
  - phase: 05-account-deletion-flutter-ux
    plan: 01
    provides: AuthNotifier.deleteAccount(), AuthUser.hasPassword, CacheManager.clearAll()
provides:
  - "Delete account tile in Settings screen"
  - "Email user confirmation bottom sheet with password field"
  - "OAuth user confirmation bottom sheet without password field"
  - "30-day warning text and Manage Subscriptions link"
  - "Full local cleanup orchestration on successful deletion"
affects: [settings-screen, auth-flow]

tech-stack:
  added: []
  patterns:
    - "showAppSheet for both email and OAuth flows (user-approved deviation from D-02)"
    - "Platform-specific subscription management URLs"

key-files:
  created: []
  modified:
    - lib/screens/settings/settings_screen.dart

key-decisions:
  - "Both email and OAuth flows use showAppSheet instead of showAppConfirmDialog — D-05 tappable link requires widget builder"
  - "Platform.isIOS check for subscription management URL (Apple vs Google Play)"
  - "SharedPreferences.clear() and onboarding reset handled in Settings after provider deleteAccount() succeeds"

requirements-completed: [COMP-04, COMP-05]

metrics:
  duration: "4min"
  completed: "2026-03-22"
  tasks_completed: 2
  tasks_total: 2
  files_changed: 1
---

# Phase 5 Plan 2: Account Deletion Settings UI Summary

**Delete account tile, email/OAuth confirmation bottom sheets, 30-day warning, subscription link, and local cleanup orchestration in Settings screen**

## What Was Done

### Task 1: Add delete account UI to Settings screen
**Commit:** `2cfacef`

Added the complete account deletion flow to `settings_screen.dart`:

- **Delete account tile** below "Clear local data" with `delete_forever_outlined` icon and "Permanently delete your data" subtitle
- **`_handleDeleteAccount`** entry point — reads `user.hasPassword` to route to email or OAuth flow
- **Email user bottom sheet** (`_DeleteAccountSheetContent`) — password field, 30-day warning text, "Manage Subscriptions" tappable link, coral "Delete Account" CTA with loading spinner
- **OAuth user bottom sheet** (`_DeleteAccountDialogContent`) — same warning and subscription link but no password field, Cancel + Delete buttons
- **`_buildDeletionWarning`** — shared warning widget: "Your account will be scheduled for deletion. Your data will be permanently removed after 30 days." + "Active subscriptions are not automatically cancelled." + tappable "Manage Subscriptions" link
- **`_openSubscriptionManagement`** — opens `apps.apple.com/account/subscriptions` (iOS) or `play.google.com/store/account/subscriptions` (Android)
- **`_executeDeleteAccount`** — calls `authProvider.notifier.deleteAccount()`, then clears SharedPreferences, resets onboarding, shows snackbar, navigates to `/login`. On failure: error snackbar, no local data wiped.

### Task 2: Verify on device
Human verified the complete deletion flow on Nothing Phone 3a.

## Deviations from Plan

- Both flows use `showAppSheet` instead of D-02's `showAppConfirmDialog` — approved by user because `showAppConfirmDialog` only accepts plain `String message` and cannot render the tappable "Manage Subscriptions" `GestureDetector` required by D-05.

## Commits

| Task | Commit | Message |
|------|--------|---------|
| 1 | `2cfacef` | feat(05-02): add account deletion UI to Settings screen |

## Self-Check: PASSED

- Delete account code confirmed in `settings_screen.dart` (7 references)
- Commit `2cfacef` verified in git log on master

---
*Phase: 05-account-deletion-flutter-ux*
*Completed: 2026-03-22*
