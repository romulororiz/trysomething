---
phase: 01-server-security-hardening
plan: 02
subsystem: api
tags: [rate-limiting, generationlog, prisma, coach, security]

# Dependency graph
requires:
  - phase: none
    provides: "Existing GenerationLog model with @@index([userId, createdAt])"
provides:
  - "checkCoachRateLimit utility (server/lib/rate_limit.ts)"
  - "Server-side coach rate limiting: 3 msgs/30 days for free users"
  - "GenerationLog logging for coach messages with query='coach'"
affects: [ai-upgrade, subscription]

# Tech tracking
tech-stack:
  added: []
  patterns: ["Reusable rate limit utility importing Prisma singleton from db.ts"]

key-files:
  created:
    - server/lib/rate_limit.ts
    - server/test/rate-limit.test.ts
  modified:
    - server/api/generate/[action].ts

key-decisions:
  - "Used query='coach' field in GenerationLog to distinguish coach messages from hobby generations"
  - "Log after AI response succeeds (not before) to prevent failed API calls from counting against limit"
  - "rate_limit.ts imports Prisma singleton from db.ts while [action].ts keeps its own PrismaClient (out of scope to change)"

patterns-established:
  - "Rate limit utility pattern: check subscription tier first, query GenerationLog for rolling window count"
  - "vi.hoisted() pattern for Vitest mock factories that reference variables"

requirements-completed: [SEC-02]

# Metrics
duration: 2min
completed: 2026-03-21
---

# Phase 1 Plan 2: Coach Rate Limiting Summary

**Server-side rate limiting for AI coach: 3 msgs/30 days for free users via GenerationLog count, Pro/lifetime bypass without DB query**

## Performance

- **Duration:** 2 min
- **Started:** 2026-03-21T19:08:45Z
- **Completed:** 2026-03-21T19:11:14Z
- **Tasks:** 2
- **Files modified:** 3

## Accomplishments
- Created reusable `checkCoachRateLimit` utility that enforces 3-message/30-day cap for free users
- Pro and lifetime users bypass rate limit entirely (no database query)
- Wired rate limiting into `handleCoachChat` with subscription tier lookup
- Added GenerationLog logging for successful coach messages (logged AFTER AI response)
- 5 unit tests covering all rate limit scenarios (pro bypass, lifetime bypass, under limit, over limit, query filters)
- Full server test suite green (103 tests, 10 files, 0 regressions)

## Task Commits

Each task was committed atomically:

1. **Task 1: Create rate_limit.ts utility and its test file** - `346ee0c` (feat)
2. **Task 2: Wire rate limit into handleCoachChat and add GenerationLog logging** - `b4e0f90` (feat)

## Files Created/Modified
- `server/lib/rate_limit.ts` - Reusable coach rate limit checker (queries GenerationLog, bypasses Pro/lifetime)
- `server/test/rate-limit.test.ts` - 5 unit tests for all rate limiting scenarios
- `server/api/generate/[action].ts` - Added rate limit check + GenerationLog logging to handleCoachChat

## Decisions Made
- Used `query: 'coach'` field in GenerationLog to distinguish coach messages from hobby generation messages -- no schema change needed
- Log successful coach messages AFTER the AI response succeeds to avoid counting failed/timed-out API calls against the user's limit
- rate_limit.ts imports Prisma singleton from db.ts; [action].ts continues using its own PrismaClient (changing that is out of scope per plan)
- Used `.catch(() => {})` on logGeneration call so logging failures don't crash the coach response

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Fixed Vitest mock hoisting with vi.hoisted()**
- **Found during:** Task 1 (rate-limit test creation)
- **Issue:** Plan's test code used `const mockCount = vi.fn()` before `vi.mock()`, but Vitest hoists `vi.mock()` above all declarations, causing "Cannot access 'mockCount' before initialization"
- **Fix:** Changed to `const { mockCount } = vi.hoisted(() => ({ mockCount: vi.fn() }))` which is the Vitest-compatible pattern for hoisted mock factories
- **Files modified:** server/test/rate-limit.test.ts
- **Verification:** All 5 tests pass
- **Committed in:** 346ee0c (Task 1 commit)

---

**Total deviations:** 1 auto-fixed (1 blocking)
**Impact on plan:** Necessary fix for test infrastructure compatibility. No scope creep.

## Issues Encountered
None beyond the Vitest mock hoisting issue documented above.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- Server-side rate limiting is live -- free users capped at 3 coach messages per rolling 30 days
- Coach messages now logged to GenerationLog with `query='coach'` for audit trail
- Phase 1 (server-security-hardening) plan 2 of 2 complete

## Self-Check: PASSED

- [x] server/lib/rate_limit.ts exists
- [x] server/test/rate-limit.test.ts exists
- [x] server/api/generate/[action].ts exists
- [x] .planning/phases/01-server-security-hardening/01-02-SUMMARY.md exists
- [x] Commit 346ee0c found (Task 1)
- [x] Commit b4e0f90 found (Task 2)

---
*Phase: 01-server-security-hardening*
*Completed: 2026-03-21*
