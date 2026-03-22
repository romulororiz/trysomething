---
gsd_state_version: 1.0
milestone: v1.0
milestone_name: milestone
status: unknown
last_updated: "2026-03-22T14:32:30.501Z"
progress:
  total_phases: 12
  completed_phases: 7
  total_plans: 17
  completed_plans: 14
---

# STATE.md — TrySomething v1.0 Launch Readiness

*Project memory. Updated at every phase transition and plan completion.*
*Last updated: 2026-03-21 — Initialized after roadmap creation*

---

## Project Reference

**Core Value:** A user can discover a hobby that fits them, start it with clear first steps, and stick with it for 30 days.
**Milestone:** v1.0 Launch Readiness — App Store and Play Store submission-ready
**Milestone Goal:** All compliance blockers, security gaps, and production-readiness issues resolved before first store submission

---

## Current Position

Phase: 09.1 (session-screen-redesign-the-breathing-ring) — EXECUTING
Plan: 3 of 3

## Performance Metrics

| Metric | Value |
|--------|-------|
| Phases complete | 0/10 |
| Requirements mapped | 23/23 |
| Plans created | 0 |
| Plans complete | 0 |
| Blockers active | 0 |

---
| Phase 01 P01 | 2min | 1 tasks | 2 files |
| Phase 01 P02 | 2min | 2 tasks | 3 files |
| Phase 03 P02 | 2min | 2 tasks | 3 files |
| Phase 03 P01 | 6min | 2 tasks | 3 files |
| Phase 04 P01 | 4min | 2 tasks | 4 files |
| Phase 04 P02 | 4min | 3 tasks | 6 files |
| Phase 05 P01 | 4min | 2 tasks | 8 files |
| Phase 05 P01 | 4min | 2 tasks | 8 files |
| Phase 06 P01 | 3min | 2 tasks | 2 files |
| Phase 07 P01 | 5min | 2 tasks | 10 files |
| Phase 08 P01 | 2min | 1 tasks | 1 files |
| Phase 10 P01 | 10min | 2 tasks | 4 files |
| Phase 09 P01 | 2min | 2 tasks | 2 files |
| Phase 09.1 P01 | 6min | 2 tasks | 14 files |
| Phase 09.1 P02 | 4min | 2 tasks | 2 files |

## Accumulated Context

### Key Decisions Logged

| Decision | Phase | Rationale |
|----------|-------|-----------|
| Use Lefthook over Husky for pre-commit hooks | Phase 10 | Repo root is Flutter (no package.json); Lefthook is language-agnostic binary |
| Soft-delete (deletedAt) over hard-delete | Phase 4 | JWT tokens remain valid up to 30 days; soft-delete allows middleware to reject them |
| RevenueCat Authorization header check, not HMAC | Phase 1 | RevenueCat uses Authorization header, not HMAC payload signing — HMAC would drop all real events |
| GenerationLog for rate limiting, not Redis | Phase 1 | GenerationLog already has @@index([userId, createdAt]); no new infra needed at current scale |
| New endpoints as switch cases in users/[path].ts | Phase 4 | Project at Vercel free-tier 12-function limit; no new files |
| Dead code cleanup after Phase 6 | Phase 7 | Ensures all active screens are in final state before any deletions |
| Screenshots after Phase 8 (Sonnet upgrade) | Phase 9 | Screenshots should reflect final AI-powered experience |
| Used query='coach' in GenerationLog to distinguish coach from hobby generation | Phase 1 | Reuses existing query field; no schema change needed |
| Log coach messages AFTER AI response (not before) | Phase 1 | Failed/timed-out API calls should not count against user's rate limit |
| Default hasPassword to true for backwards compat | Phase 5 | Shows password field if server hasn't deployed yet (safer default) |
| Use box.clear() not deleteBoxFromDisk() for Hive | Phase 5 | Keeps boxes open, prevents "Box already closed" crashes |
| deleteAccount() returns bool, leaves SharedPrefs/onboarding to caller | Phase 5 | AuthNotifier has no WidgetRef; Settings screen handles those |
| Left NearbyUser model in social.dart despite removing getSimilarUsers | Phase 7 | Still referenced by feature_seed_data.dart per D-02 (do not touch seed data) |
| No model changes needed: AI-01 and AI-02 already deployed | Phase 8 | Sonnet model and stale detection were already in production code |
| extractJson uses regex capture group for first code fence | Phase 8 | More robust than dual-replace; handles edge cases with multiple fence blocks |
| Use --no-fatal-warnings for dart analyze in pre-commit | Phase 10 | Pre-existing warnings (2 unused_element) would block all Dart commits; errors still abort |
| Exclude test/ from tsconfig.json for tsc --noEmit | Phase 10 | Vitest uses own transform; broken test imports don't affect production type safety |
| Use ./node_modules/.bin/tsc instead of npx tsc | Phase 10 | Direct binary avoids nvm/npm version mismatch on Windows dev machine |
| CA92.1 reason code for UserDefaults privacy manifest | Phase 9 | Covers Hive and SharedPreferences reading their own keys |
| iPhone-only targeting (TARGETED_DEVICE_FAMILY=1) | Phase 9 | Eliminates iPad screenshot requirement for App Store submission |
| Single CustomPainter for all 4 ring layers | Phase 09.1 | One painter with 4 canvas.draw calls is more efficient than 4 stacked CustomPaint widgets |
| Film grain as static PNG overlay, not per-frame noise | Phase 09.1 | Static 256x256 PNG at 1.5% opacity is visually identical to dynamic noise and costs zero GPU |
| Placeholder background pending Plan 02 ring integration | Phase 09.1 | SessionParticleField removed; Container placeholder keeps build green until 5-layer stack in Plan 02 |

### Architecture Notes

- `GenerationLog` has no FK to `User` (plain `userId String`) — must be deleted explicitly in `$transaction` before `user.delete`
- All other 13 user FK tables have `onDelete: Cascade` — handled at DB level automatically
- `CacheManager.clearAll()` added in Phase 5 Plan 1 — uses box.clear() on both `_dataBox` and `_metaBox`
- `deletedAt` field requires a Prisma schema migration — commit migration to git before deploying
- Apple Sign-In requires token revocation call (Apple REST API) on account deletion per TN3194
- Sonnet output may wrap JSON in markdown code fences — `extractJson()` guard must strip before `JSON.parse`

### Roadmap Evolution

- Phase 09.1 inserted after Phase 9: Session Screen Redesign — The Breathing Ring (URGENT)

### Active Todos

*(Populated as plans execute)*

### Quick Tasks Completed

| # | Description | Date | Commit | Directory |
|---|-------------|------|--------|-----------|
| 260321-s8z | Apple OAuth Routing Fix | 2026-03-21 | 01890b6 | [260321-s8z-apple-oauth-routing-fix](./quick/260321-s8z-apple-oauth-routing-fix/) |

### Active Blockers

*(None at milestone start)*

---

## Session Continuity

**To resume after a break:**

1. Read this STATE.md for current position and context
2. Read `.planning/ROADMAP.md` for full phase structure
3. Run `/gsd:plan-phase [N]` to plan the current phase if no plan exists
4. Run `/gsd:work` to continue execution on the active plan

**Phase transition checklist:**

- [ ] All plans in current phase complete
- [ ] All phase success criteria verified (observable, not assumed)
- [ ] REQUIREMENTS.md traceability updated (phase status → Complete)
- [ ] STATE.md updated with decisions and context from this phase
- [ ] Run `/gsd:transition` to advance to next phase

---

## Roadmap Quick Reference

| Phase | Goal | Requirements | Status |
|-------|------|--------------|--------|
| 1 | Server security hardening | SEC-01, SEC-02 | Not started |
| 2 | Apple OAuth routing fix | SEC-03 | Not started |
| 3 | Legal docs — host and link | COMP-09, COMP-10, COMP-11 | Not started |
| 4 | Account deletion + export — backend | COMP-01, COMP-02, COMP-03, COMP-06, COMP-07, COMP-08 | Not started |
| 5 | Account deletion — Flutter UX | COMP-04, COMP-05 | Not started |
| 6 | Restore purchases | SUB-01 | Not started |
| 7 | Dead code cleanup | CLEAN-01 | Not started |
| 8 | Sonnet AI upgrade | AI-01, AI-02, AI-03 | Not started |
| 9 | App store assets and admin | COMP-12, COMP-13, COMP-14 | Not started |
| 10 | Pre-commit hooks | DX-01 | Not started |

---

*Initialized: 2026-03-21*
