# Roadmap: TrySomething

## Milestones

- ✅ **v1.0 Launch Readiness** — Phases 1-10 (shipped 2026-03-23)
- ✅ **v1.1 Hobby Lifecycle & Monetization** — Phases 11-14 (shipped 2026-03-23)
- ✅ **v1.2 Separation of Concerns Refactor** — Phases 15-18 (shipped 2026-03-26)

---

## Phases

<details>
<summary>✅ v1.0 Launch Readiness (Phases 1-10) -- SHIPPED 2026-03-23</summary>

- [x] **Phase 1: Server Security Hardening** — Close the live webhook vulnerability and replace bypassable client-side rate limit with server-side enforcement (completed 2026-03-21)
- [x] **Phase 2: Apple OAuth Routing Fix** — One-line vercel.json fix that unblocks Apple Sign-In testing on iOS (completed 2026-03-21)
- [x] **Phase 3: Legal Documents -- Host and Link** — Publish Terms and Privacy Policy to the Next.js site and wire up Settings links (completed 2026-03-21)
- [x] **Phase 4: Account Deletion + Data Export -- Backend** — Build DELETE and export endpoints with atomic cascade and FADP-compliant field allowlist (completed 2026-03-21)
- [x] **Phase 5: Account Deletion -- Flutter UX** — Settings flow with confirmation dialog, subscription warning, and full client-side storage wipe (completed 2026-03-21)
- [x] **Phase 6: Restore Purchases** — Add RevenueCat restore flow to paywall and Settings per Apple guideline 3.1.1 (completed 2026-03-21)
- [x] **Phase 7: Dead Code Cleanup** — Remove 7 hidden feature screens (~7,000 lines) safely via impact analysis (completed 2026-03-21)
- [x] **Phase 8: Sonnet AI Upgrade** — Deploy prepared Sonnet files; fix stale detection and add JSON extraction guard (completed 2026-03-22)
- [x] **Phase 9: App Store Assets and Admin** — Screenshots, privacy manifests, privacy labels, data safety form, metadata (completed 2026-03-22)
- [x] **Phase 9.1: Session Screen Redesign -- The Breathing Ring** (INSERTED) — Replace particle field with premium Apple Watch-style breathing ring (completed 2026-03-22)
- [x] **Phase 10: Pre-Commit Hooks** — Install Lefthook for Flutter analyze + TypeScript lint on every commit (completed 2026-03-22)

See: `.planning/milestones/v1.0-ROADMAP.md` for full details

</details>

<details>
<summary>✅ v1.1 Hobby Lifecycle & Monetization (Phases 11-14) -- SHIPPED 2026-03-23</summary>

- [x] **Phase 11: Lifecycle Schema Migration** — Add `paused` enum value and pause tracking fields to Prisma schema and Dart model (completed 2026-03-23)
- [x] **Phase 12: Hobby Completion Flow + Stop** — Server-side completion detection, celebration overlay, Home completed state, and free stop/abandon action (completed 2026-03-23)
- [x] **Phase 13: Detail Page Content Gating** — Free vs Pro content sections with `ProGateSection` widget and server-side endpoint guards (completed 2026-03-23)
- [x] **Phase 14: Pause/Resume Lifecycle** — Pro-gated pause action, paused state display, resume, Pro-lapse auto-resume, and streak-safe pause duration tracking (completed 2026-03-23)

See: `.planning/milestones/v1.0-ROADMAP.md` for full details (v1.1 section)

</details>

<details>
<summary>✅ v1.2 Separation of Concerns Refactor (Phases 15-18) -- SHIPPED 2026-03-26</summary>

- [x] **Phase 15: Home Screen Refactor** — Extract page variants, journal tiles, and roadmap widgets from home_screen.dart (2,375 → 393 lines) (completed 2026-03-26)
- [x] **Phase 16: Settings Screen Refactor** — Extract edit profile sheet, photo picker, and section builders from settings_screen.dart (2,082 → 831 lines) (completed 2026-03-26)
- [x] **Phase 17: You Screen Refactor** — Extract tab contents and hobby card variants from you_screen.dart (1,654 → 336 lines) (completed 2026-03-26)
- [x] **Phase 18: Coach Screen Refactor** — Extract CoachNotifier, message bubbles, composer, and mode selector from hobby_coach_screen.dart (1,741 → 367 lines) (completed 2026-03-26)

**Known gaps:** Phases 19 (Onboarding) and 20 (Remaining Screens) were planned but deferred — 7 requirements remain as tech debt.

See: `.planning/milestones/v1.2-ROADMAP.md` for full details

</details>

---

## Progress

| Phase | Milestone | Plans Complete | Status | Completed |
|-------|-----------|----------------|--------|-----------|
| 1-10 | v1.0 | 18/18 | Complete | 2026-03-22 |
| 11-14 | v1.1 | 8/8 | Complete | 2026-03-23 |
| 15-18 | v1.2 | 8/8 | Complete | 2026-03-26 |

---

*Roadmap created: 2026-03-21 (v1.0)*
*v1.1 phases added: 2026-03-23*
*v1.2 phases added: 2026-03-26*
*v1.2 shipped: 2026-03-26 (Phases 15-18 complete, 19-20 deferred)*
