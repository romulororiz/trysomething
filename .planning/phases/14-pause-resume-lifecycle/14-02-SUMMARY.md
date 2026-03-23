---
phase: 14-pause-resume-lifecycle
plan: 02
subsystem: ui
tags: [flutter, riverpod, dart, pause-resume, home-screen, you-screen, glass-card]

requires:
  - phase: 14-pause-resume-lifecycle
    plan: 01
    provides: "pauseHobby() and resumeHobby() methods on UserHobbiesNotifier"
  - phase: 11-schema-migration
    provides: "HobbyStatus.paused enum value, pausedAt/pausedDurationDays fields on UserHobby"
provides:
  - "Pause menu item in Home 3-dot menu (Pro-gated)"
  - "Pause confirmation bottom sheet with Pause and Cancel buttons"
  - "_PausedHobbyPage on Home showing muted card with PAUSED chip, days counter, Resume CTA"
  - "4-tab layout in You screen: Active / Paused / Saved / Tried"
  - "_PausedTabContent with paused hobby cards and Resume CTA"
affects: [home-screen, you-screen, ui-pause-resume]

tech-stack:
  added: []
  patterns:
    - "allDisplayEntries pattern: active + paused combined for PageView, paused rendered via separate widget"
    - "0.7 opacity wrapper for paused state visual differentiation"
    - "Coral at 15% opacity for non-destructive confirmation buttons (vs solid coral for destructive)"

key-files:
  created: []
  modified:
    - "lib/screens/home/home_screen.dart"
    - "lib/screens/you/you_screen.dart"

key-decisions:
  - "Pause button uses coral at 15% opacity (softer than destructive Stop which uses solid coral)"
  - "Paused Home page strips all content except image, title, chip, counter, and Resume CTA"
  - "Tab order Active/Paused/Saved/Tried chosen per research recommendation for discoverability"
  - "activeCount in profile header excludes paused hobbies after split"

patterns-established:
  - "Builder wrapper for scoped provider reads inside existing widget trees (isPro in PopupMenuButton)"
  - "allDisplayEntries pattern for mixed active+paused PageView rendering"

requirements-completed: [LIFE-02, LIFE-03, LIFE-04, LIFE-05]

duration: 7min
completed: 2026-03-23
---

# Phase 14 Plan 02: Pause/Resume UI Summary

**Pause/resume Flutter UI with Pro-gated menu item, confirmation sheet, muted paused-state page on Home, and 4-tab Paused filter in You screen**

## Performance

- **Duration:** 7 min
- **Started:** 2026-03-23T21:00:49Z
- **Completed:** 2026-03-23T21:08:03Z
- **Tasks:** 2
- **Files modified:** 2

## Accomplishments
- Added Pro-gated "Pause hobby" menu item to Home 3-dot PopupMenuButton with confirmation bottom sheet
- Built _PausedHobbyPage rendering paused hobbies at 0.7 opacity with PAUSED chip, days counter, and coral Resume CTA
- Split paused hobbies out of Active tab into dedicated Paused tab in You screen (4-tab layout)
- _PausedTabContent shows hobby cards with thumbnail, PAUSED chip, days counter, and one-tap Resume

## Task Commits

Each task was committed atomically:

1. **Task 1: Home screen -- pause menu, confirmation sheet, paused hobby page** - `68d0131` (feat)
2. **Task 2: You tab -- Paused filter tab and _PausedTabContent** - `7690fd6` (feat)

## Files Created/Modified
- `lib/screens/home/home_screen.dart` - Added _PausedHobbyPage, _showPauseConfirmation, allDisplayEntries combining active+paused, Pro-gated pause menu item
- `lib/screens/you/you_screen.dart` - Split pausedEntries from activeEntries, added _PausedTabContent, updated _TabPills to 4 tabs, shifted tab indices

## Decisions Made
- Pause confirmation button uses coral at 15% opacity (non-destructive feel) vs solid coral for Stop (destructive) -- visual hierarchy distinguishes the actions
- Paused Home page shows ONLY muted card with chip/counter/Resume -- no coach, roadmap, next step, or schedule
- Tab order Active/Paused/Saved/Tried places Paused adjacent to Active for quick toggling between current and paused states
- activeCount in profile header correctly excludes paused hobbies after the split (paused hobbies are not "active")
- Resume from both Home and You calls resumeHobby() with one tap, no confirmation per locked decision

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered
None

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- Phase 14 complete: full pause/resume lifecycle from data layer (Plan 01) through UI (Plan 02)
- All LIFE requirements met: LIFE-02 through LIFE-07
- Users can pause from Home 3-dot menu, see paused state, resume with one tap from Home or You tab

## Self-Check: PASSED

All artifacts verified:
- SUMMARY.md exists at expected path
- Both task commits found in git log (68d0131, 7690fd6)
- All key source files exist and analyze clean

---
*Phase: 14-pause-resume-lifecycle*
*Completed: 2026-03-23*
