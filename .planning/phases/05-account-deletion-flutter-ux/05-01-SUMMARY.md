---
phase: 05-account-deletion-flutter-ux
plan: 01
subsystem: auth
tags: [account-deletion, freezed, hive, dio, riverpod, jwt]

# Dependency graph
requires:
  - phase: 04-account-deletion-data-export-backend
    provides: DELETE /api/users/me endpoint with soft-delete and password verification
provides:
  - hasPassword field in server mapUser() response
  - AuthUser model with hasPassword for OAuth vs email distinction
  - CacheManager.clearAll() for safe Hive box emptying
  - AuthRepository.deleteAccount() interface and API implementation
  - AuthNotifier.deleteAccount() with full local cleanup sequence
affects: [05-account-deletion-flutter-ux]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "API-first cleanup: call server before wiping local state"
    - "CacheManager.clearAll() uses box.clear() not deleteBoxFromDisk()"
    - "deleteAccount returns bool; SharedPrefs/onboarding left to caller (WidgetRef needed)"

key-files:
  created: []
  modified:
    - server/lib/mappers.ts
    - lib/models/auth.dart
    - lib/models/auth.freezed.dart
    - lib/models/auth.g.dart
    - lib/core/storage/cache_manager.dart
    - lib/data/repositories/auth_repository.dart
    - lib/data/repositories/auth_repository_api.dart
    - lib/providers/auth_provider.dart

key-decisions:
  - "Default hasPassword to true for backwards compat — shows password field if server hasn't deployed yet"
  - "Use box.clear() not deleteBoxFromDisk() for Hive — keeps boxes open, prevents crashes"
  - "deleteAccount() returns bool, leaves SharedPrefs/onboarding to caller — AuthNotifier has no WidgetRef"

patterns-established:
  - "API-first cleanup: server call must succeed before any local state is cleared"
  - "CacheManager.clearAll() empties both boxes without closing them"

requirements-completed: [COMP-04]

# Metrics
duration: 4min
completed: 2026-03-22
---

# Phase 5 Plan 1: Account Deletion Data Layer Summary

**hasPassword server field, AuthUser model update, CacheManager.clearAll(), and AuthNotifier.deleteAccount() with API-first cleanup sequence**

## Performance

- **Duration:** 4 min
- **Started:** 2026-03-22T07:10:10Z
- **Completed:** 2026-03-22T07:13:48Z
- **Tasks:** 2
- **Files modified:** 8

## Accomplishments
- Server mapUser() now returns hasPassword boolean derived from passwordHash presence, enabling the UI to distinguish email users from OAuth users
- CacheManager gained a clearAll() method that safely empties both Hive boxes without closing them
- Full deleteAccount data pipeline wired: AuthRepository interface, AuthRepositoryApi (Dio DELETE), and AuthNotifier with API-first cleanup of tokens, analytics, RevenueCat, and Hive cache

## Task Commits

Each task was committed atomically:

1. **Task 1: Add hasPassword to server mapper and Flutter AuthUser model** - `098ed53` (feat)
2. **Task 2: Add CacheManager.clearAll(), repository deleteAccount(), and provider deleteAccount()** - `3448067` (feat)

## Files Created/Modified
- `server/lib/mappers.ts` - Added passwordHash? to PrismaUser type and hasPassword: !!u.passwordHash to mapUser()
- `lib/models/auth.dart` - Added @Default(true) bool hasPassword to AuthUser freezed model
- `lib/models/auth.freezed.dart` - Regenerated freezed code with hasPassword field
- `lib/models/auth.g.dart` - Regenerated JSON serialization with hasPassword field
- `lib/core/storage/cache_manager.dart` - Added clearAll() static method using box.clear()
- `lib/data/repositories/auth_repository.dart` - Added deleteAccount({String? password}) abstract method
- `lib/data/repositories/auth_repository_api.dart` - Added deleteAccount implementation with Dio DELETE to /users/me
- `lib/providers/auth_provider.dart` - Added deleteAccount() with full cleanup sequence and CacheManager import

## Decisions Made
- Default hasPassword to true for backwards compatibility -- if server hasn't deployed yet, the field will be missing from JSON and the model will assume email user (safer: shows password field rather than skipping it)
- Use box.clear() not deleteBoxFromDisk() for Hive -- clear empties the box but keeps it open, preventing "Box has already been closed" crashes on subsequent cache operations
- deleteAccount() returns bool and leaves SharedPreferences/onboarding reset to caller -- AuthNotifier has no WidgetRef access, so the Settings screen (Plan 02) will handle those before navigating

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness
- Data layer complete and ready for Plan 02 (Settings UI) to consume
- AuthNotifier.deleteAccount() is the single entry point the Settings screen will call
- hasPassword boolean enables the UI to conditionally show/hide password confirmation field
- CacheManager.clearAll() wired into deleteAccount cleanup sequence

## Self-Check: PASSED

- All 8 modified files exist on disk
- Commit 098ed53 (Task 1) found in git log
- Commit 3448067 (Task 2) found in git log

---
*Phase: 05-account-deletion-flutter-ux*
*Completed: 2026-03-22*
