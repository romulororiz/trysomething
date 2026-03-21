# Project Research Summary

**Project:** TrySomething v1.0 Launch Readiness
**Domain:** Mobile app store compliance, security hardening, legal data privacy
**Researched:** 2026-03-21
**Confidence:** HIGH

## Executive Summary

TrySomething is a production-ready Flutter app (full stack operational, Sprints A–E complete) that requires a focused compliance and security sprint before it can pass App Store and Google Play review. The core product is built; what remains is a well-scoped set of regulatory, legal, and security requirements that are non-negotiable for first submission. None of the work requires architectural rewrites — all new features integrate as additive changes into the existing `users/[path].ts` handler switch-case pattern, Riverpod auth provider, and settings screen.

The recommended approach is to sequence work strictly by blocking dependencies: legal documents must be hosted before privacy labels can be completed; the server-side account deletion endpoint must exist before the Flutter UI can be built; security hardening (webhook verification, server-side rate limiting) should be addressed before production traffic arrives. The Apple OAuth routing bug (`vercel.json` regex missing `|apple`) is a one-line fix that unblocks iOS testing and must be done first. Five of the ten table-stakes features are administrative tasks (privacy labels, metadata, screenshots, content rating, demo account) — they require no code but require dedicated time allocation.

The primary risk vector is App Store rejection through oversight: account deletion UX that does not warn about subscription continuation, Apple Privacy Manifest missing for Firebase/RevenueCat/PostHog SDKs, or screenshots captured from the Android test device rather than iOS Simulator. Secondary risks are security gaps in the webhook handler (currently accepts all traffic if env var is unset) and the JWT validity window (tokens remain valid up to 30 days after account deletion). Both are preventable with targeted changes documented in the architecture research.

## Key Findings

### Recommended Stack

The existing stack requires exactly one new dev dependency for this milestone: `lefthook@^2.1.4` (pre-commit hooks for the polyglot Flutter+TypeScript monorepo). Everything else — Prisma `$transaction`, RevenueCat webhook verification via `crypto.timingSafeEqual`, server-side rate limiting via `GenerationLog`, and data export via `JSON.stringify` — uses packages already installed. Husky is the wrong choice here because the repository root is a Flutter project with no `package.json`; Lefthook is a language-agnostic binary that handles this structure natively.

**Core technologies (new or changed):**
- `lefthook@^2.1.4`: Pre-commit hooks — only new dev dependency, handles polyglot monorepo (Flutter Dart + TypeScript)
- `prisma.$transaction` (already installed): Account deletion with cascading deletes — all 13 user FK tables have `onDelete: Cascade`; only `GenerationLog` needs explicit deletion (bare `userId String`, no FK)
- `crypto.timingSafeEqual` (Node.js built-in): Webhook verification — RevenueCat uses Authorization header, NOT HMAC; using HMAC would drop all legitimate webhook events
- `GenerationLog` (existing Prisma model, `@@index([userId, createdAt])`): Server-side coach rate limiting — replaces bypassable Hive client-side check
- `JSON.stringify` (built-in): Data export — user data volumes are small (<1MB); streaming is unnecessary complexity

**New environment variable required:**
- `REVENUECAT_WEBHOOK_SECRET`: Set in Vercel + RevenueCat dashboard; currently absent, causing webhook endpoint to silently accept all traffic

### Expected Features

The full feature landscape is documented in `.planning/research/FEATURES.md`. The table-stakes features are defined by Apple and Google guidelines — missing any is a guaranteed rejection.

**Must have (table stakes — guaranteed rejection without):**
- Account deletion in-app (Settings → confirmation → cascade-delete all data) — Apple 5.1.1(v), mandatory since June 2022
- Privacy Policy hosted at stable HTTPS URL (not PDF) — both stores require; already drafted as .docx, just needs hosting
- Terms of Service hosted and linked from Settings — required for subscription apps; already drafted as .docx
- Restore Purchases button on paywall and in Settings — Apple 3.1.1; RevenueCat SDK has `restorePurchases()` method, just needs UI
- App Privacy Labels (App Store Connect) + Data Safety Form (Google Play) — blocking submission; requires Privacy Policy finalized first
- Demo account credentials in App Review Notes — Apple 2.1; without them reviewers cannot access the app
- Apple OAuth routing fix (`vercel.json` regex) — Apple Sign-In silently fails in production; one-line fix
- App Store screenshots at correct device sizes (6.9-inch iPhone, 1290×2796px for iOS) — not from Android test device
- App metadata (title/subtitle/description/keywords within character limits) — required to complete submission
- Content Rating Questionnaire (should receive 4+/Everyone) — blocking submission on both platforms

**Should have (compliance and security — not app store gates but legally required or security-critical):**
- Data export endpoint `GET /api/users/me/export` — FADP Art. 28, GDPR Art. 20 portability right
- RevenueCat webhook authorization hardening (mandatory env var, not optional) — prevents fake subscription events
- Server-side AI coach rate limiting via `GenerationLog` — replaces bypassable client-side Hive check
- Subscription cancellation guidance in delete account flow — Apple specifically calls this out in deletion docs

**Defer to v1.1:**
- Localized app store listings (English-only for v1.0 is explicit decision)
- GDPR consent banner (not required: app uses no advertising tracking)
- Email-based deletion flow (Apple explicitly rejects this; in-app is required)

### Architecture

All new features integrate as additive changes into the existing consolidated handler pattern. No new Vercel function files should be created — the project merges handlers to stay within Vercel's 12-function free tier limit (noted in comment at `users/[path].ts` line ~1090). Three new switch cases go into `users/[path].ts`: `delete`, `export`, and the existing webhook guard fix. One new utility file `server/lib/rate_limit.ts` exports `checkCoachRateLimit()`. On the Flutter side, `AuthNotifier` gains a `deleteAccount()` method that mirrors the existing `logout()` flow with a server call prepended.

**Major components:**
1. `DELETE /api/users/me` (new switch case) — `prisma.$transaction([generationLog.deleteMany, user.delete])`, cascades 13 FK tables automatically at DB level; returns 200, client runs logout cleanup
2. `GET /api/users/me/export` (new switch case) — `Promise.all` over 11 tables, strips `passwordHash`/`revenuecatId`/`appleId`/`googleId`, returns `application/json` with `Content-Disposition: attachment`
3. `server/lib/rate_limit.ts` (new utility) — `checkCoachRateLimit(userId, isProUser)` counting `GenerationLog` rows with `query: 'coach'` in a 30-day rolling window
4. `handleRevenueCatWebhook` (modified guard) — fail hard (`500`) if `REVENUECAT_WEBHOOK_SECRET` env var missing; currently fails open (accepts all traffic)
5. `AuthNotifier.deleteAccount()` (new Flutter method) — DELETE server call + `TokenStorage.clearTokens()` + `CacheManager.clearAll()` (needs new method) + auth state → unauthenticated
6. `lib/screens/settings/settings_screen.dart` (modified) — "Delete Account" button + confirmation dialog + subscription warning + Privacy Policy / Terms links
7. `server/vercel.json` (modified) — add routes for `delete`, `export`; fix auth regex to include `|apple`

**Key patterns to follow:**
- New user endpoints → add switch case to existing `users/[path].ts`, not new files
- Account deletion → `prisma.$transaction` callback style (interactive), not sequential array
- Data export → `Promise.all` + `res.json()`, not streaming
- Rate limiting → `GenerationLog` COUNT query, not in-memory (serverless functions share no memory)

### Critical Pitfalls

1. **RevenueCat deletion does not cancel billing** — Account deletion removes the DB row but Apple/Google subscriptions keep billing. Prevention: show explicit subscription cancellation warning with link to subscription management before allowing deletion to complete. Do NOT call RevenueCat's delete user API as part of account deletion (RevenueCat customer record is needed for dispute resolution).

2. **JWT tokens valid 30 days after account deletion** — Deleting the User row does not invalidate outstanding JWTs. Prevention: add `deletedAt` nullable field to User model, check it in auth middleware and return 401 if set. Alternatively, implement token version counter (`tokenVersion` on User). A Prisma migration is required — commit it to git.

3. **Apple Privacy Manifest missing for SDK tier** — Firebase FCM, RevenueCat `purchases_flutter`, and PostHog are all on Apple's "commonly used third-party SDKs" list requiring `PrivacyInfo.xcprivacy` (required since February 12, 2025). Automated toolchain rejects the upload before human review. Prevention: verify SDK versions include manifests; run TestFlight upload (not just `flutter build ipa`) to catch `ITMS-91061` early.

4. **RevenueCat webhook HMAC confusion** — RevenueCat uses Authorization header auth, NOT HMAC payload signing. Implementing HMAC verification (like Stripe) means all legitimate webhook events fail authentication and subscription state never updates. Prevention: use `req.headers['authorization'] === Bearer ${secret}` only.

5. **Orphaned data or cascade failure on account deletion** — `GenerationLog` has no FK relation to `User` (plain `userId String` field) so database-level cascade does not apply. Must be deleted explicitly before `user.delete`. All other 13 tables already have `onDelete: Cascade`. Prevention: always use the `$transaction([generationLog.deleteMany, user.delete])` pattern, never a bare `user.delete`.

## Implications for Roadmap

Based on combined research, suggested phase structure (10 discrete phases, ordered by blocking dependencies):

### Phase 1: Server Security Hardening
**Rationale:** Webhook gap is an immediately exploitable security vulnerability in production. Fix before any production traffic reaches the live endpoint. No dependencies on other phases.
**Delivers:** Hardened RevenueCat webhook verification; server-side AI coach rate limiting replacing bypassable client-side Hive check
**Addresses:** FEATURES.md Differentiators #2 (webhook security) and #3 (server-side rate limiting)
**Avoids:** Pitfall 6 (HMAC confusion), Pitfall 11 (Hive rate limit bypass window — deploy server-side check before removing client-side check)

### Phase 2: Apple OAuth Routing Fix
**Rationale:** One-line `vercel.json` change that unblocks Apple Sign-In testing on real iOS device. Must be verified before app store submission. No dependencies.
**Delivers:** Working Apple Sign-In in production (`|apple` added to auth route regex)
**Avoids:** Guaranteed rejection under Apple guideline 4.8

### Phase 3: Legal Documents — Host and Link
**Rationale:** Privacy Policy and Terms of Service are already drafted as .docx files. Publishing them to the Next.js site (`/privacy`, `/terms`) is low effort and is a prerequisite for completing App Privacy Labels in App Store Connect.
**Delivers:** Stable HTTPS URLs for Privacy Policy and Terms of Service; Settings screen links to both
**Avoids:** Pitfall 12 (non-HTTPS URLs rejected), guaranteed rejection for missing Privacy Policy link

### Phase 4: Account Deletion — Backend
**Rationale:** Must be built before the Flutter UI can be tested. The server-side cascade pattern is fully documented; `onDelete: Cascade` is already present on all 13 FK tables; only `GenerationLog` needs explicit deletion.
**Delivers:** `DELETE /api/users/me` endpoint with atomic `$transaction`; `GET /api/users/me/export` endpoint (FADP compliance)
**Uses:** Prisma `$transaction` (already installed), `Promise.all` for export
**Avoids:** Pitfall 3 (orphaned data), Pitfall 4 (passwordHash in export), Pitfall 13 (migration not committed)

### Phase 5: Account Deletion — Flutter UX
**Rationale:** Depends on Phase 4 (server endpoint). Mirrors existing `logout()` flow. Requires `CacheManager.clearAll()` (3-line addition) before `AuthNotifier.deleteAccount()` can be built.
**Delivers:** Settings → Delete Account flow with confirmation dialog, active subscription warning, and typed-phrase confirmation; `AuthNotifier.deleteAccount()` method; `CacheManager.clearAll()` utility
**Avoids:** Pitfall 1 (no subscription warning), Pitfall 2 (JWT invalidation — `deletedAt` check in middleware)

### Phase 6: Restore Purchases Button
**Rationale:** No dependencies; RevenueCat SDK already has `restorePurchases()`. Required by Apple 3.1.1. Add to paywall screen and Settings/Pro screen.
**Delivers:** Restore Purchases UI on paywall and Settings; RevenueCat entitlement re-check on restore
**Avoids:** Guaranteed rejection under Apple guideline 3.1.1

### Phase 7: Dead Code Cleanup
**Rationale:** 7 hidden screens with routes removed (buddy mode, community stories, local discovery, year in review, weekly challenge, mood match, seasonal picks) should have their files deleted before submission. Apple guideline 2.3.3 flags dead code. Must be done carefully — shared models and providers may still be referenced by active screens.
**Delivers:** Removal of ~7,000 lines of hidden screen code; cleaner dependency graph
**Avoids:** Pitfall 8 (shared components deleted with screens — run `gitnexus_impact` on every exported symbol before deleting; run `dart analyze` after each file)

### Phase 8: Sonnet AI Upgrade
**Rationale:** Upgrade files (`outputs/ai_generator.ts`, `outputs/action.ts`) are already written and ready to deploy. Model upgrade improves coach quality for the launch user base. Must be staged and validated for JSON parsing robustness.
**Delivers:** Claude Sonnet replacing Haiku for all AI generation; hardened prompts with `validateHobbyOutput()`; correct `lastActivityAt` usage in coach
**Avoids:** Pitfall 7 (Sonnet adds markdown wrappers around JSON — add `extractJson()` helper before `JSON.parse`)

### Phase 9: App Store Prep — Assets and Admin
**Rationale:** Parallel work stream: screenshots, app icon verification, app metadata, privacy labels, demo account. All depend on Phase 3 (Privacy Policy live) and Phase 8 (final app state for screenshots). Most tasks are non-code.
**Delivers:** iOS screenshots at 1290×2796px (iPhone 16 Pro Max Simulator, release mode); Android screenshot adaptation; app icon at 1024×1024px and adaptive icon layers; Privacy Labels completed in App Store Connect; Data Safety Form in Google Play; Content Rating questionnaire; demo account with review notes; title/subtitle/description/keywords
**Avoids:** Pitfall 5 (Apple Privacy Manifest missing — verify SDK versions before upload), Pitfall 9 (screenshots from Android device rejected), Pitfall 10 (Data Safety form inaccurate)

### Phase 10: Pre-Commit Hooks and CI
**Rationale:** Lefthook `lefthook.yml` at repo root covering Flutter analyze, dart format check, TypeScript typecheck. Install in `server/devDependencies`. Low risk, can be done in parallel with any other phase. Recommended before Phase 7 (dead code cleanup) so format issues are caught automatically.
**Delivers:** `lefthook.yml` config; `server/devDependencies` entry; git hooks active for all future commits
**Uses:** `lefthook@^2.1.4` (only new dependency in this milestone)

### Phase Ordering Rationale

- Phases 1–2 (security + OAuth fix) come first because they are unblocked and fix live vulnerabilities
- Phase 3 (legal docs) must precede Phase 9 (privacy labels) — App Store Connect requires a live URL before the labels form can be completed
- Phase 4 (backend deletion) must precede Phase 5 (Flutter deletion UX) — cannot build client without server
- Phase 7 (dead code) is best done after Phase 6 (restore purchases) — confirms all active screens are in final state before deletions
- Phase 8 (AI upgrade) should precede Phase 9 (screenshots) — screenshots should reflect the final app quality
- Phase 9 is the last code-required phase before submission; its admin tasks (metadata, demo account) can overlap with other phases
- Phase 10 (pre-commit hooks) is independent and can run in parallel with any phase

### Research Flags

Phases likely needing deeper research during planning:
- **Phase 5 (Account Deletion Flutter):** JWT invalidation via `deletedAt` requires a Prisma schema migration — confirm migration procedure for Neon free tier and the impact on token validation middleware (`core/auth/` JWT interceptor)
- **Phase 7 (Dead Code Cleanup):** Hidden screen dependency graph is not fully mapped — use `gitnexus_impact` for every exported symbol in each of the 7 screens before deletion; social.dart models (`CommunityStory`, `BuddyPair`) likely have active downstream consumers

Phases with standard patterns (skip research-phase):
- **Phase 1 (Security Hardening):** Both changes are fully specified in STACK.md and ARCHITECTURE.md with code samples
- **Phase 2 (OAuth Routing Fix):** One-line `vercel.json` change, fully specified
- **Phase 3 (Legal Documents):** Static pages on Next.js site; standard pattern
- **Phase 4 (Backend Deletion):** Cascade pattern fully specified; `$transaction` pattern is standard Prisma
- **Phase 6 (Restore Purchases):** RevenueCat SDK method is documented; UI addition only
- **Phase 8 (AI Upgrade):** Files already written and ready; validation checklist specified
- **Phase 10 (Pre-Commit Hooks):** `lefthook.yml` config specified in STACK.md with exact YAML

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | All findings verified against official docs; only one new dependency (lefthook), rest use existing packages |
| Features | HIGH | Apple and Google guidelines are authoritative official documentation; compliance requirements are binary (pass/fail) |
| Architecture | HIGH | Based on direct codebase inspection of `schema.prisma`, `users/[path].ts`, and `vercel.json`; patterns are well-established |
| Pitfalls | HIGH | 5 critical pitfalls sourced from official Apple/Google/RevenueCat docs; JWT and cascade pitfalls are documented security patterns |

**Overall confidence:** HIGH

### Gaps to Address

- **`deletedAt` migration scope:** ARCHITECTURE.md recommends adding `deletedAt` to User model to invalidate JWTs post-deletion. This is the pragmatic approach (no Redis required) but requires a Prisma migration. Confirm whether Neon free tier supports live migrations without downtime before planning Phase 5.
- **PostHog Privacy Manifest:** PITFALLS.md flags Firebase and RevenueCat manifests with specific version references, but PostHog's `PrivacyInfo.xcprivacy` status is less certain ("check posthog-ios CHANGELOG — if not present, add manual manifest"). This needs explicit version verification during Phase 9.
- **Apple Sign-In token revocation:** Apple requires calling the Sign in with Apple REST API to revoke tokens when deleting an Apple OAuth account. This adds complexity to Phase 4 (server-side deletion). The scope of this token revocation call needs confirmation against Apple TN3194 during Phase 4 planning.
- **`CacheManager.clearAll()` scope:** The existing `CacheManager` has no `clearAll()` method. ARCHITECTURE.md notes it needs to clear `_dataBox` and `_metaBox`. Confirm which Hive boxes are open in the app before implementing to ensure complete local data cleanup on account deletion.

## Sources

### Primary (HIGH confidence)
- Apple App Store Review Guidelines — https://developer.apple.com/app-store/review/guidelines/
- Apple: Offering Account Deletion — https://developer.apple.com/support/offering-account-deletion-in-your-app/
- Apple TN3194: Sign in with Apple token revocation — https://developer.apple.com/documentation/technotes/tn3194-handling-account-deletions-and-revoking-tokens-for-sign-in-with-apple
- Apple App Privacy Details — https://developer.apple.com/app-store/app-privacy-details/
- Apple Privacy Manifest requirement (Feb 2025) — https://developer.apple.com/news/?id=3d8a9yyh
- Google Play Account Deletion Requirements — https://support.google.com/googleplay/android-developer/answer/13327111
- Google Play Data Safety — https://support.google.com/googleplay/android-developer/answer/10787469
- GDPR Article 20 (data portability) — https://gdpr-info.eu/art-20-gdpr/
- RevenueCat Webhooks Documentation — https://www.revenuecat.com/docs/integrations/webhooks
- RevenueCat Restoring Purchases — https://www.revenuecat.com/docs/getting-started/restoring-purchases
- Prisma Transactions Reference — https://www.prisma.io/docs/orm/prisma-client/queries/transactions
- Direct schema inspection (`server/prisma/schema.prisma`) — confirmed cascade behavior on all 25 models
- Direct handler inspection (`server/api/users/[path].ts`, `server/api/generate/[action].ts`) — confirmed function limit comment, existing patterns
- Direct config inspection (`server/vercel.json`) — confirmed missing `|apple` in auth regex

### Secondary (MEDIUM confidence)
- RevenueCat webhook message verification community (confirms no HMAC) — https://community.revenuecat.com/sdks-51/webhook-message-verification-7165
- RevenueCat X-RevCat-Signature removal — https://community.revenuecat.com/dashboard-tools-52/is-x-revenuecat-signature-removed-and-where-is-webhook-secret-key-7110
- Lefthook GitHub v2.1.4 — https://github.com/evilmartians/lefthook
- Neon rate limiting with PostgreSQL — https://neon.com/guides/rate-limiting
- Switzerland FADP overview (multiple sources) — https://usercentrics.com/knowledge-hub/switzerland-federal-data-protection-act-fadp/
- App Store screenshot requirements 2025-2026 — multiple community guides agree on 6.9-inch mandate
- JWT invalidation after deletion — https://www.descope.com/blog/post/jwt-logout-risks-mitigations
- Promptfoo: model upgrade JSON format risks — https://www.promptfoo.dev/blog/model-upgrades-break-agent-safety/

---
*Research completed: 2026-03-21*
*Ready for roadmap: yes*
