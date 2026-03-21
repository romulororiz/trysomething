---
phase: 01-server-security-hardening
plan: 01
subsystem: api
tags: [security, webhook, revenuecat, crypto, timingSafeEqual]

# Dependency graph
requires: []
provides:
  - "Fail-closed RevenueCat webhook verification with timing-safe comparison"
  - "503 response when REVENUECAT_WEBHOOK_SECRET is unset"
  - "401 response when Authorization header is wrong or missing"
  - "Development mode bypass for local testing"
affects: []

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "crypto.timingSafeEqual for secret comparison (prevents timing attacks)"
    - "Fail-closed pattern: reject by default, only allow with valid credentials"

key-files:
  created:
    - server/test/webhook-auth.test.ts
  modified:
    - server/api/users/[path].ts

key-decisions:
  - "Used Buffer length check before timingSafeEqual to prevent RangeError on mismatched lengths"
  - "Followed errorResponse() helper for consistent error format across all endpoints"

patterns-established:
  - "Fail-closed webhook auth: check env var existence first (503), then header presence (401), then timing-safe value comparison (401)"

requirements-completed: [SEC-01]

# Metrics
duration: 2min
completed: 2026-03-21
---

# Phase 1 Plan 1: RevenueCat Webhook Fail-Closed Summary

**Fail-closed webhook verification with crypto.timingSafeEqual, replacing silent fail-open pattern that accepted all traffic when REVENUECAT_WEBHOOK_SECRET was unset**

## Performance

- **Duration:** 2 min
- **Started:** 2026-03-21T19:08:48Z
- **Completed:** 2026-03-21T19:11:03Z
- **Tasks:** 1 (TDD: RED + GREEN)
- **Files modified:** 2

## Accomplishments

- Closed a live security vulnerability where the webhook silently accepted ALL traffic when `REVENUECAT_WEBHOOK_SECRET` was not set
- Implemented timing-safe comparison using `crypto.timingSafeEqual` to prevent timing side-channel attacks
- Added development mode bypass (D-03) for local testing without RevenueCat dashboard
- Created comprehensive test suite with 5 scenarios covering all auth guard paths
- Full test suite green: 103 tests across 10 files, zero regressions

## Task Commits

Each task was committed atomically (TDD flow):

1. **Task 1 RED: Create webhook auth tests** - `d9483df` (test)
2. **Task 1 GREEN: Fix handleRevenueCatWebhook fail-closed** - `df0fb31` (feat)

## Files Created/Modified

- `server/test/webhook-auth.test.ts` - 5 test cases for webhook auth guard (SEC-01a through SEC-01e)
- `server/api/users/[path].ts` - Added `import crypto from "crypto"`, replaced fail-open auth guard with fail-closed + timingSafeEqual pattern

## Decisions Made

- **Buffer length check before timingSafeEqual:** `timingSafeEqual` throws `RangeError` on mismatched buffer lengths. Added `incomingBuf.length !== expectedBuf.length` guard to return 401 gracefully instead of crashing.
- **Used errorResponse() helper:** Consistent with all other endpoints in the codebase. Returns `{ "error": "message" }` format.
- **Test approach:** Called default handler with `query: { path: 'revenuecat-webhook' }` rather than extracting the private function, matching the actual request routing.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None.

## Verification

- `cd server && npx vitest run test/webhook-auth.test.ts --reporter=verbose` -- all 5 tests pass
- `cd server && npm test` -- 103 tests pass, 10 files, zero failures
- `grep "timingSafeEqual" server/api/users/[path].ts` -- present at line 1124
- `grep "errorResponse(res, 503" server/api/users/[path].ts` -- present at line 1109
- Old `if (secret) {` fail-open pattern confirmed removed

## Known Stubs

None.

## Self-Check: PASSED

- FOUND: server/test/webhook-auth.test.ts
- FOUND: server/api/users/[path].ts
- FOUND: commit d9483df (RED)
- FOUND: commit df0fb31 (GREEN)

---
*Phase: 01-server-security-hardening*
*Completed: 2026-03-21*
