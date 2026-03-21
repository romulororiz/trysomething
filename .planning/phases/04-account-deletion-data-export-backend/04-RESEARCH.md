# Phase 4: Account Deletion + Data Export -- Backend - Research

**Researched:** 2026-03-21
**Domain:** Prisma soft-delete, cascading transactions, Vercel Cron Jobs, FADP/GDPR data export
**Confidence:** HIGH

## Summary

This phase adds two new server endpoints (`DELETE /api/users/me` and `GET /api/users/me/export`) and a daily Vercel Cron Job for hard-purging soft-deleted users. The codebase is well-structured for this work: all 13 user-related tables already have `onDelete: Cascade` in the Prisma schema, so a single `prisma.user.delete()` would cascade automatically. However, the user decision specifies a **soft-delete** approach (`deletedAt` field + 30-day retention), which means we set `deletedAt` on the User row and rely on auth middleware to reject deleted users immediately, then a cron job hard-deletes after 30 days.

The one exception is `GenerationLog` -- it stores `userId` as a plain string with no foreign key relation to User. It must be explicitly deleted in the hard-purge transaction. All other tables (`UserPreference`, `UserHobby`, `UserCompletedStep`, `UserActivityLog`, `JournalEntry`, `PersonalNote`, `ScheduleEvent`, `ShoppingCheck`, `CommunityStory`, `StoryReaction`, `BuddyPair`, `UserChallenge`, `UserAchievement`) have `onDelete: Cascade` and will be automatically deleted when the User row is finally hard-deleted.

**Primary recommendation:** Add `deletedAt DateTime?` to the User model, modify `requireAuth()` to check for soft-deleted users, implement the DELETE endpoint with password verification, implement the export endpoint with field exclusion, create a cron handler for daily hard-purge, and add a cron schedule to `vercel.json`.

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| COMP-01 | Account deletion endpoint (`DELETE /api/users/me`) | Soft-delete pattern with `deletedAt` field; password verification via existing `comparePassword()`; immediate lockout via auth middleware check |
| COMP-02 | Cascading data removal across all user tables | 13 tables have `onDelete: Cascade` in Prisma schema; `GenerationLog` needs explicit `deleteMany` in hard-purge transaction |
| COMP-03 | 30-day retention before hard purge | `deletedAt DateTime?` on User model; Vercel Cron Job at 3 AM UTC daily; `purgeAt` = deletedAt + 30 days |
| COMP-06 | Data export endpoint (`GET /api/users/me/export`) | JSON attachment with `Content-Disposition` header; exclude `passwordHash`, `revenuecatId`, `appleId`, `googleId`, `GenerationLog` internals |
| COMP-07 | Export must include all personal data | Query all 14 user-related tables with includes; structure as nested JSON object |
| COMP-08 | Export must exclude sensitive/internal fields | Use selective field mapping (not raw Prisma output); explicit exclusion list |
</phase_requirements>

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| @prisma/client | 6.4.1 | Database ORM, transactions, schema migration | Already in use; `$transaction` for atomic hard-purge |
| @vercel/node | 5.0.2 | Serverless function runtime | Already in use; cron handler is same pattern |
| bcryptjs | 2.4.3 | Password verification for DELETE | Already in use via `comparePassword()` |
| jsonwebtoken | 9.0.2 | JWT verification in auth middleware | Already in use; no changes to library needed |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| prisma (CLI) | 6.4.1 | Schema migration for `deletedAt` field | One migration to add `deletedAt DateTime?` to User |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Manual soft-delete check in `requireAuth()` | Prisma Client Extension for soft delete | Extension adds complexity; only one model needs soft-delete; manual check is 3 lines |
| Vercel Cron for hard-purge | External scheduler (e.g., cron-job.org) | Vercel Cron is built-in, no external dependency; Hobby plan limits to once/day which is fine for this use case |
| Sequential `$transaction([])` for hard-purge | Interactive `$transaction(async (tx) => {})` | Sequential array is simpler since all operations are independent deletes; no conditional logic needed |

**Installation:**
```bash
# No new packages needed -- everything is already installed
cd server && npx prisma migrate dev --name add_user_deleted_at
```

## Architecture Patterns

### Recommended File Structure
```
server/
├── api/
│   ├── cron/
│   │   └── purge-deleted-users.ts    # NEW: Cron handler for daily hard-purge
│   └── users/
│       └── [path].ts                 # MODIFY: Add DELETE to handleMe, add "export" case
├── lib/
│   ├── auth.ts                       # MODIFY: Add deletedAt check to requireAuth()
│   └── db.ts                         # No changes
├── prisma/
│   └── schema.prisma                 # MODIFY: Add deletedAt field to User model
└── vercel.json                       # MODIFY: Add crons config + cron route
```

### Pattern 1: Soft-Delete via Auth Middleware Guard
**What:** Add `deletedAt` check directly in `requireAuth()` so every authenticated endpoint automatically rejects deleted users.
**When to use:** When only one model needs soft-delete and all endpoints already go through `requireAuth()`.
**Example:**
```typescript
// server/lib/auth.ts -- modified requireAuth()
export async function requireAuth(
  req: VercelRequest,
  res: VercelResponse
): Promise<string | null> {
  const header = req.headers.authorization;
  if (!header || !header.startsWith("Bearer ")) {
    errorResponse(res, 401, "Missing or invalid authorization header");
    return null;
  }
  try {
    const { sub } = verifyAccessToken(header.slice(7));

    // Check if user is soft-deleted
    const user = await prisma.user.findUnique({
      where: { id: sub },
      select: { deletedAt: true },
    });
    if (!user || user.deletedAt) {
      errorResponse(res, 401, "Invalid or expired token");
      return null;
    }

    return sub;
  } catch {
    errorResponse(res, 401, "Invalid or expired token");
    return null;
  }
}
```

**CRITICAL NOTE:** This adds a DB query to every authenticated request. Currently `requireAuth()` is pure JWT verification (no DB call). This is a deliberate tradeoff: it catches deleted users immediately but adds ~5-10ms latency per request. An alternative is to only check `deletedAt` on the refresh endpoint and let access tokens (15-min TTL) expire naturally. However, the user decision explicitly requires "immediate lockout," so the DB check is necessary.

**Performance mitigation:** The query uses `select: { deletedAt: true }` to fetch only one boolean-sized field, and the `id` column is the primary key, so this is an index-only lookup.

### Pattern 2: Cron Handler with CRON_SECRET Verification
**What:** A standalone serverless function that verifies `CRON_SECRET` and hard-deletes users whose `deletedAt` is older than 30 days.
**When to use:** For the daily purge job.
**Example:**
```typescript
// server/api/cron/purge-deleted-users.ts
import type { VercelRequest, VercelResponse } from "@vercel/node";
import { prisma } from "../../lib/db";

export default async function handler(
  req: VercelRequest,
  res: VercelResponse
): Promise<void> {
  // Verify CRON_SECRET
  const authHeader = req.headers.authorization;
  if (
    !process.env.CRON_SECRET ||
    authHeader !== `Bearer ${process.env.CRON_SECRET}`
  ) {
    res.status(401).json({ error: "Unauthorized" });
    return;
  }

  const cutoff = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);

  const usersToDelete = await prisma.user.findMany({
    where: { deletedAt: { lte: cutoff } },
    select: { id: true },
  });

  if (usersToDelete.length === 0) {
    res.status(200).json({ purged: 0 });
    return;
  }

  const userIds = usersToDelete.map((u) => u.id);

  // Hard delete: GenerationLog first (no FK), then User (cascades the rest)
  await prisma.$transaction([
    prisma.generationLog.deleteMany({ where: { userId: { in: userIds } } }),
    prisma.user.deleteMany({ where: { id: { in: userIds } } }),
  ]);

  res.status(200).json({ purged: userIds.length });
}
```

### Pattern 3: Data Export with Selective Field Mapping
**What:** Query all user-related data and return a sanitized JSON object excluding sensitive fields.
**When to use:** For the `GET /api/users/me/export` endpoint.
**Example:**
```typescript
// Inside handleExport() in [path].ts
const user = await prisma.user.findUnique({
  where: { id: userId },
  include: {
    preferences: true,
    hobbies: { include: { completedSteps: true } },
    activityLogs: true,
    journalEntries: true,
    personalNotes: true,
    scheduleEvents: true,
    shoppingChecks: true,
    communityStories: { include: { reactions: true } },
    storyReactions: true,
    buddyRequestsSent: true,
    buddyRequestsRcvd: true,
    challenges: true,
    achievements: true,
  },
});

// Build export object excluding sensitive fields
const exportData = {
  account: {
    id: user.id,
    email: user.email,
    displayName: user.displayName,
    bio: user.bio,
    avatarUrl: user.avatarUrl,
    subscriptionTier: user.subscriptionTier,
    createdAt: user.createdAt.toISOString(),
    updatedAt: user.updatedAt.toISOString(),
  },
  preferences: user.preferences ? { /* mapped fields */ } : null,
  hobbies: user.hobbies.map(/* ... */),
  // ... all other data sections
  exportedAt: new Date().toISOString(),
};

res.setHeader("Content-Type", "application/json");
res.setHeader("Content-Disposition", "attachment; filename=trysomething-export.json");
res.status(200).json(exportData);
```

### Anti-Patterns to Avoid
- **Using Prisma middleware/extension for soft-delete:** Overkill for one model. Manual check is clearer and more maintainable for a single-model soft-delete.
- **Deleting child tables manually when `onDelete: Cascade` exists:** The schema already handles cascading for all user-related tables (except `GenerationLog`). Do NOT write 13 separate `deleteMany` calls in the hard-purge transaction.
- **Returning raw Prisma objects in the export:** Always map through a sanitization function. Raw objects may include `passwordHash`, internal IDs, etc.
- **Skipping password verification on DELETE for OAuth users:** OAuth users have `passwordHash: ""`. The endpoint must handle this: either require re-authentication via OAuth token, or allow deletion without password for OAuth-only accounts. Decision from CONTEXT.md: password required in DELETE body, verified with bcrypt. For OAuth-only users (empty passwordHash), skip password check or accept any string.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Password hashing/comparison | Custom bcrypt wrapper | Existing `comparePassword()` in `server/lib/auth.ts` | Already battle-tested in the codebase |
| Transaction management | Manual BEGIN/COMMIT/ROLLBACK | `prisma.$transaction([])` | Handles rollback automatically on any failure |
| Cron scheduling | Custom timer or external service | Vercel Cron Jobs (`vercel.json` crons property) | Native integration, no external deps, CRON_SECRET built in |
| Date arithmetic for purge cutoff | Manual millisecond math | `new Date(Date.now() - 30 * 24 * 60 * 60 * 1000)` | Simple enough that a library is unnecessary |

**Key insight:** This phase is almost entirely wiring -- connecting existing Prisma models, existing auth utilities, and existing middleware patterns. The only genuinely new code is the export serializer and the cron handler.

## Common Pitfalls

### Pitfall 1: requireAuth() Now Makes a DB Call
**What goes wrong:** Adding a DB query to `requireAuth()` changes it from a pure synchronous JWT check to an async operation. Every authenticated endpoint now hits the database on every request.
**Why it happens:** The user decision requires immediate lockout after deletion. A JWT is stateless and cannot be revoked.
**How to avoid:** Use `select: { deletedAt: true }` to minimize the query cost. The User.id primary key lookup is an index scan. Consider adding a short TTL cache if performance becomes an issue (but don't pre-optimize).
**Warning signs:** Increased p95 latency on all authenticated endpoints after deployment.

### Pitfall 2: requireAuth() Signature Change Breaks All Callers
**What goes wrong:** If `requireAuth()` becomes async (returns `Promise<string | null>` instead of `string | null`), every call site in `[path].ts` and other files must add `await`. Missing an `await` silently returns a Promise object (truthy) instead of the userId string.
**Why it happens:** The current signature is synchronous. Adding a Prisma query makes it async.
**How to avoid:** Update ALL call sites. Search for `requireAuth(` across the codebase. There are calls in `[path].ts` (every handler) and potentially in `generate/[action].ts`.
**Warning signs:** TypeScript may not catch this if the return type is `string | null` and the caller doesn't check the type. Test by calling DELETE after deletion.

### Pitfall 3: OAuth Users Cannot Provide a Password
**What goes wrong:** Google/Apple OAuth users have `passwordHash: ""`. Calling `bcrypt.compare(password, "")` returns false, blocking OAuth users from deleting their accounts.
**Why it happens:** OAuth users were created with `passwordHash: ""` (empty string) since they authenticate via token exchange, not passwords.
**How to avoid:** Check if `passwordHash` is empty/falsy before attempting comparison. If the user has no password (OAuth-only), skip password verification. Alternatively, require OAuth re-authentication, but that adds significant complexity.
**Warning signs:** OAuth users get 403 "Invalid password" when trying to delete.

### Pitfall 4: GenerationLog Has No Foreign Key
**What goes wrong:** After hard-deleting a User, orphaned `GenerationLog` rows remain in the database because there is no `onDelete: Cascade` relation.
**Why it happens:** The `GenerationLog` model stores `userId` as a plain string with an index but no `@relation` directive pointing to the User model.
**How to avoid:** In the hard-purge transaction, delete `GenerationLog` rows BEFORE deleting the User: `prisma.generationLog.deleteMany({ where: { userId: { in: userIds } } })`.
**Warning signs:** Growing number of orphaned rows in GenerationLog table over time.

### Pitfall 5: BuddyPair Has Two User Relations
**What goes wrong:** `BuddyPair` references users via both `requesterId` and `accepterId`. When User A is deleted, cascading removes pairs where A is requester OR accepter, which is correct. But the export must include both directions.
**Why it happens:** The relation is modeled as two separate FKs, both with `onDelete: Cascade`.
**How to avoid:** In the export, include both `buddyRequestsSent` and `buddyRequestsRcvd`. In deletion, no special handling needed -- Prisma cascade handles both relations.
**Warning signs:** Incomplete buddy data in export.

### Pitfall 6: Vercel Hobby Plan Cron Limitations
**What goes wrong:** On the Hobby plan, cron jobs can only run once per day and timing is imprecise (could execute anywhere within the specified hour).
**Why it happens:** Vercel limits Hobby plan cron precision.
**How to avoid:** The daily purge at 3 AM UTC is fine for Hobby plan (once/day is sufficient). Make the handler idempotent -- running twice should be safe since `deleteMany` on already-deleted rows is a no-op.
**Warning signs:** Deployment fails with "Hobby accounts are limited to daily cron jobs" if the expression runs more frequently.

### Pitfall 7: Vercel Cron Uses GET, Not POST
**What goes wrong:** Cron handler receives GET requests but is coded to only accept POST.
**Why it happens:** Vercel cron always sends HTTP GET requests to the configured path.
**How to avoid:** The cron handler must accept GET (or at minimum, not reject it with methodNotAllowed).
**Warning signs:** Cron job returns 405 Method Not Allowed in logs.

### Pitfall 8: VercelRequest Headers Access Pattern
**What goes wrong:** Using `request.headers.get('authorization')` (Web API style) instead of `req.headers.authorization` (Node.js IncomingMessage style).
**Why it happens:** Vercel docs show the Web API `.get()` pattern for Next.js App Router, but this project uses `@vercel/node` with Node.js-style headers.
**How to avoid:** Follow existing codebase convention: `req.headers.authorization` (property access, not method call).
**Warning signs:** `TypeError: req.headers.get is not a function` at runtime.

## Code Examples

### Schema Migration: Add deletedAt to User
```prisma
// server/prisma/schema.prisma -- User model modification
model User {
  id           String          @id @default(uuid())
  email        String          @unique
  passwordHash String
  displayName  String
  bio          String          @default("")
  avatarUrl    String?
  googleId     String?         @unique
  appleId      String?         @unique
  deletedAt    DateTime?       // NEW: soft-delete timestamp, null = active
  createdAt    DateTime        @default(now())
  updatedAt    DateTime        @updatedAt

  // ... rest unchanged
}
```

### DELETE Endpoint Handler
```typescript
// Inside handleMe() in [path].ts -- add DELETE method
async function handleMe(
  req: VercelRequest,
  res: VercelResponse
): Promise<void> {
  if (methodNotAllowed(req, res, ["GET", "PUT", "DELETE"])) return;

  const userId = await requireAuth(req, res);
  if (!userId) return;

  try {
    if (req.method === "DELETE") {
      const { password } = req.body ?? {};
      const user = await prisma.user.findUnique({
        where: { id: userId },
        select: { passwordHash: true },
      });

      if (!user) {
        errorResponse(res, 404, "User not found");
        return;
      }

      // Verify password (skip for OAuth-only users with empty passwordHash)
      if (user.passwordHash) {
        if (!password) {
          errorResponse(res, 400, "Password is required");
          return;
        }
        const valid = await comparePassword(password, user.passwordHash);
        if (!valid) {
          errorResponse(res, 403, "Invalid password");
          return;
        }
      }

      const now = new Date();
      const purgeAt = new Date(now.getTime() + 30 * 24 * 60 * 60 * 1000);

      await prisma.user.update({
        where: { id: userId },
        data: { deletedAt: now },
      });

      res.status(200).json({
        status: "deleted",
        deletedAt: now.toISOString(),
        purgeAt: purgeAt.toISOString(),
      });
    } else if (req.method === "GET") {
      // ... existing GET logic
    } else {
      // ... existing PUT logic
    }
  } catch (err) {
    console.error(`${req.method} /api/users/me error:`, err);
    errorResponse(res, 500, "Failed to process user request");
  }
}
```

### vercel.json Cron Configuration
```json
{
  "crons": [
    {
      "path": "/api/cron/purge-deleted-users",
      "schedule": "0 3 * * *"
    }
  ]
}
```

### vercel.json Route Addition
```json
{
  "src": "/api/cron/purge-deleted-users",
  "dest": "/api/cron/purge-deleted-users.ts"
}
```

### Export Endpoint: Content-Disposition Headers
```typescript
res.setHeader("Content-Type", "application/json");
res.setHeader(
  "Content-Disposition",
  "attachment; filename=trysomething-export.json"
);
res.status(200).json(exportData);
```

### Fields to EXCLUDE from Export
```typescript
// These fields must NEVER appear in the export JSON:
const EXCLUDED_USER_FIELDS = [
  "passwordHash",  // Security: password hash
  "revenuecatId",  // Internal: RevenueCat identifier
  "googleId",      // Internal: Google OAuth ID
  "appleId",       // Internal: Apple OAuth ID
];

// GenerationLog is excluded entirely (internal AI audit trail)
// StoryReaction internal IDs excluded (only include type + storyId)
```

### Complete User-Related Table Inventory (14 tables)
```
Tables WITH onDelete: Cascade (auto-deleted on User hard-delete):
  1. UserPreference     (userId FK)
  2. UserHobby          (userId FK)
  3. UserCompletedStep  (via UserHobby cascade)
  4. UserActivityLog    (userId FK)
  5. JournalEntry       (userId FK)
  6. PersonalNote       (userId FK)
  7. ScheduleEvent      (userId FK)
  8. ShoppingCheck      (userId FK)
  9. CommunityStory     (userId FK)
 10. StoryReaction      (userId FK)
 11. BuddyPair          (requesterId FK + accepterId FK, both cascade)
 12. UserChallenge      (userId FK)
 13. UserAchievement    (userId FK)

Tables WITHOUT cascade (needs explicit deletion):
 14. GenerationLog      (userId string, no @relation, no FK)
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Prisma middleware for soft-delete | Prisma Client Extensions (`$extends`) | Prisma 5.2.2+ (2023) | Middleware deprecated; extensions are the official approach |
| Hard-delete only | Soft-delete with retention period | Regulatory requirement | FADP/GDPR require data portability; soft-delete allows recovery window |
| No cron in Vercel | `vercel.json` `crons` property | Vercel 2023 | Native cron support, no external scheduler needed |

**Deprecated/outdated:**
- `prisma.$use()` middleware: Deprecated since Prisma 5.2.2. Use `$extends` for client-level interceptors. However, for this phase, neither is needed -- a manual check in `requireAuth()` is simpler.

## Open Questions

1. **OAuth user deletion without password**
   - What we know: OAuth users have `passwordHash: ""`. The CONTEXT.md decision says "password required in DELETE body."
   - What's unclear: Should OAuth-only users be allowed to delete without a password, or should they re-authenticate via their OAuth provider?
   - Recommendation: Allow deletion without password check when `passwordHash` is empty (OAuth-only accounts). This is the simplest secure approach. The user is already authenticated via JWT.

2. **Photo URL cleanup on deletion**
   - What we know: `JournalEntry` can have `photoUrl` pointing to uploaded images. User `avatarUrl` may also reference uploaded files.
   - What's unclear: Are photos stored on a third-party service (e.g., Cloudinary, S3)? If so, soft-deleting the user does not delete the actual image files.
   - Recommendation: Out of scope for this phase. Photo storage cleanup can be added to the hard-purge cron in a future phase if needed.

3. **Rate limiting the export endpoint**
   - What we know: The export endpoint queries 14 tables. A malicious user could repeatedly request exports to strain the database.
   - What's unclear: Is there existing rate limiting beyond the AI generation 20/day limit?
   - Recommendation: Consider adding a simple rate limit (e.g., 1 export per hour) but this is low priority -- the endpoint requires authentication.

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | Vitest 3.0.0 |
| Config file | None detected (uses vitest defaults via package.json) |
| Quick run command | `cd server && npx vitest run test/routes_users.test.ts` |
| Full suite command | `cd server && npm test` |

### Phase Requirements to Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| COMP-01 | DELETE /api/users/me soft-deletes user with password | unit | `cd server && npx vitest run test/deletion.test.ts -t "soft delete"` | No -- Wave 0 |
| COMP-01 | DELETE rejects invalid password with 403 | unit | `cd server && npx vitest run test/deletion.test.ts -t "invalid password"` | No -- Wave 0 |
| COMP-01 | DELETE handles OAuth users (empty passwordHash) | unit | `cd server && npx vitest run test/deletion.test.ts -t "oauth"` | No -- Wave 0 |
| COMP-02 | Hard-purge deletes GenerationLog + User atomically | unit | `cd server && npx vitest run test/cron-purge.test.ts -t "hard purge"` | No -- Wave 0 |
| COMP-03 | Auth middleware rejects soft-deleted user with 401 | unit | `cd server && npx vitest run test/deletion.test.ts -t "deleted user rejected"` | No -- Wave 0 |
| COMP-03 | Cron purges users older than 30 days, skips recent | unit | `cd server && npx vitest run test/cron-purge.test.ts -t "cutoff"` | No -- Wave 0 |
| COMP-06 | GET /api/users/me/export returns JSON with attachment headers | unit | `cd server && npx vitest run test/export.test.ts -t "headers"` | No -- Wave 0 |
| COMP-07 | Export includes all 14 user data categories | unit | `cd server && npx vitest run test/export.test.ts -t "complete"` | No -- Wave 0 |
| COMP-08 | Export excludes passwordHash, revenuecatId, googleId, appleId | unit | `cd server && npx vitest run test/export.test.ts -t "excludes"` | No -- Wave 0 |

### Sampling Rate
- **Per task commit:** `cd server && npx vitest run test/deletion.test.ts test/export.test.ts test/cron-purge.test.ts`
- **Per wave merge:** `cd server && npm test`
- **Phase gate:** Full suite green before `/gsd:verify-work`

### Wave 0 Gaps
- [ ] `server/test/deletion.test.ts` -- covers COMP-01, COMP-03 (soft-delete, auth rejection, password verification)
- [ ] `server/test/export.test.ts` -- covers COMP-06, COMP-07, COMP-08 (export content, headers, field exclusion)
- [ ] `server/test/cron-purge.test.ts` -- covers COMP-02, COMP-03 (hard-purge transaction, 30-day cutoff)
- [ ] Test mocking pattern for `prisma` -- follow existing pattern in `routes_users.test.ts`

## Sources

### Primary (HIGH confidence)
- Prisma schema analysis: `server/prisma/schema.prisma` -- All 25 models reviewed, all `onDelete: Cascade` relations verified, `GenerationLog` confirmed to have no FK relation
- Codebase analysis: `server/lib/auth.ts` -- Current `requireAuth()` is synchronous, returns `string | null`, uses `req.headers.authorization`
- Codebase analysis: `server/api/users/[path].ts` -- `handleMe()` currently accepts GET/PUT, uses `requireAuth()`, follows standard error pattern
- Codebase analysis: `server/lib/middleware.ts` -- `errorResponse()`, `handleCors()`, `methodNotAllowed()` patterns
- Codebase analysis: `server/vercel.json` -- Current route configuration, no `crons` property yet
- [Vercel Cron Jobs documentation](https://vercel.com/docs/cron-jobs) -- Configuration, cron expressions, UTC timezone
- [Vercel Cron Jobs quickstart](https://vercel.com/docs/cron-jobs/quickstart) -- `vercel.json` `crons` array with `path` and `schedule`
- [Vercel Cron Jobs manage](https://vercel.com/docs/cron-jobs/manage-cron-jobs) -- CRON_SECRET verification, `@vercel/node` handler code example, GET method requirement, error handling (no retries), idempotency guidance
- [Vercel Cron Jobs usage and pricing](https://vercel.com/docs/cron-jobs/usage-and-pricing) -- Hobby: once/day, imprecise timing; Pro: once/minute, precise; 100 cron jobs per project on all plans
- [Prisma transactions documentation](https://www.prisma.io/docs/orm/prisma-client/queries/transactions) -- `$transaction([])` sequential API, interactive transactions, timeout configuration (default 5000ms), isolation levels

### Secondary (MEDIUM confidence)
- [Prisma soft delete middleware docs](https://www.prisma.io/docs/orm/prisma-client/client-extensions/middleware/soft-delete-middleware) -- Middleware deprecated in favor of `$extends`; `deletedAt DateTime?` pattern confirmed
- [Vercel community on CRON_SECRET](https://community.vercel.com/t/serverless-function-401-error-despite-valid-cron-secret/10793) -- Confirms `Bearer` prefix in authorization header, env var must not contain special characters

### Tertiary (LOW confidence)
- None

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH -- No new packages needed; all patterns verified in existing codebase
- Architecture: HIGH -- File structure follows existing conventions; all models analyzed directly
- Pitfalls: HIGH -- All pitfalls derived from direct codebase analysis (e.g., async requireAuth signature change, GenerationLog missing FK, OAuth empty passwordHash)
- Vercel Cron: HIGH -- Verified against official docs; both Hobby and Pro plan behavior documented

**Research date:** 2026-03-21
**Valid until:** 2026-04-21 (stable domain, no fast-moving dependencies)
