# TrySomething — Project Context

A hobby discovery app ("helps you actually start") built with Flutter. Dark-mode-first "Midnight Neon" design. Currently running on hardcoded seed data; architecture is Riverpod + GoRouter with SharedPreferences persistence. Backend roadmap planned and approved — see Production Roadmap section below.

## Tech Stack

### Flutter Client
- **Framework:** Flutter (Dart ^3.6.0)
- **State:** flutter_riverpod ^2.6.1 — `StateNotifierProvider` for mutable state, `Provider` for derived
- **Routing:** go_router ^14.8.1 — 24 routes, onboarding redirect guard
- **Fonts:** google_fonts ^6.2.1 — Source Serif 4 (headings), DM Sans (body), IBM Plex Mono (data)
- **Icons:** material_design_icons_flutter, phosphor_flutter
- **Images:** cached_network_image + dio
- **Persistence:** shared_preferences (onboarding, user prefs, hobby statuses); feature state is in-memory
- **Animations:** flutter_animate, plus many custom AnimationController/CustomPainter animations
- **Bottom nav:** Local fork of `curved_navigation_bar` in `lib/components/curved_nav/` (5 files, customized `buttonElevation` parameter)
- **Unused deps (ready for Batch 1):** Dio (HTTP), Hive (local cache), Freezed + JsonAnnotation (code gen), postgres ^3.4.5

### Backend (planned, not yet implemented)
- **Server:** Node.js + Express (TypeScript), deployed to Vercel (serverless functions)
- **Database:** Neon Postgres (serverless)
- **ORM:** Prisma
- **Auth:** Email + password + Google sign-in (JWT-based, bcryptjs + jsonwebtoken + Google OAuth)
- **Server repo:** `trysomething-api/` (separate project, scaffolded but not yet connected)

## Architecture

```
lib/
├── main.dart                    # Bootstrap, ProviderScope, SharedPreferences init
├── router.dart                  # GoRouter: 24 routes, onboarding redirect guard
├── models/
│   ├── hobby.dart               # Hobby, KitItem, RoadmapStep, HobbyCategory, UserHobby, UserPreferences
│   ├── features.dart            # UserProfile, Challenge, ScheduleEvent, HobbyCombo, FaqItem, CostBreakdown
│   ├── social.dart              # JournalEntry, BuddyProfile, BuddyActivity, CommunityStory, NearbyUser
│   ├── seed_data.dart           # Static SeedData: 9 categories, all hobbies with full content
│   └── feature_seed_data.dart   # Static FeatureSeedData: journals, buddies, challenges, etc.
├── providers/
│   ├── hobby_provider.dart      # hobbyList, hobbyById, categories, selectedCategory, filteredHobbies
│   ├── user_provider.dart       # onboardingComplete, userPreferences, userHobbies (SharedPrefs-persisted)
│   └── feature_providers.dart   # profile, journal, challenge, schedule, shoppingList, notes, compare, buddy, stories
├── screens/
│   ├── main_shell.dart          # ShellRoute with 4-tab bottom nav (Discover, Explore, My Stuff, Profile)
│   ├── onboarding/              # 3-page animated onboarding (vibes, budget, time, solo/social)
│   ├── feed/                    # Vertical discovery feed with category chip filter
│   ├── explore/                 # 2-column category grid
│   ├── search/                  # Full-text search across hobbies
│   ├── my_stuff/                # Personal library segmented by status (Saved/Trying/Active/Done)
│   ├── profile/                 # User profile, stats, activity heatmap, skills radar
│   ├── settings/                # Settings + onboarding reset
│   ├── detail/                  # Full hobby detail: hero, specs, starter kit, roadmap checklist
│   ├── quickstart/              # Modal slide-up hobby starter sheet
│   └── features/                # 16 feature screens (see Routes below)
├── components/
│   ├── hobby_card.dart          # Main feed card (parallax, Hero tags, particle burst save animation)
│   ├── shared_widgets.dart      # SectionHeader, OverlineLabel, HobbyMiniCard
│   ├── spec_badge.dart          # Cost/time/difficulty pills (glass + solid styles)
│   ├── category_tile.dart       # CategoryTile (grid) + CategoryChipBar (filter)
│   ├── roadmap_step_tile.dart   # Animated checklist step (elastic spring check animation)
│   ├── try_today_button.dart    # Breathing-glow coral CTA button
│   ├── shimmer_skeleton.dart    # Loading skeletons (feed, explore, detail)
│   ├── glass_container.dart     # Frosted dark glass surface with noise grain texture
│   └── curved_nav/              # Local fork of curved_labeled_navigation_bar
│       ├── curved_navigation_bar.dart      # Main widget (custom buttonElevation param)
│       ├── curved_navigation_bar_item.dart # Item data class (label + labelStyle)
│       ├── nav_bar_item_widget.dart        # Individual nav item (icon + label layout)
│       ├── nav_custom_painter.dart         # Paints curved bar background
│       └── nav_custom_clipper.dart         # Clips overflow
└── theme/
    ├── app_colors.dart          # Midnight Neon palette (all color constants)
    ├── app_theme.dart           # Material 3 ThemeData.dark
    ├── app_typography.dart      # Type scale (serif/sans/mono)
    ├── app_icons.dart           # All icon constants (MDI)
    ├── spacing.dart             # 4px grid, radii, sizes, shadows, gradients
    ├── motion.dart              # Animation tokens (durations, curves, scale, physics)
    └── scroll_physics.dart      # Custom rubber-band overscroll physics
```

## Routes

| Path | Screen | Notes |
|---|---|---|
| `/onboarding` | OnboardingScreen | Guarded — redirects away once complete |
| `/feed` | DiscoverFeedScreen | Shell tab 0 |
| `/explore` | ExploreScreen | Shell tab 1 |
| `/my` | MyStuffScreen | Shell tab 2 |
| `/profile` | ProfileScreen | Shell tab 3 |
| `/hobby/:id` | HobbyDetailScreen | Slide-right push |
| `/quickstart/:hobbyId` | QuickstartScreen | Slide-up modal with backdrop blur |
| `/settings` | SettingsScreen | Slide-right push |
| `/mood-match` | MoodMatchScreen | Discovery |
| `/seasonal` | SeasonalPicksScreen | Discovery |
| `/faq/:hobbyId` | BeginnerFaqScreen | Per-hobby FAQ |
| `/notes/:hobbyId` | PersonalNotesScreen | Per-step notes |
| `/budget/:hobbyId` | BudgetAlternativesScreen | DIY/budget/premium alternatives |
| `/combos` | HobbyCombosScreen | Complementary hobby pairs |
| `/cost/:hobbyId` | CostCalculatorScreen | 3-tier cost projection |
| `/compare` | CompareModeScreen | Side-by-side comparison |
| `/shopping/:hobbyId` | ShoppingListScreen | Checkable starter kit list |
| `/challenge` | WeeklyChallengeScreen | Gamification |
| `/journal` | HobbyJournalScreen | Photo journal |
| `/scheduler` | HobbySchedulerScreen | Weekly session planner |
| `/buddy` | BuddyModeScreen | Friend activity feed |
| `/stories` | CommunityStoriesScreen | Success stories |
| `/local` | LocalDiscoveryScreen | Nearby users |
| `/year-review` | YearInReviewScreen | Annual stats |

## Theme System — "Midnight Neon"

Dark-mode-first. Token-based: 37+ files reference `AppColors` tokens by name. Changing values in `app_colors.dart` auto-propagates everywhere.

### Color Tokens
**Neutrals (dark → light):** cream `#0A0A0F` (bg) → warmWhite `#141420` (surface) → sand `#1E1E2E` (elevated) → sandDark `#2A2A3C` (border) → stone `#363650` → warmGray `#6B6B80` (muted) → driftwood `#A0A0B8` (secondary text) → espresso `#C0C0D0` → darkBrown `#D8D8E8` → nearBlack `#F8F8FC` (headings)

**Accents:** coral `#FF6B6B` (CTA), amber `#FBBF24` (gold/badges), indigo `#7C3AED` (electric violet brand), sage `#06D6A0` (mint/success)

**`*Pale` tokens** are dark-tinted backgrounds for selected states (e.g., coralPale `#2A1215`).

**9 category colors:** catCreative=#D946EF, catOutdoors=#06D6A0, catFitness=#FF4757, catMaker=#FBBF24, catMusic=#818CF8, catFood=#FB923C, catCollecting=#38BDF8, catMind=#7C3AED, catSocial=#F472B6

### Typography
- **Serif** (Source Serif 4): serifDisplay(38), serifHero(36), serifTitle(32), serifHeading(26), serifSubheading(22), serifCardTitle(30, white on images)
- **Sans** (DM Sans): sansSection(19), sansBody(15), sansBodySmall(14), sansLabel(13), sansCaption(12), sansTiny(11), sansNav(10), sansCta(14), sansButton(15), overline(11), categoryLabel(10)
- **Mono** (IBM Plex Mono): monoTimer(40), monoLarge(18), monoMedium(16), monoBadge(11), monoCaption(12), monoTiny(11)

### Spacing (4px grid)
xs=4, sm=8, md=12, lg=16, xl=24, xxl=32, xxxl=48. Card radius=22, tile=16, button=14, input=12, badge=100(pill).

### Motion Tokens
fast=150ms, normal=250ms, slow=350ms, hero=500ms, spring=400ms. breathingGlow=1800ms. navForward=350ms, navBack=300ms.

## Key Patterns

- **Token architecture:** Never use raw hex in screens. Use `AppColors.*`, `AppTypography.*`, `Spacing.*`, `Motion.*`.
- **Hardcoded `Colors.white`:** 100+ usages across screens — these are intentional (text/icons on image overlays or colored buttons). Do NOT convert to tokens.
- **Hardcoded hex in spacing.dart:** Shadows use `#000000`, gradients use `#0A0A0F` (cream bg). Must be updated manually if palette changes.
- **Hardcoded hex in onboarding_screen.dart:** `_GradientBlobPainter` has blob accent colors and wash gradient stops. Must be updated manually if palette changes.
- **Hero animations:** Tagged `hobby_image_{id}` and `hobby_title_{id}` on feed cards → detail screen.
- **Custom painters:** Gradient blob bg (onboarding), wave underline (onboarding), celebration particles (onboarding), action button particle burst (hobby_card), noise grain (glass_container).
- **Riverpod:** `StateNotifierProvider` for mutable state with persistence. `.family` for per-ID lookups. Derived `Provider` for filtered/computed values.
- **GoRouter redirect:** `_redirectGuard` in router.dart checks onboarding completion.
- **Animations:** Mix of `flutter_animate` package and raw `AnimationController` + `CurvedAnimation`. Onboarding uses `_iv()` helper for interval calculations.
- **Category pills (neutral style):** `AppColors.sand` bg, no border, `AppColors.driftwood` text, icon keeps `hobby.catColor`. Applied across: detail, search, explore, seasonal_picks, year_in_review, hobby_journal, local_discovery. Exception: my_stuff image overlay badges use colored bg + white text (for contrast on photos).
- **Bottom nav (curved):** Local fork in `lib/components/curved_nav/`. Uses `defaultTargetPlatform` instead of `dart:io Platform` for web compatibility. Key params in main_shell.dart: `height: 85`, `buttonElevation: 115`, `iconPadding: 10`. Label bottom padding: `20.0` (both platforms, in nav_bar_item_widget.dart).
- **Feed card sizing:** Fixed `height: Spacing.cardHeight` (480px) with `bottom: 90` padding on each PageView item to clear the bottom nav (since `extendBody: true`).
- **Search input:** No focused border (set to `BorderSide.none` in app_theme.dart global InputDecoration).
- **Heatmap tooltip:** Uses `AppColors.sand` bg (NOT nearBlack — that's #F8F8FC, the lightest color in dark theme!).

## Data Flow

1. `main.dart` initializes SharedPreferences, overrides `sharedPreferencesProvider`
2. `router.dart` checks `onboardingCompleteProvider` → redirect to `/onboarding` or `/feed`
3. Onboarding collects preferences → persisted via `userPreferencesProvider`
4. Feed reads `hobbyListProvider` (from `SeedData`) filtered by `selectedCategoryProvider`
5. Detail screen reads `hobbyByIdProvider`, user progress from `userHobbiesProvider`
6. Feature screens read from `feature_providers.dart` (mostly in-memory, backed by `FeatureSeedData`)

## Commands

```bash
flutter analyze lib/    # Should show 0 errors (info-level prefer_const_constructors warnings are expected)
flutter run             # Hot restart (Shift+R) required after theme/color constant changes
```

## Current State

- All 21 screens implemented with full UI + 16 feature screens registered in router
- Midnight Neon dark theme applied across all 37+ files via token system
- Custom curved bottom nav bar (local fork, web-compatible)
- Category pills neutralized across all screens (sand bg, driftwood text)
- All data is seed data (no backend connected yet)
- SharedPreferences persists: onboarding completion, user preferences, hobby statuses/progress
- Feature state (journal, schedule, notes) is in-memory only (resets on app restart)
- Server project scaffolded at `../trysomething-api/` (npm + deps installed, not yet configured)

## Production Roadmap — 8 Batches

Full detailed plan: `.claude/plans/elegant-tickling-yao.md`

### Stack decisions (approved)
- **Server:** Node.js + Express (TypeScript) on Vercel (serverless)
- **Database:** Neon Postgres + Prisma ORM
- **Auth:** Email + password + Google sign-in (JWT)
- **Flutter deps to wire:** Dio (HTTP), Hive (cache), Freezed (serialization), flutter_secure_storage, connectivity_plus, google_sign_in

### Batch overview

| # | Batch | What ships | Key screens affected |
|---|-------|-----------|---------------------|
| 1 | **Foundation** | Server scaffolding (Prisma, Neon, health endpoint). Flutter repository pattern + Dio/Hive init. Model serialization. Category UI mapping extraction. | 0 (architecture only) |
| 2 | **Auth & Onboarding** | User registration (email + Google), login, JWT auth. Profile + preferences sync to server. | Login, Register (new), Onboarding, Profile, Settings |
| 3 | **Core Content** | All hobby data from API. Replace SeedData reads with async providers. Loading/error states. | Feed, Explore, Search, Detail, Quickstart + 10 feature screens (**15 total**) |
| 4 | **User Progress** | Save/try/complete hobbies via API. Roadmap step tracking. Streaks. Activity heatmap. | My Stuff, Detail, Quickstart, Profile |
| 5 | **Personal Tools** | Journal, notes, scheduler, shopping list — full CRUD synced to server. | Journal, Notes, Scheduler, Shopping List |
| 6 | **Social** | Buddy pairing, community stories with reactions, location-based nearby users. | Buddy Mode, Stories, Local Discovery |
| 7 | **Gamification** | Weekly challenges, achievements (auto-unlock), year-in-review with real data. | Challenge, Year Review, Profile |
| 8 | **Polish & Ship** | Push notifications (FCM), analytics, crash reporting, tests, CI/CD, app store submission. | Cross-cutting |

### Database: 29 Prisma models total across all batches
### Server: ~43 API endpoints across all batches
### Flutter: ~71 new Dart files + ~25 existing files modified

### Critical path files (touched in multiple batches)
- `lib/main.dart` — Batches 1, 2, 8
- `lib/providers/hobby_provider.dart` — Batches 1, 3
- `lib/providers/user_provider.dart` — Batches 2, 4
- `lib/providers/feature_providers.dart` — Batches 5, 6, 7
- `lib/router.dart` — Batches 2, 8
- `lib/models/hobby.dart` — Batch 1 (serialization + UI mapping extraction)
- `prisma/schema.prisma` — Every batch adds models




## TrySomething — Production Roadmap

---

## Context

The app is a polished Flutter UI prototype (26 screens, Midnight Neon dark theme, Riverpod + GoRouter) running entirely on hardcoded seed data.

- Zero backend  
- Zero auth  
- Zero persistence beyond SharedPreferences for onboarding/preferences/hobby status  

**Goal:** Take it to a production-ready, shippable app through 8 incremental batches following the user journey.

**Current state:**  
56 Dart files, ~4,200 LOC, all screens functional with mock data.

**Target state:**  
Real backend, auth, data sync, social features, push notifications, analytics, CI/CD, store submission.

---

# Backend Stack

- **Server:** Node.js + Express (TypeScript), deployed to Vercel (serverless functions)
- **Database:** Neon Postgres (serverless)
- **Auth:** Email + password + Google sign-in (JWT-based)
- **Flutter HTTP:** Dio
- **Local cache:** Hive
- **Serialization:** Freezed + JsonAnnotation

---

# Server Repo Structure (`trysomething-api/`)


trysomething-api/
api/
hobbies/
index.ts
[id].ts
search.ts
auth/
register.ts
login.ts
refresh.ts
google.ts
users/
me.ts
preferences.ts
hobbies.ts
activity.ts
journal.ts
notes.ts
schedule.ts
shopping.ts
buddies/
stories/
challenges/
lib/
db.ts
auth.ts
middleware.ts
prisma/
schema.prisma
vercel.json
package.json
tsconfig.json


---

# Batch 1 — Foundation

## Goal

Architectural backbone on both sides.  
App works identically but is ready for API swap.

---

## Server Setup


trysomething-api/
api/
health.ts
lib/
db.ts
middleware.ts
prisma/
schema.prisma
seed.ts
vercel.json
package.json
tsconfig.json
.env.example


### Prisma Content Models (10)

- Hobby
- Category
- KitItem
- RoadmapStep
- FaqItem
- CostBreakdown
- BudgetAlternative
- HobbyCombo
- SeasonalPick
- MoodTag

---

## Flutter Architecture

### New Structure


lib/core/
api/
storage/

lib/data/
repositories/
datasources/

lib/theme/


### Key Changes

- JSON serialization for models
- Remove UI fields from models
- Repository abstraction layer
- Hive + Dio initialized
- SeedData becomes fallback only

---

# Batch 2 — Auth & Onboarding

## Goal

Users can:

- Register (email or Google)
- Log in
- Sync profile + preferences

### Server Models

- User
- UserPreference

### Endpoints


/api/auth/register
/api/auth/login
/api/auth/refresh
/api/auth/google
/api/users/me
/api/users/preferences


### Flutter Additions


lib/core/auth/
lib/screens/auth/
lib/providers/auth_provider.dart


Key changes:

- Router guards
- Auth interceptor
- Secure token storage
- Google Sign-In config

---

# Batch 3 — Core Content

## Goal

Replace all SeedData with live API.

15 screens transition from mock → real.

### Endpoints


/api/hobbies
/api/hobbies/:id
/api/hobbies/search
/api/categories
/api/hobbies/combos
/api/hobbies/seasonal
/api/hobbies/mood/:mood


### Flutter Changes

- AsyncNotifier providers
- Loading + error states
- Debounced search
- Hive fallback cache

---

# Batch 4 — User Progress

## Goal

Persist:

- Saved hobbies
- Step completion
- Streaks
- Activity logs

### Models

- UserHobby
- UserCompletedStep
- UserActivityLog

Daily streak handled via server cron.

---

# Batch 5 — Personal Tools

## Goal

Full CRUD sync for:

- Journal
- Notes
- Scheduler
- Shopping list

### Models

- JournalEntry
- PersonalNote
- ScheduleEvent
- ShoppingListCheck

---

# Batch 6 — Social & Community

## Goal

Real social features.

### Models

- BuddyPair
- BuddyActivity
- CommunityStory
- StoryReaction
- UserLocation

Features:

- Buddy requests
- Story moderation
- Nearby users (earthdistance)

---

# Batch 7 — Gamification

## Goal

Challenges, achievements, year review.

### Models

- Challenge
- UserChallenge
- Achievement
- UserAchievement

Server handles achievement triggers + cron jobs.

---

# Batch 8 — Production Polish

## Goal

Ship to App Store and Play Store.

### Flutter New Dependencies

- firebase_core
- firebase_messaging
- firebase_analytics
- firebase_crashlytics
- app_links

### Analytics Events

- hobby_viewed
- hobby_saved
- hobby_started
- step_completed
- journal_entry_created
- search_performed
- challenge_completed
- buddy_paired
- story_submitted

---

# Testing


test/unit/models/
test/unit/repositories/
test/unit/providers/
test/widget/screens/
test/widget/components/
test/integration/


---

# CI/CD


.github/workflows/
ci.yml
cd_android.yml
cd_ios.yml
api_deploy.yml


---

# Summary

| Batch | Prisma Models | Endpoints | Screens Mock→Real |
|-------|--------------|----------|------------------|
| 1 | 10 | 1 | 0 |
| 2 | 2 | 7 | 5 |
| 3 | 0 | 11 | 15 |
| 4 | 3 | 6 | 4 |
| 5 | 4 | 4 | 4 |
| 6 | 5 | 7 | 3 |
| 7 | 4 | 5 | 3 |
| 8 | 1 | 2 | 0 |

**Totals**

- 29 Prisma models  
- ~43 endpoints  
- 26 screens  
- Full production pipeline  

---

# Verification Per Batch

## Server

```bash
npx prisma migrate dev
Deploy to Vercel
Test endpoints with curl/Postman
Flutter
flutter analyze
Run app
Test Android + Chrome
Integration

Flutter calls live API

Auth persists

Data round-trips

Sync verified