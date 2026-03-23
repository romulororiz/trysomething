# Stack Research

**Domain:** Hobby lifecycle management — completion detection, pause/stop states, Pro content gating
**Project:** TrySomething v1.1
**Researched:** 2026-03-23
**Scope:** NEW capabilities only — existing stack (Flutter, Riverpod, GoRouter, Prisma, RevenueCat) not re-researched
**Confidence:** HIGH — all findings derived from direct codebase inspection, no external research needed

---

## Context: What Already Exists

The v1.0 stack is in production and fully validated:

- Flutter 3.6.0 + Riverpod 2.6.1 + GoRouter 14.8.1 + Freezed 2.5.7
- Node.js/TypeScript on Vercel + Prisma 6.4.1 + Neon PostgreSQL
- RevenueCat `purchases_flutter ^9.14.0` + `purchases_ui_flutter ^9.14.0`
- `isProProvider` (Riverpod) returning `bool` — already consumed in paywall flows
- `showProUpgrade(context, triggerMessage)` — already exists in `pro_upgrade_sheet.dart`
- `HobbyStatus` enum: `saved | trying | active | done` (Dart + Prisma)
- `UserHobby` model with `completedStepIds: Set<String>`, `startedAt`, `lastActivityAt`
- `UserHobbiesNotifier.toggleStep()` — increments completed steps, fires analytics
- `UserHobbiesNotifier.setDone()` — exists, not yet auto-triggered
- `UserProgressRepositoryApi.updateStatus()` — already sends `PUT /api/users/hobbies/:id` with `status` and `completedAt`
- `flutter_animate ^4.5.2` — already available for celebration animations

**Conclusion: Zero new packages required for any of the v1.1 features.** Every capability is achievable through model changes, state logic additions, and conditional UI with the packages already installed.

---

## Recommended Stack

### Core Technologies

No changes to core technologies. All three capability areas work entirely within the existing stack.

### Capability 1: Hobby Completion Detection

**What needs to change — no new packages.**

| Layer | Change | Details |
|-------|--------|---------|
| Dart model | `UserHobby` — no field changes needed | `completedStepIds: Set<String>` already tracks steps; `progressPercent(int totalSteps)` already computes ratio |
| Dart notifier | `UserHobbiesNotifier.toggleStep()` | After adding a step, compare `completedStepIds.length == totalSteps` and call `setDone()` automatically |
| Dart notifier | Auto-complete trigger needs `totalSteps` passed in | Change `toggleStep(String hobbyId, String stepId)` to `toggleStep(String hobbyId, String stepId, {int totalSteps = 0})` |
| Dart provider | Add `hobbyCompletedProvider` StreamProvider or callback | Notifier can expose a `onHobbyCompleted` callback or callers can watch for `status == done` after toggle |
| Server API | `PUT /api/users/hobbies/:hobbyId` | Already accepts `status: 'done'` and `completedAt`. No server change needed |

**Completion detection pattern — pure Riverpod, no new package:**

```dart
// In UserHobbiesNotifier.toggleStep(), after updating state:
if (!wasCompleted && existing.completedStepIds.length + 1 >= totalSteps && totalSteps > 0) {
  setDone(hobbyId); // auto-transition to done
  // caller observes status change and shows celebration
}
```

Callers watch `userHobbiesProvider` and react when `state[hobbyId]?.status == HobbyStatus.done`.

**Celebration screen: `flutter_animate` (already installed).**
- `flutter_animate ^4.5.2` is in `pubspec.yaml`
- Use `.animate().fadeIn().scale()` chains — same pattern used on session complete phase
- No additional package needed; `lottie` would be overkill for a one-time celebration screen

### Capability 2: Pause/Stop Lifecycle States

**What needs to change — no new packages.**

| Layer | Change | Details |
|-------|--------|---------|
| Prisma schema | Add `paused` to `HobbyStatus` enum | Requires `prisma migrate dev` |
| Prisma schema | Add `pausedAt DateTime?` to `UserHobby` model | Stores when pause was initiated |
| Dart `HobbyStatus` enum | Add `paused` variant | `enum HobbyStatus { saved, trying, active, paused, done }` |
| Dart `UserHobby` model (Freezed) | Add `DateTime? pausedAt` field | Run `dart run build_runner build` after |
| `UserHobbiesNotifier` | Add `pauseHobby(String hobbyId)` | Sets status to `paused`, records `pausedAt`, calls API |
| `UserHobbiesNotifier` | Add `resumeHobby(String hobbyId)` | Sets status back to `active` or `trying`, clears `pausedAt`, calls API |
| `UserHobbiesNotifier` | Add `stopHobby(String hobbyId)` | Sets status to `done` (same as completed but no celebration), calls API |
| Server API | `PUT /api/users/hobbies/:hobbyId` | Accept `paused` status and `pausedAt` field — small handler addition |

**Pause is Pro-gated via `isProProvider`** — no new gating mechanism needed. Same pattern as coach chat limit:

```dart
// In UI before calling notifier.pauseHobby():
final isPro = ref.read(isProProvider);
if (!isPro) {
  showProUpgrade(context, 'pause_hobby');
  return;
}
ref.read(userHobbiesProvider.notifier).pauseHobby(hobbyId);
```

**Stop (abandon) is free** — no gating check, direct `stopHobby()` call with a confirmation dialog.

**Migration note:** Adding a new enum value to a PostgreSQL enum requires a migration. Prisma handles this with `prisma migrate dev`. The `paused` value must also be added to the server-side TypeScript type. No column type changes — PostgreSQL native enums are altered in-place with `ALTER TYPE`.

### Capability 3: Detail Page Content Gating

**What needs to change — no new packages.**

| Layer | Change | Details |
|-------|--------|---------|
| `hobby_detail_screen.dart` | Read `isProProvider` | `final isPro = ref.watch(isProProvider);` already imported via subscription_provider.dart |
| Detail screen | Conditional rendering for FAQ/cost/budget sections | Show sections only when `isPro == true` |
| Detail screen | Pro gate widget for locked sections | Render a blurred/dimmed preview card + "Unlock with Pro" CTA calling `showProUpgrade()` |
| `feature_providers.dart` | No change needed | FAQ, cost, and budget providers already fetch lazily — just don't render them for free users |

**Gating implementation — pure Flutter conditional, no new package:**

```dart
// In hobby_detail_screen.dart section build
final isPro = ref.watch(isProProvider);

if (!isPro) {
  return _ProGateCard(
    label: 'Full breakdown',
    onTap: () => showProUpgrade(context, 'detail_faq'),
  );
}
// render real FAQ content
```

The `_ProGateCard` is a simple `GlassCard` with blurred content preview and coral CTA — built with existing components (`GlassCard`, `AppColors.accent`, `AppTypography`). No external blur or overlay package needed.

**Stage 1 free / Stages 2-4 Pro:** The roadmap is already split into 4 stages via `milestone` field on `RoadmapStep`. Stage 1 detection: filter `roadmapSteps` where `milestone == 'Stage 1'` or where `sortOrder < stepsPerStage`. The exact gating boundary should use `milestone` field since it's already populated in seed data.

---

## Supporting Libraries

All supporting libraries are already installed. No additions.

| Library | Version (installed) | Role in v1.1 | Status |
|---------|--------------------|-----------—--|--------|
| `flutter_riverpod` | `^2.6.1` | State management for lifecycle states | Already installed |
| `freezed_annotation` | `^2.4.4` | Adds `pausedAt` field to `UserHobby` | Already installed |
| `flutter_animate` | `^4.5.2` | Celebration animation on completion | Already installed |
| `purchases_flutter` | `^9.14.0` | Pro status for pause gating | Already installed |
| `purchases_ui_flutter` | `^9.14.0` | `showProUpgrade()` paywall sheet | Already installed |
| `shared_preferences` | `^2.3.4` | Local persistence of `pausedAt` field | Already installed |
| `prisma` | `^6.4.1` | Adds `paused` enum value + migration | Already installed |

---

## Development Tools

| Tool | Purpose | Notes |
|------|---------|-------|
| `dart run build_runner build` | Regenerate Freezed files after model changes | Required after adding `paused` to enum and `pausedAt` to `UserHobby` |
| `prisma migrate dev` | Apply `paused` enum + `pausedAt` column migration | Run from `server/` directory |
| `flutter analyze` | Catch exhaustive switch errors after enum change | Enums used in switch statements (`canStartHobbyProvider`, `getByStatus()`) need `paused` case |

---

## Installation

No new packages. The only setup commands are for code generation and schema migration:

```bash
# After adding pausedAt to UserHobby and paused to HobbyStatus in Dart:
dart run build_runner build --delete-conflicting-outputs

# After updating prisma/schema.prisma:
cd server && npx prisma migrate dev --name add_hobby_paused_status
```

---

## Alternatives Considered

| Recommended | Alternative | Why Not |
|-------------|-------------|---------|
| Extend existing `HobbyStatus` enum with `paused` | Separate `isPaused: bool` field on `UserHobby` | Enum is the correct model — status is a state machine, not a collection of booleans. Boolean fields proliferate and become inconsistent (e.g., `isPaused && status == done` is incoherent) |
| `flutter_animate` for celebration (already installed) | `lottie` package for Lottie animations | Lottie requires custom animation files and an additional package. `flutter_animate` chains are sufficient for a one-time celebration — fade, scale, shimmer |
| `isProProvider` + `showProUpgrade()` for content gating | Custom paywall screen / new gating widget | Both already exist and are used throughout the app. Consistency matters more than novelty |
| Conditional rendering for gated sections | blur_widget or frosted glass overlay packages | CSS-style blur can be done with `BackdropFilter` (built into Flutter) — no new package needed |
| `prisma migrate dev` for enum change | `prisma db push` | `migrate dev` creates a tracked migration file; `db push` is for prototyping only. Always use migrations in production |

---

## What NOT to Add

| Avoid | Why | Use Instead |
|-------|-----|-------------|
| `lottie` package | Adds 2MB+ to app, requires custom animation files, zero celebrations currently | `flutter_animate` chains — already installed, sufficient for one-time celebration |
| `blur_plus` or `frosted_glass` packages | Flutter's `BackdropFilter` + `ImageFilter.blur()` already built-in | `BackdropFilter` with `sigmaX/sigmaY` — used already in glass card components |
| Any new state management approach | Riverpod `StateNotifierProvider` already handles all lifecycle states cleanly | Extend `UserHobbiesNotifier` — same provider, more methods |
| New `paused` repository endpoint | The existing `PUT /api/users/hobbies/:hobbyId` with `status: 'paused'` is sufficient | Extend the existing handler to accept `pausedAt` |
| Stream-based completion events | Riverpod `select()` watching for `status == done` is sufficient | `ref.listen(userHobbiesProvider.select((m) => m[hobbyId]?.status), ...)` in the calling widget |

---

## Version Compatibility

| Package | Constraint | Compatibility Note |
|---------|------------|-------------------|
| `freezed` `^2.5.7` (dev) | `freezed_annotation ^2.4.4` | Matched versions, no change needed |
| `riverpod_generator ^2.6.2` (dev) | `flutter_riverpod ^2.6.1` | Matched versions, no change needed |
| Prisma 6.4.1 | PostgreSQL enum `ALTER TYPE` | Supported natively; `prisma migrate dev` generates correct SQL |
| `flutter_animate ^4.5.2` | Flutter 3.6.0 | Compatible — no minimum Flutter version issue |

---

## Schema Change Detail

The only breaking change in v1.1 is the Prisma schema. The migration SQL that `prisma migrate dev` will generate:

```sql
-- Add paused to HobbyStatus enum
ALTER TYPE "HobbyStatus" ADD VALUE 'paused';

-- Add pausedAt column to UserHobby
ALTER TABLE "UserHobby" ADD COLUMN "pausedAt" TIMESTAMP(3);
```

PostgreSQL supports adding enum values without table rewrites. `ALTER TYPE ... ADD VALUE` is non-blocking on Neon (no table lock). Adding a nullable column to `UserHobby` is also non-blocking.

**No data migration needed** — existing rows with `status = 'trying'` or `status = 'active'` remain valid. `pausedAt` defaults to `NULL` for all existing rows.

---

## Summary: Changes Required

| Area | Change | Effort |
|------|--------|--------|
| `server/prisma/schema.prisma` | Add `paused` to `HobbyStatus` enum; add `pausedAt DateTime?` to `UserHobby` | 5 lines |
| `lib/models/hobby.dart` | Add `paused` to `HobbyStatus` enum; add `DateTime? pausedAt` to `UserHobby` | 3 lines + build_runner |
| `lib/providers/user_provider.dart` | Add `pauseHobby()`, `resumeHobby()`, `stopHobby()`; extend `toggleStep()` with auto-complete | ~50 lines |
| `lib/data/repositories/user_progress_repository_api.dart` | Extend `updateStatus()` to pass `pausedAt` | ~5 lines |
| `server/api/users/[path].ts` | Accept `paused` status + `pausedAt` in PUT handler | ~10 lines |
| `lib/screens/detail/hobby_detail_screen.dart` | Add `isProProvider` watch; gate FAQ/cost/budget sections | ~30 lines |
| `lib/screens/home/home_screen.dart` | Handle `done` status state + "pick your next hobby" CTA | ~30 lines |
| New: celebration screen or modal | Shown when `status` transitions to `done` | ~80 lines (new file) |

**Zero new packages. Zero new environment variables. One database migration.**

---

## Sources

- Codebase inspection: `lib/models/hobby.dart`, `lib/providers/user_provider.dart`, `lib/providers/subscription_provider.dart`, `lib/components/pro_upgrade_sheet.dart`, `lib/data/repositories/user_progress_repository_api.dart`, `server/prisma/schema.prisma`, `pubspec.yaml`, `server/package.json`
- Prisma enum migration: https://www.prisma.io/docs/orm/prisma-client/queries/working-with-enums (ALTER TYPE ADD VALUE is non-blocking in PostgreSQL 12+)
- Flutter BackdropFilter: Flutter SDK built-in, no additional package

---
*Stack research for: TrySomething v1.1 — Hobby Lifecycle and Content Gating*
*Researched: 2026-03-23*
