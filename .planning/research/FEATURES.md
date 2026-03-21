# Feature Landscape: App Store Launch Readiness

**Domain:** Mobile app store submission compliance and launch readiness
**Researched:** 2026-03-21
**Confidence:** HIGH (Apple/Google official docs + RevenueCat official docs confirmed)

---

## Context

TrySomething is a Flutter app preparing for first submission to both the Apple App Store and Google Play Store. The core product is built. This research covers only the compliance, legal, and submission-readiness features required to pass review and launch without rejection.

---

## Table Stakes

Features that are mandatory. Missing any of these = guaranteed rejection.

### 1. Account Deletion (In-App)

**Why expected:** Apple guideline 5.1.1(v) — mandatory since June 30, 2022. Google Play Data Safety policy — required for all apps supporting account creation. Blocking rejection.

**What it must do:**
- Delete the full account record and all associated personal data from the backend
- Be initiatable from within the app (Settings screen) — not just via email or web
- Show a confirmation flow that is clear but not obstruction (Apple: "cannot make deletion unnecessarily difficult")
- Warn about active subscription — inform user billing continues through Apple/Google until cancelled, provide link to manage subscription
- Inform user what data will be deleted and what (if any) will be retained and why
- Call Sign in with Apple REST API to revoke tokens when deleting Apple OAuth accounts
- Cascade-delete all associated records: UserHobby, JournalEntry, PersonalNote, ScheduleEvent, ShoppingCheck, UserCompletedStep, UserActivityLog, UserChallenge, UserAchievement

**UX pattern for TrySomething:**
1. Settings → "Delete Account" (visible, not buried)
2. Screen explaining what gets deleted (all data, journal entries, progress) and what persists (none)
3. If user has active Pro subscription: warning that they must cancel billing separately + link to `https://apps.apple.com/account/subscriptions`
4. Final confirmation: require password re-entry OR typed phrase (e.g., "DELETE") — prevents accidental taps
5. Async deletion: show "Deletion in progress" state + email confirmation on completion
6. Log out and return to login screen when done

**Complexity:** Medium
**Guideline:** Apple 5.1.1(v), Google Play Data Safety policy

---

### 2. Privacy Policy — Hosted and Linked

**Why expected:** Apple requires a live URL in App Store Connect AND accessible from within the app. Google Play requires a non-PDF, non-geofenced public URL. Both: mandatory for all apps, no exceptions.

**What it must do:**
- Policy hosted at a stable public URL (not a PDF, not a Google Doc)
- URL entered in App Store Connect metadata and Google Play Console
- Accessible with one tap from within the app (Settings screen is canonical location)
- Must state: what data is collected, how it's used, third-party SDKs (Firebase, PostHog, Sentry, RevenueCat, Unsplash), retention periods, user rights under FADP/GDPR

**UX pattern for TrySomething:**
- Host on the existing Next.js landing page at `/privacy` (already Next.js, just add a page)
- Settings screen: "Privacy Policy" → opens in-app WebView or system browser
- Also add "Terms of Service" link in the same location

**Complexity:** Low (policy already drafted as .docx — just needs hosting and linking)
**Guideline:** Apple 5.1.1, Google Play User Data policy

---

### 3. Terms of Service — Hosted and Linked

**Why expected:** Not technically mandated like privacy policy, but Apple will reject apps with missing or placeholder legal links. Required for FADP compliance (contract basis for data processing). Subscription apps especially need ToS covering billing terms.

**What it must do:**
- Hosted at stable public URL
- Accessible from Settings screen
- Covers: service description, subscription terms (7-day trial, CHF 4.99/month, CHF 39.99/year), cancellation policy, refund policy, user conduct

**Complexity:** Low (already drafted as .docx)

---

### 4. Restore Purchases Button

**Why expected:** Apple explicitly requires a "Restore Purchases" mechanism for apps selling auto-renewable subscriptions. Rejection under guideline 3.1.1 without it. Reviewers test purchase → reinstall → restore flow.

**What it must do:**
- Button visible on the paywall screen AND in Settings/Pro screen
- Calls `RevenueCat.restorePurchases()` on user tap only (not programmatically — triggers OS-level sign-in prompt)
- Re-unlocks Pro entitlement if subscription found
- Shows success/failure feedback to user

**Complexity:** Low (RevenueCat SDK has the method, just needs UI button)
**Guideline:** Apple 3.1.1

---

### 5. App Privacy Labels (Apple) + Data Safety Section (Google)

**Why expected:** Blocking submission on both platforms. Cannot submit without completing these forms in the respective consoles.

**Apple — Privacy Nutrition Labels (App Store Connect):**
Must disclose all data collected by app AND third-party SDKs. For TrySomething:
- **Contact Info:** Email address (account creation)
- **Identifiers:** User ID, Device ID (analytics/PostHog)
- **Usage Data:** App interactions, session data (PostHog analytics)
- **Diagnostics:** Crash data (Sentry)
- **User Content:** Journal entries (stored on server, user-linked)
- **Purchase History:** Transaction IDs (RevenueCat)
- Third-party SDKs to disclose: Firebase (FCM), PostHog, Sentry, RevenueCat

**Google — Data Safety Form (Play Console):**
Same categories as above. Firebase has official guidance doc at `firebase.google.com/docs/android/play-data-disclosure`. RevenueCat counts as "service provider" (processes data on developer's behalf). PostHog: disclose as analytics service provider. Mark account deletion as supported.

**Complexity:** Low (admin task in consoles) but easy to get wrong — allocate dedicated time
**Guideline:** Apple App Privacy Details requirement; Google Play Data Safety policy

---

### 6. Demo Account Credentials in App Review Notes

**Why expected:** Apple requires working login credentials if the app requires sign-in. Without them, reviewers cannot access the app — automatic rejection under guideline 2.1 (incomplete functionality).

**What it must do:**
- Create a dedicated test account (e.g., `reviewer@trysomething.app`) pre-loaded with data
- Account must have: completed onboarding, one active hobby with some journal entries, Pro subscription access (via sandbox entitlement)
- Include in App Review Notes: email, password, step-by-step instructions to reach key screens
- Provide note about subscription: "Use sandbox environment — Pro features are unlocked via RevenueCat sandbox entitlement on this account"

**Complexity:** Low (admin task)
**Guideline:** Apple 2.1

---

### 7. Apple OAuth Routing Fix

**Why expected:** Apple Sign-In is a technical requirement from Apple: apps offering third-party login must offer Sign in with Apple as an equivalent option. TrySomething already has Apple OAuth code but `vercel.json` route regex excludes the `apple` action. This means Apple Sign-In silently fails in production — guaranteed rejection.

**What it must fix:**
- `vercel.json` route regex: change `(register|login|refresh|google)` → `(register|login|refresh|google|apple)`
- Test full Apple OAuth flow on a real iOS device before submission

**Complexity:** Low (one-line config change + testing)
**Guideline:** Apple 4.8 (Sign in with Apple)

---

### 8. App Store Screenshots — Required Device Sizes

**Why expected:** Apple will not accept submissions missing required screenshot sizes. As of 2025–2026, 6.9-inch iPhone (1290×2796px) and 13-inch iPad (2064×2752px) screenshots are mandatory. All other sizes are auto-scaled from these.

**What it must cover:**
- 10 screenshots max per localized listing
- First 3 screenshots are most important (users rarely scroll past)
- No placeholder UI, no debug banners, no Flutter debug mode ribbon
- Must match actual app functionality — showing features not in the app is a rejection reason
- Overlay text on screenshots is standard practice and recommended for clarity

**Screenshot sequence recommendation for TrySomething:**
1. Home screen with active hobby + "Week N of [Hobby]" — shows core value
2. Discover feed hero card — shows personalization
3. Hobby detail with roadmap — shows structure and commitment flow
4. Session timer (particle formation) — shows unique UX
5. AI coach conversation — shows differentiator
6. Paywall/Pro screen — required to show subscription offering exists

**Complexity:** Medium (design + production work, not just code)

---

### 9. App Metadata — Title, Subtitle, Description, Keywords

**Why expected:** Misleading or incomplete metadata is the second most common rejection reason. Apple actively compares app behavior to its metadata.

**Requirements:**
- **iOS App Title:** max 30 characters
- **iOS Subtitle:** max 30 characters
- **iOS Description:** No prohibited claims ("best", "#1" without evidence), no placeholder text
- **iOS Keywords:** max 100 characters, comma-separated
- **Google Play Short Description:** max 80 characters
- **Google Play Full Description:** max 4000 characters
- Content rating questionnaire must be completed honestly
- Description must not promise features not yet built

**Complexity:** Low (copywriting task)

---

### 10. Content Rating Questionnaire

**Why expected:** Required by both App Store and Google Play. Incorrect answers can cause removal post-launch.

**For TrySomething:** No violence, no adult content, no user-generated content visible to others, no social networking (social features hidden). Should receive a 4+ / Everyone rating. The AI coach generates hobby content only, filtered by content_guard.ts.

**Complexity:** Low (admin task)

---

## Differentiators

Features that improve approval confidence and user experience post-approval. Not strictly required but materially affect review outcomes and launch success.

### 1. Data Export (FADP/GDPR Portability)

**Value:** Required by Swiss FADP Art. 28 (data portability right) and GDPR Article 20. Not an App Store rejection trigger, but a legal compliance requirement for operating in Switzerland/EU. Users can request data export — failing to honor this is a regulatory violation, not an app store violation.

**What to build:**
- `GET /api/users/me/export` endpoint returning JSON
- Response includes: user profile, preferences, all UserHobby records with status, all JournalEntry records with text and dates, all UserCompletedStep records, all ScheduleEvent records
- Response must be in a "structured, commonly used, machine-readable format" — JSON satisfies this
- Delivered inline (direct download) is sufficient for v1.0; email delivery would be more user-friendly but is optional
- Must be mentioned in the Privacy Policy
- In-app trigger: Settings → "Download My Data" → informs user they'll receive a file → triggers download

**Complexity:** Medium (backend endpoint + client download flow)
**Regulatory basis:** FADP Art. 28, GDPR Art. 20

---

### 2. RevenueCat Webhook Signature Verification

**Value:** Without this, a malicious actor who discovers the webhook URL can send fake subscription events (e.g., fake Pro upgrades). This is a security gap, not an App Store requirement. Fixes a HIGH-severity exploitable vulnerability before production traffic.

**What to build:**
- Add `Authorization` header check on webhook receiver — RevenueCat sends a configurable auth header with every webhook call
- Configure a secret authorization header value in RevenueCat dashboard
- Server verifies header on every incoming webhook POST, returns 401 if missing or wrong
- This is the only webhook verification method RevenueCat currently supports (no payload signing)

**Complexity:** Low (server-side header check, ~20 lines of code)

---

### 3. Server-Side Rate Limiting for AI Coach

**Value:** Current rate limiting uses Hive (client-side) for the 3 messages/month free tier limit — trivially bypassable. Moving to server-side `GenerationLog` table makes it tamper-proof and consistent across devices.

**What to build:**
- On `POST /api/generate/coach`: query `GenerationLog` table for user's message count in rolling 30-day window
- Return 429 with clear message if limit exceeded (free users: 3/month)
- Pro users: no limit (check entitlement before enforcing)
- Already have `GenerationLog` model in Prisma schema — just add the count query

**Complexity:** Low (server-side query, ~30 lines)

---

### 4. Subscription Cancellation Guidance in Delete Account Flow

**Value:** Apple specifically requires that apps with auto-renewable subscriptions notify users during account deletion that billing continues through Apple. Failure to do this is a specific callout in Apple's account deletion documentation. Required for compliance, improves user trust.

**What to build:**
- In the account deletion confirmation screen: detect if user has active Pro subscription
- If active: show inline warning + "Manage Subscription" link before allowing deletion to proceed
- Link to `https://apps.apple.com/account/subscriptions` (iOS) or Google Play subscription management (Android)

**Complexity:** Low (conditional UI block in deletion flow)

---

### 5. App Icon — Final Production Version

**Value:** App icons with quality issues or that look placeholder-y are flagged by reviewers. The icon also directly impacts install conversion on the store listing.

**TrySomething status:** Icon exists (`assets/icon/app_icon.png` — coral brushstroke "T" on `#0A0A0F`). Needs verification at all required sizes:
- iOS: 1024×1024px (App Store), system generates smaller sizes
- Android: 512×512px (Play Store), plus adaptive icon layers (foreground + background separately)

**Complexity:** Low (verification + possibly re-export at correct specs)

---

## Anti-Features

Features to explicitly NOT build for this launch milestone. Building these would delay launch without proportional compliance benefit.

| Anti-Feature | Why Avoid | What to Do Instead |
|---|---|---|
| Email-based data deletion request | Apple explicitly rejects this — users must be able to delete from within the app | Build in-app deletion flow as described above |
| "Request deletion" form that takes days to process | Fine for regulated industries, but Apple says general apps cannot require support flows | Async deletion is OK, but must be automatic (not manual review) |
| Biometric auth for deletion confirmation | Adds complexity, platform-specific code, testing burden | Password re-entry or typed phrase is sufficient and simpler |
| PDF-hosted Privacy Policy | Google Play explicitly rejects non-HTML privacy policy URLs | Host as HTML page on Next.js site |
| Separate localized app store listings | Adds significant asset/copy production work for v1.0 | English-only for v1.0 is explicit out-of-scope decision |
| GDPR consent banner / cookie consent flow | App does not use tracking cookies; analytics is PostHog (no advertising); not required for a non-advertising app | Disclose PostHog in privacy labels as analytics, no consent banner needed |
| "Right to erasure" 30-day SLA tracking | Enterprise-grade GDPR compliance machinery — overkill for solo developer v1.0 | Account deletion satisfies erasure right; document timeline in Privacy Policy ("deletion completes within 24-48 hours") |
| Separate FADP privacy notice | FADP is substantially aligned with GDPR; GDPR-compliant privacy policy covers FADP requirements with minor additions | Add Swiss-specific language to main Privacy Policy |

---

## Feature Dependencies

```
Privacy Policy hosted → can submit to App Store Connect + Play Console
Terms of Service hosted → can link from Settings
Account deletion endpoint (backend) → Account deletion UX (frontend)
Account deletion UX → Subscription cancellation guidance (part of same flow)
RevenueCat webhook security → safe for production traffic
App Privacy Labels → requires Privacy Policy to be finalized first (must match what's disclosed)
Demo account created → App Review Notes can be written
Screenshots produced → App Store Connect submission can be completed
```

---

## MVP Recommendation

**For Apple App Store submission (ordered by dependency and blocking status):**

1. **Apple OAuth route fix** — One-line config change, unblocks Apple Sign-In testing, required before iOS submission. Do first.
2. **Privacy Policy + ToS hosting** — Already drafted, just publish to Next.js site. Required before completing Privacy Labels.
3. **Account deletion endpoint (backend)** — Server-side cascade delete. Required by Apple 5.1.1(v), certain rejection without it.
4. **Account deletion UX (client)** — Settings flow with confirmation + subscription warning. Depends on backend.
5. **Restore Purchases button** — Add to paywall + Settings. Required by Apple 3.1.1. Low effort.
6. **App Privacy Labels** — Admin task in App Store Connect. Requires Privacy Policy finalized. Do after policy is live.
7. **Demo account + App Review Notes** — Create test account, write instructions. Do just before submission.
8. **Screenshots** — Design and export at 1290×2796px for iPhone. Do in parallel with code tasks.
9. **App metadata** — Title, subtitle, description, keywords. Low effort, do last.

**For Google Play submission (after iOS, shares most work):**
10. **Data Safety Form** — Admin task in Play Console. Firebase guidance doc available. Do after Privacy Policy finalized.
11. **Content Rating Questionnaire** — 10-minute admin task.
12. **Android screenshots** — Can reuse iOS screenshots with slight sizing adjustments.

**Defer to post-launch (v1.1) but do before EU/CH scale:**
- Data export endpoint (FADP portability) — legally required but not an app store gate
- Server-side rate limiting for AI coach — security improvement, not launch blocker

---

## Common Rejection Reasons Specific to TrySomething

Based on the known codebase state and research findings:

| Rejection Risk | Guideline | Status | Mitigation |
|---|---|---|---|
| No account deletion in-app | 5.1.1(v) | NOT BUILT | Build `DELETE /api/users/me` + UX flow |
| Apple OAuth silently broken | 4.8 | BROKEN (vercel.json regex) | One-line fix in vercel.json |
| No Restore Purchases button | 3.1.1 | LIKELY MISSING | Add to paywall + settings |
| No Privacy Policy URL | 5.1.1 | NOT HOSTED | Publish to Next.js site |
| Missing Privacy Labels | Privacy Details | NOT COMPLETED | Admin task in App Store Connect |
| Dead code / hidden features | 2.3.3 | PARTIALLY PRESENT | Delete 7,000+ lines of hidden screen code |
| Flutter debug banner in screenshots | 2.3 | RISK | Ensure `flutter run --release` for screenshots |
| Demo credentials not provided | 2.1 | NOT PREPARED | Create test account, write review notes |
| Placeholder metadata | 2.3 | NOT WRITTEN | Write final title/description/keywords |
| Subscription without Restore button | 3.1.1 | LIKELY MISSING | Add restore button |

---

## Sources

- [Apple App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/) — HIGH confidence (official)
- [Apple: Offering Account Deletion in Your App](https://developer.apple.com/support/offering-account-deletion-in-your-app/) — HIGH confidence (official)
- [Apple App Privacy Details](https://developer.apple.com/app-store/app-privacy-details/) — HIGH confidence (official)
- [Google Play: Account Deletion Requirements](https://support.google.com/googleplay/android-developer/answer/13327111?hl=en) — HIGH confidence (official)
- [Google Play: Data Safety Section](https://support.google.com/googleplay/android-developer/answer/10787469?hl=en-GB) — HIGH confidence (official)
- [Firebase for Android: Play Data Disclosure](https://firebase.google.com/docs/android/play-data-disclosure) — HIGH confidence (official)
- [RevenueCat: Restoring Purchases](https://www.revenuecat.com/docs/getting-started/restoring-purchases) — HIGH confidence (official)
- [RevenueCat: Webhooks](https://www.revenuecat.com/docs/integrations/webhooks) — HIGH confidence (official)
- [App Store Requirements: iOS & Android Submission Guide 2026](https://natively.dev/articles/app-store-requirements) — MEDIUM confidence (community guide, cross-checked with official docs)
- [App Store Review Guidelines (2025): Checklist + Top Rejection Reasons](https://nextnative.dev/blog/app-store-review-guidelines) — MEDIUM confidence (community guide)
- [GDPR Article 20: Right to Data Portability](https://gdpr-info.eu/art-20-gdpr/) — HIGH confidence (official legal text)
- [Switzerland FADP Overview](https://usercentrics.com/knowledge-hub/switzerland-federal-data-protection-act-fadp/) — MEDIUM confidence (verified against multiple sources)
