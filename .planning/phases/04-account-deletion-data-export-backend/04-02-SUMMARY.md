---
phase: 04-account-deletion-data-export-backend
plan: 02
subsystem: api
tags: [prisma, soft-delete, data-export, cron, vercel, compliance]

# Dependency graph
requires:
  - "04-01: deletedAt field on User model and async requireAuth with soft-delete check"
provides:
  - "DELETE /api/users/me endpoint with password verification and soft-delete"
  - "GET /api/users/me/export endpoint returning sanitized JSON data attachment"
  - "Daily cron handler at /api/cron/purge-deleted-users for hard-purging after 30 days"
  - "Vercel cron schedule (0 3 * * *) and routing for purge and export endpoints"
affects:
  - "Flutter app account deletion UI (needs to call DELETE /api/users/me)"
  - "Flutter app data export UI (needs to call GET /api/users/me/export)"
  - "Vercel deployment (new cron schedule and routes)"

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Soft-delete with 30-day retention before hard purge via Vercel Cron"
    - "CRON_SECRET Bearer token auth for cron endpoints"
    - "Data export with Content-Disposition attachment header for file download"
    - "Explicit GenerationLog deletion in transaction before cascading User delete"

key-files:
  created:
    - "server/api/cron/purge-deleted-users.ts"
    - "server/test/deletion.test.ts"
    - "server/test/export.test.ts"
    - "server/test/cron-purge.test.ts"
  modified:
    - "server/api/users/[path].ts"
    - "server/vercel.json"

key-decisions:
  - "Password verification required for email/password users on DELETE; skipped for OAuth-only users (empty passwordHash)"
  - "Export explicitly constructs sanitized object excluding passwordHash, revenuecatId, googleId, appleId, and GenerationLog"
  - "Cron handler uses prisma.$transaction with generationLog.deleteMany before user.deleteMany since GenerationLog has no FK cascade"
  - "Export route placed before (me|preferences) route in vercel.json to avoid regex matching conflict"

patterns-established:
  - "Cron endpoint pattern: Vercel Cron GET requests with CRON_SECRET Bearer auth"
  - "Data export pattern: Content-Disposition attachment header for JSON file download"

requirements-completed: [COMP-01, COMP-02, COMP-03, COMP-06, COMP-07, COMP-08]

# Metrics
duration: 4min
completed: 2026-03-21
---

# Phase 04 Plan 02: Account Deletion, Data Export, and Cron Purge Summary

**DELETE /api/users/me with password verification, GET /api/users/me/export with sanitized JSON attachment, and daily cron hard-purge of soft-deleted users after 30-day retention**

## Performance

- **Duration:** 4 min
- **Started:** 2026-03-21T20:50:32Z
- **Completed:** 2026-03-21T20:55:30Z
- **Tasks:** 3
- **Files modified:** 6

## Accomplishments
- Implemented DELETE /api/users/me with password verification for email/password users and skip for OAuth-only users, returning {status, deletedAt, purgeAt}
- Implemented GET /api/users/me/export returning all 13 user data categories as a sanitized JSON file attachment, excluding passwordHash, revenuecatId, googleId, appleId, and GenerationLog
- Created daily cron handler at /api/cron/purge-deleted-users that hard-deletes users with deletedAt > 30 days using $transaction (GenerationLog first, then User cascade)
- Updated vercel.json with cron schedule (0 3 * * *) and routes for both purge and export endpoints
- Created 13 new tests across 3 test files covering all requirement IDs; full test suite passes (106 tests)

## Task Commits

Each task was committed atomically:

1. **Task 1: Add DELETE handler to handleMe and add export endpoint** - `fdd4598` (feat)
2. **Task 2: Create cron handler for hard-purge and update vercel.json** - `677ec68` (feat)
3. **Task 3: Create test files for deletion, export, and cron endpoints** - `844d3da` (test)

## Files Created/Modified
- `server/api/users/[path].ts` - Added DELETE branch in handleMe with password verification, added handleExport function, added "export" case to switch
- `server/api/cron/purge-deleted-users.ts` - New cron handler for hard-purging soft-deleted users after 30-day retention
- `server/vercel.json` - Added cron schedule, purge route, and export route (before me|preferences to avoid regex conflict)
- `server/test/deletion.test.ts` - 5 tests: soft-delete, invalid password, OAuth skip, missing password, deleted user 401
- `server/test/export.test.ts` - 3 tests: Content-Disposition header, all data categories, excluded fields
- `server/test/cron-purge.test.ts` - 5 tests: CRON_SECRET auth, method guard, empty purge, transaction, 30-day cutoff

## Decisions Made
- Password verification required for email/password users on DELETE; OAuth-only users (empty passwordHash) skip the check entirely
- Export data is constructed by explicitly selecting only safe fields -- sensitive fields are never queried or included in the export object
- GenerationLog has no FK relation to User, so it must be explicitly deleted in the $transaction before the User delete (which cascades all 12 other related tables)
- Export route /api/users/me/export is placed before the (me|preferences) regex route in vercel.json to prevent the "me" portion from being caught by the generic route
- Purge At timestamp returned in DELETE response is calculated as 30 days from deletion time for user transparency

## Deviations from Plan

None - plan executed exactly as written.

## Known Stubs

None - no stubs or placeholders were introduced.

## Issues Encountered
None - all tasks completed without issues.

## User Setup Required
CRON_SECRET environment variable must be set in Vercel project settings for the cron handler to accept requests. Without it, all cron requests will be rejected with 401.

## Next Phase Readiness
- All backend endpoints for account deletion and data export are complete
- Flutter app can now implement UI for account deletion (DELETE /api/users/me with password confirmation dialog)
- Flutter app can now implement data export download (GET /api/users/me/export)
- CRON_SECRET needs to be configured in Vercel environment variables before deployment

## Self-Check: PASSED

- All 6 files (3 created, 3 modified) verified on disk
- All 3 task commits (fdd4598, 677ec68, 844d3da) verified in git log
- SUMMARY.md created at expected path

---
*Phase: 04-account-deletion-data-export-backend*
*Plan: 02*
*Completed: 2026-03-21*
