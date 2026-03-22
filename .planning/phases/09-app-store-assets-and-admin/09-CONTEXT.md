# Phase 9: App Store Assets and Admin - Context

**Gathered:** 2026-03-22
**Status:** Ready for planning

<domain>
## Phase Boundary

Complete both store submission packages: iOS privacy manifests, App Privacy Labels, Data Safety Form, screenshots, metadata, content rating, and demo account. Mix of code tasks (manifests, device targeting) and manual admin tasks (store console forms).

</domain>

<decisions>
## Implementation Decisions

### Privacy manifests (COMP-12)
- **D-01:** Claude investigates which SDK versions (Firebase FCM, RevenueCat, PostHog) already bundle `PrivacyInfo.xcprivacy` and which need manual manifests
- **D-02:** Verify by running `flutter build ipa` and checking for `ITMS-91061` errors — if none, manifests are bundled

### Device targeting
- **D-03:** Change `TARGETED_DEVICE_FAMILY` from `"1,2"` (iPhone+iPad) to `"1"` (iPhone only) in `ios/Runner.xcodeproj/project.pbxproj` — avoids iPad screenshot requirement and iPad-specific UI testing
- **D-04:** Update all 3 occurrences (Debug, Profile, Release build configs)

### Screenshots
- **D-05:** 4 screens to screenshot: Home (active hobby), Discover feed, Hobby detail, Session timer
- **D-06:** iOS: iPhone 16 Pro Max Simulator at 1290×2796px, release build
- **D-07:** Android: Nothing Phone 3a real device screenshots for Google Play
- **D-08:** Ensure Flutter debug banner is NOT visible (release build)

### Store metadata
- **D-09:** Category: Claude's discretion (Lifestyle recommended — most hobby apps)
- **D-10:** Language: English only for v1.0
- **D-11:** Demo account for Apple Review: use `support@trysomething.io` — create this user in production with pre-populated hobby data (1 active hobby with some progress) so reviewers can test the full flow
- **D-12:** Content Rating: expected 4+ (Everyone) — no violence, gambling, or mature content

### App Privacy Labels (COMP-13) + Data Safety Form (COMP-14)
- **D-13:** Both require the hosted Privacy Policy URL (already at `trysomething.io/privacy` from Phase 3)
- **D-14:** Data collection categories to declare: email address (account), usage data (PostHog analytics), crash logs (Sentry), purchase history (RevenueCat)
- **D-15:** These are manual admin tasks in App Store Connect and Google Play Console — Claude provides the checklist, user fills in the forms

### Claude's Discretion
- App Store category selection
- Screenshot composition and ordering
- Exact App Store description and keywords
- Which privacy manifest data types to declare per SDK

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### iOS build config
- `ios/Runner.xcodeproj/project.pbxproj` lines 357, 483, 536 — `TARGETED_DEVICE_FAMILY` settings to change

### Privacy
- `website/` — Hosted Terms and Privacy Policy (Phase 3)
- `ios/Runner/Info.plist` — iOS app configuration

### App metadata
- `pubspec.yaml` — App version, name
- `assets/icon/app_icon.png` — App icon (coral brushstroke "T" on dark background)

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- App icon already at 1024×1024 (`assets/icon/app_icon.png`)
- Privacy Policy already hosted from Phase 3
- `flutter_launcher_icons` configured in pubspec.yaml

### Established Patterns
- Brand: "TrySomething" — Source Serif 4, "Try" coral, "Something" warm cream
- Tagline: "Stop scrolling. Start something."
- Voice: warm, practical, encouraging

### Integration Points
- `ios/Runner.xcodeproj/project.pbxproj` — device family + privacy manifest
- App Store Connect — manual form entry
- Google Play Console — manual form entry

</code_context>

<specifics>
## Specific Ideas

- Use the tagline "Stop scrolling. Start something." as the App Store subtitle
- Screenshots should show the warm cinematic design — dark backgrounds with coral accents
- Demo account should have a hobby like "Photography" or "Pottery" with 2-3 completed steps so the reviewer sees real content

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 09-app-store-assets-and-admin*
*Context gathered: 2026-03-22*
