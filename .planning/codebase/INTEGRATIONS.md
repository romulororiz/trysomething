# External Integrations

**Analysis Date:** 2026-03-21

## APIs & External Services

**AI & Content Generation:**
- Claude API (Anthropic) - Hobby generation, FAQ, cost projections, budget alternatives, coach chat
  - SDK: `@anthropic-ai/sdk` 0.78.0
  - Model: `claude-sonnet-4-6` (production deployment ready)
  - Key: `process.env.ANTHROPIC_API_KEY`
  - Implementation: `server/lib/ai_generator.ts`, `server/api/generate/[action].ts`
  - Endpoints:
    - `POST /api/generate/hobby` - Full hobby profile from search query
    - `POST /api/generate/faq` - 5 beginner FAQ items (lazy-loaded)
    - `POST /api/generate/cost` - Cost projections: starter/3mo/1yr
    - `POST /api/generate/budget` - DIY/budget/premium alternatives per kit item
    - `POST /api/generate/coach` - Conversational hobby coach (dynamic system prompt)

**Image Services:**
- Unsplash API - Hobby image search with category fallbacks
  - API: `https://api.unsplash.com/search/photos`
  - Key: `process.env.UNSPLASH_ACCESS_KEY` (optional)
  - Implementation: `server/lib/unsplash.ts`
  - Query format: `{query} hobby` with portrait orientation
  - Fallbacks per category hardcoded (all Unsplash URLs)
  - If key missing, returns category fallback immediately

## Data Storage

**Databases:**

- PostgreSQL (Neon) - Primary relational database
  - Connection: `process.env.DATABASE_URL`
  - Client: Prisma 6.4.1 (`@prisma/client`)
  - Schema: `server/prisma/schema.prisma` (25 models)
  - Models: Category, Hobby, KitItem, RoadmapStep, FaqItem, CostBreakdown, BudgetAlternative, HobbyCombo, SeasonalPick, MoodTag, User, UserPreference, UserHobby, UserCompletedStep, UserActivityLog, JournalEntry, PersonalNote, ScheduleEvent, ShoppingCheck, CommunityStory, StoryReaction, BuddyPair, UserChallenge, UserAchievement, GenerationLog

**Local Storage:**

- Hive (encrypted key-value) - Offline cache and sensitive data
  - Package: `hive_flutter` 1.1.0, `hive` 2.2.3
  - Usage: User hobbies, preferences, journal entries, cache
  - Implementation: `lib/core/storage/cache_manager.dart`, `local_storage.dart`

- SharedPreferences - Simple persistent settings
  - Package: `shared_preferences` 2.3.4
  - Usage: App preferences, onboarding state, theme selection

**File Storage:**

- Local filesystem only (no cloud bucket)
  - Image uploads via `path_provider` for temporary paths
  - Photos saved to device documents directory (encrypted)
  - Implementation: `lib/core/media/image_upload.dart`

**Caching:**

- HTTP response cache via `dio` interceptor
- Image cache via `cached_network_image` (platform native)
- No explicit server-side caching (stateless Vercel functions)

## Authentication & Identity

**Auth Provider:**
- Custom JWT implementation
  - Access tokens: 15 minutes
  - Refresh tokens: 30 days (stored securely in `flutter_secure_storage`)
  - Implementation: `lib/core/auth/auth_interceptor.dart`, `token_storage.dart`, `server/lib/auth.ts`
  - Password hashing: bcryptjs (12 rounds)

**OAuth Providers:**

- Google Sign-In
  - SDK: `google_sign_in` 6.2.2
  - Server Client ID: `const String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID')`
  - Endpoint: `POST /api/auth/google` → exchanges ID token for JWT
  - Implementation: `lib/providers/auth_provider.dart`, `server/api/auth/[action].ts`

- Apple Sign-In
  - SDK: `sign_in_with_apple` 6.1.4
  - Service ID: `const String.fromEnvironment('APPLE_SERVICE_ID')`
  - Endpoint: `POST /api/auth/apple` → exchanges identity token for JWT
  - Implementation: `lib/providers/auth_provider.dart`, `server/api/auth/[action].ts`
  - Note: vercel.json route regex missing `|apple` (current: `(register|login|refresh|google)`)

**Local Auth:**
- Email/password registration and login
  - Endpoint: `POST /api/auth/register`, `POST /api/auth/login`
  - Implementation: `server/api/auth/[action].ts`

## Monitoring & Observability

**Error Tracking:**
- Sentry (error reporting and crash analytics)
  - SDK: `sentry_flutter` 9.14.0
  - Plugin: `sentry_dart_plugin` 3.2.1
  - Project: `try-something` / Org: `trysomething-lz`
  - Features: Automatic exception capture, source map upload, debug symbol upload
  - Implementation: `lib/core/error/error_reporter.dart`, `lib/main.dart` initialization
  - Configuration: `pubspec.yaml` sentry section

**Analytics:**
- PostHog (event tracking, session analytics, feature flags)
  - SDK: `posthog_flutter` 4.0.0
  - API Key: `phx_YBR1OSrdQgfVPK55QJVNqh1CzOSy9r6qFCh5uhgZoy7R2PL` (public)
  - Host: `https://us.i.posthog.com`
  - Features: Screen tracking, custom events, session recording (optional), user identification
  - Implementation: `lib/core/analytics/analytics_service.dart`, `analytics_provider.dart`
  - Configuration: Environment variables in `analytics_service.dart`

**Logs:**
- Console logging in debug mode (dart `debugPrint`)
- Error ring buffer (50 errors) in `ErrorReporter` class
- No persistent server-side logging (Vercel provides request logs via dashboard)

## CI/CD & Deployment

**Hosting:**

- Frontend: Deployed to Apple App Store + Google Play Store
  - Manual release via Xcode (iOS) and Android Studio (Android)
  - Test builds via TestFlight (iOS) and internal testing (Google Play)

- Backend: Vercel Serverless Functions
  - Platform: @vercel/node
  - Automatic deployment on git push to main
  - Prisma migrations: manual via `npm run db:migrate` (should be automated)
  - Configuration: `server/vercel.json`

**CI Pipeline:**
- Not detected - no GitHub Actions or CI config in repo
- Manual testing recommended before release

## Environment Configuration

**Required Environment Variables:**

Backend (Vercel production + `.env.local` for local dev):
```
DATABASE_URL=postgresql://user:pass@neon.host/db
ANTHROPIC_API_KEY=sk-ant-...
JWT_SECRET=<random-secret-for-token-signing>
UNSPLASH_ACCESS_KEY=<unsplash-api-key>  # Optional
```

Frontend (build flags or `.env`):
```
POSTHOG_API_KEY=phx_YBR1OSrdQgfVPK55QJVNqh1CzOSy9r6qFCh5uhgZoy7R2PL
POSTHOG_HOST=https://us.i.posthog.com
GOOGLE_SERVER_CLIENT_ID=<server-client-id-from-google-console>
APPLE_SERVICE_ID=<service-id-from-apple-developer>
REVENUECAT_API_KEY=<platform-specific-key>
```

**Secrets Location:**

- Environment variables stored in:
  - Vercel project settings (production backend)
  - `firebase.json` (contains projectId, no secrets)
  - Token storage: `flutter_secure_storage` (platform native keychain/keystore)
  - OAuth keys: embedded as `const String.fromEnvironment()` (dev only)

## Webhooks & Callbacks

**Incoming:**

- RevenueCat webhooks (subscription events)
  - Endpoint: `POST /api/webhooks/revenuecat`
  - Triggered by: subscription purchase, renewal, cancellation, expiration
  - Implementation: `server/api/users/[path].ts?path=revenuecat-webhook`
  - No signature verification detected (should be added)

- Firebase Cloud Messaging (push notification receipt)
  - Handled client-side only (no server webhook)
  - Implementation: `lib/core/notifications/notification_service.dart`

**Outgoing:**

- None detected - app is read-only for external services

## Third-Party SDKs Summary

| Service | Version | Purpose | Key Location |
|---------|---------|---------|---|
| Claude API | 0.78.0 | Hobby generation + coach | `ANTHROPIC_API_KEY` |
| Firebase | 3.12.1 (core), 15.2.4 (messaging) | Push notifications | `firebase.json` |
| RevenueCat | 9.14.0 | Subscriptions (iOS) | `appl_SkiBGKbnsWiBfFNnLWfPfFqYJXC` |
| PostHog | 4.0.0 | Analytics | `phx_YBR1OSrdQgfVPK55QJVNqh1CzOSy9r6qFCh5uhgZoy7R2PL` |
| Sentry | 9.14.0 | Error tracking | `try-something` project |
| Unsplash | — | Image search | `UNSPLASH_ACCESS_KEY` |
| Google OAuth | — | Sign-in | `GOOGLE_SERVER_CLIENT_ID` |
| Apple Sign-In | — | Sign-in | `APPLE_SERVICE_ID` |
| Neon PostgreSQL | — | Database | `DATABASE_URL` |

---

*Integration audit: 2026-03-21*
