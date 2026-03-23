---
phase: 14-pause-resume-lifecycle
plan: 01
subsystem: api
tags: [dart, riverpod, prisma, vercel, revenuecat, webhook, pause-resume]

requires:
  - phase: 11-schema-migration
    provides: "HobbyStatus.paused enum value, pausedAt/pausedDurationDays/lastActivityAt schema fields"
  - phase: 12-completion-flow-stop
    provides: "stopHobby fire-and-forget pattern, toggleStep (UserHobby, bool) record return type"
provides:
  - "pauseHobby() and resumeHobby() methods on UserHobbiesNotifier"
  - "Repository interface and API impl with pause fields (pausedAt, pausedDurationDays, lastActivityAt)"
  - "Server PUT handler accepting and persisting all three pause fields"
  - "EXPIRATION webhook auto-resume logic for paused hobbies (LIFE-06)"
affects: [14-02-PLAN, ui-pause-resume]

tech-stack:
  added: []
  patterns:
    - "Optimistic fire-and-forget for pauseHobby/resumeHobby (same as stopHobby)"
    - "Explicit null in Dio body to clear server-side nullable fields on resume"
    - "Per-row computation in webhook loop (not updateMany) for accumulated pausedDurationDays"

key-files:
  created: []
  modified:
    - "lib/data/repositories/user_progress_repository.dart"
    - "lib/data/repositories/user_progress_repository_api.dart"
    - "lib/providers/user_provider.dart"
    - "server/api/users/[path].ts"
    - "test/unit/repositories/user_progress_repository_api_test.dart"
    - "test/unit/providers/user_hobbies_notifier_test.dart"
    - "server/test/webhook-auth.test.ts"

key-decisions:
  - "Resume always restores to HobbyStatus.trying (not active) per LIFE-03"
  - "No Pro gate on resumeHobby -- resume is always free, pause initiation is UI-gated"
  - "Explicit null sent for pausedAt on resume to clear server value"
  - "EXPIRATION auto-resume uses loop (not updateMany) for per-row pausedDurationDays accumulation"

patterns-established:
  - "vi.mock path for server tests uses ../lib/db (relative to test dir), not ../../lib/db"

requirements-completed: [LIFE-02, LIFE-03, LIFE-06, LIFE-07]

duration: 12min
completed: 2026-03-23
---

# Phase 14 Plan 01: Pause/Resume Data Layer Summary

**Pause/resume data layer with optimistic state updates, server-side persistence of pause fields, and RevenueCat EXPIRATION auto-resume webhook**

## Performance

- **Duration:** 12 min
- **Started:** 2026-03-23T20:20:26Z
- **Completed:** 2026-03-23T20:33:00Z
- **Tasks:** 3
- **Files modified:** 7

## Accomplishments
- Fixed pre-existing test breakage from Phase 11 (HobbyStatus enum count, mock return types, mock signatures)
- Extended repository interface, API impl, and server PUT handler with pausedAt, pausedDurationDays, lastActivityAt fields
- Added pauseHobby() and resumeHobby() methods to UserHobbiesNotifier following established fire-and-forget pattern
- Implemented EXPIRATION webhook auto-resume logic that accumulates pausedDurationDays per hobby (LIFE-06)
- All tests green: 9/9 repo tests, 19/19 notifier tests, 6/6 webhook tests

## Task Commits

Each task was committed atomically:

1. **Task 0: Fix pre-existing test breakage in 3 test files** - `84ed3d5` (fix)
2. **Task 1: Extend repository interface and API impl with pause fields + server PUT handler** - `f7af911` (feat)
3. **Task 2: Add pauseHobby and resumeHobby to UserHobbiesNotifier** - `27c9c75` (feat)

## Files Created/Modified
- `lib/data/repositories/user_progress_repository.dart` - Added pausedAt, pausedDurationDays, lastActivityAt optional params to updateStatus
- `lib/data/repositories/user_progress_repository_api.dart` - API impl sends pause fields in PUT body, explicit null for pausedAt on resume
- `lib/providers/user_provider.dart` - pauseHobby() and resumeHobby() methods with optimistic state + fire-and-forget API
- `server/api/users/[path].ts` - PUT handler destructures pause fields; EXPIRATION webhook auto-resumes paused hobbies
- `test/unit/repositories/user_progress_repository_api_test.dart` - HobbyStatus enum assertion updated to 5 values
- `test/unit/providers/user_hobbies_notifier_test.dart` - Mock updateStatus/toggleStep signatures fixed
- `server/test/webhook-auth.test.ts` - Added userHobby to Prisma mock, EXPIRATION auto-resume test, fixed mock path

## Decisions Made
- Resume restores to HobbyStatus.trying (not active) per LIFE-03 -- the "active" state is only set by setActive()
- No Pro gate on resumeHobby -- resume is always free per locked decision; pause initiation gating is UI-only
- Explicit null sent for pausedAt in Dio body on resume -- uses conditional `if (pausedAt == null && lastActivityAt != null)` to distinguish resume from normal status update
- EXPIRATION auto-resume uses a for-loop (not updateMany) because pausedDurationDays needs per-row computation from each hobby's pausedAt
- Fixed vi.mock path resolution: server tests should use `../lib/db` (from test/ to lib/), not `../../lib/db` (which resolved outside server/)

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Fixed vi.mock path resolution in webhook test**
- **Found during:** Task 1 (webhook test verification)
- **Issue:** vi.mock("../../lib/db") resolved to Flutter's lib/db from test directory, not server/lib/db. Existing tests passed only because they never reached Prisma calls. New EXPIRATION test hit real Prisma engine.
- **Fix:** Changed mock path to "../lib/db" and used vi.doMock for fresh mock instance in EXPIRATION test
- **Files modified:** server/test/webhook-auth.test.ts
- **Verification:** All 6 webhook tests pass including EXPIRATION auto-resume
- **Committed in:** f7af911 (Task 1 commit)

**2. [Rule 1 - Bug] Fixed _ServerDataRepo helper in notifier test**
- **Found during:** Task 0 (test fix)
- **Issue:** _ServerDataRepo helper class at bottom of user_hobbies_notifier_test.dart had stale updateStatus and toggleStep signatures matching Phase 11 pre-changes
- **Fix:** Updated updateStatus to include pause params, toggleStep to return (UserHobby, bool) record
- **Files modified:** test/unit/providers/user_hobbies_notifier_test.dart
- **Verification:** All 19 notifier tests pass
- **Committed in:** 84ed3d5 (Task 0 commit)

---

**Total deviations:** 2 auto-fixed (1 blocking, 1 bug)
**Impact on plan:** Both auto-fixes necessary for test correctness. No scope creep.

## Issues Encountered
- Prisma engine binary incompatible with Windows ARM (pre-existing) causes PrismaClientInitializationError when mocks fail to intercept. Resolved by fixing mock path resolution.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- Data layer complete: pauseHobby()/resumeHobby() ready for UI consumption in Plan 02
- Repository, API, and server all accept pause lifecycle fields
- EXPIRATION webhook handles Pro lapse gracefully
- Plan 02 can build UI (pause button, resume card, paused filter) calling these methods directly

## Self-Check: PASSED

All artifacts verified:
- SUMMARY.md exists at expected path
- All 3 task commits found in git log (84ed3d5, f7af911, 27c9c75)
- All key source files exist and analyze clean

---
*Phase: 14-pause-resume-lifecycle*
*Completed: 2026-03-23*
