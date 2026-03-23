# Roadmap: TrySomething

## Milestones

- ✅ **v1.0 Launch Readiness** — Phases 1–10 (shipped 2026-03-23)
- 🚧 **v1.1 Hobby Lifecycle & Monetization** — Phases 11–14 (in progress)

---

## Phases

<details>
<summary>✅ v1.0 Launch Readiness (Phases 1–10) — SHIPPED 2026-03-23</summary>

- [x] **Phase 1: Server Security Hardening** — Close the live webhook vulnerability and replace bypassable client-side rate limit with server-side enforcement (completed 2026-03-21)
- [x] **Phase 2: Apple OAuth Routing Fix** — One-line vercel.json fix that unblocks Apple Sign-In testing on iOS (completed 2026-03-21)
- [x] **Phase 3: Legal Documents — Host and Link** — Publish Terms and Privacy Policy to the Next.js site and wire up Settings links (completed 2026-03-21)
- [x] **Phase 4: Account Deletion + Data Export — Backend** — Build DELETE and export endpoints with atomic cascade and FADP-compliant field allowlist (completed 2026-03-21)
- [x] **Phase 5: Account Deletion — Flutter UX** — Settings flow with confirmation dialog, subscription warning, and full client-side storage wipe (completed 2026-03-21)
- [x] **Phase 6: Restore Purchases** — Add RevenueCat restore flow to paywall and Settings per Apple guideline 3.1.1 (completed 2026-03-21)
- [x] **Phase 7: Dead Code Cleanup** — Remove 7 hidden feature screens (~7,000 lines) safely via impact analysis (completed 2026-03-21)
- [x] **Phase 8: Sonnet AI Upgrade** — Deploy prepared Sonnet files; fix stale detection and add JSON extraction guard (completed 2026-03-22)
- [x] **Phase 9: App Store Assets and Admin** — Screenshots, privacy manifests, privacy labels, data safety form, metadata (completed 2026-03-22)
- [x] **Phase 9.1: Session Screen Redesign — The Breathing Ring** (INSERTED) — Replace particle field with premium Apple Watch-style breathing ring (completed 2026-03-22)
- [x] **Phase 10: Pre-Commit Hooks** — Install Lefthook for Flutter analyze + TypeScript lint on every commit (completed 2026-03-22)

### Phase Details (v1.0 — archived)

**Phase 1:** Requirements SEC-01, SEC-02 | 2/2 plans complete
**Phase 2:** Requirements SEC-03 | 1/1 plans complete
**Phase 3:** Requirements COMP-09, COMP-10, COMP-11 | 2/2 plans complete
**Phase 4:** Requirements COMP-01, COMP-02, COMP-03, COMP-06, COMP-07, COMP-08 | 2/2 plans complete
**Phase 5:** Requirements COMP-04, COMP-05 | 2/2 plans complete
**Phase 6:** Requirements SUB-01 | 1/1 plans complete
**Phase 7:** Requirements CLEAN-01 | 1/1 plans complete
**Phase 8:** Requirements AI-01, AI-02, AI-03 | 1/1 plans complete
**Phase 9:** Requirements COMP-12, COMP-13, COMP-14 | 2/2 plans complete
**Phase 9.1:** No requirements (inserted visual redesign) | 3/3 plans complete
**Phase 10:** Requirements DX-01 | 1/1 plans complete

</details>

---

### 🚧 v1.1 Hobby Lifecycle & Monetization (In Progress)

**Milestone Goal:** Fix broken hobby completion flow, add pause/stop lifecycle, and gate detail page content for Pro conversion.

- [x] **Phase 11: Lifecycle Schema Migration** — Add `paused` enum value and pause tracking fields to Prisma schema and Dart model; run codegen before any downstream work (completed 2026-03-23)
- [x] **Phase 12: Hobby Completion Flow + Stop** — Server-side completion detection, celebration overlay, Home completed state, and free stop/abandon action (completed 2026-03-23)
- [x] **Phase 13: Detail Page Content Gating** — Free vs Pro content sections with `ProGateSection` widget and server-side endpoint guards (completed 2026-03-23)
- [x] **Phase 14: Pause/Resume Lifecycle** — Pro-gated pause action, paused state display, resume, Pro-lapse auto-resume, and streak-safe pause duration tracking (completed 2026-03-23)

---

## Phase Details

### Phase 11: Lifecycle Schema Migration
**Goal:** The Prisma schema and Dart model both contain `HobbyStatus.paused`, `pausedAt`, and `pausedDurationDays`, and the build compiles cleanly before any UI work starts
**Depends on:** Nothing (first phase of v1.1)
**Requirements:** SCHM-01, SCHM-02, SCHM-03
**Success Criteria** (what must be TRUE):
  1. The Neon database has `paused` as a valid `HobbyStatus` enum value and `UserHobby` rows have `pausedAt` and `pausedDurationDays` columns — confirmed by Prisma Studio or psql
  2. `flutter analyze` passes with zero errors after adding `HobbyStatus.paused` to the Dart enum and running `build_runner`
  3. All existing `switch` statements on `HobbyStatus` compile without exhaustive-switch warnings — every switch has a `paused` case
  4. The step completion endpoint (`PATCH /api/users/hobbies/:id/steps/:stepId`) sets `status = done` and `completedAt = now()` atomically when the final step is recorded, and returns a `hobbyCompleted` flag in its response
**Plans:** 2/2 plans complete
Plans:
- [ ] 11-01-PLAN.md — Prisma schema + migrations + mapper + step completion endpoint
- [ ] 11-02-PLAN.md — Dart model + codegen + exhaustive switch fixes

### Phase 12: Hobby Completion Flow + Stop
**Goal:** Users reach a genuine completion moment when they finish their 30-day hobby — the app recognises it, celebrates it, and the Home tab reflects the new state; users can also stop/abandon a hobby at any time
**Depends on:** Phase 11
**Requirements:** COMP-01, COMP-02, COMP-03, COMP-04, LIFE-01
**Success Criteria** (what must be TRUE):
  1. Completing the final roadmap step triggers a full-screen celebration overlay (distinct from per-step completion) with the hobby name and total step count — not a generic message
  2. After dismissing the celebration, the Home tab shows a "You finished — pick your next hobby" state with a coral CTA linking to Discover, not the normal active hobby dashboard
  3. The completed hobby appears in the You tab "Tried" section with its completion date visible
  4. Tapping the 3-dot menu on an active hobby card presents a "Stop hobby" option that, after a confirmation prompt, moves the hobby to Tried and frees the active hobby slot immediately — no waiting for a network response
**Plans:** 2/2 plans complete
Plans:
- [x] 12-01-PLAN.md — Surface hobbyCompleted flag through data layer + celebration screen
- [x] 12-02-PLAN.md — Home completed state + stop action + Tried tab cards + detail read-only

### Phase 13: Detail Page Content Gating
**Goal:** Free users see a rich preview of a hobby's detail page and are clearly shown what Pro unlocks, without losing any content they already had access to
**Depends on:** Phase 11
**Requirements:** GATE-01, GATE-02, GATE-03, GATE-04, GATE-05, GATE-06
**Success Criteria** (what must be TRUE):
  1. A free user on the detail page sees hero image, spec badge, "why it fits you", "start in 20 minutes", full 4-stage roadmap overview, and the "Start Hobby" CTA — no locked gates on these sections
  2. Why people stop, starter kit list, plan first session, cost breakdown, FAQ, and budget alternatives each render as a locked glass card with a lock icon, a one-line teaser, and an "Unlock with Pro" pill
  3. Tapping any locked section opens the existing Pro upgrade bottom sheet — no new modal or navigation required
  4. A Pro user on the same screen sees all sections fully expanded with no gate UI visible
  5. Sending a generate request (`/api/generate/faq`, `/api/generate/cost`, `/api/generate/budget`) as a free user returns a 403 response from the server — the gate is enforced server-side, not just client-side
**Plans:** 2/2 plans complete
Plans:
- [ ] 13-01-PLAN.md — Server-side requirePro() helper + 403 gating on faq/cost/budget endpoints
- [ ] 13-02-PLAN.md — ProGateSection widget + detail screen gating + HobbyQuickLinks locked mode + PlanFirstSessionCard extraction

### Phase 14: Pause/Resume Lifecycle
**Goal:** Pro users can pause an active hobby to preserve their progress through a break, and the app handles every transition cleanly — including Pro subscription lapse — without stranding the user's hobby in an inaccessible state
**Depends on:** Phase 11, Phase 12 (lifecycle sheet component established)
**Requirements:** LIFE-02, LIFE-03, LIFE-04, LIFE-05, LIFE-06, LIFE-07
**Success Criteria** (what must be TRUE):
  1. A Pro user tapping the 3-dot menu on their active hobby sees a "Pause hobby" option; a free user does not — the option is conditionally rendered based on live RevenueCat entitlement
  2. After pausing, the Home tab shows the hobby card at 0.7 opacity with a "Paused" chip and a coral "Resume" CTA, alongside a counter showing how many days it has been paused
  3. The You tab shows a distinct "Paused" filter state so the user can find their paused hobby alongside Active / Saved / Tried
  4. Tapping "Resume" from Home or You restores the hobby to active status with all completed steps intact and the correct streak — the pause gap is not counted as inactivity
  5. If a Pro subscription lapses while a hobby is paused, the hobby automatically transitions to active (not stuck in paused), and the user sees it normally on their next app open
**Plans:** 2/2 plans complete
Plans:
- [ ] 14-01-PLAN.md — Repository + provider pause/resume methods + server PUT extension + webhook auto-resume
- [ ] 14-02-PLAN.md — Home paused state + pause menu + confirmation sheet + You tab Paused filter

---

## Progress

**Execution Order:** 11 → 12 → 13 (parallel with 12) → 14

| Phase | Milestone | Plans Complete | Status | Completed |
|-------|-----------|----------------|--------|-----------|
| 1. Server Security Hardening | v1.0 | 2/2 | Complete | 2026-03-21 |
| 2. Apple OAuth Routing Fix | v1.0 | 1/1 | Complete | 2026-03-21 |
| 3. Legal Documents | v1.0 | 2/2 | Complete | 2026-03-21 |
| 4. Account Deletion — Backend | v1.0 | 2/2 | Complete | 2026-03-21 |
| 5. Account Deletion — Flutter UX | v1.0 | 2/2 | Complete | 2026-03-21 |
| 6. Restore Purchases | v1.0 | 1/1 | Complete | 2026-03-21 |
| 7. Dead Code Cleanup | v1.0 | 1/1 | Complete | 2026-03-21 |
| 8. Sonnet AI Upgrade | v1.0 | 1/1 | Complete | 2026-03-22 |
| 9. App Store Assets | v1.0 | 2/2 | Complete | 2026-03-22 |
| 9.1. Session Screen Redesign | v1.0 | 3/3 | Complete | 2026-03-22 |
| 10. Pre-Commit Hooks | v1.0 | 1/1 | Complete | 2026-03-22 |
| 11. Lifecycle Schema Migration | v1.1 | 2/2 | Complete | 2026-03-23 |
| 12. Hobby Completion Flow + Stop | v1.1 | 2/2 | Complete | 2026-03-23 |
| 13. Detail Page Content Gating | v1.1 | 2/2 | Complete | 2026-03-23 |
| 14. Pause/Resume Lifecycle | 2/2 | Complete    | 2026-03-23 | — |

---

## Coverage Map (v1.1)

| Requirement | Phase | Description |
|-------------|-------|-------------|
| SCHM-01 | Phase 11 | Add `paused` to HobbyStatus enum (split migration) |
| SCHM-02 | Phase 11 | Add `pausedAt` and `pausedDurationDays` to UserHobby |
| SCHM-03 | Phase 11 | Step completion endpoint returns `hobbyCompleted` flag in transaction |
| COMP-01 | Phase 12 | Server-side auto-transition to `done` when all steps complete |
| COMP-02 | Phase 12 | Celebration overlay on final step completion |
| COMP-03 | Phase 12 | Home completed state with "pick your next hobby" CTA |
| COMP-04 | Phase 12 | Completed hobbies in You tab Tried section with date |
| LIFE-01 | Phase 12 | Stop/abandon action — moves to Tried with confirmation, frees slot |
| GATE-01 | Phase 13 | Detail page free sections: hero + spec + Stage 1 overview + CTA |
| GATE-02 | Phase 13 | Detail page Pro-locked sections: kit, plan, cost, FAQ, budget |
| GATE-03 | Phase 13 | Locked sections render as glass card with lock icon + teaser + CTA |
| GATE-04 | Phase 13 | Tapping locked section triggers existing showProUpgrade() sheet |
| GATE-05 | Phase 13 | Server-side 403 gate on /api/generate/faq, cost, budget for free users |
| GATE-06 | Phase 13 | Plan First Session card on Home uses same component, ungated |
| LIFE-02 | Phase 14 | Pause action (Pro) — preserves progress + requires live entitlement check |
| LIFE-03 | Phase 14 | Resume paused hobby (Pro) — restores status to trying |
| LIFE-04 | Phase 14 | Home paused state: dimmed card, "Paused" chip, "Resume" CTA, days counter |
| LIFE-05 | Phase 14 | You tab Paused filter state alongside Active/Saved/Tried |
| LIFE-06 | Phase 14 | Pro lapse auto-resumes paused hobbies to active via RevenueCat webhook |
| LIFE-07 | Phase 14 | Pause duration excluded from streak (pausedDurationDays in gap formula) |

**Total mapped: 20/20**

---

## Dependency Graph (v1.1)

```
Phase 11 (Schema Migration)
  ├──> Phase 12 (Completion Flow + Stop)
  ├──> Phase 13 (Content Gating)  ← parallel with Phase 12
  └──> Phase 14 (Pause/Resume)    ← depends on Phase 11 + Phase 12 scaffold
```

---

## Backlog

### Phase 999.1: Paused Hobby (promoted to Phase 14)

*(Promoted from backlog — was Phase 999.1 in v1.0 ROADMAP.md)*

---

*Roadmap created: 2026-03-21 (v1.0)*
*v1.1 phases added: 2026-03-23*
*Last updated: 2026-03-23 after Phase 14 planning*
