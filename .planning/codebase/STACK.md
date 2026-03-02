# Technology Stack

**Analysis Date:** 2026-03-02

## Languages

**Primary:**
- **Dart** 3.6.0+ - Flutter client application
- **TypeScript** 5.7.2 - Node.js backend API and web landing page

**Secondary:**
- **JavaScript/JSX/TSX** - React landing page (web/)

## Runtime

**Environment:**
- **Flutter SDK** - Latest stable channel (3.6.0+)
- **Node.js** - 20.x (via @vercel/node runtime on Vercel)
- **Web** - Next.js 16.1.6 (serverless on Vercel)

**Package Manager:**
- **Dart:** pub (integrated with Flutter)
- **Node.js:** npm 10.x
- **Lockfiles:** `pubspec.lock`, `package-lock.json`, `web/package-lock.json`

## Frameworks

**Core Client:**
- **Flutter** - Mobile/web UI framework
- **Riverpod** 2.6.1 - State management (StateNotifierProvider, Provider, FamilyModifier)
- **GoRouter** 14.8.1 - Declarative routing with 26 routes, auth guards, onboarding redirect

**Backend:**
- **Express.js** (via @vercel/node) - Serverless API handler pattern
- **Prisma** 6.4.1 - Type-safe ORM for Postgres

**Web Landing:**
- **Next.js** 16.1.6 - React framework with serverless functions

**Build & Code Generation:**
- **build_runner** 2.4.14 - Dart code generation (Freezed, json_serializable, riverpod_generator)
- **Freezed** 2.5.7 - Immutable data classes with copyWith
- **json_serializable** 6.9.0 - JSON serialization code generation
- **riverpod_generator** 2.6.2 - Riverpod provider code generation

## Key Dependencies

**Client State & Data:**
- **flutter_riverpod** 2.6.1 - State management container and providers
- **riverpod_annotation** 2.6.1 - Annotations for Riverpod generators
- **go_router** 14.8.1 - Declarative routing with URL-based navigation
- **freezed_annotation** 2.4.4 - Freezed immutable class annotations
- **json_annotation** 4.9.0 - JSON serialization annotations

**Client Networking & Storage:**
- **dio** 5.7.0 - HTTP client with interceptor support for JWT auth
- **flutter_secure_storage** 9.2.4 - Encrypted token storage (secure enclave on iOS/Android)
- **hive_flutter** 1.1.0 - Lightweight local cache for hobby content (Hive boxes)
- **hive** 2.2.3 - Core Hive database
- **shared_preferences** 2.3.4 - Key-value persistence for onboarding state, user preferences, hobby statuses
- **cached_network_image** 3.4.1 - Image loading with disk caching

**Client Authentication:**
- **google_sign_in** 6.2.2 - Google OAuth 2.0 sign-in with idToken and accessToken fallback

**Client UI & Design:**
- **google_fonts** 6.2.1 - Google Fonts integration (Source Serif 4, DM Sans, IBM Plex Mono)
- **flutter_animate** 4.5.2 - Declarative animation framework
- **material_design_icons_flutter** 7.0.7296 - Material Design icons
- **phosphor_flutter** 2.1.0 - Phosphor icon set

**Client Utilities:**
- **uuid** 4.5.1 - UUID generation
- **intl** 0.19.0 - Internationalization and date formatting
- **collection** 1.19.0 - Collection utilities

**Backend Authentication:**
- **jsonwebtoken** 9.0.2 - JWT signing and verification (15min access, 30d refresh)
- **bcryptjs** 2.4.3 - Password hashing (PBKDF2 with 12 salt rounds)

**Backend Infrastructure:**
- **@prisma/client** 6.4.1 - Generated Prisma database client
- **cors** 2.8.5 - CORS middleware for Express
- **@vercel/node** 5.0.2 - Vercel serverless runtime

**Backend Build & Testing:**
- **typescript** 5.7.2 - TypeScript compiler
- **ts-node** 10.9.2 - TypeScript execution (for seed scripts)
- **vitest** 3.0.0 - Unit test runner

## Configuration

**Flutter Client:**

**Config Files:**
- `pubspec.yaml` - Dart dependencies, Flutter SDK constraint, assets
- `analysis_options.yaml` - Dart linting rules (prefer_const, avoid_print, prefer_single_quotes)
- `build.yaml` - Code generator configuration

**Environment Variables (optional at build time):**
- `GOOGLE_SERVER_CLIENT_ID` - Optional override for Android idToken flow (passed via `--dart-define`)

**Backend Server:**

**Config Files:**
- `server/package.json` - Node dependencies, NPM scripts (dev, build, lint, db:migrate, test)
- `server/tsconfig.json` - TypeScript compiler options (ES2020, strict mode, path aliases `@lib/*`)
- `server/vercel.json` - Vercel serverless function routing (15 routes → 4 handler files)
- `server/.env.example` - Template for environment variables

**Environment Variables (required):**
- `DATABASE_URL` - Neon Postgres connection string (serverless Postgres)
- `JWT_SECRET` - Secret for signing access tokens (15min expiry) — generate with `openssl rand -base64 32`
- `JWT_REFRESH_SECRET` - Secret for signing refresh tokens (30d expiry) — separate secret for rotation flexibility
- `GOOGLE_CLIENT_IDS` - Comma-separated list of 3 Google OAuth client IDs (Web, Android, iOS)
- `NODE_ENV` - Environment mode (development/production)

**Web Landing (Next.js):**

**Config Files:**
- `web/tsconfig.json` - TypeScript strict mode, JSX react-jsx
- `web/package.json` - React 19, Next.js 16, Tailwind CSS 4, Three.js, Framer Motion
- `web/next.config.ts` - Next.js configuration

## Platform Requirements

**Development:**

**Mobile (Flutter):**
- Flutter 3.6.0+ (Dart SDK bundled)
- iOS 12.0+ (Xcode 15+, CocoaPods)
- Android 21+ (Android Studio, JDK 11+, Gradle)
- Google OAuth setup: 3 client IDs from Google Cloud Console

**Backend:**
- Node.js 20.x
- Prisma CLI (via postinstall hook in package.json)
- Neon Postgres account for DATABASE_URL

**Web Landing:**
- Node.js 20.x
- npm 10.x

**Production:**

**Hosting:**
- **Mobile:** Apple App Store (iOS) + Google Play Store (Android) — Flutter builds APK/IPA
- **Backend:** Vercel Hobby plan (12 serverless functions, currently using 11)
- **Database:** Neon Postgres (serverless, auto-scaling)
- **Web:** Vercel (Next.js serverless functions)

**API:**
- Live at `https://server-psi-seven-49.vercel.app/api`
- Accessible from Flutter via Dio HTTP client with AuthInterceptor

**SSL/TLS:**
- All connections require HTTPS (database via sslmode=require, API over HTTPS)

## Build & Deployment

**Flutter Client:**
```bash
flutter analyze lib/                    # Type checking (0 errors expected)
flutter run                             # Development build (hot restart with Shift+R)
flutter build apk                       # Android release APK
flutter build ios                       # iOS app bundle
flutter build web                       # Web build (wasm target)
dart run build_runner build --delete-conflicting-outputs  # Code generation
```

**Backend:**
```bash
cd server && npm install                # Install dependencies (runs prisma generate as postinstall)
npm run db:migrate                      # Run migrations
npm run db:push                         # Sync schema to database
npm run db:seed                         # Seed with data
npm run build                           # TypeScript compilation
npm run lint                            # Type-check without emitting
npm test                                # Run vitest tests
npx vercel --prod                       # Deploy to Vercel production
```

**Web Landing:**
```bash
cd web && npm install
npm run dev                             # Development server
npm run build && npm start              # Production build and start
vercel deploy --prod                    # Deploy to Vercel
```

## Deployment Architecture

**Client → Backend Flow:**

1. Flutter client at startup initializes:
   - `LocalStorage.init()` → Hive box initialization
   - `SharedPreferences.getInstance()` → User state persistence
   - Dio singleton with AuthInterceptor attached

2. AuthInterceptor on every API request:
   - Reads JWT access token from `flutter_secure_storage`
   - Attaches `Authorization: Bearer {token}` header
   - On 401 response: uses separate Dio instance to refresh token at `/auth/refresh`
   - Retries original request with new token

3. Hobby content loaded via `hobbyListProvider`:
   - Attempts API fetch to `/hobbies`
   - On success: caches JSON to Hive with 1-hour TTL
   - On failure: falls back to `SeedData` (offline-first behavior)

4. User authentication:
   - Email/password: POST to `/auth/login`, receive access + refresh tokens
   - Google sign-in: Client sends idToken (or fallback accessToken) to `/auth/google`, server verifies with Google, creates/finds user, returns token pair

---

*Stack analysis: 2026-03-02*
