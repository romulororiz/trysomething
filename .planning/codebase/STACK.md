# Technology Stack

**Analysis Date:** 2026-03-21

## Languages

**Primary:**
- Dart 3.6.0+ - Flutter frontend application
- TypeScript 5.7.2 - Node.js backend on Vercel Serverless

**Secondary:**
- Swift - iOS native code (xcode build output)
- Kotlin - Android native code (gradle, CMake)

## Runtime

**Environment:**
- Flutter 3.6.0 - Cross-platform mobile framework (iOS/Android)
- Node.js - Backend runtime on Vercel Serverless Functions (@vercel/node 5.0.2)
- Dart VM - Dart code execution

**Package Managers:**
- pub - Dart/Flutter package manager (pubspec.yaml)
  - Lockfile: `pubspec.lock` (present)
- npm - JavaScript package manager (package.json)
  - Lockfile: `package-lock.json` (standard npm)

## Frameworks

**Frontend - State Management & Routing:**
- flutter_riverpod 2.6.1 - Reactive state management
- riverpod_annotation 2.6.1 - Code generation for Riverpod
- riverpod_generator 2.6.2 - Build runner provider generation
- go_router 14.8.1 - Declarative routing with GoRouter

**Frontend - UI & Animation:**
- Flutter Material Design - Material Design framework (included with Flutter)
- google_fonts 6.2.1 - Dynamic font loading (Source Serif 4, DM Sans, IBM Plex Mono)
- flutter_animate 4.5.2 - Animation builder for entrance/transition effects
- timelines_plus 1.0.0 - Timeline/roadmap UI widget

**Frontend - Build & Serialization:**
- freezed 2.5.7 - Immutable data classes with equality
- freezed_annotation 2.4.4 - Freezed annotations
- json_serializable 6.9.0 - JSON to/from Dart serialization
- json_annotation 4.9.0 - JSON serialization annotations
- build_runner 2.4.14 - Dart code generation orchestration
- flutter_launcher_icons 0.14.3 - App icon generation for iOS/Android

**Backend - Web Framework:**
- @vercel/node 5.0.2 - Vercel serverless Node.js functions
- No express.js - Raw handler functions in `/api/**/*.ts` routed by vercel.json

**Backend - Database & ORM:**
- Prisma 6.4.1 - TypeScript ORM with automatic migrations
- @prisma/client 6.4.1 - Database client
- PostgreSQL (Neon) - Relational database via CONNECTION_URL environment variable

**Backend - Authentication:**
- bcryptjs 2.4.3 - Password hashing (12 rounds)
- jsonwebtoken 9.0.2 - JWT token generation/verification
  - 15-minute access tokens
  - 30-day refresh tokens
  - Token storage in `lib/core/auth/token_storage.dart` (encrypted via flutter_secure_storage)

**Testing:**
- vitest 3.0.0 - Fast unit test runner for server code
- @types/* - TypeScript type definitions for build tooling

## Key Dependencies

**Critical:**

- @anthropic-ai/sdk 0.78.0 - Claude API integration for hobby generation (see INTEGRATIONS.md)
  - Model: claude-sonnet-4-6 (production, ready for Claude 3.5)
  - Temperature: 0.2-0.3 (hobby generation), 0.5 (coach chat)
  - Used in: `server/api/generate/[action].ts`, `server/lib/ai_generator.ts`

- purchases_flutter 9.14.0 / purchases_ui_flutter 9.14.0 - RevenueCat SDK for in-app subscriptions
  - Entitlement: `pro`
  - Apple API key: `appl_SkiBGKbnsWiBfFNnLWfPfFqYJXC`
  - Google key: placeholder (pending Google Play setup)

- firebase_core 3.12.1 - Firebase initialization
- firebase_messaging 15.2.4 - Firebase Cloud Messaging for push notifications

- posthog_flutter 4.0.0 - Event analytics and session tracking
  - API Key: `phx_YBR1OSrdQgfVPK55QJVNqh1CzOSy9r6qFCh5uhgZoy7R2PL` (public, safe to commit)
  - Host: `https://us.i.posthog.com`

- sentry_flutter 9.14.0 - Error tracking and crash reporting
  - sentry_dart_plugin 3.2.1 - Source map and debug symbol uploads
  - Project: `try-something` / Org: `trysomething-lz`

**Infrastructure:**

- dio 5.7.0 - HTTP client with interceptors for API calls
  - Base URL: `https://api.trysomething.io`
  - Timeout: 10s connect, 15s receive
  - Interceptors: AuthInterceptor (JWT token injection)

- cached_network_image 3.4.1 - Image caching with network fallback
- image_picker 1.1.2 - Native image/gallery picker

- hive_flutter 1.1.0 + hive 2.2.3 - Local encrypted key-value storage for offline cache
- shared_preferences 2.3.4 - Simple persistent key-value storage

- google_sign_in 6.2.2 - Google OAuth integration
  - Server Client ID: via `GOOGLE_SERVER_CLIENT_ID` environment variable
- sign_in_with_apple 6.1.4 - Apple Sign-In integration
  - Service ID: via `APPLE_SERVICE_ID` environment variable
- crypto 3.0.6 - Cryptographic utilities for auth flows

- flutter_secure_storage 9.2.4 - Secure token and credential storage (platform native)
- flutter_local_notifications 18.0.1 - Local notification scheduling
  - timezone 0.10.0 - Timezone support for scheduled notifications

- wakelock_plus 1.2.1 - Keep screen awake during session timer

**Utilities:**

- uuid 4.5.1 - UUID v4 generation for unique identifiers
- intl 0.19.0 - Internationalization and date formatting
- collection 1.19.0 - Dart collection utilities
- url_launcher 6.3.2 - Open links, app store URLs
- cupertino_icons 1.0.8 - iOS native icons
- material_design_icons_flutter 7.0.7296 - Material Design icon set
- phosphor_flutter 2.1.0 - Phosphor icon set (modern, minimal)
- path_provider 2.1.2 - System paths (documents, cache, tmp)
- share_plus 10.1.4 - Share dialog (text, images, files)
- cors 2.8.5 - CORS middleware for Node.js backend
- pg 8.20.0 - PostgreSQL driver (dev dependency for ts-node migrations)
- ts-node 10.9.2 - Execute TypeScript directly (db scripts)

## Configuration

**Environment Variables:**

Frontend (`.env` or `-c key=value` build flags):
- `POSTHOG_API_KEY` - Analytics API key (defaults to project key)
- `POSTHOG_HOST` - PostHog ingestion endpoint
- `GOOGLE_SERVER_CLIENT_ID` - OAuth server-to-server ID
- `APPLE_SERVICE_ID` - Apple Sign-In service identifier
- `REVENUECAT_API_KEY` - RevenueCat SDK key (platform-specific)

Backend (Vercel environment settings, `.env.local` in development):
- `DATABASE_URL` - Neon PostgreSQL connection string (required)
- `ANTHROPIC_API_KEY` - Claude API key for hobby generation (required)
- `UNSPLASH_ACCESS_KEY` - Unsplash API key for image search (optional, uses fallbacks if missing)
- `JWT_SECRET` - Secret for signing/verifying JWT tokens (required)

**Build Configuration:**

- `pubspec.yaml` - Flutter dependencies, version, assets configuration
- `server/package.json` - Node.js dependencies and scripts
- `server/tsconfig.json` - TypeScript compiler options (standard Node.js config)
- `vercel.json` - Vercel Functions routing, build config
- `firebase.json` - Firebase initialization config (Cloud Messaging)
- `analysis_options.yaml` - Dart linter rules
- `build.yaml` - Custom build step configuration
- `android/app/build.gradle` - Android build config (NDK, version)
- `ios/Podfile` - CocoaPods dependencies (iOS native)

**Icon Generation:**

- `flutter_launcher_icons` config in pubspec.yaml
  - Input: `assets/icon/app_icon.png` + `assets/icon/app_icon_foreground.png`
  - Android adaptive icon background: `#0A0A0F` (deep black)
  - Output: Generates all required sizes for iOS/Android

## Platform Requirements

**Development:**

- Dart SDK 3.6.0+ (via Flutter)
- Flutter 3.6.0 (via fvm or flutter cli)
- Android SDK 34+ (for Android builds)
- iOS 12+ (for iOS builds, Xcode 15+)
- Node.js 18+ (for server development)
- npm 9+ (for server packages)
- TypeScript 5.7+ (installed via npm)
- Vercel CLI (optional, for local development)

**Production:**

- iOS app deployed to Apple App Store (requires TestFlight or direct release)
- Android app deployed to Google Play Store
- Backend hosted on Vercel Serverless Functions (automatic scaling)
- Database: Neon PostgreSQL (managed, auto-backups)

---

*Stack analysis: 2026-03-21*
