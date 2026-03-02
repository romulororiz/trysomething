# External Integrations

**Analysis Date:** 2026-03-02

## APIs & External Services

**Google OAuth 2.0:**
- Used for: User authentication and sign-in
- SDK/Client: `google_sign_in` 6.2.2 (Flutter), native Google Sign-In libraries (Android/iOS)
- Auth: 3 OAuth client IDs from Google Cloud Console
  - Web client ID: `973949791990-m09mp4019a2i5dplg5og1h6mvlvmmvsa.apps.googleusercontent.com` (used as serverClientId on Android)
  - Android client ID: Bound to app signing key SHA-1 hash + package name `com.example.trysomething`
  - iOS client ID: GoogleService-Info.plist in `ios/Runner/`
- Flow:
  - **Primary (iOS/Android):** Client requests idToken via serverClientId parameter → server verifies token signature at `https://oauth2.googleapis.com/tokeninfo?id_token={idToken}`
  - **Fallback (Windows/Web):** Client uses accessToken → server verifies via `https://www.googleapis.com/oauth2/v3/userinfo` endpoint
- Implementation: `lib/providers/auth_provider.dart` (two GoogleSignIn instances), `server/api/auth/[action].ts` handleGoogle function

**Google Userinfo API:**
- Used for: Fallback OAuth token validation on Windows/Web
- Endpoint: `https://www.googleapis.com/oauth2/v3/userinfo`
- Auth: Bearer token (Google accessToken from oauth2 token endpoint)
- Invoked by: `server/api/auth/[action].ts` when idToken is unavailable

## Data Storage

**Databases:**

**Neon Postgres (Production):**
- Type: Serverless PostgreSQL
- Connection: Via `DATABASE_URL` env var (serverless connection pooling)
- Client: `@prisma/client` 6.4.1 (Prisma ORM)
- Models: 12 Prisma models (10 content + User + UserPreference)
  - Content: Hobby, Category, KitItem, RoadmapStep, FaqItem, CostBreakdown, BudgetAlternative, HobbyCombo, SeasonalPick, MoodTag
  - Auth: User, UserPreference
  - User Progress: UserHobby, UserCompletedStep, UserActivityLog
  - Personal Tools: JournalEntry, PersonalNote, ScheduleEvent, ShoppingCheck
- SSL: Required (`sslmode=require` in connection string)

**Hive Local Cache (Flutter Client):**
- Type: Embedded key-value store (JSON strings stored locally)
- Purpose: Cache hobby content with TTL (default 1 hour)
- Boxes:
  - `hobbies` — Cached hobby JSON strings
  - `categories` — Cached category JSON strings
  - `cache_meta` — Timestamps for TTL tracking
- Implementation: `lib/core/storage/cache_manager.dart` (managed via `CacheManager.get()`, `CacheManager.put()`)
- Fallback behavior: `CacheManager.getStale()` returns expired cache on API errors (offline-first)

**SharedPreferences (Flutter Client):**
- Type: Platform-specific key-value store (Keychain on iOS, SharedPreferences on Android)
- Purpose: User state persistence across app launches
- Keys stored:
  - `onboarding_complete` — Boolean flag
  - `user_preferences` — JSON UserPreferences object (hoursPerWeek, budgetLevel, preferSocial, vibes[])
  - `user_hobbies` — JSON array of UserHobby objects with status (saved/trying/active/done) and step completion tracking
- Implementation: `lib/providers/user_provider.dart` (StateNotifierProvider pattern with auto-save)

**File Storage:**
- Type: Local filesystem only
- Images: Cached by `cached_network_image` package to device storage
- No cloud file storage integration

## Caching

**Strategy:**
- **API responses:** Hive JSON cache with 1-hour TTL for hobby content
- **Images:** In-memory + disk cache via `cached_network_image`
- **User state:** SharedPreferences (persistent across launches)
- **Feature data:** In-memory only (no server sync yet, Batch 5+ will add)

## Authentication & Identity

**Auth Provider:**
- Type: Custom JWT + Google OAuth 2.0
- Implementation: Email/password or Google sign-in
- Token storage: `flutter_secure_storage` (encrypted with device secure enclave)
- Tokens:
  - Access token: JWT, 15-minute expiry, signed with `JWT_SECRET`
  - Refresh token: JWT, 30-day expiry, signed with `JWT_REFRESH_SECRET` (separate key for rotation)
- Flow:
  1. User logs in or signs in with Google
  2. Server returns {accessToken, refreshToken}
  3. Client stores both in `flutter_secure_storage`
  4. AuthInterceptor attaches access token on every request
  5. On 401: Automatically refresh using refresh token
  6. On refresh failure: Clear tokens and redirect to login

**Key Files:**
- `lib/core/auth/token_storage.dart` — flutter_secure_storage wrapper
- `lib/core/auth/auth_interceptor.dart` — Dio interceptor with JWT attachment + auto-refresh
- `lib/providers/auth_provider.dart` — AuthNotifier (login/register/google/logout/restore)
- `server/lib/auth.ts` — JWT generation/verification, password hashing (bcryptjs with 12 salt rounds)
- `server/api/auth/[action].ts` — Auth endpoints (register, login, refresh, google)

## Monitoring & Observability

**Error Tracking:**
- Type: None currently configured
- Logging: `debugPrint()` for client-side debug output (Google sign-in errors), `console.error()` on server

**Logs:**
- Client: Standard Flutter logging via `debugPrint()` (disabled in release builds)
- Server: Console output from Vercel serverless functions (visible in Vercel dashboard)
- No structured logging aggregation

## CI/CD & Deployment

**Hosting:**

**Backend API:**
- Platform: Vercel serverless functions (Node.js 20.x runtime)
- URL: `https://server-psi-seven-49.vercel.app/api`
- Routing: 4 handler files with 15 route rules (vercel.json)
  - `api/auth/[action].ts` — 4 auth endpoints
  - `api/users/[path].ts` — User endpoints (me, preferences, hobbies, progress, activity, journal, notes, schedule, shopping)
  - `api/hobbies/` — Content endpoints (list, detail, search, combos, seasonal, mood, per-hobby features)
  - `api/categories/index.ts` — Category listing
- Function limit: Vercel Hobby plan allows max 12 functions, currently using 11 (1 slot remaining)

**Web Landing:**
- Platform: Vercel (Next.js 16, serverless functions)
- URL: Deployed from `web/` directory

**Mobile:**
- Deployment: Apple App Store (iOS), Google Play Store (Android)
- Build system: Flutter (generates APK/IPA)

**CI Pipeline:**
- None configured yet (manual deployment with `cd server && npx vercel --prod`)

## Environment Configuration

**Required Env Vars:**

**Server (.env file):**
```
DATABASE_URL=postgresql://user:password@host.neon.tech/trysomething?sslmode=require
JWT_SECRET=<32-char random base64>
JWT_REFRESH_SECRET=<32-char random base64>
GOOGLE_CLIENT_IDS=web_client_id,android_client_id,ios_client_id
NODE_ENV=production
```

**Flutter Client (optional, compile-time):**
```bash
flutter run --dart-define=GOOGLE_SERVER_CLIENT_ID=973949791990-m09mp4019a2i5dplg5og1h6mvlvmmvsa.apps.googleusercontent.com
```

**Secrets Location:**
- Server: Vercel project environment variables (encrypted at rest)
- Client: No secrets in code (OAuth client IDs are public, tokens stored in `flutter_secure_storage`)

## Webhooks & Callbacks

**Incoming Webhooks:**
- None configured

**Outgoing Webhooks:**
- None configured

## Network Configuration

**CORS:**
- Enabled on server via `cors` middleware in Express handlers
- Allows requests from web clients and Flutter web builds

**SSL/TLS:**
- All connections required HTTPS
- API: Self-signed or Vercel-managed certificate
- Database: `sslmode=require` in Postgres connection string

## API Rate Limiting

- None currently enforced
- Vercel Hobby plan has execution time limit per function (10 seconds) and memory limit (512 MB)

## Data Sync

**User Progress Sync (Batch 4 — in progress):**
- Client: Stores hobby saves/tries/complete + step completion in SharedPreferences
- Server: `/users/hobbies` endpoint will synchronize with database
- Strategy: Optimistic updates with rollback on error
- Offline: Shared preferences serve as local cache until sync succeeds

**Feature Data Sync (Batch 5+ — planned):**
- Journal entries, notes, schedule, shopping lists will sync to server
- Endpoints consolidated in `server/api/users/[path].ts` (no new serverless functions)

---

*Integration audit: 2026-03-02*
