---
phase: 04-account-deletion-data-export-backend
plan: 01
subsystem: auth
tags: [prisma, soft-delete, jwt, auth-guard, async]

# Dependency graph
requires: []
provides:
  - "deletedAt DateTime? field on User model in Prisma schema"
  - "Async requireAuth() with soft-delete check rejecting deleted users with 401"
  - "All 26 call sites across [path].ts and [action].ts use await requireAuth()"
affects:
  - "04-02 (account deletion endpoint, data export endpoint, cron purge)"

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Soft-delete via nullable deletedAt timestamp on User model"
    - "Async auth guard with DB lookup for deletion status"

key-files:
  created: []
  modified:
    - "server/prisma/schema.prisma"
    - "server/lib/auth.ts"
    - "server/api/users/[path].ts"
    - "server/api/generate/[action].ts"

key-decisions:
  - "Used prisma.user.findUnique with select: { deletedAt: true } for minimal DB query overhead in auth guard"
  - "Soft-deleted users receive same 401 error message as invalid tokens to prevent information leakage"

patterns-established:
  - "Soft-delete pattern: nullable deletedAt timestamp checked in auth middleware before any endpoint logic"

requirements-completed: [COMP-03]

# Metrics
duration: 4min
completed: 2026-03-21
---

# Phase 04 Plan 01: Schema + Auth Guard Foundation Summary

**Added deletedAt soft-delete field to User model and converted requireAuth to async with DB-backed deletion check across all 26 authenticated endpoints**

## Performance

- **Duration:** 4 min
- **Started:** 2026-03-21T20:42:41Z
- **Completed:** 2026-03-21T20:46:27Z
- **Tasks:** 2
- **Files modified:** 4

## Accomplishments
- Added nullable `deletedAt DateTime?` field to the User model in Prisma schema, positioned between `appleId` and `createdAt`
- Converted `requireAuth()` from synchronous to async with a `prisma.user.findUnique` soft-delete check
- Updated all 21 call sites in `server/api/users/[path].ts` and all 5 in `server/api/generate/[action].ts` to use `await requireAuth()`
- TypeScript compiles cleanly with zero errors; all 93 existing tests pass unchanged

## Task Commits

Each task was committed atomically:

1. **Task 1: Add deletedAt field to User model and run migration** - `757c411` (chore)
2. **Task 2: Convert requireAuth to async with soft-delete check and update all 26 call sites** - `b0358fa` (feat)

## Files Created/Modified
- `server/prisma/schema.prisma` - Added `deletedAt DateTime?` field to User model
- `server/lib/auth.ts` - Converted requireAuth to async, added prisma import and soft-delete check
- `server/api/users/[path].ts` - Updated 21 requireAuth call sites to use await
- `server/api/generate/[action].ts` - Updated 5 requireAuth call sites to use await

## Decisions Made
- Used `select: { deletedAt: true }` in the findUnique query to minimize data transferred from database
- Soft-deleted users receive the generic "Invalid or expired token" 401 message (same as expired JWT) to avoid leaking account deletion status to potential attackers
- No migration file generated since no DATABASE_URL is available locally; `prisma generate` was used instead to update the client types

## Deviations from Plan

None - plan executed exactly as written.

## Known Stubs

None - no stubs or placeholders were introduced.

## Issues Encountered
- Global npx resolved Prisma 7.5.0 which is incompatible with the project's Prisma 6.4.1 schema format; resolved by running `npm install` first to ensure the local Prisma CLI was available

## Next Phase Readiness
- Schema foundation in place for account deletion (Plan 02 depends on `deletedAt` field)
- Auth guard now blocks soft-deleted users, enabling safe DELETE /api/users/me implementation
- All authenticated endpoints will automatically reject deleted users without any additional changes

## Self-Check: PASSED

- All 4 modified files verified on disk
- Both task commits (757c411, b0358fa) verified in git log
- SUMMARY.md created at expected path

---
*Phase: 04-account-deletion-data-export-backend*
*Plan: 01*
*Completed: 2026-03-21*
