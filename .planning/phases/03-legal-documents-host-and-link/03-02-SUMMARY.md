---
phase: 03-legal-documents-host-and-link
plan: 02
subsystem: ui
tags: [url_launcher, flutter, legal, compliance, deep-linking]

# Dependency graph
requires:
  - phase: 03-legal-documents-host-and-link plan 01
    provides: hosted legal pages at trysomething.app/terms and trysomething.app/privacy
provides:
  - All 6 in-app legal link tap handlers open hosted URLs via device browser
  - Settings, register, and login screens use url_launcher with LaunchMode.externalApplication
affects: []

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "url_launcher with canLaunchUrl guard and LaunchMode.externalApplication for external links"

key-files:
  created: []
  modified:
    - lib/screens/settings/settings_screen.dart
    - lib/screens/auth/register_screen.dart
    - lib/screens/auth/login_screen.dart

key-decisions:
  - "Used _openLegalPage helper in settings for DRY; inline in auth screens since TapGestureRecognizer requires different pattern"

patterns-established:
  - "Legal URLs: trysomething.app/terms and trysomething.app/privacy opened via url_launcher"

requirements-completed: [COMP-11]

# Metrics
duration: 2min
completed: 2026-03-21
---

# Phase 3 Plan 2: In-App Legal Links Summary

**All 6 legal link tap handlers updated to open hosted pages at trysomething.app via url_launcher in device browser**

## Performance

- **Duration:** 2 min
- **Started:** 2026-03-21T19:52:01Z
- **Completed:** 2026-03-21T19:54:09Z
- **Tasks:** 2
- **Files modified:** 3

## Accomplishments
- Settings About sheet Privacy Policy and Terms of Service links now open hosted URLs in external browser
- Register screen legal links (Terms of Service, Privacy Policy) open hosted URLs in external browser
- Login screen legal links (Terms of Service, Privacy Policy) open hosted URLs in external browser
- In-app legal screen files and router routes preserved (not deleted)

## Task Commits

Each task was committed atomically:

1. **Task 1: Update settings screen to open legal pages in external browser** - `5cb92e8` (feat)
2. **Task 2: Update register and login screens to open legal pages in external browser** - `11ba722` (feat)

## Files Created/Modified
- `lib/screens/settings/settings_screen.dart` - Added url_launcher import, _openLegalPage helper, replaced 2 context.push calls with hosted URL launches
- `lib/screens/auth/register_screen.dart` - Added url_launcher import, replaced 2 TapGestureRecognizer handlers with inline launchUrl calls
- `lib/screens/auth/login_screen.dart` - Added url_launcher import, replaced 2 TapGestureRecognizer handlers with inline launchUrl calls

## Decisions Made
- Used `_openLegalPage` helper method in settings_screen.dart for cleaner code since it has a class-level state; used inline async closures in auth screens since TapGestureRecognizer onTap handlers benefit from self-contained logic
- Kept go_router imports in all files since they are used for other navigation (not just legal links)

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered
None

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- All legal document links across the app now point to hosted URLs
- Combined with Plan 01 (hosting), Phase 3 legal document compliance is complete
- Ready for Phase 4 (account deletion + data export backend)

## Self-Check: PASSED

- All 3 modified files exist on disk
- Both task commits (5cb92e8, 11ba722) found in git history
- SUMMARY.md created at expected path

---
*Phase: 03-legal-documents-host-and-link*
*Completed: 2026-03-21*
