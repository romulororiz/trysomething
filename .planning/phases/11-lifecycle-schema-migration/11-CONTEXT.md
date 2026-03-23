# Phase 11: Lifecycle Schema Migration - Context

**Gathered:** 2026-03-23
**Status:** Ready for planning

<domain>
## Phase Boundary

Add `paused` to `HobbyStatus` enum, add `pausedAt` and `pausedDurationDays` fields to `UserHobby`, and wire server-side completion detection in the step endpoint. No UI changes — this phase produces a compiling schema and API that later phases build on.

</domain>

<decisions>
## Implementation Decisions

### Status flow
- Valid transitions: `saved → trying → active → done`; `active/trying → paused` (Pro only); `paused → active` (resume); `active/trying/paused → done` (stop)
- Paused hobbies can be stopped directly (no forced resume first)
- No restart in v1.1 — stopped and completed hobbies go to Tried permanently
- Done vs Stopped distinction: Claude's discretion on whether to use a single `done` status with a flag or separate enum values. Optimize for minimal switch statement complexity.

### Completion detection
- Hobby auto-transitions to `done` when all roadmap steps are completed (completedStepCount === totalStepCount)
- Flexible step order stays — users can do step 3 before step 1
- Server-side detection: step completion endpoint checks count in the same transaction
- No user confirmation prompt — completion is automatic when the last step is marked

### Pause data model
- Single counter approach: `pausedAt DateTime?` + `pausedDurationDays Int @default(0)`
- On pause: set `pausedAt = now()`
- On resume: add elapsed days to `pausedDurationDays`, clear `pausedAt`, set `lastActivityAt = now()`
- Pro lapse: auto-resume paused hobbies as active (no data lost, just lose ability to re-pause)
- Streak behavior: freeze at pause value. On resume, set `lastActivityAt = now()` so 24h window starts fresh

### Step completion API
- Step completion endpoint returns `{ hobbyCompleted: true/false }` in response
- When `hobbyCompleted: true`, server has already set `status = done` + `completedAt = now()` in the same DB transaction
- Client reads the flag to trigger celebration — no separate status update call needed
- Single atomic transaction prevents partial states

### Claude's Discretion
- Whether to add a `stopped` enum value or reuse `done` with a distinguishing field
- Prisma migration splitting strategy (research flagged PostgreSQL error 55P04)
- Freezed codegen ordering and build_runner approach
- Which existing switch statements need updating and how to handle the new `paused` case in each

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- `UserHobbiesNotifier.setDone()` in `user_provider.dart` — already wired to API, just never called automatically
- `UserCompletedStep` join table — tracks step completion, can be counted server-side
- `completedAt DateTime?` already exists on `UserHobby` in Prisma schema — just needs to be set

### Established Patterns
- `HobbyStatus` enum: Prisma (`schema.prisma:210`) + Dart (`hobby.dart:136`) + Freezed codegen
- Status transitions via `UserHobbiesNotifier` methods with optimistic local update + API call
- Server hobbies-detail handler in `server/api/users/[path].ts` handles step toggle via POST

### Integration Points
- `you_screen.dart:70` — switch on `uh.status` to filter Active/Saved/Tried tabs
- `home_screen.dart:72,100` — filters `trying || active` for display
- `server/api/users/[path].ts` — step completion POST handler, needs completion check added
- `server/prisma/schema.prisma:210-215` — HobbyStatus enum, needs `paused` added
- `lib/models/hobby.dart:136` — Dart enum, needs `paused` added

</code_context>

<specifics>
## Specific Ideas

No specific requirements — standard schema migration and API extension patterns.

</specifics>

<deferred>
## Deferred Ideas

- Restart hobby feature (re-activate a stopped/done hobby) — defer to v2
- Full PauseLog table for multiple pause/resume cycle analytics — defer to v2

</deferred>

---

*Phase: 11-lifecycle-schema-migration*
*Context gathered: 2026-03-23*
