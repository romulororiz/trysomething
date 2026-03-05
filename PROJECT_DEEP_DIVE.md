# TrySomething — Complete Project Deep Dive

> Generated from full codebase analysis (March 2026). Use this as the definitive reference for what the app is, how it works, and its current state.

---

## 1. Executive Summary & Purpose

**TrySomething** is a hobby discovery mobile app that helps people who are interested in trying new hobbies but don't know where to start. The tagline is *"helps you actually start."* It solves the gap between "I want a hobby" and "I'm actually doing one" by providing curated hobby content, step-by-step roadmaps, starter kit lists, cost breakdowns, and progress tracking.

**Target user:** Adults (18–45) who feel stuck in routine, want to explore new interests, but are overwhelmed by options or don't know the first practical step. Think someone scrolling Reddit's r/hobbies at midnight asking "what hobby should I pick up?"

**Jobs-to-be-done:**
1. **Discover** hobbies that match their vibe, budget, and available time
2. **Evaluate** a hobby before committing (cost, difficulty, time, starter kit)
3. **Start** with a structured roadmap of concrete steps
4. **Track** progress and maintain motivation through streaks and achievements
5. **Connect** with others trying the same hobbies (buddy system, community stories)

**Competitors:** Stridist (habit tracker), Meetup (social activities), Pinterest (inspiration boards), but none combine discovery + structured onramp + progress tracking in one app.

**Current state:** Late MVP — 7 of 8 development batches complete. Full API backend live on Vercel. 26 screens implemented. Auth, content, progress tracking, personal tools, social features, and gamification all working. UI recently redesigned ("Refined Midnight Neon"). Missing: push notifications (stub ready), production Firebase setup, app store submission.

---

## 2. Tech Stack & Architecture

```
Frontend:   Flutter 3.6.0 + Riverpod 2.6.1 + GoRouter 14.8.1 + Freezed + google_fonts
Backend:    Node.js + Express (TypeScript) + Prisma 6.4.1 + bcryptjs + jsonwebtoken
Database:   Neon Postgres (serverless) with 25 Prisma models
Infra:      Vercel (serverless functions) + GitHub Actions CI
APIs:       REST (JSON) — 40+ endpoints consolidated into 11 serverless functions
External:   Google OAuth (3 client IDs), Claude API (AI hobby generation)
Dev Tools:  flutter_analyze + TypeScript strict + Vitest + flutter_test
```

**Architecture pattern:** Client-server with offline-first caching. The Flutter client talks to a REST API on Vercel. Data flows through a repository pattern with three fallback layers: API → Hive cache → static SeedData.

```
┌─────────────────────────────┐
│     Flutter Client          │
│  ┌───────────────────────┐  │
│  │ Screens (26 routes)   │  │
│  ├───────────────────────┤  │
│  │ Riverpod Providers    │  │
│  ├───────────────────────┤  │
│  │ Repositories          │  │
│  │ (API → Hive → Seed)   │  │
│  ├───────────────────────┤  │
│  │ Dio + AuthInterceptor │  │
│  └───────┬───────────────┘  │
│          │ HTTPS/JWT        │
└──────────┼──────────────────┘
           │
┌──────────▼──────────────────┐
│    Vercel Serverless API    │
│  ┌───────────────────────┐  │
│  │ 11 Handler Functions  │  │
│  │ (auth, users, hobbies │  │
│  │  categories, generate)│  │
│  ├───────────────────────┤  │
│  │ Prisma ORM            │  │
│  └───────┬───────────────┘  │
│          │                  │
└──────────┼──────────────────┘
           │
┌──────────▼──────────────────┐
│     Neon Postgres           │
│     25 models, 10 content   │
│     + 15 user/social/game   │
└─────────────────────────────┘
```

---

## 3. Project Structure

```
c:\dev\trysomething\
├── lib/                          # Flutter app source
│   ├── main.dart                 # Bootstrap: bindings, error handler, runZonedGuarded, ProviderScope
│   ├── router.dart               # GoRouter: 26 routes, auth/onboarding redirect chain, analytics observer
│   ├── models/                   # Freezed data classes (8 files + generated)
│   │   ├── hobby.dart            # Hobby, KitItem, RoadmapStep, HobbyCategory, UserHobby, UserPreferences
│   │   ├── auth.dart             # AuthUser, AuthResponse
│   │   ├── features.dart         # UserProfile, Challenge, ScheduleEvent, HobbyCombo, FaqItem, CostBreakdown, BudgetAlternative
│   │   ├── social.dart           # JournalEntry, BuddyProfile, BuddyActivity, CommunityStory, NearbyUser, BuddyRequest
│   │   ├── gamification.dart     # Achievement model
│   │   ├── activity_log.dart     # ActivityLog model
│   │   ├── curated_pack.dart     # CuratedPack model
│   │   ├── seed_data.dart        # Static offline fallback data (9 categories, all hobbies)
│   │   └── feature_seed_data.dart # Static fallback for feature screens
│   ├── core/
│   │   ├── api/
│   │   │   ├── api_client.dart   # Dio singleton (10s connect, 15s receive timeout)
│   │   │   └── api_constants.dart # 40+ endpoint path constants
│   │   ├── auth/
│   │   │   ├── auth_interceptor.dart # Attaches Bearer JWT, catches 401, refreshes token
│   │   │   └── token_storage.dart    # flutter_secure_storage wrapper
│   │   ├── error/
│   │   │   ├── error_reporter.dart   # Ring buffer (50 errors), console logging
│   │   │   └── error_provider.dart   # Riverpod observer for provider errors
│   │   ├── analytics/
│   │   │   ├── analytics_service.dart # trackScreen/trackEvent/setUserId (console stub)
│   │   │   └── analytics_provider.dart # GoRouter observer + Riverpod provider
│   │   ├── notifications/
│   │   │   ├── notification_service.dart # FCM stub (no-op until Firebase configured)
│   │   │   └── notification_provider.dart
│   │   └── storage/
│   │       └── local_storage.dart    # Hive initialization
│   ├── data/repositories/            # Interface + API implementation pairs
│   │   ├── auth_repository.dart / auth_repository_api.dart
│   │   ├── hobby_repository.dart / hobby_repository_api.dart
│   │   ├── feature_repository.dart / feature_repository_api.dart
│   │   ├── user_progress_repository.dart / user_progress_repository_api.dart
│   │   ├── personal_tools_repository.dart / personal_tools_repository_api.dart
│   │   ├── social_repository.dart / social_repository_api.dart
│   │   └── gamification_repository.dart / gamification_repository_api.dart
│   ├── providers/
│   │   ├── auth_provider.dart        # AuthNotifier (register/login/google/logout/restore)
│   │   ├── hobby_provider.dart       # hobbyListProvider, generationProvider, filteredHobbiesProvider
│   │   ├── user_provider.dart        # onboarding, preferences, userHobbies (SharedPrefs + API)
│   │   ├── feature_providers.dart    # Journal, schedule, notes, shopping, stories, buddy, challenge, profile
│   │   └── repository_providers.dart # All repository provider bindings
│   ├── screens/                      # 26 screen files across subdirectories
│   │   ├── auth/ (login, register)
│   │   ├── onboarding/ (3-page vibes/budget/social)
│   │   ├── feed/ (vertical card discovery feed)
│   │   ├── explore/ (2-column category grid)
│   │   ├── search/ (full-text search)
│   │   ├── my_stuff/ (Saved/Trying/Active/Done tabs)
│   │   ├── profile/ (stats, heatmap, radar)
│   │   ├── settings/
│   │   ├── detail/ (full hobby detail with roadmap)
│   │   ├── quickstart/ (modal slide-up starter)
│   │   └── features/ (16 feature screens)
│   ├── components/                  # Shared widgets
│   │   ├── hobby_card.dart          # Full-bleed feed card (parallax, particle save)
│   │   ├── shared_widgets.dart, spec_badge.dart, category_tile.dart
│   │   ├── page_transitions.dart    # fadeSlide, slideRight, modalSlideUp
│   │   └── curved_nav/ (5 files)   # Local fork of curved navigation bar
│   └── theme/                       # "Midnight Neon" design tokens
│       ├── app_colors.dart (37+ tokens), app_theme.dart, app_typography.dart (20+ styles)
│       ├── spacing.dart (4px grid), motion.dart (durations/curves)
│       └── app_icons.dart, category_ui.dart, scroll_physics.dart
├── server/                          # Node.js API
│   ├── api/ (11 serverless handler files)
│   ├── lib/ (auth, mappers, middleware, db, gamification)
│   ├── prisma/schema.prisma (25 models, 390 lines)
│   └── test/ (3 files, 32 tests)
├── test/unit/ (16 files, 158 tests)
├── .github/workflows/ci.yml
└── CLAUDE.md (308-line project guide)
```

---

## 4. Backend — In Detail

### 4a. API Endpoints

**Auth (`/api/auth/[action]`)** — All POST, no auth required:

| Path | Purpose | Request Body | Response |
|------|---------|-------------|----------|
| `/api/auth/register` | Create account | `{email, password, displayName}` | `{user, accessToken, refreshToken}` |
| `/api/auth/login` | Email login | `{email, password}` | `{user, accessToken, refreshToken}` |
| `/api/auth/refresh` | Refresh JWT | `{refreshToken}` | `{accessToken, refreshToken}` |
| `/api/auth/google` | Google sign-in | `{idToken?, accessToken?}` | `{user, accessToken, refreshToken}` |

**User (`/api/users/[path]`)** — All require Bearer JWT:

| Method | Path | Purpose |
|--------|------|---------|
| GET | `/api/users/me` | Get current user profile |
| PUT | `/api/users/me` | Update displayName, bio, avatarUrl |
| GET/PUT | `/api/users/preferences` | Get/update user preferences |
| GET | `/api/users/hobbies` | Get user's saved/trying/active/done hobbies |
| POST | `/api/users/hobbies` | Save a hobby |
| PUT | `/api/users/hobbies/:hobbyId` | Update hobby status |
| DELETE | `/api/users/hobbies/:hobbyId` | Unsave a hobby |
| POST | `/api/users/hobbies/:hobbyId/steps/:stepId` | Toggle step completion |
| POST | `/api/users/hobbies-sync` | Bulk sync hobbies (first-login migration) |
| GET | `/api/users/activity` | Get activity log (last N days) |
| GET/POST | `/api/users/journal` | List/create journal entries |
| DELETE | `/api/users/journal/:entryId` | Delete journal entry |
| GET | `/api/users/notes/:hobbyId` | Get notes for hobby |
| PUT/DELETE | `/api/users/notes/:hobbyId/:stepId` | Save/delete a note |
| GET/POST | `/api/users/schedule` | List/create schedule events |
| DELETE | `/api/users/schedule/:eventId` | Delete schedule event |
| GET/PUT | `/api/users/shopping/:hobbyId` | Get/toggle shopping items |
| GET/POST | `/api/users/stories` | List/create community stories |
| DELETE | `/api/users/stories/:storyId` | Delete own story |
| POST/DELETE | `/api/users/stories/:storyId/react/:type` | Toggle reaction (heart/fire) |
| GET | `/api/users/buddies` | Get buddy profiles + activities |
| GET/POST | `/api/users/buddy-requests` | List/send buddy requests |
| PUT | `/api/users/buddy-requests/:requestId` | Accept/reject request |
| GET | `/api/users/similar-users` | Find users with overlapping hobbies |
| GET | `/api/users/challenges` | Get/auto-create weekly challenges |
| GET | `/api/users/achievements` | Get/auto-check achievements |

**Content (public, no auth):**

| Method | Path | Purpose |
|--------|------|---------|
| GET | `/api/hobbies` | List all hobbies |
| GET | `/api/hobbies/:id` | Hobby detail (kit + roadmap included) |
| GET | `/api/hobbies/search?q=` | Full-text search |
| GET | `/api/hobbies/combos` | Complementary hobby pairs |
| GET | `/api/hobbies/seasonal` | Seasonal picks by season |
| GET | `/api/hobbies/mood` | Mood-to-hobby mapping |
| GET | `/api/hobbies/:id/faq` | FAQ for a hobby |
| GET | `/api/hobbies/:id/cost` | Cost breakdown |
| GET | `/api/hobbies/:id/budget` | DIY/budget/premium alternatives |
| GET | `/api/categories` | Category list with counts |

**AI Generation (requires auth):**

| Method | Path | Purpose |
|--------|------|---------|
| POST | `/api/generate/hobby` | Generate hobby via Claude API |
| POST | `/api/generate/faq` | Generate FAQ |
| POST | `/api/generate/cost` | Generate cost breakdown |
| POST | `/api/generate/budget` | Generate budget alternatives |

### 4b. Data Models (25 Prisma Models)

**Content (10 models):**
- **Category** — id, name, imageUrl, sortOrder → hasMany Hobby
- **Hobby** — id, title, hook, categoryId, imageUrl, tags[], costText, timeText, difficultyText, whyLove, difficultyExplain, pitfalls[], isAiGenerated, generatedBy → belongsTo Category; hasMany KitItem, RoadmapStep, FaqItem, BudgetAlternative, SeasonalPick, MoodTag; hasOne CostBreakdown
- **KitItem** — name, description, cost (int CHF), isOptional, sortOrder → belongsTo Hobby (cascade)
- **RoadmapStep** — id, title, description, estimatedMinutes, milestone? → belongsTo Hobby (cascade)
- **FaqItem** — question, answer, upvotes → belongsTo Hobby
- **CostBreakdown** — starter, threeMonth, oneYear (int CHF), tips[] → 1:1 with Hobby
- **BudgetAlternative** — itemName, diyOption/Cost, budgetOption/Cost, premiumOption/Cost → belongsTo Hobby
- **HobbyCombo** — hobbyId1, hobbyId2, reason, sharedTags[] → @@unique([hobbyId1, hobbyId2])
- **SeasonalPick** — hobbyId, season → @@unique([hobbyId, season])
- **MoodTag** — hobbyId, mood → @@unique([hobbyId, mood])

**Auth (2):**
- **User** — id (uuid), email (@unique), passwordHash, displayName, bio, avatarUrl?, googleId? (@unique), timestamps
- **UserPreference** — userId (@unique), hoursPerWeek (default 3), budgetLevel (default 1), preferSocial, vibes[]

**Progress (3):**
- **UserHobby** — userId, hobbyId, status (saved/trying/active/done), startedAt?, completedAt?, streakDays → @@unique([userId, hobbyId])
- **UserCompletedStep** — userId, hobbyId, stepId → @@unique([userId, hobbyId, stepId])
- **UserActivityLog** — userId, hobbyId?, action, createdAt → @@index([userId, createdAt])

**Personal Tools (4):**
- **JournalEntry** — userId, hobbyId, text, photoUrl?, createdAt
- **PersonalNote** — userId, hobbyId, stepId, text → @@unique per step
- **ScheduleEvent** — userId, hobbyId, dayOfWeek (1-7), startTime ("HH:MM"), durationMinutes
- **ShoppingCheck** — userId, hobbyId, itemName, checked → @@unique per item

**Social (3):**
- **CommunityStory** — userId, quote, hobbyId → hasMany StoryReaction
- **StoryReaction** — userId, storyId, type ("heart"/"fire") → @@unique([userId, storyId, type])
- **BuddyPair** — requesterId, accepterId, hobbyId?, status ("pending"/"active"/"rejected")

**Gamification (2):**
- **UserChallenge** — userId, challengeType, currentCount, targetCount, isCompleted, weekStart
- **UserAchievement** — userId, achievementId, unlockedAt

**AI (1):**
- **GenerationLog** — userId, query, hobbyId?, status, reason?

### 4c. Authentication

- **JWT pair:** Access (15 min, HS256) + Refresh (30 days). Different secrets.
- **Password:** bcrypt, 12 salt rounds
- **Google OAuth:** 3 client IDs (Android, iOS, Web). Two flows: idToken verification via Google tokeninfo endpoint, accessToken fallback via userinfo endpoint (for Windows/desktop).
- **Guard:** `requireAuth()` extracts Bearer token, verifies, returns userId or sends 401.
- **Client:** Dio `AuthInterceptor` auto-attaches JWT, catches 401, refreshes with separate Dio instance, retries.
- **Storage:** `flutter_secure_storage` (encrypted at rest).

### 4d. Business Logic

- **Optimistic updates with rollback:** All user mutations update state instantly, fire API in background, revert on failure.
- **Three-layer fallback:** API → Hive cache → SeedData. App always works offline.
- **Challenge auto-progress:** Server auto-creates weekly challenges and calculates progress from real user activity.
- **Achievement auto-unlock:** 9 achievement types auto-checked server-side.
- **AI generation:** Claude API generates full hobby objects (title, roadmap, kit, etc.), stored as real hobbies in Postgres.

---

## 5. Frontend / UI/UX

### 5a. Design System — "Midnight Neon"

**Color Tokens (dark → light):**

| Token | Hex | Role |
|-------|-----|------|
| cream | #0A0A0F | **Darkest** — app background |
| warmWhite | #141420 | Surface/card bg |
| sand | #1E1E2E | Elevated surface, back buttons |
| sandDark | #2A2A3C | Borders |
| stone | #363650 | Separators |
| warmGray | #6B6B80 | Muted text |
| driftwood | #A0A0B8 | Secondary text |
| espresso | #C0C0D0 | Icons, tertiary text |
| darkBrown | #D8D8E8 | Body text |
| nearBlack | #F8F8FC | **Lightest** — headings |
| coral | #FF6B6B | CTA, primary accent |
| amber | #FBBF24 | Gold, badges |
| indigo | #7C3AED | Brand secondary |
| sage | #06D6A0 | Success, mint |

**9 category colors:** Creative=#D946EF, Outdoors=#06D6A0, Fitness=#FF4757, Maker=#FBBF24, Music=#818CF8, Food=#FB923C, Collecting=#38BDF8, Mind=#7C3AED, Social=#F472B6

**Typography:** Source Serif 4 (headings), DM Sans (body), IBM Plex Mono (data/badges). 20+ named styles.

**Spacing:** 4px grid. Card radius=22, tile=16, button=14.

**Motion:** fast=150ms, normal=250ms, slow=350ms, navForward=350ms, navBack=300ms.

**Aesthetic:** Lush dark space with glowing neon accents. Frosted glass containers with noise grain. Parallax feed cards. Particle burst animations. "Premium dark mode music app meets wellness tracker."

### 5b. Screens & User Flows

**Auth:** Login (email+Google) → Register (email+Google) → Onboarding (3 pages: vibes, budget/time, solo/social) → Feed

**Main Shell (curved bottom nav, 4 tabs):**
1. **Feed** — Vertical card swipe. Category chips filter. Full-bleed HobbyCards (480px) with parallax image, gradient overlay, save button (particle burst), spec badges.
2. **Explore** — 2-column category grid. Tap → filter feed.
3. **My Stuff** — Segmented tabs: Saved/Trying/Active/Done. Progress bars on cards.
4. **Profile** — Stats, activity heatmap, skills radar. Edit name/bio/avatar.

**Detail (`/hobby/:id`):** Hero image, spec badges, "Why you'll love it", starter kit checklist, roadmap steps (animated checkboxes), pitfalls, related hobbies. Floating "Try Today" CTA with breathing glow.

**16 Feature Screens:** mood-match, seasonal, faq, notes, budget, combos, cost, compare, shopping, challenge, journal, scheduler, buddy, stories, local, year-review.

### 5c. State Management

Riverpod throughout. `StateNotifierProvider` for mutable state with persistence. `FutureProvider` for API-backed reads. `.family` for per-ID lookups. Derived `Provider` for computed values.

**Key pattern — optimistic update:**
```
User action → snapshot state → update immediately → save to SharedPrefs
→ fire API in background → on failure: restore snapshot + re-save
```

### 5d. Navigation

GoRouter with `refreshListenable` pattern (stable router, no recreation). Redirect chain: auth check → onboarding check → normal routing. Transitions: fade (auth), slideRight (push), modalSlideUp (quickstart).

---

## 6. Key Data Flow: "User saves hobby from feed"

1. Tap bookmark → `toggleSave(hobbyId)` on UserHobbiesNotifier
2. Snapshot state → add `UserHobby(saved)` → save to SharedPreferences
3. Fire POST `/api/users/hobbies` with JWT
4. Server: `requireAuth()` → `prisma.userHobby.create()` + activity log
5. If API fails: restore snapshot, re-save to SharedPreferences
6. UI: bookmark fills instantly (optimistic), particle burst animation plays

---

## 7. Testing & CI/CD

**190 total tests:**
- Flutter: 158 tests (models, providers, repos, core services)
- Server: 32 tests (auth, middleware, mappers)

**CI:** GitHub Actions — Flutter (analyze + test + build APK) + Server (lint + test). Concurrency groups cancel stale runs.

---

## 8. Hobby Categories

| Category | Color | Icon Vibe |
|----------|-------|-----------|
| Creative | #D946EF (fuchsia) | Art, design, crafts |
| Outdoors | #06D6A0 (mint) | Nature, adventure |
| Fitness | #FF4757 (red) | Physical activity |
| Maker | #FBBF24 (amber) | Build, tinker |
| Music | #818CF8 (lavender) | Instruments, audio |
| Food | #FB923C (orange) | Cook, bake, ferment |
| Collecting | #38BDF8 (sky blue) | Curate, collect |
| Mind | #7C3AED (violet) | Strategy, calm, learn |
| Social | #F472B6 (pink) | People, groups |

---

## 9. What's Working vs What's Not

### Fully Working (Server-Synced)
- Auth (email + Google)
- All hobby content (list, detail, search, categories, combos, seasonal, mood, faq, cost, budget)
- User progress (save/try/active/done, step tracking, activity log, streaks)
- Personal tools (journal, notes, schedule, shopping list)
- Social (community stories, buddy requests, similar users)
- Gamification (weekly challenges, achievements)
- AI hobby generation via Claude API
- Error handling infrastructure
- Analytics service (console logging, ready for Firebase/Mixpanel)

### Stub/Not Yet Active
- Push notifications (code ready, Firebase not configured)
- Crash reporting to external service (Sentry/Crashlytics not connected)
- Analytics to external service (no Firebase Analytics/Mixpanel connected)

### Not Started
- App store submission (iOS/Android)
- Web deployment
- Admin panel
- Content moderation
- Email notifications

---

*This document covers every file, model, endpoint, screen, provider, and architectural decision in the TrySomething codebase as of March 5, 2026.*
