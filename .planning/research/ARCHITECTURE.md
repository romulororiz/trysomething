# Architecture Research

**Domain:** Flutter hobby-lifecycle app with Riverpod state + Vercel serverless backend
**Researched:** 2026-03-23
**Confidence:** HIGH — based on direct codebase inspection, not inference

---

## System Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                         Flutter Client                               │
│                                                                      │
│  ┌──────────────┐  ┌──────────────┐  ┌────────────────────────────┐ │
│  │  HomeScreen  │  │  YouScreen   │  │    HobbyDetailScreen       │ │
│  │  (active     │  │  (Tried tab) │  │    (content gating goes    │ │
│  │   dashboard) │  │              │  │     here)                  │ │
│  └──────┬───────┘  └──────┬───────┘  └──────────────┬─────────────┘ │
│         │                 │                          │               │
│  ┌──────▼─────────────────▼──────────────────────────▼─────────────┐ │
│  │                    Riverpod Provider Layer                       │ │
│  │  userHobbiesProvider (UserHobbiesNotifier)                      │ │
│  │  • setDone()         — exists, never called                     │ │
│  │  • toggleStep()      — called from session_screen._exitSession() │ │
│  │  • isProProvider     — from proStatusProvider / RevenueCat       │ │
│  └──────────────────────────────┬───────────────────────────────────┘ │
│                                 │                                     │
│  ┌──────────────────────────────▼───────────────────────────────────┐ │
│  │                 UserProgressRepositoryApi                        │ │
│  │  updateStatus(hobbyId, HobbyStatus.done)  — wired, unused        │ │
│  │  toggleStep(hobbyId, stepId)              — wired and working    │ │
│  └──────────────────────────────┬───────────────────────────────────┘ │
└─────────────────────────────────┼───────────────────────────────────┘
                                  │ Dio / JWT
┌─────────────────────────────────▼───────────────────────────────────┐
│                      Vercel Serverless (Node/TS)                     │
│                                                                      │
│  POST /api/users/hobbies-detail?hobbyId=&stepId=   (toggleStep)     │
│  PUT  /api/users/hobbies-detail?hobbyId=           (updateStatus)   │
│                                                                      │
│  Prisma → Neon PostgreSQL                                            │
│  UserHobby { status: saved|trying|active|done }                     │
│  UserCompletedStep { userId, hobbyId, stepId }  @@unique            │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Component Responsibilities (Current State)

| Component | Current Responsibility | Gap for v1.1 |
|-----------|------------------------|--------------|
| `session_screen.dart` `_exitSession()` | Calls `toggleStep()` if `session.isComplete` | Does NOT check if all steps done — no auto-completion trigger |
| `UserHobbiesNotifier.setDone()` | Updates status to `done`, calls `updateStatus()` API | Exists but nothing calls it |
| `UserHobbiesNotifier.toggleStep()` | Marks step complete/incomplete locally + API | No post-toggle completion check |
| `HobbyDetailScreen` | Renders all content unconditionally | No Pro gate — FAQ, cost, budget visible to all |
| `HomeScreen` | Shows `trying` + `active` status hobbies | Shows completed-state hobbies as "active" — no done state branch |
| `YouScreen` | Renders `done` hobbies in "Tried" tab | Wired correctly — `done` status already maps here |
| `HobbyStatus` enum | `saved / trying / active / done` | No `paused` variant |
| `UserHobby` model | `completedStepIds: Set<String>`, `status`, `streakDays` | No `pausedAt`, no `progressSnapshot` fields |
| `isProProvider` | Reads RevenueCat status via `proStatusProvider` | Correct — can be used immediately for gating |

---

## Recommended Project Structure (new files only)

```
lib/
├── screens/
│   ├── home/
│   │   └── home_completed_state.dart        # NEW: "You finished — pick next" card
│   └── detail/
│       └── pro_gate_section.dart            # NEW: blur+lock wrapper for gated sections
├── components/
│   ├── hobby_lifecycle_sheet.dart           # NEW: pause/stop/abandon bottom sheet
│   └── hobby_completion_celebration.dart    # NEW: full-screen celebration overlay

server/
├── prisma/schema.prisma                     # MODIFY: add paused to HobbyStatus enum
└── api/users/[path].ts                      # MODIFY: handle paused status in PUT handler
```

Files modified but not new:

```
lib/
├── models/hobby.dart                        # MODIFY: add HobbyStatus.paused, pausedAt to UserHobby
├── providers/user_provider.dart             # MODIFY: add pauseHobby(), stopHobby(), completion check
├── screens/session/session_screen.dart      # MODIFY: _exitSession() adds completion detection
├── screens/home/home_screen.dart            # MODIFY: add done-state branch, lifecycle sheet entry
└── screens/detail/hobby_detail_screen.dart  # MODIFY: wrap gated sections in ProGateSection
```

---

## Architectural Patterns

### Pattern 1: Post-Step Completion Check (auto-complete trigger)

**What:** After every `toggleStep()` call in `_exitSession()`, check if all roadmap steps are now in `completedStepIds`. If yes, call `setDone()` automatically.
**When to use:** This is the primary missing integration — the chain connecting session completion to hobby lifecycle.
**Trade-offs:** Requires knowing `totalSteps` count at the call site. The session screen already has access to `hobbyByIdProvider(session.hobbyId)` so this is zero-cost to retrieve.

```dart
// session_screen.dart — _exitSession() modified
void _exitSession() {
  final session = ref.read(sessionProvider);
  if (session != null && session.isComplete) {
    ref.read(userHobbiesProvider.notifier)
        .toggleStep(session.hobbyId, session.stepId);

    // Check if all steps now complete
    final hobby = ref.read(hobbyByIdProvider(session.hobbyId)).valueOrNull;
    if (hobby != null) {
      final userHobby = ref.read(userHobbiesProvider)[session.hobbyId];
      final completedAfter = {
        ...(userHobby?.completedStepIds ?? {}),
        session.stepId,
      };
      final allComplete = hobby.roadmapSteps.every(
        (s) => completedAfter.contains(s.id),
      );
      if (allComplete) {
        ref.read(userHobbiesProvider.notifier).setDone(session.hobbyId);
        // Push celebration overlay before popping session
        _showCompletionCelebration(session.hobbyId);
        return; // celebration handles navigation
      }
    }
  }
  ref.read(sessionProvider.notifier).completeSession();
  if (mounted) Navigator.of(context).maybePop();
}
```

### Pattern 2: Paused Status as New HobbyStatus Variant

**What:** Add `paused` to the `HobbyStatus` enum in both Flutter and Prisma schema. Store a `pausedAt` timestamp in `UserHobby` (new nullable field). Resume restores to `trying`.
**When to use:** Pause is a Pro feature — gate the action in the lifecycle sheet with `isProProvider` before calling `pauseHobby()`.
**Trade-offs:** Adding an enum variant requires a Prisma migration (adds `paused` to the PostgreSQL enum) and Freezed codegen regeneration. `HomeScreen` filter (`trying || active`) must decide how to display paused hobbies — either include them with a dim/paused badge, or exclude them (shows `_EmptyHomeState` if no active hobbies remain).

```dart
// models/hobby.dart
enum HobbyStatus { saved, trying, active, paused, done }

// UserHobby Freezed class — add field
const factory UserHobby({
  // ...existing fields unchanged...
  DateTime? pausedAt,   // NEW
}) = _UserHobby;
```

```prisma
// schema.prisma
enum HobbyStatus {
  saved
  trying
  active
  paused    // NEW — Pro only
  done
}

model UserHobby {
  // ...existing fields...
  pausedAt  DateTime?   // NEW
}
```

### Pattern 3: Content Gating via isProProvider

**What:** Wrap gated sections in `HobbyDetailScreen` with a `ProGateSection` widget. Gate checks `isProProvider` synchronously — no new provider needed.
**When to use:** Applied at render time per-section. The detail page already uses staggered card animations; gated sections become blurred/locked variants of the same cards.
**Trade-offs:** Gating is client-side only. Server returns all data — this is intentional. Content is not secret; the paywall drives subscription value, not data protection. At this app's scale, server-side gating would add latency and complexity for no security benefit.

```dart
// screens/detail/pro_gate_section.dart
class ProGateSection extends ConsumerWidget {
  final Widget child;
  final String upsellLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPro = ref.watch(isProProvider);
    if (isPro) return child;

    return Stack(children: [
      ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: IgnorePointer(child: child),
      ),
      _ProLockOverlay(label: upsellLabel),  // coral CTA
    ]);
  }
}
```

Applied in detail screen:

```dart
// Gate HobbyQuickLinks (FAQ + cost — currently ungated at staggeredCard index 6)
_staggeredCard(6, ProGateSection(
  upsellLabel: 'Unlock FAQ & cost breakdown',
  child: HobbyQuickLinks(hobbyId: widget.hobbyId),
)),
```

For roadmap stages: `_buildWhatToExpect()` renders a `StageRoadmapCard` per stage. Show Stage 1 fully, wrap Stages 2-4 in a single `ProGateSection` below Stage 1 rather than gating per-stage.

### Pattern 4: Hobby Lifecycle Bottom Sheet

**What:** A `HobbyLifecycleSheet` bottom sheet exposed from the Home tab active hobby card. Offers Stop (free, moves to done/tried) and Pause (Pro-gated, preserves progress).
**When to use:** Replace the existing ad-hoc quit reasons flow. Entry point: a 3-dot icon button on the Home tab hobby card.
**Trade-offs:** Stop moves to `done` status — same as natural completion. Distinguish in `UserActivityLog` via action field (`hobby_abandoned` vs `hobby_completed`).

---

## Data Flow

### Hobby Completion Flow

```
Session screen — user finishes final step
    |
    v
_exitSession() calls toggleStep(hobbyId, stepId)
    |
    v
UserHobbiesNotifier.toggleStep() updates local completedStepIds Set + API fire-and-forget
    |
    v
_exitSession() computes completedAfter, checks against hobby.roadmapSteps.length
    |
    +-- Not all complete: pop session, return to Home normally
    |
    +-- All complete:
            |
            v
        UserHobbiesNotifier.setDone(hobbyId)
            API: PUT /users/hobbies-detail?hobbyId= {status: "done", completedAt: now}
            |
            v
        Push HobbyCompletionCelebration overlay (imperative Navigator, not GoRouter)
        Celebration auto-dismisses after 4s, then pops session + returns to Home
            |
            v
        HomeScreen rebuilds:
            activeEntries now empty (done excluded from trying|active filter)
            -> Renders HomeCompletedState: "You finished — pick your next one"
        YouScreen Tried tab: already correct, done maps here automatically
```

### Pause/Resume Flow

```
Home tab — user opens HobbyLifecycleSheet on active hobby
    |
    +-- Stop (free):
    |       stopHobby(hobbyId) -> setDone() + activityLog("hobby_abandoned")
    |       HomeScreen filters out, YouScreen Tried tab shows it
    |
    +-- Pause (Pro gate):
            isProProvider check -> not Pro: show ProUpgradeSheet
            isPro: pauseHobby(hobbyId)
                state: status=paused, pausedAt=now
                API: PUT {status: "paused", pausedAt: now}
            HomeScreen: decide display of paused (dim card vs exclude)
            Resume: resumeHobby(hobbyId)
                state: status=trying, pausedAt=null
                API: PUT {status: "trying"}
```

### Content Gating Flow

```
HobbyDetailScreen.build()
    |
    v
isProProvider read (synchronous, from RevenueCat in-memory cache)
    |
    +-- Free user:
    |       Stage 1 roadmap: fully visible
    |       Stages 2-4: wrapped in ProGateSection -> blurred + lock overlay
    |       HobbyQuickLinks (FAQ + cost): wrapped in ProGateSection -> blurred
    |       StarterKitCard: visible (table stakes, no gate)
    |       spec badges (cost/time/difficulty): visible
    |
    +-- Pro user:
            All sections: fully visible, no wrappers active
```

---

## Integration Points: New vs Modified

### Modified Files

| File | Type of Change |
|------|----------------|
| `lib/models/hobby.dart` | Add `HobbyStatus.paused` to enum; add `pausedAt DateTime?` to `UserHobby` Freezed class |
| `lib/models/hobby.freezed.dart` / `hobby.g.dart` | Regenerate via `dart run build_runner build` — do not hand-edit |
| `lib/providers/user_provider.dart` | Add `pauseHobby()`, `resumeHobby()`, `stopHobby()` methods to `UserHobbiesNotifier` |
| `lib/screens/session/session_screen.dart` | Modify `_exitSession()` to add post-step completion check and celebration trigger |
| `lib/screens/home/home_screen.dart` | Add done-state branch (HomeCompletedState), lifecycle sheet entry point on active cards |
| `lib/screens/detail/hobby_detail_screen.dart` | Wrap `HobbyQuickLinks` and Stages 2-4 roadmap in `ProGateSection` |
| `server/prisma/schema.prisma` | Add `paused` to `HobbyStatus` enum; add `pausedAt DateTime?` to `UserHobby` |
| `server/api/users/[path].ts` | Log `hobby_paused` / `hobby_abandoned` actions in `handleHobbyDetail` PUT |
| `server/lib/mappers.ts` | Include `pausedAt` in `mapUserHobby()` response |

### New Files

| File | Purpose |
|------|---------|
| `lib/screens/home/home_completed_state.dart` | "You finished — pick your next hobby" rendered when `activeEntries.isEmpty` and at least one `done` hobby exists |
| `lib/components/hobby_lifecycle_sheet.dart` | Bottom sheet: Stop (free) + Pause (Pro-gated) actions |
| `lib/components/hobby_completion_celebration.dart` | Full-screen celebration overlay on final step completion, auto-dismiss after 4s |
| `lib/screens/detail/pro_gate_section.dart` | Blur + lock + coral CTA overlay wrapping Pro-gated content |

---

## Suggested Build Order

### Phase 1: Schema and Model Extension (unblocks all downstream work)

1. Add `paused` to `HobbyStatus` enum in `server/prisma/schema.prisma`
2. Add `pausedAt DateTime?` to `UserHobby` model in schema
3. Run Prisma migration against Neon (`npx prisma migrate dev`)
4. Add `HobbyStatus.paused` to `lib/models/hobby.dart` enum
5. Add `pausedAt` field to `UserHobby` Freezed class in `lib/models/hobby.dart`
6. Run `dart run build_runner build --delete-conflicting-outputs`
7. Update `mapUserHobby()` in `server/lib/mappers.ts` to include `pausedAt`

Rationale: Freezed codegen breaks the build if enum values are out of sync. Everything downstream depends on these being correct before any UI work starts.

### Phase 2: Completion Detection (highest user value, lowest risk)

1. Modify `_exitSession()` in `session_screen.dart` — add all-steps-complete check after `toggleStep()`
2. Verify `setDone()` in `UserHobbiesNotifier` fires `completedAt` param correctly (it does — already wired)
3. Build `hobby_completion_celebration.dart` as an imperative Navigator overlay, auto-dismiss 4s
4. Wire celebration into `_exitSession()` — push celebration, celebration pops session on exit
5. Build `home_completed_state.dart` — widget for when `activeEntries.isEmpty && triedEntries.isNotEmpty`
6. Add done-state branch to `HomeScreen.build()` — check done hobbies count, render `HomeCompletedState`
7. Confirm `YouScreen` Tried tab already shows `done` hobbies — it does, no changes required

Rationale: This feature has the most direct user impact and touches only 3 existing files. The existing `setDone()` and `toggleStep()` machinery already works end-to-end.

### Phase 3: Content Gating (pure UI, zero data dependencies)

1. Build `pro_gate_section.dart` with blur filter, lock icon, and coral Pro CTA
2. In `HobbyDetailScreen._buildWhatToExpect()`, show Stage 1 fully and wrap remaining stages
3. Wrap `HobbyQuickLinks` call site at index 6 with `ProGateSection`
4. Test with `proStatusProvider.notifier.setDebugTier(DebugTier.free)` and `DebugTier.pro`
5. Verify `StarterKitCard` remains ungated

Rationale: No migration, no provider changes, no server changes. `isProProvider` already works. Can be done in parallel with Phase 2 once Phase 1 codegen is complete.

### Phase 4: Pause/Stop Lifecycle (depends on Phase 1 enum)

1. Add `pauseHobby()`, `resumeHobby()`, `stopHobby()` to `UserHobbiesNotifier`
2. Update `handleHobbyDetail` PUT in server to emit activity log for `hobby_paused`/`hobby_abandoned`
3. Build `hobby_lifecycle_sheet.dart` — Stop always visible, Pause behind `isProProvider` check
4. Wire sheet into `HomeScreen` active hobby card (3-dot button or swipe)
5. Decide `HomeScreen` paused display: recommended approach is to include paused hobbies in `activeEntries` with a dim `paused` badge — same as how `trying` and `active` are already combined

Rationale: Depends on Phase 1 for the `paused` enum variant. Lower user value than completion (pause/stop are edge cases vs the core completion flow). Schedule last.

---

## Anti-Patterns

### Anti-Pattern 1: Completion Check Inside toggleStep()

**What people do:** Put the all-steps-complete check inside `UserHobbiesNotifier.toggleStep()` by passing `totalSteps` as a parameter.
**Why it's wrong:** `toggleStep()` handles both completing and un-completing a step. Side-effecting into `setDone()` from inside `toggleStep()` creates confusing bidirectional behavior. It also couples the progress notifier to hobby content data.
**Do this instead:** Check completion at the call site (`_exitSession()`) after `toggleStep()` returns. The session screen already has access to `hobbyByIdProvider` for total step count at zero additional cost.

### Anti-Pattern 2: Server-Side Content Gating for FAQ and Cost

**What people do:** Add Pro checks to `/api/generate/faq` and `/api/generate/cost`, returning 403 for free users.
**Why it's wrong:** The content is not secret. Server-side gating adds a round trip, creates confusing API errors for the client to handle, and adds a support burden when entitlement sync lags. RevenueCat webhook can take minutes to propagate.
**Do this instead:** Gate client-side with `isProProvider`. Free users see the blurred section and a Pro CTA. The content loads when they subscribe and `proStatusProvider.refresh()` fires.

### Anti-Pattern 3: Separate isPaused Column Instead of Enum Variant

**What people do:** Add a `isPaused Boolean @default(false)` column to `UserHobby` instead of extending the status enum.
**Why it's wrong:** Creates redundant state — a hobby could have `status=active, isPaused=true`. Every consumer (HomeScreen, YouScreen, mappers, server handlers) currently keys off `status` exclusively. Two fields means every consumer must check both.
**Do this instead:** Add `paused` to the existing `HobbyStatus` enum and a `pausedAt` timestamp. One field, one source of truth.

### Anti-Pattern 4: Celebration as a GoRouter Route

**What people do:** Navigate to `/celebration/:hobbyId` as a named GoRouter route from `_exitSession()`.
**Why it's wrong:** The session screen uses a custom `PageRouteBuilder` (not GoRouter) and manages its own Navigator stack. Mixing GoRouter pushes mid-session creates navigation state mismatch — the back stack becomes unpredictable and the system back button behavior breaks.
**Do this instead:** Push the celebration as an imperative `Navigator.of(context).push()` overlay on top of the session. It auto-dismisses after 4s, then calls `_exitSession()` which pops the session. No GoRouter involvement.

---

## Scaling Considerations

| Scale | Architecture Adjustments |
|-------|--------------------------|
| 0-10k users | Current architecture is correct. Client-side gating is appropriate. Single serverless function handles all user paths. |
| 10k-100k users | Cache `completedStepCount` server-side in `UserHobby` table to avoid shipping full `completedStepIds` set on every sync. Step completion count check becomes O(1). |
| 100k+ users | Move gamification `checkChallengeProgress()` to a background job triggered by activity log rather than inline on `toggleStep`. Step completions currently block the response on challenge evaluation. |

---

## Sources

- Direct inspection: `lib/providers/user_provider.dart` (UserHobbiesNotifier, setDone, toggleStep)
- Direct inspection: `lib/screens/session/session_screen.dart` (_exitSession, TODO comments at lines 199-202)
- Direct inspection: `server/prisma/schema.prisma` (UserHobby model, HobbyStatus enum — no paused variant)
- Direct inspection: `server/api/users/[path].ts` (handleHobbyDetail — lines 324-410)
- Direct inspection: `lib/providers/subscription_provider.dart` (isProProvider, DebugTier override)
- Direct inspection: `lib/screens/detail/hobby_detail_screen.dart` (no isProProvider usage — zero gating today)
- Direct inspection: `lib/components/hobby_quick_links.dart` (routes to /faq and /cost, no Pro check)
- Direct inspection: `lib/screens/home/home_screen.dart` (activeEntries filter: trying|active only)
- Direct inspection: `lib/screens/you/you_screen.dart` (done status already maps to triedEntries correctly)

---
*Architecture research for: TrySomething v1.1 hobby lifecycle and content gating*
*Researched: 2026-03-23*
