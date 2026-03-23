# Phase 12: Hobby Completion Flow + Stop - Context

**Gathered:** 2026-03-23
**Status:** IN PROGRESS — discussion interrupted, 1 of 4 areas complete

<domain>
## Phase Boundary

Server-side completion detection triggers a celebration, Home shows a completed state, completed hobbies move to Tried in You tab, and users can stop/abandon a hobby at any time. No pause functionality (that's Phase 14).

</domain>

<decisions>
## Implementation Decisions

### Celebration screen
- Full-screen overlay (takes over session screen, uses CinematicScaffold)
- No breathing ring animation — clean break, fresh celebration screen
- Content: mix of hobby-focused summary + stats (hobby name, total steps, days since started, sessions completed, warm message)
- Single CTA: "Discover your next hobby" (coral) linking to Discover tab
- No auto-exit timer — user must tap CTA

### Home completed state
- NEEDS DISCUSSION

### Stop/abandon UX
- NEEDS DISCUSSION

### Tried tab display
- NEEDS DISCUSSION

### Claude's Discretion
- TBD after discussion complete

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- `session_complete_phase.dart` (114 lines) — current generic step completion, needs hobby-level awareness
- `CinematicScaffold` — base scaffold with warm background, reusable for celebration
- `glass_card.dart` — for stats display
- `showAppSheet` / `showAppConfirmDialog` — for stop confirmation
- `setDone()` in `UserHobbiesNotifier` — already wired to API, just needs to be called

### Established Patterns
- Session has 4 phases: prepare → timer → reflect → complete
- `hobbyCompleted` flag now returned from server step endpoint (Phase 11)
- No PopupMenu or 3-dot menu exists on Home currently

### Integration Points
- `session_provider.dart` — needs to read `hobbyCompleted` from API response
- `session_complete_phase.dart` — needs conditional: if hobbyCompleted, show celebration instead
- `home_screen.dart` — needs completed empty state
- `you_screen.dart` — needs completion date display in Tried tab

</code_context>

<specifics>
## Specific Ideas

- Celebration should feel premium and earned — editorial warmth + data stats
- "Discover your next hobby" is the primary conversion moment after completion

</specifics>

<deferred>
## Deferred Ideas

None yet — discussion in progress.

</deferred>

---

*Phase: 12-hobby-completion-flow-stop*
*Context gathered: 2026-03-23 (partial — interrupted)*
