---
phase: 03-legal-documents-host-and-link
verified: 2026-03-21T20:30:00Z
status: human_needed
score: 5/5 must-haves verified
human_verification:
  - test: "Visit https://trysomething.app/terms in a browser"
    expected: "Publicly accessible HTML page with all 16 sections of Terms of Service, no redirect to login, crawlable"
    why_human: "Cannot verify live HTTPS deployment or crawlability programmatically; can only confirm the source files exist and build correctly"
  - test: "Visit https://trysomething.app/privacy in a browser"
    expected: "Publicly accessible HTML page with all 11 sections of Privacy Policy and all 10 processor cards, no redirect to login, crawlable"
    why_human: "Cannot verify live HTTPS deployment or crawlability programmatically"
  - test: "In the deployed website footer, click 'Terms of Service'"
    expected: "Navigates to /terms page without a login redirect"
    why_human: "Runtime browser behavior cannot be verified statically"
  - test: "Tap 'Terms of Service' and 'Privacy Policy' in the app Settings About sheet"
    expected: "Each opens https://trysomething.app/terms or /privacy in the device browser"
    why_human: "url_launcher behavior requires a physical device or emulator"
  - test: "Tap 'Terms of Service' and 'Privacy Policy' on the Register screen"
    expected: "Each opens the correct hosted URL in the device browser via LaunchMode.externalApplication"
    why_human: "url_launcher behavior requires a physical device or emulator"
  - test: "Tap 'Terms of Service' and 'Privacy Policy' on the Login screen"
    expected: "Each opens the correct hosted URL in the device browser via LaunchMode.externalApplication"
    why_human: "url_launcher behavior requires a physical device or emulator"
---

# Phase 3: Legal Documents Host and Link — Verification Report

**Phase Goal:** Terms of Service and Privacy Policy are live at stable HTTPS URLs and accessible from within the app
**Verified:** 2026-03-21T20:30:00Z
**Status:** human_needed — all automated checks pass; deployment and runtime behavior require human confirmation
**Re-verification:** No — initial verification

---

## Goal Achievement

### Observable Truths

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | `/terms` returns a fully rendered Terms of Service page with all 16 sections | VERIFIED (source) | `website/app/terms/page.tsx` exists, 499 lines, contains all 16 section headings, static export compatible |
| 2 | `/privacy` returns a fully rendered Privacy Policy page with all 11 sections | VERIFIED (source) | `website/app/privacy/page.tsx` exists, 559 lines, contains all 11 sections and all 10 data processor cards |
| 3 | Both pages load without authentication and are crawlable | VERIFIED (source) / ? DEPLOYMENT | Pure static components (`output: "export"` confirmed), no auth code, no `"use client"` — runtime accessibility requires human check |
| 4 | Tapping legal links in Settings opens hosted page in device browser | VERIFIED (code) | `settings_screen.dart` has `_openLegalPage` helper calling `launchUrl(..., LaunchMode.externalApplication)` for both URLs |
| 5 | Tapping legal links in Register/Login screens opens hosted pages | VERIFIED (code) | Both files use inline `launchUrl(Uri.parse('https://trysomething.app/...'), mode: LaunchMode.externalApplication)` |

**Score:** 5/5 truths verified at source level. Deployment and device runtime require human confirmation.

---

## Required Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `website/app/terms/page.tsx` | ToS static page with all 16 sections | VERIFIED | 499 lines; contains `export const metadata`, `export default function TermsPage`, all 16 section headings 1–16, `support@trysomething.io`, no `"use client"` |
| `website/app/privacy/page.tsx` | Privacy Policy with all 11 sections + 10 processor cards | VERIFIED | 559 lines; contains `export const metadata`, `export default function PrivacyPage`, all 11 sections, all 10 processors (Vercel, Neon, Anthropic, RevenueCat, PostHog, Sentry, Firebase, Unsplash, Google Sign-In, Apple Sign-In), `edoeb.admin.ch` |
| `website/components/layout/Footer.tsx` | Footer with working `/privacy` and `/terms` links | VERIFIED | Lines 66–67: `{ label: "Privacy Policy", href: "/privacy" }` and `{ label: "Terms of Service", href: "/terms" }` — no `href: "#"` in legal section |
| `lib/screens/settings/settings_screen.dart` | Settings with `launchUrl` for legal pages | VERIFIED | Line 25: `url_launcher` import; line 51: `_openLegalPage` helper with `canLaunchUrl` guard; lines 124, 137: correct URLs |
| `lib/screens/auth/register_screen.dart` | Register screen with `launchUrl` for legal pages | VERIFIED | Line 5: `url_launcher` import; lines 364–369: `/terms` handler; lines 376–382: `/privacy` handler; no remaining `context.push('/terms-of-service')` or `context.push('/privacy-policy')` |
| `lib/screens/auth/login_screen.dart` | Login screen with `launchUrl` for legal pages | VERIFIED | Line 5: `url_launcher` import; lines 323–329: `/terms` handler; lines 336–343: `/privacy` handler; no remaining `context.push` for legal routes |

---

## Key Link Verification

| From | To | Via | Status | Details |
|------|----|-----|--------|---------|
| `website/components/layout/Footer.tsx` | `/terms`, `/privacy` | `href` attributes on `<a>` tags | WIRED | Lines 66–67 contain `href: "/privacy"` and `href: "/terms"`; rendered via `<a href={link.href}>` loop |
| `website/app/terms/page.tsx` | Next.js static export | App Router file-based routing | WIRED | `export default function TermsPage` present; `next.config.ts` confirms `output: "export"` |
| `website/app/privacy/page.tsx` | Next.js static export | App Router file-based routing | WIRED | `export default function PrivacyPage` present; same static export config |
| `settings_screen.dart` | `https://trysomething.app/privacy` and `/terms` | `_openLegalPage` + `launchUrl(LaunchMode.externalApplication)` | WIRED | Helper defined at line 51; called at lines 124 and 137 |
| `register_screen.dart` | `https://trysomething.app/terms` and `/privacy` | Inline async `TapGestureRecognizer` + `launchUrl` | WIRED | Both URLs wired at lines 364–382 |
| `login_screen.dart` | `https://trysomething.app/terms` and `/privacy` | Inline async `TapGestureRecognizer` + `launchUrl` | WIRED | Both URLs wired at lines 323–343 |

---

## Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
|-------------|------------|-------------|--------|----------|
| COMP-09 | 03-01-PLAN.md | Terms of Service hosted at stable public HTTPS URL | SATISFIED (source) | `website/app/terms/page.tsx` fully implemented, static export, all 16 sections present |
| COMP-10 | 03-01-PLAN.md | Privacy Policy hosted at stable public HTTPS URL | SATISFIED (source) | `website/app/privacy/page.tsx` fully implemented, static export, all 11 sections + 10 processor cards |
| COMP-11 | 03-02-PLAN.md | In-app legal links open hosted URLs in device browser | SATISFIED (code) | All 6 tap handlers (2 settings, 2 register, 2 login) wired to `launchUrl` with `LaunchMode.externalApplication` pointing to `https://trysomething.app/terms` and `/privacy` |

No orphaned requirements — all 3 IDs claimed by plans are fully accounted for.

---

## Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
|------|------|---------|----------|--------|
| `website/components/layout/Footer.tsx` | 1 | `"use client"` directive | INFO | Footer uses `new Date().getFullYear()` and `document.querySelector` (scroll behavior), requiring `"use client"`. This is intentional and correct — it does not affect the static export of the legal pages themselves. The legal pages (`terms/page.tsx`, `privacy/page.tsx`) are pure server components as required. |

No stubs, no TODO/placeholder comments, no empty return values found in any of the 5 modified files.

---

## Human Verification Required

### 1. Live URL accessibility — Terms of Service

**Test:** Open `https://trysomething.app/terms` in a browser (no authentication).
**Expected:** Page loads with "Terms of Service" heading, all 16 sections visible, HTTP 200, no redirect to a login page.
**Why human:** Cannot verify live HTTPS deployment or public crawlability from static analysis.

### 2. Live URL accessibility — Privacy Policy

**Test:** Open `https://trysomething.app/privacy` in a browser (no authentication).
**Expected:** Page loads with "Privacy Policy" heading, all 11 sections visible including all 10 data processor cards, HTTP 200, no redirect.
**Why human:** Same as above.

### 3. Settings About sheet legal links

**Test:** On a physical device or emulator, open Settings, tap the "About" sheet, then tap "Privacy Policy" and "Terms of Service".
**Expected:** Each tap closes the sheet and opens the respective `https://trysomething.app/...` URL in the system browser.
**Why human:** `url_launcher` with `LaunchMode.externalApplication` requires a real device environment.

### 4. Register screen legal links

**Test:** On the Register screen, tap "Terms of Service" and "Privacy Policy" in the consent text at the bottom.
**Expected:** Each opens the correct hosted URL in the system browser.
**Why human:** Same url_launcher requirement.

### 5. Login screen legal links

**Test:** On the Login screen, tap "Terms of Service" and "Privacy Policy" in the consent text at the bottom.
**Expected:** Each opens the correct hosted URL in the system browser.
**Why human:** Same url_launcher requirement.

---

## Summary

All five source-level checks pass with full evidence:

- **Website pages** (`/terms`, `/privacy`): Fully substantive static server components with all required legal content migrated verbatim, correct SEO metadata, back navigation, warm cinematic theme, no dynamic features, compatible with `output: "export"`.
- **Footer links**: Updated from `href: "#"` placeholders to `href: "/privacy"` and `href: "/terms"`.
- **Flutter in-app wiring**: All 6 legal link tap handlers across settings, register, and login screens call `launchUrl` with `LaunchMode.externalApplication` pointing to the correct `https://trysomething.app` URLs. `url_launcher: ^6.3.2` is declared in `pubspec.yaml`.

The only thing that cannot be verified statically is whether the Next.js site has been deployed to `trysomething.app` and the pages are publicly accessible. This is the expected final step before app store submission.

---

_Verified: 2026-03-21T20:30:00Z_
_Verifier: Claude (gsd-verifier)_
