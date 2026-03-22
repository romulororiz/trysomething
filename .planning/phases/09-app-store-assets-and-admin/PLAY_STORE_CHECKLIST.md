# Google Play Console — Submission Checklist

**App:** TrySomething
**Version:** 1.0.0+1
**Date:** 2026-03-22

Follow each section in order. Every field value is pre-determined — no guesswork needed.

---

## Section 1: Store Listing

Navigate to: **Google Play Console -> Your App -> Store Listing -> Main store listing**

- [ ] **App Name:** `TrySomething`
  - 13 characters (limit: 30)

- [ ] **Short Description (80 chars max):**
  ```
  Find your hobby. Start it in 30 days.
  ```
  (38 characters)

- [ ] **Full Description:**

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

- [ ] **App Category:** `Lifestyle`

---

## Section 2: Graphics

Navigate to: **Google Play Console -> Your App -> Store Listing -> Graphics**

- [ ] **App Icon:** 512 x 512 px (exported from `assets/icon/app_icon.png`)
- [ ] **Feature Graphic:** 1024 x 500 px (create from app branding — coral brushstroke "T" on dark background with tagline)
- [ ] **Phone Screenshots:** Upload 4 screenshots from Nothing Phone 3a
  1. **Home** — Active hobby dashboard
  2. **Discover** — Hero hobby card with cinematic background
  3. **Detail** — Hobby detail with roadmap
  4. **Session** — Particle timer mid-animation

See `SCREENSHOT_GUIDE.md` for detailed capture instructions.

---

## Section 3: Content Rating

Navigate to: **Google Play Console -> Your App -> Policy -> Content Rating**

### IARC Questionnaire

Answer each question as listed:

| Question Topic | Answer |
|---------------|--------|
| Violence | No |
| Sexual Content | No |
| Language (profanity) | No |
| Controlled Substance | No |
| Gambling | No |
| User-to-User Communication | No |
| User-Generated Content shared with others | No |
| Location Sharing | No |
| Purchases | Yes (in-app purchases via RevenueCat) |
| Advertisements | No |

- [ ] Questionnaire completed
- [ ] **Expected Result:** `Everyone` (ESRB) / `PEGI 3` / `USK 0`

---

## Section 4: Data Safety Form (COMP-14)

Navigate to: **Google Play Console -> Your App -> Policy -> Data Safety**

### Step 1: Overview

- [ ] **Privacy Policy URL:** `https://trysomething.io/privacy`
- [ ] **"Does your app collect or share any of the required user data types?"** -> **Yes**

### Step 2: Data Collection Declarations

For each data type below, declare exactly as shown:

| # | Data Type (Play terms) | Collected | Shared with 3rd parties | Encrypted in transit | Users can request deletion |
|---|------------------------|-----------|------------------------|---------------------|---------------------------|
| 1 | Email address | Yes | No | Yes | Yes |
| 2 | User IDs | Yes | No | Yes | Yes |
| 3 | App interactions | Yes | Yes (PostHog) | Yes | No |
| 4 | Crash logs | Yes | Yes (Sentry) | Yes | No |
| 5 | Purchase history | Yes | Yes (RevenueCat) | Yes | No |
| 6 | Device or other IDs | Yes | Yes (Firebase, Sentry) | Yes | No |

### Step 3: Data Sharing Details

When prompted about third-party sharing for each data type:

| Data Type | Shared With | Purpose |
|-----------|-------------|---------|
| App interactions | PostHog | Analytics — understand feature usage and user flows |
| Crash logs | Sentry | App stability — crash detection and error reporting |
| Purchase history | RevenueCat | Subscription management — validate entitlements |
| Device or other IDs | Firebase (push token), Sentry (device context) | Push notifications, crash diagnostics |

### Step 4: Data NOT Collected

Do NOT declare any of these:

- Location (no GPS features)
- Contacts (no address book access)
- Photos and videos (not uploaded to server in free tier)
- Audio / Music files
- Files and docs
- Calendar
- SMS / Call log
- Health info
- Financial info (RevenueCat handles payments directly)
- Web browsing / Installed apps

### Step 5: Security Practices

- [ ] **Data encrypted in transit:** Yes (all API calls use HTTPS/TLS)
- [ ] **Users can request data deletion:** Yes (account deletion endpoint at `DELETE /api/users/me`)
- [ ] **Committed to Google Play Families Policy:** No (not a children's app)

### Step 6: Data Handling Purposes

When asked about purpose for collected data:

| Data Type | Purpose |
|-----------|---------|
| Email address | Account management, authentication |
| User IDs | Account management, personalization |
| App interactions | Analytics, app improvement |
| Crash logs | App stability, bug fixing |
| Purchase history | Subscription management |
| Device or other IDs | Push notifications, crash diagnostics |

- [ ] All 6 data types declared
- [ ] Security practices completed
- [ ] Data Safety form submitted

---

## Section 5: App Access

Navigate to: **Google Play Console -> Your App -> Policy -> App Access**

- [ ] **"All or some functionality is restricted"** -> Yes
- [ ] Provide test credentials:
  - **Email:** `support@trysomething.io`
  - **Password:** `[Enter the password you created for this account in production]`
  - **Instructions:** `Account has an active hobby with completed steps. Home tab shows active dashboard. Discover tab shows hobby browsing.`

---

## Section 6: Ads Declaration

Navigate to: **Google Play Console -> Your App -> Policy -> Ads**

- [ ] **"Does your app contain ads?"** -> **No**

---

## Section 7: Target Audience

Navigate to: **Google Play Console -> Your App -> Policy -> Target audience and content**

- [ ] **Target age group:** 18 and over
  - Do NOT select any age groups under 18 (avoids Families Policy requirements)

---

## Final Pre-Submission Checklist

- [ ] All sections above marked complete
- [ ] App bundle (AAB) uploaded via internal/closed/open testing track
- [ ] No policy warnings in Play Console dashboard
- [ ] Internal testing verified on Nothing Phone 3a
- [ ] Promote to production track and submit for review

---

*Checklist generated: 2026-03-22 | Phase 09, Plan 02*
