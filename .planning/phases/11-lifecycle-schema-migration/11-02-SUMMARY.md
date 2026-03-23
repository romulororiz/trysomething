---
phase: 11-lifecycle-schema-migration
plan: 02
subsystem: models
tags: [dart, freezed, enum, riverpod, flutter]

# Dependency graph
requires:
  - phase: none
    provides: none
provides:
  - HobbyStatus.paused enum value in Dart
  - UserHobby model with completedAt, pausedAt, pausedDurationDays fields
  - All exhaustive switch statements handle paused
  - canStartHobbyProvider counts paused as active slot
affects: [12-completion-flow, 14-pause-resume]

# Tech tracking
tech-stack:
  added: []
  patterns: [enum-extension-with-switch-stubs]

key-files:
  created: []
  modified:
    - lib/models/hobby.dart
    - lib/models/hobby.freezed.dart
    - lib/models/hobby.g.dart
    - lib/screens/you/you_screen.dart
    - lib/screens/coach/hobby_coach_screen.dart
    - lib/core/notifications/notification_scheduler.dart
    - lib/providers/user_provider.dart

key-decisions:
  - "Paused hobbies appear in Active tab temporarily until Phase 14 adds dedicated Paused filter"
  - "Paused hobbies get same coach message limit as active (5 messages)"
  - "Paused hobbies receive no notification reminders (grouped with done)"
  - "Paused hobbies occupy the Free-tier active slot to prevent starting a second hobby"

patterns-established:
  - "Enum extension pattern: add value, regenerate codegen, stub all switches, patch providers"
  - "No default cases in exhaustive switches -- Dart 3 exhaustiveness is the safety net"

requirements-completed: [SCHM-01, SCHM-02]

# Metrics
duration: 29min
completed: 2026-03-23
---

# Phase 11 Plan 02: Dart Model Migration Summary

**HobbyStatus.paused enum with pause-tracking fields added to UserHobby Freezed model, all switch sites stubbed, Free-tier slot guard patched**

## Performance

- **Duration:** 29 min
- **Started:** 2026-03-23T11:26:15Z
- **Completed:** 2026-03-23T11:55:17Z
- **Tasks:** 3
- **Files modified:** 7

## Accomplishments
- Added `HobbyStatus.paused` between `active` and `done` in the Dart enum
- Added `completedAt`, `pausedAt`, and `pausedDurationDays` fields to UserHobby Freezed model with regenerated codegen
- Fixed all three exhaustive switch statements to handle the new `paused` value with appropriate stub behavior
- Patched `canStartHobbyProvider` to count paused hobbies as active-slot occupiers for Free users

## Task Commits

Each task was committed atomically:

1. **Task 1: Update Dart HobbyStatus enum and UserHobby model + codegen** - `670ca89` (feat)
2. **Task 2: Fix exhaustive switch statements for paused enum value** - `b19368e` (fix)
3. **Task 3: Patch canStartHobbyProvider to count paused as active slot** - `802dd6c` (fix)

## Files Created/Modified
- `lib/models/hobby.dart` - Added `paused` to HobbyStatus enum, added completedAt/pausedAt/pausedDurationDays to UserHobby
- `lib/models/hobby.freezed.dart` - Regenerated Freezed code with new fields and enum value
- `lib/models/hobby.g.dart` - Regenerated JSON serialization with new fields
- `lib/screens/you/you_screen.dart` - Paused hobbies fall through to Active tab
- `lib/screens/coach/hobby_coach_screen.dart` - Paused gets same message limit as active (5)
- `lib/core/notifications/notification_scheduler.dart` - Paused skips reminders (grouped with done)
- `lib/providers/user_provider.dart` - canStartHobbyProvider includes paused in active-slot filter

## Decisions Made
- Paused hobbies appear in the Active tab temporarily -- Phase 14 will add a dedicated Paused filter tab
- Paused hobbies get the same coach message limit (5) as active/trying -- this is the safe default
- Paused hobbies receive no notification reminders -- grouped with done in the switch to avoid nagging users who intentionally paused
- Paused hobbies occupy the Free-tier active slot -- prevents Free users from bypassing the 1-hobby limit by pausing and starting a new one

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered
None.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- Dart model is ready for Phase 12 (Completion Flow) to use `completedAt` field
- Dart model is ready for Phase 14 (Pause/Resume) to use `pausedAt` and `pausedDurationDays` fields
- All switch statements have stubs that Phase 14 will replace with full paused behavior
- `flutter analyze` passes with zero new errors (pre-existing firebase_options and unused element warnings remain)

## Self-Check: PASSED

All 8 files verified present. All 3 commit hashes verified in git log. All must-have patterns confirmed in source files.

---
*Phase: 11-lifecycle-schema-migration*
*Completed: 2026-03-23*
