---
gsd_state_version: 1.0
milestone: v1.2
milestone_name: Separation of Concerns Refactor
status: executing
last_updated: "2026-03-26"
progress:
  total_phases: 6
  completed_phases: 0
  total_plans: 2
  completed_plans: 1
---

# STATE.md -- TrySomething

*Project memory. Updated at every phase transition and plan completion.*
*Last updated: 2026-03-26 -- Plan 15-01 complete*

---

## Project Reference

See: .planning/PROJECT.md (updated 2026-03-26)

**Core value:** A user can discover a hobby that fits them, start it with clear first steps, and stick with it for 30 days.
**Current focus:** v1.2 Separation of Concerns Refactor -- Phase 15 Plan 01 complete

---

## Current Position

Phase: 15 of 20 (Home Screen Refactor) -- first of 6 phases in v1.2
Plan: 1 of 2 complete in current phase
Status: Executing Phase 15
Last activity: 2026-03-26 -- Plan 15-01 complete (extract PausedHobbyPage + RoadmapJourney)

Progress: [█████░░░░░] 50% (1/2 plans in phase 15)

---

## Performance Metrics

**Velocity:**
- Total plans completed: 1 (v1.2)
- Average duration: 3min
- Total execution time: 3min

**By Phase:**

| Phase | Plans | Total | Avg/Plan |
|-------|-------|-------|----------|
| 15 - Home Screen Refactor | 1/2 | 3min | 3min |

*Updated after each plan completion*

---

## Accumulated Context

### Decisions
- Extract widgets 100+ lines OR with own state (controllers, timers, providers)
- Target <500 lines per screen file (<300 for onboarding)
- CoachNotifier must move to its own provider file
- No new features -- pure refactor, zero UI/UX changes
- Photo picker becomes shared component in Phase 16, consumed by Phase 20
- `dart analyze` must pass with 0 errors, 0 warnings after every phase
- Widget extraction pattern: public class in new file, state class stays private, imports copied explicitly (15-01)
- _StepItem kept private in home_roadmap_section.dart since only used by RoadmapJourney (15-01)

### Current File Sizes (baseline)
- home_screen.dart: 1,119 lines after 15-01 (was 2,375, target ~400)
- settings_screen.dart: 2,082 lines (target ~300)
- you_screen.dart: 1,654 lines (target ~300)
- hobby_coach_screen.dart: 1,741 lines (target ~400)
- onboarding_screen.dart: 1,456 lines (target ~200)
- hobby_journal_screen.dart: 1,170 lines (target ~500)
- search_screen.dart: 1,128 lines (target ~500)
- hobby_detail_screen.dart: 1,070 lines (target ~500)
- discover_screen.dart: 970 lines (target ~500)

### Blockers
(none)

---

## Session Continuity

Last session: 2026-03-26
Stopped at: Completed 15-01-PLAN.md
Resume file: .planning/phases/15-home-screen-refactor/15-02-PLAN.md
