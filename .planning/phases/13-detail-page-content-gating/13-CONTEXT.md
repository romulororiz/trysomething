# Phase 13: Detail Page Content Gating - Context

**Gathered:** 2026-03-23
**Status:** Ready for planning

<domain>
## Phase Boundary

Gate specific sections of the hobby detail page behind Pro. Free users see a rich preview with blurred locked sections. Server enforces 403 on AI generation endpoints for non-Pro users. No new sections added — only gating of existing content.

</domain>

<decisions>
## Implementation Decisions

### Locked card design
- Real content renders behind a `BackdropFilter` blur (not placeholder shimmer)
- Overlay on top of blur: centered lock icon (24px) + section title + coral "Unlock with Pro" pill button
- Tapping anywhere on the locked card opens the existing `showProUpgrade()` bottom sheet
- Same blur treatment for ALL gated sections (consistent pattern — user learns "blurred = Pro")

### Section ordering
- Keep current order — gated sections stay interleaved in their natural positions (not grouped at bottom)
- Free sections: hero image, "Why this fits you", "Start in 20 minutes", "What to expect" (roadmap), Start CTA
- Locked sections: "Why people stop", starter kit, plan first session / coach teaser, quick links (FAQ, cost, budget)
- Quick links show lock icon immediately on the button — tapping opens Pro upgrade sheet, no API call for free users

### Free vs Pro sections
| Section | Free | Pro |
|---------|------|-----|
| Hero image | ✓ | ✓ |
| Spec badge | ✓ | ✓ |
| "Why this fits you" | ✓ | ✓ |
| "Start in 20 minutes" | ✓ | ✓ |
| "What to expect" (roadmap) | ✓ | ✓ |
| Start Hobby CTA | ✓ | ✓ |
| "Why people stop" | 🔒 blur | ✓ |
| Starter Kit | 🔒 blur | ✓ |
| Plan First Session / Coach teaser | 🔒 blur | ✓ |
| FAQ (quick link) | 🔒 lock icon | ✓ |
| Cost breakdown (quick link) | 🔒 lock icon | ✓ |
| Budget alternatives (quick link) | 🔒 lock icon | ✓ |

### Plan First Session card
- Same blur treatment as other gated sections on the detail page
- Ungated on Home for active hobbies (same component, `isLocked` flag controls behavior)
- Single shared component used in both places

### Server-side enforcement
- `/api/generate/faq`, `/api/generate/cost`, `/api/generate/budget` return 403 for non-Pro users
- Pro status checked via JWT claims or RevenueCat entitlement check on the server
- Client-side gating is visual only — server is the real gate

### Claude's Discretion
- Blur intensity (sigma value for BackdropFilter)
- Lock icon style (outline vs filled, color)
- "Unlock with Pro" pill exact styling (size, border, text)
- How to create a reusable `ProGateSection` wrapper widget
- Server-side Pro check implementation (middleware vs per-endpoint)

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- `showProUpgrade()` in `pro_upgrade_sheet.dart` — existing Pro upgrade bottom sheet
- `isProProvider` — synchronous RevenueCat entitlement check (in-memory cache)
- `GlassCard` — base card component, can be wrapped with blur overlay
- `BackdropFilter` — Flutter built-in, no package needed for blur
- `shimmer_skeleton.dart` — exists but NOT used (real content behind blur instead)

### Established Patterns
- Detail page sections are built with `_staggeredCard(index, widget)` wrapper
- Quick links load lazily via feature providers (faqProvider, costProvider, budgetProvider)
- Pro checks use `ref.watch(isProProvider)` — synchronous, no async complexity

### Integration Points
- `hobby_detail_screen.dart` — all sections rendered in a single `CustomScrollView`
- `server/api/generate/[action].ts` — FAQ, cost, budget generation endpoints
- `server/lib/auth.ts` — JWT middleware, can add Pro check
- `hobby_quick_links.dart` — component for FAQ/cost/budget link buttons

</code_context>

<specifics>
## Specific Ideas

- Blur should be strong enough that content is unreadable but shapes/colors are visible — creates FOMO
- The "Unlock with Pro" pill should feel like the app's coral CTA style, not a generic button
- Lock icon should be subtle (white with low opacity) — the pill does the heavy lifting for conversion

</specifics>

<deferred>
## Deferred Ideas

- Progressive unlock (completing Stage 1 unlocks Stage 2 preview for free) — defer to v2
- Time-limited Pro trial on specific hobby — defer to v2

</deferred>

---

*Phase: 13-detail-page-content-gating*
*Context gathered: 2026-03-23*
