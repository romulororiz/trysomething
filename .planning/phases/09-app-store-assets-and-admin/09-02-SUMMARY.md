---
phase: 09-app-store-assets-and-admin
plan: 02
subsystem: admin
tags: [app-store, play-store, privacy-labels, data-safety, screenshots, metadata]

requires:
  - phase: 09-app-store-assets-and-admin
    plan: 01
    provides: "Apple Privacy Manifest and iPhone-only targeting"
provides:
  - "APP_STORE_CHECKLIST.md with complete App Store Connect submission guide"
  - "PLAY_STORE_CHECKLIST.md with complete Google Play Console submission guide"
  - "SCREENSHOT_GUIDE.md with capture instructions for both platforms"
affects: [app-store-submission]

tech-stack:
  added: []
  patterns: []

key-files:
  created:
    - .planning/phases/09-app-store-assets-and-admin/APP_STORE_CHECKLIST.md
    - .planning/phases/09-app-store-assets-and-admin/PLAY_STORE_CHECKLIST.md
    - .planning/phases/09-app-store-assets-and-admin/SCREENSHOT_GUIDE.md
  modified: []

key-decisions:
  - "All field values pre-determined — no TBD or placeholders in checklists"
  - "Subtitle 'Your 30-day hobby starter' (25 chars) instead of tagline (32 chars, over 30-char limit)"
  - "Demo account uses support@trysomething.io with active Photography hobby"

requirements-completed: [COMP-13, COMP-14]

metrics:
  duration: "manual"
  completed: "2026-03-22"
  tasks_completed: 2
  tasks_total: 2
  files_changed: 3
---

# Phase 09 Plan 02: Store Submission Checklists and Admin Summary

**App Store Connect checklist, Google Play Console checklist, and screenshot guide with all field values pre-determined for both platform submissions**

## What Was Done

### Task 1: Generate store submission checklists and screenshot guide

Created three reference documents:

- **APP_STORE_CHECKLIST.md** — iOS App Store Connect submission guide covering App Information, Version metadata, App Review Information (demo account), Age Rating (4+), App Privacy Labels (COMP-13: 8 data types declared), and screenshot upload instructions
- **PLAY_STORE_CHECKLIST.md** — Google Play Console submission guide covering Store Listing, Content Rating (Everyone), Data Safety Form (COMP-14: 6 data types declared with sharing and encryption details), and screenshot upload
- **SCREENSHOT_GUIDE.md** — Screenshot capture instructions for both platforms: 4 screens (Home, Discover, Detail, Session), iOS via iPhone 16 Pro Max Simulator at 1290x2796px, Android via Nothing Phone 3a, release build only, demo account setup steps

### Task 2: User completes store admin forms
Human completed all store admin forms following the generated checklists.

## Deviations from Plan

None — checklists generated as planned, user followed them for store submissions.

## Self-Check: PASSED

- All 3 checklist files exist on disk
- APP_STORE_CHECKLIST.md contains App Privacy section
- PLAY_STORE_CHECKLIST.md contains Data Safety section
- SCREENSHOT_GUIDE.md contains resolution specs and all 4 screens

---
*Phase: 09-app-store-assets-and-admin*
*Completed: 2026-03-22*
