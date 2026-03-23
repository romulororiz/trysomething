# Project Research Summary

**Project:** TrySomething v1.1 — Hobby Lifecycle & Content Gating
**Domain:** Flutter mobile hobby-guidance app — completion flows, pause/stop states, Pro content gating
**Researched:** 2026-03-23
**Confidence:** HIGH

## Executive Summary

TrySomething v1.1 adds three capability areas on top of a fully-working v1.0 production system: auto-completion detection when all roadmap steps are done, a pause/stop lifecycle (free users can stop, Pro users can pause with progress preserved), and detail page content gating (Stage 1 and starter kit remain free; Stages 2-4, FAQ, cost, and budget alternatives lock behind Pro). The core research finding is that all three capabilities are achievable with zero new packages — the existing stack (Riverpod, Freezed, flutter_animate, RevenueCat, Prisma) already contains every primitive needed. The only infrastructure change is a single Prisma schema migration to add a `paused` variant to the `HobbyStatus` enum and a nullable `pausedAt` column to `UserHobby`.

The recommended build order is strictly phase-sequential because of a hard dependency chain: the schema migration must be deployed and Freezed codegen must run before any UI touching the `paused` status is built. Completion detection (Phase 2) is the highest user-value item and should ship before pause/stop (Phase 4), since completion is the core product moment — finishing a 30-day hobby — while pause is an edge-case lifecycle action. Content gating (Phase 3) has no data dependencies and can be built in parallel with Phase 2 after Phase 1 codegen completes.

The dominant risks are not UI complexity but infrastructure correctness: the Prisma enum migration must be split to avoid a known PostgreSQL transaction error; completion detection must be server-driven (not client-counted) to avoid race conditions and duplicate analytics events; and the Pro subscription downgrade path for paused hobbies must be defined and implemented in the same phase as pause itself — not deferred. Each of these is a critical pitfall with documented recovery cost of HIGH if missed.

## Key Findings

### Recommended Stack

No new packages are required. The entire v1.1 feature set is achievable through model changes, state logic additions, and conditional UI using the packages already installed. The only setup commands are `dart run build_runner build --delete-conflicting-outputs` (after Freezed model changes) and `npx prisma migrate dev --name add_hobby_paused_status` (from the `server/` directory).

**Core technologies:**
- `flutter_riverpod ^2.6.1`: State management for all lifecycle state transitions — extend `UserHobbiesNotifier` with `pauseHobby()`, `resumeHobby()`, `stopHobby()`; completion detection reads from server response flag
- `freezed_annotation ^2.4.4`: Add `HobbyStatus.paused` enum variant and `DateTime? pausedAt` / `int pausedDurationDays` fields to `UserHobby` — requires build_runner regeneration after changes
- `flutter_animate ^4.5.2`: Completion celebration animation — already installed, sufficient for fade/scale/shimmer chains; no Lottie package needed
- `purchases_flutter ^9.14.0` + `isProProvider`: Gate pause action and detail page Stages 2-4 using the same pattern already used for coach chat limits and the paywall sheet
- `prisma ^6.4.1`: One schema migration — `ALTER TYPE HobbyStatus ADD VALUE 'paused'` plus nullable `pausedAt` and `pausedDurationDays` columns on `UserHobby` — all non-blocking on Neon

### Expected Features

**Must have (table stakes — all required for v1.1 milestone):**
- Auto-complete detection: server returns `hobbyCompleted: true` flag when final step is recorded; Flutter reads the flag and triggers celebration
- Completion celebration screen: distinct from per-step completion; hobby-specific copy; "pick your next hobby" CTA; stays until user taps, does not auto-navigate
- Home completed state: `_CompletedAllState` widget when `activeEntries.isEmpty && hasCompletedHobbies` — distinct from generic new-user empty state
- Completed hobbies in You tab "Tried" section: `done` status already maps here; no change required
- Stop/abandon action (free): moves to `tried` status, two-step confirmation, asks for stop reason (optional), frees the hobby slot immediately regardless of network state
- Pause action (Pro-gated): requires schema migration; preserves step progress; `pausedAt` timestamp recorded; resume is always free (Pro gate only on initiating a pause)
- Resume paused hobby: single-tap from Home or You tab; restores status to `trying`, clears `pausedAt`, adds gap to `pausedDurationDays`
- Detail page Stage 1 free / Stages 2-4 locked: conditional rendering via `ProGateSection` widget; inline upgrade prompt at stage boundary (not full-screen paywall)
- Detail page FAQ + cost + budget locked for free users: same `ProGateSection` pattern; gate new AI generation calls, not existing cached content

**Should have (target v1.2):**
- Personalized "pick your next hobby" recommendations after completion (similar category/difficulty)
- Coach-aware resume: AI coach acknowledges pause gap in first message after resume
- Pause reason capture: optional single-tap (Life got busy / Trying something else / Need a break)

**Defer to v2+:**
- Completion milestone sharing (social features previously removed in v1.0)
- Hobby streak tracking (contradicts product thesis for overwhelmed adults)
- Progress recovery after stop (adds state complexity; stop is intentional)

### Architecture Approach

The system is a Flutter Riverpod client reading from `userHobbiesProvider` (local-first, Hive-backed, API-synced), talking to Vercel serverless Node/TS endpoints backed by Neon PostgreSQL via Prisma. All three capability areas follow existing patterns: Riverpod state machines for lifecycle, `isProProvider` for gating, repository `updateStatus()` for API sync. Four new files are needed and eight existing files are modified. Content gating is purely client-side conditional rendering — the server returns all data and the client gates based on `isProProvider`. Completion detection is the exception: the server must own the `done` transition in the same database transaction as step recording, to prevent race conditions.

**Major components:**
1. `UserHobbiesNotifier` (user_provider.dart) — add `pauseHobby()`, `resumeHobby()`, `stopHobby()`; `_exitSession()` reads the server's `hobbyCompleted` flag instead of inferring from local step count
2. `HobbyLifecycleSheet` (new: `lib/components/hobby_lifecycle_sheet.dart`) — bottom sheet offering Stop (free) and Pause (Pro-gated); entry point from 3-dot icon on active hobby card in Home
3. `HobbyCompletionCelebration` (new: `lib/components/hobby_completion_celebration.dart`) — imperative Navigator overlay pushed from `_exitSession()`, not a GoRouter route; user-dismissed
4. `ProGateSection` (new: `lib/screens/detail/pro_gate_section.dart`) — blur + lock + coral CTA wrapper; applied to Stages 2-4 roadmap and to FAQ/cost/budget sections in detail screen
5. `HomeCompletedState` (new: `lib/screens/home/home_completed_state.dart`) — "You finished — what's next?" card with Discover CTA; shown when `activeEntries.isEmpty && hasCompletedHobbies`

### Critical Pitfalls

1. **Prisma enum migration transaction error** — Adding `paused` to `HobbyStatus` and using it as a default in the same migration triggers PostgreSQL error `55P04` (confirmed in Prisma issues #8424, #5290, #7251; still present in Prisma 6.4.1). Prevention: manually inspect generated SQL before deploying; if `ALTER TYPE ADD VALUE` and any usage of the new value appear in the same file, split into two sequential migration files.

2. **Auto-completion race condition** — Client-side step counting against local `completedStepIds` can fire `setDone()` on stale state, producing duplicate `hobby_completed` analytics events and a celebration screen that contradicts the Home tab state. Prevention: server endpoint returns a `hobbyCompleted: true` flag and sets `status = done` server-side in the same transaction; Flutter reads the flag, never infers completion from local counts.

3. **Pro lapse strands paused hobby** — If subscription lapses, hobby is stuck in `paused` and invisible to the user (excluded from both active and tried views). Prevention: resume is always free (Pro gate applies only to initiating a pause); implement the RevenueCat `EXPIRATION` webhook handler to transition paused hobbies to `stopped` in the same phase as pause.

4. **Content gating removes existing free access** — Detail page currently shows FAQ/cost/budget to all users. Retrospectively gating it may trigger App Store Review Guideline §3.1.2(a). Prevention: gate only new AI generation calls; free users see a paywall prompt for the "Generate" button; previously generated cached content remains accessible to all users.

5. **Streak counter breaks on resume** — Without `pausedDurationDays` tracked, the streak calculation sees a pause gap as inactivity and resets the streak to zero. Prevention: add `pausedDurationDays Int @default(0)` to the schema in Phase 1; streak formula: `effectiveGap = totalGapDays - pausedDurationDays`; Home screen must not decrement streak countdown while `status == paused`.

## Implications for Roadmap

Based on combined research, the build order is dictated by a hard dependency chain: schema migration first, then completion flow and content gating in parallel, then pause/stop lifecycle last.

### Phase 1: Lifecycle Schema Migration
**Rationale:** Everything downstream depends on `HobbyStatus.paused`, `pausedAt`, and `pausedDurationDays` existing in both the Prisma schema and the Dart model. Freezed codegen breaks the build if enum values are out of sync. This is the only database change in v1.1 and must be deployed and compiled before any UI work starts.
**Delivers:** Prisma migration applied to Neon; `HobbyStatus.paused` enum in Dart; `UserHobby.pausedAt` and `UserHobby.pausedDurationDays` Freezed fields; build_runner codegen complete; `mapUserHobby()` mapper updated; any `switch` statements on `HobbyStatus` updated with `paused` case to prevent exhaustive-switch compile errors
**Avoids:** Pitfall 1 (enum migration) — inspect generated SQL before running; Pitfall 5 (streak tracking fields added now before any pause logic references them)

### Phase 2: Completion Flow
**Rationale:** Highest user value, lowest risk. Only touches three existing files plus two new ones. The existing `setDone()` and `toggleStep()` machinery is already wired end-to-end — the only missing pieces are the server returning a `hobbyCompleted` flag and `_exitSession()` reading it. Stop action (free, no schema dependency) is also included here as the simpler half of the lifecycle sheet.
**Delivers:** Server-side completion detection (step endpoint returns `hobbyCompleted` flag); `HobbyCompletionCelebration` overlay triggered from `_exitSession()`; `HomeCompletedState` widget for post-completion home tab; Stop action with confirmation dialog; You tab "Tried" section already correct
**Implements:** Architecture Patterns 1 (post-step completion check, server-driven) and 4 (lifecycle sheet, stop branch only)
**Avoids:** Pitfall 2 (race condition — server owns completion authority), Pitfall 7 (stop must free slot immediately, fire-and-forget API sync), Pitfall 9 (celebration fires only on `!wasCompleted`), Pitfall 10 (distinct `_CompletedAllState` vs generic `_EmptyHomeState`)

### Phase 3: Detail Page Content Gating
**Rationale:** Zero data dependencies — purely conditional rendering on `isProProvider` which already works. Can run in parallel with Phase 2 after Phase 1 codegen is complete. No migration, no provider changes, no new server endpoints needed.
**Delivers:** `ProGateSection` widget (BackdropFilter blur + lock icon + coral CTA); Stages 2-4 roadmap gated in `HobbyDetailScreen`; FAQ/cost/budget sections gated with inline bottom-sheet upgrade prompt; Stage 1 and starter kit fully free; existing cached FAQ content remains accessible
**Implements:** Architecture Pattern 3 (content gating via `isProProvider`)
**Avoids:** Pitfall 4 (existing free access preserved — gate new generation, not cached content)

### Phase 4: Pause/Resume Lifecycle
**Rationale:** Depends on Phase 1 (enum variant) and reuses the lifecycle sheet scaffolding from Phase 2. Scheduled last because it has the most cross-cutting concerns: server webhook, streak calculation, coach context update, and RevenueCat cache handling. Building it last means Phase 2 and Phase 3 are already validated before touching the more complex pause machinery.
**Delivers:** `pauseHobby()` and `resumeHobby()` notifier methods with live RevenueCat entitlement check before writing `paused` status; Pause option in `HobbyLifecycleSheet` (alongside existing Stop); Home tab paused-state display (dim card with "Paused" badge in `activeEntries`); RevenueCat `EXPIRATION` webhook handler transitioning paused hobbies to `stopped` on lapse; `pausedDurationDays` accumulation on resume; streak calculation using effective gap; coach context updated to map `paused` → `RESCUE` mode with `pausedDays` in prompt
**Implements:** Architecture Patterns 2 (paused status as `HobbyStatus` variant) and 4 (lifecycle sheet, pause branch)
**Avoids:** Pitfall 3 (downgrade path built in same phase), Pitfall 5 (streak accounts for pause duration), Pitfall 6 (coach context updated), Pitfall 8 (live RevenueCat entitlement check before writing paused)

### Phase Ordering Rationale

- Phase 1 before everything: Freezed codegen must succeed before any file referencing `HobbyStatus.paused` can compile. This is a hard build dependency, not a soft preference. Exhaustive switch statements on `HobbyStatus` (in `canStartHobbyProvider`, `getByStatus()`) will produce compile errors until the `paused` case is handled.
- Phase 2 before Phase 4: Completion flow has 3× the user impact of pause (it is the core product moment) and no blocked dependencies after Phase 1. It also establishes the lifecycle sheet component that Phase 4 extends.
- Phase 3 in parallel with Phase 2: Content gating is pure conditional UI; starting it after Phase 1 codegen allows both Phase 2 and Phase 3 to complete in the same sprint window.
- Phase 4 last: Has the most pitfalls, the most external integration concerns (RevenueCat webhook), and the most cross-cutting changes. Doing it last means every other v1.1 feature is already shipped and tested.

### Research Flags

Phases with standard patterns (skip `/gsd:research-phase`):
- **Phase 1:** Schema migration pattern is well-documented; the Prisma split-migration workaround is explicit in three Prisma GitHub issues
- **Phase 2:** Riverpod state machine, imperative Navigator overlay, and home state branching are all standard Flutter patterns with full code samples in ARCHITECTURE.md
- **Phase 3:** Conditional rendering with an existing provider; `BackdropFilter` is Flutter built-in; no new patterns needed

Phases that may benefit from a targeted research spike before implementation:
- **Phase 4 (Pause/Resume):** The RevenueCat webhook integration for subscription lapse handling needs a 30-minute spike before coding. Specifically: the EXPIRATION event payload shape, how to identify the affected `userId` in the serverless function, and whether the Neon free-tier connection pool can handle the synchronous hobby status update in the webhook response window. Reference: `https://www.revenuecat.com/docs/integrations/webhooks`.

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | Derived entirely from direct codebase inspection; all packages verified in pubspec.yaml; zero new packages required |
| Features | MEDIUM-HIGH | Core requirements from PROJECT.md are definitive; competitive benchmarks (Duolingo, Headspace, Strava) from secondary sources; paywall pattern research from RevenueCat official docs (HIGH) and independent analysis (MEDIUM) |
| Architecture | HIGH | Based on direct file inspection of all relevant source files; code patterns verified against live codebase; call sites and method signatures confirmed with line references |
| Pitfalls | HIGH | Critical pitfalls backed by official Prisma GitHub issues, RevenueCat official docs, Apple App Store Review Guidelines, and direct codebase analysis |

**Overall confidence:** HIGH

### Gaps to Address

- **RevenueCat EXPIRATION webhook payload format:** Research confirms the webhook is needed and what it must do, but the exact event payload shape and how to identify the affected user in a serverless Vercel function needs explicit verification before Phase 4 starts. Do not assume the payload structure matches Stripe's — RevenueCat uses its own format. Reference: `https://www.revenuecat.com/docs/integrations/webhooks`.
- **Stop vs done status distinction in analytics:** Research recommends logging `hobby_abandoned` vs `hobby_completed` in `UserActivityLog`, but the current `ActivityLog` Prisma model needs verification that the `action` field accepts these values before Phase 2 coding starts. Confirm `action` field type and any enum constraints.
- **Detail page existing cached FAQ content scope:** Research identifies the App Store guideline risk but leaves open whether any free users in production have seen generated FAQ content. Before deploying Phase 3, query `GenerationLog` to check whether FAQ items have been generated for free-tier users. This determines whether "gate new generation only" is sufficient or whether a grandfather exclusion is needed.

## Sources

### Primary (HIGH confidence)
- Direct codebase inspection: `lib/models/hobby.dart`, `lib/providers/user_provider.dart`, `lib/providers/subscription_provider.dart`, `lib/screens/session/session_screen.dart`, `lib/screens/home/home_screen.dart`, `lib/screens/detail/hobby_detail_screen.dart`, `server/prisma/schema.prisma`, `server/api/users/[path].ts`, `server/lib/mappers.ts`, `pubspec.yaml`
- Prisma GitHub issues #8424, #5290, #7251 — enum migration transaction error (`55P04`) and documented workaround
- RevenueCat official docs: Customer Info / `getCustomerInfo()` caching behavior
- Apple App Store Review Guidelines §3.1.2(a) — subscription content restriction
- RevenueCat official docs: Freemium Playbook, Hard vs Soft Paywall

### Secondary (MEDIUM confidence)
- Duolingo official blog: streak milestone design, home screen redesign (2024)
- fline.dev: learnings from analyzing 20 mobile paywalls (independent research, 2025)
- Blinkist trial conversion case study — growth.design (23% conversion lift from honest preview gate)
- Strava auto-pause official support documentation (2025)
- Headspace free vs paid features — independent review (2025)
- RevenueCat / dev.to: top fitness app paywall UX patterns (2025)

### Tertiary (LOW confidence)
- RevenueCat Community forum: subscription expiry behavior when user is offline — behavior inferred, not guaranteed across all edge cases

---
*Research completed: 2026-03-23*
*Ready for roadmap: yes*
