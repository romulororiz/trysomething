# Phase 11: Lifecycle Schema Migration - Research

**Researched:** 2026-03-23
**Domain:** Prisma schema migration (PostgreSQL enum extension), Dart/Freezed enum codegen, TypeScript API extension
**Confidence:** HIGH

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

**Status flow:**
- Valid transitions: `saved → trying → active → done`; `active/trying → paused` (Pro only); `paused → active` (resume); `active/trying/paused → done` (stop)
- Paused hobbies can be stopped directly (no forced resume first)
- No restart in v1.1 — stopped and completed hobbies go to Tried permanently
- Done vs Stopped distinction: Claude's discretion on whether to use a single `done` status with a flag or separate enum values. Optimize for minimal switch statement complexity.

**Completion detection:**
- Hobby auto-transitions to `done` when all roadmap steps are completed (completedStepCount === totalStepCount)
- Flexible step order stays — users can do step 3 before step 1
- Server-side detection: step completion endpoint checks count in the same transaction
- No user confirmation prompt — completion is automatic when the last step is marked

**Pause data model:**
- Single counter approach: `pausedAt DateTime?` + `pausedDurationDays Int @default(0)`
- On pause: set `pausedAt = now()`
- On resume: add elapsed days to `pausedDurationDays`, clear `pausedAt`, set `lastActivityAt = now()`
- Pro lapse: auto-resume paused hobbies as active (no data lost, just lose ability to re-pause)
- Streak behavior: freeze at pause value. On resume, set `lastActivityAt = now()` so 24h window starts fresh

**Step completion API:**
- Step completion endpoint returns `{ hobbyCompleted: true/false }` in response
- When `hobbyCompleted: true`, server has already set `status = done` + `completedAt = now()` in the same DB transaction
- Client reads the flag to trigger celebration — no separate status update call needed
- Single atomic transaction prevents partial states

### Claude's Discretion
- Whether to add a `stopped` enum value or reuse `done` with a distinguishing field
- Prisma migration splitting strategy (research flagged PostgreSQL error 55P04)
- Freezed codegen ordering and build_runner approach
- Which existing switch statements need updating and how to handle the new `paused` case in each

### Deferred Ideas (OUT OF SCOPE)
- Restart hobby feature (re-activate a stopped/done hobby) — defer to v2
- Full PauseLog table for multiple pause/resume cycle analytics — defer to v2
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| SCHM-01 | Add `paused` to `HobbyStatus` enum in Prisma schema and Flutter model via two-step migration (add enum value first, then use it) | Two-step migration pattern documented below; Dart exhaustive-switch impact on 3 switch sites identified |
| SCHM-02 | Add `pausedAt DateTime?` and `pausedDurationDays Int @default(0)` fields to UserHobby model | Single `ALTER TABLE ADD COLUMN` migration; safe to add nullable/default fields in one step |
| SCHM-03 | Server-side step completion endpoint sets `status = done` and `completedAt = now()` when all steps are complete (single transaction) | Step handler in `server/api/users/[path].ts:342–380` identified; completion count query pattern and transaction approach documented |
</phase_requirements>

---

## Summary

Phase 11 is a pure schema + API-layer change with no UI output. It has three separable workstreams that must complete in order: (1) Prisma migration and server-side type update, (2) Dart model update and Freezed codegen, (3) step completion endpoint extension.

The most critical constraint is the PostgreSQL enum extension limitation (Prisma issue #8424 / error code 55P04): adding a new enum value AND immediately using it as a column default must be split into two migration files. The `paused` enum addition is migration file 1; any future usage of `paused` as a default value would be migration file 2. For Phase 11, neither `pausedAt` nor `pausedDurationDays` use `paused` as a default, so only one extra migration is strictly needed for the enum value itself — but splitting is still the safe pattern. SCHM-02 (adding nullable fields with non-enum defaults) can be a separate migration file without the 55P04 risk.

The Dart side requires adding `paused` to the `HobbyStatus` enum in `lib/models/hobby.dart`, then running `build_runner` to regenerate `hobby.freezed.dart` and `hobby.g.dart`. Dart 3 switch expressions are exhaustive by default — all three existing `switch (status)` sites (`you_screen.dart:70`, `hobby_coach_screen.dart:94`, `notification_scheduler.dart:77`) will become compile errors until `paused` is handled in each. This is the safest exhaustiveness check possible — the compiler enforces it.

**Primary recommendation:** Three migration files total — (1) `ALTER TYPE HobbyStatus ADD VALUE 'paused'`, (2) `ALTER TABLE UserHobby ADD COLUMN pausedAt / pausedDurationDays`, (3) step completion transaction extension (no new migration, only code). Run `build_runner` immediately after the Dart enum change to let the compiler surface all unhandled switch arms.

---

## Standard Stack

### Core

| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Prisma | 6.4.1 | ORM + migration runner | Already in project; `prisma migrate dev` generates and applies SQL |
| Neon PostgreSQL | current | Production DB (serverless) | Already in project; PostgreSQL semantics apply for enum extension |
| Freezed | 2.x (Flutter 3.6) | Dart code generation for immutable models | Already in project; enum changes regenerate `.freezed.dart` + `.g.dart` |
| build_runner | current | Dart codegen orchestrator | Already in project; `dart run build_runner build --delete-conflicting-outputs` |
| Vitest | 3.0.0 | Server-side unit tests | Already in project; `cd server && npm test` |

### Supporting

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| `@prisma/client` | 6.4.1 | TypeScript Prisma query client | Step completion transaction uses `prisma.$transaction([...])` |
| `dart analyze` | SDK | Static analysis | Run after each Dart file change to catch exhaustiveness errors early |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Two migration files (enum + fields) | Single migration file | Single file triggers 55P04 on Neon PostgreSQL if `paused` were used as a default; splitting is always safe |
| Reuse `done` + `isStopped` flag | Add `stopped` enum value | Adding `stopped` requires a third enum migration file and 4 more switch arms across 3 sites. Reusing `done` with a flag (e.g., `completedAt = null` means stopped, `completedAt != null` means completed) keeps switch complexity minimal and uses an already-existing field. Recommended. |

---

## Architecture Patterns

### Recommended File Change Order

```
1. server/prisma/schema.prisma          # Add paused to HobbyStatus enum + pausedAt/pausedDurationDays fields
2. server/prisma/migrations/
   ├── YYYYMMDD_add_paused_to_hobby_status/migration.sql   # ALTER TYPE ADD VALUE only
   └── YYYYMMDD_add_pause_fields_to_user_hobby/migration.sql  # ALTER TABLE ADD COLUMN
3. server/lib/mappers.ts                # Add pausedAt + pausedDurationDays to PrismaUserHobby type + mapUserHobby
4. server/api/users/[path].ts           # Extend step toggle handler with completion detection
5. lib/models/hobby.dart                # Add paused to HobbyStatus enum + pausedAt/pausedDurationDays to UserHobby
6. (run build_runner)                   # Regenerate hobby.freezed.dart + hobby.g.dart
7. lib/screens/you/you_screen.dart      # Handle paused in switch (add to activeEntries — temporary stub)
8. lib/screens/coach/hobby_coach_screen.dart  # Handle paused in switch (same limits as active — temporary stub)
9. lib/core/notifications/notification_scheduler.dart  # Handle paused in switch (skip notifications — temporary stub)
10. lib/providers/user_provider.dart    # canStartHobbyProvider and status filters already use || chains, no switch — no change needed
```

### Pattern 1: Two-Step Prisma Enum Migration

**What:** PostgreSQL cannot use a newly added enum value in the same transaction. Prisma generates a single migration file that does both `ALTER TYPE ADD VALUE` and then uses the value. This fails with error 55P04 on all PostgreSQL versions (Prisma issue #8424).

**When to use:** Any time a new enum value is added to a Prisma schema AND is used in the same schema change (as a default or new column type).

**Approach for Phase 11:** `paused` is not used as a default anywhere. The enum addition is safe in its own file. The pause fields use non-enum defaults (`null` and `0`). Two separate migration files is still the safest approach.

**Migration file 1 — enum value only:**
```sql
-- Migration: add_paused_to_hobby_status
-- DO NOT add any ALTER TABLE in this file

ALTER TYPE "HobbyStatus" ADD VALUE 'paused';
```

**Migration file 2 — new columns:**
```sql
-- Migration: add_pause_fields_to_user_hobby

ALTER TABLE "UserHobby" ADD COLUMN "pausedAt" TIMESTAMP(3);
ALTER TABLE "UserHobby" ADD COLUMN "pausedDurationDays" INTEGER NOT NULL DEFAULT 0;
```

**schema.prisma changes:**
```prisma
enum HobbyStatus {
  saved
  trying
  active
  paused   // NEW
  done
}

model UserHobby {
  // ... existing fields ...
  pausedAt           DateTime?
  pausedDurationDays Int       @default(0)  // NEW
}
```

### Pattern 2: Prisma Manual Migration Creation

**What:** When Prisma auto-generates a migration that is unsafe (combines enum add + use), create the migration files manually and use `prisma migrate resolve` to mark them applied.

**Correct approach for this project:**
```bash
# Step 1: Create migration directory manually with correct timestamp
mkdir server/prisma/migrations/YYYYMMDDHHMMSS_add_paused_to_hobby_status

# Step 2: Write migration.sql manually (enum only)
# Step 3: Apply to Neon dev DB
cd server && npx prisma migrate dev --name add_paused_to_hobby_status

# If Prisma auto-generates both in one file, split manually:
# - Edit the generated file to remove field additions
# - Create a second migration file for the fields
# - npx prisma migrate dev --name add_pause_fields_to_user_hobby
```

**Alternative safe approach:** Edit `schema.prisma` in two commits — first add enum value only and migrate, then add fields and migrate again.

### Pattern 3: Step Completion Detection in Transaction

**What:** The existing step toggle handler at `server/api/users/[path].ts:342` runs multiple sequential Prisma operations. SCHM-03 requires wrapping them in a transaction and adding a completion check.

**Current flow (non-transactional):**
1. `prisma.userHobby.upsert` — ensure hobby row exists
2. `prisma.userCompletedStep.findUnique` — check if step already done
3. `prisma.userCompletedStep.delete` OR `.create` — toggle step
4. `prisma.userActivityLog.create` — log action
5. `checkChallengeProgress(...)` — gamification
6. `prisma.userHobby.findUnique` — fetch updated hobby to return

**New flow (transactional with completion detection):**
```typescript
// Source: Prisma docs — interactive transactions
const result = await prisma.$transaction(async (tx) => {
  // 1. Ensure hobby row exists
  await tx.userHobby.upsert({
    where: { userId_hobbyId: { userId, hobbyId } },
    create: { userId, hobbyId, status: "trying", lastActivityAt: new Date() },
    update: { lastActivityAt: new Date() },
  });

  // 2. Toggle step
  const existing = await tx.userCompletedStep.findUnique({
    where: { userId_hobbyId_stepId: { userId, hobbyId, stepId } },
  });

  if (existing) {
    await tx.userCompletedStep.delete({ where: { id: existing.id } });
  } else {
    await tx.userCompletedStep.create({ data: { userId, hobbyId, stepId } });
  }

  // 3. Completion check (only on step ADD, not remove)
  let hobbyCompleted = false;
  if (!existing) {
    const [completedCount, totalSteps] = await Promise.all([
      tx.userCompletedStep.count({ where: { userId, hobbyId } }),
      tx.roadmapStep.count({ where: { hobbyId } }),
    ]);
    if (totalSteps > 0 && completedCount >= totalSteps) {
      await tx.userHobby.update({
        where: { userId_hobbyId: { userId, hobbyId } },
        data: { status: "done", completedAt: new Date() },
      });
      hobbyCompleted = true;
    }
  }

  // 4. Fetch updated hobby
  const updatedHobby = await tx.userHobby.findUnique({
    where: { userId_hobbyId: { userId, hobbyId } },
    include: { completedSteps: { select: { stepId: true } } },
  });

  return { hobby: updatedHobby!, hobbyCompleted };
});

// 5. Activity log + gamification (outside transaction — non-critical)
await prisma.userActivityLog.create({ ... });
if (!existing) await checkChallengeProgress(userId, "step_complete");

res.status(200).json({ ...mapUserHobby(result.hobby), hobbyCompleted: result.hobbyCompleted });
```

**Key decision:** `checkChallengeProgress` and activity log stay outside the transaction — they are non-critical and should not cause the step toggle to roll back on failure.

### Pattern 4: Dart HobbyStatus Enum + Freezed

**What:** Adding `paused` to the Dart `HobbyStatus` enum in `lib/models/hobby.dart` plus the two new fields to the `UserHobby` Freezed class.

**Dart enum change:**
```dart
// lib/models/hobby.dart:136
enum HobbyStatus { saved, trying, active, paused, done }
```

**UserHobby Freezed change — add two fields:**
```dart
@freezed
class UserHobby with _$UserHobby {
  const UserHobby._();

  const factory UserHobby({
    required String hobbyId,
    required HobbyStatus status,
    @SetStringConverter() @Default(<String>{}) Set<String> completedStepIds,
    DateTime? startedAt,
    DateTime? lastActivityAt,
    DateTime? pausedAt,                    // NEW
    @Default(0) int pausedDurationDays,    // NEW
    @Default(0) int streakDays,
  }) = _UserHobby;

  factory UserHobby.fromJson(Map<String, dynamic> json) =>
      _$UserHobbyFromJson(json);
}
```

**Codegen command:**
```bash
cd C:/dev/trysomething
dart run build_runner build --delete-conflicting-outputs
```

### Pattern 5: Exhaustive Switch Stub Handling

**What:** Dart 3 `switch` on an enum is exhaustive — omitting any case is a compile-time error. Phase 11 adds `paused` to the enum, which will break compilation at three sites immediately.

**Approach:** Add `paused` to each switch with a minimal stub that is semantically correct for Phase 11 (UI behavior comes in Phase 14):

**`lib/screens/you/you_screen.dart:70`** — paused hobby should appear in Active tab for now:
```dart
switch (uh.status) {
  case HobbyStatus.trying:
  case HobbyStatus.active:
  case HobbyStatus.paused:   // NEW — Phase 14 will add Paused filter
    activeEntries.add(meta);
  case HobbyStatus.saved:
    savedEntries.add(meta);
  case HobbyStatus.done:
    triedEntries.add(meta);
}
```

**`lib/screens/coach/hobby_coach_screen.dart:94`** — paused gets same message limit as active:
```dart
switch (status) {
  case HobbyStatus.saved:
    return 5;
  case HobbyStatus.trying:
  case HobbyStatus.active:
  case HobbyStatus.paused:   // NEW
    return 5;
  case HobbyStatus.done:
    return 2;
}
```

**`lib/core/notifications/notification_scheduler.dart:77`** — paused hobby gets no notifications (frozen):
```dart
case HobbyStatus.done:
case HobbyStatus.paused:   // NEW — no reminders while paused
  break;
```

### Pattern 6: Mapper Update

**What:** `mapUserHobby` in `server/lib/mappers.ts` currently omits `completedAt`, `pausedAt`, and `pausedDurationDays`. The `PrismaUserHobby` type and the mapper function need these fields.

```typescript
type PrismaUserHobby = {
  userId: string;
  hobbyId: string;
  status: string;
  startedAt: Date | null;
  completedAt: Date | null;
  lastActivityAt: Date | null;
  streakDays: number;
  pausedAt: Date | null;          // NEW
  pausedDurationDays: number;     // NEW
  completedSteps: { stepId: string }[];
};

export function mapUserHobby(uh: PrismaUserHobby) {
  return {
    hobbyId: uh.hobbyId,
    status: uh.status,
    completedStepIds: uh.completedSteps.map((s) => s.stepId),
    startedAt: uh.startedAt?.toISOString() ?? null,
    completedAt: uh.completedAt?.toISOString() ?? null,  // expose for Phase 12
    lastActivityAt: uh.lastActivityAt?.toISOString() ?? null,
    streakDays: uh.streakDays,
    pausedAt: uh.pausedAt?.toISOString() ?? null,        // NEW
    pausedDurationDays: uh.pausedDurationDays,            // NEW
  };
}
```

**Note:** `completedAt` was in `PrismaUserHobby` type but was never returned by `mapUserHobby`. Expose it now — Phase 12 needs it for the Tried section completion date.

### Anti-Patterns to Avoid

- **Single migration for enum + usage:** Adding `paused` enum AND using it in the same `.sql` file triggers 55P04 on Neon. Always separate enum DDL from usage DDL into two files.
- **Non-transactional completion check:** Checking step count outside the step create transaction can lead to race conditions where two simultaneous step completions both see count = totalSteps - 1 and both set `done`. The transaction isolation prevents this.
- **Running build_runner after switching sites are updated:** Update `hobby.dart` first, run `build_runner`, then fix the switch sites. If you update switch sites before `build_runner` runs, the IDE shows false errors. The correct order is: edit enum → regenerate → fix switches.
- **Modifying migration lock or migration history files:** Never edit `migration_lock.toml` or existing migration `.sql` files; Prisma validates checksums.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Atomic step toggle + completion check | Manual try/catch with sequential queries | `prisma.$transaction(async (tx) => {...})` | Prisma interactive transactions provide rollback on any throw; sequential queries can leave partial state |
| Enum exhaustiveness enforcement | Manual `default` case throwing | Dart 3 exhaustive switch (no default) | Compiler enforces it; adding `default` would suppress future missing-case errors |
| Dart model JSON serialization | Manual `fromJson`/`toJson` for new fields | Freezed + `build_runner` | Generated code handles null safety, nested objects, default values correctly |

**Key insight:** The entire safety net for this phase is the Dart compiler's exhaustive switch check and Prisma's transaction rollback. Don't add `default` cases to switches and don't add fallback logic outside transactions.

---

## Common Pitfalls

### Pitfall 1: PostgreSQL Error 55P04

**What goes wrong:** Prisma auto-generates a migration that adds `paused` to the enum and immediately uses it (e.g., as a column default). On Neon (PostgreSQL), this fails with `New enum values must be committed before they can be used` (error 55P04).

**Why it happens:** PostgreSQL requires enum additions to be committed in their own transaction before being referenced. Prisma puts everything in one migration file.

**How to avoid:** Always separate the `ALTER TYPE ADD VALUE` into its own migration file. Do not add any `ALTER TABLE` usage of `paused` in the same file. For Phase 11, `paused` is not a default value anywhere, but the principle still applies.

**Warning signs:** `prisma migrate dev` fails with error code 55P04 or message containing "unsafe use of new value of enum type".

### Pitfall 2: Incomplete `include` in Transaction

**What goes wrong:** After updating `UserHobby` status to `done` inside the transaction, the final `findUnique` does not include `completedSteps: { select: { stepId: true } }`. The returned `hobby` has no `completedSteps` array, causing `mapUserHobby` to throw.

**Why it happens:** The `include` clause was present in the old non-transactional code but easy to forget when rewriting.

**How to avoid:** The final `tx.userHobby.findUnique` inside the transaction must always include `{ completedSteps: { select: { stepId: true } } }`.

**Warning signs:** `mapUserHobby` throws `Cannot read properties of undefined (reading 'map')` at `uh.completedSteps.map(...)`.

### Pitfall 3: Dart Build Runner Stale Output

**What goes wrong:** After adding `paused` and the two new fields to `UserHobby`, `build_runner` is not re-run. The `.g.dart` file still contains the old `fromJson` without `pausedAt`/`pausedDurationDays`, causing silent null values at runtime.

**Why it happens:** The generated files (`hobby.freezed.dart`, `hobby.g.dart`) are not automatically kept in sync during development.

**How to avoid:** Run `dart run build_runner build --delete-conflicting-outputs` immediately after any change to `hobby.dart`. Verify the output files changed with `git diff`.

**Warning signs:** `pausedAt` is always null even when the server sends a value; no compile error because the field is nullable.

### Pitfall 4: Missing `paused` in `canStartHobbyProvider`

**What goes wrong:** `canStartHobbyProvider` in `user_provider.dart:340` filters for `trying || active`. A `paused` hobby is neither, so Free users with a paused hobby are incorrectly allowed to start a second one.

**Why it happens:** The filter was written before `paused` existed.

**How to avoid:** Update `canStartHobbyProvider` to include `paused` in the "counts as active" check. Phase 11 must patch this even though pause UI is in Phase 14.

```dart
final activeEntries = hobbies.entries.where(
  (e) => e.value.status == HobbyStatus.trying ||
         e.value.status == HobbyStatus.active ||
         e.value.status == HobbyStatus.paused,  // ADD
);
```

**Warning signs:** Free user with a paused hobby can start a fresh hobby during Phase 14 testing.

### Pitfall 5: `done` vs `stopped` Distinction

**What goes wrong:** Using a single `done` status for both "all steps complete" and "user quit" makes Phase 12 celebratory UI undistinguishable from stop confirmation UI. However, adding `stopped` to the enum creates a 5-value enum with 3 more switch arms across all sites.

**Recommendation (Claude's Discretion resolved):** Use `done` for both, distinguish by `completedAt`:
- `completedAt != null` = all steps complete (celebrate)
- `completedAt == null` = user stopped manually (no celebration)

This avoids a third enum value and leverages the already-existing `completedAt` field. The server sets `completedAt = now()` only on auto-completion (SCHM-03). Manual stop (Phase 12) sets `status = done` without setting `completedAt`.

**Warning signs:** Phase 12 builder tries to add `stopped` enum and triggers another two-file migration.

### Pitfall 6: Step Un-toggle After Auto-Completion

**What goes wrong:** User completes last step → hobby becomes `done`. User then un-toggles a step. Should the hobby revert to `active`?

**Decision needed for SCHM-03 implementation:** The step toggle handler should not auto-revert status on un-toggle. Once `done`, status stays `done` — the un-toggle only updates `completedSteps`. This is consistent with "completion is permanent in v1.1 (no restart)".

**How to handle:** In the completion check block, only run the completion check when `!existing` (step being added). When `existing` (step being removed), skip the check entirely.

---

## Code Examples

### Migration File 1 — Enum Extension

```sql
-- Migration name: add_paused_to_hobby_status
-- Source: Prisma #8424 two-step pattern

ALTER TYPE "HobbyStatus" ADD VALUE 'paused';
```

### Migration File 2 — Pause Fields

```sql
-- Migration name: add_pause_fields_to_user_hobby

ALTER TABLE "UserHobby" ADD COLUMN "pausedAt" TIMESTAMP(3);
ALTER TABLE "UserHobby" ADD COLUMN "pausedDurationDays" INTEGER NOT NULL DEFAULT 0;
```

### Prisma Schema Diff

```prisma
// server/prisma/schema.prisma

enum HobbyStatus {
  saved
  trying
  active
  paused    // ADD
  done
}

model UserHobby {
  id                 String      @id @default(uuid())
  userId             String
  hobbyId            String
  status             HobbyStatus @default(saved)
  startedAt          DateTime?
  completedAt        DateTime?
  lastActivityAt     DateTime?
  streakDays         Int         @default(0)
  pausedAt           DateTime?              // ADD
  pausedDurationDays Int         @default(0) // ADD
  createdAt          DateTime    @default(now())
  updatedAt          DateTime    @updatedAt

  user           User        @relation(fields: [userId], references: [id], onDelete: Cascade)
  completedSteps UserCompletedStep[]

  @@unique([userId, hobbyId])
}
```

### Step Completion Endpoint (SCHM-03 core change)

```typescript
// server/api/users/[path].ts — step toggle POST handler
// Source: handleHobbyDetail function, line ~342

if (req.method === "POST" && stepId) {
  const result = await prisma.$transaction(async (tx) => {
    await tx.userHobby.upsert({
      where: { userId_hobbyId: { userId, hobbyId } },
      create: { userId, hobbyId, status: "trying", lastActivityAt: new Date() },
      update: { lastActivityAt: new Date() },
    });

    const existing = await tx.userCompletedStep.findUnique({
      where: { userId_hobbyId_stepId: { userId, hobbyId, stepId } },
    });

    if (existing) {
      await tx.userCompletedStep.delete({ where: { id: existing.id } });
    } else {
      await tx.userCompletedStep.create({ data: { userId, hobbyId, stepId } });
    }

    let hobbyCompleted = false;
    if (!existing) {
      const [completedCount, totalSteps] = await Promise.all([
        tx.userCompletedStep.count({ where: { userId, hobbyId } }),
        tx.roadmapStep.count({ where: { hobbyId } }),
      ]);
      if (totalSteps > 0 && completedCount >= totalSteps) {
        await tx.userHobby.update({
          where: { userId_hobbyId: { userId, hobbyId } },
          data: { status: "done", completedAt: new Date() },
        });
        hobbyCompleted = true;
      }
    }

    const updatedHobby = await tx.userHobby.findUnique({
      where: { userId_hobbyId: { userId, hobbyId } },
      include: { completedSteps: { select: { stepId: true } } },
    });

    return { hobby: updatedHobby!, hobbyCompleted };
  });

  // Outside transaction — non-critical
  await prisma.userActivityLog.create({
    data: { userId, hobbyId, action: existing ? "step_uncomplete" : "step_complete" },
  });
  if (!existing) await checkChallengeProgress(userId, "step_complete");

  res.status(200).json({ ...mapUserHobby(result.hobby), hobbyCompleted: result.hobbyCompleted });
  return;
}
```

**Note:** `existing` must be captured before the transaction to use in the activity log and challenge check outside.

### Dart Enum + Model

```dart
// lib/models/hobby.dart

enum HobbyStatus { saved, trying, active, paused, done }  // ADD paused

@freezed
class UserHobby with _$UserHobby {
  const UserHobby._();

  const factory UserHobby({
    required String hobbyId,
    required HobbyStatus status,
    @SetStringConverter() @Default(<String>{}) Set<String> completedStepIds,
    DateTime? startedAt,
    DateTime? completedAt,             // ADD — needed by Phase 12
    DateTime? lastActivityAt,
    DateTime? pausedAt,                // ADD
    @Default(0) int pausedDurationDays, // ADD
    @Default(0) int streakDays,
  }) = _UserHobby;

  factory UserHobby.fromJson(Map<String, dynamic> json) =>
      _$UserHobbyFromJson(json);
}
```

---

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Single migration for enum + usage | Two-step migration (Prisma #8424) | Ongoing known issue | Always split enum DDL from usage DDL |
| `prisma.userHobby.update` + sequential queries | `prisma.$transaction(async tx => {...})` | Prisma 2.10+ | Interactive transactions prevent partial state |
| Dart 2 switch with `default` | Dart 3 exhaustive switch (no default needed) | Dart 3.0 | Compiler enforces all enum arms — safe migration guard |

---

## Open Questions

1. **`existing` variable scope in refactored handler**
   - What we know: The completion check uses `!existing` to decide whether to auto-complete. The activity log outside the transaction also uses `existing` (to determine "step_complete" vs "step_uncomplete"). This variable must be captured before entering the transaction.
   - What's unclear: Whether to capture `existing` with a pre-transaction query or restructure the return from `$transaction` to also return the `existing` value.
   - Recommendation: Return `existing` from the transaction result (`return { hobby, hobbyCompleted, wasNew: !existing }`) and use `wasNew` for the activity log and challenge check outside.

2. **`completedAt` in `UserHobby` Dart model**
   - What we know: The field exists in Prisma (`UserHobby.completedAt`) and in `PrismaUserHobby` type. It is not currently in the Dart `UserHobby` Freezed model. The mapper does not expose it. Phase 12 needs it.
   - What's unclear: Should Phase 11 add `completedAt` to the Dart model now (forward compatibility) or defer to Phase 12?
   - Recommendation: Add it in Phase 11. The mapper will expose it, and the Dart model will accept it. Adding it later requires another `build_runner` run in Phase 12 for a trivial change. Low risk to add now.

---

## Validation Architecture

### Test Framework

| Property | Value |
|----------|-------|
| Framework | Vitest 3.0.0 |
| Config file | none — inlined in `package.json` scripts |
| Quick run command | `cd C:/dev/trysomething/server && npm test` |
| Full suite command | `cd C:/dev/trysomething/server && npm test` |
| Dart analysis | `dart analyze lib/models/hobby.dart lib/providers/user_provider.dart lib/screens/you/you_screen.dart lib/screens/coach/hobby_coach_screen.dart lib/core/notifications/notification_scheduler.dart` |

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| SCHM-01 | `paused` is a valid `HobbyStatus` value; `UserHobby.fromJson({'status': 'paused'})` parses without error | unit | `cd server && npm test -- mappers` | ❌ Wave 0: add to `mappers.test.ts` |
| SCHM-01 | Dart `HobbyStatus.paused` compiles and all switch arms are exhaustive | compile-time | `dart analyze lib/models/hobby.dart` | ✅ (analysis, not a test file) |
| SCHM-02 | `mapUserHobby` includes `pausedAt` and `pausedDurationDays` in output | unit | `cd server && npm test -- mappers` | ❌ Wave 0: add to `mappers.test.ts` |
| SCHM-03 | Step toggle returns `hobbyCompleted: true` when completedCount === totalSteps | unit (mock Prisma) | `cd server && npm test -- routes_users` | ❌ Wave 0: add to `routes_users.test.ts` or new file |
| SCHM-03 | Step toggle returns `hobbyCompleted: false` when steps remain | unit (mock Prisma) | `cd server && npm test -- routes_users` | ❌ Wave 0 |
| SCHM-03 | Un-toggling a step does not revert `done` status | unit (mock Prisma) | `cd server && npm test -- routes_users` | ❌ Wave 0 |

### Sampling Rate

- **Per task commit:** `cd C:/dev/trysomething/server && npm test`
- **Per wave merge:** `cd C:/dev/trysomething/server && npm test` + `dart analyze lib/`
- **Phase gate:** Full suite green + `dart analyze lib/` clean before `/gsd:verify-work`

### Wave 0 Gaps

- [ ] `server/test/mappers.test.ts` — add `mapUserHobby` tests for `paused` status, `pausedAt`, `pausedDurationDays` fields
- [ ] `server/test/routes_users.test.ts` OR `server/test/step_completion.test.ts` — add step completion detection tests (hobbyCompleted flag, transaction behavior)
- [ ] No framework install needed — Vitest 3.0.0 already present

---

## Sources

### Primary (HIGH confidence)

- Codebase direct read — `server/prisma/schema.prisma` (confirmed current `HobbyStatus` enum, `UserHobby` model fields, existing migration history)
- Codebase direct read — `server/api/users/[path].ts:342–380` (confirmed step toggle handler structure, non-transactional current implementation)
- Codebase direct read — `lib/models/hobby.dart` (confirmed Dart `HobbyStatus` enum, `UserHobby` Freezed class, missing `completedAt`/`pausedAt` fields)
- Codebase direct read — `lib/providers/user_provider.dart` (confirmed `setDone`, `toggleStep`, `canStartHobbyProvider` patterns)
- Codebase direct read — switch sites: `you_screen.dart:70`, `hobby_coach_screen.dart:94`, `notification_scheduler.dart:77`
- Codebase direct read — `server/prisma/migrations/20260302104218_add_user_progress_models/migration.sql` (confirmed PostgreSQL provider, original `HobbyStatus` DDL)

### Secondary (MEDIUM confidence)

- [Prisma issue #8424](https://github.com/prisma/prisma/issues/8424) — confirmed two-step migration workaround for 55P04 (PostgreSQL enum + usage in single migration); issue is open and ongoing as of 2025

### Tertiary (LOW confidence)

- None

---

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — all tools already in use in the project; versions confirmed from package.json and pubspec
- Architecture: HIGH — all patterns derived from direct codebase reading; no assumptions needed
- Pitfalls: HIGH for enum migration (confirmed issue #8424 + Prisma behavior) and MEDIUM for switch exhaustiveness (confirmed Dart 3 compiler behavior from codebase structure)

**Research date:** 2026-03-23
**Valid until:** 2026-04-23 (Prisma 6.x stable; Dart 3.x exhaustive switch stable)
