---
phase: 03-legal-documents-host-and-link
plan: 01
subsystem: ui
tags: [next.js, static-pages, legal, terms-of-service, privacy-policy, tailwind]

# Dependency graph
requires: []
provides:
  - "Terms of Service page at /terms on Next.js website"
  - "Privacy Policy page at /privacy on Next.js website"
  - "Footer with working legal navigation links"
affects: [app-store-prep, settings-screen-links]

# Tech tracking
tech-stack:
  added: []
  patterns: [legal-page-layout-pattern-with-nav-and-glass-cards]

key-files:
  created:
    - website/app/terms/page.tsx
    - website/app/privacy/page.tsx
  modified:
    - website/components/layout/Footer.tsx

key-decisions:
  - "Migrated all legal text verbatim from Flutter Dart screens to Next.js TSX pages"
  - "Used pure static components compatible with output: export (no use client, no hooks)"
  - "Used warm cinematic theme tokens consistently (bg-bg, text-coral, glass cards)"

patterns-established:
  - "Legal page pattern: nav back link + max-w-3xl centered content + glass contact blocks"

requirements-completed: [COMP-09, COMP-10]

# Metrics
duration: 6min
completed: 2026-03-21
---

# Phase 3 Plan 1: Legal Documents Host and Link Summary

**Terms of Service (16 sections) and Privacy Policy (11 sections) as static Next.js pages with Footer navigation links**

## Performance

- **Duration:** 6 min
- **Started:** 2026-03-21T19:51:53Z
- **Completed:** 2026-03-21T19:57:52Z
- **Tasks:** 2
- **Files modified:** 3

## Accomplishments
- Created Terms of Service page with all 16 legal sections faithfully migrated from Flutter Dart source
- Created Privacy Policy page with all 11 sections, 10 data processor cards, and FDPIC contact info
- Updated Footer component to replace placeholder # links with /privacy and /terms routes
- Both pages build successfully as static HTML via Next.js output: export

## Task Commits

Each task was committed atomically:

1. **Task 1: Create Terms of Service and Privacy Policy pages** - `a2a698c` (feat)
2. **Task 2: Update Footer legal links from placeholders to real routes** - `c983b77` (feat)

## Files Created/Modified
- `website/app/terms/page.tsx` - Terms of Service static page with all 16 sections, SEO metadata, back navigation
- `website/app/privacy/page.tsx` - Privacy Policy static page with all 11 sections, 10 data processor cards, SEO metadata
- `website/components/layout/Footer.tsx` - Updated legal links from href="#" to href="/privacy" and href="/terms"

## Decisions Made
- Migrated all legal text verbatim from Flutter Dart screens (terms_of_service_screen.dart and privacy_policy_screen.dart) to ensure exact content parity
- Used pure static server components (no "use client", no useState/useEffect) to maintain compatibility with Next.js static export
- Applied warm cinematic theme tokens consistently: coral section headings, glass card contact blocks, text-secondary body text

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered
None

## User Setup Required

None - no external service configuration required.

## Known Stubs

None - all legal content is fully rendered with no placeholder text.

## Next Phase Readiness
- Both /terms and /privacy pages are ready for app store submission URLs
- Footer links are functional for website visitors
- In-app settings screen can link to these URLs (future task if needed)

## Self-Check: PASSED

All files exist. All commits verified.

---
*Phase: 03-legal-documents-host-and-link*
*Completed: 2026-03-21*
