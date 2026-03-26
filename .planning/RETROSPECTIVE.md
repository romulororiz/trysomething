# Project Retrospective

*A living document updated after each milestone. Lessons feed forward into future planning.*

## Milestone: v1.0 — Launch Readiness

**Shipped:** 2026-03-23
**Phases:** 11 | **Plans:** 18 | **Commits:** 121

### What Was Built
- Server security hardening (webhook fail-closed, server-side rate limiting)
- Full account deletion pipeline (backend soft-delete + Flutter UI with email/OAuth flows)
- Legal compliance (Terms & Privacy hosted, linked in Settings)
- AI upgrade from Haiku to Sonnet with extractJson() guard
- Session screen breathing ring redesign (5-layer stack, Apple Watch aesthetic)
- App store submission packages (privacy manifests, store checklists, pre-commit hooks)
- Dead code cleanup (7 screens, ~7,000 lines removed)
- Apple OAuth routing fix + Restore Purchases

### What Worked
- GSD phased approach kept 23 requirements organized and trackable
- Fine granularity (10 phases + 1 inserted) prevented scope creep per phase
- Phase 09.1 insertion (breathing ring) demonstrated flexibility without disrupting the roadmap
- Pre-determined checklists for manual store admin work (Phase 09 Plan 02) eliminated guesswork
- API-first cleanup pattern (server call before local wipe) prevented data loss edge cases

### What Was Inefficient
- REQUIREMENTS.md traceability table fell behind — 8 requirements still showed "Pending" despite phases being complete
- STATE.md progress metrics never updated from initial "0/10" — stale from day 1
- ROADMAP.md phase checkboxes not updated as work completed (only Phase 1 and 10 were checked)
- Summary files for 3 phases (02, 05-Plan 02, 09-Plan 02) were missing — had to be created retroactively
- Quick task (Apple OAuth) done outside GSD tracking created a gap in Phase 02

### Patterns Established
- `showAppSheet` for all confirmation flows (even simple ones) when tappable widgets are needed
- `CacheManager.clearAll()` using `box.clear()` not `deleteBoxFromDisk()` to keep Hive boxes open
- `extractJson()` guard for all AI response parsing (Sonnet wraps JSON in code fences)
- Film grain as static PNG overlay at 1.5% opacity instead of per-frame noise generation
- Single CustomPainter for multi-layer ring drawing (track + glow + arc + dot)

### Key Lessons
1. **Update tracking artifacts as you go** — retroactive summary writing loses context and accuracy
2. **Quick tasks should generate PLAN+SUMMARY stubs** — otherwise phases show as incomplete
3. **Phase 09.1 insertion proved the decimal numbering works** — inserted without renumbering anything
4. **Manual admin phases need different plan structure** — checklists + human checkpoints, not code tasks

### Cost Observations
- Model mix: primarily Sonnet for execution, Opus for planning
- Sessions: ~15-20 across 2 days
- Notable: 121 commits in 2 days shows high velocity — fine granularity kept each commit focused

---

## Milestone: v1.2 — Separation of Concerns Refactor

**Shipped:** 2026-03-26
**Phases:** 4 (of 6 planned) | **Plans:** 8 | **Commits:** 32

### What Was Built
- Home screen decomposed: 2,375 → 393 lines (page variants, journal tiles, roadmap widgets extracted)
- Settings screen decomposed: 2,082 → 831 lines (edit profile sheet, photo picker, section builders extracted)
- You screen decomposed: 1,654 → 336 lines (4 tab contents, hobby card variants extracted)
- Coach screen decomposed: 1,741 → 367 lines (provider, bubbles, composer, mode widgets — 5-file architecture)
- Shared PhotoPickerOverlay component for cross-screen reuse

### What Worked
- Consistent "extract-then-compose" pattern across all 4 screens — each followed the same structure
- Wave-based execution (Wave 1: foundations, Wave 2: dependents) kept plans independent
- Verification after each phase caught issues immediately
- Pure refactor scope (zero UI/UX changes) made verification straightforward — just dart analyze
- Decision to ship 4/6 phases avoided diminishing returns on lower-priority screens

### What Was Inefficient
- Initial executor agent hit usage limit mid-plan 18-01 — partial file created but no commit, required manual state assessment and re-spawn
- Summary one_liner fields not populated by executor agents — summary-extract returned null for all 8 summaries
- Settings screen ended at 831 lines (above 500 target) — acceptable but inconsistent with other screens
- Phase completion tool reported `is_last_phase: true` for Phase 18 because it only counts directories, not roadmap entries — misleading when phases 19-20 existed in roadmap but had no directory

### Patterns Established
- 5-file decomposition pattern for complex screens: shell + provider + bubble/card + composer/input + widgets/helpers
- Wave dependency: extract models/providers first (Wave 1), then UI widgets that depend on them (Wave 2)
- `export` re-export pattern in screen files to preserve external import paths (coach screen exports CoachEntryContext, CoachMode)
- Partial execution recovery: check git status + file existence + SUMMARY existence to assess what the interrupted agent completed

### Key Lessons
1. **Pure refactors are fast** — 4 large screens refactored in a single day with no behavioral changes to verify
2. **Ship what matters, defer what doesn't** — onboarding/remaining screens are tech debt, not blockers
3. **Agent interruptions are recoverable** — untracked files + no commits = clean re-start; committed partial work = resume from SUMMARY gap
4. **Wave dependencies work well for extract refactors** — provider/model first, then widgets that import them

### Cost Observations
- Model mix: Opus orchestration, Sonnet verification, inherit (Opus) execution
- Sessions: 2 (1 interrupted by limit, 1 completion)
- Notable: 8 plans across 4 phases in ~6 hours wall time including the limit interruption

---

## Cross-Milestone Trends

### Process Evolution

| Milestone | Commits | Phases | Key Change |
|-----------|---------|--------|------------|
| v1.0 | 121 | 11 | First GSD milestone — established phase/plan/summary pattern |
| v1.2 | 32 | 4 | Pure refactor — extract-then-compose pattern, wave-based execution |

### Cumulative Quality

| Milestone | Tests | LOC | Net Change |
|-----------|-------|-----|------------|
| v1.0 | 37 test files | 68,450 | +15,519 |
| v1.2 | 37 test files | ~67,460 | -988 |

### Top Lessons (Verified Across Milestones)

1. Keep tracking artifacts updated in real-time — retroactive cleanup is error-prone
2. Fine-grained phases (1-3 plans each) ship faster than large batches
3. Pure refactor milestones are fast and low-risk — scope them separately from feature work
4. Ship what matters, defer the rest — 80% of the value in 4/6 phases
