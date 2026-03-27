---
phase: 21-server-deploy-fix-signing-foundation
plan: 01
status: complete
started: 2026-03-27
completed: 2026-03-27
---

## Summary

Configured release signing foundation: Vercel Root Directory set to `server/`, release keystore generated, Gradle signing config with key.properties + debug fallback, Proguard/R8 keep rules for all SDKs. Release AAB builds successfully at 57.6MB.

## Tasks Completed

| # | Task | Status |
|---|------|--------|
| 1 | Set Vercel Root Directory to server/ | ✓ Complete (manual — dashboard) |
| 2 | Generate release keystore | ✓ Complete (keytool, stored at android/keystores/) |
| 3 | Configure Gradle signing + Proguard | ✓ Complete |
| 4 | Verify release AAB build | ✓ Complete (57.6MB, release-signed) |

## Key Files

- `android/app/build.gradle.kts` — Release signing config from key.properties with debug fallback
- `android/app/proguard-rules.pro` — Keep rules for RevenueCat, Firebase, Sentry, PostHog, Google Sign-In, Play Core
- `android/key.properties` — Keystore path + passwords (gitignored)
- `android/keystores/trysomething/upload-keystore.jks` — Release upload keystore (gitignored)
- `.gitignore` — key.properties, keystores/, *.jks excluded

## Commits

- `c3ee459` feat(21-01): configure release signing and Proguard keep rules
- `9e1e4a9` fix(21-01): add Play Core dontwarn to fix R8 minification

## Deviations

- R8 failed on first attempt due to missing Play Core deferred component classes — added `-dontwarn com.google.android.play.core.**` to proguard-rules.pro
- Keystore path in key.properties needed `../` prefix because Gradle's `file()` resolves relative to `android/app/`, not `android/`

## Self-Check: PASSED
- [x] Vercel health endpoint responds after Root Directory change
- [x] Keystore generated and gitignored
- [x] key.properties gitignored
- [x] build.gradle.kts has signingConfigs.create("release")
- [x] proguard-rules.pro has keep rules for all SDKs
- [x] flutter build appbundle --release produces app-release.aab (57.6MB)
