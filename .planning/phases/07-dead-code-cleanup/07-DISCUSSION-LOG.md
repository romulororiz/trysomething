# Phase 7: Dead Code Cleanup - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-03-22
**Phase:** 07-dead-code-cleanup
**Areas discussed:** Cleanup scope, Verification approach

---

## Cleanup scope

### Q1: Should we also remove orphaned models/providers/seed data that were ONLY used by the dead screens?

| Option | Description | Selected |
|--------|-------------|----------|
| Full cleanup (Recommended) | Delete screens + any models, providers, seed data that become orphaned | ✓ |
| Screens only | Just delete the 7 screen files | |
| You decide | Claude uses GitNexus to determine what's safe to remove | |

**User's choice:** Full cleanup (Recommended)

### Q2: Remove fake seed data too?

| Option | Description | Selected |
|--------|-------------|----------|
| Yes, clean all fake seed data | Remove buddy profiles, fake stories, fake users, heatmap generator | |
| Keep seed data | Leave it — some might be reused later | ✓ |

**User's choice:** Keep seed data

---

## Verification approach

### Q1: How should deletions be verified?

| Option | Description | Selected |
|--------|-------------|----------|
| After each file | Delete one, analyze, commit, repeat | |
| Batch then verify | Delete all 7 at once, analyze once, commit if clean | ✓ |
| You decide | Claude picks based on dependency analysis | |

**User's choice:** Batch then verify

---

## Claude's Discretion

- Which orphaned models/providers to remove
- Commit granularity
- Whether to remove Freezed model classes or just provider wrappers

## Deferred Ideas

None
