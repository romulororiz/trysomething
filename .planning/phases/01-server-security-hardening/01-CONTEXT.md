# Phase 1: Server Security Hardening - Context

**Gathered:** 2026-03-21
**Status:** Ready for planning

<domain>
## Phase Boundary

Close two live security vulnerabilities in the Vercel serverless backend: (1) RevenueCat webhook endpoint silently accepts all traffic when `REVENUECAT_WEBHOOK_SECRET` is not set, and (2) AI coach chat has zero rate limiting — free users can send unlimited messages. Both fixes are server-side only (no Flutter changes required for the core fix).

</domain>

<decisions>
## Implementation Decisions

### Webhook failure mode
- **D-01:** When `REVENUECAT_WEBHOOK_SECRET` env var is NOT set, return **503 Service Unavailable** — signals misconfiguration and RevenueCat will retry later
- **D-02:** When the Authorization header is wrong/missing, return **401 silently** — no logging of failed attempts (avoid noise)
- **D-03:** Skip webhook verification entirely when `NODE_ENV === 'development'` — allows local testing without RevenueCat dashboard setup

### Coach rate limits
- **D-04:** Free tier: **3 messages per rolling 30 days** — sliding window, no calendar month reset. Query: `GenerationLog.count({ where: { userId, createdAt: { gte: 30_days_ago }, query: 'coach' } })`
- **D-05:** Pro tier: **Unlimited** (no cap) — trust the user, don't limit paying customers
- **D-06:** 429 response body: **message only** — `{"error": "Rate limit exceeded"}`. Client handles the UX (upgrade prompt, etc.)

### Client-side Hive check
- **D-07:** Claude's discretion — choose the most pragmatic approach for client-side rate check behavior given that server now enforces the limit

### Claude's Discretion
- Whether to keep client-side Hive rate check as UX fast-fail or remove entirely
- How to distinguish coach messages from hobby generation in GenerationLog (tag field vs query content)
- Exact `timingSafeEqual` implementation pattern for webhook auth
- Error response format consistency with existing `errorResponse()` helper

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Webhook endpoint
- `server/api/users/[path].ts` lines 1090-1189 — Current `handleRevenueCatWebhook()` implementation with the `if (secret)` fail-open pattern
- `server/lib/middleware.ts` — `errorResponse()` helper used across all endpoints

### Coach endpoint
- `server/api/generate/[action].ts` — `handleCoachChat()` function (no rate limiting), `handleGenerateHobby()` (has 20/24h rate limit pattern to follow)
- `server/lib/ai_generator.ts` — AI generation functions

### Rate limiting pattern
- `server/api/generate/[action].ts` lines 93-100 — Existing `GenerationLog.count()` pattern in `handleGenerateHobby` (reuse this for coach)

### Database
- `server/prisma/schema.prisma` — `GenerationLog` model with `@@index([userId, createdAt])`

### Research
- `.planning/research/ARCHITECTURE.md` — Integration patterns, data flows, build order for new endpoints
- `.planning/research/STACK.md` — Stack additions (crypto.timingSafeEqual for webhook auth)
- `.planning/research/PITFALLS.md` — RevenueCat webhook pitfalls, rate limiting bypass risks

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `handleGenerateHobby()` rate limit pattern: `prisma.generationLog.count({ where: { userId, createdAt: { gte: ... } } })` — direct template for coach rate limiting
- `errorResponse()` helper in `middleware.ts` — standardized JSON error responses across all endpoints
- `requireAuth()` middleware — extracts userId from JWT, returns 401 if invalid

### Established Patterns
- All endpoints use `switch (action/path)` routing in consolidated handler files
- Error responses use `errorResponse(res, statusCode, message)` consistently
- Rate limiting check happens BEFORE any AI call (early return on 429)
- `logGeneration()` helper already creates GenerationLog entries with `{ userId, query, status, reason }`

### Integration Points
- Webhook handler: `handleRevenueCatWebhook()` at `users/[path].ts` line 1092 — modify in-place
- Coach handler: `handleCoachChat()` at `generate/[action].ts` — add rate limit check before AI call
- New utility: `server/lib/rate_limit.ts` — shared rate limit checker callable from any endpoint

</code_context>

<specifics>
## Specific Ideas

- Webhook should use `crypto.timingSafeEqual()` for the Authorization header comparison (prevents timing attacks)
- Coach rate limiting should reuse the exact same `GenerationLog.count()` pattern from `handleGenerateHobby` but with a 30-day window instead of 24h
- The `logGeneration()` helper already logs coach messages — verify it tags them distinctly from hobby generations

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 01-server-security-hardening*
*Context gathered: 2026-03-21*
