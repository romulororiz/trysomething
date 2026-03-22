---
phase: 09-app-store-assets-and-admin
plan: 01
subsystem: infra
tags: [ios, xcode, privacy-manifest, app-store, compliance]

requires:
  - phase: none
    provides: "No dependencies - standalone iOS project configuration"
provides:
  - "App-level Apple Privacy Manifest declaring UserDefaults API access (CA92.1)"
  - "iPhone-only device targeting (no iPad screenshots required)"
affects: [app-store-submission, ios-build]

tech-stack:
  added: []
  patterns: ["Apple Privacy Manifest for UserDefaults access declaration"]

key-files:
  created:
    - ios/Runner/PrivacyInfo.xcprivacy
  modified:
    - ios/Runner.xcodeproj/project.pbxproj

key-decisions:
  - "CA92.1 reason code covers Hive and SharedPreferences reading their own UserDefaults keys"
  - "NSPrivacyCollectedDataTypes left empty (data collection declared in App Store Connect, not manifest)"
  - "iPhone-only targeting eliminates iPad screenshot requirement for App Store submission"

metrics:
  duration: "2min"
  completed: "2026-03-22"
  tasks_completed: 2
  tasks_total: 2
  files_changed: 2
---

# Phase 09 Plan 01: Apple Privacy Manifest and iPhone-Only Targeting Summary

App-level PrivacyInfo.xcprivacy declaring UserDefaults access with CA92.1 reason, registered in Xcode project, plus iPhone-only device family targeting across all build configurations.

## What Was Done

### Task 1: Create PrivacyInfo.xcprivacy and register in Xcode project
**Commit:** `3073ec7`

Created `ios/Runner/PrivacyInfo.xcprivacy` with the required Apple Privacy Manifest structure:
- `NSPrivacyTracking` set to `false` (app does not track per ATT)
- `NSPrivacyTrackingDomains` empty (no tracking domains)
- `NSPrivacyCollectedDataTypes` empty (declared in App Store Connect instead)
- `NSPrivacyAccessedAPITypes` declares `NSPrivacyAccessedAPICategoryUserDefaults` with reason `CA92.1` ("Access info from the same app that wrote it") covering Hive and SharedPreferences

Registered the manifest in `ios/Runner.xcodeproj/project.pbxproj` with 4 entries:
1. PBXBuildFile entry (build resource reference)
2. PBXFileReference entry (file metadata)
3. PBXGroup Runner children (group membership)
4. PBXResourcesBuildPhase Runner Resources (build inclusion)

### Task 2: Change TARGETED_DEVICE_FAMILY to iPhone-only
**Commit:** `2fe7fa5`

Changed `TARGETED_DEVICE_FAMILY` from `"1,2"` (iPhone + iPad) to `"1"` (iPhone only) in all three build configurations:
- Profile (line 361)
- Debug (line 487)
- Release (line 540)

This eliminates the iPad screenshot requirement for App Store submission.

## Deviations from Plan

None - plan executed exactly as written.

## Verification Results

| Check | Result |
|-------|--------|
| PrivacyInfo.xcprivacy exists | PASS |
| Contains NSPrivacyAccessedAPICategoryUserDefaults | PASS |
| Contains CA92.1 reason code | PASS |
| 4+ references in project.pbxproj | PASS (4 references) |
| Zero TARGETED_DEVICE_FAMILY "1,2" occurrences | PASS (0) |
| Three TARGETED_DEVICE_FAMILY "1" occurrences | PASS (3) |

## Known Stubs

None - no stubs introduced.

## Commits

| Task | Commit | Message |
|------|--------|---------|
| 1 | `3073ec7` | feat(09-01): add Apple Privacy Manifest with UserDefaults CA92.1 declaration |
| 2 | `2fe7fa5` | chore(09-01): change TARGETED_DEVICE_FAMILY to iPhone-only |

## Self-Check: PASSED

All files exist. All commits verified.
