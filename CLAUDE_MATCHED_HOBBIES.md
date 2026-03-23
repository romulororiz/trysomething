# CLAUDE_MATCHED_HOBBIES.md — Match Results Screen + Updated Matches

> Read `CLAUDE.md` before starting. This task adds the missing bridge between
> onboarding/preferences and hobby discovery.
> This is a CRITICAL gap — users currently finish onboarding and land on an empty
> Home screen with no guidance on what to do next.

---

## The Problem (3 Gaps)

### Gap 1: Onboarding → Dead End
The onboarding "You're ready!" page (page 2) shows 4 floating 3D hobby cards, but they're purely decorative — **not tappable**. The CTA "Start Exploring →" calls `_completeOnboarding()` which goes straight to `context.go('/home')`. If the user hasn't saved any hobby, they land on an empty dashboard.

### Gap 2: Preference Changes Are Silent
In Settings, the user can adjust hours, budget, social, and vibes. Each change calls `UserPreferencesNotifier` setters which save to `SharedPreferences` locally. But:
- **No server sync** is triggered (the onboarding does a fire-and-forget sync, but Settings doesn't)
- **No UI response** — nothing tells the user "your recommendations have updated"
- The Discover "For You" tab DOES reactively recompute via `computeMatchScore()`, but nobody tells the user to go look

### Gap 3: Matching Logic Works But Is Never Surfaced
`computeMatchedHobbies()`, `computeMatchScore()`, and `computeMatchReasons()` in `core/hobby_match.dart` all work correctly. The scoring system (budget fit 0-3, time fit 0-3, social 0-2, vibes +1 each) produces good matches. It's just never shown to the user at the right moments.

---

## The Solution (2 Components)

### A. Match Results Screen (`/match-results`)
A full-screen results page shown **after onboarding completes**, before the user reaches Home. Displays the top matched hobbies as interactive cards. The user can tap any match to view its detail page (where they can save/start), or go to Discover to browse more.

### B. Updated Matches Sheet
A bottom sheet triggered **after preference changes in Settings**. Shows the top 3 new recommendations. Tappable → hobby detail. Also syncs preferences to the server.

---

## Part 1: Reactive Match Provider

### Create `lib/providers/match_provider.dart`

This provider recalculates matched hobbies whenever `userPreferencesProvider` OR `hobbyListProvider` changes. Both the Match Results Screen and the Updated Matches Sheet consume it.

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/hobby.dart';
import '../core/hobby_match.dart';
import 'hobby_provider.dart';
import 'user_provider.dart';

/// Single match result with score and reasons.
class MatchResult {
  final Hobby hobby;
  final int score;
  final List<String> reasons;
  const MatchResult({required this.hobby, required this.score, required this.reasons});
}

/// Reactive provider: recalculates when preferences or hobby list changes.
final matchedHobbiesProvider = Provider<List<MatchResult>>((ref) {
  final allHobbies = ref.watch(hobbyListProvider).valueOrNull ?? [];
  final prefs = ref.watch(userPreferencesProvider);

  if (allHobbies.isEmpty) return [];

  final matched = computeMatchedHobbies(
    allHobbies: allHobbies,
    userHours: prefs.hoursPerWeek.toDouble(),
    userBudgetLevel: prefs.budgetLevel,
    userPrefersSocial: prefs.preferSocial,
    userVibes: prefs.vibes,
  );

  return matched.map((hobby) {
    final score = computeMatchScore(
      hobby: hobby,
      userHours: prefs.hoursPerWeek.toDouble(),
      userBudgetLevel: prefs.budgetLevel,
      userPrefersSocial: prefs.preferSocial,
      userVibes: prefs.vibes,
    );
    final reasons = computeMatchReasons(
      hobby: hobby,
      userHours: prefs.hoursPerWeek.toDouble(),
      userBudgetLevel: prefs.budgetLevel,
      userPrefersSocial: prefs.preferSocial,
      userVibes: prefs.vibes,
    );
    return MatchResult(hobby: hobby, score: score, reasons: reasons);
  }).toList();
});
```

This provider is the single source of truth for matched hobbies everywhere in the app. Discover's `_forYou()` method should also be refactored to use it instead of computing scores inline (optional, not blocking).

---

## Part 2: Match Results Screen

### Create `lib/screens/onboarding/match_results_screen.dart`

This is a full-screen route shown once after onboarding. It's NOT inside the tab shell — it takes over the screen like the trial offer does.

### Visual Design

Follow the prototype in `roadmap_interactive_v2.jsx` match results mockup. Use the exact TrySomething design system (AppBackground, Manrope, glass cards, coral accent).

**Screen layout (top to bottom):**

```
[AppBackground — teal top-left + burgundy bottom-right]

"CURATED FOR YOU" — overline badge (glass pill, sparkle icon + text)

"Your matches" — hero text, 36pt Manrope 800
"Based on your time, budget, and energy. Tap any to explore."
  — body text, 15pt, textSecondary. "Tap any to explore" in textMuted.

───────────────────────────────
 #1 MATCH — Large card
   Full-width, tall (280px image area)
   Hobby image (CachedNetworkImage, cover)
   Gradient overlay bottom→dark
   "BEST MATCH" badge — top-left, coral pill with pulsing dot
   Score ring — top-right, animated fill (see below)
   Category overline — textMuted, 11pt, tracking 1.5
   Title — 28pt, weight 800, textPrimary
   Hook text — 15pt, textSecondary
   Spec line — IBM Plex Mono 12pt, textMuted: "CHF X · Xh/week · Easy"
   Match reasons — pills (first in coral tint, rest in glass)
   onTap → context.push('/hobby/${hobby.id}')
───────────────────────────────

── ALSO FOR YOU ── divider with overline text

───────────────────────────────
 #2 MATCH — Compact horizontal card
   110px image thumbnail left, content right
   Category overline + title + hook + spec line
   Score ring (34px, smaller)
   Top match reason
   onTap → context.push('/hobby/${hobby.id}')
───────────────────────────────

 #3 MATCH — Same layout as #2

 #4 MATCH — Same layout as #2 (if available)

───────────────────────────────

[ Explore all hobbies → ]  — coral gradient CTA, full-width
                             onTap → context.go('/discover')

"Skip to home" — secondary text link, textMuted
                  onTap → context.go('/home')

"Join 10,000+ people discovering hobbies they love"
  — social proof text, textWhisper, centered
```

### Score Ring Component

Animated circular progress ring showing match percentage:
- Outer ring: `textWhisper` track (3px stroke)
- Inner ring: `accent` (coral) fill, animated with `strokeDashoffset` transition
- Center: score number in IBM Plex Mono 12pt
- Computed as: `(score / maxPossibleScore * 100).round()` — max possible score is budget(3) + time(3) + social(2) + vibes(userVibes.length) = 8 + vibes
- Animation: 1.2 seconds, `Curves.easeOutCubic`, delayed per card (800ms + index * 150ms)

Use `CustomPainter` with `AnimationController` for the ring. Same approach as `particle_timer_painter.dart`.

### Entrance Animation

Use `flutter_animate`:
- Header: fade + slide up, 800ms, `Curves.easeOutCubic`, delay 100ms
- Top match card: fade + slide up, 600ms, delay 400ms
- Each secondary card: fade + slide up, 500ms, staggered at 150ms intervals starting at 550ms
- CTA section: fade, delay 1200ms
- Score rings: independent animation starting at 800ms + card delay

### Image Handling

Each match card shows the hobby's `imageUrl` via `CachedNetworkImage`:
- Top match: 280px height, `BoxFit.cover`, top-clipped with border radius
- Secondary matches: 110px width, full height, `BoxFit.cover`, left side
- Both: gradient overlay for text readability
- Placeholder: `AppColors.surfaceElevated` solid
- Error: same placeholder

---

## Part 3: Router Changes

### Add Route

In `lib/router.dart`, add the match results route OUTSIDE the shell (full-screen, same level as trial offer):

```dart
// Match Results — shown once after onboarding
GoRoute(
  path: '/match-results',
  parentNavigatorKey: _rootNavigatorKey,
  pageBuilder: (context, state) => CustomTransitionPage(
    child: const MatchResultsScreen(),
    transitionsBuilder: (_, a, __, c) =>
      FadeTransition(opacity: a, child: c),
    transitionDuration: Motion.slow,
  ),
),
```

### Update Redirect Logic

The redirect chain needs to handle the new screen. Current flow:

```
Onboarding → /home → (redirect catches) → /trial-offer → /home
```

New flow:

```
Onboarding → /match-results → user interacts → /hobby/:id or /discover or /home
→ (redirect catches on next navigation) → /trial-offer → /home
```

Changes to the `redirect` function:

```dart
redirect: (context, state) {
  final auth = ref.read(authProvider);
  final onboarded = ref.read(onboardingCompleteProvider);
  final path = state.uri.path;
  final isAuthRoute = path == '/login' || path == '/register';
  final isOnboarding = path == '/onboarding';
  final isMatchResults = path == '/match-results';
  final isTrialOffer = path == '/trial-offer';

  // ... existing auth checks ...

  if (!onboarded && !isOnboarding) return '/onboarding';
  if (onboarded && isOnboarding) return '/match-results';  // ← CHANGED: was '/home'

  // Match results guard — show once after onboarding
  final matchResultsSeen = ref.read(sharedPreferencesProvider)
      .getBool('matchResultsSeen') ?? false;
  if (onboarded && !matchResultsSeen && !isMatchResults && !isOnboarding && !isAuthRoute) {
    return '/match-results';
  }
  // Don't redirect away from match-results
  if (isMatchResults) return null;

  // Trial offer guard — show once (AFTER match results now)
  final trialOfferShown = ref.read(sharedPreferencesProvider)
      .getBool('trialOfferShown') ?? false;
  if (onboarded && matchResultsSeen && !trialOfferShown && !isTrialOffer
      && !isAuthRoute && !isOnboarding && !isMatchResults) {
    return '/trial-offer';
  }
  if (trialOfferShown && isTrialOffer) return '/home';

  return null;
},
```

### Mark Match Results as Seen

In the Match Results Screen, when the user navigates away (taps a hobby, Explore, or Skip), set the flag:

```dart
void _markSeen() {
  ref.read(sharedPreferencesProvider).setBool('matchResultsSeen', true);
}

// Call before any navigation:
void _onHobbyTap(String hobbyId) {
  _markSeen();
  context.push('/hobby/$hobbyId');
}

void _onExploreAll() {
  _markSeen();
  context.go('/discover');
}

void _onSkipToHome() {
  _markSeen();
  context.go('/home');
}
```

---

## Part 4: Onboarding Changes

### Change Navigation Target

In `lib/screens/onboarding/onboarding_screen.dart`, update `_completeOnboarding()`:

```dart
void _completeOnboarding() {
  // ... existing preference saving + analytics ...

  // CHANGED: go to match results instead of home
  context.go('/match-results');
}
```

### Keep the Floating Cards

The `_ReadyPage` with its 3D floating cards stays as-is. The cards are decorative — they create visual anticipation for the match results screen that follows. The "Start Exploring →" CTA now takes them to `/match-results` where the real interactive matches live.

No changes needed to `_ReadyPage`, `_buildFloatingCard`, or the CTA labels.

---

## Part 5: Updated Matches Sheet (Settings)

### Create `lib/components/updated_matches_sheet.dart`

A function that shows the existing `showAppSheet()` with match results:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/match_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/spacing.dart';
import 'app_overlays.dart';

/// Shows a bottom sheet with updated hobby matches after preference changes.
/// Also triggers server sync of preferences.
Future<void> showUpdatedMatchesSheet(BuildContext context, WidgetRef ref) async {
  final matches = ref.read(matchedHobbiesProvider).take(3).toList();
  if (matches.isEmpty) return;

  await showAppSheet(
    context: context,
    title: 'Updated matches',
    builder: (context) => _UpdatedMatchesContent(matches: matches),
  );
}
```

### Sheet Content Design

```
┌──────────────────────────────────────┐
│           ─── (drag handle) ───      │
│                                      │
│  Updated matches                     │  ← title from showAppSheet
│  Based on your new preferences       │  ← subtitle, textMuted 12pt
│                                      │
│  ┌──────────────────────────────┐    │
│  │ [IMG] Title          92 ◉   │    │  ← match tile 1
│  │       Spec line              │    │
│  │       ✦ Match reason         │    │
│  └──────────────────────────────┘    │
│                                      │
│  ┌──────────────────────────────┐    │
│  │ [IMG] Title          87 ◉   │    │  ← match tile 2
│  │       Spec line              │    │
│  │       ✦ Match reason         │    │
│  └──────────────────────────────┘    │
│                                      │
│  ┌──────────────────────────────┐    │
│  │ [IMG] Title          81 ◉   │    │  ← match tile 3
│  │       Spec line              │    │
│  │       ✦ Match reason         │    │
│  └──────────────────────────────┘    │
│                                      │
│  See all recommendations →           │  ← teal text link → /discover
│                                      │
└──────────────────────────────────────┘
```

Each match tile:
- Glass card background (`GlassCard` or manual glass styling)
- 50px circular image thumbnail (left)
- Title: 15pt, weight 700, textPrimary
- Spec line: IBM Plex Mono 11pt, textMuted
- Top match reason: 11pt, textSecondary, with ✦ prefix
- Score ring (34px) on the right
- `onTap` → dismiss sheet + `context.push('/hobby/${match.hobby.id}')`

Entrance: stagger each tile 80ms with `flutter_animate` fadeIn + slideUp.

### "See all recommendations →" link
- Text in `coachText` (#5CB8C9), 13pt, weight 600
- `onTap` → dismiss sheet + `context.go('/discover')`

---

## Part 6: Settings Integration

### Track Preference Changes

The Settings screen needs to detect when preferences have actually changed and show a "See updated matches" button.

In `lib/screens/settings/settings_screen.dart`:

```dart
// At the top of the build method, capture initial state:
final initialPrefs = useRef(ref.read(userPreferencesProvider));
// Or since this is ConsumerWidget, store in initState

// After the vibes section, check if changed:
final currentPrefs = ref.watch(userPreferencesProvider);
final hasChanged = currentPrefs != _initialPrefs;
```

**Option A (Recommended): Inline "See updated matches" button**

After the vibes chips section, show a coral CTA that appears when preferences differ from the initial state:

```dart
if (hasChanged) ...[
  const SizedBox(height: 20),
  AnimatedSize(
    duration: Motion.normal,
    curve: Motion.normalCurve,
    child: SizedBox(
      width: double.infinity,
      height: Spacing.buttonPrimaryHeight,
      child: ElevatedButton(
        onPressed: () {
          // 1. Sync to server
          ref.read(authRepositoryProvider).updatePreferences(
            hoursPerWeek: currentPrefs.hoursPerWeek,
            budgetLevel: currentPrefs.budgetLevel,
            preferSocial: currentPrefs.preferSocial,
            vibes: currentPrefs.vibes,
          );
          // 2. Show updated matches
          showUpdatedMatchesSheet(context, ref);
          // 3. Reset change tracking
          _initialPrefs = currentPrefs;
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Spacing.radiusCta),
          ),
        ),
        child: Text('See updated matches', style: AppTypography.button),
      ),
    ),
  ),
],
```

This button appearance should be animated — use `AnimatedSize` + `AnimatedOpacity` so it smoothly appears when preferences change.

**What this fixes:**
1. Preferences now sync to server when the user taps "See updated matches" (not on every individual tweak)
2. The user gets visual feedback that their changes matter
3. The sheet shows them concrete hobby recommendations based on new preferences

### Change Tracking Implementation

The Settings screen is a `ConsumerStatefulWidget`. Store the initial prefs in `initState`:

```dart
late UserPreferences _initialPrefs;

@override
void initState() {
  super.initState();
  _initialPrefs = ref.read(userPreferencesProvider);
}
```

Compare `ref.watch(userPreferencesProvider) != _initialPrefs` in the build method. After showing the sheet, update `_initialPrefs` to the current value so the button disappears.

---

## Part 7: Analytics Events

Track these events to measure if the match results screen works:

```dart
// In MatchResultsScreen:
'match_results_viewed'          // Screen opened, with match_count
'match_results_hobby_tapped'    // User tapped a match, with hobby_id, position (1-4)
'match_results_explore_tapped'  // User tapped "Explore all hobbies"
'match_results_skipped'         // User tapped "Skip to home"

// In Settings:
'preferences_changed'           // Any preference changed, with changed_fields list
'updated_matches_viewed'        // Sheet opened after preference change
'updated_matches_hobby_tapped'  // User tapped a match in the sheet, with hobby_id
```

---

## Part 8: Edge Cases

### No Matches
If `matchedHobbiesProvider` returns empty (hobbies still loading or all filtered out):

**Match Results Screen:** Show a loading shimmer (3 skeleton cards) while hobbies load. If hobbies are loaded but 0 match (extremely unlikely given the padding logic in `computeMatchedHobbies`), show: "We're still curating matches for you. Explore our full catalog while we work on it." + "Explore hobbies →" CTA to `/discover`.

**Updated Matches Sheet:** If 0 matches after preference change, show: "No hobbies match these exact preferences. Try adjusting your budget or time." Don't show the sheet if matches array is empty.

### Hobby Already Saved/Started
If the user taps a match and that hobby is already saved/active, the hobby detail screen handles this — it shows the current status. No special handling needed in the match results.

### Returning User (Match Results Already Seen)
The `matchResultsSeen` SharedPreferences flag ensures the screen only shows once. If the user has already seen it, the redirect skips straight to trial offer (if not shown) or home.

### Trial Offer Timing
The trial offer now shows AFTER match results, not immediately after onboarding. This is better — the user has seen their matches, possibly viewed a hobby detail, and has more context for why Pro matters. The redirect chain handles this automatically.

---

## Part 9: Files to Create / Modify

### New Files
| File | Purpose |
|------|---------|
| `lib/providers/match_provider.dart` | Reactive matched hobbies provider |
| `lib/screens/onboarding/match_results_screen.dart` | Full-screen match results |
| `lib/components/updated_matches_sheet.dart` | Bottom sheet for preference changes |

### Modified Files
| File | Changes |
|------|---------|
| `lib/screens/onboarding/onboarding_screen.dart` | Change `context.go('/home')` → `context.go('/match-results')` in `_completeOnboarding()` |
| `lib/router.dart` | Add `/match-results` route, update redirect logic with `matchResultsSeen` flag, adjust trial offer timing |
| `lib/screens/settings/settings_screen.dart` | Add preference change tracking, "See updated matches" button, server sync on button tap |

### No Changes Needed
| File | Why |
|------|-----|
| `lib/core/hobby_match.dart` | Matching logic already works perfectly |
| `lib/screens/discover/discover_screen.dart` | "For You" tab already uses preferences reactively |
| `lib/components/app_overlays.dart` | `showAppSheet()` already exists and works |
| `lib/providers/user_provider.dart` | Preference setters already work |
| `lib/data/repositories/auth_repository_api.dart` | `updatePreferences()` already exists |

### No New Packages Required
Everything uses existing dependencies:
- `flutter_animate` — staggered card entrances
- `cached_network_image` — hobby images
- `CustomPainter` — score rings
- `GlassCard` — card styling
- `showAppSheet()` — bottom sheet for updated matches

---

## Part 10: Complete User Flow

### Flow A: New User (First Time)

```
1. Open app → /login (or /register)
2. Register/login → redirect to /onboarding
3. Onboarding page 0: Vibes selection
4. Onboarding page 1: Time, budget, social
5. Onboarding page 2: "You're ready!" with floating cards
6. Tap "Start Exploring →"
   → Preferences saved to SharedPreferences
   → Preferences synced to server (fire-and-forget)
   → onboardingComplete flag set
   → context.go('/match-results')

7. /match-results screen appears with staggered animation
   → 4 matched hobbies with scores and reasons
   → Score rings animate in
   → User sees their #1 best match prominently

8. User taps #1 match
   → matchResultsSeen flag set
   → context.push('/hobby/pottery')
   → Hobby detail screen (can save or start)

9. User taps back or navigates
   → Redirect catches: matchResultsSeen=true, trialOfferShown=false
   → Redirects to /trial-offer

10. Trial offer screen
    → User starts trial or skips
    → trialOfferShown flag set
    → context.go('/home')

11. Home screen — if user started a hobby, it's here
```

### Flow B: Existing User Changes Preferences

```
1. User goes to Settings (from You tab)
2. Changes budget from "Low" to "Medium"
3. Changes vibe from "relaxing" to "physical"
4. "See updated matches" button appears (animated)
5. User taps button
   → Preferences synced to server
   → showUpdatedMatchesSheet() fires
   → Sheet shows 3 new top matches with scores

6. User taps a match
   → Sheet dismisses
   → context.push('/hobby/bouldering')
   → Hobby detail screen

7. Meanwhile, Discover "For You" tab has already
   recomputed via watchedProvider — if user goes
   to Discover, new recommendations are there
```

### Flow C: User Skips Match Results

```
1. Match results screen appears
2. User taps "Skip to home"
   → matchResultsSeen flag set
   → context.go('/home')
   → Redirect catches → /trial-offer (if not shown)
   → Then /home
3. User can still discover hobbies via Discover tab
```

---

## Part 11: Testing Checklist

### Match Results Screen
- [ ] Screen appears after onboarding completion (not before)
- [ ] 4 hobby cards render with images, titles, specs, reasons
- [ ] #1 match has "BEST MATCH" badge with pulsing dot
- [ ] Score rings animate with 1.2s fill
- [ ] Cards have staggered entrance animation
- [ ] Tapping #1 card → navigates to hobby detail
- [ ] Tapping secondary card → navigates to hobby detail
- [ ] "Explore all hobbies" → navigates to Discover
- [ ] "Skip to home" → navigates to Home
- [ ] Screen only shows once (matchResultsSeen flag)
- [ ] Trial offer shows AFTER match results, not before
- [ ] Loading state: shimmer skeletons while hobbies load
- [ ] Analytics: match_results_viewed, match_results_hobby_tapped

### Updated Matches Sheet
- [ ] Button appears in Settings when preferences change
- [ ] Button does NOT appear when preferences haven't changed
- [ ] Button appearance is animated (not instant)
- [ ] Tapping button syncs preferences to server
- [ ] Sheet shows 3 match tiles with images, scores, reasons
- [ ] Tapping a tile → dismisses sheet → navigates to hobby detail
- [ ] "See all recommendations" → dismisses sheet → navigates to Discover
- [ ] Sheet handles 0 matches gracefully (edge case)
- [ ] Analytics: preferences_changed, updated_matches_viewed

### Redirect Chain
- [ ] New user: onboarding → match-results → trial-offer → home
- [ ] New user skip: onboarding → match-results (skip) → trial-offer → home
- [ ] Returning user: login → home (match-results already seen)
- [ ] Deep link during onboarding: redirects back to onboarding
- [ ] Deep link after onboarding but before match-results: redirects to match-results

### Matching Quality
- [ ] Budget "Low" users see hobbies under CHF 50
- [ ] Time "1h/week" users see hobbies ≤ 1h/week first
- [ ] Solo preference shows solo-tagged hobbies higher
- [ ] Vibes selection affects ranking (creative vibe → creative hobbies score higher)
- [ ] Reasons are specific ("Starter cost: CHF 30-60") not generic ("Fits your budget")
