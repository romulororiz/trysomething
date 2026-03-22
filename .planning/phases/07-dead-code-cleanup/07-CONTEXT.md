# Phase 7: Dead Code Cleanup - Context

**Gathered:** 2026-03-22
**Status:** Ready for planning

<domain>
## Phase Boundary

Remove 7 hidden feature screens (~2,658 lines) whose routes were already removed. Also remove any orphaned models, providers, or imports that become unreferenced after screen deletion. Seed data in `feature_seed_data.dart` is explicitly kept.

</domain>

<decisions>
## Implementation Decisions

### Cleanup scope
- **D-01:** Full cleanup — delete the 7 screen files AND any models, providers, or imports that become orphaned after deletion
- **D-02:** Keep `feature_seed_data.dart` as-is — do NOT remove fake buddy profiles, community stories, similar users, or heatmap data even if orphaned
- **D-03:** Use GitNexus impact analysis to determine which models/providers are safe to remove (only remove if zero remaining consumers after screen deletion)

### Verification approach
- **D-04:** Batch delete all 7 screens at once, then run `flutter analyze` once to verify. Commit if clean. Faster than per-file verification.
- **D-05:** If `flutter analyze` fails after batch deletion, fix broken references before committing (likely orphaned imports in other files)

### Files to delete
- **D-06:** Target files (confirmed zero imports across `lib/`):
  - `lib/screens/features/buddy_mode_screen.dart` (413 lines)
  - `lib/screens/features/community_stories_screen.dart` (406 lines)
  - `lib/screens/features/local_discovery_screen.dart` (270 lines)
  - `lib/screens/features/year_in_review_screen.dart` (344 lines)
  - `lib/screens/features/weekly_challenge_screen.dart` (413 lines)
  - `lib/screens/features/mood_match_screen.dart` (403 lines)
  - `lib/screens/features/seasonal_picks_screen.dart` (409 lines)

### Claude's Discretion
- Which orphaned models/providers to remove (based on GitNexus or grep analysis)
- Whether to remove orphaned Freezed model classes or just the provider wrappers
- Commit message granularity (single commit vs screens + orphans separately)

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Dead screens
- `lib/screens/features/buddy_mode_screen.dart` — Buddy mode (routes removed)
- `lib/screens/features/community_stories_screen.dart` — Community stories (routes removed)
- `lib/screens/features/local_discovery_screen.dart` — Local discovery (routes removed)
- `lib/screens/features/year_in_review_screen.dart` — Year in review (routes removed)
- `lib/screens/features/weekly_challenge_screen.dart` — Weekly challenge (routes removed)
- `lib/screens/features/mood_match_screen.dart` — Mood match (routes removed)
- `lib/screens/features/seasonal_picks_screen.dart` — Seasonal picks (routes removed)

### Potential orphan sources
- `lib/providers/feature_providers.dart` — May contain providers only used by dead screens
- `lib/models/social.dart` — BuddyPair, CommunityStory models (check if used elsewhere)
- `lib/models/gamification.dart` — Challenge, Achievement models (check if used elsewhere)

### Seed data (DO NOT DELETE)
- `lib/models/feature_seed_data.dart` — Keep all seed data per D-02

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- None — this is a deletion phase

### Established Patterns
- Routes already removed from `router.dart` — screens are unreachable
- Zero imports found across `lib/` for any of the 7 target screens
- CLAUDE.md lists these as "Hidden Features (code exists, routes removed)"

### Integration Points
- `lib/providers/feature_providers.dart` — providers for mood, seasonal, challenges may be only used by dead screens
- `lib/models/social.dart` — BuddyPair and CommunityStory may have active consumers (profile screen shows community content)
- `lib/data/repositories/` — social and gamification repositories may have methods only called by dead screens

</code_context>

<specifics>
## Specific Ideas

No specific requirements — standard dead code removal with dependency verification.

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 07-dead-code-cleanup*
*Context gathered: 2026-03-22*
