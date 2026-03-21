# Technology Stack — Launch Readiness Additions

**Project:** TrySomething v1.0 Launch Readiness
**Researched:** 2026-03-21
**Scope:** Stack additions for 5 new capabilities only — existing stack not re-researched
**Overall confidence:** HIGH (all findings verified against official docs or multiple sources)

---

## Context: What Already Exists

The base stack (Flutter 3.6.0, Riverpod 2.6.1, GoRouter 14.8.1, Node.js/TypeScript on Vercel, Prisma 6.4.1, Neon PostgreSQL, RevenueCat, PostHog, Sentry, FCM) is validated and in production. This document covers ONLY what must be added or changed for launch readiness.

---

## New Capability 1: Prisma Interactive Transactions (Account Deletion + Data Export)

### Verdict

No new library needed. Prisma 6.4.1 already installed includes `$transaction`. The question is which transaction pattern to use.

### Two Patterns Available

**Sequential array transactions** — pass an array of independent operations:

```typescript
await prisma.$transaction([
  prisma.journalEntry.deleteMany({ where: { userId } }),
  prisma.personalNote.deleteMany({ where: { userId } }),
  prisma.scheduleEvent.deleteMany({ where: { userId } }),
  prisma.user.delete({ where: { id: userId } }),
]);
```

**Interactive transactions** — async function with intermediate logic:

```typescript
await prisma.$transaction(async (tx) => {
  const user = await tx.user.findUnique({ where: { id: userId } });
  if (!user) throw new Error('User not found');
  await tx.journalEntry.deleteMany({ where: { userId } });
  await tx.user.delete({ where: { id: userId } });
}, { timeout: 10000, maxWait: 5000 });
```

### Which Pattern to Use

**Use sequential array for the full account deletion.** The schema already has `onDelete: Cascade` on all 13 user-related foreign keys. This means deleting the `User` record in a single `prisma.user.delete()` call will cascade all child records at the database level automatically.

The only records that need explicit deletion first are those without cascade constraints or where ordering matters. Looking at the schema:

- `UserPreference` — `onDelete: Cascade` (auto-cascades)
- `UserHobby` — `onDelete: Cascade` (auto-cascades)
- `UserCompletedStep` — `onDelete: Cascade` via UserHobby (auto-cascades)
- `UserActivityLog` — `onDelete: Cascade` (auto-cascades)
- `JournalEntry` — `onDelete: Cascade` (auto-cascades)
- `PersonalNote` — `onDelete: Cascade` (auto-cascades)
- `ScheduleEvent` — `onDelete: Cascade` (auto-cascades)
- `ShoppingCheck` — `onDelete: Cascade` (auto-cascades)
- `CommunityStory` — `onDelete: Cascade` (auto-cascades, StoryReaction also cascades)
- `StoryReaction` — `onDelete: Cascade` (auto-cascades)
- `BuddyPair` — `onDelete: Cascade` on both requester and accepter
- `UserChallenge` — `onDelete: Cascade` (auto-cascades)
- `UserAchievement` — `onDelete: Cascade` (auto-cascades)
- `GenerationLog` — no FK constraint (userId is a plain String, no relation)

`GenerationLog` has no Prisma relation defined (userId is a bare String field, not a foreign key). It will NOT cascade. Must be deleted explicitly. Pattern:

```typescript
await prisma.$transaction([
  prisma.generationLog.deleteMany({ where: { userId } }),
  prisma.user.delete({ where: { id: userId } }),
  // All other tables cascade automatically from user.delete
]);
```

### Timeout Configuration

Default interactive transaction timeout is 5000ms. For account deletion with 13 tables, increase to:

```typescript
{ timeout: 15000, maxWait: 5000 }
```

On Neon free tier with 100 connections, use `connection_limit=1` in DATABASE_URL for serverless to avoid pool exhaustion.

### Data Export Pattern

No new library. Use Prisma `findMany` with `include` to gather all user data, then `JSON.stringify`. For the export endpoint, a single large `prisma.$transaction` is not needed — read operations are safe to run sequentially without a transaction.

```typescript
const [profile, hobbies, journal, notes, schedule, shopping, challenges, achievements, activityLog] =
  await Promise.all([
    prisma.user.findUnique({ where: { id: userId }, include: { preferences: true } }),
    prisma.userHobby.findMany({ where: { userId }, include: { completedSteps: true } }),
    prisma.journalEntry.findMany({ where: { userId } }),
    // ...
  ]);
```

Return as `application/json` with `Content-Disposition: attachment; filename="trysomething-export.json"`.

**Confidence:** HIGH — verified against Prisma 6 official docs and schema inspection.

---

## New Capability 2: RevenueCat Webhook Verification

### Verdict

No new library needed. RevenueCat uses a simple shared-secret authorization header, not HMAC signing.

### How RevenueCat Webhooks Work

RevenueCat does NOT send cryptographic signatures (no `X-RevCat-Signature` header). The `x-revenuecat-signature` header mentioned in old community posts no longer exists. Their current mechanism is:

1. You set an arbitrary "Authorization header value" in the RevenueCat dashboard under Integrations > Webhooks.
2. RevenueCat sends that exact value as the `Authorization` header on every webhook POST.
3. Your server compares the incoming header to the value you configured.

This is token-based authentication, not signature-based. It is simpler but sufficient — the secret token should be a high-entropy random string.

### Implementation

```typescript
function verifyRevenueCatWebhook(req: VercelRequest): boolean {
  const incoming = req.headers['authorization'];
  const expected = process.env.REVENUECAT_WEBHOOK_SECRET;
  if (!expected) throw new Error('REVENUECAT_WEBHOOK_SECRET not configured');
  if (!incoming) return false;
  // Use timing-safe comparison to prevent timing attacks
  const a = Buffer.from(incoming);
  const b = Buffer.from(expected);
  if (a.length !== b.length) return false;
  return require('crypto').timingSafeEqual(a, b);
}
```

Use Node's built-in `crypto.timingSafeEqual` for the comparison — no external library needed. The `crypto` module is already available in Node.js.

### Environment Variable Required

Add `REVENUECAT_WEBHOOK_SECRET` to Vercel environment variables. Set the same value in the RevenueCat dashboard. There is no existing `REVENUECAT_WEBHOOK_SECRET` in the current stack's env vars (the existing `REVENUECAT_API_KEY` is separate — that is the SDK public key, not the webhook secret).

### Additional Security: Idempotency

RevenueCat may send the same event more than once. The webhook handler should be idempotent — check if the event has already been processed before acting on it. Store the `event.id` from the webhook payload in a processed-events table or in `GenerationLog` with a deduplicated key.

**Confidence:** HIGH — verified against RevenueCat official webhook docs and community forum posts confirming X-RevCat-Signature was removed.

---

## New Capability 3: Server-Side Rate Limiting (Vercel Serverless)

### The Core Problem

Vercel serverless functions are stateless — each invocation is independent with no shared memory. Traditional in-memory rate limiters (like `express-rate-limit` with default memory store) will not work because each function instance has its own counter.

### Recommended Approach: Database-Backed via GenerationLog

The `GenerationLog` model already exists in the schema with `@@index([userId, createdAt])`. This is the right place to count requests per user per window. No new library, no Redis, no extra cost.

```typescript
async function checkCoachRateLimit(userId: string): Promise<boolean> {
  const windowStart = new Date();
  windowStart.setDate(windowStart.getDate() - 1); // last 24 hours

  const count = await prisma.generationLog.count({
    where: {
      userId,
      status: 'success',
      createdAt: { gte: windowStart },
    },
  });

  return count < 20; // 20 per 24h as documented in CLAUDE.md
}
```

This COUNT query hits the `(userId, createdAt)` index and is fast. Vercel function cold start + Neon query typically < 100ms for this pattern.

### Why Not Redis/Upstash

Upstash Redis free tier exists (256MB, 500K commands/month) and `@upstash/ratelimit` works on Vercel. However:

- GenerationLog already exists with the right index
- Adding Upstash introduces a new paid service dependency (free tier may not cover scale)
- The coach endpoint is already async (2-5s AI calls) — a 50ms DB count does not change user experience
- Existing CLAUDE.md states the plan is to move rate limiting to GenerationLog

Use GenerationLog. Defer Upstash/Redis to a future performance milestone if rate limit checks become a bottleneck.

### For Login Rate Limiting (Future)

The auth endpoint has no rate limiting. If adding login rate limiting (not in this milestone), the same GenerationLog pattern applies with a separate table or a failed-login audit table. Do not block this milestone on it.

**Confidence:** HIGH — design validated against Neon docs on Postgres rate limiting patterns and confirmed GenerationLog index exists in schema.

---

## New Capability 4: Pre-Commit Hooks (Polyglot Monorepo)

### Recommended Tool: Lefthook v2.1.4

**Not Husky.** The repository is a polyglot monorepo (Flutter Dart + TypeScript) with `.git` at root, Flutter app at root, and server at `server/`. Husky is Node-centric and requires npm at root; the root of this repo is a Flutter project with no `package.json` at root. Lefthook is language-agnostic, installed as a binary, and natively supports this structure.

Lefthook v2.1.4 was released March 12, 2026. It is an npm-installable binary but also works without npm at the project root.

### Installation

Install in the server package (where npm exists):

```bash
cd server && npm install --save-dev lefthook
```

Then initialize hooks at the git root:

```bash
cd .. && npx --prefix server lefthook install
```

Or install system-wide via winget (Windows): `winget install lefthook`

### Configuration File

Place `lefthook.yml` at repository root (same level as `.git`):

```yaml
pre-commit:
  parallel: false  # run sequentially — Flutter analyze must pass first
  jobs:
    - name: flutter-analyze
      glob: "*.dart"
      run: flutter analyze

    - name: dart-format-check
      glob: "*.dart"
      run: dart format --output=none --set-exit-if-changed {staged_files}

    - name: typescript-typecheck
      glob: "server/**/*.ts"
      root: "server/"
      run: npm run lint  # runs tsc --noEmit

    - name: freezed-check
      glob: "lib/models/*.dart"
      run: echo "WARNING: Model changed — run 'dart run build_runner build' if .freezed.dart files are stale"
```

The `root: "server/"` option runs the TypeScript check from the correct directory. The `{staged_files}` placeholder passes only changed files to dart format, keeping pre-commit fast.

### Why Not Husky + lint-staged

Husky 9.1.7 (last release: March 2025, no new version in 12 months) requires `package.json` with a `prepare` script. The Flutter root has no `package.json`. Setting up Husky from `server/` subdirectory with hooks pointing to root-level flutter commands requires custom shell script wrangling. Lefthook handles this naturally.

### Dart Code Generation Warning

The `lefthook.yml` above includes a warning for model changes. Full Freezed regeneration (`dart run build_runner build`) cannot run in a pre-commit hook because it modifies generated files that are not yet staged — this causes confusing git state. The right approach is to warn the developer and have them stage the generated files, or run build_runner as a pre-push hook instead.

**Confidence:** HIGH — Lefthook v2 officially supports polyglot monorepos, verified against evilmartians/lefthook GitHub and community posts showing Flutter + Lefthook configurations working in 2025.

---

## New Capability 5: Data Export Serialization

### Verdict

No new library needed. Node's built-in `JSON.stringify` is sufficient for the data export. The 14 user-related tables produce at most a few hundred KB per user.

### Pattern

```typescript
const exportData = {
  exportedAt: new Date().toISOString(),
  version: '1.0',
  user: {
    id: user.id,
    email: user.email,
    displayName: user.displayName,
    createdAt: user.createdAt,
  },
  preferences: user.preferences,
  hobbies: userHobbies,
  completedSteps: completedSteps,
  journalEntries: journalEntries,
  personalNotes: personalNotes,
  scheduleEvents: scheduleEvents,
  shoppingChecks: shoppingChecks,
  challenges: challenges,
  achievements: achievements,
  activityLog: activityLog,
};

res.setHeader('Content-Type', 'application/json');
res.setHeader('Content-Disposition', 'attachment; filename="trysomething-export.json"');
res.status(200).json(exportData);
```

Strip sensitive fields before export: `passwordHash`, `revenuecatId`, `googleId`, `appleId`. These are internal identifiers the user doesn't need and shouldn't receive.

**Confidence:** HIGH — standard Node.js JSON serialization, no external dependencies needed.

---

## Summary: New Dependencies

| Package | Version | Where | Purpose | Cost |
|---------|---------|-------|---------|------|
| `lefthook` | `^2.1.4` | `server/devDependencies` | Polyglot pre-commit hooks | Free |

That's it. One new dev dependency. Everything else uses existing installed packages or Node.js built-ins.

---

## Summary: New Environment Variables

| Variable | Where | Purpose |
|----------|-------|---------|
| `REVENUECAT_WEBHOOK_SECRET` | Vercel + RevenueCat dashboard | Webhook auth token comparison |

---

## Alternatives Considered

| Capability | Recommended | Alternative | Why Not |
|------------|-------------|-------------|---------|
| Rate limiting | GenerationLog COUNT query | Upstash @upstash/ratelimit | Adds paid dependency; GenerationLog already indexed; coach latency dominated by AI call |
| Webhook verification | crypto.timingSafeEqual (built-in) | Custom HMAC library | RevenueCat doesn't sign payloads; HMAC approach is wrong for this provider |
| Pre-commit hooks | Lefthook | Husky + lint-staged | Husky needs root package.json; Flutter project has none; lefthook is binary, language-agnostic |
| Account deletion | Prisma $transaction + cascade | Manual delete-each-table | `onDelete: Cascade` already set on all 13 FKs; only GenerationLog needs explicit delete |
| Data export | JSON.stringify | CSV, zip, streaming | Volumes are small (< 1MB); JSON is portable; streaming adds complexity for no benefit |

---

## Sources

- Prisma Transactions Reference: https://www.prisma.io/docs/orm/prisma-client/queries/transactions
- Prisma Cascading Deletes Discussion: https://github.com/prisma/prisma/discussions/5158
- RevenueCat Webhooks Documentation: https://www.revenuecat.com/docs/integrations/webhooks
- RevenueCat Webhook Message Verification Community: https://community.revenuecat.com/sdks-51/webhook-message-verification-7165
- RevenueCat X-RevCat-Signature Removed: https://community.revenuecat.com/dashboard-tools-52/is-x-revenuecat-signature-removed-and-where-is-webhook-secret-key-7110
- Lefthook GitHub (v2.1.4): https://github.com/evilmartians/lefthook
- Neon Rate Limiting with PostgreSQL: https://neon.com/guides/rate-limiting
- Husky Documentation: https://typicode.github.io/husky/
- Upstash Rate Limit for Serverless: https://upstash.com/blog/upstash-ratelimit
- Vercel Rate Limiting Guide: https://vercel.com/kb/guide/add-rate-limiting-vercel
- Lefthook Flutter Integration: https://dev.to/arthurdenner/git-hooks-in-flutter-projects-with-lefthook-52n
