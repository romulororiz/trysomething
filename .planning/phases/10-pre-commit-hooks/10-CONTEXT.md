# Phase 10: Pre-Commit Hooks - Context

**Gathered:** 2026-03-22
**Status:** Ready for planning

<domain>
## Phase Boundary

Install Lefthook for pre-commit hooks enforcing Flutter analyze on `lib/` and TypeScript lint on `server/`. Every commit is automatically checked before landing.

</domain>

<decisions>
## Implementation Decisions

### Tool choice
- **D-01:** Use Lefthook (not Husky) — repo root is Flutter (no package.json), Lefthook is language-agnostic
- **D-02:** Install via npm in `server/` as devDependency OR as standalone binary — Claude's discretion

### Hook configuration
- **D-03:** Pre-commit hook runs two parallel checks:
  1. `dart analyze {staged_files}` for `*.dart` files in `lib/`
  2. `npx tsc --noEmit` for `*.ts` files in `server/`
- **D-04:** Hooks must complete within 30 seconds for a clean commit
- **D-05:** `lefthook.yml` at repository root, committed to git

### Claude's Discretion
- Exact Lefthook installation method (npm devDep vs standalone)
- Whether to use `{staged_files}` placeholder or analyze all files
- Whether to add a `commit-msg` hook for conventional commits

</decisions>

<canonical_refs>
## Canonical References

No external specs — requirements fully captured in decisions above.

### Research
- `.planning/research/STACK.md` — Lefthook v2.1.4 recommendation with Flutter patterns

</canonical_refs>

<code_context>
## Existing Code Insights

### Integration Points
- Repository root: `D:/programming/projetos/trysomething/` (Flutter project)
- Server directory: `server/` (Node.js/TypeScript)
- `server/tsconfig.json` — TypeScript config for `tsc --noEmit`
- `analysis_options.yaml` — Dart analyzer rules

</code_context>

<specifics>
## Specific Ideas

No specific requirements — standard Lefthook setup for polyglot monorepo.

</specifics>

<deferred>
## Deferred Ideas

None

</deferred>

---

*Phase: 10-pre-commit-hooks*
*Context gathered: 2026-03-22*
