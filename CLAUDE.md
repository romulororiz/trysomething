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

<!-- gitnexus:start -->
# GitNexus — Code Intelligence

This project is indexed by GitNexus as **trysomething** (1008 symbols, 1741 relationships, 51 execution flows). Use the GitNexus MCP tools to understand code, assess impact, and navigate safely.

> If any GitNexus tool warns the index is stale, run `npx gitnexus analyze` in terminal first.

## Always Do

- **MUST run impact analysis before editing any symbol.** Before modifying a function, class, or method, run `gitnexus_impact({target: "symbolName", direction: "upstream"})` and report the blast radius (direct callers, affected processes, risk level) to the user.
- **MUST run `gitnexus_detect_changes()` before committing** to verify your changes only affect expected symbols and execution flows.
- **MUST warn the user** if impact analysis returns HIGH or CRITICAL risk before proceeding with edits.
- When exploring unfamiliar code, use `gitnexus_query({query: "concept"})` to find execution flows instead of grepping. It returns process-grouped results ranked by relevance.
- When you need full context on a specific symbol — callers, callees, which execution flows it participates in — use `gitnexus_context({name: "symbolName"})`.

## When Debugging

1. `gitnexus_query({query: "<error or symptom>"})` — find execution flows related to the issue
2. `gitnexus_context({name: "<suspect function>"})` — see all callers, callees, and process participation
3. `READ gitnexus://repo/trysomething/process/{processName}` — trace the full execution flow step by step
4. For regressions: `gitnexus_detect_changes({scope: "compare", base_ref: "main"})` — see what your branch changed

## When Refactoring

- **Renaming**: MUST use `gitnexus_rename({symbol_name: "old", new_name: "new", dry_run: true})` first. Review the preview — graph edits are safe, text_search edits need manual review. Then run with `dry_run: false`.
- **Extracting/Splitting**: MUST run `gitnexus_context({name: "target"})` to see all incoming/outgoing refs, then `gitnexus_impact({target: "target", direction: "upstream"})` to find all external callers before moving code.
- After any refactor: run `gitnexus_detect_changes({scope: "all"})` to verify only expected files changed.

## Never Do

- NEVER edit a function, class, or method without first running `gitnexus_impact` on it.
- NEVER ignore HIGH or CRITICAL risk warnings from impact analysis.
- NEVER rename symbols with find-and-replace — use `gitnexus_rename` which understands the call graph.
- NEVER commit changes without running `gitnexus_detect_changes()` to check affected scope.

## Tools Quick Reference

| Tool | When to use | Command |
|------|-------------|---------|
| `query` | Find code by concept | `gitnexus_query({query: "auth validation"})` |
| `context` | 360-degree view of one symbol | `gitnexus_context({name: "validateUser"})` |
| `impact` | Blast radius before editing | `gitnexus_impact({target: "X", direction: "upstream"})` |
| `detect_changes` | Pre-commit scope check | `gitnexus_detect_changes({scope: "staged"})` |
| `rename` | Safe multi-file rename | `gitnexus_rename({symbol_name: "old", new_name: "new", dry_run: true})` |
| `cypher` | Custom graph queries | `gitnexus_cypher({query: "MATCH ..."})` |

## Impact Risk Levels

| Depth | Meaning | Action |
|-------|---------|--------|
| d=1 | WILL BREAK — direct callers/importers | MUST update these |
| d=2 | LIKELY AFFECTED — indirect deps | Should test |
| d=3 | MAY NEED TESTING — transitive | Test if critical path |

## Resources

| Resource | Use for |
|----------|---------|
| `gitnexus://repo/trysomething/context` | Codebase overview, check index freshness |
| `gitnexus://repo/trysomething/clusters` | All functional areas |
| `gitnexus://repo/trysomething/processes` | All execution flows |
| `gitnexus://repo/trysomething/process/{name}` | Step-by-step execution trace |

## Self-Check Before Finishing

Before completing any code modification task, verify:
1. `gitnexus_impact` was run for all modified symbols
2. No HIGH/CRITICAL risk warnings were ignored
3. `gitnexus_detect_changes()` confirms changes match expected scope
4. All d=1 (WILL BREAK) dependents were updated

## Keeping the Index Fresh

After committing code changes, the GitNexus index becomes stale. Re-run analyze to update it:

```bash
npx gitnexus analyze
```

If the index previously included embeddings, preserve them by adding `--embeddings`:

```bash
npx gitnexus analyze --embeddings
```

To check whether embeddings exist, inspect `.gitnexus/meta.json` — the `stats.embeddings` field shows the count (0 means no embeddings). **Running analyze without `--embeddings` will delete any previously generated embeddings.**

> Claude Code users: A PostToolUse hook handles this automatically after `git commit` and `git merge`.

## CLI

| Task | Read this skill file |
|------|---------------------|
| Understand architecture / "How does X work?" | `.claude/skills/gitnexus/gitnexus-exploring/SKILL.md` |
| Blast radius / "What breaks if I change X?" | `.claude/skills/gitnexus/gitnexus-impact-analysis/SKILL.md` |
| Trace bugs / "Why is X failing?" | `.claude/skills/gitnexus/gitnexus-debugging/SKILL.md` |
| Rename / extract / split / refactor | `.claude/skills/gitnexus/gitnexus-refactoring/SKILL.md` |
| Tools, resources, schema reference | `.claude/skills/gitnexus/gitnexus-guide/SKILL.md` |
| Index, status, clean, wiki CLI commands | `.claude/skills/gitnexus/gitnexus-cli/SKILL.md` |

<!-- gitnexus:end -->

<!-- GSD:project-start source:PROJECT.md -->
## Project

**TrySomething**

A mobile app for overwhelmed adults who want to pick up a hobby but don't know where to start. TrySomething matches users to one hobby based on their preferences, provides a structured 30-day guided start with step-by-step roadmaps, and offers AI coaching to keep them going. Built with Flutter (frontend) and Node.js/TypeScript on Vercel (backend), backed by Neon PostgreSQL and Claude AI.

**Core Value:** A user can discover a hobby that fits them, start it with clear first steps, and stick with it for 30 days through guided support and coaching.

### Constraints

- **App Store compliance:** Apple requires account deletion (mandatory since 2022). Google Play requires it for apps with accounts.
- **FADP (Swiss data protection):** Art. 28 requires data portability — users must be able to export their data.
- **RevenueCat:** Entitlement ID is `pro`. Webhook verification needed before production traffic.
- **AI model:** Sonnet upgrade files ready — same API key, drop-in replacement for Haiku.
- **Budget:** Solo developer, cost-conscious — Vercel free tier, Neon free tier.
- **Tech stack:** Flutter + Node.js/Vercel — no stack changes in this milestone.
<!-- GSD:project-end -->

<!-- GSD:stack-start source:codebase/STACK.md -->
## Technology Stack

## Languages
- Dart 3.6.0+ - Flutter frontend application
- TypeScript 5.7.2 - Node.js backend on Vercel Serverless
- Swift - iOS native code (xcode build output)
- Kotlin - Android native code (gradle, CMake)
## Runtime
- Flutter 3.6.0 - Cross-platform mobile framework (iOS/Android)
- Node.js - Backend runtime on Vercel Serverless Functions (@vercel/node 5.0.2)
- Dart VM - Dart code execution
- pub - Dart/Flutter package manager (pubspec.yaml)
- npm - JavaScript package manager (package.json)
## Frameworks
- flutter_riverpod 2.6.1 - Reactive state management
- riverpod_annotation 2.6.1 - Code generation for Riverpod
- riverpod_generator 2.6.2 - Build runner provider generation
- go_router 14.8.1 - Declarative routing with GoRouter
- Flutter Material Design - Material Design framework (included with Flutter)
- google_fonts 6.2.1 - Dynamic font loading (Source Serif 4, DM Sans, IBM Plex Mono)
- flutter_animate 4.5.2 - Animation builder for entrance/transition effects
- timelines_plus 1.0.0 - Timeline/roadmap UI widget
- freezed 2.5.7 - Immutable data classes with equality
- freezed_annotation 2.4.4 - Freezed annotations
- json_serializable 6.9.0 - JSON to/from Dart serialization
- json_annotation 4.9.0 - JSON serialization annotations
- build_runner 2.4.14 - Dart code generation orchestration
- flutter_launcher_icons 0.14.3 - App icon generation for iOS/Android
- @vercel/node 5.0.2 - Vercel serverless Node.js functions
- No express.js - Raw handler functions in `/api/**/*.ts` routed by vercel.json
- Prisma 6.4.1 - TypeScript ORM with automatic migrations
- @prisma/client 6.4.1 - Database client
- PostgreSQL (Neon) - Relational database via CONNECTION_URL environment variable
- bcryptjs 2.4.3 - Password hashing (12 rounds)
- jsonwebtoken 9.0.2 - JWT token generation/verification
- vitest 3.0.0 - Fast unit test runner for server code
- @types/* - TypeScript type definitions for build tooling
## Key Dependencies
- @anthropic-ai/sdk 0.78.0 - Claude API integration for hobby generation (see INTEGRATIONS.md)
- purchases_flutter 9.14.0 / purchases_ui_flutter 9.14.0 - RevenueCat SDK for in-app subscriptions
- firebase_core 3.12.1 - Firebase initialization
- firebase_messaging 15.2.4 - Firebase Cloud Messaging for push notifications
- posthog_flutter 4.0.0 - Event analytics and session tracking
- sentry_flutter 9.14.0 - Error tracking and crash reporting
- dio 5.7.0 - HTTP client with interceptors for API calls
- cached_network_image 3.4.1 - Image caching with network fallback
- image_picker 1.1.2 - Native image/gallery picker
- hive_flutter 1.1.0 + hive 2.2.3 - Local encrypted key-value storage for offline cache
- shared_preferences 2.3.4 - Simple persistent key-value storage
- google_sign_in 6.2.2 - Google OAuth integration
- sign_in_with_apple 6.1.4 - Apple Sign-In integration
- crypto 3.0.6 - Cryptographic utilities for auth flows
- flutter_secure_storage 9.2.4 - Secure token and credential storage (platform native)
- flutter_local_notifications 18.0.1 - Local notification scheduling
- wakelock_plus 1.2.1 - Keep screen awake during session timer
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
- `POSTHOG_API_KEY` - Analytics API key (defaults to project key)
- `POSTHOG_HOST` - PostHog ingestion endpoint
- `GOOGLE_SERVER_CLIENT_ID` - OAuth server-to-server ID
- `APPLE_SERVICE_ID` - Apple Sign-In service identifier
- `REVENUECAT_API_KEY` - RevenueCat SDK key (platform-specific)
- `DATABASE_URL` - Neon PostgreSQL connection string (required)
- `ANTHROPIC_API_KEY` - Claude API key for hobby generation (required)
- `UNSPLASH_ACCESS_KEY` - Unsplash API key for image search (optional, uses fallbacks if missing)
- `JWT_SECRET` - Secret for signing/verifying JWT tokens (required)
- `pubspec.yaml` - Flutter dependencies, version, assets configuration
- `server/package.json` - Node.js dependencies and scripts
- `server/tsconfig.json` - TypeScript compiler options (standard Node.js config)
- `vercel.json` - Vercel Functions routing, build config
- `firebase.json` - Firebase initialization config (Cloud Messaging)
- `analysis_options.yaml` - Dart linter rules
- `build.yaml` - Custom build step configuration
- `android/app/build.gradle` - Android build config (NDK, version)
- `ios/Podfile` - CocoaPods dependencies (iOS native)
- `flutter_launcher_icons` config in pubspec.yaml
## Platform Requirements
- Dart SDK 3.6.0+ (via Flutter)
- Flutter 3.6.0 (via fvm or flutter cli)
- Android SDK 34+ (for Android builds)
- iOS 12+ (for iOS builds, Xcode 15+)
- Node.js 18+ (for server development)
- npm 9+ (for server packages)
- TypeScript 5.7+ (installed via npm)
- Vercel CLI (optional, for local development)
- iOS app deployed to Apple App Store (requires TestFlight or direct release)
- Android app deployed to Google Play Store
- Backend hosted on Vercel Serverless Functions (automatic scaling)
- Database: Neon PostgreSQL (managed, auto-backups)
<!-- GSD:stack-end -->

<!-- GSD:conventions-start source:CONVENTIONS.md -->
## Conventions

## Naming Patterns
- Snake case: `hobby_card.dart`, `auth_provider.dart`, `discover_feed_screen.dart`
- Class files match class name: `HobbyCard` lives in `hobby_card.dart`
- Repository interfaces and implementations: `hobby_repository.dart` (abstract), `hobby_repository_api.dart` (implementation)
- Notifier classes: `*_notifier.dart` (e.g., `user_hobbies_notifier_test.dart`)
- camelCase: `getHobbies()`, `saveHobby()`, `toggleStep()`, `buildImage()`
- Private functions prefixed with underscore: `_extractError()`, `_buildBottomContent()`, `_load()`
- Async functions explicitly return `Future`: `Future<Hobby?> getHobbyById(String id)`
- camelCase: `_pageController`, `selectedCategory`, `isSaved`, `mockRepo`
- Private fields prefixed with underscore: `_prefs`, `_repo`, `_currentIndex`, `_showSwipeHint`
- Late variables: `late SharedPreferences prefs;`, `late PageController _pageController;`
- Final constants for class-level keys: `static const _key = 'user_hobbies';`
- PascalCase: `UserHobby`, `HobbyStatus`, `AuthState`, `AuthNotifier`
- Enums: PascalCase with lowercase values: `enum AuthStatus { unknown, unauthenticated, loading, authenticated }`
- Model classes: Always use `@freezed` with `part 'file.freezed.dart';` and `part 'file.g.dart';`
- Global constants: UPPER_SNAKE_CASE when they are configuration values (e.g., `SALT_ROUNDS = 12`)
- Token system values in `app_colors.dart`: camelCase (e.g., `coral`, `warmWhite`, `nearBlack`)
- No raw hex colors in screens — always use `AppColors.*`, `AppTypography.*`, `Spacing.*`, `Motion.*`
## Code Style
- Tool: `flutter analyze lib/` enforces style
- Line length: Wrapped for readability (no strict limit enforced)
- Indentation: 2 spaces (Flutter standard)
- Use `const` constructors where possible (linter rule: `prefer_const_constructors`)
- Use `const` declarations where possible (linter rule: `prefer_const_declarations`)
- Tool: `flutter_lints` package (configured in `analysis_options.yaml`)
- Rules enforced:
- Imports grouped in order:
- Section comments: `// ═══════════════════════════════════` separate logical sections (see `lib/main.dart` lines 262-266)
- Class documentation comments: `///` precedes each public class/function (see `lib/theme/app_colors.dart` lines 1-8)
- One import per line, no wildcard imports
- Imports at top, grouped:
- Strict type imports: `import type { VercelRequest } from "@vercel/node";`
- Section comments: `// ── Name ─────────────────────────` separate endpoints/functions
- Function comments above handlers: standard JSDoc style
- 2-space indentation, semicolons required
## Import Organization
- Dart: No path aliases configured (all relative imports)
- TypeScript (server): `@lib/*` maps to `lib/*` in `tsconfig.json`
- Always explicit: `import 'package:flutter_riverpod/flutter_riverpod.dart';`
- Not: `import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;`
## Error Handling
- Try/catch in notifiers for API calls — see `lib/providers/auth_provider.dart` lines 87–111
- Catch-all exception handler that uses `_extractError()` to convert to user-facing messages
- For Dio exceptions: Check `e.response?.statusCode` and `e.response?.data` for error details
- Optimistic updates with rollback: Update state immediately, then rollback on API failure with `debugPrint`
- Never silently swallow errors — always log with `debugPrint` when rolling back state
- Sentry error reporting in `lib/core/error/error_reporter.dart` (lines 35-59) captures exceptions with context
## Logging
- Use brackets for scoping: `debugPrint('[GoogleAuth] Attempting sign-in...');`
- Log before long operations: `debugPrint('[GoogleAuth] Calling server...');`
- Log success and failure: `debugPrint('[GoogleAuth] Success!');`
- For errors, include type and stack:
- Separator lines for major errors (see `lib/main.dart` lines 50-58):
- No centralized logger configured
- Use `console.log()` if needed (will appear in Vercel logs)
- Not required for normal operations
## Comments
- Public methods and classes: Always document with `///`
- Complex algorithms: Explain the "why", not the "what"
- Gotchas and platform-specific behavior: Note workarounds (see `lib/main.dart` lines 47-52 for kIsWeb checks)
- Section headers: Use separator comments to group related code (see `lib/main.dart` lines 262-266)
- Dart: Use `///` for public APIs:
- TypeScript: Use JSDoc `/**  */`:
## Function Design
- Target: 20–50 lines per function (smaller is better)
- Larger functions: Break into named helper functions (e.g., `_buildImage()`, `_buildBottomContent()`)
- Private helpers use underscore prefix
- Use named parameters for functions with 2+ parameters: `Future<bool> login({required String email, required String password})`
- Positional parameters only for single, obvious parameters: `void complete()`
- Always mark required params: `required String hobbyId`
- Default values for optional params: `{int limit = 3}`
- Explicit return types (no `var` or `dynamic`): `Future<List<Hobby>>`, `Map<String, UserHobby>`, `bool`
- Nullable returns marked with `?`: `Future<Hobby?>`, `String?`
- Async functions return `Future`: `Future<void>` for fire-and-forget
## Module Design
- Repository pattern: Abstract interface in `lib/data/repositories/hobby_repository.dart`, implementation in `lib/data/repositories/hobby_repository_api.dart`
- Notifiers: Exported as class + provider in single file (e.g., `lib/providers/auth_provider.dart`)
- Models: `@freezed` classes with `fromJson`/`toJson` methods in single file (e.g., `lib/models/hobby.dart`)
- Not used in this codebase
- All imports are explicit
## Widget Conventions
- Use `GlassCard` widget everywhere, not manual containers
- `blur: true` only for max 3-5 static/hero elements per screen (uses BackdropFilter, performance-conscious)
- `blur: false` (default) for scrollable lists, safe at 60fps
- Scale animation to 0.97 on press when `onTap` provided
- Never hardcode glass colors — use `AppColors.glassBackground` and `AppColors.glassBorder`
- Never hardcode colors: Use `AppColors.coral`, `AppColors.driftwood`, `AppColors.textPrimary`
- Never hardcode spacing: Use `Spacing.md`, `Spacing.lg`
- Never hardcode animations: Use `Motion.fast`, `Motion.normal`
- Exception: Hardcoded `Colors.white` for text on overlays is intentional (100+ usages, DO NOT convert to tokens)
## Server TypeScript Conventions
- Validate inputs before database operations
- Check for required fields: `if (!email || !password)`
- Type-check strings: `if (typeof password !== "string")`
- Return early with `errorResponse()` if validation fails
<!-- GSD:conventions-end -->

<!-- GSD:architecture-start source:ARCHITECTURE.md -->
## Architecture

## Pattern Overview
- **Repository Pattern** — Data sources abstracted via repositories; implementations can swap between API, Hive cache, and seed data
- **Riverpod State Management** — Functional reactive programming; providers auto-dispose when no widgets listen, composable for complex state
- **Layered Backend** — Vercel serverless functions → business logic (AI generation, auth, mappers) → Prisma ORM → Neon PostgreSQL
- **Session State Machine** — Four-phase immersive session (prepare → timer → reflect → complete) managed via SessionNotifier with DateTime-based timer survival
- **JWT Auth Flow** — 15-min access token + 30-day refresh token, plus OAuth (Google/Apple) + RevenueCat subscriptions
- **Offline-First Caching** — API responses cached in Hive; stale cache returned on network error; seed data as emergency fallback
## Layers
- Purpose: Render screens, handle user interaction, display state reactively
- Location: `lib/screens/`, `lib/components/`
- Contains: ConsumerStatefulWidgets, ConsumerWidgets, custom painters (particle timer, category shapes, glows), glass card system
- Depends on: Riverpod providers, GoRouter, theme tokens
- Used by: App routing, main shell navigation
- Purpose: Cache state, compute derived values, react to data changes
- Location: `lib/providers/`
- Contains: StateNotifiers (auth, session, hobbies, journal), FutureProviders (async data), Computed providers (derived state like isProProvider)
- Depends on: Repositories, external services (analytics, subscriptions), models
- Used by: All screens and components via `ref.watch()`
- Key pattern: Providers auto-dispose when no listeners; cascade updates on auth success
- Purpose: Services, algorithms, orchestration (no UI, no external I/O on client side)
- Location: `lib/core/` (client) + `server/lib/` (backend)
- Client: `lib/core/auth/` (JWT handling, token refresh), `lib/core/notifications/` (FCM + local scheduling), `lib/core/subscription/` (RevenueCat), `lib/core/analytics/`, `lib/core/media/`, `lib/core/error/` (Sentry)
- Server: `lib/ai_generator.ts` (Claude Haiku prompts), `lib/auth.ts` (bcrypt, JWT crypto), `lib/mappers.ts` (response transformation), `lib/content_guard.ts` (input validation, blocklist), `lib/gamification.ts`
- Depends on: Models, external SDKs, Prisma client
- Used by: Providers, repositories, API handlers
- Purpose: Unified interface to data sources with pluggable backends
- Location: `lib/data/repositories/`
- Contains: Repository interfaces (abstract), API implementations (Dio calls), optional Hive fallbacks
- Depends on: ApiClient (Dio), LocalStorage (Hive), Prisma models (server)
- Used by: Riverpod providers via repository_providers.dart DI
- Pattern: Abstract → API impl → optional cache impl (for read-heavy features)
- Purpose: Immutable, serializable data structures
- Location: `lib/models/`, `server/prisma/schema.prisma`
- Flutter: Freezed-generated with copyWith, fromJson/toJson, equality
- Server: Prisma models (25 tables across 9 domains)
- Domains: Content (Hobby, Category, KitItem, RoadmapStep, FaqItem), Auth (User, UserPreference), Progress (UserHobby, UserCompletedStep), Personal Tools (JournalEntry, PersonalNote, ScheduleEvent, ShoppingCheck), Social (CommunityStory, StoryReaction, BuddyPair), Gamification (UserChallenge, UserAchievement), AI (GenerationLog)
## Data Flow
## Key Abstractions
- Purpose: Encapsulates complete session lifecycle without coupling to UI
- Location: `lib/providers/session_provider.dart`
- Pattern: StateNotifier<SessionState?> with internal Timer, DateTime-based elapsed time calculation
- Key methods: `startSession()`, `beginTimer()`, `pauseTimer()`, `resumeTimer()`, `completeReflection()`
- Manages: Wakelock, haptic feedback timing, pause/resume duration tracking
- Purpose: Abstract data access, enable offline caching
- Location: `lib/data/repositories/`
- Pattern: Abstract interface → API implementation → optional Hive fallback
- Example: `hobby_repository.dart` (interface) → `hobby_repository_api.dart` (API + Hive) → provided via DI
- Retry logic: Built into API layer; if network error, returns Hive cache
- Purpose: Transparent JWT token management
- Location: `lib/core/auth/auth_interceptor.dart`
- Pattern: Dio interceptor that (1) adds Authorization header to all requests, (2) catches 401, (3) calls refresh endpoint, (4) retries original request
- No exponential backoff (single retry)
- Purpose: Transform Prisma models → API response DTOs
- Location: `server/lib/mappers.ts`
- Pattern: Pure functions, one per entity type (mapUserWithPreferences, mapHobbyDetail, etc.)
- Strips sensitive fields (passwordHash, tokens)
- Purpose: Multi-layer safety (input validation, AI constraints, output validation, rate limiting)
- Location: `server/lib/content_guard.ts`
- Layers:
## Entry Points
- Location: `lib/main.dart`
- Triggers: `flutter run` (app startup)
- Responsibilities:
- Location: `lib/router.dart` → `routerProvider` Riverpod provider
- Triggers: Route navigation, auth state changes, onboarding completion
- Responsibilities:
- Location: `lib/screens/main_shell.dart`
- Triggers: After auth + onboarding complete
- Responsibilities:
- Location: `lib/screens/home/home_screen.dart`
- Triggers: User taps home icon or `ref.read(authProvider).status == authenticated`
- Responsibilities:
- Location: `lib/screens/session/session_screen.dart` (coordinator) + phase files
- Triggers: User taps "Start session" on a hobby step
- Responsibilities:
- Location: `server/api/auth/[action].ts` (dynamic routing)
- Triggers: HTTP POST `/api/auth/{action}` (register, login, refresh, google, apple)
- Responsibilities:
- Location: `server/api/users/[path].ts` (consolidated handler)
- Triggers: HTTP GET/POST/PUT to `/api/users/*`
- Responsibilities:
## Error Handling
- **Sentry Integration:** `lib/core/error/error_reporter.dart` captures unhandled exceptions + stack traces; `ErrorReporterObserver` watches Riverpod for provider failures
- **Provider Errors:** AsyncValue<T> in all FutureProviders; screens check `.when(data: ..., error: ..., loading: ...)`
- **Network Fallback:** ApiClient catches DioException → HobbyRepository falls back to Hive cache → if cache miss, returns empty/null with UI message
- **User Messages:** `AuthNotifier._extractError()` maps HTTP status codes to readable strings:
- **Server Validation:** All endpoints validate input, return structured error:
## Cross-Cutting Concerns
- Client: `debugPrint('[ComponentName]')` with context prefix (e.g., `[Session] Timer started`)
- Server: `console.error()` with endpoint context (e.g., `POST /api/users/hobbies error:`)
- Production: Sentry + PostHog; console logs for dev only
- Client: Freezed models enforce type safety; TextFields validate before submission
- Server: Content guard blocklist (4-layer), Prisma constraints (unique, non-null, enums)
- JWT: 15-min access token (short-lived) + 30-day refresh token (long-lived)
- Storage: Secure Hive (platform-specific encryption)
- Injection: AuthInterceptor adds `Authorization: Bearer {token}` to all requests
- Refresh: 401 triggers `POST /api/auth/refresh` with refresh token
- Verify: Server validates JWT signature + expiry
- Single-user model: No role-based access control
- Events tracked: registration, login, hobby_start, hobby_abandoned, session_complete, coach_message, upgrade_view, purchase, day_3_return, day_7_return
- User context: userId set on auth, sessionId generated per app launch
- Metadata: hobby_id, completion_time, reflection_type, coach_mode
- Observer: AnalyticsObserver in router tracks screen views automatically
- FCM (Firebase Cloud Messaging): Token synced to server after auth
- Scheduler: `NotificationScheduler` reschedules when hobby state changes
- Triggers: Inactivity-based re-engagement (1 day for trying, 3 days for active)
- Local: `NotificationService` via `flutter_local_notifications`
<!-- GSD:architecture-end -->

<!-- GSD:workflow-start source:GSD defaults -->
## GSD Workflow Enforcement

Before using Edit, Write, or other file-changing tools, start work through a GSD command so planning artifacts and execution context stay in sync.

Use these entry points:
- `/gsd:quick` for small fixes, doc updates, and ad-hoc tasks
- `/gsd:debug` for investigation and bug fixing
- `/gsd:execute-phase` for planned phase work

Do not make direct repo edits outside a GSD workflow unless the user explicitly asks to bypass it.
<!-- GSD:workflow-end -->

<!-- GSD:profile-start -->
## Developer Profile

> Profile not yet configured. Run `/gsd:profile-user` to generate your developer profile.
> This section is managed by `generate-claude-profile` -- do not edit manually.
<!-- GSD:profile-end -->
