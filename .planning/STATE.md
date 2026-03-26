---
gsd_state_version: 1.0
milestone: v1.2
milestone_name: Separation of Concerns Refactor
status: executing
last_updated: "2026-03-26"
progress:
  total_phases: 6
  completed_phases: 1
  total_plans: 2
  completed_plans: 2
---

# STATE.md -- TrySomething

*Project memory. Updated at every phase transition and plan completion.*
*Last updated: 2026-03-26 -- Phase 15 complete (Plan 15-02 done)*

---

## Project Reference

See: .planning/PROJECT.md (updated 2026-03-26)

**Core value:** A user can discover a hobby that fits them, start it with clear first steps, and stick with it for 30 days.
**Current focus:** v1.2 Separation of Concerns Refactor -- Phase 15 complete

---

## Current Position

Phase: 15 of 20 (Home Screen Refactor) -- first of 6 phases in v1.2
Plan: 2 of 2 complete in current phase
Status: Phase 15 Complete
Last activity: 2026-03-26 -- Plan 15-02 complete (extract ActiveHobbyPage + JournalEntryTile)

Progress: [██████████] 100% (2/2 plans in phase 15)

---

## Performance Metrics

**Velocity:**
- Total plans completed: 2 (v1.2)
- Average duration: 4min
- Total execution time: 8min

**By Phase:**

| Phase | Plans | Total | Avg/Plan |
|-------|-------|-------|----------|
| 15 - Home Screen Refactor | 2/2 | 8min | 4min |

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
- _RestartCard kept private in active_hobby_page.dart since only used by ActiveHobbyPage (15-02)
- Home screen 5-file decomposition: thin shell coordinator + 4 extracted widget files (15-02)

### Current File Sizes (baseline)
- home_screen.dart: 393 lines after 15-02 (was 2,375, target ~400) -- DONE
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
Stopped at: Completed 15-02-PLAN.md (Phase 15 complete)
Resume file: Next phase (16)
