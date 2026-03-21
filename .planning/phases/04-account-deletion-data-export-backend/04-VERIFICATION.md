---
phase: 04-account-deletion-data-export-backend
verified: 2026-03-21T21:30:00Z
status: passed
score: 6/6 must-haves verified
re_verification: false
---

# Phase 04: Account Deletion + Data Export Backend Verification Report

**Phase Goal:** Server correctly deletes all user data atomically and exports a complete, safe JSON package on request
**Verified:** 2026-03-21T21:30:00Z
**Status:** passed
**Re-verification:** No — initial verification

---

## Goal Achievement

### Observable Truths (from Success Criteria)

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | `DELETE /api/users/me` with a valid JWT deletes the user and all related rows atomically — no orphan rows | VERIFIED | `prisma.user.update({ data: { deletedAt: now } })` in `handleMe`; 13 cascade tables confirmed in schema; GenerationLog explicitly deleted in cron `$transaction` |
| 2 | Sending a request with the same JWT after deletion returns 401 (soft-delete `deletedAt` check in auth middleware) | VERIFIED | `requireAuth()` calls `prisma.user.findUnique({ select: { deletedAt: true } })` and returns 401 if `user.deletedAt` is truthy (`auth.ts` lines 64–70) |
| 3 | Sending a request with the same JWT after deletion returns 401 (duplicate of criterion 2) | VERIFIED | Same mechanism as above; `deletion.test.ts` test "returns 401 for soft-deleted user" confirms the path |
| 4 | A deleted user's account is not purged immediately — `deletedAt` is set and the row persists for 30 days before hard purge | VERIFIED | DELETE sets `deletedAt: now` (no row removal); cron handler uses `cutoff = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000)` with `deletedAt: { lte: cutoff }` |
| 5 | `GET /api/users/me/export` returns a JSON file attachment containing all personal data with sensitive fields excluded | VERIFIED | `handleExport` explicitly constructs `exportData` object selecting only safe fields; `passwordHash`, `revenuecatId`, `googleId`, `appleId`, `GenerationLog` never appear in the object |
| 6 | Export response has `Content-Disposition: attachment; filename=trysomething-export.json` and `Content-Type: application/json` | VERIFIED | `res.setHeader("Content-Type", "application/json")` and `res.setHeader("Content-Disposition", "attachment; filename=trysomething-export.json")` at `[path].ts` lines 1374–1378 |

**Score:** 6/6 truths verified

---

### Required Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `server/prisma/schema.prisma` | `deletedAt DateTime?` field on User model between `appleId` and `createdAt` | VERIFIED | Line 168: `deletedAt    DateTime?` — positioned correctly between `appleId` (167) and `createdAt` (169) |
| `server/lib/auth.ts` | Async `requireAuth` with soft-delete DB check | VERIFIED | `export async function requireAuth(...)` with `Promise<string \| null>`; imports `prisma` from `./db`; checks `user.deletedAt` |
| `server/api/users/[path].ts` | DELETE handler in `handleMe` + `export` case + `handleExport` function | VERIFIED | Lines 102–140: DELETE branch; line 83–84: `case "export"` routing; lines 1234–1384: full `handleExport` function |
| `server/api/cron/purge-deleted-users.ts` | Daily cron handler for hard-purging soft-deleted users | VERIFIED | 59 lines; CRON_SECRET check; 30-day cutoff; `prisma.$transaction([generationLog.deleteMany, user.deleteMany])` |
| `server/vercel.json` | Cron schedule and routes for purge + export | VERIFIED | Route for `/api/users/me/export` at line 11 (before `me\|preferences` regex at line 35); cron schedule `0 3 * * *` at lines 47–51 |
| `server/test/deletion.test.ts` | Tests for DELETE endpoint and requireAuth rejection | VERIFIED | 5 tests: soft-delete, invalid password, OAuth skip, missing password, deleted user 401 |
| `server/test/export.test.ts` | Tests for export endpoint headers and field exclusion | VERIFIED | 3 tests: Content-Disposition header, all data categories, excluded sensitive fields |
| `server/test/cron-purge.test.ts` | Tests for cron authentication and purge logic | VERIFIED | 5 tests: CRON_SECRET auth, method guard, empty purge, transaction, 30-day cutoff |

---

### Key Link Verification

| From | To | Via | Status | Details |
|------|-----|-----|--------|---------|
| `server/lib/auth.ts` | `server/lib/db.ts` | `prisma.user.findUnique` in `requireAuth` | WIRED | `import { prisma } from "./db"` at line 5; `prisma.user.findUnique({ where: { id: sub }, select: { deletedAt: true } })` at lines 64–67 |
| `server/api/users/[path].ts` | `server/lib/auth.ts` | `await requireAuth(req, res)` at all 22 call sites | WIRED | `import { requireAuth, comparePassword } from "../../lib/auth"` at line 8; 22 `await requireAuth` calls (21 original + 1 in `handleExport`) |
| `server/api/generate/[action].ts` | `server/lib/auth.ts` | `await requireAuth(req, res)` | WIRED | 5 occurrences confirmed; all using `await` |
| `server/api/users/[path].ts` | `prisma.user.update` | Soft-delete sets `deletedAt` | WIRED | `prisma.user.update({ where: { id: userId }, data: { deletedAt: now } })` at lines 131–134 |
| `server/api/users/[path].ts` | `server/lib/auth.ts` | `comparePassword` for DELETE verification | WIRED | `import { requireAuth, comparePassword }` at line 8; `await comparePassword(password, user.passwordHash)` at line 120 |
| `server/api/cron/purge-deleted-users.ts` | `prisma.$transaction` | Atomic GenerationLog + User hard-delete | WIRED | `await prisma.$transaction([prisma.generationLog.deleteMany(...), prisma.user.deleteMany(...)])` at lines 48–51 |
| `server/vercel.json` | `server/api/cron/purge-deleted-users.ts` | Cron routing | WIRED | Route `{ "src": "/api/cron/purge-deleted-users", "dest": "/api/cron/purge-deleted-users.ts" }` at line 10; cron schedule at lines 47–51 |
| `server/vercel.json` | `server/api/users/[path].ts` | Export route before `me\|preferences` regex | WIRED | `/api/users/me/export` route at line 11 appears before `(me\|preferences)` catch-all at line 35 |

---

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
|-------------|-------------|-------------|--------|----------|
| COMP-01 | 04-01, 04-02 | Account deletion endpoint (`DELETE /api/users/me`) with password verification and immediate lockout | SATISFIED | DELETE handler in `handleMe`; password check via `comparePassword`; `requireAuth` blocks deleted users with 401 immediately |
| COMP-02 | 04-02 | Cascading data removal across all user tables | SATISFIED | 13 user-related tables have `onDelete: Cascade` in schema; `GenerationLog` explicitly deleted in cron `$transaction` before `user.deleteMany` |
| COMP-03 | 04-01, 04-02 | 30-day retention before hard purge | SATISFIED | `deletedAt DateTime?` on User model; cron uses `deletedAt: { lte: cutoff }` where cutoff is 30 days ago; `purgeAt` = `deletedAt + 30d` returned in DELETE response |
| COMP-06 | 04-02 | Data export endpoint (`GET /api/users/me/export`) with JSON attachment headers | SATISFIED | `handleExport` returns `Content-Type: application/json` and `Content-Disposition: attachment; filename=trysomething-export.json` |
| COMP-07 | 04-02 | Export must include all personal data | SATISFIED | `handleExport` includes all 13 data categories: account, preferences, hobbies (with completedSteps), activityLogs, journalEntries, personalNotes, scheduleEvents, shoppingChecks, communityStories, storyReactions, buddyConnections, challenges, achievements |
| COMP-08 | 04-02 | Export must exclude sensitive/internal fields | SATISFIED | Export object explicitly constructed; `passwordHash`, `revenuecatId`, `googleId`, `appleId`, and `GenerationLog` never queried or included; `export.test.ts` validates absence of raw field values and key names |

No orphaned requirements. All 6 IDs in the `requirements:` frontmatter of plans 01 and 02 are accounted for, match the definitions in `04-RESEARCH.md`, and are satisfied.

---

### Anti-Patterns Found

No blockers or warnings identified.

| File | Pattern Checked | Result |
|------|----------------|--------|
| `server/api/users/[path].ts` DELETE branch | Return value of `prisma.user.update` not used | INFO — deliberate; only `deletedAt` is needed in the response, not the full updated row |
| `server/api/cron/purge-deleted-users.ts` | `$transaction` array form (not interactive) | INFO — intentional as documented in RESEARCH.md; no conditional logic required |
| `server/api/users/[path].ts` | 22 `await requireAuth` calls vs. plan's claimed 21 | INFO — expected; `handleExport` added in plan 02 adds the 22nd call site; all are `await`; zero non-await calls confirmed |

---

### Human Verification Required

The following behaviors are correct in code but require a real server deployment with a live database to fully confirm:

#### 1. DELETE endpoint atomicity under real Prisma cascade

**Test:** With a real database, create a user with rows in all 13 related tables. Call `DELETE /api/users/me` with valid JWT and password. After the `deletedAt` is set and 30 days pass, run the cron. Then query all 14 tables for the userId.
**Expected:** Zero rows remain in all 14 tables including `GenerationLog`.
**Why human:** Cannot verify cascading deletes against a real Postgres database from static analysis; Prisma schema declares `onDelete: Cascade` but actual DB enforcement needs migration applied.

#### 2. JWT rejection timing after soft-delete

**Test:** Call `DELETE /api/users/me` with a valid 15-minute JWT. Immediately reuse that same JWT for `GET /api/users/me`.
**Expected:** 401 response — `requireAuth` queries the database and sees `deletedAt` is set.
**Why human:** Requires live server with JWT_SECRET configured.

#### 3. Export file download in browser/Flutter client

**Test:** Call `GET /api/users/me/export` from a browser or HTTP client that respects `Content-Disposition`.
**Expected:** The response triggers a file download named `trysomething-export.json`.
**Why human:** `Content-Disposition` behavior is client-controlled; header correctness is verified in code but client handling cannot be checked statically.

#### 4. CRON_SECRET environment variable configured in Vercel

**Test:** Deploy to Vercel. Confirm `CRON_SECRET` is set in project environment variables. Trigger the cron manually via Vercel dashboard.
**Expected:** Cron runs, logs `purged: N`, no 401 errors.
**Why human:** Environment variable configuration is outside the codebase; cannot be verified statically.

---

### Commit Verification

All 5 task commits verified in git log:

| Commit | Task | Type |
|--------|------|------|
| `757c411` | Add deletedAt field to User model | chore |
| `b0358fa` | Convert requireAuth to async with soft-delete check | feat |
| `fdd4598` | Add DELETE /api/users/me and GET /api/users/me/export endpoints | feat |
| `677ec68` | Add cron purge handler and update vercel.json routes | feat |
| `844d3da` | Add tests for deletion, export, and cron-purge endpoints | test |

---

### Summary

Phase 04 achieves its goal. The server correctly:

1. Soft-deletes users by setting `deletedAt` on the User row (not immediate removal)
2. Immediately rejects soft-deleted users with 401 via the upgraded async `requireAuth`
3. Retains user data for 30 days before the Vercel Cron hard-purges via `$transaction` (GenerationLog first, then User cascade)
4. Exports a complete, sanitized JSON attachment for all 13 personal data categories
5. Excludes all sensitive/internal fields (`passwordHash`, `revenuecatId`, `googleId`, `appleId`, `GenerationLog`) from the export

All 6 requirement IDs (COMP-01, COMP-02, COMP-03, COMP-06, COMP-07, COMP-08) are satisfied. Tests cover all happy paths and error branches. No stubs, no orphaned code, no placeholder implementations.

The only items requiring human verification are environment-dependent (live DB, Vercel deployment, CRON_SECRET configuration) and cannot be checked statically.

---

_Verified: 2026-03-21T21:30:00Z_
_Verifier: Claude (gsd-verifier)_
