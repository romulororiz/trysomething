# Requirements: TrySomething

**Defined:** 2026-03-23
**Core Value:** A user can discover a hobby that fits them, start it with clear first steps, and stick with it through guided support.

## v1.1 Requirements

Requirements for v1.1 Hobby Lifecycle & Monetization. Each maps to roadmap phases.

### Completion Flow

- [x] **COMP-01**: Hobby auto-transitions to `done` status when all roadmap steps are completed (server-side detection in step completion endpoint, returns `hobbyCompleted` flag)
- [x] **COMP-02**: Celebration screen displays when user completes the final step (distinct from regular step completion, hobby-specific copy with hobby title and step count)
- [x] **COMP-03**: Home shows completed state with "pick your next hobby" CTA linking to Discover when active hobby is done
- [x] **COMP-04**: Completed hobbies appear in You tab "Tried" section with completion date

### Lifecycle

- [x] **LIFE-01**: User can stop/abandon an active hobby (free) — moves to Tried with confirmation prompt, no progress preserved
- [x] **LIFE-02**: User can pause an active hobby (Pro) — preserves progress, streaks, completed steps; requires active Pro entitlement
- [x] **LIFE-03**: User can resume a paused hobby (Pro) — picks up where they left off with streak continuity
- [x] **LIFE-04**: Home shows paused hobby with frosted glass card (opacity 0.7), "Paused" chip, coral "Resume" CTA, days-paused counter
- [x] **LIFE-05**: You tab shows Paused as a distinct filter state alongside Active/Saved/Tried with pause icon on card
- [ ] **LIFE-06**: Pro subscription lapse auto-resumes paused hobbies as active (no data lost, removes pause state gracefully)
- [ ] **LIFE-07**: Pause duration excluded from streak calculation (pausedDurationDays subtracted from gap)

### Content Gating

- [x] **GATE-01**: Detail page shows for free users: hero image, spec badge, "why it fits you", "start in 20 minutes", what to expect, full 4-stage roadmap overview, "Start Hobby" CTA
- [x] **GATE-02**: Detail page Pro-locked sections: why people stop, starter kit list, plan first session, cost breakdown, FAQ, budget alternatives
- [x] **GATE-03**: Locked sections render as glass card with lock icon, section title, one-line teaser text, "Unlock with Pro" pill
- [x] **GATE-04**: Tapping any locked section triggers existing `showProUpgrade()` bottom sheet
- [x] **GATE-05**: Server-side gate on `/api/generate/faq`, `/api/generate/cost`, `/api/generate/budget` endpoints — return 403 for non-Pro users
- [x] **GATE-06**: Plan First Session card on Home (for active hobby) uses same component as detail page version, ungated for active hobby

### Schema

- [x] **SCHM-01**: Add `paused` to `HobbyStatus` enum in Prisma schema and Flutter model via two-step migration (add enum value first, then use it)
- [x] **SCHM-02**: Add `pausedAt DateTime?` and `pausedDurationDays Int @default(0)` fields to UserHobby model
- [x] **SCHM-03**: Server-side step completion endpoint sets `status = done` and `completedAt = now()` when all steps are complete (single transaction)

## v2 Requirements

Deferred to future release. Tracked but not in current roadmap.

### Enhanced Lifecycle

- **LIFE-08**: Multiple pause/resume cycles tracked with PauseLog join table
- **LIFE-09**: "Restart hobby" action — reset all progress and start fresh
- **LIFE-10**: Hobby archive — hide from all views but preserve data

### Enhanced Gating

- **GATE-07**: Progressive unlock — completing Stage 1 unlocks Stage 2 preview for free users
- **GATE-08**: Time-limited Pro trial on specific hobby (try Pro features for one hobby only)

## Out of Scope

| Feature | Reason |
|---------|--------|
| Gating the roadmap overview | Roadmap visibility drives engagement and conversion — hiding it hurts free users |
| Removing free coach messages | 3 msg/month demonstrates value and drives upgrades; zero messages = no trial |
| 30-day timer enforcement | Steps are the real progression; 30 days is marketing, not a constraint |
| Blur overlay on locked content | Research shows lock icon + clear CTA outperforms blur (cleaner, more intentional) |
| Hard-deleting stopped hobbies | Keep data for analytics and potential "restart" in v2 |
| Gating active hobby features on Home | Free users who started a hobby should succeed — frustrated users don't convert |

## Traceability

Which phases cover which requirements. Updated during roadmap creation.

| Requirement | Phase | Status |
|-------------|-------|--------|
| SCHM-01 | Phase 11 | Complete |
| SCHM-02 | Phase 11 | Complete |
| SCHM-03 | Phase 11 | Complete |
| COMP-01 | Phase 12 | Complete |
| COMP-02 | Phase 12 | Complete |
| COMP-03 | Phase 12 | Complete |
| COMP-04 | Phase 12 | Complete |
| LIFE-01 | Phase 12 | Complete |
| GATE-01 | Phase 13 | Complete |
| GATE-02 | Phase 13 | Complete |
| GATE-03 | Phase 13 | Complete |
| GATE-04 | Phase 13 | Complete |
| GATE-05 | Phase 13 | Complete |
| GATE-06 | Phase 13 | Complete |
| LIFE-02 | Phase 14 | Complete |
| LIFE-03 | Phase 14 | Complete |
| LIFE-04 | Phase 14 | Complete |
| LIFE-05 | Phase 14 | Complete |
| LIFE-06 | Phase 14 | Pending |
| LIFE-07 | Phase 14 | Pending |

**Coverage:**
- v1.1 requirements: 20 total
- Mapped to phases: 20
- Unmapped: 0

---
*Requirements defined: 2026-03-23*
*Last updated: 2026-03-23 after roadmap creation — traceability complete*
