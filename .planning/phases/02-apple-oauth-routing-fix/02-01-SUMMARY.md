---
phase: 02-apple-oauth-routing-fix
plan: 01
subsystem: routing
tags: [vercel, apple-auth, oauth, routing]

requires:
  - phase: none
    provides: "No dependencies — one-line config fix"
provides:
  - "Apple OAuth route /api/auth/apple reachable via Vercel routing"
  - "Apple callback route /api/auth/apple-callback for Android web flow"
affects: [auth-flow, apple-sign-in]

tech-stack:
  added: []
  patterns: []

key-files:
  created: []
  modified:
    - server/vercel.json

key-decisions:
  - "Added both apple and apple-callback to the regex to support iOS native and Android web redirect flows"

metrics:
  duration: "1min"
  completed: "2026-03-21"
  tasks_completed: 1
  tasks_total: 1
  files_changed: 1
---

# Phase 02 Plan 01: Apple OAuth Routing Fix Summary

**Added `apple` and `apple-callback` to Vercel auth route regex so Apple Sign-In requests reach the existing handler**

## What Was Done

### Task 1: Fix auth route regex in vercel.json
**Commit:** `01890b6`

Changed the auth route regex in `server/vercel.json` from:
```
(register|login|refresh|google)
```
to include `apple`. A subsequent commit (`4ae5fb7`) also added `apple-callback` for the Android web redirect flow, resulting in:
```
(register|login|refresh|google|apple|apple-callback)
```

The `handleApple()` function in `server/api/auth/[action].ts` was already fully implemented with the switch case at line 35 — only the Vercel routing was preventing requests from reaching it.

## Deviations from Plan

- Also added `apple-callback` route for Android web flow (not in original context, but necessary for full Apple Sign-In support on Android where a web redirect is needed instead of native ASAuthorizationController).

## Commits

| Task | Commit | Message |
|------|--------|---------|
| 1 | `01890b6` | fix(quick-260321-s8z): add apple to auth route regex in vercel.json |
| 1b | `4ae5fb7` | feat: add Apple Sign-In callback for Android web flow |

## Self-Check: PASSED

- `server/vercel.json` contains `apple` and `apple-callback` in auth route regex
- Both commits verified in git log on master

---
*Phase: 02-apple-oauth-routing-fix*
*Completed: 2026-03-21*
