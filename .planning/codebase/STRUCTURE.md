# Codebase Structure

**Analysis Date:** 2026-03-02

## Directory Layout

```
trysomething/
├── lib/                                    # Flutter client source
│   ├── main.dart                           # App bootstrap, ProviderScope, SharedPreferences init
│   ├── router.dart                         # GoRouter: 26 routes, auth + onboarding guards
│   ├── models/                             # Data models (Freezed + JSON)
│   ├── core/                               # Infrastructure (API, auth, storage)
│   ├── data/                               # Repository layer
│   ├── providers/                          # Riverpod state management
│   ├── screens/                            # UI screens
│   ├── components/                         # Reusable widgets
│   └── theme/                              # Design tokens (colors, typography, spacing)
│
├── server/                                 # Node.js backend
│   ├── api/                                # Vercel serverless functions
│   │   ├── auth/                           # Authentication endpoints
│   │   ├── users/                          # User data endpoints
│   │   ├── hobbies/                        # Content endpoints
│   │   └── categories/                     # Category endpoints
│   ├── lib/                                # Shared utilities
│   ├── prisma/                             # Database schema + migrations
│   ├── package.json                        # Dependencies
│   └── vercel.json                         # Route configuration
│
├── .planning/                              # GSD planning documents
├── pubspec.yaml                            # Flutter dependencies
└── CLAUDE.md                               # Project context (this file's contents)
```

## Directory Purposes

**lib/models/:**
- Purpose: Define all data structures (Freezed + JSON serialization)
- Contains: `hobby.dart`, `auth.dart`, `features.dart`, `social.dart`, `activity_log.dart`, plus `.freezed.dart` and `.g.dart` generated files
- Key files: `seed_data.dart` (9 categories + all hobbies static), `feature_seed_data.dart` (journals, buddies, challenges, etc.)
- Generated: Yes (via `build_runner`)
- Pattern: Each model uses `@freezed` annotation, `copyWith()`, `fromJson()/toJson()`

**lib/core/:**
- Purpose: Cross-cutting infrastructure
- Contains:
  - `api/api_client.dart`: Dio singleton
  - `api/api_constants.dart`: All endpoint paths (baseUrl + path constants)
  - `auth/auth_interceptor.dart`: JWT attachment + 401 refresh
  - `auth/token_storage.dart`: flutter_secure_storage wrapper
  - `storage/local_storage.dart`: Hive box initialization
  - `storage/cache_manager.dart`: TTL-based Hive caching

**lib/data/repositories/:**
- Purpose: Data access abstraction
- Contains:
  - `*_repository.dart`: Abstract interfaces (no impl suffix)
  - `*_repository_api.dart`: API implementations (calls Dio + caching)
  - `*_repository_impl.dart`: Optional local/fallback implementations
- Key repositories:
  - `auth_repository.dart` (register, login, loginWithGoogle, getMe, updateProfile)
  - `hobby_repository.dart` (getHobbies, getHobbyById, getCategories, getRelatedHobbies, searchHobbies)
  - `user_progress_repository.dart` (saveHobby, updateStatus, toggleStep, syncHobbies, getActivityLog)
  - `feature_repository.dart` (getFaqForHobby, getCostBreakdown, etc.)
  - `personal_tools_repository.dart` (journal, notes, scheduler, shopping CRUD)

**lib/providers/:**
- Purpose: Riverpod state definitions
- Contains:
  - `auth_provider.dart`: AuthNotifier (status, user, error, loadingMethod), login/logout/restore methods
  - `hobby_provider.dart`: hobbyListProvider, hobbyByIdProvider, categoriesProvider, filteredHobbiesProvider
  - `user_provider.dart`: onboardingCompleteProvider, userPreferencesProvider, userHobbiesProvider, hobbyCountByStatusProvider
  - `feature_providers.dart`: faqProvider, costBreakdownProvider, journalProvider, scheduleProvider, etc.
  - `repository_providers.dart`: Singleton repository instances (injected into notifiers)
- Pattern: Each provider defined at module level, consumed via `ref.watch()` in screens

**lib/screens/:**
- Structure:
  - `auth/`: login_screen.dart, register_screen.dart
  - `onboarding/`: onboarding_screen.dart (multi-page with animations)
  - `feed/`: discover_feed_screen.dart (vertical TikTok-style feed)
  - `explore/`: explore_screen.dart (2-column category grid)
  - `search/`: search_screen.dart (full-text search)
  - `my_stuff/`: my_stuff_screen.dart (4-tab library: saved/trying/active/done)
  - `profile/`: profile_screen.dart (stats, heatmap, activity)
  - `detail/`: hobby_detail_screen.dart (full hobby view with hero animation)
  - `quickstart/`: quickstart_screen.dart (bottom sheet modal)
  - `settings/`: settings_screen.dart (logout, reset onboarding)
  - `features/`: 16 feature screens (mood_match, seasonal_picks, beginner_faq, personal_notes, budget_alternatives, hobby_combos, cost_calculator, compare_mode, shopping_list, weekly_challenge, hobby_journal, hobby_scheduler, buddy_mode, community_stories, local_discovery, year_in_review)
- Pattern: All screens are ConsumerStatefulWidget or ConsumerWidget, watch providers via `ref.watch()`

**lib/components/:**
- Purpose: Reusable widgets (composable building blocks)
- Contains:
  - `hobby_card.dart`: Main feed card (parallax, hero animation, save action)
  - `category_tile.dart`: Grid tile + CategoryChipBar (filter bar)
  - `spec_badge.dart`: Cost/time/difficulty pills
  - `roadmap_step_tile.dart`: Checklist step with spring animation
  - `try_today_button.dart`: Breathing-glow CTA button
  - `shared_widgets.dart`: SectionHeader, OverlineLabel, HobbyMiniCard
  - `shimmer_skeleton.dart`: Loading placeholders
  - `glass_container.dart`: Frosted glass surface with noise grain
  - `curved_nav/`: Local fork of curved_labeled_navigation_bar (5 files)
- Pattern: Stateless/stateful widgets, support Consumer mixin for provider access

**lib/theme/:**
- Purpose: Centralized design tokens (single source of truth for styling)
- Contains:
  - `app_colors.dart`: 37+ color constants (neutrals, accents, category colors)
  - `app_typography.dart`: 15+ text styles (serif/sans/mono scales)
  - `app_theme.dart`: Material 3 ThemeData.dark() definition
  - `app_icons.dart`: Icon constants (MDI, phosphor)
  - `spacing.dart`: 4px grid scale, radii, shadows, gradients
  - `motion.dart`: Animation durations and curves
  - `scroll_physics.dart`: Custom rubber-band overscroll
- Pattern: Never use raw hex in screens — reference tokens by name (e.g., `AppColors.coral`, `Spacing.lg`)

**server/api/:**
- Consolidated handlers (each handles one resource):
  - `auth/[action].ts`: Single handler, 4 switch cases (register, login, refresh, google)
  - `users/[path].ts`: Single handler, 12+ switch cases (me, preferences, hobbies, hobbies-sync, hobbies-detail, activity, journal, journal-detail, notes, schedule, schedule-detail, shopping)
  - `hobbies/index.ts`: List hobbies (GET)
  - `hobbies/[id]/index.ts`: Get single hobby
  - `hobbies/[id]/[feature].ts`: Get per-hobby features (faq, cost, budget)
  - `hobbies/mood.ts`: Filter by mood tags
  - `hobbies/seasonal.ts`: Filter by season
  - `hobbies/combos.ts`: Hobby pairs
  - `hobbies/search.ts`: Full-text search
  - `categories/index.ts`: List categories
- Pattern: Route → handler → switch on query/path param → specific business logic → Prisma query → mappers → JSON response

**server/lib/:**
- Purpose: Shared utilities for all handlers
- Contains:
  - `auth.ts`: JWT utilities (generateTokenPair, verifyAccessToken, hashPassword, comparePassword, requireAuth)
  - `db.ts`: Prisma client singleton (`prisma` export)
  - `middleware.ts`: CORS, errorResponse, methodNotAllowed helpers
  - `mappers.ts`: Response transformers (strips sensitive fields, serializes Prisma objects)

**server/prisma/:**
- Purpose: Database schema and migrations
- Contains:
  - `schema.prisma`: 12 models (10 content + User + UserPreference)
  - `migrations/`: Timestamped migration files (applied automatically on deploy)
  - `.env`: (not committed) DATABASE_URL, JWT_SECRET, JWT_REFRESH_SECRET, GOOGLE_CLIENT_IDS

## Key File Locations

**Entry Points:**
- `lib/main.dart`: App bootstrap
- `lib/router.dart`: Navigation definition
- `server/api/auth/[action].ts`: Auth API entry
- `server/api/users/[path].ts`: User data API entry

**Configuration:**
- `pubspec.yaml`: Flutter dependencies
- `server/package.json`: Node.js dependencies
- `server/vercel.json`: Route → function mapping
- `lib/core/api/api_constants.dart`: All API endpoints
- `server/prisma/schema.prisma`: Database schema

**Core Logic:**
- `lib/providers/auth_provider.dart`: Auth state machine
- `lib/providers/user_provider.dart`: User progress persistence
- `lib/data/repositories/user_progress_repository_api.dart`: User hobby sync
- `server/lib/auth.ts`: JWT + password utilities
- `server/api/users/[path].ts`: User data mutations

**Testing:**
- `lib/test/`: Unit tests for notifiers (exists but not fully populated)
- `server/`: No tests currently

## Naming Conventions

**Files:**
- Screen files: `snake_case_screen.dart` (e.g., `hobby_detail_screen.dart`)
- Repository files: `snake_case_repository.dart` for interfaces, `snake_case_repository_api.dart` for API impls
- Provider files: `snake_case_provider.dart`
- Component files: `snake_case.dart` (e.g., `hobby_card.dart`)
- Model files: `snake_case.dart`, plus `snake_case.freezed.dart` and `snake_case.g.dart` for generated code
- Server handlers: `[path].ts` where brackets denote dynamic segments (Vercel routing convention)

**Directories:**
- Feature directories in `screens/` match route names (e.g., `my_stuff/` for `/my` route, `hobby_journal/` for journal feature)
- Repository interfaces live in `data/repositories/`, implementations inline with `_api` or `_impl` suffix

**Classes:**
- ScreenClasses: `PascalCaseScreen` extends ConsumerStatefulWidget/ConsumerWidget (e.g., `HobbyDetailScreen`)
- Notifier classes: `PascalCaseNotifier` extends StateNotifier<T> (e.g., `AuthNotifier`)
- Repository classes: `PascalCaseRepository` for interface, `PascalCaseRepositoryApi` for API impl
- Component classes: `PascalCase` extends Widget (e.g., `HobbyCard`)

**Riverpod Providers:**
- StateNotifier providers: `lowerCaseProvider` with notifier exposed as `.notifier`
- FutureProvider: `lowerCaseProvider` with `.future` accessor
- Provider.family: `lowerCaseProvider` with argument in watch: `ref.watch(lowerCaseProvider(id))`
- Derived providers: `derived_logic_provider` (e.g., `isHobbySavedProvider`)

**API Endpoints:**
- Paths: lowercase with hyphens for multi-word (e.g., `/api/hobby-combos`, `/api/budget-alternatives`)
- Query params: kebab-case or camelCase depending on convention
- Request bodies: `{ action, email, password, displayName, ...}` — camelCase

## Where to Add New Code

**New Feature (e.g., challenges, achievements):**
1. **Data model:** Add to `lib/models/features.dart` (or new model file if large)
2. **Server schema:** Add tables to `server/prisma/schema.prisma`, run `prisma migrate dev --name feature_name`
3. **Repository:** Create `lib/data/repositories/feature_repository.dart` (interface) + `_api.dart` (impl)
4. **Providers:** Create `lib/providers/feature_provider.dart` with StateNotifier + FutureProviders
5. **Screens:** Create `lib/screens/features/feature_screen.dart`
6. **Routes:** Add to `lib/router.dart` routes array
7. **Server endpoint:** Add to existing `server/api/users/[path].ts` handler (add new switch case)

**New Screen within existing feature:**
1. Create `lib/screens/existing_feature/new_screen_screen.dart` (ConsumerStatefulWidget)
2. Add route to `lib/router.dart` (GoRoute with path, parent navigator key, transition)
3. Watch existing providers (no new repository needed if using existing data)

**New Component:**
1. Create `lib/components/component_name.dart`
2. Extend StatelessWidget or StatefulWidget (or ConsumerWidget for provider access)
3. Use theme tokens: `AppColors.*`, `AppTypography.*`, `Spacing.*`, `Motion.*`
4. Export from component files if part of named group (e.g., curved_nav exports 5 files)

**New Utility:**
- **Shared helpers:** `lib/core/utils/` (create if needed) or `lib/utils/`
- **Server utilities:** `server/lib/` (alongside auth.ts, mappers.ts, etc.)

## Special Directories

**lib/models/ (Generated code):**
- Purpose: Data structures with serde (JSON serialization)
- Contains: `.dart` source files + `.freezed.dart` + `.g.dart` generated files
- Generated: Yes (via `build_runner`)
- Command: `dart run build_runner build --delete-conflicting-outputs`
- Committed: Yes (both source and generated)

**server/prisma/migrations/:**
- Purpose: Schema version history
- Contains: Timestamped `.sql` migration files
- Generated: Yes (via `prisma migrate dev --name description`)
- Committed: Yes (replay migrations on deploy)
- Do not edit manually

**lib/components/curved_nav/:**
- Purpose: Local fork of curved_labeled_navigation_bar
- Why fork: Custom `buttonElevation` parameter not in published package
- Files: `curved_navigation_bar.dart` (main), `curved_navigation_bar_item.dart`, `nav_bar_item_widget.dart`, `nav_custom_painter.dart`, `nav_custom_clipper.dart`
- Imported: Only in `lib/screens/main_shell.dart`
- Do not update from pub.dev (will lose customization)

**lib/theme/:**
- Purpose: Design tokens (single source of truth)
- Critical: Update `app_colors.dart` if changing palette → auto-propagates everywhere
- Hardcoded values:
  - Shadows in `spacing.dart` use `#000000` (black)
  - Gradients in `spacing.dart` use `#0A0A0F` (cream)
  - Onboarding blob colors in `screens/onboarding/onboarding_screen.dart` (must be manually updated if palette changes)
- Pattern: Never use `Colors.white` in screens unless intentional (e.g., text on image overlays)

---

*Structure analysis: 2026-03-02*
