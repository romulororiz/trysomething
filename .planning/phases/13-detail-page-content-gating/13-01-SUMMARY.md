---
phase: 13-detail-page-content-gating
plan: 01
subsystem: api
tags: [auth, pro-gating, ai-generation, server-side, content-guard]

# Dependency graph
requires:
  - phase: 11-schema-migration
    provides: subscriptionTier field on User model
provides:
  - requirePro() helper for Pro tier enforcement
  - Server-side 403 gating on faq/cost/budget generation endpoints
affects: [13-02 (client-side gating UI), 14-pause-resume]

# Tech tracking
tech-stack:
  added: []
  patterns: [cache-first-gate-second, sentinel-return-pattern]

key-files:
  created: []
  modified:
    - server/lib/auth.ts
    - server/api/generate/[action].ts

key-decisions:
  - "PAID_TIERS constant array for DRY tier checking -- avoids repeating pro/trial/lifetime strings"
  - "requirePro follows requireAuth sentinel pattern: sends own error response, returns boolean for caller to early-return"

patterns-established:
  - "Cache-first gate-second: always check DB cache before enforcing Pro tier, so free users retain access to previously generated content"
  - "Sentinel return pattern for auth helpers: requireAuth returns null, requirePro returns false -- caller checks and returns early"

requirements-completed: [GATE-05]

# Metrics
duration: 2min
completed: 2026-03-23
---

# Phase 13 Plan 01: Server-Side Pro Tier Gating Summary

**requirePro() helper + cache-first 403 gating on faq/cost/budget AI generation endpoints**

## Performance

- **Duration:** 2 min
- **Started:** 2026-03-23T18:20:36Z
- **Completed:** 2026-03-23T18:22:58Z
- **Tasks:** 2
- **Files modified:** 2

## Accomplishments
- Added `requirePro()` exported helper to `server/lib/auth.ts` that checks `subscriptionTier` against paid tiers (pro, trial, lifetime)
- Gated three AI generation handlers (faq, cost, budget) with Pro enforcement after cache check -- free users get 403 only when new generation would be triggered
- Preserved cached content access for all users (200) and left hobby generation + coach chat ungated

## Task Commits

Each task was committed atomically:

1. **Task 1: Add requirePro() helper to server/lib/auth.ts** - `52ae88c` (feat)
2. **Task 2: Gate faq, cost, budget handlers with requirePro after cache check** - `66dd51a` (feat)

## Files Created/Modified
- `server/lib/auth.ts` - Added `requirePro()` function with PAID_TIERS constant, follows requireAuth sentinel pattern
- `server/api/generate/[action].ts` - Added `requirePro` import, inserted Pro gate after cache check in handleGenerateFaq, handleGenerateCost, handleGenerateBudget

## Decisions Made
- Used a `PAID_TIERS` constant array instead of inline string comparisons for maintainability when tiers change
- requirePro takes `(userId, res)` not `(req, res)` since userId is already extracted by requireAuth -- avoids redundant token parsing

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered
- Pre-existing tsconfig.json issue: `"ignoreDeprecations": "6.0"` is invalid for TypeScript 5.9.3 (dropped support after TS 5.4). Does not affect compilation of project code. Logged as out-of-scope discovery.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness
- Server-side gating is in place for Plan 02 to build client-side UI that responds to 403
- requirePro is reusable for any future endpoint that needs Pro enforcement

## Self-Check: PASSED

- [x] server/lib/auth.ts exists
- [x] server/api/generate/[action].ts exists
- [x] 13-01-SUMMARY.md exists
- [x] Commit 52ae88c exists (Task 1)
- [x] Commit 66dd51a exists (Task 2)
- [x] requirePro exported from auth.ts (1 match)
- [x] requirePro imported in [action].ts (1 match)

---
*Phase: 13-detail-page-content-gating*
*Completed: 2026-03-23*
