# Pitfalls Research

**Domain:** Flutter mobile app — hobby lifecycle states (pause/stop/complete) and Pro content gating on an existing system
**Researched:** 2026-03-23
**Confidence:** HIGH (codebase directly inspected + official docs verified)
**Milestone:** TrySomething v1.1

---

## Critical Pitfalls

Mistakes that cause data loss, store rejection, or require a schema rewrite.

---

### Pitfall 1: Prisma Enum Migration Fails When New Value Is Also a Default in the Same Migration

**What goes wrong:**
Adding `paused` to the `HobbyStatus` enum AND using it as a default in the same generated migration throws:

```
ERROR: unsafe use of new value "paused" of enum type "HobbyStatus"
HINT: New enum values must be committed before they can be used.
```

PostgreSQL error `55P04` prevents the entire migration from applying. Prisma generates both the `ALTER TYPE HobbyStatus ADD VALUE 'paused'` and the `ALTER TABLE "UserHobby" ALTER COLUMN "status" SET DEFAULT 'paused'` in a single transaction — which PostgreSQL rejects because the new enum value has not been committed at the point the default is applied.

**Why it happens:**
The current schema (`server/prisma/schema.prisma` line 210-215) defines `HobbyStatus` as a PostgreSQL native enum. Adding `paused` and `stopped` triggers Prisma to emit a migration that runs both operations atomically. This is a long-standing, well-documented Prisma issue (GitHub #8424, #5290, #7251) that is still present in Prisma 6.4.1 (the version in use).

**Consequences:**
- Migration fails in production, leaving the schema unchanged
- If `prisma migrate deploy` was run on Neon, the migration is marked as applied in `_prisma_migrations` but the enum change did not actually execute — the table is now in an inconsistent state with the migration history
- Requires manual SQL repair in the Neon console

**How to avoid:**
Never add a new enum value and use it as a column default in the same migration file. Split into two sequential migrations:

Migration 1 — add the enum values only:
```sql
ALTER TYPE "HobbyStatus" ADD VALUE 'paused';
ALTER TYPE "HobbyStatus" ADD VALUE 'stopped';
```

Migration 2 — any schema changes that reference those new values.

Practical approach: add the values to the Prisma schema, run `prisma migrate dev --name add_hobby_status_paused_stopped`, then manually inspect the generated SQL. If the generated migration contains both `ADD VALUE` and any usage of the new value in the same file, split it manually before running.

**Warning signs:**
- Migration file contains both `ALTER TYPE ... ADD VALUE` and `ALTER TABLE ... DEFAULT 'paused'` in the same file
- Migration fails with `55P04` in CI or staging
- Running `npx prisma migrate status` shows a migration as "applied" even though the schema change is not visible in the database

**Phase to address:** Phase 1 — Lifecycle Schema Migration (the very first task)

---

### Pitfall 2: Auto-Completion Race Condition — Last Step Triggers Two `setDone` Calls

**What goes wrong:**
The completion detection logic lives in `toggleStep()` in `UserHobbiesNotifier` (user_provider.dart, line 267). When the user completes the final roadmap step, the step toggle must atomically: (1) mark the step done, (2) detect that all steps are now complete, (3) transition status to `done`. If the detection check runs against stale local state and the optimistic update fires before the API rollback resolves, two events can race:

- The user taps the final step
- `toggleStep` fires, adds step to `completedStepIds`, detects completion, calls `setDone`
- Simultaneously, the previous step's API call returns a 500, rolling back state
- `setDone` is now called on a `UserHobby` that rolled back — the hobby reverts to `trying` status but the celebration screen already showed

The user sees the celebration, then returns to the home screen which shows the hobby as still active. Tapping the step again fires another completion cycle.

**Why it happens:**
The current `toggleStep` implementation uses optimistic updates with independent rollback (user_provider.dart lines 290-306). Each step is rolled back individually on failure. But completion detection reads `completedStepIds` from the current state at the time of the toggle, not from the server's authoritative count. The local `Set<String>` in SharedPreferences may drift from `UserCompletedStep` rows in Neon PostgreSQL if a prior sync failed silently.

**Consequences:**
- Double-completion: hobby appears `done` then reverts to `trying` in the same session
- Analytics event `hobby_completed` fires twice
- Celebration screen shows, user feels good — then home screen shows the hobby still active, breaking trust
- In the worst case: `completedAt` is written to the database twice with different timestamps

**How to avoid:**
Do not perform completion detection in the Flutter client. The server endpoint that records a completed step (`POST /api/users/hobbies/:hobbyId/steps/:stepId/complete`) should check the total step count after recording. If `completedStepCount === totalStepCount`, the server sets `status = done` and `completedAt = now()` in the same database transaction and returns a flag in the response body:

```typescript
// Server response shape
{ stepCompleted: true, hobbyCompleted: true, completedAt: "2026-03-23T..." }
```

The Flutter client reads the `hobbyCompleted` flag from the response and triggers the celebration screen only then — not from local state inference.

**Warning signs:**
- Celebration screen shows briefly then disappears on return from navigation
- `HobbyStatus.done` hobbies appear in the Home tab alongside `trying` hobbies
- PostHog receives duplicate `hobby_completed` events for the same `hobbyId`

**Phase to address:** Phase 2 — Completion Flow. This must be a server-driven check, not a client-side count comparison.

---

### Pitfall 3: Pause Feature Locked Behind Pro — But Pro Lapse Strands the Hobby

**What goes wrong:**
A Pro user pauses a hobby. Their subscription lapses (trial ends, payment fails, or they cancel). The hobby is now in `paused` status. The client checks `isProProvider` on app start — the user is no longer Pro. The pause feature is locked. But the user's hobby is stuck in `paused` — it does not appear in the Home tab (which only shows `trying | active`) and cannot be resumed without Pro. The user effectively loses access to their in-progress hobby.

**Why it happens:**
The `canStartHobbyProvider` (user_provider.dart, line 334) checks `isProProvider` for the multi-hobby gate. A similar gate on the resume action would block non-Pro users from resuming a paused hobby. There is no migration path defined for what happens to a `paused` hobby when the user loses Pro status.

**Consequences:**
- Hobby with completed steps, journal entries, and a streak is inaccessible — data is preserved but the user cannot see it or interact with it
- User's only option is to contact support or subscribe again — neither is acceptable UX
- If the user starts a new hobby instead, they now have a `paused` orphan and a `trying` active hobby — violating the free-tier single-hobby constraint

**How to avoid:**
Define the downgrade path explicitly before implementing pause. Two acceptable approaches:

Option A (recommended): Non-Pro users can always resume a paused hobby. Pro gate applies only to *initiating* a pause. Once paused, resume is always free. This is the least surprising behavior for the user.

Option B: On Pro lapse, automatically transition all `paused` hobbies to `stopped` (moved to Tried with progress preserved). The webhook handler for `EXPIRATION` and `CANCELLATION` events must include this transition. Requires adding a webhook-side query: `prisma.userHobby.updateMany({ where: { userId, status: 'paused' }, data: { status: 'stopped' } })`.

Implement the downgrade behavior in the same phase as pause, not as an afterthought.

**Warning signs:**
- Home tab shows no active hobbies but You tab shows a paused hobby
- RevenueCat `EXPIRATION` webhook fires and no state transition happens to paused hobbies
- User reports "I can't find my hobby" after subscription renewal reminder

**Phase to address:** Phase 3 — Pause/Resume. The downgrade path must be part of the acceptance criteria for this phase, not deferred.

---

### Pitfall 4: Content Gating on Detail Page Breaks Existing Saved Users' Experience

**What goes wrong:**
The detail page (`hobby_detail_screen.dart`) currently shows the full FAQ, cost breakdown, and budget alternatives to all users. The plan is to gate FAQ/cost/budget behind Pro for new users. But users who saved a hobby before the gate was added have seen this content. After the update, those users see it locked — content they had access to is now behind a paywall.

Apple's App Store Review Guidelines §3.1.2(a) state: "If you are changing your existing app to a subscription-based business model, you should not take away the primary functionality existing users have already paid for." The language is about previously-paid users, but review teams apply a broader interpretation: content visible to free users before an update should not become paid-only without grandfathering. A reviewer who registered as a free user before the gating update and sees locked content that was previously visible is likely to flag this.

**Why it happens:**
The detail page currently has no tier check at all — `hobby_detail_screen.dart` renders all sections unconditionally. Adding a gate after launch means existing free users experience a content removal, not just a content restriction.

**Consequences:**
- App Store rejection or review flag citing guideline §3.1.2(a)
- Free users perceive the update negatively ("they took away features")
- PostHog will show a spike in `detail_page_exit` events and a drop in `hobby_started` conversions from the detail page after the update

**How to avoid:**
Gate only content that was never shown to free users in production. Currently, FAQ items are lazy-loaded (generated on first view). If the generation endpoint was only accessible to Pro users from the start, gating is clean. But if free users in production have already seen FAQ content for their saved hobbies, that content is in a morally gray zone.

The safest approach: gate FAQ/cost/budget generation for *new* hobbies from this release forward. Hobbies already in the database with generated FAQ content remain accessible to all users (the content is already there). The gate is: Pro users see a "Generate FAQ" button that calls the API; free users see a paywall prompt in the FAQ section.

For the detail page structure, this means:
- Stage 1 roadmap: free (already visible, keep it)
- Starter kit: free (already visible, keep it)
- FAQ section: free users see the paywall prompt; Pro users see the "Generate" button or cached FAQ
- Cost breakdown: same gate as FAQ
- Budget alternatives: same gate as FAQ

This approach adds new Pro value without removing existing free value.

**Warning signs:**
- The App Store review build uses a free test account that was created after launch and sees locked content that existing free users saw before
- Beta testers who were free users before the update report that sections "disappeared"
- Apple review notes mention content restriction that was previously available

**Phase to address:** Phase 4 — Detail Page Content Gating. The acceptance criteria must include: "A user who had access to this content before this update can still access it."

---

### Pitfall 5: Streak Counter Does Not Account for Pause Duration

**What goes wrong:**
`streakDays` in `UserHobby` (schema.prisma line 226, model hobby.dart line 148) counts consecutive days of activity. When a user pauses a hobby and resumes 14 days later, the streak calculation does not know about the pause — it sees a 14-day gap and resets the streak to zero.

Separately, if the streak is calculated from `lastActivityAt` on the client (using `DateTime.now().difference(lastActivityAt).inDays`), the streak appears to break in real-time as the hobby sits paused. The user sees their streak dying while they are legitimately paused.

**Why it happens:**
The current schema has no `pausedAt` or `pauseDurationDays` field. There is no mechanism to distinguish "I haven't done anything for 14 days" from "I paused for 14 days." The streak counter treats both identically.

**Consequences:**
- User pauses to go on holiday, returns to find their 20-day streak is zero
- This is a severe motivation killer — the entire point of pausing is to preserve progress
- The home screen "This week's plan" card, which displays streak information, shows misleading data during a pause

**How to avoid:**
Add two fields to `UserHobby` in the schema:

```prisma
pausedAt       DateTime?   // set when status transitions to paused
pauseResumedAt DateTime?   // set when status transitions back from paused
```

When calculating streaks, exclude days between `pausedAt` and `pauseResumedAt`. If multiple pause/resume cycles are needed, this requires a `PauseLog` join table or a cumulative `pausedDurationDays Int @default(0)` counter (simpler for this scale).

For v1.1, the simpler approach: add `pausedAt` and accumulate `pausedDurationDays` (incremented when resuming by `DateTime.now().difference(pausedAt).inDays`). The streak calculation becomes:

```
effectiveGap = totalGapDays - pausedDurationDays
if (effectiveGap <= 1) streak continues
```

The home screen must not show the streak decrementing during a paused state. Explicitly check `status === 'paused'` before rendering streak countdown logic.

**Warning signs:**
- Beta user reports that their streak reset after resuming a paused hobby
- Home screen shows "Streak: 0 days" for a recently resumed hobby that had a 15+ day streak
- `streakDays` in the database is 0 for a `UserHobby` with `status = paused` and 30 `UserCompletedStep` rows

**Phase to address:** Phase 3 — Pause/Resume. Schema must include pause duration tracking from day one of pause implementation.

---

## Moderate Pitfalls

Mistakes that cause user confusion, data inconsistency, or poor UX without requiring a rewrite.

---

### Pitfall 6: Coach Context Passes Stale Status After Lifecycle Transition

**What goes wrong:**
The coach system prompt (`buildCoachSystemPrompt()` in `server/api/generate/[action].ts`) includes `userState: BROWSING | SAVED | ACTIVE` and `coachMode: START | MOMENTUM | RESCUE`. After a hobby transitions to `paused` or `done`, the coach context is not updated — it still shows `ACTIVE` and `MOMENTUM` mode.

A user who paused a hobby and opens the coach asks "I've been away for a month, how do I get back into this?" — the coach responds as if they're mid-active, recommending the next roadmap step without acknowledging the pause.

**Why it happens:**
The coach context builder reads from `UserHobby.status` but only maps to the three defined states. There is no mapping for `paused` → a new coach mode, and there is no mapping for `done` → a congratulatory mode.

**How to avoid:**
Add status mappings to the coach context builder:
- `paused` → userState `PAUSED`, coachMode `RESCUE` (returning after a break is the same emotional context as rescue)
- `done` → userState `COMPLETED`, coachMode `CELEBRATE` (or a new mode)

Also add a `pausedDays` field to the coach context so the AI knows how long the user was away. This is the `lastActivityAt` gap, clamped to the pause window.

**Warning signs:**
- Coach says "great job with your momentum!" to a user who just resumed after 3 weeks away
- Coach recommends a step the user completed before pausing ("Try your first session") when they are clearly past Stage 1
- PostHog `coach_message_sent` events from `paused` status hobbies return responses that do not acknowledge the pause

**Phase to address:** Phase 3 — Pause/Resume. The coach context update is a one-line mapping change but must be part of the same PR as the status transition.

---

### Pitfall 7: Free User Stops a Hobby — Slot Does Not Free Up Immediately

**What goes wrong:**
A free user has one active hobby. They tap "Stop this hobby" and confirm. The hobby moves to `stopped` (Tried). The `canStartHobbyProvider` (user_provider.dart line 334) checks the live state — but if the UI navigates to Discover before the API call completes and the optimistic update is rolled back, the user's slot appears taken. The Discover feed "Start this hobby" button is disabled even though the user stopped their active hobby.

More subtly: if the API call to update status fails entirely, the local state rolls back to `trying`, the slot remains taken, and the user sees a "you already have an active hobby" block — even though they just explicitly stopped it.

**How to avoid:**
The stop action must be idempotent and must not roll back on network failure. Use a fire-and-forget pattern with local persistence: write `stopped` status to SharedPreferences immediately, do not roll back on API failure (just retry silently). The slot should free immediately on user intent. A background sync on next app start will reconcile any discrepancy.

**Warning signs:**
- "Start Hobby" button remains disabled after stopping an active hobby (network flake)
- You tab "Tried" section shows the stopped hobby, but Home tab still shows it as active
- User reports they can't start a new hobby after stopping their previous one

**Phase to address:** Phase 2 — Stop/Abandon Hobby. Test explicitly with airplane mode during the stop action.

---

### Pitfall 8: RevenueCat Subscription State Is Not Refreshed Before Showing Pause Gate

**What goes wrong:**
RevenueCat SDK caches entitlement status and updates the cache if it is older than 5 minutes. If a user's trial expired while they had the app open (or while the app was backgrounded), the cached `isPro = true` state has not been invalidated. The user sees the "Pause hobby" option, taps it, and the pause succeeds locally — but when the app restarts, the subscription check runs a fresh `getCustomerInfo()` call, Pro status is false, and the UI is in an inconsistent state (hobby is `paused` but user is free).

**Why it happens:**
`proStatusProvider` is initialized from `SubscriptionService.isPro` which reads the RevenueCat cache. The cache is at most 5 minutes stale — but for a trial that expired exactly at midnight while the user was asleep, the app might open with stale cached Pro status. The `refresh()` method is async and may not complete before the UI renders the pause option.

**How to avoid:**
Before rendering the pause action, call `proStatusProvider.refresh()` explicitly and await it. This is a one-time network call per session to RevenueCat. For the pause action specifically (since it has durable consequences), do not show the option based on cached state — verify with a fresh entitlement check first.

In `canPauseHobbyProvider` (a new provider to add alongside `canStartHobbyProvider`):
```dart
// Trigger a refresh before checking Pro status for gated actions
await ref.read(proStatusProvider.notifier).refresh();
return ref.read(isProProvider);
```

**Warning signs:**
- User reports they paused a hobby but it shows as "trying" on next app open
- RevenueCat dashboard shows the user's trial ended but the database shows `status = paused`
- Trial conversion funnel shows users pausing right at trial expiry (they see the option during grace cache window)

**Phase to address:** Phase 3 — Pause/Resume. Add a live entitlement check before writing a `paused` status transition.

---

### Pitfall 9: Completion Celebration Fires on Roadmap Step Uncomplete (Toggle)

**What goes wrong:**
`toggleStep` can un-complete a step (user mistakenly checks then unchecks). If the completion detection runs on every toggle (not just completions), a user who unchecks the final step and then rechecks it will see the celebration screen appear again on the re-check. This produces a jarring experience and emits a second `hobby_completed` analytics event.

The current `toggleStep` already has a `wasCompleted` flag (user_provider.dart line 271), but if auto-completion detection is added client-side, it would need to check `!wasCompleted` (only trigger on a check, not an uncheck) — which is easy to implement correctly but also easy to forget.

**How to avoid:**
If completion detection is done server-side (per Pitfall 2 recommendation), this is automatically handled — the server only sets `status = done` when the step count reaches the total, it does not un-set it when a step is unchecked. The client simply trusts the server response.

If there is any client-side completion check, add an explicit guard: only trigger completion detection when `wasCompleted == false` (step was just completed, not uncompleted).

**Warning signs:**
- Celebration screen shows when a user unchecks and rechecks the last step
- `hobby_completed` fires twice for the same session in PostHog
- `completedAt` in the database has a timestamp from the re-check, not the original completion

**Phase to address:** Phase 2 — Completion Flow.

---

### Pitfall 10: Home Screen Shows No State When All Active Hobbies Complete

**What goes wrong:**
`home_screen.dart` (line 112) renders `_EmptyHomeState()` when `activeEntries.isEmpty`. This covers the "no hobbies started" case. After v1.1, a user who completes their only hobby also produces `activeEntries.isEmpty` — the Home tab shows the same empty state as a brand-new user.

This is a UX failure: a user who just finished a 30-day hobby deserves a "You did it — what's next?" moment, not the same generic "Get started" prompt that new users see.

**Why it happens:**
The `activeEntries` filter (home_screen.dart lines 98-110) only includes `trying | active` statuses. `done` hobbies are correctly excluded. But there is no branch for "user has completed hobbies but no active ones" — it falls through to the generic empty state.

**How to avoid:**
Add a new branch in `home_screen.dart` build method:

```dart
final hasCompletedHobbies = userHobbies.values.any((h) => h.status == HobbyStatus.done);
if (activeEntries.isEmpty && hasCompletedHobbies) {
  return _CompletedAllState(); // celebration state with "Pick your next one" CTA
}
if (activeEntries.isEmpty) {
  return _EmptyHomeState(); // generic new user state
}
```

The `_CompletedAllState` widget is a distinct screen with different copy, imagery, and a Discover CTA.

**Warning signs:**
- QA tester completes a hobby and Home tab shows the new-user empty state
- "Get started" button on the empty state is shown to a user who has 30 completed step rows
- User navigates away from Home immediately after completing — no discovery prompt shown

**Phase to address:** Phase 2 — Completion Flow (specifically the "home completed state" requirement from PROJECT.md).

---

## Technical Debt Patterns

Shortcuts that seem reasonable but create long-term problems.

| Shortcut | Immediate Benefit | Long-term Cost | When Acceptable |
|----------|-------------------|----------------|-----------------|
| Client-side completion detection (counting local steps) | Avoids a server round-trip on step toggle | Race conditions, double-completion events, drift from server truth | Never — server must own completion authority |
| Single `stopped` value serves both "user quit" and "subscription lapsed" | Simpler schema | Cannot distinguish intentional quits from forced stops in analytics; cannot auto-restart on re-subscribe | Never — use a `stopReason` field or separate `lapsed` status |
| Paused hobbies resume with the same coach mode (no context reset) | Zero code change | Coach gives advice appropriate for active users to someone returning from a 3-week break | Never — coach context must acknowledge the return |
| Gating FAQ/cost behind Pro without server-side enforcement | Faster to build (just hide widgets) | Client-side gate can be bypassed; calling the generation endpoint directly still works for non-Pro users | Never — the API endpoint must check `subscriptionTier` before generating |
| Using SharedPreferences as the source of truth for `paused` status | Works offline | SharedPreferences can be cleared by the OS on low storage; a pause that only lives in SharedPreferences is lost on reinstall | Never — `paused` is a durable state, must be in the server DB |

---

## Integration Gotchas

Common mistakes when connecting to external services.

| Integration | Common Mistake | Correct Approach |
|-------------|----------------|------------------|
| RevenueCat — Pro gate on pause | Checking cached `isPro` before showing the pause option | Call `getCustomerInfo()` (forces cache refresh) before writing a `paused` status transition — stale cache causes inconsistent state |
| RevenueCat — subscription lapse | No handler for `EXPIRATION` webhook that transitions `paused` hobbies | `EXPIRATION` event handler must query `UserHobby.findMany({ where: { userId, status: 'paused' } })` and transition to `stopped` or `trying` per the defined downgrade policy |
| RevenueCat — offline check for content gate | Using cached `isPro` to decide whether to show Pro FAQ/cost sections | Always call `getCustomerInfo()` on detail page open for gated sections; 5-min cache is acceptable but cold-start cache can be 30+ days stale |
| Prisma — adding `paused` enum value | Running `prisma migrate dev` and deploying the generated migration directly | Inspect the generated SQL; if it contains both `ADD VALUE` and any usage of the new value in the same transaction, split into two migration files before deploying |
| Neon + Vercel — migration during traffic | Running `prisma migrate deploy` while serverless functions have live connections | Run migrations during low-traffic windows; Neon free tier limits connections and `ALTER TYPE` on a live table holds a lock |
| Anthropic coach — status context | Passing `status: 'paused'` to the prompt without defining what it means in the system prompt | Add explicit handling in the coach system prompt: "If userState is PAUSED, the user is returning from a deliberate break. Acknowledge the return warmly and ask how they feel about picking up where they left off." |

---

## Performance Traps

Patterns that work at small scale but fail as usage grows.

| Trap | Symptoms | Prevention | When It Breaks |
|------|----------|------------|----------------|
| Counting total roadmap steps in the Flutter client on every step toggle | Imperceptible at 1K users | Count steps server-side in the completion endpoint; cache `totalStepCount` in `UserHobby` or `Hobby` | At 10K users with many concurrent toggles, local counts diverge from server |
| Loading all `UserHobby` rows (all statuses) to determine active count for the free-tier gate | Works with 1-5 hobbies | Add a `status` index on `UserHobby`; filter server-side for active count | At 50+ hobbies per user (power users), map iteration in Dart becomes noticeable |
| Coach system prompt includes all completed steps in roadmap annotation | Fine with 8 steps | Cap at 20 steps or summarize completed stages as a block; don't enumerate every step | Hobby with 30+ steps pushes context beyond 4K tokens for Haiku; Claude Sonnet handles more but still adds latency |
| Server checks Pro status by calling RevenueCat REST API on every coach message | Works at 10 req/min | Cache `subscriptionTier` on the User model in Neon and update it via webhook; read from Neon, not RevenueCat API | RevenueCat API rate limits at ~150 req/min per app; coach is high-frequency |

---

## Security Mistakes

Domain-specific security issues beyond general web security.

| Mistake | Risk | Prevention |
|---------|------|------------|
| Content gate enforced only on the Flutter client (hiding FAQ widget) | Pro users can call `POST /api/generate/faq` directly via curl or Postman — client gate provides no protection | Enforce `subscriptionTier === 'pro'` check in the API endpoint handler, not just in Flutter |
| Stop/pause endpoints accessible without ownership check | User A can stop User B's hobby by knowing the hobbyId (UUIDs are not secret if leaked via analytics) | Every lifecycle mutation endpoint must verify `userHobby.userId === authenticatedUserId` before updating |
| `completedAt` timestamp set client-side | Client can claim a hobby was completed at any time in the past by sending a spoofed `completedAt` | Set `completedAt = new Date()` server-side in the completion endpoint; never accept it from the client |
| Pause as a vector for content generation abuse | Paused users cannot use the coach (no active hobby context) but the gate might not be enforced | Explicitly check that hobby status is `active` or `trying` before processing a coach message; return 403 for `paused` or `done` hobbies |

---

## UX Pitfalls

Common user experience mistakes in this domain.

| Pitfall | User Impact | Better Approach |
|---------|-------------|-----------------|
| Stop action is immediate with no confirmation | User taps "Stop" accidentally and loses their active hobby slot | Two-step confirmation: "Are you sure? Your progress will be saved in Tried." with a distinct "Stop hobby" destructive button — not the same coral CTA used for positive actions |
| Pause action doesn't explain what pausing does | User doesn't understand that Pro is required, progress is preserved, and they can resume | Before the Pro gate paywall, show one line of copy: "Pausing saves your streak and progress. You can resume whenever you're ready." |
| Completion celebration navigates automatically back to Home | User feels rushed — they want to sit with the achievement | Stay on the celebration screen until the user explicitly taps "Pick my next hobby" or "Done"; do not auto-navigate with a timer |
| Pro content gate (FAQ/cost) shows a blank space for free users | Users don't know why the section is empty — they think the content failed to load | Show a visible "Pro feature" card with a brief description and upgrade CTA where the section would be; never show a blank |
| Completed hobbies disappear from Home without explanation | User opens the app after finishing and sees the empty/new-user state — confused about where their hobby went | Add a one-time "You finished [Hobby]! Here's what's next" moment on first Home tab open after completion; then move to the discovery CTA |

---

## "Looks Done But Isn't" Checklist

Things that appear complete but are missing critical pieces.

- [ ] **Hobby completion:** Celebration screen shows — verify that `status = done` is also written to Neon and `completedAt` is set server-side, not just in Hive/SharedPreferences
- [ ] **Pause feature:** Pause button is hidden behind Pro gate — verify the API endpoint also rejects `status = paused` mutations from non-Pro users (client gate alone is insufficient)
- [ ] **Stop hobby:** Hobby moves to Tried list — verify the home tab slot frees immediately for free users AND the server reflects the change (not just local state)
- [ ] **Streak on resume:** Streak count is non-zero after resume — verify the `pausedDurationDays` was subtracted from the gap calculation, not just the raw `lastActivityAt` difference
- [ ] **Coach context:** Coach is accessible after resume — verify the system prompt contains the `PAUSED` → `RESCUE` mode mapping and the return duration is included
- [ ] **Content gate:** FAQ section shows paywall prompt to free users — verify that calling `POST /api/generate/faq` directly with a free user's JWT returns 403, not 200
- [ ] **Downgrade path:** Pro subscription lapses with a paused hobby — verify the EXPIRATION webhook transitions the hobby to a defined non-paused state (not left stranded in paused forever)
- [ ] **Migration safety:** `paused` enum value deployed to Neon — verify with `SELECT unnest(enum_range(NULL::"HobbyStatus"));` that the value exists before deploying any code that references it

---

## Recovery Strategies

When pitfalls occur despite prevention, how to recover.

| Pitfall | Recovery Cost | Recovery Steps |
|---------|---------------|----------------|
| Prisma migration partially applied (enum value added but not migration history) | HIGH | Manually run `ALTER TYPE "HobbyStatus" ADD VALUE IF NOT EXISTS 'paused'` in Neon console; mark the migration as applied manually in `_prisma_migrations`; re-run `prisma migrate deploy` |
| Double-completion: `hobby_completed` fires twice | MEDIUM | Add deduplication: check `status = done` before processing any completion request server-side; `IF status != 'done' THEN update` (conditional update prevents double-write) |
| Paused hobbies stranded when Pro lapses | HIGH | Write a one-time migration script: `UPDATE "UserHobby" SET status = 'stopped' WHERE status = 'paused' AND userId IN (SELECT id FROM "User" WHERE subscriptionTier = 'free')` — run manually in Neon |
| Streak incorrectly zeroed after resume | MEDIUM | Recalculate using `UserCompletedStep.completedAt` timestamps — the raw step data is still there; rebuild `streakDays` from step completion history |
| Content gate is client-only, free users calling API directly | LOW | Deploy server-side check immediately; no data damage, just unauthorized generations in `GenerationLog` which can be audited |

---

## Pitfall-to-Phase Mapping

How roadmap phases should address these pitfalls.

| Pitfall | Prevention Phase | Verification |
|---------|------------------|--------------|
| Prisma enum migration transaction error | Phase 1 — Lifecycle Schema | Inspect generated SQL before running migrate; test on staging Neon branch first |
| Auto-completion race condition | Phase 2 — Completion Flow | Server returns `hobbyCompleted` flag; integration test: complete last step twice rapidly, verify single `done` transition |
| Pro lapse strands paused hobby | Phase 3 — Pause/Resume | Implement and test the EXPIRATION webhook transition; verify with RevenueCat sandbox cancel event |
| Content gating removes existing free features | Phase 4 — Detail Page Gating | QA with a pre-existing free account; verify FAQ sections gate new generation, not existing cached content |
| Streak does not account for pause duration | Phase 3 — Pause/Resume | Add `pausedAt` + `pausedDurationDays` to schema; unit test streak calculation with 14-day pause |
| Coach context stale after lifecycle transition | Phase 3 — Pause/Resume | Verify coach prompt includes PAUSED state mapping; send a message from a paused hobby and inspect system prompt |
| Stop action does not free the hobby slot | Phase 2 — Stop/Abandon | Test with airplane mode during stop action; verify `canStartHobbyProvider` returns true after stop regardless of network |
| RevenueCat stale cache on pause gate | Phase 3 — Pause/Resume | Test with a trial account at the moment of expiry; verify live entitlement check before writing paused |
| Celebration fires on step uncomplete | Phase 2 — Completion Flow | Toggle the last step on and off three times; verify celebration fires exactly once |
| Home shows wrong empty state after completion | Phase 2 — Completion Flow | Complete all steps of a hobby and return to Home; verify `_CompletedAllState` renders, not `_EmptyHomeState` |

---

## Sources

- [Prisma GitHub #8424: Migration fails when adding enum value used as default](https://github.com/prisma/prisma/issues/8424) — HIGH confidence (official Prisma issue tracker, confirmed root cause)
- [Prisma GitHub #5290: ALTER TYPE enum migrations fail in PostgreSQL](https://github.com/prisma/prisma/issues/5290) — HIGH confidence (official Prisma issue tracker)
- [Prisma GitHub #7251: Can't add value to enum in Postgres Database](https://github.com/prisma/prisma/issues/7251) — HIGH confidence (official Prisma issue tracker)
- [RevenueCat Docs: Getting Subscription Status / Offline caching behavior](https://www.revenuecat.com/docs/customers/customer-info) — HIGH confidence (official RevenueCat documentation)
- [RevenueCat Community: Subscription expires when user is offline](https://community.revenuecat.com/sdks-51/subscription-expires-when-user-is-offline-5002) — MEDIUM confidence (official RevenueCat community forum)
- [Apple App Store Review Guidelines §3.1.2(a) — Subscription content restrictions](https://developer.apple.com/app-store/review/guidelines/) — HIGH confidence (official Apple documentation)
- [Riverpod GitHub #1215: Race conditions in event sequence processing](https://github.com/rrousselGit/riverpod/issues/1215) — MEDIUM confidence (official Riverpod issue tracker)
- [Neon Docs: Connect from Prisma — connection pooling for serverless](https://neon.com/docs/guides/prisma) — HIGH confidence (official Neon documentation)
- Direct codebase analysis: `server/prisma/schema.prisma`, `lib/providers/user_provider.dart`, `lib/providers/subscription_provider.dart`, `lib/screens/home/home_screen.dart`, `lib/screens/detail/hobby_detail_screen.dart` — HIGH confidence (live codebase, 2026-03-23)

---

*Pitfalls research for: TrySomething v1.1 — Hobby Lifecycle & Content Gating*
*Researched: 2026-03-23*
