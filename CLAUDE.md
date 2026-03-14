# TrySomething — CLAUDE.md (v5 — March 2026)

> Single source of truth for Claude Code. Read this before every task.
> Last updated: March 14, 2026 — reflects actual codebase state from repo scan.

---

## Product Thesis

"The best app for helping overwhelmed adults choose one hobby and actually stick with it for 30 days."

Every decision filters through this. If a feature doesn't directly help someone choose a hobby, start it, or keep doing it for 30 days — it's not priority.

**North star metric:** User completes first real session AND returns for step 2.

---

## Tech Stack

```
Frontend:   Flutter 3.6.0 + Riverpod 2.6.1 + GoRouter 14.8.1 + Freezed + google_fonts
Backend:    Node.js + TypeScript on Vercel Serverless + Prisma 6.4.1 + Neon PostgreSQL
AI:         Claude Haiku 3.5 (claude-haiku-4-5-20251001) — PENDING upgrade to Sonnet
Auth:       JWT (15-min access / 30-day refresh) + Google OAuth + Apple Sign-In
Payments:   RevenueCat (purchases_flutter 8.0.0)
Analytics:  PostHog (posthog_flutter 4.0.0) + Sentry (sentry_flutter 9.14.0)
Push:       Firebase Cloud Messaging (firebase_messaging 15.2.4)
Images:     Unsplash API + cached_network_image
Website:    Next.js 16 landing page (website/ directory)
```

### Test Device
Nothing Phone 3a (Android)

---

## Sprint Status

| Sprint | Status | Summary |
|--------|--------|---------|
| A: Fix Foundation | ✅ DONE | Onboarding matching, "why fits you", analytics events |
| B: Restructure App | ✅ DONE | 3-tab nav, Home/Discover/You rebuilt, secondary features hidden |
| C: Visual Overhaul | ✅ DONE | Warm cinematic palette, glass cards, floating dock, hero layout |
| D: Detail Page | ✅ DONE | Hobby detail redesign, commitment flow, 4-stage roadmap, quit reasons |
| E: Coach + Monetization | ✅ DONE | Coach modes, RevenueCat, paywall, Pro locks, trial screen |
| F: Polish & Launch | 🔶 IN PROGRESS | F.1-F.3 done. F.4 (E2E testing), F.5 (app store prep), F.6 (beta) remain |

### Pending Work
- **F.4** — End-to-end testing (manual, physical device required)
- **F.5** — App store prep (screenshots, descriptions, metadata)
- **F.6** — Beta launch
- **AI prompt upgrade** — Rewritten prompts for Sonnet ready (see Pending Upgrade section), not yet deployed to codebase
- **Account deletion endpoint** — Required for app store compliance, not yet built. Needs `DELETE /api/users/me`
- **Data export endpoint** — FADP requires data portability. Needs `GET /api/users/me/export` returning JSON
- **Terms of Service + Privacy Policy** — Generated as .docx, need to be hosted and linked in app settings + app store listing

---

## App Architecture — 3 Tabs

### Tab 1: Home (`/home` → `home_screen.dart`)
Active hobby dashboard. Action-first, no feed behavior.
- Warm greeting (time-of-day)
- Current hobby card with "Week N of [Hobby]" overline
- Next step glass card → one clear action + coral "Start session" CTA
- This week's plan
- Coach entry with starter chips
- Recent progress / journal
- Restart flow if stalled

### Tab 2: Discover (`/discover` → `discover_feed_screen.dart`)
Hobby discovery with cinematic hero layout.
- Glass search bar → opens search screen
- Full-width hero card (55-60% height) = #1 personalized recommendation
- "More For You" section with 2 smaller glass cards
- "Start Cheap" + "Start This Week" horizontal rails
- Category browse via bottom sheet (not chips)

### Tab 3: You (`/you` → `you_screen.dart`)
Personal utility.
- Active / Saved / Tried hobbies (3 states)
- Journal archive
- Profile
- Subscription status + Pro screen
- Settings
- Basic stats

### Navigation
Floating glass dock in `main_shell.dart` — 3 icons (Home/Compass/Profile), no labels, glass background with blur, 28px radius, 40px horizontal margins.

### Hidden Features (code exists, routes removed)
- Buddy mode (`buddy_mode_screen.dart`)
- Community stories (`community_stories_screen.dart`)
- Local discovery (`local_discovery_screen.dart`)
- Hobby passport / Year in review (`year_in_review_screen.dart`)
- Weekly challenge (`weekly_challenge_screen.dart`)
- Mood match standalone (`mood_match_screen.dart`)
- Seasonal picks standalone (`seasonal_picks_screen.dart`)

---

## File Structure

```
lib/
├── main.dart                          # App entry, Sentry init, provider scope
├── router.dart                        # GoRouter config, all routes
├── core/
│   ├── analytics/                     # PostHog service + navigator observer
│   ├── api/                           # Dio-based API client + constants
│   ├── auth/                          # JWT interceptor + secure token storage
│   ├── error/                         # Sentry error reporter
│   ├── hobby_match.dart               # Onboarding → hobby matching algorithm
│   ├── media/                         # Image upload helper
│   ├── notifications/                 # FCM service + local notification scheduler
│   ├── storage/                       # Hive cache manager + local storage
│   └── subscription/                  # RevenueCat service
├── components/
│   ├── glass_card.dart                # Glass card (blur + no-blur variants)
│   ├── glass_container.dart           # Lower-level glass surface
│   ├── cinematic_scaffold.dart        # Base scaffold with warm background
│   ├── hobby_card.dart                # Hobby card used across screens
│   ├── particle_timer_painter.dart    # Particle formation timer (CustomPainter)
│   ├── category_shape_painter.dart    # Category SVG shapes for particle targets
│   ├── brushstroke_timer_painter.dart  # Brushstroke timer variant
│   ├── radial_hold_painter.dart       # Hold-to-complete radial progress
│   ├── session_glow_widget.dart       # Session ambient glow effect
│   ├── shimmer_skeleton.dart          # Loading skeleton shimmer
│   ├── spec_badge.dart                # Warm gray spec line (cost · time · difficulty)
│   ├── stage_roadmap_card.dart        # 4-stage roadmap card
│   ├── roadmap_step_tile.dart         # Individual step tile
│   ├── pro_upgrade_sheet.dart         # Pro upgrade bottom sheet
│   ├── try_today_button.dart          # CTA button
│   ├── curved_nav/                    # Legacy nav (replaced by floating dock)
│   └── ...
├── data/repositories/                 # Repository pattern: interface → API impl → Hive fallback
│   ├── auth_repository[_api].dart
│   ├── hobby_repository[_api|_impl].dart
│   ├── feature_repository[_api|_impl].dart
│   ├── user_progress_repository[_api].dart
│   ├── personal_tools_repository[_api].dart
│   ├── social_repository[_api].dart
│   └── gamification_repository[_api].dart
├── models/                            # Freezed data classes
│   ├── hobby.dart                     # Hobby, KitItem, RoadmapStep, Category
│   ├── session.dart                   # SessionState, SessionPhase, CompletionMode
│   ├── auth.dart                      # User, TokenPair
│   ├── social.dart                    # JournalEntry, CommunityStory, BuddyPair
│   ├── features.dart                  # FaqItem, CostBreakdown, BudgetAlternative
│   ├── gamification.dart              # Challenge, Achievement
│   ├── activity_log.dart              # ActivityLog
│   ├── seed_data.dart                 # Hardcoded seed data (150+ hobbies)
│   ├── feature_seed_data.dart         # Seed data for features
│   └── curated_pack.dart              # Curated pack model
├── providers/
│   ├── auth_provider.dart             # Auth state + Google/Apple sign-in
│   ├── hobby_provider.dart            # Hobby list, detail, search, generation
│   ├── user_provider.dart             # User prefs, hobbies, onboarding state
│   ├── session_provider.dart          # Session state machine (prepare→timer→reflect→complete)
│   ├── subscription_provider.dart     # RevenueCat Pro status
│   ├── feature_providers.dart         # FAQ, cost, budget, combos, seasonal, mood
│   └── repository_providers.dart      # DI for repositories (API + Hive cache)
├── screens/
│   ├── auth/                          # login_screen, register_screen
│   ├── onboarding/                    # onboarding_screen, trial_offer_screen
│   ├── home/                          # home_screen (Tab 1)
│   ├── feed/                          # discover_feed_screen, rail_feed_screen (Tab 2)
│   ├── you/                           # you_screen (Tab 3)
│   ├── search/                        # search_screen (natural language)
│   ├── detail/                        # hobby_detail_screen (conversion screen)
│   ├── quickstart/                    # quickstart_screen
│   ├── session/                       # session_screen + 4 phase files
│   ├── coach/                         # hobby_coach_screen
│   ├── plan/                          # plan_screen
│   ├── explore/                       # explore_screen
│   ├── my_stuff/                      # my_stuff_screen
│   ├── profile/                       # profile_screen
│   ├── settings/                      # settings_screen, pro_screen
│   ├── features/                      # All feature screens (FAQ, budget, cost, journal, etc.)
│   └── main_shell.dart                # Bottom nav shell (floating glass dock)
└── theme/
    ├── app_colors.dart                # Warm cinematic palette
    ├── app_typography.dart            # Source Serif 4 / DM Sans / IBM Plex Mono
    ├── app_theme.dart                 # ThemeData config
    ├── app_icons.dart                 # Icon mappings
    ├── category_ui.dart               # Category display helpers
    ├── motion.dart                    # Animation durations + curves
    ├── scroll_physics.dart            # Custom scroll physics
    └── spacing.dart                   # Spacing constants
```

---

## Server Structure

```
server/
├── api/
│   ├── auth/[action].ts               # register, login, refresh, google, apple
│   ├── generate/[action].ts           # hobby, faq, cost, budget, coach
│   ├── users/[path].ts                # me, preferences, hobbies, hobbies-sync, hobbies-detail,
│   │                                  #   journal, journal-detail, notes, schedule, schedule-detail,
│   │                                  #   shopping, stories, stories-detail, stories-react,
│   │                                  #   buddies, buddy-requests, buddy-requests-detail,
│   │                                  #   similar-users, challenges, achievements
│   ├── hobbies/                       # index, [id], [id]/[feature], search, combos, mood, seasonal
│   ├── categories/index.ts            # Category list
│   └── health.ts                      # Health check
├── lib/
│   ├── ai_generator.ts                # 4 AI prompts (Haiku): hobby gen, FAQ, cost, budget
│   ├── auth.ts                        # bcrypt (12 rounds) + JWT helpers
│   ├── content_guard.ts               # Input blocklist + output validation
│   ├── db.ts                          # Prisma client singleton
│   ├── gamification.ts                # Challenge/achievement logic
│   ├── mappers.ts                     # DB → API response mappers
│   ├── middleware.ts                   # CORS, method check, error response
│   └── unsplash.ts                    # Unsplash image search with category fallbacks
├── prisma/schema.prisma               # 25 models (399 lines)
├── scripts/                           # batch-generate.ts (one-time seed)
├── test/                              # Vitest tests
├── vercel.json                        # Route config
└── package.json                       # @anthropic-ai/sdk, @prisma/client, @vercel/node, bcryptjs, jsonwebtoken
```

---

## Database (25 Prisma Models)

### Content (Phase 1)
`Category`, `Hobby`, `KitItem`, `RoadmapStep`, `FaqItem`, `CostBreakdown`, `BudgetAlternative`, `HobbyCombo`, `SeasonalPick`, `MoodTag`

### Auth (Phase 2)
`User` (email/password + Google/Apple OAuth, subscriptionTier, revenuecatId), `UserPreference` (hoursPerWeek, budgetLevel, preferSocial, vibes[])

### Progress (Phase 3)
`UserHobby` (status enum: saved/trying/active/done, streakDays, lastActivityAt), `UserCompletedStep` (join table: userId + hobbyId + stepId, @@unique), `UserActivityLog`

### Personal Tools (Phase 5)
`JournalEntry` (text + optional photoUrl), `PersonalNote` (per step), `ScheduleEvent` (dayOfWeek, startTime, duration), `ShoppingCheck`

### Social (Phase 6)
`CommunityStory`, `StoryReaction` (heart/fire), `BuddyPair` (pending/active/rejected)

### Gamification (Phase 7)
`UserChallenge` (weekly, with targetCount), `UserAchievement`

### AI (Phase 9)
`GenerationLog` (userId, query, status, reason — audit trail)

---

## AI System

### Current State: Haiku 3.5 (`claude-haiku-4-5-20251001`)

All AI lives in `server/api/generate/[action].ts` + `server/lib/ai_generator.ts`.

| Endpoint | What it does |
|----------|-------------|
| `POST /api/generate/hobby` | Generate full hobby profile from search query (title, hook, category, tags, cost, time, difficulty, whyLove, pitfalls, kitItems[], roadmapSteps[]) |
| `POST /api/generate/faq` | Generate 5 beginner FAQ items (lazy, on first view) |
| `POST /api/generate/cost` | Generate cost projections: starter/3mo/1yr + tips (lazy) |
| `POST /api/generate/budget` | Generate DIY/budget/premium alternatives per kit item (lazy) |
| `POST /api/coach/chat` | Conversational AI hobby coach with dynamic system prompt |

### Coach System Prompt (built by `buildCoachSystemPrompt()`)
Includes: hobby context (title, category, difficulty, cost, time, kit list, roadmap), user state (BROWSING/SAVED/ACTIVE), coach mode (START/MOMENTUM/RESCUE), recent journal entries (last 5, 100 chars), conversation history (last 15 messages).

### Content Safety (`content_guard.ts`)
4-layer defense:
1. Input validation — length, charset, blocklist (weapons, drugs, NSFW, self-harm, extremism)
2. AI prompt constraints — safe/legal/real hobbies only, CHF pricing, error return for invalid queries
3. Output validation — schema check, field types/ranges, re-scan all generated text against blocklist
4. Rate limiting — 20 generations/user/24h

### Pending Upgrade: Haiku → Sonnet (`claude-sonnet-4-20250514`)

Rewritten files ready but NOT deployed:
- `outputs/ai_generator.ts` — All 4 generation prompts hardened: structured system prompts, temperature 0.2-0.3, explicit JSON schema with field constraints, category definitions, `{"error":"invalid"}` for bad queries, full runtime `validateHobbyOutput()` function
- `outputs/action.ts` — Full `[action].ts` replacement with Sonnet coach: single-mode injection (model only sees one mode), roadmap annotated with ✓/← CURRENT, 9 hard rules with exact phrasing, temperature 0.5, `UserCompletedStep.count()` for progress, `lastActivityAt` for stale detection

**To deploy:** Replace `server/lib/ai_generator.ts` and `server/api/generate/[action].ts` with the output files. Same API key works.

---

## Design System — "Warm Cinematic Minimalism"

### Color Palette (`lib/theme/app_colors.dart`)
| Token | Hex | Usage |
|-------|-----|-------|
| background | `#0A0A0F` | Deep black |
| surface | `#111116` | Barely lighter |
| surfaceElevated | `#1A1A20` | Cards |
| textPrimary | `#F5F0EB` | Warm cream (NOT pure white) |
| textSecondary | `#B0A89E` | Warm gray (body text) |
| textMuted | `#6B6360` | Warm dark gray (metadata) |
| textWhisper | `#3D3835` | Barely visible |
| accent | `#FF6B6B` | Coral — CTAs ONLY |
| success | `#06D6A0` | Completed steps only |
| glass | `#15FFFFFF` | White at 8% (glass surfaces) |
| glassBorder | `#20FFFFFF` | White at 12% |

Legacy aliases (amber, indigo, category colors) exist in AppColors but ALL map to warm grays. Do not reintroduce colors.

### Typography (`lib/theme/app_typography.dart`)
| Style | Font | Size | Weight |
|-------|------|------|--------|
| hero | Source Serif 4 | 36pt | 700 |
| display | Source Serif 4 | 28pt | 600 |
| title | Source Serif 4 | 20pt | 600 |
| body | DM Sans | 15pt | 400 |
| caption | DM Sans | 12pt | 500 |
| dataLarge | IBM Plex Mono | 48pt | — |

### Key Rules
- **Glass cards** everywhere — white 8% bg, 12% border, blur for static, no-blur for lists
- **Floating glass dock** — 3 icons, no labels, 28px radius, 40px margins
- **One coral CTA per screen** — everything else secondary
- **Spec badges** — single warm gray line: `CHF X · Xh/week · Easy`
- **Motion** — staggered fade-up (400ms/100ms), scale 0.97 on press, crossfade tabs

### Voice
**Use:** "Start gently" / "Try the easy version" / "Keep it simple" / "Small progress counts"
**Don't:** "Crush it" / "Unlock everything" / "Level up" / "Become your best self"

---

## Session Screen (`lib/screens/session/`)

Full-screen immersive. No app bar, no bottom nav. 4 phases managed by `SessionNotifier`:

| Phase | File | Lines | Purpose |
|-------|------|-------|---------|
| Prepare | `session_prepare_phase.dart` | 221 | What you need, instructions, "Start" CTA |
| Timer | `session_timer_phase.dart` | 503 | Particle formation timer (250 particles → category shape) |
| Reflect | `session_reflect_phase.dart` | 418 | Journal prompts: what worked, what was hard |
| Complete | `session_complete_phase.dart` | 102 | Celebration, next step preview |

### Completion Modes (`models/session.dart`)
- **Timer** (default): 15-min, must complete before reflecting
- **Photo proof** (Pro, creative): timer + photograph result
- **Check-in** (setup steps): hold button 2.5 seconds

### Key Components
- `particle_timer_painter.dart` — CustomPainter, 250 particles → PathMetric convergence
- `category_shape_painter.dart` — 9 shapes (vase/mountains/yoga/hands/clef/bowl/gem/eye/figures)
- `radial_hold_painter.dart` — Hold-to-complete ring
- `session_glow_widget.dart` — Ambient glow

---

## Business Model

### Free Tier
All 150+ hobbies, roadmaps, starter kits. One active hobby. AI coach 3 msg/month. Text journal. Affiliate buy links.

### TrySomething Pro (CHF 4.99/month or CHF 39.99/year)
Unlimited AI coach. Photo journal. Multi-hobby. 30-day guided support + rescue mode. 7-day free trial via RevenueCat, entitlement: `pro`.

---

## Brand Identity

- **App Icon:** Coral brushstroke "T" on `#0A0A0F` — `assets/icon/app_icon.png`
- **Wordmark:** "TrySomething" Source Serif 4, "Try" coral, "Something" warm cream
- **Tagline:** "Stop scrolling. Start something."

---

## Known Issues & Missing Pieces

1. **No account deletion endpoint** — App store requirement. Need `DELETE /api/users/me` with cascading deletes.
2. **No data export endpoint** — FADP Art. 28 requires portability. Need `GET /api/users/me/export` → JSON.
3. **AI still on Haiku** — Sonnet upgrade files ready, not deployed.
4. **Coach stale detection** — Current code uses `startedAt` for days-since. Should use `lastActivityAt` (fixed in upgrade files).
5. **Terms & Privacy** — .docx files generated, need hosting + in-app linking.
6. **No Apple auth in vercel.json** — Route exists for `google` but `apple` not in the regex: `(register|login|refresh|google)`. Add `|apple`.

---

## Testing

```bash
# After each task
dart analyze lib/path/to/changed_files.dart

# After each sprint
flutter analyze
dart test

# Server
cd server && npm test
```

37 test files: 5 golden, 12 unit (core/models/providers/repositories), 8 widget (components + screens).

---

## Reference Docs

| File | Purpose |
|------|---------|
| `CLAUDE.md` | This file — primary context |
| `CLAUDE_TASKS_v5.md` | Sprint task checklist |
| `PRODUCT_GUARDRAILS.md` | Design principles |