# Milestones

## v1.2 Separation of Concerns Refactor (Shipped: 2026-03-26)

**Phases completed:** 4 phases, 8 plans

**Key accomplishments:**
- Home screen decomposed: 2,375 → 393 lines — page variants, journal tiles, roadmap widgets extracted
- Settings screen decomposed: 2,082 → 831 lines — edit profile sheet, photo picker, section builders extracted
- You screen decomposed: 1,654 → 336 lines — 4 tab contents and hobby card variants extracted
- Coach screen decomposed: 1,741 → 367 lines — provider, bubbles, composer, mode widgets extracted to 5-file architecture
- Shared PhotoPickerOverlay component created in `lib/components/` for reuse across screens

**Stats:**
- Timeline: 1 day (2026-03-26)
- Commits: 32
- Files modified: 72
- Lines: +8,984 / -9,972 (net -988 lines)
- Screens refactored: 4 (home, settings, you, coach)

### Known Gaps
Phases 19-20 were planned but not executed. 7 requirements deferred:
- ONBD-01, ONBD-02 (Phase 19 — Onboarding Screen Refactor)
- MISC-01 through MISC-05 (Phase 20 — Remaining Screens Refactor)

These are pure refactoring tasks with no user-facing impact. Candidate for a future milestone.

---

## v1.0 Launch Readiness (Shipped: 2026-03-23)

**Phases completed:** 11 phases, 18 plans, 17 tasks

**Key accomplishments:**
- Server security hardened: webhook fail-closed with timingSafeEqual, server-side coach rate limiting via GenerationLog
- Full account deletion pipeline: soft-delete backend with 30-day purge cron, data export endpoint, Flutter Settings UI with email/OAuth confirmation flows
- Legal compliance: Terms of Service and Privacy Policy hosted on Next.js site, linked from Settings
- AI upgraded to Claude Sonnet: all generation endpoints with extractJson() guard and fixed stale detection
- Session screen redesigned: premium Apple Watch-style breathing ring with 5-layer stack architecture
- App store submission ready: privacy manifests, privacy labels, data safety form, store checklists, pre-commit hooks
- Dead code cleanup: 7,000+ lines removed (7 hidden feature screens)
- Apple OAuth routing fixed, restore purchases added

**Stats:**
- Timeline: 2 days (2026-03-21 → 2026-03-22)
- Commits: 121
- Files modified: 193
- Lines: +24,997 / -9,478
- Codebase: 50,138 LOC Dart + 18,312 LOC TypeScript

---

