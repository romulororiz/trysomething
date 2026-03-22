---
phase: 08-sonnet-ai-upgrade
plan: 01
subsystem: api
tags: [claude-ai, sonnet, json-parsing, ai-generator, error-handling]

# Dependency graph
requires: []
provides:
  - "extractJson<T>() utility for safe AI response parsing in ai_generator.ts"
  - "Verified Sonnet model (claude-sonnet-4-6) deployed for all AI endpoints"
  - "Verified lastActivityAt stale detection in coach"
affects: [09-app-store-assets]

# Tech tracking
tech-stack:
  added: []
  patterns: ["extractJson<T>() centralizes AI JSON parsing with code-fence stripping and descriptive errors"]

key-files:
  created: []
  modified:
    - "server/lib/ai_generator.ts"

key-decisions:
  - "No model changes needed: AI-01 (Sonnet) and AI-02 (stale detection) were already deployed"
  - "extractJson uses regex to match first code fence block rather than simple replace, handling edge cases better"

patterns-established:
  - "extractJson<T>(): All AI response JSON parsing goes through this single function with type parameter"
  - "Descriptive error messages: AI parse failures include a preview of the malformed text for debugging"

requirements-completed: [AI-01, AI-02, AI-03]

# Metrics
duration: 2min
completed: 2026-03-22
---

# Phase 8 Plan 1: Sonnet AI Upgrade Summary

**Verified Sonnet model deployment, added extractJson() guard for AI JSON parsing across all 4 generation functions**

## Performance

- **Duration:** 2 min
- **Started:** 2026-03-22T11:34:51Z
- **Completed:** 2026-03-22T11:37:00Z
- **Tasks:** 1
- **Files modified:** 1

## Accomplishments
- Verified AI-01: both MODEL and COACH_MODEL constants are `claude-sonnet-4-6` (already deployed)
- Verified AI-02: coach stale detection uses `lastActivityAt ?? startedAt` fallback (already deployed)
- Implemented AI-03: exported `extractJson<T>()` function that strips markdown code fences, handles empty input, and wraps JSON.parse with descriptive error messages
- Replaced all 4 inline code-fence-strip + JSON.parse patterns with `extractJson()` calls using specific type parameters

## Task Commits

Each task was committed atomically:

1. **Task 1: Verify AI-01 and AI-02, create extractJson() and wire into all 4 generation functions** - `1d0975d` (feat)

## Files Created/Modified
- `server/lib/ai_generator.ts` - Added extractJson<T>() utility; replaced 4 inline JSON parse patterns with typed extractJson() calls

## Decisions Made
- AI-01 and AI-02 were already deployed in production code -- no changes needed, only verification
- Used regex capture group `(/^```(?:json)?\s*\n?([\s\S]*?)\n?\s*```/m)` to extract first code fence block content, which is more robust than the previous dual-replace approach

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered
- Pre-existing test failure in `test/cron-purge.test.ts` (5 tests) -- the test imports `api/cron/purge-deleted-users.ts` which does not exist yet. This is from Phase 04 account deletion work and is unrelated to AI upgrade changes. Logged to `deferred-items.md`. All 12 other test files (111 tests) pass.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness
- All AI requirements (AI-01, AI-02, AI-03) are complete
- Phase 08 is done with a single plan -- ready for phase transition to Phase 09 (app store assets)
- AI-generated responses are now protected against Sonnet's occasional code-fence-wrapped JSON output

## Self-Check: PASSED

- FOUND: server/lib/ai_generator.ts
- FOUND: .planning/phases/08-sonnet-ai-upgrade/08-01-SUMMARY.md
- FOUND: commit 1d0975d

---
*Phase: 08-sonnet-ai-upgrade*
*Completed: 2026-03-22*
