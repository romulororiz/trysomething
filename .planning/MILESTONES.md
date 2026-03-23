# Milestones

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

