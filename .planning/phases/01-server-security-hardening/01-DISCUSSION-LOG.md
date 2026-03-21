# Phase 1: Server Security Hardening - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-03-21
**Phase:** 01-server-security-hardening
**Areas discussed:** Webhook failure mode, Coach rate limits, Client Hive cleanup

---

## Webhook failure mode

### Q1: When REVENUECAT_WEBHOOK_SECRET env var is NOT set, how should the endpoint respond?

| Option | Description | Selected |
|--------|-------------|----------|
| 500 + console.error | Server error — signals misconfiguration, logs for devops visibility | |
| 503 Service Unavailable | Temporarily unavailable — RevenueCat will retry later | ✓ |
| 403 Forbidden | Silent rejection — no hint about what's wrong | |

**User's choice:** 503 Service Unavailable
**Notes:** None

### Q2: Log failed webhook auth attempts (wrong secret)?

| Option | Description | Selected |
|--------|-------------|----------|
| console.warn with IP | Log the attempt with request IP for monitoring | |
| console.error full headers | Log full headers (useful early, noisy later) | |
| Silent 401 only | Just reject — don't log noise | ✓ |

**User's choice:** Silent 401 only
**Notes:** None

### Q3: Should webhook verification be skipped in development (no env var set locally)?

| Option | Description | Selected |
|--------|-------------|----------|
| Never skip | Always require the secret — catch issues early | |
| Skip if NODE_ENV=dev | Allow testing without setting up RevenueCat locally | ✓ |

**User's choice:** Skip if NODE_ENV=dev
**Notes:** None

---

## Coach rate limits

### Q1: Free tier coach limit: 3 messages per what window?

| Option | Description | Selected |
|--------|-------------|----------|
| 3/calendar month | Resets on the 1st — simple, predictable for users | |
| 3/rolling 30 days | Sliding window — no sudden reset, harder to game | ✓ |
| 5/rolling 30 days | Slightly more generous to reduce paywall friction | |

**User's choice:** Asked for recommendation — Claude recommended 3/rolling 30 days
**Notes:** User asked "what do you recommend?" — Claude recommended rolling 30 days for even usage distribution and harder gaming, plus the GenerationLog index already supports this query pattern.

### Q2: Pro tier coach limit?

| Option | Description | Selected |
|--------|-------------|----------|
| Unlimited (no cap) | Pro = full access, trust the user | ✓ |
| 100/day soft cap | Prevent abuse/runaway bots, effectively unlimited for humans | |
| 50/day | Moderate cap — saves AI token costs | |

**User's choice:** Unlimited (no cap)
**Notes:** None

### Q3: What should the rate limit 429 response include?

| Option | Description | Selected |
|--------|-------------|----------|
| Message + reset time | {"error": "Rate limit exceeded", "resetsAt": "..."} | |
| Message + upgrade CTA | {"error": "Free limit reached", "upgradeUrl": "/pro"} | |
| Message only | {"error": "Rate limit exceeded"} — client handles UX | ✓ |

**User's choice:** Message only
**Notes:** None

---

## Client Hive cleanup

### Q1: Once server-side rate limiting is in place, what happens to client-side Hive checks?

| Option | Description | Selected |
|--------|-------------|----------|
| Keep as UX fast-fail | Client shows limit reached instantly, server still enforces | |
| Remove entirely | Server is source of truth — client just shows whatever server returns | |
| You decide | Claude's discretion — pick the pragmatic option | ✓ |

**User's choice:** You decide
**Notes:** Deferred to Claude's discretion

---

## Claude's Discretion

- Client-side Hive rate check behavior (keep as UX fast-fail vs remove)
- How to distinguish coach messages from hobby generation in GenerationLog
- Exact timingSafeEqual implementation pattern
- Error response format details

## Deferred Ideas

None — discussion stayed within phase scope
