# Phase 3: Legal Documents -- Host and Link - Research

**Researched:** 2026-03-21
**Domain:** Legal page hosting (Next.js static site) + Flutter in-app linking
**Confidence:** HIGH

## Summary

This phase is straightforward: legal document text already exists as hardcoded Flutter screens (`privacy_policy_screen.dart`, `terms_of_service_screen.dart`), the website (`website/`) is a Next.js 16 static export already deployed to Vercel, and the app already has `url_launcher: ^6.3.2` in pubspec.yaml. The work is: (1) create `/terms` and `/privacy` pages in the Next.js website using App Router, (2) update the Flutter settings screen to open those hosted URLs via `url_launcher` instead of navigating to in-app screens, and (3) update the website footer to link to the new pages instead of `#`.

The existing legal content is fully written -- over 540 lines of Privacy Policy and 460 lines of Terms of Service, covering FADP/GDPR compliance, AI disclosure, data processors, and Swiss jurisdiction. No legal drafting is needed. The task is purely converting this content to web-hosted HTML pages and wiring up the links.

**Primary recommendation:** Add `website/app/terms/page.tsx` and `website/app/privacy/page.tsx` as static pages in the existing Next.js site, then update the Flutter settings to open those URLs via `launchUrl` with `LaunchMode.externalApplication`.

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| COMP-09 | Terms of Service hosted at a publicly accessible HTTPS URL | Next.js App Router static page at `website/app/terms/page.tsx` on the existing Vercel deployment |
| COMP-10 | Privacy Policy hosted at a publicly accessible HTTPS URL | Next.js App Router static page at `website/app/privacy/page.tsx` on the existing Vercel deployment |
| COMP-11 | In-app links to hosted legal pages from Settings screen | Replace `context.push('/terms-of-service')` and `context.push('/privacy-policy')` with `launchUrl()` calls using `url_launcher` (already in pubspec.yaml) |
</phase_requirements>

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Next.js | 16.1.6 | Static site framework for legal pages | Already used for the landing page in `website/` directory |
| Tailwind CSS | 4.2.1 | Styling legal pages | Already configured in the website with theme tokens matching the app design system |
| url_launcher | ^6.3.2 | Opening legal URLs from Flutter | Already a dependency in pubspec.yaml, already used in 3 places in the codebase |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| React | 19.2.4 | Component rendering | Already in the website |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Next.js pages | Standalone HTML files | Would work but misses shared layout, fonts, theming from the existing site |
| `launchUrl` (external browser) | In-app WebView | External browser is standard for legal docs -- avoids WebView security concerns, simpler, no extra dependency |
| Converting .docx | Hardcoded content from existing Flutter screens | The .docx files are mentioned but not found -- the content is already fully written in the Flutter screens as Dart string literals |

**Installation:**
```bash
# No new packages needed -- everything is already installed
# Website: Next.js 16.1.6, Tailwind CSS 4.2.1, React 19.2.4
# Flutter: url_launcher ^6.3.2
```

## Architecture Patterns

### Recommended Project Structure
```
website/
├── app/
│   ├── layout.tsx           # Existing root layout (fonts, metadata)
│   ├── page.tsx             # Existing landing page
│   ├── globals.css          # Existing styles
│   ├── terms/
│   │   └── page.tsx         # NEW: Terms of Service page
│   └── privacy/
│       └── page.tsx         # NEW: Privacy Policy page
```

### Pattern 1: Static Legal Page as Next.js App Router Page
**What:** Each legal document is a simple React component in its own route directory under `app/`. Since the site uses `output: "export"`, these become static HTML files at build time.
**When to use:** Always for this project -- the site is statically exported, no server-side features needed.
**Example:**
```tsx
// website/app/terms/page.tsx
import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Terms of Service - TrySomething",
  description: "Terms of Service for the TrySomething mobile application.",
};

export default function TermsPage() {
  return (
    <main className="max-w-3xl mx-auto px-6 py-16">
      <h1 className="text-3xl font-bold text-text-primary mb-2 font-serif">
        Terms of Service
      </h1>
      <p className="text-sm text-text-muted mb-8">
        Effective date: 14 March 2026
      </p>
      {/* Section content using existing Tailwind theme tokens */}
      <section className="prose-legal space-y-6">
        <h2 className="text-xl font-semibold text-coral">1. Agreement to Terms</h2>
        <p className="text-text-secondary leading-relaxed">
          By downloading, installing, or using the TrySomething mobile application...
        </p>
      </section>
    </main>
  );
}
```

### Pattern 2: Flutter URL Opening with url_launcher
**What:** Replace in-app GoRouter navigation to local legal screens with `launchUrl()` to open hosted web pages in the device's default browser.
**When to use:** For all legal document links in the app (Settings, About sheet, onboarding).
**Example:**
```dart
// In settings_screen.dart
import 'package:url_launcher/url_launcher.dart';

// Constants (add to api_constants.dart or a new legal_constants.dart)
const String termsUrl = 'https://trysomething.app/terms';   // or whatever the domain is
const String privacyUrl = 'https://trysomething.app/privacy';

// Opening a legal page
Future<void> _openLegalPage(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
```

### Pattern 3: Shared Layout for Legal Pages
**What:** Legal pages should use the same root layout as the landing page (fonts, base styles) but NOT the full landing page chrome (no Navbar, no SmoothScroll, no Footer sections). Instead, use a minimal layout with just a back-to-home link.
**When to use:** For legal pages that need to be clean, readable, and fast-loading.
**Example:**
```tsx
// Legal pages use the root layout.tsx (which provides fonts + body styles)
// but render their own minimal wrapper -- no need for a nested layout
export default function PrivacyPage() {
  return (
    <div className="min-h-screen bg-bg">
      <nav className="max-w-3xl mx-auto px-6 pt-8">
        <a href="/" className="text-sm text-text-secondary hover:text-text-primary">
          &larr; Back to TrySomething
        </a>
      </nav>
      <main className="max-w-3xl mx-auto px-6 py-12">
        {/* Legal content */}
      </main>
    </div>
  );
}
```

### Anti-Patterns to Avoid
- **Embedding legal content in a WebView inside Flutter:** Adds webview_flutter dependency, complicates navigation, and creates security concerns. External browser is the standard for legal docs.
- **Keeping legal docs as in-app-only screens:** App stores require the URLs to be publicly accessible and crawlable. The existing in-app screens satisfy the in-app requirement but NOT the public URL requirement.
- **Using a CMS or database for legal content:** Overkill for two static documents that change rarely. Hardcoded content in TSX files is appropriate.
- **Duplicating the full landing page Navbar/Footer on legal pages:** Legal pages should be clean and focused. A simple back link is sufficient.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| URL opening from Flutter | Custom platform channel for browser | `url_launcher` package (already installed) | Handles all platforms, fallbacks, and launch modes |
| Static page routing | Custom server or redirect logic | Next.js App Router file-based routing | `app/terms/page.tsx` automatically becomes `/terms` |
| Legal page styling | Custom CSS from scratch | Existing Tailwind theme tokens in `globals.css` | Theme variables (`--color-text-primary`, `--color-coral`, etc.) already match the app design system |
| Content conversion from Flutter to web | Automated .docx-to-HTML converter | Manual copy of text content from existing Dart screens | Content is already finalized in `privacy_policy_screen.dart` (542 lines) and `terms_of_service_screen.dart` (461 lines). Copy the text strings directly. |

**Key insight:** The legal content is already fully written and structured in the Flutter codebase. This phase is a content migration + link wiring task, not a content creation task.

## Common Pitfalls

### Pitfall 1: Forgetting the Static Export Constraint
**What goes wrong:** Adding server-side features (API routes, server components with `headers()`, dynamic rendering) to the legal pages causes the `next build` to fail because `output: "export"` is set in `next.config.ts`.
**Why it happens:** Developers forget that the website uses static export mode.
**How to avoid:** Legal pages must be pure static components. No `cookies()`, `headers()`, `searchParams` on the server, or API routes. All content is hardcoded in the TSX file.
**Warning signs:** `next build` fails with "Page with `dynamic` couldn't be exported" error.

### Pitfall 2: Wrong URL Domain
**What goes wrong:** Flutter links point to a different domain than where the website is deployed, or to localhost/staging.
**Why it happens:** The website deployment URL is not clearly documented. The Footer has `hello@trysomething.app` as contact but the API uses `api.trysomething.io`.
**How to avoid:** Define the legal page URLs as constants in a single place in the Flutter codebase. Verify the actual production URL of the Next.js website before hardcoding.
**Warning signs:** Links from the app lead to 404 pages or wrong domains.

### Pitfall 3: Not Updating All Link Locations
**What goes wrong:** Some links are updated but others still point to the old in-app routes.
**Why it happens:** Legal links appear in multiple places: (1) Settings screen About sheet (`_showAboutSheet` method, lines 113-133), (2) the website Footer (`Footer.tsx`, lines 66-67 with `href: "#"`), and possibly (3) app store listings.
**How to avoid:** Search for ALL occurrences of `/privacy-policy`, `/terms-of-service`, `Privacy Policy`, and `Terms of Service` across the entire codebase. Update every instance.
**Warning signs:** Tapping a link navigates to an in-app screen instead of opening the browser.

### Pitfall 4: Not Handling `canLaunchUrl` Failure
**What goes wrong:** `canLaunchUrl` returns false on some devices (especially Android with intent query restrictions), leaving the user unable to access legal documents.
**Why it happens:** Android 11+ restricts which apps can be queried. While `url_launcher` handles most cases, edge cases exist.
**How to avoid:** Either remove the `canLaunchUrl` check (the existing codebase pattern uses it, but `launchUrl` will throw on failure, which can be caught), or keep the check and show a fallback (copy URL to clipboard, or navigate to the existing in-app screen as fallback).
**Warning signs:** Users report they cannot open legal documents on certain Android devices.

### Pitfall 5: Removing In-App Screens Too Early
**What goes wrong:** Deleting `privacy_policy_screen.dart` and `terms_of_service_screen.dart` before verifying the web pages are live.
**Why it happens:** Eager cleanup.
**How to avoid:** Keep the in-app screens and routes in place during this phase. They can be deprecated in a future phase. The router already marks them as public routes (lines 450-451 of `router.dart`). Simply update the Settings links to use `launchUrl` instead.
**Warning signs:** Removing screens before web pages are deployed and verified.

### Pitfall 6: Missing SEO Metadata on Legal Pages
**What goes wrong:** Legal pages are deployed but without proper `<title>`, `<meta description>`, or `<meta robots>` tags.
**Why it happens:** Focus on content, not metadata.
**How to avoid:** Each legal page should export a `metadata` object (Next.js App Router pattern) with title, description, and ensure the page is indexable (no `noindex` robots tag).
**Warning signs:** Searching for "TrySomething privacy policy" on Google returns nothing.

## Code Examples

Verified patterns from the existing codebase:

### Existing url_launcher Usage Pattern (from starter_kit_card.dart)
```dart
// Source: lib/components/starter_kit_card.dart, lines 26-33
import 'package:url_launcher/url_launcher.dart';

Future<void> _openAffiliateLink(KitItem item) async {
  final url = item.affiliateUrl ??
      'https://www.amazon.de/s?k=${Uri.encodeComponent(item.name)}&tag=trysomething-21';
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
```

### Existing In-App Legal Link Pattern (to be replaced)
```dart
// Source: lib/screens/settings/settings_screen.dart, lines 113-134
// Current: navigates to in-app Flutter screens
GestureDetector(
  onTap: () {
    Navigator.pop(context);
    context.push('/privacy-policy');
  },
  child: Text('Privacy Policy',
      style: AppTypography.caption.copyWith(color: AppColors.accent)),
),
// ...
GestureDetector(
  onTap: () {
    Navigator.pop(context);
    context.push('/terms-of-service');
  },
  child: Text('Terms of Service',
      style: AppTypography.caption.copyWith(color: AppColors.accent)),
),
```

### Website Footer Legal Links (to be updated)
```tsx
// Source: website/components/layout/Footer.tsx, lines 66-67
// Current: links to "#" (placeholder)
{ label: "Privacy Policy", href: "#" },
{ label: "Terms of Service", href: "#" },
```

### Next.js App Router Static Page Pattern (from existing page.tsx)
```tsx
// Source: website/app/page.tsx
// Pattern: default export function, uses components from @/components
import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Terms of Service - TrySomething",
  description: "...",
};

export default function TermsPage() {
  return (
    <main>
      {/* Static content */}
    </main>
  );
}
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| In-app hardcoded legal screens | Hosted web pages + external browser links | Industry standard since app stores started requiring public URLs | App stores require publicly accessible legal URLs |
| `output: "export"` static site | Same | Next.js has supported this since v13 | Legal pages fit naturally as static routes |
| `canLaunchUrl` + `launchUrl` | Same pattern (url_launcher 6.x) | url_launcher 6.0 (2022) | LaunchMode enum replaced boolean flags |

**Deprecated/outdated:**
- Using `launch()` function from url_launcher -- replaced by `launchUrl()` in v6.x. The codebase already uses the current API.
- `forceWebView` parameter -- replaced by `LaunchMode.inAppWebView` enum value.

## Open Questions

1. **What is the production domain for the website?**
   - What we know: The website uses Next.js and is deployed to Vercel. The Footer references `hello@trysomething.app`. The API is at `api.trysomething.io`. The codebase references both `.io` and `.app` TLDs.
   - What's unclear: The exact production URL for the website (e.g., `trysomething.app`, `www.trysomething.app`, or a Vercel subdomain like `trysomething-landing.vercel.app`).
   - Recommendation: Check the Vercel dashboard or run `vercel ls` in the website directory to determine the production URL. The legal page URLs in Flutter must match this exactly.

2. **Should in-app legal screens be removed or kept as fallback?**
   - What we know: The in-app screens exist with full content. The router marks them as public routes.
   - What's unclear: Whether to keep them as offline fallback or remove to reduce maintenance.
   - Recommendation: Keep them in place for this phase. Do not delete or modify the in-app screens. Only change the links in the Settings/About UI to open the web URLs. Removal can be a separate future task.

## Sources

### Primary (HIGH confidence)
- Codebase analysis: `website/next.config.ts` -- confirms `output: "export"` static site
- Codebase analysis: `website/app/layout.tsx` -- confirms App Router with Metadata API
- Codebase analysis: `website/package.json` -- confirms Next.js 16.1.6, React 19.2.4, Tailwind CSS 4.2.1
- Codebase analysis: `pubspec.yaml` line 82 -- confirms `url_launcher: ^6.3.2`
- Codebase analysis: `lib/screens/settings/settings_screen.dart` lines 113-134 -- confirms current in-app legal links
- Codebase analysis: `lib/screens/settings/privacy_policy_screen.dart` (542 lines) -- full privacy policy content
- Codebase analysis: `lib/screens/settings/terms_of_service_screen.dart` (461 lines) -- full terms content
- Codebase analysis: `website/components/layout/Footer.tsx` lines 66-67 -- confirms placeholder `#` links
- Codebase analysis: `lib/router.dart` lines 311-333, 450-451 -- confirms existing routes and public route check

### Secondary (MEDIUM confidence)
- [Apple App Store privacy policy requirements](https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-privacy/) -- Privacy policy URL required in App Store Connect and accessible in-app
- [Google Play Store privacy policy requirements](https://termly.io/resources/articles/google-play-store-privacy-policy-updates/) -- Privacy policy URL mandatory, must be publicly accessible
- [url_launcher pub.dev documentation](https://pub.dev/packages/url_launcher) -- LaunchMode.externalApplication for external browser

### Tertiary (LOW confidence)
- None -- all findings are from codebase analysis or official sources

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - all libraries already in the project, no new dependencies needed
- Architecture: HIGH - Next.js App Router file-based routing is the most basic feature, static export is confirmed
- Pitfalls: HIGH - identified from direct codebase analysis of existing link locations and Next.js config
- Legal content: HIGH - fully verified by reading both in-app screen files (1000+ lines of legal text already written)

**Research date:** 2026-03-21
**Valid until:** 2026-04-21 (stable -- no fast-moving dependencies)
