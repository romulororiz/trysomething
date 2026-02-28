# TrySomething — Flutter UI Kit

**"Neo-Editorial + Kinetic Glass"** design system for a hobby discovery app.

## Design Language

| Element | Choice | Why |
|---------|--------|-----|
| **Base** | Deep graphite (#0A0A0C) | Premium, non-fatiguing dark mode |
| **Accents** | Electric cyan, acid lime, violet | High-energy without warmth clichés |
| **Headings** | Playfair Display (serif) | Editorial magazine feel |
| **Body** | DM Sans (geometric sans) | Clean, modern readability |
| **Numbers** | JetBrains Mono | "Spec sheet" data density |
| **Surfaces** | Frosted glass + grain | Kinetic Glass signature |
| **Motion** | 200–300ms, spring for confirms | Purposeful, not decorative |

## Architecture

```
lib/
├── main.dart                      # App entry + theme mode
├── theme/
│   ├── app_colors.dart            # Full color system (dark + light)
│   ├── app_typography.dart        # Type scale (serif/sans/mono)
│   ├── app_theme.dart             # ThemeData (dark primary + light)
│   └── spacing.dart               # 4px grid + radius + size tokens
├── models/
│   └── hobby.dart                 # Data models + sample data
├── components/
│   ├── glass_container.dart       # Frosted glass surface widget
│   ├── spec_badge.dart            # Cost/Time/Difficulty badges + SpecBar
│   ├── hobby_card.dart            # Full-bleed discovery feed card
│   ├── try_today_button.dart      # Primary CTA with glow animation
│   ├── roadmap_step_tile.dart     # Editorial checklist step
│   └── category_tile.dart         # Explore grid tile + chip bar
├── screens/
│   ├── main_shell.dart            # Bottom nav shell
│   ├── onboarding/
│   │   └── onboarding_screen.dart # 3-page welcome + preferences + results
│   ├── feed/
│   │   └── discover_feed_screen.dart  # Vertical swipe card feed
│   ├── detail/
│   │   └── hobby_detail_screen.dart   # Full conversion page
│   ├── quickstart/
│   │   └── quickstart_screen.dart     # "First 30 minutes" task flow
│   ├── my_stuff/
│   │   └── my_stuff_screen.dart       # Saved/Trying/Active/Done tabs
│   └── explore/
│       └── explore_screen.dart        # Category grid + filters + search
```

## Component Library

### `SpecBadge` / `SpecBar`
Product-label styled pills showing cost, time, and difficulty.
Always visible on cards — core UX decision data.

### `HobbyCard`
Full-bleed media card with parallax-ready image, gradient overlay,
category chip, action buttons, and bottom spec shelf.

### `TryTodayButton`
Primary CTA with breathing glow animation and press feedback.
Never says "Start learning" — always action-oriented.

### `RoadmapStepTile`
Editorial checklist with animated checkbox (elastic spring),
milestone badges, time estimates, and completion states.

### `CategoryTile` / `CategoryChipBar`
Bold icon grid tiles and horizontal filter chips
with accent-colored icon containers.

### `GlassContainer`
Frosted glass surface with backdrop blur and noise grain texture.
Signature "Kinetic Glass" design element.

## Screens

| Screen | Key Features |
|--------|-------------|
| **Onboarding** | 3-page flow: Welcome → Preferences (sliders/toggles) → Vibe results |
| **Discover Feed** | Vertical PageView, category filter bar, card actions |
| **Hobby Detail** | Hero parallax, spec bar, starter kit, pitfalls, roadmap, related |
| **Quickstart** | 25-min timer, 3 quick tasks, progress bar, completion flow |
| **My Stuff** | Tab bar (Saved/Trying/Active/Done), stat chips, progress tiles |
| **Explore** | Search + intent prompts, filter panel, category grid, curated packs |

## Setup

1. Create a new Flutter project: `flutter create trysomething`
2. Replace `lib/` with this code
3. Copy `pubspec.yaml` dependencies
4. Download fonts from Google Fonts and place in `assets/fonts/`
5. Run `flutter pub get`
6. Run `flutter run`

**Note:** For quick prototyping without downloading fonts, replace the font family
references with `google_fonts` package calls or use system fonts temporarily.

## Next Steps (Production)

- [ ] Wire up Riverpod state management
- [ ] Add go_router for declarative navigation + Hero transitions
- [ ] Connect Supabase backend for hobby data
- [ ] Implement `flutter_animate` for staggered list entry animations
- [ ] Add shimmer loading skeletons (skeleton_loader package)
- [ ] Implement share card generation (screenshot + brand overlay)
- [ ] Add PostHog analytics events
- [ ] Sentry crash reporting
- [ ] Light mode polish pass
- [ ] Accessibility audit (semantics, contrast, reduced motion)
