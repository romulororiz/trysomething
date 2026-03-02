# Architecture

**Analysis Date:** 2026-03-02

## Pattern Overview

**Overall:** Multi-tier layered architecture with clean separation between UI (Flutter), state management (Riverpod), data access (repositories), and API integration (Dio).

**Key Characteristics:**
- Client-server architecture: Flutter frontend + Node.js/Express backend on Vercel
- Repository pattern with abstract interfaces and API implementations
- Riverpod for reactive state management with StateNotifier for mutable state
- API-first with Hive caching fallback and SeedData emergency fallback
- Optimistic updates with rollback on API failure
- JWT authentication with auto-refresh via Dio interceptor

## Layers

**Presentation (UI):**
- Purpose: Render screens with Flutter widgets, handle user interactions
- Location: `lib/screens/` (26 screens across 11 directories)
- Contains: ConsumerStatefulWidget/ConsumerWidget, UI logic, form handling
- Depends on: Riverpod providers, routing (GoRouter)
- Used by: GoRouter navigation system

**State Management:**
- Purpose: Manage application state reactively (auth, hobbies, preferences, features)
- Location: `lib/providers/`
- Contains: Riverpod StateNotifierProvider, FutureProvider, Provider definitions
- Depends on: Repositories, SharedPreferences, Riverpod
- Used by: Screens (via `ref.watch()`)
- Key files: `auth_provider.dart`, `hobby_provider.dart`, `user_provider.dart`, `feature_providers.dart`

**Data Access (Repositories):**
- Purpose: Abstract data sources (API, cache, seed data), implement persistence patterns
- Location: `lib/data/repositories/`
- Contains: Abstract interfaces (no `_impl` suffix), API implementations (`_api.dart`), actual logic (`_impl.dart`)
- Depends on: Dio (HTTP), Hive (cache), Prisma models
- Used by: Riverpod providers
- Pattern: Interface → API impl → optional local impl (fallback)

**Core Infrastructure:**
- Purpose: Cross-cutting concerns (HTTP, auth, storage, caching)
- Location: `lib/core/`
- Contains: `api/` (Dio client, endpoints), `auth/` (JWT, token storage), `storage/` (Hive, SharedPreferences)
- Depends on: External packages (Dio, flutter_secure_storage, google_sign_in)
- Used by: Repositories

**Components (Reusable Widgets):**
- Purpose: Shared UI components (cards, buttons, chips, animations)
- Location: `lib/components/`
- Contains: 10+ stateless/stateful widgets, custom painters, curved nav bar (local fork)
- Depends on: Theme system, Riverpod (some components)
- Used by: Screens

**Theme System:**
- Purpose: Centralized styling (colors, typography, spacing, motion)
- Location: `lib/theme/`
- Contains: `app_colors.dart` (37+ tokens), `app_typography.dart` (fonts), `spacing.dart` (4px grid), `motion.dart` (animation timings)
- Depends on: Google Fonts package
- Used by: All screens and components

**Backend (Node.js/Express):**
- Purpose: API endpoints, database access, business logic
- Location: `server/api/`, `server/lib/`
- Contains: Serverless Vercel functions (consolidated handlers), Prisma models, auth/middleware utilities
- Deployed to: Vercel (serverless)
- Database: Neon Postgres via Prisma ORM

## Data Flow

**Authentication Flow:**
1. User submits email/password or taps Google Sign-In
2. `LoginScreen` calls `authProvider.notifier.login()` or `loginWithGoogle()`
3. `AuthNotifier` delegates to `AuthRepositoryApi`
4. `AuthRepositoryApi` calls `/api/auth/login` or `/api/auth/google` endpoint
5. Server validates credentials, returns JWT pair + User object
6. `TokenStorage.saveTokens()` persists tokens to flutter_secure_storage
7. `AuthState` updated to `authenticated`
8. Router redirect triggers → onboarding or feed
9. `AuthInterceptor` auto-attaches Bearer token to all subsequent API calls

**Content Data Flow (Hobbies):**
1. `hobbyListProvider` watches `hobbyRepositoryProvider.getHobbies()`
2. `HobbyRepositoryApi` calls `ApiClient` → `/api/hobbies` endpoint
3. Server returns paginated hobby list from Prisma
4. `CacheManager` (Hive) stores response with TTL (24 hours)
5. On next request: Hive returns cached data if valid, API if expired
6. SeedData (static `lib/models/seed_data.dart`) is fallback if cache empty + API fails
7. Screens watch `filteredHobbiesProvider` which filters by `selectedCategoryProvider`

**User Progress Data Flow:**
1. User taps "Save" on hobby card
2. `UserHobbiesNotifier.saveHobby(hobbyId)` creates optimistic update → local state + SharedPrefs
3. Fire-and-forget API call: `userProgressRepositoryProvider.saveHobby(hobbyId)`
4. Server creates `UserHobby` record in Postgres
5. If API fails, `_apiCall()` rollback restores previous state from snapshot
6. On app startup: `syncFromServer()` reconciles local vs server (server is source of truth)

**Personal Tools Data Flow (Journal, Notes, etc.):**
1. `journalProvider` (StateNotifier) holds in-memory journal entries
2. `JournalNotifier.loadFromServer()` called on auth success, fetches from `/users/journal`
3. User adds entry → optimistic update → state + API call
4. Server validates, persists to Postgres `JournalEntry` table
5. On success: state updated with server response (real ID)
6. On failure: state rolled back from snapshot

**State Synchronization:**
- **Pessimistic:** Auth (wait for server, show loading spinner)
- **Optimistic:** User progress + personal tools (update UI immediately, rollback if API fails)
- **Polling:** None (event-driven via user actions)
- **Cache invalidation:** TTL-based (24h for hobbies, per-request for user data)

## Key Abstractions

**AuthRepository:**
- Purpose: Abstract authentication source
- Examples: `lib/data/repositories/auth_repository.dart` (interface), `auth_repository_api.dart` (impl)
- Pattern: Interface defines contract, API impl calls server, no fallback layer

**HobbyRepository:**
- Purpose: Abstract hobby content source with layered fallback
- Examples: `lib/data/repositories/hobby_repository.dart` (interface), `hobby_repository_api.dart` (API), `hobby_repository_impl.dart` (no-op impl)
- Pattern: `hobbyRepositoryProvider` → `HobbyRepositoryApi` → API → Hive cache → SeedData

**UserProgressRepository:**
- Purpose: Abstract user hobby progress operations
- Examples: `lib/data/repositories/user_progress_repository.dart` (interface), `user_progress_repository_api.dart` (impl)
- Methods: saveHobby, updateStatus, toggleStep, syncHobbies, getActivityLog
- Pattern: All mutations are optimistic, server is source of truth on sync

**PersonalToolsRepository:**
- Purpose: Abstract journal, notes, scheduler, shopping list CRUD
- Examples: `lib/data/repositories/personal_tools_repository.dart` (interface), `personal_tools_repository_api.dart` (impl)
- Pattern: Similar to user progress (optimistic with rollback)

**StateNotifier Patterns:**
- `AuthNotifier`: Holds `AuthState` with status + user + error + loadingMethod
- `UserHobbiesNotifier`: Holds `Map<String, UserHobby>` persisted to SharedPrefs
- `JournalNotifier`: Holds `List<JournalEntry>` (in-memory, synced on demand)

## Entry Points

**Flutter Client:**
- Location: `lib/main.dart`
- Triggers: App startup via `flutter run`
- Responsibilities: Initialize SharedPreferences, init Hive, create ProviderScope, show splash overlay, restore auth session

**GoRouter:**
- Location: `lib/router.dart`
- Triggers: `routerProvider` watched by `MaterialApp.router`
- Responsibilities: Define 26 routes, manage 4-tab bottom nav (ShellRoute), redirect on auth/onboarding, provide transition animations

**AuthNotifier.tryRestoreSession():**
- Location: `lib/providers/auth_provider.dart`
- Triggers: Called in `main.dart` initState via `Future.microtask()`
- Responsibilities: Check for stored JWT, verify with `/users/me` endpoint, restore `AuthState`

**Server Entry Points (Vercel Functions):**
- `/api/auth/[action].ts`: Handles register, login, refresh, google (consolidated handler)
- `/api/users/[path].ts`: Handles user endpoints (me, preferences, hobbies, activity, journal, notes, schedule, shopping)
- `/api/hobbies/index.ts`: List all hobbies (GET)
- `/api/hobbies/[id]/index.ts`: Get hobby by ID
- `/api/hobbies/[id]/[feature].ts`: Get per-hobby features (faq, cost, budget, combos)
- `/api/categories/index.ts`: List categories
- Other endpoints: `/api/hobbies/search.ts`, `/api/hobbies/mood.ts`, `/api/hobbies/seasonal.ts`, `/api/hobbies/combos.ts`

## Error Handling

**Strategy:** Three-tier fallback

**Patterns:**
- **API Errors:** Caught in repositories, wrapped in `DioException`, extracted to user-readable strings
- **Auth Errors:** `AuthNotifier._extractError()` maps HTTP status to message ("Invalid email or password", "Email already registered")
- **Network Errors:** Timeout 10s (connect), 15s (receive) via Dio BaseOptions
- **Optimistic Update Failure:** Catch in `_apiCall()`, rollback from snapshot
- **Cache Failure:** Try Hive → fall back to SeedData
- **Unauthenticated (401):** `AuthInterceptor` calls `/auth/refresh` with refresh token, retries request

**Server Error Responses:**
- All errors return JSON: `{ error: "message" }` via `errorResponse(res, statusCode, msg)`
- 400: Validation errors
- 401: Unauthorized (missing/invalid token)
- 409: Conflict (email already registered)
- 404: Not found (hobby, user, etc.)
- 500: Server errors (logged to console)

## Cross-Cutting Concerns

**Logging:**
- Flutter: `debugPrint()` for auth flow, API errors, sync operations
- Server: `console.error()` for unhandled exceptions
- No persistent logging (would require Sentry/external service)

**Validation:**
- Client: Minimal (email format, password length checked in `AuthNotifier`)
- Server: Strict (all register/login endpoints validate payload, normalize email lowercase+trim)

**Authentication:**
- JWT pair: Access token 15min, refresh token 30 days
- `TokenStorage` (flutter_secure_storage): Persists to encrypted platform storage
- `AuthInterceptor` (Dio): Attaches Bearer token, catches 401, refreshes automatically
- `requireAuth()` (server): Extracts token from `Authorization: Bearer {token}` header

**Authorization:**
- All user endpoints require `Authorization` header (checked via `requireAuth()`)
- No role-based access control (single user type)

**Rate Limiting:**
- None implemented (Vercel default limits apply)

**CORS:**
- Server: `handleCors()` middleware sets headers, allows all origins for dev
- Client: Dio respects CORS automatically

---

*Architecture analysis: 2026-03-02*
