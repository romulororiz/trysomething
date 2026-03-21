# Phase 1: Server Security Hardening - Research

**Researched:** 2026-03-21
**Domain:** Vercel serverless security -- webhook verification + server-side rate limiting
**Confidence:** HIGH

## Summary

Phase 1 closes two live security vulnerabilities in the Vercel serverless backend. Both are server-side only changes with no Flutter dependency.

**Vulnerability 1 -- Webhook fail-open:** The `handleRevenueCatWebhook()` function in `server/api/users/[path].ts` (line 1101-1108) uses `if (secret) { ... }` which silently accepts all traffic when `REVENUECAT_WEBHOOK_SECRET` is unset. The fix inverts this to fail-closed: return 503 when the env var is missing, return 401 when the Authorization header is wrong, and use `crypto.timingSafeEqual` for the comparison.

**Vulnerability 2 -- Coach rate limiting bypass:** The `handleCoachChat()` function in `server/api/generate/[action].ts` (line 378-507) has zero rate limiting. Free users can send unlimited coach messages. The fix adds a server-side count query against `GenerationLog` rows with a 30-day rolling window, limited to 3 for free users. The existing `handleGenerateHobby` rate limit pattern (lines 94-105) is the direct template.

**Primary recommendation:** Implement both fixes as minimal, surgical edits to existing handler files. Create one new utility file (`server/lib/rate_limit.ts`) for the reusable rate limit checker. No schema changes, no new dependencies, no Flutter changes required for the security fix itself.

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
- **D-01:** When `REVENUECAT_WEBHOOK_SECRET` env var is NOT set, return **503 Service Unavailable** -- signals misconfiguration and RevenueCat will retry later
- **D-02:** When the Authorization header is wrong/missing, return **401 silently** -- no logging of failed attempts (avoid noise)
- **D-03:** Skip webhook verification entirely when `NODE_ENV === 'development'` -- allows local testing without RevenueCat dashboard setup
- **D-04:** Free tier: **3 messages per rolling 30 days** -- sliding window, no calendar month reset. Query: `GenerationLog.count({ where: { userId, createdAt: { gte: 30_days_ago }, query: 'coach' } })`
- **D-05:** Pro tier: **Unlimited** (no cap) -- trust the user, don't limit paying customers
- **D-06:** 429 response body: **message only** -- `{"error": "Rate limit exceeded"}`. Client handles the UX (upgrade prompt, etc.)

### Claude's Discretion
- Whether to keep client-side Hive rate check as UX fast-fail or remove entirely
- How to distinguish coach messages from hobby generation in GenerationLog (tag field vs query content)
- Exact `timingSafeEqual` implementation pattern for webhook auth
- Error response format consistency with existing `errorResponse()` helper

### Deferred Ideas (OUT OF SCOPE)
None -- discussion stayed within phase scope
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| SEC-01 | RevenueCat webhook verifies Authorization header and fails closed (rejects when env var unset) | Webhook handler at `users/[path].ts:1092-1189` fully analyzed; `crypto.timingSafeEqual` pattern documented; D-01/D-02/D-03 decisions constrain implementation |
| SEC-02 | Coach rate limiting enforced server-side via GenerationLog count query (replaces client-side Hive check) | Coach handler at `generate/[action].ts:378-507` analyzed; existing rate limit pattern at lines 94-105 documented; `GenerationLog` model confirmed with `@@index([userId, createdAt])`; D-04/D-05/D-06 decisions constrain implementation |
</phase_requirements>

## Standard Stack

### Core (already installed -- no changes)

| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Node.js `crypto` | built-in | `timingSafeEqual` for webhook header comparison | Zero-dependency, prevents timing attacks |
| `@prisma/client` | 6.4.1 | `GenerationLog.count()` for rate limiting | Already installed, already indexed |
| `@vercel/node` | 5.0.2 | Request/response types | Already installed |

### Supporting (no additions needed)

No new npm packages. Everything needed is already in the project or built into Node.js.

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| `crypto.timingSafeEqual` | Simple `===` string comparison | `===` is vulnerable to timing attacks; `timingSafeEqual` is the standard for secret comparison |
| `GenerationLog` count | Upstash Redis `@upstash/ratelimit` | Adds paid dependency and new infra; GenerationLog already has the right index; decided out-of-scope in STATE.md |
| Database-backed rate limiting | In-memory Map | Vercel serverless functions share no memory between invocations; in-memory counters reset on every cold start and are silently ineffective |

**Installation:** None needed. No new packages.

## Architecture Patterns

### Files to Modify

```
server/
├── api/
│   ├── users/[path].ts          # MODIFY: handleRevenueCatWebhook() -- fail-closed + timingSafeEqual
│   └── generate/[action].ts     # MODIFY: handleCoachChat() -- add rate limit check + GenerationLog logging
└── lib/
    └── rate_limit.ts            # NEW: checkCoachRateLimit() utility
```

### Important: Prisma Client Usage

Two different Prisma client patterns exist in the codebase:
- `server/api/users/[path].ts` imports the **shared singleton** from `server/lib/db.ts`: `import { prisma } from "../../lib/db";`
- `server/api/generate/[action].ts` creates its **own instance** at line 32: `const prisma = new PrismaClient();`

The new `server/lib/rate_limit.ts` utility MUST import from `server/lib/db.ts` (the singleton) to avoid creating yet another connection pool. The `db.ts` singleton uses `globalThis` caching to reuse connections across warm serverless invocations.

### Pattern 1: Fail-Closed Webhook Verification

**What:** Invert the current `if (secret)` guard to reject traffic when the env var is missing, and use timing-safe comparison for the header value.

**When to use:** Any webhook endpoint that validates a shared secret.

**Current code (BROKEN -- fail-open):**
```typescript
// server/api/users/[path].ts lines 1101-1108
const secret = process.env.REVENUECAT_WEBHOOK_SECRET;
if (secret) {
  const auth = req.headers.authorization;
  if (!auth || auth !== `Bearer ${secret}`) {
    res.status(401).json({ error: "Unauthorized" });
    return;
  }
}
// If secret is unset, ALL traffic passes through silently
```

**Fixed code (fail-closed, per D-01/D-02/D-03):**
```typescript
import crypto from 'crypto';

// D-03: Skip verification in development
if (process.env.NODE_ENV !== 'development') {
  const secret = process.env.REVENUECAT_WEBHOOK_SECRET;

  // D-01: Fail closed when env var is not configured
  if (!secret) {
    console.warn('[RC Webhook] REVENUECAT_WEBHOOK_SECRET not configured');
    return errorResponse(res, 503, 'Webhook not configured');
  }

  // D-02: Reject silently when Authorization header is wrong/missing
  const auth = req.headers.authorization;
  if (!auth) {
    return errorResponse(res, 401, 'Unauthorized');
  }

  // Timing-safe comparison to prevent timing attacks
  const expected = `Bearer ${secret}`;
  const a = Buffer.from(auth);
  const b = Buffer.from(expected);
  if (a.length !== b.length || !crypto.timingSafeEqual(a, b)) {
    return errorResponse(res, 401, 'Unauthorized');
  }
}
```

**Key details:**
- `timingSafeEqual` requires both Buffers to be the same length. Check length first; if different, reject immediately (the length check itself leaks that lengths differ, but this is acceptable -- the attacker already knows the format is `Bearer <token>`).
- Uses `errorResponse()` from `middleware.ts` for consistency with all other endpoints.
- `console.warn` on 503 (not `console.error`) -- this is a configuration issue, not a runtime error.
- The `try/catch` block that wraps the business logic (lines 1110-1189) remains unchanged.

### Pattern 2: Server-Side Rate Limiting via GenerationLog

**What:** Count `GenerationLog` rows for a user within a rolling 30-day window to enforce the 3-message free tier limit.

**When to use:** Any endpoint that needs per-user rate limiting on Vercel serverless.

**Reference implementation (existing, from `handleGenerateHobby` lines 94-105):**
```typescript
// Existing 24h rate limit for hobby generation
const recentCount = await prisma.generationLog.count({
  where: {
    userId,
    createdAt: { gte: new Date(Date.now() - 24 * 60 * 60 * 1000) },
    status: "success",
  },
});
if (recentCount >= RATE_LIMIT) {
  await logGeneration(userId, trimmed, "rejected", "Rate limit exceeded");
  return errorResponse(res, 429, "Generation limit reached (5 per day). Try again tomorrow.");
}
```

**New utility (`server/lib/rate_limit.ts`):**
```typescript
// server/lib/rate_limit.ts
import { prisma } from './db';  // USE THE SINGLETON -- do NOT create new PrismaClient()

const COACH_FREE_LIMIT = 3;
const COACH_WINDOW_MS = 30 * 24 * 60 * 60 * 1000; // 30 days rolling

export async function checkCoachRateLimit(
  userId: string,
  subscriptionTier: string
): Promise<{ allowed: boolean; count: number }> {
  // D-05: Pro users are unlimited
  if (subscriptionTier !== 'free') {
    return { allowed: true, count: 0 };
  }

  // D-04: Rolling 30-day window count from GenerationLog
  const windowStart = new Date(Date.now() - COACH_WINDOW_MS);
  const count = await prisma.generationLog.count({
    where: {
      userId,
      query: 'coach',
      status: 'success',
      createdAt: { gte: windowStart },
    },
  });

  return { allowed: count < COACH_FREE_LIMIT, count };
}
```

**Call site in `handleCoachChat` (inserted after `requireAuth`, before hobby lookup):**
```typescript
// Fetch user's subscription tier
const user = await prisma.user.findUnique({
  where: { id: userId },
  select: { subscriptionTier: true },
});
if (!user) {
  return errorResponse(res, 401, 'User not found');
}

// Check rate limit (server-side, tamper-proof)
const rateCheck = await checkCoachRateLimit(userId, user.subscriptionTier);
if (!rateCheck.allowed) {
  // D-06: Simple error message, client handles UX
  return errorResponse(res, 429, 'Rate limit exceeded');
}
```

**After successful coach response, log to GenerationLog:**
```typescript
// After res.status(200).json({ response: text.trim() });
await logGeneration(userId, 'coach', 'success', null).catch(() => {});
```

### Pattern 3: Coach Message Tagging in GenerationLog

**Discretion decision -- use `query: 'coach'` field value:**

The `GenerationLog` model has a `query` field (String). For hobby generation, this stores the user's search query (e.g., "pottery"). For coach messages, set `query: 'coach'` as a fixed tag. This cleanly distinguishes coach messages from hobby generations in the count query (`where: { query: 'coach' }`) without requiring a schema change.

Rationale: Adding a separate `type` column would require a Prisma migration. Using the existing `query` field with a fixed string is zero-migration and the count query is still efficient due to the `@@index([userId, createdAt])` composite index.

### Pattern 4: Subscription Tier Lookup

The `handleCoachChat` function currently does NOT fetch the user's subscription tier. It only fetches `userHobby` and `hobby`. The rate limit check needs `subscriptionTier` from the `User` model. There are two options:

**Option A (recommended): Add a `prisma.user.findUnique` call at the top of `handleCoachChat`.**
This adds one small DB query (~2ms). The function already makes 3+ DB queries, so the overhead is negligible.

**Option B: Combine with existing `userHobby` query using `include: { user: { select: { subscriptionTier: true } } }`.**
This is slightly more efficient but couples the rate limit logic to the `userHobby` query, which may be null (user might be browsing without a saved hobby).

Recommend Option A for clarity and independence from the hobby lookup flow.

### Anti-Patterns to Avoid

- **Anti-Pattern: In-Memory Rate Limiting.** Vercel serverless functions are stateless. Module-level Maps/counters reset on every cold start. The rate limiter would be silently ineffective.
- **Anti-Pattern: Trusting Client-Side Hive Count.** A modified APK can bypass the Hive cache entirely. The server MUST enforce the limit via `GenerationLog` regardless of what the client reports.
- **Anti-Pattern: Using simple `===` for webhook secret comparison.** String comparison in JavaScript leaks timing information. `crypto.timingSafeEqual` is the standard Node.js approach.
- **Anti-Pattern: Logging failed auth attempts for webhooks.** Per D-02, failed webhook auth returns 401 silently. Logging every failed attempt creates noise from scanners/bots probing the endpoint.
- **Anti-Pattern: Creating new PrismaClient() in utility files.** `server/lib/db.ts` already provides a singleton via `globalThis` caching. Creating additional clients exhausts Neon's 100-connection pool limit on serverless.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Timing-safe string comparison | Custom byte-by-byte loop | `crypto.timingSafeEqual(Buffer.from(a), Buffer.from(b))` | Node.js built-in, constant-time, battle-tested |
| Rate limiting on serverless | In-memory counter / Map | `GenerationLog.count()` with `@@index([userId, createdAt])` | Serverless has no shared memory; DB is the only reliable state |
| Error response formatting | Custom `res.status().json()` per endpoint | `errorResponse(res, statusCode, message)` from `middleware.ts` | Existing helper ensures consistent `{ "error": "..." }` shape |

**Key insight:** The project already has the right infrastructure for both fixes. `GenerationLog` is indexed and ready. `errorResponse()` is the standard error helper. `crypto` is built into Node.js. No new dependencies or schema changes are needed.

## Common Pitfalls

### Pitfall 1: timingSafeEqual Buffer Length Mismatch Throws

**What goes wrong:** `crypto.timingSafeEqual(a, b)` throws `RangeError: Input buffers must have the same byte length` if the two Buffers differ in length. If the attacker sends `Authorization: Bearer short`, the server crashes with an unhandled error instead of returning 401.

**Why it happens:** `timingSafeEqual` compares byte-by-byte and cannot operate on different-length inputs. This is by design (comparing different-length strings would leak length information through timing).

**How to avoid:** Always check `a.length !== b.length` before calling `timingSafeEqual`. If lengths differ, return 401 immediately. The length check itself reveals that the values differ, but this is acceptable -- the format `Bearer <token>` is known.

**Warning signs:** Unhandled `RangeError` exceptions in Vercel function logs.

### Pitfall 2: Coach Rate Limit Log Written Before AI Response

**What goes wrong:** The `logGeneration` call is placed before the AI call. If the Anthropic API times out or returns an error, the GenerationLog entry with `status: 'success'` is already written. The user's rate limit counter increments even though they received no response.

**Why it happens:** The existing `handleGenerateHobby` logs success AFTER the DB write (line 209), but a developer might place the coach log before the AI call for "cleaner" code.

**How to avoid:** Log to `GenerationLog` with `status: 'success'` ONLY after the AI response is successfully returned to the client. If the AI call fails, either don't log or log with `status: 'error'` (which the count query excludes via `status: 'success'` filter).

**Warning signs:** Free users hitting the limit after receiving error responses instead of actual coach messages.

### Pitfall 3: Existing Hive Limit Is Per-Hobby, Server Limit Is Per-User

**What goes wrong:** The current client-side `_CoachLimitTracker` counts messages per-hobby per-month (key: `${hobbyId}_${year}_${month}`). The server-side limit per D-04 is 3 messages per user across ALL hobbies per rolling 30 days. If the client-side check is kept as-is, a user with 2 hobbies could appear to have remaining messages on the client but get 429'd by the server.

**Why it happens:** The client-side and server-side counting scopes differ.

**How to avoid:** If keeping the client-side Hive check as a UX fast-fail (Claude's discretion item), update it to match the server scope: count across all hobbies, rolling 30-day window. Alternatively, remove the client-side check entirely and rely on the server 429 response to trigger the upgrade prompt.

**Recommendation (discretion):** Keep the client-side Hive check but simplify it to a single global counter (not per-hobby). This prevents unnecessary network round-trips when the user is clearly over the limit. The server remains the authoritative source of truth.

### Pitfall 4: `NODE_ENV` Not Set on Vercel

**What goes wrong:** D-03 skips webhook verification when `NODE_ENV === 'development'`. On Vercel, `NODE_ENV` is set to `'production'` by default in production deployments and `'development'` in `vercel dev` local mode. However, if a developer deploys to a preview/staging environment without checking, `NODE_ENV` might not be `'production'` in all deployment contexts.

**Why it happens:** Vercel preview deployments use the same environment as production by default, but custom env var overrides could change this.

**How to avoid:** The check `process.env.NODE_ENV !== 'development'` is safe -- it only skips verification when explicitly in development. Vercel production and preview deployments both default to `NODE_ENV=production`. No action needed beyond documenting the behavior.

### Pitfall 5: Existing Error Response in Webhook Catch Block Returns 200

**What goes wrong:** The current webhook handler has a `catch` block at line 1186-1188 that returns `res.status(200).json({ status: "error", message: "Internal error logged" })`. This means internal errors are returned as HTTP 200, which RevenueCat considers a successful delivery. If there is a database error, RevenueCat will not retry the webhook.

**Why it happens:** The original implementation chose 200 for all responses to acknowledge receipt, even on error. This is a defensible pattern (acknowledge receipt, handle internally) but means genuine transient errors (e.g., Neon connection timeout) are never retried.

**How to avoid:** Consider changing the catch block to return 500 so RevenueCat retries on transient errors. However, this is outside the scope of SEC-01 (which focuses on the auth guard). Flag for future improvement but do not change in this phase to minimize blast radius.

## Code Examples

### Example 1: Complete Webhook Verification Block

```typescript
// Source: Analysis of server/api/users/[path].ts lines 1092-1108
// and RevenueCat webhook docs (Authorization header model)
import crypto from 'crypto';

async function handleRevenueCatWebhook(
  req: VercelRequest,
  res: VercelResponse
): Promise<void> {
  if (req.method !== "POST") {
    res.status(405).json({ error: "Method not allowed" });
    return;
  }

  // D-03: Skip verification in development for local testing
  if (process.env.NODE_ENV !== 'development') {
    const secret = process.env.REVENUECAT_WEBHOOK_SECRET;

    // D-01: Fail closed -- 503 signals misconfiguration, RevenueCat retries
    if (!secret) {
      console.warn('[RC Webhook] REVENUECAT_WEBHOOK_SECRET not configured');
      return errorResponse(res, 503, 'Webhook not configured');
    }

    const auth = req.headers.authorization;
    // D-02: Reject silently (no logging of failed attempts)
    if (!auth) {
      return errorResponse(res, 401, 'Unauthorized');
    }

    // Timing-safe comparison
    const expected = `Bearer ${secret}`;
    const incomingBuf = Buffer.from(auth);
    const expectedBuf = Buffer.from(expected);
    if (incomingBuf.length !== expectedBuf.length || !crypto.timingSafeEqual(incomingBuf, expectedBuf)) {
      return errorResponse(res, 401, 'Unauthorized');
    }
  }

  // ... rest of webhook business logic unchanged (lines 1110-1189)
}
```

### Example 2: Rate Limit Utility

```typescript
// Source: Modeled after server/api/generate/[action].ts lines 94-105
// File: server/lib/rate_limit.ts
import { prisma } from './db';  // Singleton from server/lib/db.ts

const COACH_FREE_LIMIT = 3;
const COACH_WINDOW_MS = 30 * 24 * 60 * 60 * 1000; // 30 days rolling

export async function checkCoachRateLimit(
  userId: string,
  subscriptionTier: string
): Promise<{ allowed: boolean; count: number }> {
  // Pro/lifetime/trial: unlimited (D-05)
  if (subscriptionTier !== 'free') {
    return { allowed: true, count: 0 };
  }

  // D-04: Rolling 30-day window count
  const windowStart = new Date(Date.now() - COACH_WINDOW_MS);
  const count = await prisma.generationLog.count({
    where: {
      userId,
      query: 'coach',
      status: 'success',
      createdAt: { gte: windowStart },
    },
  });

  return { allowed: count < COACH_FREE_LIMIT, count };
}
```

### Example 3: Coach Handler Rate Limit Integration Point

```typescript
// Source: server/api/generate/[action].ts handleCoachChat function
// Insert AFTER requireAuth, BEFORE hobby lookup

async function handleCoachChat(req: VercelRequest, res: VercelResponse) {
  const userId = requireAuth(req, res);
  if (!userId) return;

  // --- NEW: Server-side rate limit check ---
  const user = await prisma.user.findUnique({
    where: { id: userId },
    select: { subscriptionTier: true },
  });
  if (!user) {
    return errorResponse(res, 401, 'User not found');
  }

  const rateCheck = await checkCoachRateLimit(userId, user.subscriptionTier);
  if (!rateCheck.allowed) {
    return errorResponse(res, 429, 'Rate limit exceeded');
  }
  // --- END rate limit check ---

  const { hobbyId, message, conversationHistory, modeOverride } = req.body ?? {};
  // ... rest of handler unchanged ...

  // IMPORTANT: Log AFTER successful AI response (not before)
  // At the end, after res.status(200).json({ response: text.trim() }):
  await logGeneration(userId, 'coach', 'success', null).catch(() => {});
}
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Client-side Hive rate check | Server-side GenerationLog count | This phase | Tamper-proof; reinstall cannot bypass |
| `if (secret)` fail-open webhook | `if (!secret)` fail-closed + timingSafeEqual | This phase | Prevents unauthorized subscription state changes |
| Simple `===` string comparison for secrets | `crypto.timingSafeEqual` | Node.js best practice | Prevents timing side-channel attacks |

**Nothing deprecated or outdated** -- this phase uses stable Node.js built-ins and existing Prisma patterns.

## Validation Architecture

### Test Framework

| Property | Value |
|----------|-------|
| Framework | Vitest 3.x |
| Config file | None (zero-config, `vitest run` from package.json `test` script) |
| Quick run command | `cd server && npx vitest run --testPathPattern=webhook` |
| Full suite command | `cd server && npm test` |

### Phase Requirements to Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| SEC-01a | Webhook returns 503 when `REVENUECAT_WEBHOOK_SECRET` is not set | unit | `cd server && npx vitest run test/webhook.test.ts -t "503"` | Wave 0 |
| SEC-01b | Webhook returns 401 when Authorization header is wrong | unit | `cd server && npx vitest run test/webhook.test.ts -t "401"` | Wave 0 |
| SEC-01c | Webhook returns 401 when Authorization header is missing | unit | `cd server && npx vitest run test/webhook.test.ts -t "missing"` | Wave 0 |
| SEC-01d | Webhook passes through when correct Authorization header provided | unit | `cd server && npx vitest run test/webhook.test.ts -t "passes"` | Wave 0 |
| SEC-01e | Webhook skips verification when NODE_ENV=development | unit | `cd server && npx vitest run test/webhook.test.ts -t "development"` | Wave 0 |
| SEC-02a | Coach returns 429 for free user exceeding 3 messages in 30 days | unit | `cd server && npx vitest run test/rate_limit.test.ts -t "429"` | Wave 0 |
| SEC-02b | Coach allows pro user unlimited messages | unit | `cd server && npx vitest run test/rate_limit.test.ts -t "pro"` | Wave 0 |
| SEC-02c | Coach count comes from GenerationLog, not client Hive | unit | `cd server && npx vitest run test/rate_limit.test.ts -t "GenerationLog"` | Wave 0 |
| SEC-02d | Coach logs successful messages to GenerationLog with query='coach' | unit | `cd server && npx vitest run test/rate_limit.test.ts -t "logs"` | Wave 0 |

### Sampling Rate
- **Per task commit:** `cd server && npm test`
- **Per wave merge:** `cd server && npm test`
- **Phase gate:** Full suite green before verification

### Wave 0 Gaps
- [ ] `server/test/webhook.test.ts` -- covers SEC-01 (a-e): webhook verification behavior
- [ ] `server/test/rate_limit.test.ts` -- covers SEC-02 (a-d): coach rate limiting behavior

Test pattern: Follow existing test style in `server/test/routes_users.test.ts` -- mock `VercelRequest`/`VercelResponse` with `vi.fn()`, test handler/utility logic in isolation. No Prisma integration tests needed -- mock `prisma.generationLog.count()`.

## Open Questions

1. **Prisma Client Singleton in rate_limit.ts -- RESOLVED**
   - **Finding:** `server/lib/db.ts` exists and exports a Prisma singleton via `globalThis` caching. `users/[path].ts` already imports from it: `import { prisma } from "../../lib/db"`. However, `generate/[action].ts` creates its own `const prisma = new PrismaClient()` at line 32 instead of using the singleton.
   - **Resolution:** The new `rate_limit.ts` MUST import from `server/lib/db.ts`. The planner may optionally also fix `generate/[action].ts` to use the singleton, but this is a pre-existing issue outside SEC-01/SEC-02 scope.

2. **Client-Side Hive Check Behavior (Claude's Discretion)**
   - What we know: Current `_CoachLimitTracker` in `lib/screens/coach/hobby_coach_screen.dart` counts per-hobby per-calendar-month (key: `${hobbyId}_${year}_${month}`). Server counts per-user per-rolling-30-days. Scopes are mismatched.
   - Recommendation: Keep the client-side Hive check as a UX fast-fail but simplify it to a single global counter (all hobbies, rolling 30 days). When the server returns 429, the client should also update its local counter to match.
   - Alternative: Remove the Hive check entirely and let the server 429 response trigger the upgrade prompt. Simpler but adds a round-trip for every over-limit attempt.
   - **Note:** Modifying the client-side Hive check is optional for this phase. The core security requirement (SEC-02) is satisfied by the server-side check alone. Client-side changes are a UX optimization, not a security fix.

## Sources

### Primary (HIGH confidence)
- `server/api/users/[path].ts` lines 1092-1189 -- direct code inspection of current webhook handler
- `server/api/generate/[action].ts` lines 32, 75-218, 378-507 -- direct code inspection of Prisma instantiation, rate limit pattern, and coach handler
- `server/prisma/schema.prisma` lines 392-402 -- `GenerationLog` model with `@@index([userId, createdAt])`
- `server/lib/middleware.ts` -- `errorResponse(res, status, message)` helper signature: returns `{ "error": message }`
- `server/lib/auth.ts` -- `requireAuth()` returns `string | null` (userId or null after sending 401)
- `server/lib/db.ts` -- Prisma singleton via `globalThis` pattern, exports `prisma`
- `lib/screens/coach/hobby_coach_screen.dart` lines 72-120 -- current client-side `_CoachLimitTracker` implementation
- `server/vercel.json` line 34 -- webhook route: `"/api/webhooks/revenuecat" -> path=revenuecat-webhook`

### Secondary (MEDIUM confidence)
- `.planning/research/ARCHITECTURE.md` -- integration patterns and data flow analysis
- `.planning/research/PITFALLS.md` -- webhook and rate limiting pitfall catalogue
- `.planning/research/STACK.md` -- `crypto.timingSafeEqual` pattern and GenerationLog strategy

### Tertiary (LOW confidence)
- None -- all findings verified against codebase or prior research documents

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH -- no new packages, all built-in Node.js or existing dependencies
- Architecture: HIGH -- direct code inspection of all affected files; patterns copied from existing codebase
- Pitfalls: HIGH -- 5 pitfalls identified from code analysis and prior research; all verified against actual implementation

**Research date:** 2026-03-21
**Valid until:** 2026-04-21 (stable -- no fast-moving dependencies)
