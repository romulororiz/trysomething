# Phase 14: Pause/Resume Lifecycle - Research

**Researched:** 2026-03-23
**Domain:** Flutter state management, Riverpod optimistic updates, server webhook handling, UI lifecycle states
**Confidence:** HIGH

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

**Paused Home card**
- Same hobby card but at 0.7 opacity, with "Paused" chip and coral "Resume" CTA overlaid
- Days-paused counter visible (e.g., "Paused for 5 days")
- When paused, Home shows ONLY the muted card + Resume CTA + days counter — no coach, no roadmap, no next step
- Card is tappable (opens hobby detail page)

**Pause action**
- "Pause hobby" added to existing 3-dot PopupMenu, above "Stop hobby"
- Only visible for Pro users (check `isProProvider` — free users don't see the option)
- Quick confirmation bottom sheet: "Pause [Hobby]? Your progress will be saved." with Pause/Cancel buttons
- Optimistic: hobby transitions to paused locally, server call in background

**Resume action**
- Prominent coral "Resume" CTA button directly on the paused Home card
- Also available on paused cards in You tab
- No confirmation needed — one tap to resume
- On resume: set `lastActivityAt = now()` so 24h streak window starts fresh

**Pro lapse handling**
- Server-side via RevenueCat EXPIRATION webhook
- When Pro expires: server sets all user's paused hobbies to `active` status, clears `pausedAt`, adds elapsed days to `pausedDurationDays`
- Silent auto-resume — no message shown to user
- Works even if user doesn't open the app

**You tab Paused filter**
- New "Paused" tab alongside Active / Saved / Tried (4 tabs total)
- Paused hobby cards: muted styling + "Resume" CTA button on card (consistent with Home paused card)
- Tapping card opens detail page, tapping Resume button resumes the hobby

**Streak handling (from Phase 11 discussion)**
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

### Deferred Ideas (OUT OF SCOPE)
- Multiple pause/resume cycle tracking (PauseLog table) — defer to v2
- Pause time limit (auto-resume after 30 days) — not discussed, defer
- Notification reminder for paused hobbies ("Still paused — want to resume?") — future feature
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| LIFE-02 | User can pause an active hobby (Pro) — preserves progress, streaks, completed steps; requires active Pro entitlement | `pauseHobby()` in `UserHobbiesNotifier` + `isProProvider` gate + optimistic update pattern established in codebase |
| LIFE-03 | User can resume a paused hobby (Pro) — picks up where they left off with streak continuity | `resumeHobby()` in `UserHobbiesNotifier` + `lastActivityAt = now()` on resume; resume is always free per STATE.md decision |
| LIFE-04 | Home shows paused hobby with frosted glass card (opacity 0.7), "Paused" chip, coral "Resume" CTA, days-paused counter | New branch in `_HobbyPageContentState.build()` when `userHobby.status == HobbyStatus.paused`; `pausedAt` field already available |
| LIFE-05 | You tab shows Paused as a distinct filter state alongside Active/Saved/Tried with pause icon on card | Add 4th tab to `_TabPills`; split `paused` out of `activeEntries` in build(); add `_PausedTabContent` widget |
| LIFE-06 | Pro subscription lapse auto-resumes paused hobbies as active (no data lost, removes pause state gracefully) | Extend existing `EXPIRATION` case in `handleRevenueCatWebhook()` with `prisma.userHobby.updateMany()` |
| LIFE-07 | Pause duration excluded from streak calculation (pausedDurationDays subtracted from gap) | `pausedDurationDays` field exists on `UserHobby`; server updates it on resume; client streak display uses server value |
</phase_requirements>

---

## Summary

Phase 14 adds pause/resume lifecycle for Pro users. The schema work is already done — `HobbyStatus.paused`, `pausedAt`, and `pausedDurationDays` exist on both the Prisma schema and the Dart `UserHobby` model from Phase 11. The `mapUserHobby()` mapper already serializes these fields. This phase is entirely about wiring up the UI and business logic on top of that foundation.

The work splits into three distinct areas. First, Flutter state layer: add `pauseHobby()` and `resumeHobby()` to `UserHobbiesNotifier` using the same optimistic fire-and-forget pattern as `stopHobby()`. Second, Flutter UI: add a "Pause hobby" item to the existing `PopupMenuButton` in `home_screen.dart`, render a distinct paused card branch in `_HobbyPageContentState`, and add a 4th tab to `YouScreen`. Third, server: extend the `EXPIRATION` case in the RevenueCat webhook handler (`handleRevenueCatWebhook`) with a `prisma.userHobby.updateMany()` call to auto-resume paused hobbies.

The existing `PUT /api/users/hobbies/:hobbyId` endpoint already accepts `status: "paused"` because it does a passthrough `{ status }` update — no new server route is needed for pause/resume actions. The only server change needed is the webhook auto-resume logic.

**Primary recommendation:** Follow the `stopHobby()` pattern exactly for `pauseHobby()`/`resumeHobby()`. Extend `_TabPills` and the webhook switch in-place. No new infrastructure needed.

---

## Standard Stack

### Core (all already in project — no new dependencies)

| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| flutter_riverpod | 2.6.1 | State management — `UserHobbiesNotifier` | Project standard; `StateNotifier` pattern established |
| freezed | current | Immutable models — `UserHobby.copyWith()` | Project standard; all models use this |
| shared_preferences | current | Local persistence of `UserHobbiesNotifier` state | Project standard |
| go_router | 14.8.1 | Navigation — `/hobby/:id` detail pushes | Project standard |
| @prisma/client | 6.4.1 | Server DB — `userHobby.updateMany()` for webhook | Project standard |

### No New Dependencies

All functionality is implemented using existing project infrastructure. No new packages needed.

---

## Architecture Patterns

### Recommended File Changes

```
lib/
├── providers/
│   └── user_provider.dart          # Add pauseHobby() + resumeHobby()
├── screens/
│   ├── home/
│   │   └── home_screen.dart        # Add paused branch + "Pause hobby" menu item
│   └── you/
│       └── you_screen.dart         # Add Paused tab (4th) + _PausedTabContent
└── data/repositories/
    └── user_progress_repository.dart     # No changes needed (updateStatus covers pause/resume)
server/
└── api/users/[path].ts             # Extend EXPIRATION case in handleRevenueCatWebhook()
```

### Pattern 1: Optimistic Pause (mirrors stopHobby)

**What:** Update local state immediately, fire API call in background, log analytics.
**When to use:** All status transitions in `UserHobbiesNotifier`.

```dart
// Source: lib/providers/user_provider.dart (stopHobby pattern)
void pauseHobby(String hobbyId) {
  final existing = state[hobbyId];
  if (existing == null) return;
  final now = DateTime.now();
  state = {
    ...state,
    hobbyId: existing.copyWith(
      status: HobbyStatus.paused,
      pausedAt: now,
    ),
  };
  _save();
  _analytics.trackEvent('hobby_paused', {'hobby_id': hobbyId});
  () async {
    try {
      await _repo.updateStatus(hobbyId, HobbyStatus.paused, pausedAt: now);
    } catch (e) {
      debugPrint('[UserHobbies] pauseHobby API call failed: $e');
    }
  }();
}

void resumeHobby(String hobbyId) {
  final existing = state[hobbyId];
  if (existing == null) return;
  final now = DateTime.now();
  // Compute elapsed pause days before clearing pausedAt
  final elapsed = existing.pausedAt != null
      ? now.difference(existing.pausedAt!).inDays
      : 0;
  state = {
    ...state,
    hobbyId: existing.copyWith(
      status: HobbyStatus.active,
      pausedAt: null,
      pausedDurationDays: existing.pausedDurationDays + elapsed,
      lastActivityAt: now,  // LIFE-03 + LIFE-07: fresh streak window
    ),
  };
  _save();
  _analytics.trackEvent('hobby_resumed', {'hobby_id': hobbyId});
  () async {
    try {
      await _repo.updateStatus(
        hobbyId, HobbyStatus.active,
        pausedAt: null,
        pausedDurationDays: existing.pausedDurationDays + elapsed,
        lastActivityAt: now,
      );
    } catch (e) {
      debugPrint('[UserHobbies] resumeHobby API call failed: $e');
    }
  }();
}
```

### Pattern 2: Repository updateStatus Extension

The existing `updateStatus()` on `UserProgressRepositoryApi` passes all fields through via named params. Add `pausedAt` and `pausedDurationDays` optional parameters to both the abstract interface and the API impl:

```dart
// Source: lib/data/repositories/user_progress_repository.dart
Future<UserHobby> updateStatus(
  String hobbyId,
  HobbyStatus status, {
  DateTime? startedAt,
  DateTime? completedAt,
  DateTime? pausedAt,        // new
  bool clearPausedAt = false, // new — explicit null-set signal
  int? pausedDurationDays,   // new
  DateTime? lastActivityAt,  // new
});
```

The server `PUT /users/hobbies/:hobbyId` already does `...(status !== undefined && { status })` spread — just add the new fields to the body in `updateStatus()` API impl and add them to the server's spread destructure.

### Pattern 3: Home Screen Paused State Branch

**What:** In `_HomeScreenState.build()`, paused hobbies are currently excluded from `activeEntries`. They need a parallel `pausedEntries` list and a page branch. However — per locked decision — Home shows ONLY the muted paused card when paused. So paused hobbies appear as their own page in the `PageView`, not in `activeEntries`.

The simplest approach: include paused entries in the page list alongside active entries, but render them with `_PausedHobbyPage` instead of `_HobbyPage`:

```dart
// In home_screen.dart build():
final pausedEntries = userHobbies.entries
    .where((e) => e.value.status == HobbyStatus.paused)
    .toList();

// All displayable hobby pages = active + paused
final allDisplayEntries = [...activeEntries, ...pausedEntries];
// (or sorted by lastActivityAt for consistent ordering)

// In PageView itemBuilder:
itemBuilder: (context, i) {
  final entry = allDisplayEntries[i];
  if (entry.value.status == HobbyStatus.paused) {
    return _PausedHobbyPage(key: ValueKey('paused_${entry.key}'), userHobby: entry.value);
  }
  // existing active page logic...
}
```

### Pattern 4: You Tab — Add 4th "Paused" Tab

In `you_screen.dart`, `paused` currently falls through to `activeEntries` (line 73). Phase 14 splits it out:

```dart
// Split in build():
final pausedEntries = <_HobbyWithMeta>[];

// In the switch:
case HobbyStatus.paused:
  pausedEntries.add(meta);  // was: activeEntries.add(meta)

// _TabPills gets pausedCt parameter; tab order: Active / Paused / Saved / Tried
// _selectedTab: 0=Active, 1=Paused, 2=Saved, 3=Tried
```

`_buildTabContent` gains a `case 1:` for paused. `_TabPills` adds `pausedCt` param and a 4th tab entry.

### Pattern 5: Webhook Auto-Resume (LIFE-06)

In `server/api/users/[path].ts`, extend the `EXPIRATION` case:

```typescript
// Source: server/api/users/[path].ts — handleRevenueCatWebhook
case 'CANCELLATION':
case 'EXPIRATION':
  if (!user.isLifetime) {
    await prisma.user.update({
      where: { id: userId },
      data: { subscriptionTier: "free", proExpiresAt: expiresAt },
    });
    // LIFE-06: auto-resume any paused hobbies — Pro lapse should not strand them
    const now = new Date();
    const pausedHobbies = await prisma.userHobby.findMany({
      where: { userId, status: 'paused' },
      select: { hobbyId: true, pausedAt: true, pausedDurationDays: true },
    });
    for (const ph of pausedHobbies) {
      const elapsedDays = ph.pausedAt
        ? Math.floor((now.getTime() - ph.pausedAt.getTime()) / 86_400_000)
        : 0;
      await prisma.userHobby.update({
        where: { userId_hobbyId: { userId, hobbyId: ph.hobbyId } },
        data: {
          status: 'active',
          pausedAt: null,
          pausedDurationDays: ph.pausedDurationDays + elapsedDays,
          lastActivityAt: now,
        },
      });
    }
  }
  break;
```

Note: Using a loop instead of `updateMany` because `pausedDurationDays` needs a per-row calculation. If performance is a concern with many hobbies, a raw SQL approach works, but the loop is correct and simple.

### Anti-Patterns to Avoid

- **Including paused in activeEntries filter:** `_findHobbyIndex()` and the streak header would treat paused hobbies as active. Keep paused separate in Home page list.
- **Using `setActive()` for resume:** `setActive()` does not update `lastActivityAt`, `pausedAt`, or `pausedDurationDays`. Use a dedicated `resumeHobby()` method.
- **updateMany for webhook auto-resume:** Can't use `updateMany` to compute per-row `pausedDurationDays` increments; must query first then loop.
- **Pro-gating resume:** Per STATE.md (key decision): "Resume is always free; only initiating a pause requires Pro." Do not put `isProProvider` check on the Resume button.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Bottom sheet UI | Custom modal widget | `showAppSheet()` in `app_overlays.dart` | Already has drag handle, blur backdrop, title row, correct insets |
| Days-paused calculation | Manual DateTime math | `DateTime.now().difference(userHobby.pausedAt!).inDays` | Dart built-in, already used in codebase |
| Local state persistence | Custom storage | `_save()` + `SharedPreferences` in `UserHobbiesNotifier` | Pattern already established, handles serialization |
| Pause confirmation | Custom dialog | `showAppSheet()` with coral CTA button (matching stop confirmation pattern) | Consistent with stop confirmation UX |
| Streak freeze logic | Recompute streaks client-side | Use server-returned `streakDays` value | Server owns streak computation; `pausedDurationDays` accumulates on server |

**Key insight:** Every primitive needed for this phase exists — the only work is wiring them together. No new architecture is needed.

---

## Common Pitfalls

### Pitfall 1: toggleStep returns (UserHobby, bool) — Mock needs updating

**What goes wrong:** `MockUserProgressRepository.toggleStep()` in `user_hobbies_notifier_test.dart` (line 46) returns `UserHobby` instead of `(UserHobby, bool)`. The test file already has this bug.
**Why it happens:** Test was written before the return type was changed to a record tuple.
**How to avoid:** When adding `pauseHobby`/`resumeHobby` tests, update `MockUserProgressRepository` to match the current `toggleStep` signature and add `pauseHobby`/`resumeHobby` to the mock.
**Warning signs:** `dart analyze` will catch the type mismatch immediately.

### Pitfall 2: HobbyStatus enum test needs `paused` added

**What goes wrong:** `user_progress_repository_api_test.dart` line 13 asserts `HobbyStatus.values` has length 4 and does not include `paused`. Since Phase 11 added `paused`, this test is wrong (or was wrong even before this phase).
**Why it happens:** Test was not updated when `paused` was added in Phase 11.
**How to avoid:** Fix test to expect length 5 and include `HobbyStatus.paused`.
**Warning signs:** `dart test test/unit/repositories/user_progress_repository_api_test.dart` will fail.

### Pitfall 3: Home screen _findHobbyIndex must include paused

**What goes wrong:** `_findHobbyIndex()` filters only `trying` and `active` statuses. If paused hobbies appear in the `PageView`, the initial page index calculation for `initialHobbyId` will be wrong.
**Why it happens:** Originally written before pause existed.
**How to avoid:** If paused hobbies are shown in the Home `PageView`, update `_findHobbyIndex()` to include `paused` in the filter.

### Pitfall 4: You screen activeCount in profile header counts paused as active

**What goes wrong:** `_CenteredProfileHeader` receives `activeCount: activeEntries.length`. After the split, this should only count truly active/trying hobbies, not paused.
**Why it happens:** Paused currently lumped into active.
**How to avoid:** Pass `activeCount: activeEntries.length` using the post-split activeEntries (after paused is moved to its own list).

### Pitfall 5: optimistic resume race condition

**What goes wrong:** User taps Pause, then immediately taps Resume before the `pauseHobby` API call completes. Both API calls fire concurrently. Server processes resume first, then pause overwrites.
**Why it happens:** Both calls are fire-and-forget with no cancellation.
**How to avoid:** Per CONTEXT.md "Claude's Discretion" — simplest approach is to accept this edge case for v1 since it requires deliberate rapid tapping. Alternatively, debounce with a 300ms delay in the notifier before firing. Given STATE.md notes this as a known concern, document the limitation but don't over-engineer.

### Pitfall 6: updateStatus repository signature change is additive

**What goes wrong:** Adding `pausedAt`, `pausedDurationDays` to `updateStatus` without default values breaks callers that don't provide them.
**Why it happens:** Dart requires named parameters with defaults or `?` nullable.
**How to avoid:** All new params must be nullable with `= null` defaults. Server `PUT` handler must use `...(pausedAt !== undefined && { pausedAt: ...})` spread pattern.

### Pitfall 7: Server PUT needs explicit null for pausedAt clear

**What goes wrong:** Sending `pausedAt: null` in JSON may be omitted/ignored by the server's `...(pausedAt !== undefined && ...)` check if undefined ≠ null.
**Why it happens:** JavaScript distinguishes `undefined` (key absent) from `null` (key present with null value).
**How to avoid:** Use a distinct sentinel: send `clearPausedAt: true` in the request body for resume, or always include `pausedAt` in the body with explicit null. Simplest: always send `pausedAt` regardless (even if null), and check `if (pausedAt !== undefined)` on server (null is !== undefined, so null will be accepted and written).

---

## Code Examples

Verified patterns from existing codebase:

### showAppSheet — pause confirmation sheet

```dart
// Source: lib/components/app_overlays.dart (showAppSheet)
// Source: lib/screens/home/home_screen.dart (_showStopConfirmation pattern)
void _showPauseConfirmation(BuildContext context, WidgetRef ref, Hobby hobby) {
  showAppSheet(
    context: context,
    title: 'Pause ${hobby.title}?',
    builder: (ctx) => Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your progress will be saved. Resume anytime.',
            style: AppTypography.body.copyWith(
              color: AppColors.textMuted, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                ref.read(userHobbiesProvider.notifier).pauseHobby(hobby.id);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent.withValues(alpha: 0.15),
                foregroundColor: AppColors.accent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Text('Pause hobby', style: AppTypography.button),
            ),
          ),
        ],
      ),
    ),
  );
}
```

### PopupMenuButton — adding Pause item above Stop

```dart
// Source: lib/screens/home/home_screen.dart (PopupMenuButton, line 513)
PopupMenuButton<String>(
  icon: Icon(Icons.more_vert_rounded, color: AppColors.textMuted, size: 20),
  color: AppColors.surface,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
    side: BorderSide(color: AppColors.glassBorder, width: 0.5),
  ),
  onSelected: (value) {
    if (value == 'pause') {
      _showPauseConfirmation(context, ref, hobby);
    } else if (value == 'stop') {
      _showStopConfirmation(context, ref, hobby);
    }
  },
  itemBuilder: (_) => [
    if (isPro) PopupMenuItem(
      value: 'pause',
      child: Row(children: [
        Icon(MdiIcons.pauseCircleOutline, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        Text('Pause hobby', style: AppTypography.body.copyWith(
            color: AppColors.textSecondary, fontSize: 14)),
      ]),
    ),
    PopupMenuItem(
      value: 'stop',
      child: Row(children: [
        Icon(Icons.stop_circle_outlined, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        Text('Stop hobby', style: AppTypography.body.copyWith(
            color: AppColors.textSecondary, fontSize: 14)),
      ]),
    ),
  ],
),
```

### Paused card — Opacity + Chip + Resume CTA overlay structure

```dart
// Conceptual pattern — uses AppColors.accent for Resume CTA
Widget _buildPausedCardContent(Hobby hobby, UserHobby userHobby) {
  final daysPaused = userHobby.pausedAt != null
      ? DateTime.now().difference(userHobby.pausedAt!).inDays
      : 0;

  return Opacity(
    opacity: 0.7,
    child: Stack(
      children: [
        // Existing card content (hero image, title etc.) — tappable to detail
        GestureDetector(
          onTap: () => context.push('/hobby/${hobby.id}'),
          child: _buildCardBase(hobby, userHobby),
        ),
        // Paused chip (top-left area, below category chip)
        Positioned(
          top: 12, left: 24,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.glassBorder, width: 0.5),
            ),
            child: Text('PAUSED',
                style: AppTypography.overline.copyWith(color: AppColors.textMuted)),
          ),
        ),
        // Days counter
        Positioned(
          bottom: 80, left: 24,
          child: Text(
            daysPaused == 0 ? 'Paused today' : 'Paused for $daysPaused ${daysPaused == 1 ? "day" : "days"}',
            style: AppTypography.caption.copyWith(color: AppColors.textMuted),
          ),
        ),
        // Resume CTA
        Positioned(
          bottom: 24, left: 24, right: 24,
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: () => ref.read(userHobbiesProvider.notifier).resumeHobby(hobby.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Text('Resume', style: AppTypography.button),
            ),
          ),
        ),
      ],
    ),
  );
}
```

### _TabPills — adding the Paused tab

```dart
// Source: lib/screens/you/you_screen.dart (_TabPills.build)
// Add pausedCt to constructor and tabs list:
final tabs = [
  ('Active', activeCt),
  ('Paused', pausedCt),  // new — index 1
  ('Saved', savedCt),    // was index 1, now 2
  ('Tried', triedCt),    // was index 2, now 3
];
```

### Webhook auto-resume — mappers type

The `mapUserHobby` mapper already serializes `pausedAt` and `pausedDurationDays`. No mapper changes needed.

---

## State of the Art

| Old Approach | Current Approach | Impact |
|--------------|------------------|--------|
| paused falls into Active tab in You | Separate Paused tab | Cleaner UX, no ambiguity |
| Streak resets on any gap | `pausedDurationDays` excludes pause time from gap | Streak integrity preserved |
| Lapse strands paused hobbies | Webhook auto-resume | No data loss on subscription expiry |

**Existing infrastructure that's ready:**
- `HobbyStatus.paused` enum value: exists in both Dart and Prisma (Phase 11)
- `pausedAt DateTime?` + `pausedDurationDays Int @default(0)` on `UserHobby`: exists (Phase 11)
- `mapUserHobby()`: already maps both pause fields
- `isProProvider`: synchronous bool, available anywhere in the widget tree
- `showAppSheet`: premium bottom sheet ready to use

---

## Open Questions

1. **Tab order in You screen — Active / Paused / Saved / Tried vs Active / Saved / Tried / Paused**
   - What we know: Locked decision says "New 'Paused' tab alongside Active / Saved / Tried (4 tabs total)"
   - What's unclear: Exact position. Paused after Active is most logical (related state). "Active / Paused / Saved / Tried" makes semantic sense.
   - Recommendation: Active / Paused / Saved / Tried. Paused is a sub-state of active (hobby in progress, just sleeping), so adjacency is right. Tab indices shift: 0=Active, 1=Paused, 2=Saved, 3=Tried. Update `_buildTabContent` default case to `return const SizedBox.shrink()` (same as now).

2. **Home PageView: where do paused pages appear relative to active pages?**
   - What we know: Home currently shows only active/trying hobbies in the PageView. Paused hobbies must appear somewhere.
   - What's unclear: Should paused be interleaved with active or appended after?
   - Recommendation: Append paused after active in the page list, sorted by `pausedAt` descending. This keeps the most recent active hobby at index 0 (unchanged behavior for users without paused hobbies).

3. **updateStatus API signature — does server need `pausedAt` and `pausedDurationDays` in the PUT body?**
   - What we know: Server PUT currently accepts `{ status, startedAt, completedAt }` and spreads them. Resume needs `pausedAt: null` and `pausedDurationDays: N` to be written.
   - What's unclear: Whether to extend the server PUT body or use a separate endpoint.
   - Recommendation: Extend the existing PUT body. Add `pausedAt`, `clearPausedAt`, `pausedDurationDays`, `lastActivityAt` to the server's destructure and spread. Low risk — same pattern as existing fields.

---

## Validation Architecture

### Test Framework

| Property | Value |
|----------|-------|
| Framework | flutter_test (Flutter SDK) + Vitest (server) |
| Config file | `pubspec.yaml` (Flutter) / `server/package.json` (Vitest) |
| Quick run command | `dart test test/unit/providers/user_hobbies_notifier_test.dart` |
| Full suite command | `flutter analyze && dart test` |

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| LIFE-02 | `pauseHobby()` sets status=paused, pausedAt, fires API, tracks analytics | unit | `dart test test/unit/providers/user_hobbies_notifier_test.dart` | ✅ (extend existing) |
| LIFE-02 | `pauseHobby()` blocked for free users (UI gate, not provider-level) | unit | `dart test test/unit/providers/user_hobbies_notifier_test.dart` | ✅ (extend existing) |
| LIFE-03 | `resumeHobby()` sets status=active, clears pausedAt, adds elapsed days, sets lastActivityAt=now | unit | `dart test test/unit/providers/user_hobbies_notifier_test.dart` | ✅ (extend existing) |
| LIFE-04 | Paused card renders with opacity 0.7, "Paused" chip, Resume CTA visible | manual | Device smoke test | — manual only |
| LIFE-05 | You tab shows Paused as 4th option, paused hobbies appear there | manual | Device smoke test | — manual only |
| LIFE-06 | Webhook EXPIRATION auto-resumes paused hobbies | unit (server) | `cd server && npm test -- webhook-auth.test.ts` | ✅ extend webhook-auth.test.ts |
| LIFE-07 | pausedDurationDays excluded from streak display | unit | `dart test test/unit/repositories/user_progress_repository_api_test.dart` | ✅ extend (fix paused enum count too) |

### Sampling Rate
- **Per task commit:** `dart analyze lib/providers/user_provider.dart lib/screens/home/home_screen.dart lib/screens/you/you_screen.dart`
- **Per wave merge:** `flutter analyze && dart test`
- **Phase gate:** Full suite green before `/gsd:verify-work`

### Wave 0 Gaps

- [ ] `test/unit/providers/user_hobbies_notifier_test.dart` — extend `MockUserProgressRepository` with `pauseHobby`/`resumeHobby` calls (currently missing; `toggleStep` return type also wrong: returns `UserHobby` not `(UserHobby, bool)` — fix this too)
- [ ] `test/unit/repositories/user_progress_repository_api_test.dart` line 13 — fix `HobbyStatus.values` length assertion from 4 to 5 and add `HobbyStatus.paused` to `containsAll`
- [ ] `server/test/webhook-auth.test.ts` — add test case for EXPIRATION event when user has paused hobbies (verify updateMany/loop sets status=active, clears pausedAt)

---

## Sources

### Primary (HIGH confidence)

- Codebase direct read — `lib/models/hobby.dart` lines 136-161: `HobbyStatus.paused`, `UserHobby` fields `pausedAt`/`pausedDurationDays`/`streakDays`
- Codebase direct read — `server/prisma/schema.prisma` lines 210-235: `HobbyStatus` enum with `paused`, `UserHobby` model with all pause fields
- Codebase direct read — `server/lib/mappers.ts` lines 271-283: `mapUserHobby()` already maps `pausedAt` and `pausedDurationDays`
- Codebase direct read — `server/api/users/[path].ts` lines 419-450: `PUT /users/hobbies/:hobbyId` passthrough pattern
- Codebase direct read — `server/api/users/[path].ts` lines 1169-1287: `handleRevenueCatWebhook()` with full EXPIRATION case
- Codebase direct read — `lib/providers/user_provider.dart` lines 334-353: `stopHobby()` fire-and-forget pattern to replicate
- Codebase direct read — `lib/components/app_overlays.dart`: `showAppSheet()` signature and implementation
- Codebase direct read — `lib/screens/home/home_screen.dart` lines 513-544: `PopupMenuButton` with `stop` item
- Codebase direct read — `lib/screens/you/you_screen.dart` lines 433-493: `_TabPills` with 3 tabs
- Codebase direct read — `.planning/STATE.md` lines 74-96: key architectural decisions including "Resume is always free"

### Secondary (MEDIUM confidence)

- STATE.md line 99: "Phase 14 needs a 30-min RevenueCat webhook spike before coding: EXPIRATION event payload shape" — noted, but the existing `handleRevenueCatWebhook` already handles EXPIRATION and `event.app_user_id` resolution. The auto-resume extension is additive to that existing handler.

### Tertiary (LOW confidence)

- RevenueCat EXPIRATION webhook payload documented at https://www.revenuecat.com/docs/integrations/webhooks/event-types-and-fields — existing handler shows `event.type`, `event.app_user_id`, `event.expiration_at_ms`. The relevant fields are already extracted in the existing code.

---

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — all in codebase, versions confirmed
- Architecture: HIGH — full source read of all integration points
- Pitfalls: HIGH — identified from direct code reading, not speculation
- Test gaps: HIGH — confirmed by reading actual test files

**Research date:** 2026-03-23
**Valid until:** 2026-04-22 (stable domain — 30 days)
