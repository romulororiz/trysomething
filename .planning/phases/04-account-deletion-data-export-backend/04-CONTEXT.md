# Phase 4: Account Deletion + Data Export — Backend - Context

**Gathered:** 2026-03-21
**Status:** Ready for planning

<domain>
## Phase Boundary

Server-side endpoints for account deletion and data export. `DELETE /api/users/me` soft-deletes the user with a 30-day grace period before hard purge. `GET /api/users/me/export` returns a complete JSON package of all personal data. Flutter UX for triggering these endpoints is Phase 5.

</domain>

<decisions>
## Implementation Decisions

### Deletion API contract
- **D-01:** `DELETE /api/users/me` requires password in request body: `{ "password": "..." }`. Server verifies with bcrypt before proceeding.
- **D-02:** Response on success: `200 { "status": "scheduled", "deletedAt": "...", "purgeAt": "..." }` — confirms soft-delete with 30-day purge date.
- **D-03:** No undo/reactivation window. Once deleted, auth middleware immediately rejects the user's tokens. The account cannot be recovered.

### Soft-delete mechanism
- **D-04:** Add `deletedAt DateTime?` field to User model in Prisma schema. When deletion is requested, set `deletedAt = now()` instead of hard-deleting.
- **D-05:** Auth middleware (`requireAuth()`) must check `deletedAt` — if set, return 401 regardless of valid JWT. This is a new check that doesn't exist today.
- **D-06:** Related rows across all 14 tables are NOT deleted during soft-delete. They persist until the hard purge.

### 30-day hard purge
- **D-07:** Vercel Cron Job runs daily. Queries `WHERE deletedAt IS NOT NULL AND deletedAt < NOW() - 30 days`. Hard-deletes matching users with cascading delete across all 14 related tables.
- **D-08:** Cron endpoint: `GET /api/cron/purge-deleted-users` with Vercel cron auth header verification (`CRON_SECRET`).
- **D-09:** Add cron config to `vercel.json`: `"crons": [{ "path": "/api/cron/purge-deleted-users", "schedule": "0 3 * * *" }]` (daily at 3 AM UTC).

### Data export
- **D-10:** `GET /api/users/me/export` returns JSON with `Content-Disposition: attachment; filename=trysomething-export.json` and `Content-Type: application/json`.
- **D-11:** Export includes all user-owned data across 14 tables, structured by category: profile, preferences, hobbies (with steps, notes, shopping), journal entries, schedule, activity log, stories, buddy pairs, challenges, achievements.
- **D-12:** Excluded fields: `passwordHash`, `revenuecatId`, `appleId`, `googleId`, and `GenerationLog` internal fields (model, promptTokens, completionTokens, rawResponse).
- **D-13:** Use existing `map*()` functions from `server/lib/mappers.ts` where available to normalize DB records in the export.

### RevenueCat on deletion
- **D-14:** Do nothing with RevenueCat on deletion. Let the subscription run its natural course. Apple/Google prohibit revoking a paid period. The webhook handler already returns 401 for deleted users (via D-05), and RevenueCat handles that gracefully.

### GenerationLog handling
- **D-15:** `GenerationLog` has a `userId` field but no FK relation in Prisma schema. During hard purge, explicitly delete `GenerationLog` rows matching the userId before deleting the User row. Include only sanitized fields (query, status, createdAt) in data export — exclude model, promptTokens, completionTokens, rawResponse.

### Claude's Discretion
- Exact Prisma migration strategy (single migration vs multiple)
- Export JSON structure and nesting
- Error handling edge cases (concurrent deletion requests, export during deletion window)
- Cron job logging and error reporting
- Test structure and coverage approach

</decisions>

<specifics>
## Specific Ideas

- The 14 related tables with `onDelete: Cascade` in the schema will handle cascading during hard purge automatically — except `GenerationLog` which needs explicit deletion
- `prisma.$transaction()` is already used in `handleHobbiesSync()` — same pattern for atomic operations
- Existing `requireAuth()` in `server/lib/auth.ts` returns `{ sub: userId }` — the `deletedAt` check should query the User table and reject if set

</specifics>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Database schema
- `server/prisma/schema.prisma` — All 25 models, FK relationships, cascade rules, User model structure

### Auth system
- `server/lib/auth.ts` — JWT validation, `requireAuth()`, `verifyAccessToken()`, bcrypt config
- `server/lib/middleware.ts` — CORS, method check, `errorResponse()` helper

### User endpoints (pattern reference)
- `server/api/users/[path].ts` — All 22 user handlers, switch-on-path pattern, auth guard usage

### Mappers (for export)
- `server/lib/mappers.ts` — DB→API response mappers to reuse in export

### Routing
- `server/vercel.json` — Route config, where to add cron and new endpoint routes

### Existing tests
- `server/test/routes_users.test.ts` — Test patterns for user endpoints

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `requireAuth(req, res)` in `auth.ts` — JWT validation, returns `{ sub: userId }` or null
- `errorResponse(res, status, message)` in `middleware.ts` — Standardized error format
- `prisma.$transaction()` — Already used in `handleHobbiesSync()` for atomic multi-table ops
- `map*()` functions in `mappers.ts` — DB record normalization for API responses
- `bcrypt.compare()` already imported and used in `auth.ts` for password verification

### Established Patterns
- All user endpoints follow: `requireAuth()` → extract `userId` → switch on HTTP method → handler function
- Routes configured in `vercel.json` with regex patterns mapping to `[path].ts?path=<action>`
- Error responses use `errorResponse(res, statusCode, "message")`

### Integration Points
- `server/api/users/[path].ts` — Add `me` DELETE handler and `export` GET handler to existing switch
- `server/lib/auth.ts` — Add `deletedAt` check to `requireAuth()`
- `server/prisma/schema.prisma` — Add `deletedAt` field to User model
- `server/vercel.json` — Add cron config and ensure routes cover new endpoints

</code_context>

<deferred>
## Deferred Ideas

- Flutter UX for account deletion (confirmation dialog, progress, success screen) — Phase 5
- RevenueCat subscription cancellation API integration — not needed (D-14)
- Admin dashboard for viewing/managing deleted accounts — not in scope

</deferred>

---

*Phase: 04-account-deletion-data-export-backend*
*Context gathered: 2026-03-21*
