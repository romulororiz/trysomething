---
phase: 13-detail-page-content-gating
plan: 02
subsystem: ui
tags: [flutter, riverpod, content-gating, paywall, blur, pro-upgrade]

# Dependency graph
requires:
  - phase: 13-detail-page-content-gating
    provides: "Server-side content gating endpoints and subscription provider"
provides:
  - "ProGateSection reusable blur + lock overlay widget"
  - "PlanFirstSessionCard shared coach entry component with isLocked flag"
  - "HobbyQuickLinks with locked mode and Budget Alternatives link"
  - "Detail page conditional gating based on isProProvider"
affects: [14-pause-resume, pro-screen, subscription]

# Tech tracking
tech-stack:
  added: []
  patterns: [ImageFiltered blur for scroll-safe content gating, ProGateSection wrapper pattern]

key-files:
  created:
    - lib/components/pro_gate_section.dart
    - lib/components/plan_first_session_card.dart
  modified:
    - lib/components/hobby_quick_links.dart
    - lib/screens/detail/hobby_detail_screen.dart
    - lib/screens/home/home_screen.dart

key-decisions:
  - "Used ImageFiltered instead of BackdropFilter to avoid scroll jank in lists"
  - "ProGateSection is a StatelessWidget receiving isLocked as param -- no provider dependency, parent controls state"
  - "PlanFirstSessionCard uses optional overrides for multi-mode reuse across detail (single mode) and home (3-mode)"
  - "Lock badges on quick links use 8px icon in 16px circle at top-right of feature icon"

patterns-established:
  - "ProGateSection wrapper: wrap any content widget to add blur + lock + upgrade CTA overlay"
  - "Shared component extraction: PlanFirstSessionCard pattern for detail+home reuse with optional overrides"

requirements-completed: [GATE-01, GATE-02, GATE-03, GATE-04, GATE-06]

# Metrics
duration: 7min
completed: 2026-03-23
---

# Phase 13 Plan 02: Content Gating UI Summary

**ProGateSection blur overlay, PlanFirstSessionCard shared component, and HobbyQuickLinks locked mode with Budget Alternatives link wired into detail and home screens**

## Performance

- **Duration:** 7 min
- **Started:** 2026-03-23T18:21:26Z
- **Completed:** 2026-03-23T18:28:02Z
- **Tasks:** 4
- **Files modified:** 5

## Accomplishments
- Created ProGateSection widget that blurs content behind a lock overlay with "Unlock with Pro" pill CTA
- Extracted PlanFirstSessionCard as shared ConsumerWidget supporting both locked (detail) and unlocked (home) modes with optional title/subtitle/message/mode overrides
- Added Budget Alternatives as third quick link in HobbyQuickLinks with lock badge support
- Wired all gating into detail screen: why-people-stop, starter kit, plan session blurred for free users; why-fits-you, start-in-20, what-to-expect, Start CTA remain free

## Task Commits

Each task was committed atomically:

1. **Task 1: Create ProGateSection widget and PlanFirstSessionCard** - `9bc3c88` (feat)
2. **Task 2: Update HobbyQuickLinks with locked mode and budget link** - `52aa066` (feat)
3. **Task 3: Wire ProGateSection into hobby detail screen** - `11ee0e1` (feat)
4. **Task 4: Wire PlanFirstSessionCard into Home screen** - `9b2f832` (feat)

## Files Created/Modified
- `lib/components/pro_gate_section.dart` - Reusable blur + lock overlay widget (ImageFiltered, not BackdropFilter)
- `lib/components/plan_first_session_card.dart` - Shared coach entry card with isLocked flag and optional overrides
- `lib/components/hobby_quick_links.dart` - Added isLocked param, onLockTap callback, Budget Alternatives third link, lock badges
- `lib/screens/detail/hobby_detail_screen.dart` - Wrapped 3 sections in ProGateSection, replaced _buildCoachTeaser with PlanFirstSessionCard, added isPro reactive state
- `lib/screens/home/home_screen.dart` - Replaced inline GlassCard coach entry with PlanFirstSessionCard(isLocked: false)

## Decisions Made
- Used ImageFiltered instead of BackdropFilter to avoid scroll jank in sliver lists -- BackdropFilter causes repaint on every frame during scroll
- ProGateSection is a plain StatelessWidget that receives isLocked as a parameter -- no provider reads inside, the parent screen owns the Pro state
- PlanFirstSessionCard accepts optional title/subtitle/coachMessage/coachMode/autoSend so Home screen can pass its 3-mode logic (rescue/start/momentum) while detail screen uses defaults
- Quick link lock badges use a small 8px lock icon in a 16px surfaceElevated circle positioned at top-right of the feature icon

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered
None

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- Content gating UI complete -- free users see blurred locked sections, Pro users see everything
- All locked taps trigger showProUpgrade with section-specific analytics triggers
- Ready for Phase 14 (Pause/Resume) which builds on the subscription infrastructure

## Self-Check: PASSED

All 5 files verified present. All 4 commits verified in git log.

---
*Phase: 13-detail-page-content-gating*
*Completed: 2026-03-23*
