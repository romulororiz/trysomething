---
phase: 22-service-keys-build-pipeline
plan: 02
status: complete
started: 2026-03-27
completed: 2026-03-27
---

## Summary

Created build script with --dart-define injection for all 4 production keys. Release AAB builds successfully at 58.7MB with real production keys.

## Tasks Completed

| # | Task | Status |
|---|------|--------|
| 1 | Create build script and env template | ✓ Complete |
| 2 | Create build-release.env with real keys | ✓ All 4 keys filled |
| 3 | Smoke test — build release AAB | ✓ 58.7MB, release-signed with production keys |

## Key Files

- `scripts/build-release.sh` — Build script validating + injecting 4 --dart-define keys
- `scripts/build-release.env.example` — Template documenting required variables
- `scripts/build-release.env` — Real production keys (gitignored)
- `android/app/google-services.json` — Updated with release SHA fingerprints + OAuth clients

## Commits

- `68000b8` feat(22-02): create release build script with dart-define injection

## Self-Check: PASSED
- [x] Build script exists and validates all keys before building
- [x] Env template documents all required variables
- [x] build-release.env is gitignored
- [x] Running build script produces signed release AAB (58.7MB)
