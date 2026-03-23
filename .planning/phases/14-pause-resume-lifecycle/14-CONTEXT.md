# Phase 14: Pause/Resume Lifecycle - Context

**Gathered:** 2026-03-23
**Status:** Ready for planning

<domain>
## Phase Boundary

Pro users can pause an active hobby to preserve progress, see it as a muted card on Home and in a dedicated Paused tab on You, resume it with a coral CTA, and Pro subscription lapse auto-resumes paused hobbies via server webhook. No new schema changes needed (Phase 11 added `paused` enum + `pausedAt` + `pausedDurationDays`).

</domain>

<decisions>
## Implementation Decisions

### Paused Home card
- Same hobby card but at 0.7 opacity, with "Paused" chip and coral "Resume" CTA overlaid
- Days-paused counter visible (e.g., "Paused for 5 days")
- When paused, Home shows ONLY the muted card + Resume CTA + days counter — no coach, no roadmap, no next step
- Card is tappable (opens hobby detail page)

### Pause action
- "Pause hobby" added to existing 3-dot PopupMenu, above "Stop hobby"
- Only visible for Pro users (check `isProProvider` — free users don't see the option)
- Quick confirmation bottom sheet: "Pause [Hobby]? Your progress will be saved." with Pause/Cancel buttons
- Optimistic: hobby transitions to paused locally, server call in background

### Resume action
- Prominent coral "Resume" CTA button directly on the paused Home card
- Also available on paused cards in You tab
- No confirmation needed — one tap to resume
- On resume: set `lastActivityAt = now()` so 24h streak window starts fresh

### Pro lapse handling
- Server-side via RevenueCat EXPIRATION webhook
- When Pro expires: server sets all user's paused hobbies to `active` status, clears `pausedAt`, adds elapsed days to `pausedDurationDays`
- Silent auto-resume — no message shown to user
- Works even if user doesn't open the app

### You tab Paused filter
- New "Paused" tab alongside Active / Saved / Tried (4 tabs total)
- Paused hobby cards: muted styling + "Resume" CTA button on card (consistent with Home paused card)
- Tapping card opens detail page, tapping Resume button resumes the hobby

### Streak handling (from Phase 11 discussion)
- Streak freezes at pause value
- On resume: `lastActivityAt = now()` so 24h window starts fresh
- Pause duration NOT counted as inactivity gap

### Claude's Discretion
- Exact opacity and chip styling for paused cards
- "Paused" chip design (color, shape, position on card)
- Days counter formatting ("Paused for 5 days" vs "5d paused")
- Confirmation sheet layout and wording
- RevenueCat webhook event parsing (EXPIRATION payload structure)
- How to handle edge case: user pauses, then immediately resumes before server sync
- Tab order in You screen (Active / Paused / Saved / Tried vs other orderings)

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- `HobbyStatus.paused` — already in Dart enum + Prisma schema (Phase 11)
- `pausedAt DateTime?` + `pausedDurationDays Int` — fields exist on UserHobby model
- 3-dot `PopupMenuButton` on Home hobby card — already has "Stop hobby" item
- `stopHobby()` in `UserHobbiesNotifier` — pattern for `pauseHobby()` and `resumeHobby()`
- `showAppSheet` — for pause confirmation bottom sheet
- `isProProvider` — synchronous Pro check for conditional menu rendering
- RevenueCat webhook handler — exists in `server/api/users/[path].ts:1169`
- `canStartHobbyProvider` — already counts paused as active slot (Phase 11)

### Established Patterns
- Optimistic local update + async API call (existing pattern in `UserHobbiesNotifier`)
- You tab switch on `uh.status` — paused currently falls through to Active (line 73)
- `_CompletedHomeState` was removed — paused state will be a new branch in the Home build

### Integration Points
- `home_screen.dart` — needs paused state branch (like active but muted)
- `you_screen.dart` — needs 4th "Paused" tab
- `user_provider.dart` — needs `pauseHobby()` and `resumeHobby()` methods
- `server/api/users/[path].ts` — webhook handler needs EXPIRATION case for auto-resume
- `user_progress_repository.dart` + `_api.dart` — need pause/resume API methods

</code_context>

<specifics>
## Specific Ideas

- Paused card should feel like the hobby is "sleeping" — muted but alive, ready to come back
- Resume should be the most prominent action on a paused card — coral CTA, can't miss it
- The pause confirmation should reassure: "Your progress will be saved" — reduces anxiety about losing streaks

</specifics>

<deferred>
## Deferred Ideas

- Multiple pause/resume cycle tracking (PauseLog table) — defer to v2
- Pause time limit (auto-resume after 30 days) — not discussed, defer
- Notification reminder for paused hobbies ("Still paused — want to resume?") — future feature

</deferred>

---

*Phase: 14-pause-resume-lifecycle*
*Context gathered: 2026-03-23*
