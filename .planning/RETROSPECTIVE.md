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

## Cross-Milestone Trends

### Process Evolution

| Milestone | Commits | Phases | Key Change |
|-----------|---------|--------|------------|
| v1.0 | 121 | 11 | First GSD milestone — established phase/plan/summary pattern |

### Cumulative Quality

| Milestone | Tests | LOC | Net Change |
|-----------|-------|-----|------------|
| v1.0 | 37 test files | 68,450 | +15,519 |

### Top Lessons (Verified Across Milestones)

1. Keep tracking artifacts updated in real-time — retroactive cleanup is error-prone
2. Fine-grained phases (1-3 plans each) ship faster than large batches
