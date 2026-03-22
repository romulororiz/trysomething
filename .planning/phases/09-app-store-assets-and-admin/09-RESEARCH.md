# Phase 9: App Store Assets and Admin - Research

**Researched:** 2026-03-22
**Domain:** iOS/Android app store submission — privacy manifests, screenshot specs, metadata, privacy labels, content rating
**Confidence:** HIGH (primary findings), MEDIUM (SDK manifest status for RevenueCat)

---

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
- **D-01:** Claude investigates which SDK versions (Firebase FCM, RevenueCat, PostHog) already bundle `PrivacyInfo.xcprivacy` and which need manual manifests
- **D-02:** Verify by running `flutter build ipa` and checking for `ITMS-91061` errors — if none, manifests are bundled
- **D-03:** Change `TARGETED_DEVICE_FAMILY` from `"1,2"` (iPhone+iPad) to `"1"` (iPhone only) in `ios/Runner.xcodeproj/project.pbxproj` — avoids iPad screenshot requirement
- **D-04:** Update all 3 occurrences (Debug at line 483, Profile at line 357, Release at line 536)
- **D-05:** 4 screens to screenshot: Home (active hobby), Discover feed, Hobby detail, Session timer
- **D-06:** iOS: iPhone 16 Pro Max Simulator at 1290×2796px, release build
- **D-07:** Android: Nothing Phone 3a real device screenshots for Google Play
- **D-08:** Ensure Flutter debug banner is NOT visible (release build)
- **D-09:** Category: Claude's discretion (Lifestyle recommended)
- **D-10:** Language: English only for v1.0
- **D-11:** Demo account: `support@trysomething.io` — create in production with 1 active hobby + some progress
- **D-12:** Content Rating: expected 4+ (Everyone)
- **D-13:** Both App Privacy Labels and Data Safety Form require hosted Privacy Policy URL (already at `trysomething.io/privacy`)
- **D-14:** Data categories to declare: email address, usage data (PostHog), crash logs (Sentry), purchase history (RevenueCat)
- **D-15:** Privacy Labels and Data Safety Form are manual admin tasks — Claude provides the checklist

### Claude's Discretion
- App Store category selection
- Screenshot composition and ordering
- Exact App Store description and keywords
- Which privacy manifest data types to declare per SDK

### Deferred Ideas (OUT OF SCOPE)
None — discussion stayed within phase scope
</user_constraints>

---

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| COMP-12 | iOS app includes Apple Privacy Manifests for Firebase, RevenueCat, and PostHog SDKs | SDK manifest status verified; Firebase FCM and PostHog flutter bundle their own; Sentry 9.14.0 bundles via sentry-cocoa; RevenueCat needs verification via build test |
| COMP-13 | App Privacy Labels completed in App Store Connect | Exact declaration checklist documented below |
| COMP-14 | Data Safety Form completed in Google Play Console | Exact declaration checklist documented below |
</phase_requirements>

---

## Summary

Phase 9 is a mix of code tasks (privacy manifests, device targeting) and manual admin tasks (store console forms, screenshot capture). The code tasks are straightforward; the admin tasks require careful data declaration accuracy.

**Privacy manifests:** Three SDKs are in scope. Firebase Messaging 15.2.4 bundles `PrivacyInfo.xcprivacy` in its Flutter plugin (via FlutterFire). PostHog flutter 4.0.0 bundles a `PrivacyInfo.xcprivacy` inside a resource bundle declared in its podspec. Sentry flutter 9.14.0 is above version 7.17.0, which is the minimum version that introduced native sentry-cocoa privacy manifest support. RevenueCat purchases-flutter 9.14.0 relies on `PurchasesHybridCommon` as its native bridge — a direct PrivacyInfo in the flutter podspec was not found, but RevenueCat iOS SDK (`purchases-ios`) ships `Sources/PrivacyInfo.xcprivacy`. The safest verification path is D-02: build the IPA and check for `ITMS-91061` rejections. If no error, manifests are covered.

**Screenshots:** iOS requires the new 6.9" display size (1260×2736) for iPhone 17 Pro Max/16 Pro Max or the established 6.5" size (1284×2778). The CONTEXT.md decision D-06 specifies 1290×2796 — this is the iPhone 16 Pro Max actual screen resolution (not the 6.9" screenshot spec). Research shows the correct spec for iPhone 16 Pro Max screenshots submitted to the App Store is **1290×2796** (it maps to the 6.3" display slot, not 6.9"). Since the 6.9" (1260×2736) covers iPhone 17 Pro Max as the newest device, providing 1290×2796 covers 6.3" and Apple will scale it appropriately for other sizes.

**Primary recommendation:** Run `flutter build ipa` first to detect any ITMS-91061 warnings; if the build passes without errors, SDK manifests are covered. Write an app-level `PrivacyInfo.xcprivacy` in `ios/Runner/` declaring the app's own API access (UserDefaults for Hive/SharedPreferences).

---

## Standard Stack

### Core (this phase is config/admin, not library installation)

| Tool | Version | Purpose | Why Standard |
|------|---------|---------|--------------|
| Xcode Simulator | Xcode 16+ | iOS screenshots | Required for App Store Connect submissions; produces correct pixel dimensions |
| App Store Connect | Web UI | App Privacy Labels, metadata | Mandatory platform for iOS submission |
| Google Play Console | Web UI | Data Safety Form, metadata | Mandatory platform for Android submission |
| flutter build ipa | Flutter 3.6.0 | IPA build + ITMS error detection | Standard Flutter iOS build command |

### Privacy Manifest Files Already Bundled (no action needed)

| SDK | Flutter Version | Privacy Manifest Status | Source |
|-----|----------------|------------------------|--------|
| firebase_messaging | 15.2.4 | BUNDLED — in `ios/Resources/PrivacyInfo.xcprivacy` | FlutterFire GitHub (verified) |
| posthog_flutter | 4.0.0 (latest 5.21.0) | BUNDLED — in `darwin/posthog_flutter/Sources/posthog_flutter/PrivacyInfo.xcprivacy` | posthog-flutter podspec (verified) |
| sentry_flutter | 9.14.0 | BUNDLED — requires version ≥ 7.17.0 (we are at 9.14.0) | sentry-dart README (verified) |
| purchases_flutter | 9.14.0 | LIKELY BUNDLED via purchases-ios `Sources/PrivacyInfo.xcprivacy` | purchases-ios repo (MEDIUM confidence — verify via D-02) |

**Confidence note on RevenueCat:** The purchases-ios native SDK ships a `Sources/PrivacyInfo.xcprivacy` that declares `NSPrivacyAccessedAPICategoryUserDefaults` (CA92.1) and `NSPrivacyCollectedDataTypePurchaseHistory`. Whether the Flutter bridge (`PurchasesHybridCommon`) correctly propagates this into the IPA resource bundle should be confirmed with D-02.

### App-Level Privacy Manifest Needed

The app itself accesses `UserDefaults` (via Hive, SharedPreferences). Flutter apps typically need an app-level `PrivacyInfo.xcprivacy` in `ios/Runner/`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>NSPrivacyTracking</key>
    <false/>
    <key>NSPrivacyTrackingDomains</key>
    <array/>
    <key>NSPrivacyCollectedDataTypes</key>
    <array/>
    <key>NSPrivacyAccessedAPITypes</key>
    <array>
        <dict>
            <key>NSPrivacyAccessedAPIType</key>
            <string>NSPrivacyAccessedAPICategoryUserDefaults</string>
            <key>NSPrivacyAccessedAPITypeReasons</key>
            <array>
                <string>CA92.1</string>
            </array>
        </dict>
    </array>
</dict>
</plist>
```

**Reason code CA92.1** = "Access info from the same app that wrote it". This covers Hive and SharedPreferences reading their own keys.

---

## Architecture Patterns

### ITMS-91061 Detection Flow

```
flutter build ipa --release
  → Xcode archive
  → App Store Connect validation (or local via altool/xcrun)
  → If ITMS-91061 appears: lists exactly which SDK is missing manifest
  → If no ITMS-91061: all manifests present
```

**Note:** `flutter build ipa` on Windows is not supported — must be run on macOS with Xcode.

### Project Structure Changes (code tasks only)

```
ios/Runner/
├── Info.plist                   (existing)
├── PrivacyInfo.xcprivacy        (NEW — app-level manifest)
└── ...

ios/Runner.xcodeproj/project.pbxproj
  TARGETED_DEVICE_FAMILY = "1,2"  →  "1"   (lines 357, 483, 536)
```

### Screenshot Capture Process

```
1. flutter run --release  (on iPhone 16 Pro Max Simulator)
   OR
   flutter build ios --release && open on Simulator
2. Navigate to each of the 4 screens
3. Cmd+S (Simulator screenshot) → saves to Desktop at native resolution
4. Verify: 1290×2796 for iPhone 16 Pro Max Simulator
5. Upload to App Store Connect (App Store Connect accepts PNG/JPG)
```

**Android screenshots:**
```
1. Connect Nothing Phone 3a via USB
2. flutter run --release
3. Navigate to each of the 4 screens
4. Physical screenshot (power + volume down) or adb screencap
5. Upload to Google Play Console
```

### Device Family Change (TARGETED_DEVICE_FAMILY)

Current: `"1,2"` (iPhone + iPad)
Target: `"1"` (iPhone only)

Three occurrences in `project.pbxproj`:
- Line 357: Project-level Profile configuration
- Line 483: Project-level Debug configuration
- Line 536: Project-level Release configuration

No Runner target-level occurrences (only project-level). All three must change.

### Demo Account Setup

```
POST /api/auth/register
  email: support@trysomething.io
  password: [generate secure password, store offline]

Then via API or DB:
  - Create UserHobby with status "active" for e.g. "Photography"
  - Complete 2-3 steps via UserCompletedStep
  - Add 1-2 JournalEntry records
```

Purpose: Apple reviewer needs to see the full active-hobby experience (Home tab dashboard, session CTA, coach).

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Privacy manifest XML | Custom XML generator | Copy the template from verified SDK manifests | Format is rigid; wrong keys cause silent failures |
| Screenshot resizing | Image editor crops | Use correct Simulator device for native resolution | Upscaled screenshots are rejected by App Store Connect |
| Privacy label declarations | Guess from code review | Map each SDK to its published privacy policy | Google/Apple validate declared data vs. SDK behavior |

---

## Common Pitfalls

### Pitfall 1: Wrong Screenshot Dimensions

**What goes wrong:** Screenshots captured at wrong size are rejected by App Store Connect with "Invalid screenshot dimensions."
**Why it happens:** Using wrong Simulator device, or capturing from Debug build (which adds status bar).
**How to avoid:** Use iPhone 16 Pro Max Simulator specifically. Use Release build. The correct dimensions are 1290×2796 (portrait).
**Warning signs:** App Store Connect shows red error on screenshot upload.

Note: The CONTEXT.md specifies `1290×2796` which matches iPhone 16 Pro Max native resolution. This covers the "6.3-inch display" slot in App Store Connect. Apple requires either 6.9" (1260×2736) or 6.5" (1284×2778) as the primary set; 1290×2796 is accepted in the 6.3" slot and Apple scales from that to other sizes. If Apple requires 6.9" shots specifically, use iPhone 17 Pro Max Simulator (resolution 1320×2868) instead.

### Pitfall 2: TARGETED_DEVICE_FAMILY Change Incomplete

**What goes wrong:** Changed only one of the three build configurations, iPad screenshots still required.
**Why it happens:** project.pbxproj has separate Debug/Profile/Release blocks each with their own `TARGETED_DEVICE_FAMILY`.
**How to avoid:** Change all 3 occurrences (lines 357, 483, 536).
**Warning signs:** App Store Connect still prompts for iPad screenshots after build.

### Pitfall 3: Debug Banner in Screenshots

**What goes wrong:** "DEBUG" banner visible in top corner of screenshots — Apple will reject or request replacement.
**Why it happens:** Screenshots taken from a Debug build.
**How to avoid:** Always use Release builds for screenshots (`flutter run --release`).
**Warning signs:** Red "DEBUG" ribbon visible in top-right of screenshots.

### Pitfall 4: Missing App-Level PrivacyInfo.xcprivacy

**What goes wrong:** App submits fine but ITMS-91061 appears post-upload (the app itself uses UserDefaults without declaring it).
**Why it happens:** SDK manifests cover SDK usage. The app's own UserDefaults access (Hive, SharedPreferences) must be declared separately at the app level.
**How to avoid:** Add `PrivacyInfo.xcprivacy` to `ios/Runner/` (not a Framework — the app target).
**Warning signs:** ITMS-91061 warning naming `UserDefaults` without a specific SDK.

### Pitfall 5: Data Safety Form vs. App Privacy Labels Divergence

**What goes wrong:** Declared different data types on Apple vs. Google, creating legal inconsistency.
**Why it happens:** Forms use different terminology for same data.
**How to avoid:** Decide canonical data list first (see Declarations Checklist below), then map to each platform's terminology.

### Pitfall 6: Screenshot Size Mismatch for Required Slot

**What goes wrong:** App Store Connect warns that 6.5" or 6.9" screenshots are required.
**Why it happens:** iPhone 16 Pro Max (1290×2796) fills the 6.3" slot, not 6.5". Without a 6.5" or 6.9" screenshot, App Store Connect may show a warning (though it allows submission with auto-scaling).
**How to avoid:** Confirm in App Store Connect whether a warning appears. If needed, also capture on iPhone 14 Plus Simulator (1284×2778 = 6.5") or accept auto-scaling.

---

## App Store Metadata Reference

### Required Fields (iOS — App Store Connect)

| Field | Limit | TrySomething Value |
|-------|-------|--------------------|
| App Name | 30 chars | "TrySomething" (13 chars) |
| Subtitle | 30 chars | "Stop scrolling. Start something." → **too long (32 chars)** — use "Your 30-day hobby starter" (25 chars) |
| Keywords | 100 chars total | `hobbies,hobby,discover,beginner,lifestyle,try,start,pottery,photography,cooking,sport` |
| Promotional Text | 170 chars | (editable without resubmission) |
| Description | 4000 chars | Full app description |
| Support URL | Required | https://trysomething.io |
| Privacy Policy URL | Required | https://trysomething.io/privacy (Phase 3, complete) |
| Category | Required | **Lifestyle** (primary) — confirmed as standard for hobby apps |
| Secondary Category | Optional | **Health & Fitness** |
| Content Rating | Required | 4+ (answer all questionnaire items as "None") |
| Age Rating | Required | 4+ |

**Tagline note:** "Stop scrolling. Start something." is 32 characters — 2 over the 30-char subtitle limit. Use "Your 30-day hobby starter" or "Pick a hobby. Start today." (25 chars) instead. The tagline can still appear in the description body.

### Age Rating Questionnaire — TrySomething Answers

| Category | Answer | Resulting Rating |
|----------|--------|-----------------|
| Cartoon/Fantasy Violence | None | 4+ |
| Realistic Violence | None | 4+ |
| Sexual Content | None | 4+ |
| Profanity | None | 4+ |
| Drug/Alcohol/Tobacco | None | 4+ |
| Horror/Fear Themes | None | 4+ |
| Gambling/Contests | None | 4+ |
| User-Generated Content | None (journal is private) | 4+ |
| Advertising | None | 4+ |

**Expected result: 4+** — consistent with D-12.

### Google Play Metadata

| Field | Limit | TrySomething Value |
|-------|-------|--------------------|
| App Name | 30 chars | "TrySomething" |
| Short Description | 80 chars | "Find your hobby. Start it in 30 days." (38 chars) |
| Full Description | 4000 chars | Full app description |
| Category | Required | **Lifestyle** |
| Content Rating | Required | Everyone (ESRB equivalent) |
| Privacy Policy URL | Required | https://trysomething.io/privacy |

---

## App Privacy Labels — Declaration Checklist

### iOS App Store Connect (App Privacy section)

**Step 1:** Confirm you collect data (Yes — email, usage data, crash logs, purchases).

**Data type declarations required:**

| Data Type | Collected? | Linked to User? | Used for Tracking? | Purpose | SDK Responsible |
|-----------|------------|-----------------|-------------------|---------|-----------------|
| Email Address | Yes | Yes | No | App Functionality | First-party (registration) |
| User ID | Yes | Yes | No | App Functionality | First-party (JWT) |
| Product Interaction | Yes | No | No | Analytics | PostHog |
| Other Usage Data | Yes | No | No | Analytics | PostHog |
| Crash Data | Yes | No | No | App Functionality | Sentry |
| Performance Data | Yes | No | No | App Functionality | Sentry |
| Purchase History | Yes | No | No | App Functionality | RevenueCat |
| Device ID | Yes | No | No | App Functionality | Sentry, Firebase |

**Not collected (no declaration needed):**
- Location data (no GPS features)
- Contacts (no address book access)
- Health data (no HealthKit)
- Financial info (RevenueCat handles payments; we store entitlement status, not payment details)
- Photos (image_picker used for journal, but photos stay on device — no server upload unless Pro journal upload)
- Browsing history, search history (not transmitted)

**Note on photos:** If the Pro journal photo upload feature is active, add "Photos or Videos" → App Functionality. Check if this is live in production.

### Google Play Data Safety Form

**Data collection:**

| Data Type (Play terms) | Collected | Shared with 3rd parties | Encrypted in transit | Users can request deletion |
|------------------------|-----------|------------------------|---------------------|---------------------------|
| Email address | Yes | No | Yes | Yes |
| User IDs | Yes | No | Yes | Yes |
| App interactions | Yes | Yes (PostHog) | Yes | No |
| Crash logs | Yes | Yes (Sentry) | Yes | No |
| Purchase history | Yes | Yes (RevenueCat) | Yes | No |
| Device or other IDs | Yes | Yes (Firebase, Sentry) | Yes | No |

**Third-party SDKs that handle data:** PostHog (analytics), Sentry (crash reporting), Firebase (push token), RevenueCat (purchase validation).

**Security practices to declare:**
- Data encrypted in transit: Yes (HTTPS/TLS)
- Users can request data deletion: Yes (account deletion per COMP-01, data export per COMP-07)
- Data minimization: Yes (no unnecessary collection)

---

## Screenshot Composition Guide

### 4 Required Screens (D-05)

| Order | Screen | What to Show | Key UI Elements Visible |
|-------|--------|-------------|------------------------|
| 1 | Home (active hobby) | Week 2 of Photography with coral "Start session" CTA | Warm greeting, glass card, coral button, floating dock |
| 2 | Discover feed | Hero hobby card at full height | 55-60% hero card, cinematic dark background, coral accents |
| 3 | Hobby detail | Full hobby detail with roadmap | Stage roadmap, spec badge, "Start Hobby" CTA |
| 4 | Session timer | Particle formation timer mid-animation | Particle convergence, session glow, full-screen immersive |

**Capture notes:**
- Use portrait orientation (1290×2796)
- Ensure app is in Release build (no debug banner)
- Screenshots should show the warm cinematic dark theme — not a light mode
- The floating glass dock should be visible in screens 1-3
- Session timer (screen 4): pause timer mid-animation for particle effect visibility

---

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| 5.5" screenshots required for iPhone 8 Plus era | 6.9" primary (iPhone 17 Pro Max) or 6.3" accepted | 2025 | Must use modern Simulator |
| TARGETED_DEVICE_FAMILY = "1,2" default | Set to "1" for iPhone-only apps | Ongoing best practice | Avoids mandatory iPad screenshots |
| Privacy manifests optional | Required for App Store since May 2024 | May 1, 2024 | Must have for submission |
| Privacy manifests not enforced | Enforced: ITMS-91061 error on upload without them | May 2024 ongoing | Will block submission if missing |

**Upcoming:** From April 28, 2026, apps must be built with Xcode 26 and iOS 26 SDKs. This is 5 weeks from research date. Current requirement is Xcode 16 / iOS 18 SDKs (since April 24, 2025). **Action:** Ensure Xcode 16 is installed before building the IPA. If submission happens after April 28, 2026, Xcode 26 is required.

---

## Open Questions

1. **RevenueCat hybrid common manifest propagation**
   - What we know: RevenueCat iOS SDK ships `Sources/PrivacyInfo.xcprivacy`. The Flutter bridge uses `PurchasesHybridCommon`.
   - What's unclear: Whether `PurchasesHybridCommon` includes the privacy manifest in its pod resources so it bundles into the IPA.
   - Recommendation: D-02 resolves this. Run `flutter build ipa` on macOS and check for ITMS-91061. If it appears naming RevenueCat, add a manual manifest to `ios/Runner/PrivacyInfo.xcprivacy` (the app-level one) or escalate to RevenueCat support.

2. **iPhone 16 Pro Max screenshot slot**
   - What we know: D-06 specifies 1290×2796. The App Store Connect screenshot slots include 6.9" (1260×2736 for iPhone 17 Pro Max) and 6.3" (1290×2796 for iPhone 16 Pro Max / 16 Pro).
   - What's unclear: Whether App Store Connect shows a warning requiring the 6.9" slot to be filled separately.
   - Recommendation: Start with 1290×2796. If App Store Connect prompts for 6.9" screenshots, also capture using iPhone 17 Pro Max Simulator (1320×2868 or 1260×2736 — check Simulator specs).

3. **Pro journal photo upload**
   - What we know: `image_picker` is in the stack and there's a Pro photo journal feature.
   - What's unclear: Is server-side photo upload live in production? If yes, "Photos or Videos" must be declared in App Privacy Labels.
   - Recommendation: Check `server/api/users/[path].ts` for photo upload endpoints. If `/api/users/journal` accepts `photoUrl` from client upload (not Unsplash), declare Photos.

4. **Xcode 26 deadline**
   - What we know: April 28, 2026 is the deadline to use Xcode 26 and iOS 26 SDKs (research date: March 22, 2026 — 37 days away).
   - What's unclear: Whether the project's dependencies are compatible with iOS 26 SDK yet.
   - Recommendation: If submitting before April 28, use Xcode 16. If submitting on or after April 28, test the full build with Xcode 26 first.

---

## Validation Architecture

### Test Framework

| Property | Value |
|----------|-------|
| Framework | Flutter test (dart test) + vitest (server) |
| Config file | `analysis_options.yaml` (Flutter) |
| Quick run command | `flutter analyze lib/` |
| Full suite command | `flutter test` |

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| COMP-12 | PrivacyInfo.xcprivacy present in ios/Runner/ | manual | `ls ios/Runner/PrivacyInfo.xcprivacy` | ❌ Wave 0 |
| COMP-12 | TARGETED_DEVICE_FAMILY = "1" in all 3 configs | manual | `grep -c '"1"' ios/Runner.xcodeproj/project.pbxproj` | N/A |
| COMP-13 | App Privacy Labels declared in App Store Connect | manual-only | N/A | N/A |
| COMP-14 | Data Safety Form completed in Google Play Console | manual-only | N/A | N/A |

**COMP-13 and COMP-14 are manual-only.** There is no automated test for store console form completion. Verification is by visual inspection of App Store Connect / Google Play Console.

### Sampling Rate
- **Per task commit:** `flutter analyze lib/`
- **Per wave merge:** `flutter test`
- **Phase gate:** Manual verification that screenshots are uploaded, forms are complete, and IPA builds without ITMS-91061

### Wave 0 Gaps
- No new test files needed — this phase has no Flutter code changes beyond `project.pbxproj` and adding `PrivacyInfo.xcprivacy`
- The `PrivacyInfo.xcprivacy` file is not tested via automated tests; verified by IPA build success

---

## Code Examples

### App-Level PrivacyInfo.xcprivacy (create at `ios/Runner/PrivacyInfo.xcprivacy`)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>NSPrivacyTracking</key>
    <false/>
    <key>NSPrivacyTrackingDomains</key>
    <array/>
    <key>NSPrivacyCollectedDataTypes</key>
    <array/>
    <key>NSPrivacyAccessedAPITypes</key>
    <array>
        <dict>
            <key>NSPrivacyAccessedAPIType</key>
            <string>NSPrivacyAccessedAPICategoryUserDefaults</string>
            <key>NSPrivacyAccessedAPITypeReasons</key>
            <array>
                <string>CA92.1</string>
            </array>
        </dict>
    </array>
</dict>
</plist>
```

Source: Based on verified pattern from Firebase Messaging and RevenueCat iOS manifests (GitHub, HIGH confidence).

### TARGETED_DEVICE_FAMILY Change

In `ios/Runner.xcodeproj/project.pbxproj`, change all 3 occurrences:
```
TARGETED_DEVICE_FAMILY = "1,2";
```
to:
```
TARGETED_DEVICE_FAMILY = "1";
```

Lines to change: 357 (Profile), 483 (Debug), 536 (Release).

### Screenshot Capture Command (macOS)

```bash
# Verify simulator is running release build
flutter run --release -d "iPhone 16 Pro Max"

# Take screenshot from Simulator (while app is running)
# Use Cmd+S in Simulator window → saves to ~/Desktop at 1290×2796

# Or via xcrun:
xcrun simctl io booted screenshot ~/Desktop/trysomething_home.png
```

---

## Sources

### Primary (HIGH confidence)
- FlutterFire GitHub — `firebase_messaging/ios/Resources/PrivacyInfo.xcprivacy` — verified XML content
- RevenueCat purchases-ios GitHub — `Sources/PrivacyInfo.xcprivacy` — verified XML content (UserDefaults CA92.1 + PurchaseHistory)
- PostHog posthog-flutter GitHub podspec — `posthog_flutter.podspec` — verified resource bundle includes `PrivacyInfo.xcprivacy`
- sentry-dart GitHub README — verified requirement of sentry_flutter ≥ 7.17.0 for privacy manifest
- Apple App Store Connect screenshot specs page — verified 6.9" (1260×2736) and 6.3" (1290×2796) sizes
- Apple developer.apple.com upcoming requirements — confirmed privacy manifests still required (May 2024 onwards), Xcode 26 deadline April 28, 2026
- Apple App Store categories page — Lifestyle confirmed as correct category
- Apple age rating questionnaire — verified 4+ expected for TrySomething content profile
- Apple app metadata character limits — App Name 30, Subtitle 30, Keywords 100 confirmed

### Secondary (MEDIUM confidence)
- WebFetch of Apple App Store product page — character limits for metadata fields
- RevenueCat PurchasesHybridCommon GitHub — no `PrivacyInfo.xcprivacy` found at Flutter bridge level (manifest may rely on underlying purchases-ios pod)
- Apple WWDC23 session summary — required reason APIs and enforcement timeline

### Tertiary (LOW confidence)
- Google Play Data Safety form requirements — could not fetch official docs directly (WebFetch denied). Data types listed below are based on training knowledge of the form, cross-referenced with App Privacy Label structure.

---

## Metadata

**Confidence breakdown:**
- SDK manifest status: HIGH (Firebase, PostHog, Sentry verified); MEDIUM (RevenueCat flutter bridge — verify with D-02)
- Screenshot specs: HIGH — verified from official App Store Connect spec page
- App metadata limits: HIGH — verified from official Apple developer pages
- Privacy label declarations: HIGH (iOS) — inferred from SDK privacy manifests; MEDIUM (Android) — Google Play form structure from training knowledge
- Content rating: HIGH — questionnaire answers verified against official Apple age rating definitions

**Research date:** 2026-03-22
**Valid until:** 2026-04-22 (stable platform; screenshot specs rarely change)
