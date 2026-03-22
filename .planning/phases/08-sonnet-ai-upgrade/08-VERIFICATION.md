---
phase: 08-sonnet-ai-upgrade
verified: 2026-03-22T11:40:23Z
status: gaps_found
score: 4/5 must-haves verified
gaps:
  - truth: "All 4 generation functions use claude-sonnet-4-6 model ID"
    status: partial
    reason: "PLAN must_haves specify 'claude-sonnet-4-6' and the code constants match, but ROADMAP.md Success Criterion 1 specifies 'claude-sonnet-4-20250514'. Header comments in both files also say 'claude-sonnet-4-20250514'. The deployed model ID string does not match the ROADMAP success criterion. Either the ROADMAP criterion needs updating to reflect the already-deployed 'claude-sonnet-4-6', or the constants need updating to 'claude-sonnet-4-20250514'."
    artifacts:
      - path: "server/lib/ai_generator.ts"
        issue: "Header comment line 6 says 'claude-sonnet-4-20250514' but const MODEL on line 20 says 'claude-sonnet-4-6'"
      - path: "server/api/generate/[action].ts"
        issue: "Header comment line 9 says 'claude-sonnet-4-20250514' but const COACH_MODEL on line 36 says 'claude-sonnet-4-6'"
    missing:
      - "Resolve model ID discrepancy: update ROADMAP.md success criterion 1 to match 'claude-sonnet-4-6' (if that is the correct ID), OR update both constants to 'claude-sonnet-4-20250514' (if the ROADMAP intent was the specific release alias). Update stale header comments in both files to match whichever value is chosen."
human_verification:
  - test: "Verify that 'claude-sonnet-4-6' is a valid Anthropic model ID that resolves to Claude Sonnet"
    expected: "A POST to /api/generate/hobby with a valid JWT returns a 201 with a full hobby profile, confirming the model ID is accepted by the Anthropic API"
    why_human: "Cannot confirm whether 'claude-sonnet-4-6' is an alias for 'claude-sonnet-4-20250514' or a different model without calling the live Anthropic API"
---

# Phase 8: Sonnet AI Upgrade Verification Report

**Phase Goal:** All AI generation runs on Claude Sonnet with hardened prompts, correct stale detection, and safe JSON parsing
**Verified:** 2026-03-22T11:40:23Z
**Status:** gaps_found
**Re-verification:** No — initial verification

---

## Goal Achievement

### Observable Truths

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | All 4 generation functions use claude-sonnet-4-6 model ID | ⚠ PARTIAL | `const MODEL = "claude-sonnet-4-6"` (line 20) and `const COACH_MODEL = "claude-sonnet-4-6"` (line 36) are in code; all 4 generation functions call `client.messages.create({ model: MODEL, ... })`. However, ROADMAP Success Criterion 1 requires `claude-sonnet-4-20250514` — the string in the constants does not match. Header comments in both files (stale) also say `claude-sonnet-4-20250514`. |
| 2 | Coach stale detection uses lastActivityAt with startedAt fallback | ✓ VERIFIED | `const lastActivity = userHobby.lastActivityAt ?? userHobby.startedAt;` at `server/api/generate/[action].ts` line 461. Used to compute `daysSinceLastSession` for RESCUE mode detection. |
| 3 | All AI JSON parsing goes through extractJson() with try/catch error handling | ✓ VERIFIED | `grep -c extractJson server/lib/ai_generator.ts` returns 8. `grep -c 'JSON\.parse' server/lib/ai_generator.ts` returns 1 (inside `extractJson` only). All 4 generation functions (`generateHobbyContent`, `generateFaqContent`, `generateCostContent`, `generateBudgetContent`) call `extractJson(text)` as their sole JSON parse step. |
| 4 | extractJson() strips markdown code fences before JSON.parse | ✓ VERIFIED | Function body contains `const fenceMatch = cleaned.match(/^```(?:json)?\s*\n?([\s\S]*?)\n?\s*```/m);` which captures the inner content of the first code fence block. Falls through to full text if no fence found. |
| 5 | Malformed AI output produces a descriptive error, not a raw SyntaxError | ✓ VERIFIED | try/catch in `extractJson` throws `new Error(\`extractJson: failed to parse AI response as JSON. Preview: ${preview}\`)` where preview contains first 200 chars of malformed text. Empty input throws `"extractJson: received empty response from AI model"`. |

**Score:** 4/5 truths verified (1 partial due to model ID string mismatch vs ROADMAP criterion)

---

### Required Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `server/lib/ai_generator.ts` | extractJson utility + all 4 generation functions using it | ✓ VERIFIED | File exists (466 lines). `export function extractJson<T = unknown>(text: string): T` defined and exported. All 4 generation functions present and use `extractJson`. Imported by `server/api/generate/[action].ts`. |

**Artifact wiring check:**

- `generateHobbyContent`, `generateFaqContent`, `generateCostContent`, `generateBudgetContent` imported at `[action].ts` lines 20-24 — WIRED
- All 4 functions used in their respective handler functions (`handleGenerateHobby`, `handleGenerateFaq`, `handleGenerateCost`, `handleGenerateBudget`) — WIRED

---

### Key Link Verification

| From | To | Via | Status | Details |
|------|----|-----|--------|---------|
| `generateHobbyContent` | `extractJson` | function call | ✓ WIRED | Line 181: `const parsed = extractJson<Record<string, unknown>>(text);` |
| `generateFaqContent` | `extractJson` | function call | ✓ WIRED | Line 341: `return extractJson<{ question: string; answer: string }[]>(text);` |
| `generateCostContent` | `extractJson` | function call | ✓ WIRED | Line 398: `return extractJson<{ starter: number; threeMonth: number; oneYear: number; tips: string[] }>(text);` |
| `generateBudgetContent` | `extractJson` | function call | ✓ WIRED | Line 465: `return extractJson<{ ... }[]>(text);` |

All 4 key links are wired. No inline `.replace(/^```/)` patterns remain in `ai_generator.ts`.

---

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
|-------------|-------------|-------------|--------|----------|
| AI-01 | 08-01-PLAN.md | AI generation upgraded from Haiku to Sonnet | ⚠ PARTIAL | Code uses `claude-sonnet-4-6` (not Haiku) — Sonnet is deployed. But ROADMAP criterion specifies `claude-sonnet-4-20250514`; the model ID strings differ. REQUIREMENTS.md marks AI-01 as `[x]` complete. |
| AI-02 | 08-01-PLAN.md | Coach stale detection uses lastActivityAt | ✓ SATISFIED | `lastActivityAt ?? startedAt` at `[action].ts` line 461. REQUIREMENTS.md marks `[x]` complete. |
| AI-03 | 08-01-PLAN.md | extractJson() guard for Sonnet output format safety | ✓ SATISFIED | `export function extractJson<T>` in `ai_generator.ts`, called by all 4 generation functions. REQUIREMENTS.md marks `[x]` complete. |

No orphaned requirements. All 3 requirements claimed by the phase are accounted for and match the ROADMAP Coverage Map (Phase 8 owns AI-01, AI-02, AI-03).

---

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
|------|------|---------|----------|--------|
| `server/lib/ai_generator.ts` | 6 | Header comment says `claude-sonnet-4-20250514`, constant says `claude-sonnet-4-6` | ⚠ Warning | Misleading — reader cannot determine the intended model from the file header alone |
| `server/api/generate/[action].ts` | 9 | Header comment says `claude-sonnet-4-20250514`, constant says `claude-sonnet-4-6` | ⚠ Warning | Same issue — the authoritative comment and the authoritative constant contradict each other |

No stub implementations. No empty handlers. No TODO/FIXME comments in modified files. No return null patterns in generation functions.

**Pre-existing test failure (not introduced by this phase):**
`server/test/cron-purge.test.ts` — 5 tests fail with `Cannot find module '../api/cron/purge-deleted-users'`. This file belongs to Phase 4 (account deletion cron job) and has not been created yet. Documented in `.planning/phases/08-sonnet-ai-upgrade/deferred-items.md`. All other 111 tests pass.

---

### Human Verification Required

#### 1. Confirm claude-sonnet-4-6 is a valid production Anthropic model ID

**Test:** Make a real request to `POST /api/generate/hobby` with a valid JWT and a simple query (e.g. `{"query": "pottery"}`).
**Expected:** HTTP 201 with a full hobby profile (title, hook, kitItems, roadmapSteps, etc.) — no API error about an unknown model.
**Why human:** Cannot verify programmatically whether `claude-sonnet-4-6` is an accepted alias for `claude-sonnet-4-20250514` or a distinct model without a live Anthropic API call. If the model ID is wrong, every AI generation endpoint silently fails in production.

---

### Gaps Summary

There is one gap blocking full goal verification: the model ID string used in the code (`claude-sonnet-4-6`) does not match the string specified in ROADMAP.md Success Criterion 1 (`claude-sonnet-4-20250514`). The stale header comments in both files also reference `claude-sonnet-4-20250514`.

This may be a documentation inconsistency (the ROADMAP was written with the anticipated model ID, but the code was already using `claude-sonnet-4-6` before the plan ran), or it may indicate the wrong model ID was left in place. The PLAN's own must_haves used `claude-sonnet-4-6` and treated it as already correct.

**Resolution options:**
1. If `claude-sonnet-4-6` is confirmed to be a valid Anthropic model alias for Claude Sonnet 4 — update ROADMAP.md Success Criterion 1 and the header comments in both files to say `claude-sonnet-4-6`. Mark the gap closed.
2. If the correct production model ID is `claude-sonnet-4-20250514` — update `const MODEL` in `ai_generator.ts` and `const COACH_MODEL` in `[action].ts` to `claude-sonnet-4-20250514`. Fix the header comments to match.

All other phase deliverables (extractJson utility, stale detection, safe JSON parsing, error messages) are fully implemented and wired correctly.

---

*Verified: 2026-03-22T11:40:23Z*
*Verifier: Claude (gsd-verifier)*
