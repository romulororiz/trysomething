# Phase 2: Apple OAuth Routing Fix - Context

**Gathered:** 2026-03-21
**Status:** Ready for planning

<domain>
## Phase Boundary

Fix the Vercel route regex so `/api/auth/apple` reaches the existing `handleApple()` handler instead of returning 404. The handler code is complete — only the routing config is broken.

</domain>

<decisions>
## Implementation Decisions

### Route fix
- **D-01:** Add `|apple` to the auth action regex in `server/vercel.json` line 11 — change `(register|login|refresh|google)` to `(register|login|refresh|google|apple)`
- **D-02:** No other files need modification — `handleApple()` at `server/api/auth/[action].ts` line 341 is fully implemented and the switch case at line 35 already handles `"apple"`

### Claude's Discretion
- Whether to add a verification test (curl/vitest) for the route
- Test file naming and structure

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Routing config
- `server/vercel.json` line 11 — Auth route regex (the broken line)

### Apple auth handler
- `server/api/auth/[action].ts` lines 35-36 — Switch case for `"apple"` (already exists)
- `server/api/auth/[action].ts` lines 341+ — `handleApple()` full implementation (already exists)

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `handleApple()` — Complete Apple Sign-In handler with identity token verification, user creation/lookup, and JWT issuance
- `handleGoogle()` — Existing OAuth pattern to match (same structure, same response format)

### Established Patterns
- Auth routes consolidated in `[action].ts` with switch-case routing
- Vercel.json regex groups route all actions to single handler file
- All OAuth handlers follow same pattern: validate token → find/create user → issue JWT pair

### Integration Points
- `server/vercel.json` line 11 — the only file that needs modification
- Flutter `auth_provider.dart` already has Apple Sign-In client logic that calls `/api/auth/apple`

</code_context>

<specifics>
## Specific Ideas

No specific requirements — this is a one-line config fix. The regex pattern is clear from the existing `google` entry.

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 02-apple-oauth-routing-fix*
*Context gathered: 2026-03-21*
