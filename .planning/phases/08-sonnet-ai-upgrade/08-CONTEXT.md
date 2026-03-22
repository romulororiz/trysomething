# Phase 8: Sonnet AI Upgrade - Context

**Gathered:** 2026-03-22
**Status:** Ready for planning

<domain>
## Phase Boundary

Ensure all AI generation runs on Claude Sonnet with hardened prompts, correct stale detection, and safe JSON parsing. The model upgrade and stale detection fix are already deployed — remaining work is extracting a reusable `extractJson()` utility and adding error handling for malformed AI output.

</domain>

<decisions>
## Implementation Decisions

### AI model status
- **D-01:** Model is ALREADY `claude-sonnet-4-6` in both `ai_generator.ts` (MODEL) and `[action].ts` (COACH_MODEL). No model ID change needed — just verify and document.

### Stale detection status
- **D-02:** Coach stale detection ALREADY uses `lastActivityAt ?? startedAt` at `[action].ts` line 461. The fallback to `startedAt` is correct behavior when `lastActivityAt` is null (new hobby, never practiced). No change needed — just verify and document.

### extractJson() guard
- **D-03:** Extract the duplicated code fence stripping + JSON.parse into a shared `extractJson(text: string)` function in `ai_generator.ts`. Replace all 4 inline occurrences.
- **D-04:** `extractJson()` must wrap `JSON.parse` in try/catch — on parse failure, log the raw text and throw a descriptive error rather than crashing with raw SyntaxError.
- **D-05:** The function should handle edge cases: empty string, text with no JSON, multiple code fence blocks (take the first one).

### Claude's Discretion
- Whether to make `extractJson` a standalone export in `ai_generator.ts` or a separate `server/lib/json_utils.ts` file
- Exact error message format for parse failures

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### AI generation
- `server/lib/ai_generator.ts` — All 4 generation functions with duplicated code fence stripping (lines 150-155, 314-319, 375-380, 446-451)
- `server/api/generate/[action].ts` — Coach handler with COACH_MODEL and stale detection (lines 36, 461, 520)

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- The code fence stripping pattern is already correct: `.replace(/^```(?:json)?\s*/m, "").replace(/\s*```\s*$/m, "").trim()`
- Just needs extraction into a named function + error handling

### Established Patterns
- All AI functions follow the same pattern: create message → get response → extract text → strip fences → parse JSON
- `logGeneration()` helper for audit trail

### Integration Points
- `extractJson()` would be called from all 4 generation functions in `ai_generator.ts`
- Could also be used by the coach handler's response parsing if it does any JSON extraction

</code_context>

<specifics>
## Specific Ideas

No specific requirements — straightforward refactor of duplicated code into a shared utility with error handling.

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 08-sonnet-ai-upgrade*
*Context gathered: 2026-03-22*
