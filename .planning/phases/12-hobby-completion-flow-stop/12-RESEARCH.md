# Phase 12: Hobby Completion Flow + Stop - Research

**Researched:** 2026-03-23
**Domain:** Flutter UI state management — hobby lifecycle transitions, celebration screens, optimistic updates
**Confidence:** HIGH

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

#### Celebration screen
- Full-screen overlay (takes over session screen, uses CinematicScaffold)
- No breathing ring animation — clean break, fresh celebration screen
- Content: mix of hobby-focused summary + stats (hobby name, total steps completed, days since started, sessions completed, warm message)
- Single CTA: "Discover your next hobby" (coral) linking to Discover tab
- No auto-exit timer — user must tap CTA

#### Home completed state
- Completed hobby card stays visible with animated completion icon (checkmark drawing in or circle filling)
- Card shows: hobby title, animated complete icon, steps completed, days active, achievements — gamification and reward feeling
- Below the card: prominent coral "Find your next hobby" CTA linking to Discover
- Persists until user starts a new hobby — no auto-dismiss or timeout

#### Stop/abandon UX
- Stop action lives in a 3-dot PopupMenuButton (⋮) on the active hobby card on Home
- Menu initially has one item: "Stop hobby" (Phase 14 adds "Pause hobby" to same menu)
- Tapping "Stop hobby" opens a bottom sheet via showAppSheet with warning text ("Your progress won't be saved"), hobby name, and destructive coral "Stop hobby" button — matches delete account pattern
- Transition is optimistic: hobby immediately moves to Tried locally, server call in background. If server fails, error snackbar but no revert

#### Tried tab display
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

### Deferred Ideas (OUT OF SCOPE)
- Restart hobby (re-activate a stopped/done hobby) — defer to v2
- Share completion on social media — potential future feature
- Completion badges/achievements system — could enhance gamification feel in future
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| COMP-01 | Hobby auto-transitions to `done` status when all roadmap steps are completed (server-side detection, returns `hobbyCompleted` flag) | Already implemented in Phase 11: `toggleStepCompletion()` in `server/api/users/[path].ts` sets `status = done` and returns `hobbyCompleted: true` in transaction. Client just needs to read it. |
| COMP-02 | Celebration screen displays when user completes the final step | `session_screen.dart` `_exitSession()` calls `toggleStep()` which reaches `UserProgressRepositoryApi.toggleStep()` — returns `UserHobby` but not `hobbyCompleted` flag. Need to surface flag up to session screen to branch celebration. |
| COMP-03 | Home shows completed state with "pick your next hobby" CTA linking to Discover when active hobby is done | Home already filters `status == trying || active` — done hobbies don't appear. Need a new branch: when `userHobbiesProvider` has a `done` hobby, show completed card above empty state. |
| COMP-04 | Completed hobbies appear in You tab "Tried" section with completion date | `_TriedHobbyCard` already renders `done` hobbies but shows no status distinction. Needs: checkmark icon, "Completed" label, `completedAt` date, step count. |
| LIFE-01 | User can stop/abandon an active hobby — moves to Tried with confirmation prompt, no progress preserved | `setDone()` already exists in `UserHobbiesNotifier`. Need: PopupMenuButton on home active card, `showAppSheet` confirmation, call `setDone()` optimistically (no revert on error, show snackbar). |
</phase_requirements>

---

## Summary

Phase 12 is almost entirely a Flutter UI phase. The server side is already complete from Phase 11: `toggleStepCompletion()` detects completion transactionally, sets `status = done`, and returns `hobbyCompleted: true`. The work here is surfacing that flag to the UI and implementing 4 screen changes.

The critical gap is that `UserHobbiesNotifier.toggleStep()` currently calls `_repo.toggleStep()` as fire-and-forget and does NOT read the `hobbyCompleted` flag from the API response. The `UserProgressRepositoryApi.toggleStep()` method returns a `UserHobby` but the server response also includes `hobbyCompleted` — this field is currently ignored. The session screen's `_exitSession()` must be modified to check whether the completed step was the final one, and if so, show the celebration screen before navigating away.

The stop flow uses all existing plumbing: `setDone()` in `UserHobbiesNotifier`, `showAppSheet()` for the confirmation sheet, and `showAppSnackbar()` for errors. The only new component needed is a `PopupMenuButton` on the home active hobby card. All optimistic-update patterns are already established and consistent across the codebase.

**Primary recommendation:** Implement in this order: (1) surface `hobbyCompleted` from API response through the repository and provider chain; (2) build `HobbyCompletionScreen`; (3) modify session exit to branch on `hobbyCompleted`; (4) update Home for completed state; (5) add stop menu to home card; (6) update Tried tab card UI.

---

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| flutter_animate | ^4.5.2 | Animated completion icon (checkmark draw-in), staggered fade-ups on celebration screen | Already in pubspec, used in `session_complete_phase.dart` for fadeIn sequences |
| flutter_riverpod | ^2.6.1 | State management for `userHobbiesProvider`, `sessionProvider` | Established pattern across entire app |
| go_router | ^14.8.1 | Navigate to Discover tab after celebration | Established routing pattern |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| cached_network_image | already in pubspec | Hobby image in celebration screen header | Consistent with home_screen and you_screen image loading |
| material_design_icons_flutter | already in pubspec | Checkmark/trophy icons for Tried tab cards | Consistent with existing icon usage throughout app |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| flutter_animate checkmark | Lottie animation file | Lottie is NOT in pubspec and adds a dependency; flutter_animate can draw a checkmark path with `CustomEffect` or use `shimmer`+`scale` sequence. Stick with flutter_animate. |
| flutter_animate checkmark | CustomPainter path animation | More control but significantly more code. flutter_animate covers the use case. |
| showAppSheet for stop confirmation | showAppConfirmDialog | `app_overlays.dart` has both. The context-specified pattern uses `showAppSheet` (matching delete account pattern), not `showAppConfirmDialog`. Use `showAppSheet`. |

**Installation:** No new packages needed.

---

## Architecture Patterns

### Recommended File Changes
```
lib/
├── screens/
│   ├── session/
│   │   ├── session_screen.dart          # Modify: _exitSession reads hobbyCompleted, branches to celebration
│   │   ├── session_complete_phase.dart  # Modify: add hobbyCompleted bool param to skip auto-exit and show celebration inline, OR...
│   │   └── hobby_completion_screen.dart # NEW: full-screen celebration (CinematicScaffold, no nav)
│   ├── home/
│   │   └── home_screen.dart             # Modify: completed state branch + PopupMenuButton
│   └── you/
│       └── you_screen.dart              # Modify: _TriedHobbyCard with status icon + step count
├── data/repositories/
│   └── user_progress_repository_api.dart # Modify: toggleStep returns hobbyCompleted flag
└── providers/
    └── user_provider.dart               # Modify: toggleStep returns hobbyCompleted; add stopHobby()
```

### Pattern 1: Surfacing `hobbyCompleted` through the stack

**What:** Server returns `{ ...mapUserHobby(result.hobby), hobbyCompleted: result.hobbyCompleted }`. Client currently ignores `hobbyCompleted`. Need to thread it up.

**Current flow (broken for completion):**
```
session_screen._exitSession()
  → userHobbiesProvider.notifier.toggleStep(hobbyId, stepId)   // fire-and-forget
  → _repo.toggleStep(hobbyId, stepId)                           // returns UserHobby, ignores hobbyCompleted
  → Navigator.maybePop()
```

**Fixed flow:**
```
session_screen._exitSession()
  → userHobbiesProvider.notifier.toggleStep(hobbyId, stepId)   // now returns Future<bool> hobbyCompleted
  → _repo.toggleStep(hobbyId, stepId)                           // parse response.data['hobbyCompleted']
  → if hobbyCompleted: push HobbyCompletionScreen
  → else: Navigator.maybePop()
```

**Key constraint:** `toggleStep()` in `UserHobbiesNotifier` is currently `void` (fire-and-forget). It must become `Future<bool>` to return the flag. The provider still does the optimistic local update immediately; the `hobbyCompleted` value comes from the async API response.

**Example — modified repository method:**
```dart
// Source: existing UserProgressRepositoryApi.toggleStep() pattern
@override
Future<(UserHobby, bool)> toggleStep(String hobbyId, String stepId) async {
  final response = await _dio.post(
    ApiConstants.userHobbyStep(hobbyId, stepId),
  );
  final data = response.data as Map<String, dynamic>;
  final hobbyCompleted = (data['hobbyCompleted'] as bool?) ?? false;
  return (UserHobby.fromJson(data), hobbyCompleted);
}
```

**Example — modified notifier method:**
```dart
// Returns whether this toggle completed the entire hobby
Future<bool> toggleStep(String hobbyId, String stepId) async {
  final existing = state[hobbyId] ?? UserHobby(hobbyId: hobbyId, status: HobbyStatus.trying);
  final steps = Set<String>.from(existing.completedStepIds);
  final wasCompleted = steps.contains(stepId);
  if (wasCompleted) {
    steps.remove(stepId);
  } else {
    steps.add(stepId);
    if (existing.completedStepIds.isEmpty) {
      _analytics.trackEvent('first_session_completed', {'hobby_id': hobbyId, 'step_id': stepId});
    }
  }
  state = {...state, hobbyId: existing.copyWith(completedStepIds: steps)};
  _save();
  try {
    final (updatedHobby, hobbyCompleted) = await _repo.toggleStep(hobbyId, stepId);
    // Sync server state (handles done status update server set)
    state = {...state, hobbyId: updatedHobby};
    _save();
    return hobbyCompleted;
  } catch (e) {
    debugPrint('[UserHobbies] toggleStep failed, reverting step $stepId: $e');
    // revert only this step
    final current = state[hobbyId];
    if (current != null) {
      final revertedSteps = Set<String>.from(current.completedStepIds);
      if (wasCompleted) revertedSteps.add(stepId); else revertedSteps.remove(stepId);
      state = {...state, hobbyId: current.copyWith(completedStepIds: revertedSteps)};
      _save();
    }
    return false;
  }
}
```

**IMPORTANT:** Abstract interface `UserProgressRepository.toggleStep()` must also be updated to return `Future<(UserHobby, bool)>`. The mock in tests must be updated too.

### Pattern 2: Celebration Screen as a Push Route

**What:** `HobbyCompletionScreen` is a full-screen push (no shell nav) that replaces the session screen.

**When to use:** Called from `session_screen._exitSession()` when `hobbyCompleted == true`.

**Routing approach:** Use `Navigator.of(context).pushReplacement(...)` with a custom page route (FadeTransition, same pattern as `SessionScreen.route()`). This replaces the session screen in the navigator stack so back-navigation doesn't go back to session.

```dart
// In session_screen.dart _exitSession():
final hobbyCompleted = await ref
    .read(userHobbiesProvider.notifier)
    .toggleStep(session.hobbyId, session.stepId);

ref.read(sessionProvider.notifier).completeSession();

if (mounted) {
  if (hobbyCompleted) {
    Navigator.of(context).pushReplacement(
      HobbyCompletionScreen.route(
        hobbyId: session.hobbyId,
        hobbyTitle: session.hobbyTitle,
      ),
    );
  } else {
    Navigator.of(context).maybePop();
  }
}
```

**Celebration screen structure (CinematicScaffold, no app bar, no nav):**
```dart
class HobbyCompletionScreen extends ConsumerWidget {
  final String hobbyId;
  final String hobbyTitle;

  static Route<void> route({required String hobbyId, required String hobbyTitle}) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 600),
      pageBuilder: (_, __, ___) => HobbyCompletionScreen(hobbyId: hobbyId, hobbyTitle: hobbyTitle),
      transitionsBuilder: (_, animation, __, child) =>
          FadeTransition(opacity: animation, child: child),
    );
  }
  // ...
}
```

### Pattern 3: Home Completed State Branch

**What:** When `userHobbiesProvider` has a `done` hobby and no `trying`/`active` hobbies, Home currently falls through to `_EmptyHomeState`. Need a new `_CompletedHomeState` branch.

**Current Home filter (home_screen.dart line 98-101):**
```dart
final activeEntries = userHobbies.entries
    .where((e) =>
        e.value.status == HobbyStatus.trying ||
        e.value.status == HobbyStatus.active)
    .toList()
```

**New branch — add before `if (activeEntries.isEmpty)` check:**
```dart
final doneEntries = userHobbies.entries
    .where((e) => e.value.status == HobbyStatus.done)
    .toList();

if (activeEntries.isEmpty && doneEntries.isNotEmpty) {
  // Show completed state for most recently completed hobby
  final mostRecent = doneEntries
      .reduce((a, b) => (a.value.completedAt ?? DateTime(0))
          .isAfter(b.value.completedAt ?? DateTime(0)) ? a : b);
  return _CompletedHomeState(
    hobbyId: mostRecent.key,
    userHobby: mostRecent.value,
  );
}
```

### Pattern 4: Stop Hobby via PopupMenuButton

**What:** 3-dot menu in top-right of active hobby card on Home, with "Stop hobby" item.

**Placement:** In `_HobbyPageContent.build()` — add a `Positioned` widget at top-right of the hero Stack, alongside the existing streak badge.

**PopupMenuButton pattern (no existing instance — new pattern for this codebase):**
```dart
// Source: Flutter Material docs / project patterns
PopupMenuButton<String>(
  icon: Icon(Icons.more_vert_rounded, color: AppColors.textMuted, size: 18),
  color: AppColors.surface,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
    side: const BorderSide(color: AppColors.glassBorder, width: 0.5),
  ),
  itemBuilder: (ctx) => [
    PopupMenuItem(
      value: 'stop',
      child: Row(
        children: [
          const Icon(Icons.stop_circle_outlined, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Text('Stop hobby', style: AppTypography.body.copyWith(
            color: AppColors.textSecondary, fontSize: 14)),
        ],
      ),
    ),
    // Phase 14 adds: PopupMenuItem(value: 'pause', ...)
  ],
  onSelected: (value) {
    if (value == 'stop') _showStopConfirmation(context);
  },
)
```

**Stop confirmation sheet (matches existing `_showUncompleteConfirmation` pattern):**
```dart
void _showStopConfirmation(BuildContext context) {
  showAppSheet(
    context: context,
    title: 'Stop ${hobby.title}?',
    builder: (ctx) => Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Your progress won\'t be saved. ${hobby.title} will move to your Tried tab.',
            style: AppTypography.body.copyWith(color: AppColors.textMuted, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                ref.read(userHobbiesProvider.notifier).stopHobby(hobby.id);
                // No revert on server failure — show snackbar only
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.coral,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Text('Stop hobby', style: AppTypography.button.copyWith(color: Colors.white)),
            ),
          ),
        ],
      ),
    ),
  );
}
```

**New `stopHobby()` on `UserHobbiesNotifier` (distinct from `setDone()` to preserve semantics):**
```dart
void stopHobby(String hobbyId) {
  // Optimistic: immediate local update, no revert on error (per CONTEXT.md decision)
  final existing = state[hobbyId];
  if (existing == null) return;
  state = {
    ...state,
    hobbyId: existing.copyWith(status: HobbyStatus.done),
  };
  _save();
  _analytics.trackEvent('hobby_stopped', {'hobby_id': hobbyId});
  _repo.updateStatus(hobbyId, HobbyStatus.done).catchError((e) {
    debugPrint('[UserHobbies] stopHobby API failed (no revert): $e');
    // Show snackbar via callback or global key — caller handles UI feedback
  });
}
```

**Note on error feedback for stop:** Since `stopHobby()` is a void notifier method (can't pass BuildContext into notifier), the caller in `_showStopConfirmation` should wrap the `stopHobby()` call and schedule a snackbar via a separate error listener, or use a `ref.listen` on a dedicated error state. Simpler approach: catch in the notifier, store an error message in a `StateProvider<String?>`, and show from Home with `ref.listen`.

### Pattern 5: Updated Tried Tab Card

**What:** `_TriedHobbyCard` needs status icon, label, `completedAt` date, and step progress.

**Key data available in `UserHobby`:**
- `completedAt` — DateTime? (set when status = done via completion flow or stop)
- `completedStepIds` — Set<String>
- `status` — HobbyStatus.done (both completed and stopped show as `done`)

**Distinguishing completed vs stopped:** The current `UserHobby` model has no `stoppedAt` or separate stopped status. Both completion and stop use `HobbyStatus.done`. To distinguish visually, options are:
1. Add a `stoppedAt DateTime?` field to `UserHobby` — cleanest but requires model change + migration
2. Infer: if `completedStepIds.length == totalSteps`, it's completed; otherwise stopped
3. Add a boolean `wasCompleted` to `UserHobby`

**Recommendation (Claude's discretion area):** Infer from step completion percentage. If the `Hobby` data is available (it is in `_HobbyWithMeta`), compare `completedStepIds.length` vs `hobby.roadmapSteps.length`. This requires no model or schema change — use it.

```dart
// In _TriedHobbyCard, given _HobbyWithMeta:
final totalSteps = meta.hobby.roadmapSteps.length;
final completedSteps = meta.userHobby.completedStepIds.length;
final isFullyCompleted = totalSteps > 0 && completedSteps >= totalSteps;

// Display:
// isFullyCompleted → Icons.check_circle_rounded (success green) + "Completed"
// else → Icons.stop_circle_outlined (textMuted) + "Stopped"
```

### Anti-Patterns to Avoid

- **Don't call `setDone()` for stop** — `setDone()` is already used by the server-driven completion flow (called when `hobbyCompleted` is read). Create a separate `stopHobby()` method so analytics and semantics are clear.
- **Don't auto-dismiss the celebration screen** — locked decision: no auto-exit timer. The existing `SessionCompletePhase` has a 3-second timer — do NOT copy this pattern to `HobbyCompletionScreen`.
- **Don't revert the stop action** — locked decision: optimistic stop with no revert. The `_apiCall()` helper in `UserHobbiesNotifier` DOES revert on failure — do NOT use it for `stopHobby()`.
- **Don't try to pass `hobbyCompleted` through `SessionState`** — the server flag comes from the API response, not session state. Thread it through the repository return value.
- **Don't filter `done` hobbies out of Home entirely** — until user starts a new hobby, the completed card should persist on Home. Only filter when `activeEntries.isNotEmpty`.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Bottom sheet confirmation | Custom modal widget | `showAppSheet()` from `app_overlays.dart` | Already has glass bg, drag handle, backdrop blur, haptic, safe area |
| Error snackbar | Custom SnackBar widget | `showAppSnackbar()` from `app_overlays.dart` with `AppSnackbarType.error` | Consistent style, floating, dismissible, already used codebase-wide |
| Animated checkmark | Custom AnimationController | `flutter_animate` `.animate().scale().fadeIn()` chain | Already in pubspec, used in session_complete_phase.dart |
| Route transition | Navigator.push with default transition | `PageRouteBuilder` with FadeTransition | Matches `SessionScreen.route()` pattern for cinematic feel |

**Key insight:** The entire overlay/notification layer is already built. This phase is purely about connecting existing components in the right order.

---

## Common Pitfalls

### Pitfall 1: Breaking the existing `toggleStep` callers
**What goes wrong:** `toggleStep()` is called from 2 places in `home_screen.dart` (lines 939, 1084) and from `session_screen.dart` (line 246). Changing it from `void` to `Future<bool>` will break all callers.
**Why it happens:** The notifier method is used for both session completion AND manual roadmap step toggling from Home.
**How to avoid:** Update all call sites. Home screen callers don't need the return value — they can `await` and ignore, or use `.then((_) {})`. Only `session_screen._exitSession()` needs the return value.
**Warning signs:** Dart analyzer will flag `void` being awaited or returned value ignored.

### Pitfall 2: `UserProgressRepository` interface signature mismatch
**What goes wrong:** The abstract interface declares `Future<UserHobby> toggleStep(...)`, but the API impl now returns `Future<(UserHobby, bool)>`. The mock in tests also returns `UserHobby`.
**Why it happens:** Interface, implementation, and mock must all be updated together.
**How to avoid:** Update all 3 files in the same task wave: `user_progress_repository.dart`, `user_progress_repository_api.dart`, and the mock in `user_hobbies_notifier_test.dart`.
**Warning signs:** Dart compile error on mismatched return types.

### Pitfall 3: Home active-entries filter misses `done` state for completed card
**What goes wrong:** After hobby completion, `done` hobby is not in `activeEntries`, so Home shows `_EmptyHomeState` with "explore hobbies" prompt instead of the completed card.
**Why it happens:** Current filter explicitly excludes `done` from `activeEntries`.
**How to avoid:** Add explicit `doneEntries` check before the `activeEntries.isEmpty` empty state branch.
**Warning signs:** After completing a hobby, Home immediately shows empty state.

### Pitfall 4: `HobbyCompletionScreen` loses context after `pushReplacement`
**What goes wrong:** If `session_screen` calls `Navigator.of(context).pushReplacement(...)` after an async `await`, and the widget has been unmounted (e.g., user popped the route), the `mounted` check is skipped or the context is stale.
**Why it happens:** Async gap between `await toggleStep()` and subsequent navigation.
**How to avoid:** Always check `if (mounted)` before calling `Navigator.of(context)` after any `await`. This pattern already exists in `session_screen._exitSession()`.
**Warning signs:** `Looking up a deactivated widget's ancestor is unsafe` error in logs.

### Pitfall 5: Stop hobby snackbar context issue
**What goes wrong:** `stopHobby()` on the notifier can't show a snackbar (no BuildContext in notifier), but the caller's BuildContext may be stale by the time the async API call fails (seconds later).
**Why it happens:** Async error happens after user has already left the bottom sheet.
**How to avoid:** Store error state in a `StateProvider<String?>` on the notifier, listen from Home with `ref.listen`, show snackbar reactively. Alternatively, store the error in `UserHobbiesNotifier` state and expose it as a side-channel.
**Warning signs:** Error is logged to console but user sees nothing, OR crash on stale context.

### Pitfall 6: Tried tab step count without hobby data
**What goes wrong:** `_TriedHobbyCard` receives a `_HobbyWithMeta` that has both `UserHobby` and `Hobby` — but `Hobby.roadmapSteps` may be empty if hobby was loaded from seed data that doesn't include steps at the summary level.
**Why it happens:** `hobbyListProvider` returns summary-level `Hobby` objects; `roadmapSteps` may be empty list vs. populated.
**How to avoid:** Guard with `if (hobby.roadmapSteps.isNotEmpty)` before showing step count. Fallback: show only date if steps unavailable.
**Warning signs:** "0/0 steps" displayed on cards.

---

## Code Examples

### Existing `showAppSheet` confirmation pattern (from `home_screen.dart`)
```dart
// Source: C:/dev/trysomething/lib/screens/home/home_screen.dart:888
void _showUncompleteConfirmation(BuildContext context, RoadmapStep step) {
  showAppSheet(
    context: context,
    title: 'Mark as incomplete?',
    builder: (ctx) => Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'This will remove your progress for this step. Are you sure?',
            style: AppTypography.body.copyWith(
              color: AppColors.textMuted, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 24),
          Row(children: [/* Cancel button */ /* Destructive confirm button */]),
        ],
      ),
    ),
  );
}
```

### Existing `flutter_animate` staggered fade-in pattern (from `session_complete_phase.dart`)
```dart
// Source: C:/dev/trysomething/lib/screens/session/session_complete_phase.dart:56
Text('STEP COMPLETE', style: AppTypography.overline)
    .animate().fadeIn(duration: 300.ms, delay: 500.ms),

// Scale + fade combination for icons:
const Icon(Icons.check_circle_outline_rounded, color: AppColors.success, size: 22)
    .animate()
    .scale(begin: const Offset(0.5, 0.5), duration: 400.ms, curve: Curves.elasticOut)
    .fadeIn(duration: 200.ms),
```

### Existing optimistic update pattern (from `UserHobbiesNotifier.saveHobby`)
```dart
// Source: C:/dev/trysomething/lib/providers/user_provider.dart:177
void saveHobby(String hobbyId) {
  if (state.containsKey(hobbyId)) return;
  final snapshot = Map<String, UserHobby>.from(state);
  state = {...state, hobbyId: UserHobby(hobbyId: hobbyId, status: HobbyStatus.saved)};
  _save();
  _analytics.trackEvent('hobby_saved', {'hobby_id': hobbyId});
  _apiCall(snapshot, () async => _repo.saveHobby(hobbyId)); // rollback on error
}
// NOTE: stopHobby should NOT use _apiCall (no rollback per CONTEXT.md decision)
```

### Existing `setDone()` method (reference — DO NOT use for stop flow)
```dart
// Source: C:/dev/trysomething/lib/providers/user_provider.dart:254
void setDone(String hobbyId) {
  final existing = state[hobbyId];
  if (existing == null) return;
  final snapshot = Map<String, UserHobby>.from(state);
  state = {...state, hobbyId: existing.copyWith(status: HobbyStatus.done)};
  _save();
  _apiCall(snapshot, () async =>
    _repo.updateStatus(hobbyId, HobbyStatus.done, completedAt: DateTime.now()));
}
// setDone() does rollback — stopHobby() must NOT rollback per design decision.
// Keep setDone() for server-driven completion; add stopHobby() for user-driven stop.
```

### UserHobby model — available fields for celebration screen stats
```dart
// Source: C:/dev/trysomething/lib/models/hobby.dart:139
class UserHobby {
  final String hobbyId;
  final HobbyStatus status;
  final Set<String> completedStepIds; // count = steps completed
  final DateTime? startedAt;          // for "X days active" calculation
  final DateTime? lastActivityAt;
  final DateTime? completedAt;        // set by server on completion
  final int streakDays;
  // completedStepIds.length = total steps completed (celebration stat)
  // DateTime.now().difference(startedAt!).inDays = days active (celebration stat)
}
```

---

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Client-side completion detection (count steps locally) | Server-side: `hobbyCompleted` flag from `toggleStepCompletion()` transaction | Phase 11 | Client never infers completion — only trusts server flag |
| `HobbyStatus` with 4 values (saved/trying/active/done) | 5 values: saved/trying/active/paused/done | Phase 11 | Paused status now exists in enum even though UI doesn't use it yet |
| `toggleStep` as void fire-and-forget | Must become async returning `hobbyCompleted` | Phase 12 (this phase) | Breaking change to repository interface and notifier signature |

---

## Open Questions

1. **`stopHobby()` error snackbar delivery**
   - What we know: Notifier can't hold BuildContext; async error from `_repo.updateStatus()` fires after user leaves the bottom sheet
   - What's unclear: Best pattern — dedicated error StateProvider vs. ignore silently vs. ref.listen in Home
   - Recommendation: Add `stopError` as `StateProvider<String?>` exposed from `userHobbiesProvider` context. Home listens with `ref.listen` and calls `showAppSnackbar`. This is idiomatic Riverpod for side-effect communication.

2. **Stats for celebration screen: session count**
   - What we know: `completedStepIds.length` gives steps done; `startedAt` gives days active; `streakDays` gives streak
   - What's unclear: "Sessions completed" isn't directly tracked — each step completion is one session, so `completedStepIds.length` doubles as session count
   - Recommendation: Use `completedStepIds.length` for "sessions", consistent with step count. No separate session counter needed.

3. **Detail page read-only mode for Tried hobbies**
   - What we know: CONTEXT.md says hide/disable/replace the "Start Hobby" CTA when `status == done`
   - What's unclear: Exact implementation (hide vs replace with label) — this is Claude's discretion
   - Recommendation: Replace "Start Hobby" button with a muted "Completed" or "Tried" chip (no action, no CTA coral). This is cleaner than hiding (avoids layout shift) and more informative than disabling.

---

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | flutter_test (Flutter SDK built-in) + vitest 3.0.0 (server) |
| Config file | `pubspec.yaml` (Flutter) / `server/package.json` (server) |
| Quick run command | `dart test test/unit/providers/user_hobbies_notifier_test.dart` |
| Full suite command | `flutter test && cd server && npm test` |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| COMP-01 | Server sets `done` + returns `hobbyCompleted: true` on last step | unit (server) | `cd server && npx vitest run test/step_completion.test.ts` | ✅ step_completion.test.ts (3 tests already) |
| COMP-02 | `UserProgressRepositoryApi.toggleStep()` parses `hobbyCompleted` from response | unit (dart) | `dart test test/unit/repositories/user_progress_repository_api_test.dart` | ✅ exists (needs new test case) |
| COMP-02 | `UserHobbiesNotifier.toggleStep()` returns `true` when hobby is completed | unit (dart) | `dart test test/unit/providers/user_hobbies_notifier_test.dart` | ✅ exists (needs new test case) |
| COMP-02 | Celebration screen renders with hobby title and stats | widget | `flutter test test/widget/` | ❌ Wave 0 — new file needed |
| COMP-03 | Home shows completed state when done hobby exists and no active hobbies | widget | `flutter test test/widget/home_completed_state_test.dart` | ❌ Wave 0 |
| COMP-04 | Tried tab card shows Completed label for fully-done hobby | widget | `flutter test test/widget/tried_card_test.dart` | ❌ Wave 0 |
| COMP-04 | Tried tab card shows Stopped label for partially-done hobby | widget | `flutter test test/widget/tried_card_test.dart` | ❌ Wave 0 |
| LIFE-01 | `UserHobbiesNotifier.stopHobby()` sets status to done without rollback | unit (dart) | `dart test test/unit/providers/user_hobbies_notifier_test.dart` | ✅ exists (needs new test case) |
| LIFE-01 | Stop hobby does NOT revert on API failure | unit (dart) | `dart test test/unit/providers/user_hobbies_notifier_test.dart` | ✅ exists (needs new test case) |

### Sampling Rate
- **Per task commit:** `dart test test/unit/providers/user_hobbies_notifier_test.dart && cd server && npx vitest run test/step_completion.test.ts`
- **Per wave merge:** `flutter analyze && flutter test`
- **Phase gate:** Full suite green before `/gsd:verify-work`

### Wave 0 Gaps
- [ ] `test/widget/home_completed_state_test.dart` — covers COMP-03 (completed home state widget)
- [ ] `test/widget/tried_card_test.dart` — covers COMP-04 (completed vs stopped card distinction)
- [ ] `test/widget/hobby_completion_screen_test.dart` — covers COMP-02 celebration screen rendering
- [ ] Update `test/unit/providers/user_hobbies_notifier_test.dart` — add `stopHobby`, `toggleStep returns hobbyCompleted` cases
- [ ] Update `test/unit/repositories/user_progress_repository_api_test.dart` — add `hobbyCompleted` parse case (note: file's own comment says it tests model serialization, not API calls — may be a model-level test only)

---

## Sources

### Primary (HIGH confidence)
- Direct codebase inspection: `server/api/users/[path].ts` (lines 40-82) — `toggleStepCompletion` implementation confirmed
- Direct codebase inspection: `lib/providers/user_provider.dart` (lines 254-265, 267-307) — `setDone()` and `toggleStep()` implementations
- Direct codebase inspection: `lib/components/app_overlays.dart` — `showAppSheet`, `showAppSnackbar` API surface
- Direct codebase inspection: `lib/screens/session/session_screen.dart` — `_exitSession()` flow and async pattern
- Direct codebase inspection: `lib/screens/you/you_screen.dart` (line 1408-1461) — existing `_TriedHobbyCard` implementation
- Direct codebase inspection: `lib/screens/home/home_screen.dart` (lines 98-116) — active entries filter and empty state branch
- Direct codebase inspection: `lib/models/hobby.dart` (lines 136-161) — `UserHobby` model with `completedAt`, `pausedAt` fields
- Direct codebase inspection: `server/test/step_completion.test.ts` — existing server tests for `hobbyCompleted` flag

### Secondary (MEDIUM confidence)
- `pubspec.yaml`: `flutter_animate: ^4.5.2` confirmed present — no install needed
- Flutter `PopupMenuButton` API: standard Material widget, well-understood, no external verification needed for this usage level

### Tertiary (LOW confidence)
- None — all findings are from direct codebase inspection

---

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — verified from pubspec.yaml and existing code
- Architecture: HIGH — all integration points verified from direct code reading
- Pitfalls: HIGH — derived from actual code signatures and patterns (not general Flutter knowledge)

**Research date:** 2026-03-23
**Valid until:** 2026-04-22 (30 days — stable codebase, no fast-moving dependencies)
