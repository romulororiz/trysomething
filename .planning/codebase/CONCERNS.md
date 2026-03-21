# Codebase Concerns

**Analysis Date:** 2026-03-21

---

## Missing Critical Compliance Endpoints

**Account Deletion (GDPR/App Store Requirement):**
- Issue: No `DELETE /api/users/me` endpoint exists. App store submission requires account deletion capability.
- Files: `./server/api/users/[path].ts` (only supports GET, PUT on line 94)
- Impact: Cannot submit to app stores; users cannot comply with data deletion requests; legal exposure
- Fix approach: Implement `DELETE /api/users/me` with cascading deletes across all user-related tables (UserHobby, JournalEntry, PersonalNote, ScheduleEvent, ShoppingCheck, CommunityStory, StoryReaction, BuddyPair, UserChallenge, UserAchievement, UserActivityLog, UserPreference), then delete User record. Store deletion timestamp for audit.

**Data Export (FADP Article 28 Data Portability):**
- Issue: No `GET /api/users/me/export` endpoint for user data portability
- Files: `./server/api/users/[path].ts`
- Impact: Cannot comply with data portability regulations; users cannot export their data in portable format
- Fix approach: Implement `GET /api/users/me/export` returning JSON with all user data: profile, preferences, hobbies (saved/active/done), journal entries, personal notes, schedule events, shopping checks, challenges, achievements, activity log. Return as JSON lines or ZIP with structured folders.

---

## API Routing Configuration Incomplete

**Apple Sign-In Route Missing from Vercel Regex:**
- Issue: `server/vercel.json` line 11 has regex `(register|login|refresh|google)` — `apple` action exists in `./server/api/auth/[action].ts` line 36 but is not routed
- Files: `./server/vercel.json` line 11
- Impact: Apple OAuth sign-in route returns 404 error; Apple authentication flows fail
- Fix approach: Update regex to `(register|login|refresh|google|apple)` — single character change, critical for Apple Sign-In users

---

## AI System Incomplete Upgrade

**Haiku → Sonnet Migration Status Unclear:**
- Issue: `./server/lib/ai_generator.ts` line 20 shows `const MODEL = "claude-sonnet-4-6"` but CLAUDE.md indicates upgrade "not yet deployed"
- Files: `./server/lib/ai_generator.ts` (model constant), `./server/api/generate/[action].ts` (generation handler)
- Impact: Unclear if production uses Sonnet or Haiku; AI quality inconsistent; cannot validate if upgrade successful
- Fix approach: Verify actual model running in production via API logs; if still Haiku, deploy `outputs/ai_generator.ts` and `outputs/action.ts` files with Sonnet prompts, structured output, temperature 0.2-0.3

**Coach Stale Detection Uses Wrong Field:**
- Issue: Coach system prompt builder uses `startedAt` to calculate days inactive; should use `lastActivityAt` from `UserHobby` model
- Files: `./server/api/generate/[action].ts` (coach handler, system prompt construction), `./server/lib/ai_generator.ts` (coach prompt builder)
- Impact: Coach rescue/momentum mode activates at wrong times; stale detection inaccurate for users with gaps between sessions
- Fix approach: Update coach prompt builder to query `UserHobby.lastActivityAt` instead of `startedAt`; recalculate days-since-activity correctly; fixed in Sonnet upgrade files

---

## Large Monolithic Screen Components

**Screen Complexity — Difficult to Test and Maintain:**
- `./lib/screens/profile/profile_screen.dart` — 2,021 lines
- `./lib/screens/home/home_screen.dart` — 1,977 lines
- `./lib/screens/feed/discover_feed_screen.dart` — 1,813 lines
- `./lib/screens/settings/settings_screen.dart` — 1,564 lines
- `./lib/screens/you/you_screen.dart` — 1,346 lines

Files: Multiple in `./lib/screens/`
- Impact: High cognitive load; difficult to test components in isolation; regression risk when modifying; slow to evolve
- Fix approach: Extract logical sections into sub-components per Sprint M checklist (M.1-M.5 in CLAUDE_TASKS_v5.md):
  - Discover: extract top chrome, feed wrapper, card renderer, list renderer, filter logic, empty states
  - You: extract header, Active section, Saved section, Tried section, utility rows
  - Search: extract chrome, suggestions, result groups, cards
  - Detail: extract hero, quick-start, why-fits, roadmap, coach teaser, CTA area
  - Home: extract active hobby hero, next-step block, week plan, coach module, restart prompt

---

## Coach Message Rate Limiting in Hive Cache

**Per-Hobby Monthly Limits Not Persistent:**
- Issue: Coach message rate limiting stored only in Hive cache (`coach_limits` box), not in database
- Files: `./lib/screens/coach/hobby_coach_screen.dart` lines 72-79 (`_CoachLimitTracker` class)
- Impact: Limits reset if app uninstalled; Hive cache can corrupt; multi-device users bypass limits; no audit trail; no server-side enforcement
- Fix approach: Move rate limiting to database `GenerationLog` model; track per user per hobby per month server-side; validate before allowing coach message; add server-side limit check in `POST /api/generate/coach` handler; maintain Hive cache as client-side optimization only

---

## Hidden Feature Code Dead Weight

**Dead Code Still in Repository:**
- Issue: Seven secondary features hidden (routes removed from router.dart) but implementation code remains in codebase
- Files:
  - `./lib/screens/buddy_mode_screen.dart`
  - `./lib/screens/community_stories_screen.dart`
  - `./lib/screens/local_discovery_screen.dart`
  - `./lib/screens/year_in_review_screen.dart`
  - `./lib/screens/weekly_challenge_screen.dart`
  - `./lib/screens/mood_match_screen.dart`
  - `./lib/screens/seasonal_picks_screen.dart`
- Impact: Increases maintenance burden; confuses developer context; unused models/providers still referenced; makes codebase harder to understand; test coverage diluted
- Fix approach: Either delete entirely or move to `archived_features/` subdirectory; remove from `router.dart` (confirm routes not in active codebase); clean unused providers from `providers/` and models from `models/`; run `dart analyze` to find orphaned references

---

## Terms & Privacy Policy Not Deployed

**Legal Compliance Documentation Missing:**
- Issue: Terms of Service and Privacy Policy generated as .docx files but not hosted or linked in app
- Files: Not in codebase (generated externally, .docx format)
- Impact: App store submission will be rejected; GDPR/legal compliance gaps; users cannot review policies
- Fix approach: Convert .docx to HTML or markdown; host on company website or CDN; add deep links in `./lib/screens/settings/settings_screen.dart` (terms, privacy); ensure links appear in App Store and Google Play listings with correct localization

---

## Type Checking Not Part of Commit Process

**Missing Pre-commit Hooks for Code Quality:**
- Issue: `npm run lint` exists in `./server/package.json` line 9 but no Git hook enforces it; `flutter analyze` requires manual run
- Files: `./server/package.json` (server linting), `analysis_options.yaml` (Flutter linting)
- Impact: TypeScript type errors slip to production; Vercel deploys may fail; Flutter deprecated APIs used undetected
- Fix approach: Add Husky pre-commit hook to run `npm run lint` in `server/` directory; add hook for `flutter analyze` on changed `.dart` files; fail commit on lint errors

---

## Inconsistent Server Error Response Formats

**Error Handling Fragmentation:**
- Issue: API endpoints mix error response formats; some use `errorResponse()` helper, others may throw uncaught exceptions
- Files: `./server/api/auth/[action].ts` (mostly consistent), `./server/api/users/[path].ts` (multiple handlers with varied error responses)
- Impact: Client error handling complex; error payloads inconsistent in logs; difficult to add global error tracking
- Fix approach: Standardize all endpoints to use error response shape `{ error: string, message: string, statusCode: number }`; wrap all handlers with try-catch; route all errors through single `errorResponse()` middleware

---

## Offline-First Synchronization Fragile

**Fire-and-Forget API Calls with Rollback:**
- Issue: User progress updates use optimistic updates in SharedPreferences + fire-and-forget API calls with rollback on error, but app crash during sync can orphan local changes
- Files: `./lib/providers/user_provider.dart` (UserHobbiesNotifier), `./lib/providers/feature_providers.dart` (JournalNotifier, ScheduleNotifier)
- Impact: User loses progress if app crashes during sync; journal entries, schedule updates may not reach server
- Fix approach: Implement sync queue pattern — store pending changes in Hive with sync status (pending/synced); background sync worker retries pending changes; user sees "syncing" indicator; confirm sync success before allowing navigation

---

## Test Coverage Gaps

**Session State Machine Partially Tested:**
- Issue: Session provider (`./lib/providers/session_provider.dart`) has complex timer logic with pause/resume, but test coverage unclear
- Files: `./lib/providers/session_provider.dart` (lines 72-120 timer logic, pause/resume state machine)
- Impact: Timer bugs (pause drift, haptic timing misfire, wakelock not release) only caught in manual E2E testing
- Fix approach: Add unit tests for:
  - `SessionNotifier._tick()` timing accuracy
  - Pause/resume state transitions
  - Haptic feedback firing at correct times (halfway, 1-min remaining)
  - Timer completion triggers reflection phase
  - Wakelock enable/disable on timer start/stop

**Coach Message Limiting Not Tested:**
- Issue: Coach limit tracker (`_CoachLimitTracker` in `hobby_coach_screen.dart` lines 72-79) uses Hive cache with month-key rotation; no unit tests for boundary conditions
- Files: `./lib/screens/coach/hobby_coach_screen.dart` lines 72-79
- Impact: Month boundary bugs, year rollovers untested
- Fix approach: Extract `_CoachLimitTracker` to separate file `lib/core/coach_limit_tracker.dart`; add unit tests for:
  - Month-key generation (year_month format)
  - Increment logic
  - Month boundary reset (Dec→Jan)
  - Year rollover

**Free → Pro Coach Upgrade Flow Not Tested:**
- What's not tested: User hits free message limit, sees upgrade prompt, upgrades, resumes coach interaction
- Files: `./lib/screens/coach/hobby_coach_screen.dart` (limit checking), `./lib/components/pro_upgrade_sheet.dart` (upgrade flow), `./lib/providers/subscription_provider.dart` (Pro status)
- Risk: Pro upgrade conversion broken unnoticed; revenue impact; user abandonment
- Priority: High — critical monetization path

**Session Timer Under Memory Pressure Not Tested:**
- What's not tested: App backgrounding during session; wakelock + timer survival; memory warnings
- Files: `./lib/providers/session_provider.dart` (wakelock management), `./lib/screens/session/session_timer_phase.dart`
- Risk: Session lost mid-activity; poor UX for core feature; user frustration
- Priority: High — core user flow

---

## Security Considerations

**Password Validation Insufficient:**
- Risk: `./server/api/auth/[action].ts` line 55 only checks password length >= 8; no complexity requirements
- Current mitigation: bcryptjs with 12 rounds provides strong salting; tokens have expiration (15 min access, 30 day refresh)
- Recommendations:
  - Add complexity checks (at least one uppercase, one number, one symbol)
  - Implement rate limiting on login attempts (max 5 attempts per 15 minutes)
  - Log failed auth attempts for audit trail
  - Consider passwordless authentication (magic links) for better UX

**API Key Exposure Risk:**
- Risk: Anthropic API key in environment variables; no key rotation mechanism documented
- Files: `./server/lib/ai_generator.ts` line 15 reads `process.env.ANTHROPIC_API_KEY`
- Current mitigation: Vercel environment secrets encrypted at rest; API key not exposed in code or logs
- Recommendations:
  - Document API key rotation policy
  - Monitor API key usage for anomalies
  - Consider dedicated service account with scoped permissions
  - Add API key versioning if supported by Anthropic

**Content Blocklist Static:**
- Risk: `./server/lib/content_guard.ts` uses hardcoded blocklist; evolves only with code deployment
- Current mitigation: 4-layer defense (input validation, prompt constraints, output validation, rate limiting); AI model trained for safety
- Recommendations:
  - Add ML-based content moderation if AI-generated hobby content scales
  - Implement dynamic blocklist that can be updated without code deploy
  - Audit blocklist quarterly; add common abuse patterns

---

## Performance Bottlenecks

**Hardcoded Seed Data Limits Scalability:**
- Issue: 150+ hobbies in `./lib/models/seed_data.dart` embedded as Dart constants; new hobbies require code change and app release
- Files: `./lib/models/seed_data.dart`, `./server/prisma/seed-data/*.ts`
- Current capacity: 150+ hobbies
- Limit: Adding hobbies at >1 per release unsustainable
- Scaling path: Move hobby catalog to database; implement admin CMS for hobby management; client caches hobby list in Hive; server pushes updates via notification

**Unsplash API Rate Limiting:**
- Issue: Image search called synchronously during hobby generation; no response caching or request deduplication
- Files: `./server/lib/unsplash.ts`, `./server/api/generate/[action].ts`
- Current capacity: Unsplash free tier ~50 requests/hour
- Limit: Signup surge (many users generating hobbies simultaneously) hits rate limit
- Scaling path:
  - Pre-generate and cache images during hobby seed
  - Use CDN for image delivery (Cloudflare Images)
  - Implement exponential backoff for API retries
  - Migrate to paid Unsplash tier or self-hosted image service

**Coach Response Latency:**
- Issue: Coach endpoint calls Anthropic API synchronously; model inference 2-5 seconds typical; no response caching
- Files: `./server/api/generate/[action].ts` (coach handler)
- Impact: User perceives slow coach (2-5s wait); multiple taps cause duplicate requests
- Scaling path:
  - Add Redis caching for repeated coach queries (same hobby + mode + stage)
  - Implement request deduplication on server
  - Add loading state and retry UI on client
  - Consider async queuing for lower-priority coach requests

**Database Connection Pool Exhaustion:**
- Issue: Vercel serverless uses Prisma connection pooling; Neon free tier provides 100 connections
- Files: `./server/lib/db.ts` (Prisma singleton)
- Current capacity: 100 concurrent connections (Neon free tier)
- Limit: Concurrent users * connections per request may exhaust pool
- Scaling path:
  - Use Prisma PgBouncer for connection pooling
  - Implement connection pooling proxy (pgBouncer or similar)
  - Monitor connection pool usage; alert on >80% saturation
  - Migrate to Neon Pro tier (higher connection limits)

---

## Database Concerns

**Cascading Deletes Risk:**
- Issue: Multiple foreign keys with `onDelete: Cascade` in schema; no soft-delete pattern
- Files: `./server/prisma/schema.prisma` (KitItem, RoadmapStep, FaqItem, CostBreakdown, BudgetAlternative, etc. all cascade on Hobby delete)
- Impact: User account deletion will trigger cascading deletes across all related data; no audit trail; potential orphaned data if relationships inconsistent; data loss if bug in delete logic
- Safe modification: Before implementing DELETE /api/users/me, test cascade order in transaction; add audit table to track deletions with timestamp and reason

**Schema Evolution Without Migrations:**
- Issue: Prisma migrations stored in Neon, not committed to Git; no migration history in repo
- Files: Migrations in Neon database, not in `server/prisma/migrations/`
- Impact: Difficult to reproduce database state; rollback unclear; schema drift between environments
- Recommendations:
  - Commit migration history to Git: `prisma migrate resolve --rolled-back <migration_name>`
  - Document schema versioning strategy (version bumps with major releases)
  - Use Prisma Studio for safe exploration and debugging
  - Test migrations in staging before production deploy

---

## Deployment & Infrastructure Concerns

**Vercel Serverless Cold Starts:**
- Issue: First request to Vercel function after deploy may take 2-5 seconds
- Impact: User experiences slow coach response, slow hobby search on cold start after deploy
- Mitigation: Add keep-alive pings from client; pre-warm serverless functions after deploy; monitor cold start times in Sentry

**Prisma Query Performance Unmonitored:**
- Issue: No query optimization documentation or index analysis
- Files: `./server/prisma/schema.prisma` (schema), `./server/api/` (all query files)
- Impact: Complex queries (user hobbies + progress + coach context) may be slow as data grows
- Recommendations:
  - Add database indexes on frequently queried fields (userId, hobbyId, createdAt)
  - Monitor slow query logs in Neon
  - Use Prisma Studio to analyze query plans
  - Add query performance tests to catch regressions

---

## Fragile Areas — Safe Modification Guide

**Session Timer Particle Animation:**
- Files: `./lib/components/particle_timer_painter.dart` (643 lines), `./lib/screens/session/session_timer_phase.dart` (487 lines)
- Why fragile: CustomPainter with 250 particles, PathMetric convergence, timing-dependent animations, platform-specific rendering
- Safe modification:
  - Add unit tests for particle position calculations before editing
  - Test on physical device (Nothing Phone 3a) with performance profiler
  - Avoid changing tick frequency or particle spawn rate
  - Profile memory usage with DevTools
- Test coverage: Particle spawn logic, convergence math, category shape matching not unit tested

**Coach Message Mode Routing:**
- Files: `./lib/screens/coach/hobby_coach_screen.dart` (1,290 lines), `./server/api/generate/[action].ts`, `./server/lib/ai_generator.ts`
- Why fragile: Message limit tracking in Hive cache, mode-dependent response logic (Start/Momentum/Rescue), free/Pro gating, context injection from hobby/user state
- Safe modification:
  - Add database-backed rate limiting before scaling
  - Write tests for coach mode switching and context injection
  - Verify Pro entitlement check before launch
  - Test with various hobby states (new/active/stalled)
- Test coverage: Mode switching, free/Pro boundary, monthly reset logic not unit tested

**Onboarding Match Algorithm:**
- Files: `./lib/core/hobby_match.dart`, `./lib/screens/onboarding/match_results_screen.dart` (747 lines)
- Why fragile: Scoring logic depends on user answers; multiple factors (vibes, budget, hours, social preference); no A/B testing framework
- Safe modification:
  - Document scoring formula in comments
  - Add logging for match scores and factors
  - Test with multiple user personas (budget-conscious, social, time-constrained)
  - Avoid changing weights without data analysis
  - Implement feature flags for score tweaks
- Test coverage: Match algorithm not unit tested with real user scenarios; no edge case coverage (all vibes selected, no vibes, extreme budget)

---

## Known Bugs

**Coach Stale Detection Timing:**
- Symptoms: Coach rescue mode may not activate when user has skipped days
- Files: `./server/api/generate/[action].ts` (coach system prompt construction)
- Trigger: User starts hobby, does session, stops for 3+ days, opens coach — expects Rescue mode suggestion
- Workaround: User can manually select "Rescue" mode from dropdown
- Root cause: Coach system prompt uses `UserHobby.startedAt` instead of `lastActivityAt`; both fields fixed in Sonnet upgrade files (outputs/action.ts)

**Apple OAuth Route 404:**
- Symptoms: User taps "Sign in with Apple" → error "Route not found"
- Files: `./server/vercel.json` line 11
- Trigger: Any attempt to use Apple Sign-In on iOS
- Workaround: Force user to email/password or Google Sign-In
- Root cause: Vercel regex pattern `(register|login|refresh|google)` missing `apple` action

---

## Scaling Limits

**Hobby Catalog Limited to Seed Data:**
- Current capacity: 150+ hardcoded hobbies in code
- Limit: Adding hobbies requires code commit, review, merge, deploy, app update
- Scaling path:
  - Move to database; implement admin CMS for hobby CRUD
  - Client caches hobby list in Hive; sync on app launch
  - Server pushes updates via FCM notifications
  - Version hobby catalog for A/B testing variants

**API Rate Limiting Not Enforced:**
- Current capacity: No documented rate limits per user or IP
- Limit: Malicious users could spam generation endpoints (hobby, FAQ, cost, budget, coach)
- Scaling path:
  - Implement Redis-backed rate limiting: 20 generations per user per 24h (documented in CLAUDE.md)
  - Add rate limiting middleware to all `/api/generate/` and `/api/hobbies/search` endpoints
  - Return HTTP 429 (Too Many Requests) with retry-after header
  - Track abuse patterns; block suspicious IPs

**Unsplash API Quota:**
- Current capacity: Unsplash free tier ~50 requests/hour
- Limit: Hits limit during signup surge or batch hobby generation
- Scaling path:
  - Pre-cache images during hobby seed (store imageUrl in database)
  - Use image CDN (Cloudflare, Imgix) for delivery
  - Implement fallback category-based placeholder images
  - Migrate to Unsplash paid tier or self-hosted image service

---

## Dependencies at Risk

**Freezed Code Generation Drift:**
- Risk: Freezed generates `.freezed.dart` files; if not regenerated after model edits, type safety breaks
- Files: Generated files like `./lib/models/hobby.freezed.dart` (1,797 lines auto-generated)
- Impact: Type mismatches cause runtime errors; stale code generation common issue
- Migration plan:
  - Ensure `flutter pub get` and `dart run build_runner build` run before every build
  - Add code generation to pre-commit hook
  - Document in CONTRIBUTING.md

**Riverpod Circular Dependencies:**
- Risk: Providers can form circular dependency graphs if not carefully structured
- Files: `./lib/providers/*` (auth, hobby, user, session, subscription, feature providers form complex DAG)
- Impact: Runtime errors if provider invalidation triggers cycles; difficult to debug
- Migration plan:
  - Document provider dependency graph (create visual diagram)
  - Add unit tests for provider relationships
  - Use `ref.watch()` patterns carefully; avoid watching providers from their own dependents
  - Add CI check to detect circular dependencies

---

## Summary — Prioritized Action Items

**CRITICAL (Blocks Launch):**
1. Add `DELETE /api/users/me` endpoint with cascading deletes
2. Add `GET /api/users/me/export` endpoint
3. Fix Apple OAuth routing: update vercel.json regex
4. Host Terms & Privacy Policy; link in app settings

**HIGH (Before Beta):**
1. Verify Sonnet AI deployment or upgrade from Haiku
2. Fix coach stale detection (use `lastActivityAt`)
3. Move coach rate limiting from Hive to database
4. Add pre-commit linting hooks (server TypeScript, Flutter analysis)

**MEDIUM (V1.1 or V2):**
1. Refactor large screen components (home, discover, you, settings, profile)
2. Clean up hidden feature code (buddy mode, community stories, etc.)
3. Add unit tests for session timer, coach limits, onboarding match
4. Implement sync queue for offline-first progress

**LOW (Post-Launch):**
1. Move hobby seed data to CMS
2. Implement Redis caching for coach responses
3. Optimize database indexes
4. Add comprehensive API monitoring and alerting

---

*Concerns audit: 2026-03-21*
