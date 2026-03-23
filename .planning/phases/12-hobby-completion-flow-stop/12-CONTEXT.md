# Phase 12: Hobby Completion Flow + Stop - Context

**Gathered:** 2026-03-23
**Status:** Ready for planning

<domain>
## Phase Boundary

Server-side completion detection triggers a celebration, Home shows a completed state, completed hobbies move to Tried in You tab, and users can stop/abandon a hobby at any time. No pause functionality (that's Phase 14).

</domain>

<decisions>
## Implementation Decisions

### Celebration screen
- Full-screen overlay (takes over session screen, uses CinematicScaffold)
- No breathing ring animation — clean break, fresh celebration screen
- Content: mix of hobby-focused summary + stats (hobby name, total steps completed, days since started, sessions completed, warm message)
- Single CTA: "Discover your next hobby" (coral) linking to Discover tab
- No auto-exit timer — user must tap CTA

### Home completed state
- Completed hobby card stays visible with animated completion icon (checkmark drawing in or circle filling)
- Card shows: hobby title, animated complete icon, steps completed, days active, achievements — gamification and reward feeling
- Below the card: prominent coral "Find your next hobby" CTA linking to Discover
- Persists until user starts a new hobby — no auto-dismiss or timeout

### Stop/abandon UX
- Stop action lives in a 3-dot PopupMenuButton (⋮) on the active hobby card on Home
- Menu initially has one item: "Stop hobby" (Phase 14 adds "Pause hobby" to same menu)
- Tapping "Stop hobby" opens a bottom sheet via showAppSheet with warning text ("Your progress won't be saved"), hobby name, and destructive coral "Stop hobby" button — matches delete account pattern
- Transition is optimistic: hobby immediately moves to Tried locally, server call in background. If server fails, error snackbar but no revert

### Tried tab display
- Visually distinguish completed (all steps done) vs stopped hobbies
- Completed: checkmark/trophy icon + "Completed" label
- Stopped: neutral icon + "Stopped" label
- Card info: hobby title, completion/stop date, status icon, steps progress (e.g., "8/10 steps" for stopped)
- Tapping a Tried hobby opens the detail page in read-only mode (no "Start Hobby" CTA for Tried status)

### Claude's Discretion
- Animated completion icon style (Lottie, CustomPainter, or flutter_animate)
- Exact celebration screen layout and spacing
- Warm message copy on celebration screen
- How "read-only" detail page handles the Start CTA (hide vs disable vs replace with "Completed" label)
- Card density and spacing in Tried tab

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- `session_complete_phase.dart` (114 lines) — current generic step completion with 3-sec auto-exit, needs hobby-level completion awareness
- `CinematicScaffold` — base scaffold with warm background, reusable for celebration
- `glass_card.dart` — for stats display on celebration and Home completed card
- `showAppSheet` — for stop confirmation bottom sheet (same pattern as delete account)
- `setDone()` in `UserHobbiesNotifier` — already wired to API with `completedAt`, just needs to be called
- `hobby_card.dart` — existing card component, can be extended for completed state
- `flutter_animate` — already in pubspec, can animate the completion icon

### Established Patterns
- Session has 4 phases: prepare → timer → reflect → complete
- `hobbyCompleted` flag returned from server step endpoint (Phase 11)
- No PopupMenu or 3-dot menu exists on Home currently
- Optimistic updates: `UserHobbiesNotifier` does local state update + async API call (existing pattern)
- `you_screen.dart:70` — switch on `uh.status` already routes `done` to Tried tab

### Integration Points
- `session_provider.dart` — needs to read `hobbyCompleted` from API response and trigger celebration flow
- `session_complete_phase.dart` — conditional: if `hobbyCompleted`, show full celebration instead of step completion
- `home_screen.dart` — add completed state branch when active hobby has `status == done`
- `home_screen.dart` — add PopupMenuButton to active hobby card
- `you_screen.dart` — Tried tab cards need completion date + status icon display
- `hobby_detail_screen.dart` — hide "Start Hobby" CTA when hobby status is `done`

</code_context>

<specifics>
## Specific Ideas

- Celebration should feel premium and earned — editorial warmth + gamification stats
- "Discover your next hobby" is the primary conversion moment after completion
- Animated completion icon should feel satisfying — like a task being checked off with a flourish
- Stop confirmation matches the delete account bottom sheet pattern (consistency)
- Home completed state is a reward, not an empty state — celebrate, don't mourn

</specifics>

<deferred>
## Deferred Ideas

- Restart hobby (re-activate a stopped/done hobby) — defer to v2
- Share completion on social media — potential future feature
- Completion badges/achievements system — could enhance gamification feel in future

</deferred>

---

*Phase: 12-hobby-completion-flow-stop*
*Context gathered: 2026-03-23*
