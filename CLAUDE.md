# TrySomething — Project Context

A hobby discovery app ("helps you actually start") built with Flutter. Dark-mode-first "Midnight Neon" design. Backend is live (Node.js + Express on Vercel, Neon Postgres). Architecture is Riverpod + GoRouter with API-backed repositories, Hive caching, and SharedPreferences persistence.

## Tech Stack

### Flutter Client
- **Framework:** Flutter (Dart ^3.6.0)
- **State:** flutter_riverpod ^2.6.1 — `StateNotifierProvider` for mutable state, `Provider` for derived
- **Routing:** go_router ^14.8.1 — 26 routes, auth + onboarding redirect guards
- **Fonts:** google_fonts ^6.2.1 — Source Serif 4 (headings), DM Sans (body), IBM Plex Mono (data)
- **Icons:** material_design_icons_flutter, phosphor_flutter
- **Images:** cached_network_image + dio
- **HTTP:** Dio with AuthInterceptor (auto-attaches JWT, handles 401 refresh)
- **Auth:** flutter_secure_storage (tokens), google_sign_in (Google OAuth)
- **Caching:** Hive (hobby content cache), SharedPreferences (onboarding, user prefs, hobby statuses)
- **Serialization:** Freezed + json_annotation with build_runner code generation
- **Animations:** flutter_animate, plus many custom AnimationController/CustomPainter animations
- **Bottom nav:** Local fork of `curved_navigation_bar` in `lib/components/curved_nav/` (5 files, customized `buttonElevation` parameter)

### Backend (live)
- **Server:** Node.js + Express (TypeScript), deployed to Vercel (serverless functions)
- **URL:** `https://server-psi-seven-49.vercel.app/api`
- **Database:** Neon Postgres (serverless)
- **ORM:** Prisma (12 models: 10 content + User + UserPreference)
- **Auth:** Email + password + Google sign-in (JWT pair: access 15min, refresh 30 days)
- **Server directory:** `server/` (within main repo)

## Architecture

```
lib/
├── main.dart                    # Bootstrap, ProviderScope, SharedPreferences init
├── router.dart                  # GoRouter: 26 routes, auth + onboarding redirect guards
├── models/
│   ├── hobby.dart               # Hobby, KitItem, RoadmapStep, HobbyCategory, UserHobby, UserPreferences
│   ├── features.dart            # UserProfile, Challenge, ScheduleEvent, HobbyCombo, FaqItem, CostBreakdown
│   ├── social.dart              # JournalEntry, BuddyProfile, BuddyActivity, CommunityStory, NearbyUser
│   ├── seed_data.dart           # Static SeedData: 9 categories, all hobbies with full content
│   └── feature_seed_data.dart   # Static FeatureSeedData: journals, buddies, challenges, etc.
├── core/
│   ├── api/
│   │   ├── api_client.dart      # Dio singleton with AuthInterceptor
│   │   └── api_constants.dart   # All endpoint path constants
│   └── auth/
│       ├── auth_interceptor.dart # Attaches JWT, handles 401 auto-refresh
│       └── token_storage.dart   # flutter_secure_storage wrapper
├── data/
│   └── repositories/
│       ├── auth_repository.dart          # Auth interface
│       ├── auth_repository_api.dart      # Auth API implementation
│       ├── hobby_repository.dart         # Hobby interface
│       └── hobby_repository_api.dart     # Hobby API implementation (Hive cache + SeedData fallback)
├── providers/
│   ├── auth_provider.dart       # AuthNotifier (register/login/google/logout/restore), AuthState, AuthMethod
│   ├── hobby_provider.dart      # Async hobby providers (API → Hive cache → SeedData fallback)
│   ├── user_provider.dart       # onboardingComplete, userPreferences, userHobbies (SharedPrefs-persisted)
│   └── feature_providers.dart   # profile, journal, challenge, schedule, shoppingList, notes, compare, buddy, stories
├── screens/
│   ├── main_shell.dart          # ShellRoute with 4-tab bottom nav (Discover, Explore, My Stuff, Profile)
│   ├── auth/
│   │   ├── login_screen.dart    # Email/password + Google sign-in
│   │   └── register_screen.dart # Registration with Google sign-up
│   ├── onboarding/              # 3-page animated onboarding (vibes, budget, time, solo/social)
│   ├── feed/                    # Vertical discovery feed with category chip filter
│   ├── explore/                 # 2-column category grid with filter panel
│   ├── search/                  # Full-text search across hobbies
│   ├── my_stuff/                # Personal library segmented by status (Saved/Trying/Active/Done)
│   ├── profile/                 # User profile, stats, activity heatmap, skills radar
│   ├── settings/                # Settings + onboarding reset + logout
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

1. `main.dart` initializes SharedPreferences, overrides `sharedPreferencesProvider`, shows splash overlay during auth restore
2. `AuthNotifier.tryRestoreSession()` checks for stored JWT tokens, calls `/users/me` to verify
3. `router.dart` redirect chain: auth status (unauthenticated → `/login`) → onboarding check (→ `/onboarding`) → normal routing
4. Router uses `refreshListenable` pattern (ValueNotifier + `ref.listen`) — NOT `ref.watch` (which would recreate the router)
5. Onboarding collects preferences → persisted locally via `userPreferencesProvider`, synced to server fire-and-forget
6. Feed reads `hobbyListProvider` (API → Hive cache → SeedData fallback) filtered by `selectedCategoryProvider`
7. Detail screen reads `hobbyByIdProvider`, user progress from `userHobbiesProvider` (SharedPreferences only — not yet synced to server)
8. Feature screens read from `feature_providers.dart` (mostly in-memory, backed by `FeatureSeedData`)

## Commands

```bash
flutter analyze lib/    # Should show 0 errors (info-level prefer_const_constructors warnings are expected)
flutter run             # Hot restart (Shift+R) required after theme/color constant changes
```

## Current State

### Batch Progress

| Batch | Name | Status | What shipped |
| --- | --- | --- | --- |
| 1 | **Foundation** | DONE | Server scaffolding (Prisma, Neon, health endpoint). Flutter repository pattern, Dio/Hive init, model serialization, category UI mapping extraction. |
| 2 | **Auth & Onboarding** | DONE | Email + Google sign-in, JWT auth, login/register screens, splash screen, profile + preferences sync, router auth guards. |
| 3 | **Core Content** | DONE | All hobby data from API. 15 screens transitioned from SeedData to async API-backed providers. Loading/error states. Hive caching with SeedData fallback. |
| 4 | **User Progress** | NEXT | Plan written and approved (`.claude/plans/valiant-sauteeing-sutton.md`). Will persist hobby save/try/complete + step tracking + activity log + streaks to server. |
| 5 | Personal Tools | Planned | Journal, notes, scheduler, shopping list — full CRUD synced to server. |
| 6 | Social | Planned | Buddy pairing, community stories, nearby users. |
| 7 | Gamification | Planned | Weekly challenges, achievements, year-in-review with real data. |
| 8 | Polish & Ship | Planned | Push notifications, analytics, crash reporting, tests, CI/CD, app store submission. |

### What's live now

**Server (11 serverless functions, Vercel Hobby plan limit is 12):**

- URL: `https://server-psi-seven-49.vercel.app/api`
- 12 Prisma models: 10 content (Hobby, Category, KitItem, RoadmapStep, FaqItem, CostBreakdown, BudgetAlternative, HobbyCombo, SeasonalPick, MoodTag) + User + UserPreference
- Auth endpoints: register, login, refresh, google (consolidated into `server/api/auth/[action].ts`)
- User endpoints: me (GET/PUT), preferences (PUT) (consolidated into `server/api/users/[path].ts`)
- Content endpoints: hobbies (list, detail, search, combos, seasonal, mood) + categories + per-hobby features (faq, cost, budget)
- Server accepts both `idToken` and `accessToken` for Google sign-in (Windows/web sends accessToken, Android/iOS sends idToken)
- JWT pair: access token 15min, refresh token 30 days
- Google OAuth: 3 client IDs (Android, iOS, Web) — server checks `GOOGLE_CLIENT_IDS` env var

**Flutter client:**

- All 26 screens + login/register screens implemented with full Midnight Neon dark theme
- API-backed repositories with Hive caching and SeedData fallback for hobby content
- Auth: email + password + Google sign-in with flutter_secure_storage token persistence
- Dio AuthInterceptor: auto-attaches Bearer token, catches 401, refreshes, retries
- GoRouter redirect chain using `refreshListenable` pattern (stable router, no recreation)
- Animated splash screen overlay during session restore (`AuthStatus.unknown`)
- Per-button loading spinners (AuthMethod enum) on login/register screens
- `debugPrint` logging on Google sign-in errors for diagnostics

**What's NOT yet server-synced (still local-only):**

- User hobby progress (save/try/complete, step tracking) — SharedPreferences only, Batch 4 will fix this
- Feature state (journal, schedule, notes, challenges) — in-memory only, resets on restart
- Activity heatmap — hardcoded seed data

### Key architecture files

**Server:**

- `server/api/auth/[action].ts` — All 4 auth endpoints in one handler (register, login, refresh, google)
- `server/api/users/[path].ts` — User endpoints (me, preferences) — Batch 4 will add hobbies/activity here
- `server/prisma/schema.prisma` — All Prisma models
- `server/lib/auth.ts` — JWT helpers (hashPassword, comparePassword, generateTokenPair, verifyAccessToken, requireAuth)
- `server/lib/mappers.ts` — Response mapping (strips sensitive fields)
- `server/lib/middleware.ts` — CORS, methodNotAllowed, errorResponse helpers
- `server/vercel.json` — Route rules mapping URLs to consolidated handler files

**Flutter:**

- `lib/core/api/api_client.dart` — Dio singleton with AuthInterceptor
- `lib/core/api/api_constants.dart` — All endpoint path constants (baseUrl + paths)
- `lib/core/auth/token_storage.dart` — flutter_secure_storage wrapper (saveTokens, getAccessToken, clearTokens)
- `lib/core/auth/auth_interceptor.dart` — Dio interceptor: attaches JWT, handles 401 refresh with separate Dio instance
- `lib/providers/auth_provider.dart` — AuthNotifier (register/login/google/logout/restore), AuthState, AuthMethod enum
- `lib/providers/hobby_provider.dart` — Async hobby providers (API → Hive cache → SeedData fallback)
- `lib/providers/user_provider.dart` — SharedPreferences-backed onboarding/preferences/userHobbies
- `lib/router.dart` — GoRouter with refreshListenable + auth/onboarding redirect chain
- `lib/data/repositories/` — Repository pattern (interface + API impl) for auth and hobbies

### Build commands

```bash
flutter analyze lib/              # Should show 0 errors
flutter run                       # Basic run
flutter run --dart-define=GOOGLE_SERVER_CLIENT_ID=973949791990-m09mp4019a2i5dplg5og1h6mvlvmmvsa.apps.googleusercontent.com  # With Google Sign-In idToken support on Android
dart run build_runner build --delete-conflicting-outputs  # Regenerate Freezed/JSON files
cd server && npx vercel --prod    # Deploy server to Vercel
```

### Google OAuth setup

- **Web client ID:** `973949791990-m09mp4019a2i5dplg5og1h6mvlvmmvsa.apps.googleusercontent.com` (also used as `serverClientId` on Android via dart-define)
- **Android client ID:** Bound to debug keystore SHA-1 + `com.example.trysomething`
- **iOS client ID:** GoogleService-Info.plist in `ios/Runner/`, reversed client ID in Info.plist URL schemes
- **Vercel env vars:** `GOOGLE_CLIENT_IDS` (all 3 comma-separated), `JWT_SECRET`, `JWT_REFRESH_SECRET`, `DATABASE_URL`

### Known issues / notes

- Vercel Hobby plan allows max 12 serverless functions — currently at 11. All new endpoints must be consolidated into existing handler files.
- Vercel deployments can go stale/down occasionally — if all endpoints return 404, redeploy with `cd server && npx vercel --prod`
- On Windows, `google_sign_in` doesn't return `idToken` — uses `accessToken` fallback via Google userinfo endpoint
- `GoogleSignIn.signOut()` hangs on Windows/Linux — called as fire-and-forget with `.catchError`
- `String.fromEnvironment` returns `''` not `null` — serverClientId uses ternary null check

## Production Roadmap — Remaining Batches

Detailed Batch 4 plan: `.claude/plans/valiant-sauteeing-sutton.md`

### Critical path files (touched in upcoming batches)

- `lib/providers/user_provider.dart` — Batch 4
- `lib/providers/feature_providers.dart` — Batches 5, 6, 7
- `lib/router.dart` — Batch 8
- `server/prisma/schema.prisma` — Every batch adds models
- `server/api/users/[path].ts` — Batches 4, 5 (add new switch cases, no new serverless functions)

### Remaining batch details

**Batch 4 — User Progress (3 Prisma models, ~7 endpoints, 4 screens)**
Models: UserHobby, UserCompletedStep, UserActivityLog. Optimistic updates with rollback. SharedPreferences as offline cache. Streak computed server-side from activity log. All endpoints consolidated into existing `users/[path].ts`.

**Batch 5 — Personal Tools (4 models, ~4 endpoints, 4 screens)**
Full CRUD sync for: Journal, Notes, Scheduler, Shopping list.

**Batch 6 — Social & Community (5 models, ~7 endpoints, 3 screens)**
Buddy pairing, community stories with reactions, nearby users (earthdistance).

**Batch 7 — Gamification (4 models, ~5 endpoints, 3 screens)**
Weekly challenges, achievements (auto-unlock), year-in-review with real data.

**Batch 8 — Production Polish (1 model, ~2 endpoints, cross-cutting)**
Push notifications (FCM), analytics, crash reporting, tests, CI/CD, app store submission.

**Totals remaining:** 17 Prisma models, ~25 endpoints across 4 handler files
