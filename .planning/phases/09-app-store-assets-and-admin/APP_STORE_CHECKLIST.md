# iOS App Store Connect — Submission Checklist

**App:** TrySomething
**Version:** 1.0.0+1
**Date:** 2026-03-22

Follow each section in order. Every field value is pre-determined — no guesswork needed.

---

## Section 1: App Information

Navigate to: **App Store Connect -> Your App -> App Information**

- [ ] **App Name:** `TrySomething`
  - 13 characters (limit: 30)
- [ ] **Subtitle:** `Your 30-day hobby starter`
  - 25 characters (limit: 30)
  - Note: The tagline "Stop scrolling. Start something." is 32 chars — over the 30-char limit. Use this shorter subtitle instead.
- [ ] **Primary Category:** `Lifestyle`
- [ ] **Secondary Category:** `Health & Fitness`
- [ ] **Privacy Policy URL:** `https://trysomething.io/privacy`
  - Already live from Phase 3
- [ ] **Support URL:** `https://trysomething.io`
- [ ] **Primary Language:** English

---

## Section 2: Version Page Metadata

Navigate to: **App Store Connect -> Your App -> (Version) -> App Store tab**

- [ ] **Keywords (100 chars max):**
  ```
  hobbies,hobby,discover,beginner,lifestyle,try,start,pottery,photography,cooking,sport
  ```
  (88 characters — under the 100-char limit)

- [ ] **Promotional Text (170 chars, editable anytime without resubmission):**
  ```
  Overwhelmed by choices? TrySomething matches you to one hobby and guides you through the first 30 days with step-by-step plans and AI coaching.
  ```
  (144 characters)

- [ ] **Description:**

  ```
  Finding a new hobby shouldn't be overwhelming. TrySomething matches you to
  one hobby based on your lifestyle — how much time you have, your budget,
  and what excites you — then guides you through the first 30 days with a
  clear, step-by-step roadmap.

  Browse 150+ hobbies across creative, active, mindful, and social
  categories. Each hobby comes with a personalized starter kit list, weekly
  plans, cost breakdowns, and beginner FAQs so you know exactly what to
  expect before you commit. When you're ready, start a guided session with
  an immersive timer and reflect on your progress in a private journal. An
  AI hobby coach is always available to answer questions, keep you motivated,
  and help you through rough patches.

  TrySomething Pro unlocks unlimited AI coaching, photo journaling, and
  support for multiple hobbies at once — with a free 7-day trial to see if
  it's right for you.

  Stop scrolling. Start something.
  ```

- [ ] **What's New:** `Initial release`

---

## Section 3: App Review Information

Navigate to: **App Store Connect -> Your App -> (Version) -> App Review**

- [ ] **Sign-In Required:** Yes
- [ ] **Demo Account Email:** `support@trysomething.io`
- [ ] **Demo Account Password:** `[Enter the password you created for this account in production]`
- [ ] **Review Notes:**
  ```
  Demo account has an active hobby ("Photography") with completed steps.
  Navigate to the Home tab to see the active dashboard with next step and
  session CTA. Use the Discover tab to browse hobbies. Tap any hobby for
  the detail page with roadmap and starter kit. Start a session from the
  Home tab to see the immersive timer with particle animation.
  ```

---

## Section 4: Age Rating

Navigate to: **App Store Connect -> Your App -> Age Rating**

Answer each category as listed below:

| Category | Answer |
|----------|--------|
| Cartoon or Fantasy Violence | None |
| Realistic Violence | None |
| Prolonged Graphic or Sadistic Realistic Violence | None |
| Profanity or Crude Humor | None |
| Mature/Suggestive Themes | None |
| Horror/Fear Themes | None |
| Medical/Treatment Information | None |
| Alcohol, Tobacco, or Drug Use or References | None |
| Simulated Gambling | None |
| Sexual Content and Nudity | None |
| Graphic Sexual Content and Nudity | None |
| Unrestricted Web Access | No |
| Gambling and Contests | No |

- [ ] All categories answered as listed above
- [ ] **Expected Result:** `4+`

---

## Section 5: App Privacy (COMP-13)

Navigate to: **App Store Connect -> Your App -> App Privacy**

### Step 1: Collection Declaration

- [ ] **"Does your app collect data?"** -> **Yes**

### Step 2: Data Type Declarations

For each data type below, click "+" to add it, then fill in the details exactly as shown.

| # | Data Type | Collected | Linked to User | Used for Tracking | Purpose |
|---|-----------|-----------|----------------|-------------------|---------|
| 1 | Email Address | Yes | Yes | No | App Functionality |
| 2 | User ID | Yes | Yes | No | App Functionality |
| 3 | Product Interaction | Yes | No | No | Analytics |
| 4 | Other Usage Data | Yes | No | No | Analytics |
| 5 | Crash Data | Yes | No | No | App Functionality |
| 6 | Performance Data | Yes | No | No | App Functionality |
| 7 | Purchase History | Yes | No | No | App Functionality |
| 8 | Device ID | Yes | No | No | App Functionality |

### Step 3: Data NOT Collected (no declaration needed)

Do NOT declare any of these — they are not collected:

- Location Data (no GPS features)
- Contacts (no address book access)
- Health & Fitness (no HealthKit)
- Financial Info (RevenueCat handles payments; we store entitlement status only)
- Browsing History / Search History (not transmitted off device)
- Sensitive Info
- Photos or Videos (journal photos stay on device in free tier; Pro upload is optional user action)

### Step 4: Tracking Declaration

- [ ] **"Does your app or third-party SDKs use data for tracking?"** -> **No**
  - PostHog analytics are first-party (self-hosted style), not cross-app tracking
  - Sentry crash data is not used for ad targeting
  - Firebase is used for push notifications only

### What Each SDK Contributes

| SDK | Data Types It Handles |
|-----|----------------------|
| First-party (registration/auth) | Email Address, User ID |
| PostHog | Product Interaction, Other Usage Data |
| Sentry | Crash Data, Performance Data, Device ID |
| RevenueCat | Purchase History |
| Firebase | Device ID (push token) |

- [ ] All 8 data types declared
- [ ] Privacy labels saved

---

## Section 6: Screenshots

Navigate to: **App Store Connect -> Your App -> (Version) -> Screenshots**

- [ ] Upload 4 screenshots at **1290 x 2796 px** (iPhone 16 Pro Max)
- [ ] Screenshot order:
  1. **Home** — Active hobby dashboard with warm greeting, "Week 2 of Photography", coral "Start session" CTA
  2. **Discover** — Full-width hero card, cinematic dark background
  3. **Detail** — Hobby detail with stage roadmap, spec badge, "Start Hobby" CTA
  4. **Session** — Particle formation timer mid-animation, full-screen immersive

See `SCREENSHOT_GUIDE.md` for detailed capture instructions.

- [ ] If App Store Connect warns about missing 6.9" screenshots, also capture using iPhone 17 Pro Max Simulator (1320x2868 or 1260x2736 — check Simulator specs)

---

## Section 7: App Icon

- [ ] App icon uploaded (1024x1024, already configured via `flutter_launcher_icons` in pubspec.yaml)
  - Source: `assets/icon/app_icon.png` (coral brushstroke "T" on dark background)

---

## Final Pre-Submission Checklist

- [ ] All sections above marked complete
- [ ] App binary uploaded (via `flutter build ipa` + Transporter or `xcrun altool`)
- [ ] No ITMS-91061 errors (privacy manifests present)
- [ ] TestFlight build passes review
- [ ] Submit for App Review

---

*Checklist generated: 2026-03-22 | Phase 09, Plan 02*
