# Phase 13: Detail Page Content Gating - Research

**Researched:** 2026-03-23
**Domain:** Flutter UI content gating (BackdropFilter blur overlay) + Node.js/TypeScript server-side tier enforcement
**Confidence:** HIGH

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

**Locked card design**
- Real content renders behind a `BackdropFilter` blur (not placeholder shimmer)
- Overlay on top of blur: centered lock icon (24px) + section title + coral "Unlock with Pro" pill button
- Tapping anywhere on the locked card opens the existing `showProUpgrade()` bottom sheet
- Same blur treatment for ALL gated sections (consistent pattern — user learns "blurred = Pro")

**Section ordering**
- Keep current order — gated sections stay interleaved in their natural positions (not grouped at bottom)
- Free sections: hero image, "Why this fits you", "Start in 20 minutes", "What to expect" (roadmap), Start CTA
- Locked sections: "Why people stop", starter kit, plan first session / coach teaser, quick links (FAQ, cost, budget)
- Quick links show lock icon immediately on the button — tapping opens Pro upgrade sheet, no API call for free users

**Free vs Pro sections**
| Section | Free | Pro |
|---------|------|-----|
| Hero image | free | free |
| Spec badge | free | free |
| "Why this fits you" | free | free |
| "Start in 20 minutes" | free | free |
| "What to expect" (roadmap) | free | free |
| Start Hobby CTA | free | free |
| "Why people stop" | blur locked | pro only |
| Starter Kit | blur locked | pro only |
| Plan First Session / Coach teaser | blur locked | pro only |
| FAQ (quick link) | lock icon | pro only |
| Cost breakdown (quick link) | lock icon | pro only |
| Budget alternatives (quick link) | lock icon | pro only |

**Plan First Session card**
- Same blur treatment as other gated sections on the detail page
- Ungated on Home for active hobbies (same component, `isLocked` flag controls behavior)
- Single shared component used in both places

**Server-side enforcement**
- `/api/generate/faq`, `/api/generate/cost`, `/api/generate/budget` return 403 for non-Pro users
- Pro status checked via JWT claims or RevenueCat entitlement check on the server
- Client-side gating is visual only — server is the real gate

### Claude's Discretion
- Blur intensity (sigma value for BackdropFilter)
- Lock icon style (outline vs filled, color)
- "Unlock with Pro" pill exact styling (size, border, text)
- How to create a reusable `ProGateSection` wrapper widget
- Server-side Pro check implementation (middleware vs per-endpoint)

### Deferred Ideas (OUT OF SCOPE)
- Progressive unlock (completing Stage 1 unlocks Stage 2 preview for free) — defer to v2
- Time-limited Pro trial on specific hobby — defer to v2
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| GATE-01 | Detail page shows for free users: hero image, spec badge, "why it fits you", "start in 20 minutes", what to expect, full 4-stage roadmap overview, "Start Hobby" CTA | Existing free sections in `hobby_detail_screen.dart` lines 180-210 are already built; no changes needed to these widgets |
| GATE-02 | Detail page Pro-locked sections: why people stop, starter kit list, plan first session, cost breakdown, FAQ, budget alternatives | Six sections already exist in the detail screen; wrap each with `ProGateSection` widget |
| GATE-03 | Locked sections render as glass card with lock icon, section title, one-line teaser text, "Unlock with Pro" pill | New `ProGateSection` widget — wraps child in `BackdropFilter` + overlay with lock icon and pill CTA |
| GATE-04 | Tapping any locked section triggers existing `showProUpgrade()` bottom sheet | `showProUpgrade()` already exists in `pro_upgrade_sheet.dart` — just call it from `ProGateSection.onTap` |
| GATE-05 | Server-side gate on `/api/generate/faq`, `/api/generate/cost`, `/api/generate/budget` — return 403 for non-Pro users | Add `requirePro()` helper in `server/lib/auth.ts` that reads `subscriptionTier` from User row; call it inside each handler before generation |
| GATE-06 | Plan First Session card on Home (for active hobby) uses same component as detail page version, ungated for active hobby | Extract `_buildCoachTeaser()` (detail screen line 861-907) into a shared `PlanFirstSessionCard` widget with `isLocked` flag |
</phase_requirements>

---

## Summary

Phase 13 is a UI wrapping + server enforcement phase, not a feature-from-scratch phase. The complete content already exists in `hobby_detail_screen.dart` — the six sections to be gated (`_buildWhyPeopleStop`, `StarterKitCard`, `_buildCoachTeaser`, and the three quick links in `HobbyQuickLinks`) are rendered unconditionally today. The work is: (1) create one new `ProGateSection` widget that wraps any child in a BackdropFilter blur with a lock overlay, (2) update the detail screen to wrap gated sections with `ProGateSection` conditioned on `isProProvider`, (3) extract the coach teaser into a shared `PlanFirstSessionCard(isLocked:)` component reusable on both the detail and Home screens, (4) update `HobbyQuickLinks` to support a locked mode that shows lock icons and intercepts taps, and (5) add `requirePro()` to the server `auth.ts` and call it in the three generation endpoints.

The server already has `subscriptionTier` on the `User` model (`"free" | "trial" | "pro" | "lifetime"`). No schema migration is needed. The JWT `requireAuth` helper already returns a userId from which the tier can be looked up in a single DB query. The CONTEXT.md note about grandfathered content (STATE.md: "content gating targets new AI generation calls only — previously cached FAQ/cost/budget content remains accessible") means the 403 gate only applies when the handler would actually call Claude — if data already exists in the DB, it must still be returned to free users. This is the key behavioral nuance for GATE-05.

Flutter-side, `BackdropFilter` is built into Flutter's `dart:ui` — no new packages. `isProProvider` is a synchronous `Provider<bool>` in `subscription_provider.dart` — reads in O(1) from in-memory RevenueCat cache. The existing `showProUpgrade()` in `pro_upgrade_sheet.dart` is the sole CTA trigger. No new navigation routes needed.

**Primary recommendation:** Create one `ProGateSection` wrapper widget (blur + overlay) and one `requirePro()` server helper — everything else is wiring.

---

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Flutter `dart:ui` `BackdropFilter` | SDK built-in | Frosted glass blur over content | Already used in `GlassCard` (blur variant); no new dep |
| `flutter_riverpod` `isProProvider` | 2.6.1 (existing) | Synchronous Pro status check | Already returns `bool` from in-memory RC cache; zero network cost |
| `showProUpgrade()` | existing component | RevenueCat paywall + custom fallback | Tracks analytics, handles RC native paywall — do not duplicate |
| `GlassCard` | existing component | Base card surface | All locked overlays sit on top of this existing surface |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| Vitest | 3.0.0 (existing) | Server unit tests | Test `requirePro()` helper and 403 behavior on generate endpoints |
| `flutter_test` widget tests | SDK built-in | Widget tests for `ProGateSection` | Verify blur present when locked, absent when unlocked |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| `BackdropFilter` blur | Solid overlay or placeholder shimmer | Locked — CONTEXT.md explicitly requires real content + blur for FOMO effect |
| Per-endpoint Pro DB lookup | JWT claim for `subscriptionTier` | JWT approach avoids DB round-trip but requires re-issuing tokens on subscription change; DB lookup is safer and consistent with current `requireAuth` pattern |
| Middleware Pro guard | Per-endpoint inline check | Both valid; per-endpoint is simpler for 3 specific endpoints — middleware would apply to ALL generate actions including `/hobby` which is free |

**No new package installations required** — all tools already in pubspec/package.json.

---

## Architecture Patterns

### Recommended Project Structure

New files this phase:
```
lib/
├── components/
│   ├── pro_gate_section.dart          # NEW — blur + lock overlay wrapper
│   └── plan_first_session_card.dart   # NEW — extracted from detail screen, isLocked param
server/
└── lib/
    └── auth.ts                        # ADD requirePro() helper
```

Modified files:
```
lib/
├── screens/detail/hobby_detail_screen.dart   # Wrap 3 gated sections + update quick links
├── components/hobby_quick_links.dart          # Add isLocked param, intercept taps
└── screens/home/home_screen.dart              # Use PlanFirstSessionCard (ungated)
server/
└── api/generate/[action].ts                   # Add requirePro check to faq/cost/budget handlers
```

### Pattern 1: ProGateSection Widget

**What:** A widget that takes `isLocked`, `sectionTitle`, `teaserText`, and a `child`. When locked, it wraps child in `ClipRRect` + `BackdropFilter` + `ImageFilter.blur` then renders a centered overlay with lock icon, title, and coral pill. When unlocked, renders child directly.

**When to use:** Every gated section in `hobby_detail_screen.dart`.

**Example:**
```dart
// Source: Derived from existing GlassCard blur pattern (lib/components/glass_card.dart:69-77)
// and BackdropFilter usage already established in the codebase.

class ProGateSection extends ConsumerWidget {
  final Widget child;
  final bool isLocked;
  final String sectionTitle;
  final String teaserText;

  const ProGateSection({
    super.key,
    required this.child,
    required this.isLocked,
    required this.sectionTitle,
    required this.teaserText,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!isLocked) return child;

    return GestureDetector(
      onTap: () => showProUpgrade(context, 'detail_gate_$sectionTitle'),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Real content — blurred for FOMO
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: child,
            ),
            // Overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.background.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_outline_rounded,
                        size: 24, color: Colors.white.withValues(alpha: 0.6)),
                    const SizedBox(height: 8),
                    Text(sectionTitle, style: AppTypography.sansLabel
                        .copyWith(color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    Text(teaserText, style: AppTypography.sansTiny
                        .copyWith(color: AppColors.textSecondary),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    // Coral "Unlock with Pro" pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('Unlock with Pro',
                          style: AppTypography.caption
                              .copyWith(color: Colors.white,
                                  fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

**Note on `ImageFiltered` vs `BackdropFilter`:** Use `ImageFiltered` (blurs the child widget's own pixels) rather than `BackdropFilter` (blurs what is BEHIND the widget in the compositing layer). For content-over-dark-background use cases like this, `ImageFiltered` gives a cleaner result and avoids the "bleed through" artifact common with `BackdropFilter` on scrolling lists. `GlassCard(blur: true)` uses `BackdropFilter` because it blurs a transparent surface — different use case.

### Pattern 2: requirePro() Server Helper

**What:** A server function in `auth.ts` that resolves a userId to their `subscriptionTier` and returns a boolean (or responds 403 directly).

**When to use:** In `handleGenerateFaq`, `handleGenerateCost`, `handleGenerateBudget` — AFTER `requireAuth`, BEFORE calling the generator — but ONLY when no cached DB record already exists (to honor grandfathering).

**Example:**
```typescript
// server/lib/auth.ts — add to existing file
// Source: pattern consistent with existing requireAuth() in this file

export async function requirePro(
  userId: string,
  res: VercelResponse
): Promise<boolean> {
  const user = await prisma.user.findUnique({
    where: { id: userId },
    select: { subscriptionTier: true },
  });
  const isPro = user?.subscriptionTier === "pro" ||
                user?.subscriptionTier === "trial" ||
                user?.subscriptionTier === "lifetime";
  if (!isPro) {
    errorResponse(res, 403, "Pro subscription required");
    return false;
  }
  return true;
}
```

**Usage in generate handler (key: check AFTER cache lookup):**
```typescript
// server/api/generate/[action].ts — inside handleGenerateFaq
async function handleGenerateFaq(req: VercelRequest, res: VercelResponse) {
  const userId = await requireAuth(req, res);
  if (!userId) return;

  const { hobbyId } = req.body ?? {};
  // ... validation ...

  // Return cached data to ALL users (including free) — grandfathering
  const existing = await prisma.faqItem.findMany({ where: { hobbyId } });
  if (existing.length > 0) {
    return res.status(200).json(existing.map(mapFaqItem));
  }

  // Gate NEW generation for free users only
  const isPro = await requirePro(userId, res);
  if (!isPro) return; // 403 already sent

  // ... rest of generation logic
}
```

### Pattern 3: Locked HobbyQuickLinks

**What:** Update `HobbyQuickLinks` to accept `isLocked` parameter. When locked, show each link button with a lock icon badge and intercept tap to call `showProUpgrade()` instead of navigating.

**When to use:** In `hobby_detail_screen.dart` when `!isPro`.

### Pattern 4: PlanFirstSessionCard Extraction

**What:** Extract `_buildCoachTeaser()` from `hobby_detail_screen.dart` into a standalone `PlanFirstSessionCard` widget that accepts an `isLocked` flag. The Home screen passes `isLocked: false`; the detail screen passes `isLocked: !isPro`.

**When to use:** The CONTEXT.md requirement that the same component be used in both Home (ungated) and Detail (gated for non-Pro).

### Anti-Patterns to Avoid

- **Double-gating the CTA:** The "Start Hobby" button must remain ungated. Only the six content sections listed in CONTEXT.md should be wrapped with `ProGateSection`.
- **Gating existing cached data on server:** Free users who already have FAQ/cost/budget data in the DB must still get it — only NEW AI generation calls are gated. See grandfathering note in STATE.md.
- **Using `BackdropFilter` in a scrollable list for every gated card:** `BackdropFilter` creates a compositing layer — using it for 3+ items in a `SliverList` causes jank. Use `ImageFiltered` instead (blurs the widget's own pixels, no compositing layer overhead).
- **Reading `isProProvider` inside a `StatelessWidget` without `ConsumerWidget`:** `isProProvider` requires Riverpod access — all widgets using it must be `ConsumerWidget` or `ConsumerStatefulWidget`.
- **Calling `showProUpgrade()` without `context.mounted` check:** The upgrade sheet is async — the calling context may be unmounted if the user navigated away during the async check.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Pro status check (client) | Custom RC API call | `ref.watch(isProProvider)` | Already returns cached `bool` synchronously — in-memory, no network |
| Paywall display | Custom modal | `showProUpgrade(context, triggerMessage)` | Handles RC native paywall + analytics + fallback in one call |
| Blur effect | Custom painter | `ImageFilter.blur` via `ImageFiltered` | Flutter built-in; no package; correct for in-widget blur |
| Server Pro tier check | JWT claim parsing | DB lookup via `requirePro()` | JWT doesn't auto-update on RC webhook — DB is authoritative |

**Key insight:** This phase is entirely about wiring existing infrastructure. The paywall, the blur primitive, the Pro status check, and the existing section widgets are all built. The work is composition, not construction.

---

## Common Pitfalls

### Pitfall 1: BackdropFilter Jank in ScrollView
**What goes wrong:** Using `BackdropFilter` (via `GlassCard(blur: true)`) for locked section cards in a `SliverList` causes 30fps scroll stutters — each `BackdropFilter` requires a new compositing layer.
**Why it happens:** `BackdropFilter` blurs everything BEHIND it in the compositing tree, forcing a GPU composition pass per widget.
**How to avoid:** Use `ImageFiltered(imageFilter: ImageFilter.blur(...), child: child)` instead. This blurs only the child widget's pixels without creating a compositing layer. Reserve `BackdropFilter` for truly static hero elements.
**Warning signs:** Flutter DevTools shows "Repaint boundary" or "SaveLayer" operations on every scroll frame.

### Pitfall 2: Gating Previously-Cached Content (App Store §3.1.2(a))
**What goes wrong:** Returning 403 on `/api/generate/faq` even when FAQ data already exists in the DB blocks free users from content they previously accessed.
**Why it happens:** Adding the `requirePro()` check at the top of the handler before the cache lookup.
**How to avoid:** Always check DB cache FIRST and return cached data to any authenticated user. Only call `requirePro()` when the handler would actually invoke Claude to generate new content.
**Warning signs:** Free users who previously viewed FAQ data now see an error in the app.

### Pitfall 3: isLocked State Not Reactive to Subscription Changes
**What goes wrong:** A user who upgrades to Pro mid-session still sees locked cards until they restart the app.
**Why it happens:** `isLocked` is computed once in `build()` but `proStatusProvider` is not watched.
**How to avoid:** Use `ref.watch(isProProvider)` inside the `build()` method of the parent widget (or `ProGateSection` if it is a `ConsumerWidget`). When the user purchases Pro, `proStatusProvider.notifier.sync()` is called in `showProUpgrade()` — this triggers a rebuild automatically.
**Warning signs:** After successful purchase the UI doesn't unlock until hot restart.

### Pitfall 4: Budget Quick Link is Missing from HobbyQuickLinks
**What goes wrong:** The existing `HobbyQuickLinks` component only shows two buttons: "Cost Breakdown" and "Beginner FAQ" — it does NOT include "Budget Alternatives".
**Why it happens:** The component was built before budget alternatives was a required quick link.
**How to avoid:** Update `HobbyQuickLinks` to add a third "Budget Alternatives" button (navigating to `/budget/$hobbyId`). This is needed whether the button is locked or not — it's currently missing entirely.
**Warning signs:** GATE-02 requires gating three quick links but only two exist in the component.

### Pitfall 5: showProUpgrade Requires Mounted Context
**What goes wrong:** Calling `showProUpgrade(context, ...)` inside a `GestureDetector.onTap` after an async operation causes a `!context.mounted` assertion.
**Why it happens:** `onTap` is synchronous but `showProUpgrade` is async internally. If the widget unmounts between tap and execution, the BuildContext is stale.
**How to avoid:** `ProGateSection.onTap` should call `showProUpgrade` synchronously (no await needed at the call site) — just `showProUpgrade(context, trigger)` without `await` since the sheet is fire-and-forget from the caller's perspective.

---

## Code Examples

Verified patterns from official sources / existing codebase:

### ImageFiltered blur (correct for in-widget content)
```dart
// Source: Flutter SDK dart:ui ImageFilter — use for blurring a child widget's own pixels
ImageFiltered(
  imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
  child: existingContentWidget,
)
// Note: sigmaX/Y of 6-10 makes content shapes visible but text unreadable — optimal FOMO zone
```

### BackdropFilter (do NOT use in scrollable lists)
```dart
// Source: lib/components/glass_card.dart:69-77 — existing usage in GlassCard
// Only use for static/hero elements (max 3-5 per screen)
ClipRRect(
  borderRadius: BorderRadius.circular(widget.borderRadius),
  child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
    child: card,
  ),
)
```

### isProProvider consumption (synchronous, reactive)
```dart
// Source: lib/providers/subscription_provider.dart:84-86
// In ConsumerWidget.build or ConsumerState.build:
final isPro = ref.watch(isProProvider); // synchronous bool, updates on purchase
```

### showProUpgrade call pattern
```dart
// Source: lib/components/pro_upgrade_sheet.dart:14-53
// Call without await — fire and forget from caller's perspective
showProUpgrade(context, 'detail_gate_why_people_stop');
// triggerMessage appears in PostHog 'paywall_shown' event as 'trigger' property
```

### requireAuth pattern (to extend with requirePro)
```typescript
// Source: server/lib/auth.ts:51-78
// requirePro follows the same contract: resolves userId, sends error itself, returns bool
export async function requirePro(
  userId: string,
  res: VercelResponse
): Promise<boolean> {
  const user = await prisma.user.findUnique({
    where: { id: userId },
    select: { subscriptionTier: true },
  });
  const paid = ["pro", "trial", "lifetime"];
  if (!user || !paid.includes(user.subscriptionTier)) {
    errorResponse(res, 403, "Pro subscription required");
    return false;
  }
  return true;
}
```

### Server generate handler ordering (grandfathering pattern)
```typescript
// Cache check BEFORE Pro gate — free users get existing data
const existing = await prisma.faqItem.findMany({ where: { hobbyId } });
if (existing.length > 0) {
  return res.status(200).json(existing.map(mapFaqItem)); // free users get this
}
// Pro gate applies ONLY when about to generate new content
const isPro = await requirePro(userId, res);
if (!isPro) return; // 403 sent
// ... call Claude ...
```

---

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `BackdropFilter` for any blur | `ImageFiltered` for in-widget blur, `BackdropFilter` only for behind-widget blur | Flutter 3.x — always been separate but commonly confused | Prevents scroll jank in lists |
| Checking RevenueCat entitlements on server via webhook | DB `subscriptionTier` field set by webhook, read at request time | Current schema design | Single DB read per protected request; no RC API call on hot path |

**No deprecated approaches apply to this phase.** All tooling is current.

---

## Open Questions

1. **Blur sigma value (Claude's discretion)**
   - What we know: sigma 6-10 makes content shapes/colors visible but text unreadable; GlassCard uses sigma 12 for the blur variant (behind-widget blur, different effect)
   - What's unclear: exact subjective "best" value for FOMO effect without feeling broken
   - Recommendation: Start with sigma 8 (moderate — content silhouette visible, text illegible). Adjust during visual review on device.

2. **Budget Alternatives route/screen**
   - What we know: `HobbyQuickLinks` currently has Cost (`/cost/$id`) and FAQ (`/faq/$id`) buttons only. Budget alternatives quick link is required by GATE-02 but the button doesn't exist yet.
   - What's unclear: Whether the budget screen (`/budget/$id`) and its feature provider (`budgetProvider`) are already wired in the router.
   - Recommendation: Check `lib/router.dart` before planning — if the route exists, add the button and gate it. If the route doesn't exist, the planner must scope that as a sub-task.

3. **Lock icon style (Claude's discretion)**
   - What we know: CONTEXT.md says "lock icon should be subtle (white with low opacity) — the pill does the heavy lifting"
   - Recommendation: Use `Icons.lock_outline_rounded` at 24px, `Colors.white.withValues(alpha: 0.5)`.

---

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework (Flutter) | flutter_test (SDK built-in) |
| Framework (Server) | Vitest 3.0.0 |
| Config file (Flutter) | none — dart test discovers automatically |
| Config file (Server) | none — vitest finds `server/test/**/*.test.ts` |
| Quick run command (Flutter) | `flutter test test/widget/components/pro_gate_section_test.dart` |
| Quick run command (Server) | `cd server && npm test -- --reporter=verbose` |
| Full suite command (Flutter) | `flutter test` |
| Full suite command (Server) | `cd server && npm test` |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| GATE-01 | Free sections visible without gating (hero, why fits, start in 20, what to expect) | widget | `flutter test test/widget/screens/hobby_detail_gating_test.dart` | No — Wave 0 |
| GATE-02 | Six sections identified as locked in detail screen | widget | `flutter test test/widget/screens/hobby_detail_gating_test.dart` | No — Wave 0 |
| GATE-03 | `ProGateSection` shows blur + lock icon when `isLocked:true`, shows child directly when `isLocked:false` | widget | `flutter test test/widget/components/pro_gate_section_test.dart` | No — Wave 0 |
| GATE-04 | Tapping a locked section calls `showProUpgrade` | widget | `flutter test test/widget/components/pro_gate_section_test.dart` | No — Wave 0 |
| GATE-05 | `/api/generate/faq` returns 403 for free user when no cached data exists; returns 200 for cached data regardless of tier | unit (server) | `cd server && npm test -- --reporter=verbose test/routes_generate.test.ts` | No — Wave 0 |
| GATE-06 | `PlanFirstSessionCard` renders with blur when `isLocked:true`, without blur when `isLocked:false` | widget | `flutter test test/widget/components/plan_first_session_card_test.dart` | No — Wave 0 |

### Sampling Rate
- **Per task commit:** Run the specific test file for that task's new component
- **Per wave merge:** `flutter test && cd server && npm test`
- **Phase gate:** Full suite green before `/gsd:verify-work`

### Wave 0 Gaps
- [ ] `test/widget/components/pro_gate_section_test.dart` — covers GATE-03, GATE-04
- [ ] `test/widget/components/plan_first_session_card_test.dart` — covers GATE-06
- [ ] `test/widget/screens/hobby_detail_gating_test.dart` — covers GATE-01, GATE-02 (uses `isProProvider` override via ProviderScope)
- [ ] `server/test/routes_generate.test.ts` — covers GATE-05 (mock prisma + requireAuth, test 403 on generation path and 200 on cache path)

---

## Sources

### Primary (HIGH confidence)
- Existing codebase: `lib/screens/detail/hobby_detail_screen.dart` — full section inventory, `_staggeredCard` pattern, existing section builders at lines 180-910
- Existing codebase: `lib/components/pro_upgrade_sheet.dart` — `showProUpgrade()` signature and behavior confirmed
- Existing codebase: `lib/providers/subscription_provider.dart` — `isProProvider` confirmed as synchronous `Provider<bool>`
- Existing codebase: `lib/components/glass_card.dart` — `BackdropFilter` usage pattern, `blur` variant
- Existing codebase: `server/lib/auth.ts` — `requireAuth()` pattern; confirms `subscriptionTier` readable via DB
- Existing codebase: `server/prisma/schema.prisma` lines 173-177 — `subscriptionTier String @default("free")` field confirmed on `User` model
- Existing codebase: `server/api/generate/[action].ts` — confirmed all three tier-2 endpoints (`faq`, `cost`, `budget`) structure and cache-check flow
- Existing codebase: `lib/components/hobby_quick_links.dart` — confirmed only 2 quick links exist (Cost, FAQ); Budget is missing

### Secondary (MEDIUM confidence)
- Flutter documentation on `ImageFiltered` vs `BackdropFilter`: `ImageFiltered` blurs child widget pixels; `BackdropFilter` blurs everything behind it in the compositing layer. Multiple Flutter performance guides recommend `ImageFiltered` for content blurring in lists.
- STATE.md accumulated context: "Content gating targets new AI generation calls only — previously cached FAQ/cost/budget content remains accessible to avoid App Store §3.1.2(a) retroactive-gating risk" — this constrains GATE-05 implementation.

### Tertiary (LOW confidence)
- Sigma value recommendation (8 for moderate FOMO blur): based on general Flutter blur UX heuristics, not empirically validated on the target Nothing Phone 3a. Validate on device during implementation.

---

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — all libraries confirmed in codebase; no new dependencies
- Architecture: HIGH — existing section structure fully read from source; `ProGateSection` pattern is a standard Flutter composition
- Server pattern: HIGH — `subscriptionTier` schema confirmed; `requireAuth` pattern confirmed; grandfathering rule confirmed from STATE.md
- Pitfall re: BackdropFilter vs ImageFiltered: MEDIUM — confirmed pattern distinction from Flutter docs, but jank threshold on device not empirically measured
- Budget quick link gap (missing third button): HIGH — confirmed by reading `hobby_quick_links.dart` source

**Research date:** 2026-03-23
**Valid until:** 2026-04-22 (stable — no fast-moving external APIs; all work is internal to this codebase)
