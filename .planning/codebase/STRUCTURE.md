# Codebase Structure

**Analysis Date:** 2026-03-21

## Directory Layout

```
trysomething/
├── lib/                                    # Flutter client source (Dart)
│   ├── main.dart                           # App entry: ProviderScope, service init, splash
│   ├── router.dart                         # GoRouter: 26+ routes, auth/onboarding guards
│   ├── models/                             # Data models (Freezed, JSON serialization)
│   ├── core/                               # Infrastructure services
│   │   ├── api/                            # Dio HTTP client + endpoints
│   │   ├── auth/                           # JWT, token storage, OAuth
│   │   ├── analytics/                      # PostHog tracking
│   │   ├── notifications/                  # FCM + local notifications
│   │   ├── subscription/                   # RevenueCat
│   │   ├── media/                          # Image upload helpers
│   │   ├── error/                          # Sentry error reporter
│   │   └── storage/                        # Hive caching + SharedPreferences
│   ├── data/repositories/                  # Data access abstraction
│   ├── providers/                          # Riverpod state management
│   ├── screens/                            # UI screens (26+ files)
│   ├── components/                         # Reusable widgets
│   └── theme/                              # Design tokens (colors, typography, spacing)
│
├── server/                                 # Node.js/Vercel backend
│   ├── api/                                # Vercel serverless functions
│   │   ├── auth/[action].ts                # register, login, refresh, google, apple
│   │   ├── generate/[action].ts            # hobby, faq, cost, budget, coach AI
│   │   ├── users/[path].ts                 # Consolidated user data handler
│   │   ├── hobbies/                        # Content endpoints
│   │   │   ├── index.ts                    # List all hobbies
│   │   │   ├── [id]/index.ts               # Get hobby by ID
│   │   │   ├── [id]/[feature].ts           # Per-hobby features (faq, cost, budget)
│   │   │   ├── search.ts                   # Full-text search
│   │   │   ├── mood.ts                     # Filter by mood
│   │   │   ├── seasonal.ts                 # Filter by season
│   │   │   └── combos.ts                   # Hobby pairs
│   │   ├── categories/index.ts             # List categories
│   │   └── health.ts                       # Health check
│   ├── lib/                                # Shared utilities
│   │   ├── ai_generator.ts                 # Claude Haiku prompts (4 endpoints)
│   │   ├── auth.ts                         # bcrypt, JWT crypto
│   │   ├── content_guard.ts                # Input validation, blocklist, rate limiting
│   │   ├── db.ts                           # Prisma client singleton
│   │   ├── gamification.ts                 # Challenge/achievement logic
│   │   ├── mappers.ts                      # Response transformers
│   │   ├── middleware.ts                   # CORS, error responses
│   │   └── unsplash.ts                     # Image search + caching
│   ├── prisma/                             # Database schema + migrations
│   │   ├── schema.prisma                   # 25 models (399 lines)
│   │   └── migrations/                     # Timestamped SQL files
│   ├── package.json                        # Node.js dependencies
│   ├── vercel.json                         # Route → function mapping
│   └── test/                               # Vitest tests (exists, not populated)
│
├── .planning/codebase/                     # GSD documents (this directory)
│   ├── ARCHITECTURE.md                     # Architecture patterns, data flows
│   ├── STRUCTURE.md                        # Directory purposes, naming conventions
│   ├── CONVENTIONS.md                      # Code style, imports, error handling
│   ├── TESTING.md                          # Test patterns, setup, coverage
│   ├── STACK.md                            # Technology versions, dependencies
│   ├── INTEGRATIONS.md                     # External APIs, services
│   └── CONCERNS.md                         # Technical debt, known issues
│
├── pubspec.yaml                            # Flutter dependencies
├── pubspec.lock                            # Dependency lock file
├── CLAUDE.md                               # Project context (product thesis, tech stack, file structure, business model)
├── CLAUDE_TASKS_v5.md                      # Sprint task checklist
└── PRODUCT_GUARDRAILS.md                   # Design principles
```

## Directory Purposes

**lib/models/:**
- Purpose: Immutable data structures (Freezed + JSON serialization)
- Contains: `hobby.dart` (Hobby, Category, KitItem, RoadmapStep), `auth.dart` (User, TokenPair), `session.dart` (SessionState, SessionPhase), `features.dart` (FAQ, CostBreakdown, BudgetAlternative), `social.dart` (JournalEntry, BuddyPair, CommunityStory), `activity_log.dart`, `gamification.dart`, `curated_pack.dart`
- Key files: `seed_data.dart` (150+ hardcoded hobbies), `feature_seed_data.dart` (fixture data for testing/seeding)
- Generated: `.freezed.dart`, `.g.dart` (via `build_runner`)
- Committed: Yes (both source and generated)
- Pattern: All use `@freezed`, `copyWith()`, `fromJson()/toJson()`

**lib/core/:**
- Purpose: Infrastructure services (no UI, no screens)
- **api/:** `api_client.dart` (Dio singleton), `api_constants.dart` (base URL + all endpoints)
- **auth/:** `auth_interceptor.dart` (JWT injection + 401 refresh), `token_storage.dart` (secure Hive storage)
- **analytics/:** `analytics_service.dart` (PostHog wrapper), `analytics_provider.dart` (Riverpod DI)
- **notifications/:** `notification_service.dart` (FCM), `notification_scheduler.dart` (local scheduling), `notification_provider.dart` (DI)
- **subscription/:** `subscription_service.dart` (RevenueCat wrapper), `subscription_provider.dart` (DI), manages Pro status
- **media/:** `media_upload_helper.dart` (image upload for journal photos)
- **error/:** `error_reporter.dart` (Sentry integration), `error_provider.dart` (ProviderObserver for Riverpod errors)
- **storage/:** `local_storage.dart` (Hive box init), `cache_manager.dart` (TTL caching)

**lib/data/repositories/:**
- Purpose: Data access abstraction with pluggable backends
- Pattern: Interface (no suffix) + API implementation (`_api.dart`) + optional cache fallback (`_impl.dart`)
- Key repositories:
  - `auth_repository.dart`: register, login, loginWithGoogle, loginWithApple, getMe, updateProfile
  - `hobby_repository.dart`: getHobbies, getHobbyById, getCategories, getRelatedHobbies, searchHobbies, generateHobby
  - `user_progress_repository.dart`: saveHobby, updateStatus, toggleStep, syncFromServer, getActivityLog
  - `feature_repository.dart`: getFaq, getCostBreakdown, getBudgetAlternatives, getHobbyCombo, getMoodMatches, getSeasonalPicks
  - `personal_tools_repository.dart`: journal, notes, schedule, shopping CRUD
  - `social_repository.dart`: stories, buddy pairs, reactions
  - `gamification_repository.dart`: challenges, achievements
- DI: All injected via `repository_providers.dart`

**lib/providers/:**
- Purpose: Riverpod state management, caching, computed values
- Contains:
  - `auth_provider.dart`: `AuthNotifier` (status, user, error, loadingMethod), login/register/restore methods
  - `hobby_provider.dart`: `hobbyListProvider`, `hobbyByIdProvider`, `categoriesProvider`, `filteredHobbiesProvider`, `relatedHobbiesProvider`, `searchHobbiesProvider`
  - `user_provider.dart`: `onboardingCompleteProvider`, `userPreferencesProvider`, `userHobbiesProvider`, `hobbyCountByStatusProvider`
  - `session_provider.dart`: `SessionNotifier` (4-phase state machine), timer lifecycle
  - `subscription_provider.dart`: `isProProvider`, `proStatusProvider`, RevenueCat sync
  - `feature_providers.dart`: `faqProvider`, `costBreakdownProvider`, `journalProvider`, `scheduleProvider`, `storiesProvider`, `buddyProvider`, `challengeProvider`
  - `repository_providers.dart`: DI setup for all repositories
- Pattern: Each provider defined at module level, consumed via `ref.watch()` in screens

**lib/screens/:**
- Structure: 26+ screens across 13 directories
  - `auth/`: `login_screen.dart`, `register_screen.dart`
  - `onboarding/`: `onboarding_screen.dart` (multi-page with animations), `match_results_screen.dart`, `trial_offer_screen.dart`
  - `home/`: `home_screen.dart` (active hobby dashboard, Tab 1)
  - `discover/` → `feed/`: `discover_feed_screen.dart`, `rail_feed_screen.dart` (Tab 2 — hobby feed)
  - `you/`: `you_screen.dart` (profile, stats, saved hobbies, Tab 3)
  - `search/`: `search_screen.dart` (natural language search)
  - `detail/`: `hobby_detail_screen.dart` (full hobby profile, hero animation)
  - `quickstart/`: `quickstart_screen.dart` (bottom sheet for quick hobby launch)
  - `session/`: `session_screen.dart` (4-phase immersive), `session_prepare_phase.dart`, `session_timer_phase.dart`, `session_reflect_phase.dart`, `session_complete_phase.dart`
  - `coach/`: `hobby_coach_screen.dart` (conversational AI)
  - `settings/`: `settings_screen.dart`, `pro_screen.dart` (paywall), `privacy_policy_screen.dart`, `terms_of_service_screen.dart`
  - `features/`: 16+ feature screens (mood_match, seasonal_picks, beginner_faq, personal_notes, budget_alternatives, cost_calculator, shopping_list, hobby_journal, hobby_scheduler, compare_mode, etc.)
  - `main_shell.dart`: Bottom nav shell with floating glass dock
- Pattern: All screens are ConsumerStatefulWidget or ConsumerWidget; watch providers via `ref.watch()`

**lib/components/:**
- Purpose: Reusable UI widgets (composable building blocks)
- Contains:
  - `glass_card.dart`: Glass surface (blur + no-blur variants)
  - `glass_container.dart`: Lower-level glass primitive
  - `cinematic_scaffold.dart`: Base scaffold with warm background
  - `hobby_card.dart`: Main feed card (image + title + specs)
  - `spec_badge.dart`: Warm gray line (cost · time · difficulty)
  - `roadmap_step_tile.dart`: Checklist item with spring animation
  - `stage_roadmap_card.dart`: 4-stage roadmap display
  - `try_today_button.dart`: Coral CTA button
  - `pro_upgrade_sheet.dart`: Bottom sheet paywall
  - `particle_timer_painter.dart`: CustomPainter — 250 particles converging to shape
  - `category_shape_painter.dart`: SVG shapes for particle targets (9 categories)
  - `radial_hold_painter.dart`: Hold-to-complete ring
  - `session_glow_widget.dart`: Ambient glow effect during session
  - `shimmer_skeleton.dart`: Loading placeholders
  - `page_dots.dart`: Carousel dots
  - `page_transitions.dart`: Custom page transitions
  - `curved_nav/`: Local fork of curved navigation bar (5 files — custom buttons)
  - `shared_widgets.dart`: SectionHeader, OverlineLabel, HobbyMiniCard
  - `coach_cards.dart`: Coach mode/message cards
  - `hobby_quick_links.dart`: Quick action chips
  - `app_background.dart`: Cinematic background
  - `app_overlays.dart`: Overlays (toasts, notifications)
- Pattern: Stateless/stateful widgets; use Consumer mixin for provider access

**lib/theme/:**
- Purpose: Design tokens (single source of truth for styling)
- Contains:
  - `app_colors.dart`: 40+ tokens (background, surface, text scales, glass, accent, success, categories)
  - `app_typography.dart`: Serif/Sans/Mono scales (Source Serif 4 / DM Sans / IBM Plex Mono)
  - `app_theme.dart`: Material 3 ThemeData.dark() setup
  - `app_icons.dart`: Icon constants (MDI, phosphor)
  - `category_ui.dart`: Category display helpers
  - `spacing.dart`: 4px grid scale, radii, shadows, gradients
  - `motion.dart`: Animation durations (fast, medium, slow) and curves
  - `scroll_physics.dart`: Custom rubber-band overscroll
- Pattern: Never use raw hex in screens; reference by name (AppColors.coral, Spacing.lg)

**server/api/:**
- Purpose: Vercel serverless functions (consolidated handlers)
- **Consolidated Handlers:**
  - `auth/[action].ts`: Single handler with switch statement
    - register: Create User, hash password (bcrypt 12), generate JWT pair
    - login: Find User, compare password, return tokens
    - refresh: Verify refresh token, issue new access token
    - google: Verify Google idToken/accessToken, create/find User
    - apple: Verify Apple token, create/find User
  - `users/[path].ts`: Single handler with 15+ switch cases
    - me: GET current user
    - preferences: GET/POST user preferences
    - hobbies: GET user hobbies
    - hobbies-sync: Sync all hobbies
    - hobbies-detail: GET hobby detail for user
    - journal: GET/POST journal entries
    - journal-detail: GET/POST/DELETE single entry
    - notes: GET/POST personal notes
    - schedule: GET/POST schedule events
    - schedule-detail: Single event CRUD
    - shopping: GET/POST shopping checks
    - stories: GET/POST community stories
    - stories-detail: Single story + reactions
    - stories-react: Heart/fire reactions
    - buddies: GET buddy pairs
    - buddy-requests: GET pending requests
    - buddy-requests-detail: Accept/reject
    - similar-users: GET similar users (mood match)
    - challenges: GET/POST user challenges
    - achievements: GET user achievements
  - `generate/[action].ts`: AI generation endpoints
    - hobby: Generate full hobby profile from query
    - faq: Generate 5 FAQ items (lazy, first view)
    - cost: Generate cost projections (starter/3mo/1yr)
    - budget: Generate DIY/budget/premium alternatives per item
    - coach: Conversational AI hobby coach
- **Hobby Content:**
  - `hobbies/index.ts`: List all hobbies (GET)
  - `hobbies/[id]/index.ts`: Get hobby by ID with all features
  - `hobbies/[id]/[feature].ts`: Per-hobby endpoints (faq, cost, budget, combos)
  - `hobbies/search.ts`: Full-text search
  - `hobbies/mood.ts`: Filter by mood tags
  - `hobbies/seasonal.ts`: Filter by season
  - `hobbies/combos.ts`: Hobby pair suggestions
- **Other:**
  - `categories/index.ts`: List categories
  - `health.ts`: Health check

**server/lib/:**
- Purpose: Shared utilities for all handlers
- **ai_generator.ts**: Claude Haiku prompts (4 endpoints)
  - `generateHobby()`: Full hobby profile with kit items, roadmap, etc.
  - `generateFaq()`: 5 beginner FAQ items
  - `generateCost()`: Cost projections (starter/3mo/1yr)
  - `generateBudget()`: DIY/budget/premium alternatives per item
  - Temperature: 0.3-0.7 (creativity controlled)
- **auth.ts**: Cryptographic utilities
  - `hashPassword()`: bcrypt 12 rounds
  - `comparePassword()`: Verify hash
  - `generateTokenPair()`: Access (15min) + Refresh (30day)
  - `verifyAccessToken()`: Check signature + expiry
  - `verifyRefreshToken()`: Similar
  - `requireAuth()`: Middleware to extract + verify token from Authorization header
- **content_guard.ts**: 4-layer safety system
  - Input validation: length, charset, blocklist (weapons, drugs, NSFW, extremism)
  - AI constraints: safe/legal hobbies, CHF pricing, error for invalid queries
  - Output validation: schema check, field types/ranges, re-scan against blocklist
  - Rate limiting: 20 generations/user/24h
- **db.ts**: Prisma client singleton (reuse across warm invocations to avoid connection pool exhaustion)
- **gamification.ts**: Challenge/achievement logic
- **mappers.ts**: Response transformers
  - `mapUserWithPreferences()`: Strip passwordHash, include preferences
  - `mapHobbyDetail()`: Include category, kit items, roadmap, FAQ, cost, budget, combos
  - etc.
- **middleware.ts**: CORS, error responses, method checks
- **unsplash.ts**: Image search with category fallbacks

**server/prisma/:**
- Purpose: Database schema and migrations
- **schema.prisma:** 25 models across 9 domains
  - Content (10): Category, Hobby, KitItem, RoadmapStep, FaqItem, CostBreakdown, BudgetAlternative, HobbyCombo, SeasonalPick, MoodTag
  - Auth (2): User, UserPreference
  - Progress (3): UserHobby, UserCompletedStep, UserActivityLog
  - Personal Tools (4): JournalEntry, PersonalNote, ScheduleEvent, ShoppingCheck
  - Social (3): CommunityStory, StoryReaction, BuddyPair
  - Gamification (2): UserChallenge, UserAchievement
  - AI (1): GenerationLog (audit trail)
- **migrations/:** Timestamped SQL files (applied automatically on deploy)
- Committed: Yes (migrations are source of truth)

## Key File Locations

**Entry Points:**
- `lib/main.dart`: App bootstrap
- `lib/router.dart`: Navigation definition (routerProvider)
- `server/api/auth/[action].ts`: Auth API
- `server/api/users/[path].ts`: User data API
- `server/api/generate/[action].ts`: AI generation API

**Configuration:**
- `pubspec.yaml`: Flutter dependencies + metadata
- `pubspec.lock`: Flutter lock file
- `server/package.json`: Node.js dependencies
- `server/vercel.json`: Route → function mapping
- `lib/core/api/api_constants.dart`: All API endpoint paths
- `server/prisma/schema.prisma`: Database schema

**Core Logic:**
- `lib/providers/auth_provider.dart`: Auth state machine (login, register, restore)
- `lib/providers/session_provider.dart`: 4-phase session state machine
- `lib/providers/hobby_provider.dart`: Hobby caching + filtering
- `lib/providers/user_provider.dart`: User hobbies + preferences
- `lib/core/auth/auth_interceptor.dart`: JWT management
- `server/lib/auth.ts`: JWT + password crypto
- `server/lib/content_guard.ts`: AI safety validation
- `server/api/users/[path].ts`: User data mutations

**Testing:**
- `lib/test/`: Unit tests (golden, unit, widget)
- `server/test/`: Vitest tests (exists, not populated)

## Naming Conventions

**Files:**
- Screen files: `snake_case_screen.dart` (e.g., `hobby_detail_screen.dart`)
- Repository files: `snake_case_repository.dart` (interface), `snake_case_repository_api.dart` (API impl)
- Provider files: `snake_case_provider.dart`
- Component files: `snake_case.dart` (e.g., `hobby_card.dart`)
- Model files: `snake_case.dart` + `.freezed.dart` + `.g.dart` (generated)
- Server handlers: `[dynamic].ts` (Vercel routing convention for dynamic segments)
- Migrations: `timestamp_description.sql`

**Directories:**
- Feature directories match functionality (e.g., `session/` for session screens, `features/` for optional features)
- Repository files organized by feature domain (auth, hobby, user_progress, etc.)

**Classes:**
- Screens: `PascalCaseScreen` extends ConsumerStatefulWidget
- Notifiers: `PascalCaseNotifier` extends StateNotifier<T>
- Repositories: `PascalCaseRepository` (interface), `PascalCaseRepositoryApi` (impl)
- Components: `PascalCase` extends Widget
- Services: `PascalCaseService` (no suffix)

**Riverpod Providers:**
- StateNotifier providers: `lowerCaseProvider` with `.notifier` accessor
- FutureProvider: `lowerCaseProvider` with `.future` accessor
- Provider.family: `lowerCaseProvider(argument)` — parameterized
- Derived/computed: `descriptive_logic_provider` (e.g., `isProProvider`, `hobbyCountByStatusProvider`)

**API Endpoints:**
- Paths: lowercase with hyphens (e.g., `/api/hobbies-sync`, `/api/cost-breakdown`)
- Query params: camelCase or kebab-case per convention
- Request bodies: camelCase (email, password, displayName)

## Where to Add New Code

**New Feature (e.g., challenges, achievements):**
1. **Data model:** Add to `lib/models/` (new file or existing `features.dart`)
2. **Database:** Add tables to `server/prisma/schema.prisma`; run `prisma migrate dev --name feature_name`
3. **Repository:** Create `lib/data/repositories/feature_repository.dart` (interface) + `_api.dart` (impl)
4. **Providers:** Create `lib/providers/feature_provider.dart` (StateNotifier + FutureProviders)
5. **Screens:** Create `lib/screens/features/feature_screen.dart` (ConsumerStatefulWidget)
6. **Routes:** Add GoRoute to `lib/router.dart`
7. **Server endpoint:** Add to `server/api/users/[path].ts` (new switch case) or create new handler file

**New Screen within existing feature:**
1. Create `lib/screens/existing_feature/new_screen_screen.dart` (ConsumerStatefulWidget)
2. Add GoRoute to `lib/router.dart` (with transition)
3. Watch existing providers (no new repository)

**New Component:**
1. Create `lib/components/component_name.dart`
2. Extend StatelessWidget or StatefulWidget (or ConsumerWidget if using providers)
3. Use theme tokens: `AppColors.*`, `AppTypography.*`, `Spacing.*`, `Motion.*`

**New Utility:**
- Shared: `lib/core/` subdirectory (auth, notifications, storage, etc.) or `lib/utils/`
- Server: `server/lib/` (alongside ai_generator.ts, auth.ts, etc.)

## Special Directories

**lib/models/ (Generated):**
- Freezed code generation via `build_runner`
- Command: `dart run build_runner build --delete-conflicting-outputs`
- Includes: source `.dart` + generated `.freezed.dart` + `.g.dart`
- Committed: Yes (both source and generated)

**server/prisma/migrations/:**
- Auto-generated via `prisma migrate dev --name description`
- Never edit manually
- Replayed on deploy to keep database in sync
- Committed: Yes

**lib/components/curved_nav/:**
- Local fork of `curved_labeled_navigation_bar` (custom `buttonElevation` parameter)
- 5 files: main + item + widget + clipper + painter
- Only imported in `main_shell.dart`
- Do not update from pub.dev (will lose customization)

**lib/theme/:**
- Single source of truth for styling
- Update `app_colors.dart` if changing palette (auto-propagates)
- Some hardcoded values in screens (onboarding blobs) — must update manually if palette changes
- Never use raw color values; always reference tokens

---

*Structure analysis: 2026-03-21*
