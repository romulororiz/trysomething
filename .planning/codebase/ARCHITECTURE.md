# Architecture

**Analysis Date:** 2026-03-21

## Pattern Overview

**Overall:** Clean Architecture with layered separation between Flutter UI, Riverpod state management, repository pattern, and Node.js/Vercel serverless backend. Session-based immersive experience (4-phase state machine) for hobby practice.

**Key Characteristics:**
- **Repository Pattern** — Data sources abstracted via repositories; implementations can swap between API, Hive cache, and seed data
- **Riverpod State Management** — Functional reactive programming; providers auto-dispose when no widgets listen, composable for complex state
- **Layered Backend** — Vercel serverless functions → business logic (AI generation, auth, mappers) → Prisma ORM → Neon PostgreSQL
- **Session State Machine** — Four-phase immersive session (prepare → timer → reflect → complete) managed via SessionNotifier with DateTime-based timer survival
- **JWT Auth Flow** — 15-min access token + 30-day refresh token, plus OAuth (Google/Apple) + RevenueCat subscriptions
- **Offline-First Caching** — API responses cached in Hive; stale cache returned on network error; seed data as emergency fallback

## Layers

**Presentation Layer (Flutter UI):**
- Purpose: Render screens, handle user interaction, display state reactively
- Location: `lib/screens/`, `lib/components/`
- Contains: ConsumerStatefulWidgets, ConsumerWidgets, custom painters (particle timer, category shapes, glows), glass card system
- Depends on: Riverpod providers, GoRouter, theme tokens
- Used by: App routing, main shell navigation

**State Management Layer (Riverpod):**
- Purpose: Cache state, compute derived values, react to data changes
- Location: `lib/providers/`
- Contains: StateNotifiers (auth, session, hobbies, journal), FutureProviders (async data), Computed providers (derived state like isProProvider)
- Depends on: Repositories, external services (analytics, subscriptions), models
- Used by: All screens and components via `ref.watch()`
- Key pattern: Providers auto-dispose when no listeners; cascade updates on auth success

**Business Logic Layer:**
- Purpose: Services, algorithms, orchestration (no UI, no external I/O on client side)
- Location: `lib/core/` (client) + `server/lib/` (backend)
- Client: `lib/core/auth/` (JWT handling, token refresh), `lib/core/notifications/` (FCM + local scheduling), `lib/core/subscription/` (RevenueCat), `lib/core/analytics/`, `lib/core/media/`, `lib/core/error/` (Sentry)
- Server: `lib/ai_generator.ts` (Claude Haiku prompts), `lib/auth.ts` (bcrypt, JWT crypto), `lib/mappers.ts` (response transformation), `lib/content_guard.ts` (input validation, blocklist), `lib/gamification.ts`
- Depends on: Models, external SDKs, Prisma client
- Used by: Providers, repositories, API handlers

**Data Access Layer (Repositories):**
- Purpose: Unified interface to data sources with pluggable backends
- Location: `lib/data/repositories/`
- Contains: Repository interfaces (abstract), API implementations (Dio calls), optional Hive fallbacks
- Depends on: ApiClient (Dio), LocalStorage (Hive), Prisma models (server)
- Used by: Riverpod providers via repository_providers.dart DI
- Pattern: Abstract → API impl → optional cache impl (for read-heavy features)

**Data Models:**
- Purpose: Immutable, serializable data structures
- Location: `lib/models/`, `server/prisma/schema.prisma`
- Flutter: Freezed-generated with copyWith, fromJson/toJson, equality
- Server: Prisma models (25 tables across 9 domains)
- Domains: Content (Hobby, Category, KitItem, RoadmapStep, FaqItem), Auth (User, UserPreference), Progress (UserHobby, UserCompletedStep), Personal Tools (JournalEntry, PersonalNote, ScheduleEvent, ShoppingCheck), Social (CommunityStory, StoryReaction, BuddyPair), Gamification (UserChallenge, UserAchievement), AI (GenerationLog)

## Data Flow

**User Authentication & Session Restore:**

1. User enters `/login` or `/register` screen
2. `LoginScreen` calls `ref.read(authProvider.notifier).login(email, password)`
3. `AuthNotifier` delegates to `AuthRepositoryApi.login()`
4. API calls `POST /api/auth/login` with credentials
5. Server validates, hashes password (bcrypt 12 rounds), generates JWT pair
6. Tokens returned: `{ accessToken, refreshToken, user }`
7. `TokenStorage.saveTokens()` persists both tokens to secure Hive
8. `AuthState` updates to `authenticated` with user object
9. Router redirects to onboarding or home based on `onboardingCompleteProvider`
10. On app restart: `tryRestoreSession()` reads stored token, calls `GET /api/users/me` to verify
11. If token expired: `AuthInterceptor` catches 401, calls `/api/auth/refresh`, retries original request

**Hobby Discovery to Session Completion:**

1. User lands on `/discover` feed or `/home` (active hobby dashboard)
2. Taps hobby card → navigates to `hobby_detail_screen.dart` with hobbyId
3. Detail screen calls `hobbyByIdProvider(hobbyId)` FutureProvider
4. If not cached: calls `HobbyRepositoryApi.getHobbyById()` → `GET /api/hobbies/{id}`
5. Server returns full hobby with category, tags, roadmap steps, kit items, FAQ, cost breakdown
6. Hive cache stores response (24h TTL); if API fails, returns cached data
7. User reviews steps, taps "Start" on a step → `SessionScreen` launched
8. `SessionNotifier.startSession()` initializes with step metadata, phase=prepare
9. **Prepare Phase:** User selects duration (15 min default), reviews instructions, taps "Start session"
   - Calls `sessionProvider.notifier.beginTimer()` → phase transitions to timer
10. **Timer Phase:** DateTime-based countdown starts
    - `WakelockPlus.enable()` keeps screen on
    - `_tick()` runs every 1 second, calculates elapsed time from start DateTime
    - `particle_timer_painter.dart` renders 250 particles converging to category-specific shape
    - Haptic feedback fires at 50% and 1-minute remaining
    - User can pause/resume or abort (no completion recorded)
11. **Reflect Phase:** Timer completes, phase=reflect
    - User selects reflection (loved it / okay / struggled)
    - Types journal entry (text)
    - Optional: uploads photo (Pro feature via `photo_proof_variant`)
12. **Complete Phase:** Reflects saved, phase=complete
    - Server records `UserCompletedStep(userId, hobbyId, stepId)` with timestamp
    - Server updates `UserHobby.lastActivityAt` and streak
    - Home screen reactive update shows progress
    - Analytics tracks 'session_complete' event
    - Display celebration + next step preview
13. When session screen pops: `SessionNotifier` auto-disposes (cleanup)

**AI Coach Interaction:**

1. User taps "Coach" from home screen → `hobby_coach_screen.dart`
2. Coach mode determined: START (hobby not tried) / MOMENTUM (active) / RESCUE (abandoned)
3. User types message
4. First message triggers coach system prompt build via `buildCoachSystemPrompt()`:
   - Hobby context: title, category, difficulty, kit list, first 3 roadmap steps
   - User state: active/saved/trying status, days since started, last activity
   - Recent entries: last 5 journal entries (max 100 chars each)
   - Conversation history: last 15 messages from this session
5. Message sent → `POST /api/generate/coach` with full history
6. Server calls Claude Haiku (3 messages per turn limit) with structured system prompt
7. Response streamed back, appended to local conversation history
8. History cached locally; full conversation persisted in provider until screen pops
9. Rate limit: Free tier = 3 msg/month; Pro = unlimited

**State Synchronization on App Startup:**

1. `_TrySomethingAppState.initState()` fires on app load
2. Calls `tryRestoreSession()` → checks for stored tokens
3. If found: verifies with `/api/users/me` → updates `authProvider` to authenticated
4. Cascade of sync calls in sequence:
   - `proStatusProvider.refresh()` → checks RevenueCat subscription
   - `userHobbiesProvider.syncFromServer()` → `GET /api/users/hobbies-sync` → reads all UserHobby records
   - `journalProvider.loadFromServer()` → `GET /api/users/journal` → loads recent entries
   - `scheduleProvider.loadFromServer()` → loads weekly schedule
   - `storiesProvider.loadFromServer()` → loads community stories
   - `buddyProvider.loadFromServer()` → loads buddy pairs
   - `challengeProvider.loadFromServer()` → loads active challenges
5. Track retention events (day_3_return, day_7_return) based on first_open_date
6. Track abandoned hobbies (14+ days inactive) → analytics.trackEvent('hobby_abandoned')
7. Reschedule notifications based on hobby state (via `NotificationScheduler`)
8. FCM token synced to server (mobile only)

## Key Abstractions

**SessionNotifier:**
- Purpose: Encapsulates complete session lifecycle without coupling to UI
- Location: `lib/providers/session_provider.dart`
- Pattern: StateNotifier<SessionState?> with internal Timer, DateTime-based elapsed time calculation
- Key methods: `startSession()`, `beginTimer()`, `pauseTimer()`, `resumeTimer()`, `completeReflection()`
- Manages: Wakelock, haptic feedback timing, pause/resume duration tracking

**Repository Pattern:**
- Purpose: Abstract data access, enable offline caching
- Location: `lib/data/repositories/`
- Pattern: Abstract interface → API implementation → optional Hive fallback
- Example: `hobby_repository.dart` (interface) → `hobby_repository_api.dart` (API + Hive) → provided via DI
- Retry logic: Built into API layer; if network error, returns Hive cache

**AuthInterceptor:**
- Purpose: Transparent JWT token management
- Location: `lib/core/auth/auth_interceptor.dart`
- Pattern: Dio interceptor that (1) adds Authorization header to all requests, (2) catches 401, (3) calls refresh endpoint, (4) retries original request
- No exponential backoff (single retry)

**Mappers (Server Only):**
- Purpose: Transform Prisma models → API response DTOs
- Location: `server/lib/mappers.ts`
- Pattern: Pure functions, one per entity type (mapUserWithPreferences, mapHobbyDetail, etc.)
- Strips sensitive fields (passwordHash, tokens)

**Content Guard:**
- Purpose: Multi-layer safety (input validation, AI constraints, output validation, rate limiting)
- Location: `server/lib/content_guard.ts`
- Layers:
  1. Input: length check, blocklist scan (weapons, drugs, NSFW, extremism)
  2. AI prompt: safe/legal hobbies only, CHF pricing, return `{"error":"invalid"}` for bad queries
  3. Output: schema validation, field type/range checks, re-scan generated text against blocklist
  4. Rate limit: 20 generations/user/24h

## Entry Points

**Flutter App Bootstrap:**
- Location: `lib/main.dart`
- Triggers: `flutter run` (app startup)
- Responsibilities:
  - Initialize Flutter bindings
  - Set up Sentry error reporting
  - Initialize Firebase (mobile only)
  - Initialize local storage (Hive)
  - Initialize notification service + scheduler (mobile)
  - Initialize PostHog analytics (mobile)
  - Initialize RevenueCat subscriptions (mobile)
  - Create ProviderScope with service overrides
  - Call `tryRestoreSession()` in initState microtask
  - Show splash overlay during session restore

**Router:**
- Location: `lib/router.dart` → `routerProvider` Riverpod provider
- Triggers: Route navigation, auth state changes, onboarding completion
- Responsibilities:
  - Define all routes (auth, onboarding, main shell with 3 tabs, screens)
  - Redirect based on auth status + onboarding completion
  - Manage page transitions (fade, slide, custom)
  - Observe analytics events via AnalyticsObserver

**Main Shell (3-Tab Navigation):**
- Location: `lib/screens/main_shell.dart`
- Triggers: After auth + onboarding complete
- Responsibilities:
  - Render floating glass dock (28px radius, blur, 40px margins)
  - 3 icon buttons (home/compass/profile) with active/inactive states
  - Route tab changes via GoRouter
  - Show/hide dock based on shell loading state

**Home Screen:**
- Location: `lib/screens/home/home_screen.dart`
- Triggers: User taps home icon or `ref.read(authProvider).status == authenticated`
- Responsibilities:
  - Fetch active hobbies (trying + active status)
  - Render hobby carousel (PageView with dots)
  - Show "Week N of [Hobby]" overline
  - Display next step glass card with CTA
  - Show coach entry with starter chips
  - Display recent journal entries
  - Handle "Start session" navigation

**Session Screen:**
- Location: `lib/screens/session/session_screen.dart` (coordinator) + phase files
- Triggers: User taps "Start session" on a hobby step
- Responsibilities:
  - Initialize SessionNotifier with step metadata
  - Render correct phase widget based on `SessionState.phase`
  - Route phase transitions (4 phases: prepare, timer, reflect, complete)
  - Auto-dispose session on pop

**API Handler (Backend Example):**
- Location: `server/api/auth/[action].ts` (dynamic routing)
- Triggers: HTTP POST `/api/auth/{action}` (register, login, refresh, google, apple)
- Responsibilities:
  - Parse request body
  - Validate input + normalize (lowercase email, trim)
  - Call Prisma + auth utilities
  - Generate JWT pair (access 15min, refresh 30day)
  - Map response via mapUserWithPreferences()
  - Return JSON or error

**User Data Endpoint (Backend Example):**
- Location: `server/api/users/[path].ts` (consolidated handler)
- Triggers: HTTP GET/POST/PUT to `/api/users/*`
- Responsibilities:
  - Extract path from req.query
  - Route to correct handler (me, hobbies, journal, etc.)
  - Enforce auth via requireAuth() middleware
  - Call Prisma queries
  - Map response or return error

## Error Handling

**Strategy:** Multi-layer error reporting with Sentry telemetry, user-facing messages, and cache fallbacks.

**Patterns:**

- **Sentry Integration:** `lib/core/error/error_reporter.dart` captures unhandled exceptions + stack traces; `ErrorReporterObserver` watches Riverpod for provider failures
- **Provider Errors:** AsyncValue<T> in all FutureProviders; screens check `.when(data: ..., error: ..., loading: ...)`
- **Network Fallback:** ApiClient catches DioException → HobbyRepository falls back to Hive cache → if cache miss, returns empty/null with UI message
- **User Messages:** `AuthNotifier._extractError()` maps HTTP status codes to readable strings:
  - 400: "Invalid email or password"
  - 409: "Email already registered"
  - 401: "Session expired, please log in again"
- **Server Validation:** All endpoints validate input, return structured error:
  ```json
  { "statusCode": 400, "message": "email is required" }
  ```

## Cross-Cutting Concerns

**Logging:**
- Client: `debugPrint('[ComponentName]')` with context prefix (e.g., `[Session] Timer started`)
- Server: `console.error()` with endpoint context (e.g., `POST /api/users/hobbies error:`)
- Production: Sentry + PostHog; console logs for dev only

**Validation:**
- Client: Freezed models enforce type safety; TextFields validate before submission
- Server: Content guard blocklist (4-layer), Prisma constraints (unique, non-null, enums)

**Authentication & Authorization:**
- JWT: 15-min access token (short-lived) + 30-day refresh token (long-lived)
- Storage: Secure Hive (platform-specific encryption)
- Injection: AuthInterceptor adds `Authorization: Bearer {token}` to all requests
- Refresh: 401 triggers `POST /api/auth/refresh` with refresh token
- Verify: Server validates JWT signature + expiry
- Single-user model: No role-based access control

**Analytics:**
- Events tracked: registration, login, hobby_start, hobby_abandoned, session_complete, coach_message, upgrade_view, purchase, day_3_return, day_7_return
- User context: userId set on auth, sessionId generated per app launch
- Metadata: hobby_id, completion_time, reflection_type, coach_mode
- Observer: AnalyticsObserver in router tracks screen views automatically

**Notifications:**
- FCM (Firebase Cloud Messaging): Token synced to server after auth
- Scheduler: `NotificationScheduler` reschedules when hobby state changes
- Triggers: Inactivity-based re-engagement (1 day for trying, 3 days for active)
- Local: `NotificationService` via `flutter_local_notifications`

---

*Architecture analysis: 2026-03-21*
