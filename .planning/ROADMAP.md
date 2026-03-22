# Roadmap: TrySomething v1.0 Launch Readiness

**Milestone:** v1.0 Launch Readiness
**Goal:** App Store and Play Store submission-ready — all compliance, security, and production-readiness gaps resolved
**Created:** 2026-03-21
**Granularity:** Fine (10 phases)
**Requirements covered:** 23/23

---

## Phases

- [x] **Phase 1: Server Security Hardening** — Close the live webhook vulnerability and replace the bypassable client-side rate limit with server-side enforcement (completed 2026-03-21)
- [ ] **Phase 2: Apple OAuth Routing Fix** — One-line vercel.json fix that unblocks Apple Sign-In testing on iOS
- [ ] **Phase 3: Legal Documents — Host and Link** — Publish Terms and Privacy Policy to the Next.js site and wire up Settings links
- [ ] **Phase 4: Account Deletion + Data Export — Backend** — Build DELETE and export endpoints with atomic cascade and FADP-compliant field allowlist
- [ ] **Phase 5: Account Deletion — Flutter UX** — Settings flow with confirmation dialog, subscription warning, and full client-side storage wipe
- [ ] **Phase 6: Restore Purchases** — Add RevenueCat restore flow to paywall and Settings per Apple guideline 3.1.1
- [ ] **Phase 7: Dead Code Cleanup** — Remove 7 hidden feature screens (~7,000 lines) safely via GitNexus impact analysis
- [ ] **Phase 8: Sonnet AI Upgrade** — Deploy prepared Sonnet files; fix stale detection and add JSON extraction guard
- [ ] **Phase 9: App Store Assets and Admin** — Screenshots, privacy manifests, privacy labels, data safety form, metadata
- [x] **Phase 10: Pre-Commit Hooks** — Install Lefthook for Flutter analyze + TypeScript lint on every commit (completed 2026-03-22)

---

## Phase Details

### Phase 1: Server Security Hardening
**Goal:** Live security vulnerabilities are closed before production traffic reaches the endpoints
**Depends on:** Nothing
**Requirements:** SEC-01, SEC-02
**Success Criteria** (what must be TRUE):
  1. Webhook endpoint returns 500 and logs a warning when `REVENUECAT_WEBHOOK_SECRET` env var is not set — no traffic is silently accepted
  2. A request to the webhook endpoint with a wrong Authorization header value returns 401, not 200
  3. A free user who sends more than 3 coach messages in a month is rejected by the server with a 429 response, regardless of what the client reports
  4. A modified Hive cache cannot bypass the server-side rate limit check — the count comes from `GenerationLog` rows in Postgres
**Plans:** 2/2 plans complete

Plans:
- [x] 01-01-PLAN.md — Webhook fail-closed + timingSafeEqual (SEC-01)
- [x] 01-02-PLAN.md — Server-side coach rate limiting via GenerationLog (SEC-02)

### Phase 2: Apple OAuth Routing Fix
**Goal:** Apple Sign-In works in production so the iOS auth flow can be tested end-to-end
**Depends on:** Nothing
**Requirements:** SEC-03
**Success Criteria** (what must be TRUE):
  1. A POST to `/api/auth/apple` returns a valid JWT response, not a 404
  2. The `vercel.json` auth route regex includes `apple` alongside `google`, `login`, `register`, `refresh`
  3. Apple Sign-In button on the login screen completes without a network error on a real iOS device or Simulator
**Plans:** TBD

### Phase 3: Legal Documents — Host and Link
**Goal:** Terms of Service and Privacy Policy are live at stable HTTPS URLs and accessible from within the app
**Depends on:** Nothing
**Requirements:** COMP-09, COMP-10, COMP-11
**Success Criteria** (what must be TRUE):
  1. `https://[domain]/terms` returns a publicly accessible HTML page containing the Terms of Service text
  2. `https://[domain]/privacy` returns a publicly accessible HTML page containing the Privacy Policy text
  3. Tapping "Terms of Service" in Settings opens the hosted terms page in the in-app browser (or system browser)
  4. Tapping "Privacy Policy" in Settings opens the hosted privacy page in the in-app browser (or system browser)
  5. Both URLs load without authentication and are crawlable (no redirect to login)
**Plans:** TBD

### Phase 4: Account Deletion + Data Export — Backend
**Goal:** Server correctly deletes all user data atomically and exports a complete, safe JSON package on request
**Depends on:** Nothing (backend-only; Phase 5 depends on this)
**Requirements:** COMP-01, COMP-02, COMP-03, COMP-06, COMP-07, COMP-08
**Success Criteria** (what must be TRUE):
  1. `DELETE /api/users/me` with a valid JWT deletes the user and all related rows across all 14 tables in a single atomic transaction — no orphan rows remain
  2. Sending a request with the same JWT after deletion returns 401 (soft-delete `deletedAt` check in auth middleware rejects the token)
  3. A deleted user's account is not purged immediately — the `deletedAt` timestamp is set and the row persists for 30 days before hard purge
  4. `GET /api/users/me/export` returns a JSON file attachment containing all personal data with `passwordHash`, `revenuecatId`, `appleId`, `googleId`, and `GenerationLog` internal fields excluded
  5. The export response has `Content-Disposition: attachment; filename=trysomething-export.json` and `Content-Type: application/json`
**Plans:** TBD

### Phase 5: Account Deletion — Flutter UX
**Goal:** A user can delete their account from Settings with clear warnings and all local data is wiped on completion
**Depends on:** Phase 4 (server endpoint must exist)
**Requirements:** COMP-04, COMP-05
**Success Criteria** (what must be TRUE):
  1. Settings screen has a "Delete Account" option that opens a confirmation dialog requiring deliberate user action before proceeding
  2. The confirmation dialog explicitly warns the user that their active subscription will not be automatically cancelled and provides a link to manage subscriptions
  3. After confirming deletion, the app clears all local storage (Hive boxes, SharedPreferences, secure token storage) and logs out of RevenueCat
  4. After deletion completes, the app navigates to the unauthenticated login screen and cannot access any protected route
  5. If the deletion API call fails, an error message is shown and no local data is wiped prematurely
**Plans:** 2 plans

Plans:
- [x] 05-01-PLAN.md — Data layer: hasPassword field, CacheManager.clearAll(), repository + provider deleteAccount()
- [ ] 05-02-PLAN.md — Settings UI: delete tile, confirmation flows, warning text, subscription link, local cleanup

### Phase 6: Restore Purchases
**Goal:** Users can restore their Pro subscription on any new device without contacting support
**Depends on:** Nothing
**Requirements:** SUB-01
**Success Criteria** (what must be TRUE):
  1. A "Restore Purchases" button is visible on the paywall screen before any purchase action
  2. A "Restore Purchases" option is present in Settings (or the Pro/subscription screen)
  3. Tapping "Restore" calls `RevenueCat.restorePurchases()` and updates the Pro entitlement status in the app without requiring a fresh login
  4. If no purchases are found to restore, the user sees a clear "No purchases found" message rather than a silent failure
**Plans:** 1 plan

Plans:
- [x] 06-01-PLAN.md — Restore tile in Settings + unit tests for restore flow (SUB-01)

### Phase 7: Dead Code Cleanup
**Goal:** The 7 hidden feature screens and their associated code are fully removed with no breakage to active screens
**Depends on:** Phase 6 (all active screens in final state before deletions)
**Requirements:** CLEAN-01
**Success Criteria** (what must be TRUE):
  1. All 7 hidden screen files (buddy_mode_screen, community_stories_screen, local_discovery_screen, year_in_review_screen, weekly_challenge_screen, mood_match_screen, seasonal_picks_screen) are deleted from the repository
  2. `flutter analyze` passes with zero errors after each file deletion
  3. No active screen (Home, Discover, You, Detail, Session, Coach, Settings) has broken imports or missing references after cleanup
  4. The final line count reduction is approximately 7,000 lines — confirmed by git diff stat
**Plans:** 1 plan

Plans:
- [x] 07-01-PLAN.md — Delete 7 dead screens + remove orphaned providers and repository methods (CLEAN-01)

### Phase 8: Sonnet AI Upgrade
**Goal:** All AI generation runs on Claude Sonnet with hardened prompts, correct stale detection, and safe JSON parsing
**Depends on:** Nothing (independent of other phases; screenshots in Phase 9 should reflect final AI quality)
**Requirements:** AI-01, AI-02, AI-03
**Success Criteria** (what must be TRUE):
  1. `server/lib/ai_generator.ts` uses `claude-sonnet-4-6` (Sonnet 4.6 alias) as the model ID for all generation endpoints
  2. The coach system prompt uses `lastActivityAt` (not `startedAt`) to compute days-since-last-activity for stale detection
  3. All AI response parsing passes through `extractJson()` which strips markdown code fences before `JSON.parse` — malformed Sonnet output does not crash the endpoint
  4. A hobby generation request returns a valid, schema-conforming hobby profile and does not error on Sonnet's output format
**Plans:** 1 plan

Plans:
- [x] 08-01-PLAN.md — Verify Sonnet model + stale detection, extract extractJson() utility (AI-01, AI-02, AI-03)

### Phase 9: App Store Assets and Admin
**Goal:** Both stores have complete submission packages — screenshots, manifests, metadata, privacy declarations, and content ratings
**Depends on:** Phase 3 (Privacy Policy URL required for label forms), Phase 8 (final app state for screenshots)
**Requirements:** COMP-12, COMP-13, COMP-14
**Success Criteria** (what must be TRUE):
  1. iOS screenshots exist at 1290x2796px (iPhone 16 Pro Max Simulator, release build) covering all 3 main tabs and the session screen
  2. App Privacy Labels in App Store Connect are completed and reference the live Privacy Policy URL from Phase 3
  3. Data Safety Form in Google Play Console is completed and references the live Privacy Policy URL from Phase 3
  4. `PrivacyInfo.xcprivacy` files are present (or verified present via SDK versions) for Firebase FCM, RevenueCat, and PostHog — `flutter build ipa` completes without `ITMS-91061` errors
  5. Content Rating questionnaire is submitted on both stores (expected result: 4+ / Everyone)
**Plans:** 2 plans

Plans:
- [x] 09-01-PLAN.md — Privacy manifest + iPhone-only device targeting (COMP-12)
- [ ] 09-02-PLAN.md — Store submission checklists, screenshots, metadata, demo account (COMP-13, COMP-14)

### Phase 09.1: Session Screen Redesign — The Breathing Ring (INSERTED)

**Goal:** [Urgent work - to be planned]
**Requirements**: TBD
**Depends on:** Phase 9
**Plans:** 0 plans

Plans:
- [ ] TBD (run /gsd:plan-phase 09.1 to break down)

### Phase 10: Pre-Commit Hooks
**Goal:** Every commit to the repository automatically runs Flutter analyze and TypeScript lint — formatting issues are caught before they land
**Depends on:** Nothing (independent; can run in parallel with any phase)
**Requirements:** DX-01
**Success Criteria** (what must be TRUE):
  1. `lefthook.yml` exists at the repository root and is committed to git
  2. Running `git commit` on a Flutter file with a Dart analysis error aborts the commit and prints the analyzer output
  3. Running `git commit` on a TypeScript file with a type error aborts the commit and prints the tsc output
  4. A clean commit (no errors) passes all hooks and completes normally within 30 seconds
**Plans:** 1/1 plans complete

Plans:
- [x] 10-01-PLAN.md — Install Lefthook + configure pre-commit hooks for Flutter analyze and TypeScript lint (DX-01)

---

## Progress Table

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Server Security Hardening | 2/2 | Complete   | 2026-03-21 |
| 2. Apple OAuth Routing Fix | 0/? | Not started | — |
| 3. Legal Documents — Host and Link | 0/? | Not started | — |
| 4. Account Deletion + Data Export — Backend | 0/? | Not started | — |
| 5. Account Deletion — Flutter UX | 1/2 | In Progress | — |
| 6. Restore Purchases | 0/1 | Not started | — |
| 7. Dead Code Cleanup | 0/1 | Not started | — |
| 8. Sonnet AI Upgrade | 0/1 | Not started | — |
| 9. App Store Assets and Admin | 0/2 | Not started | — |
| 10. Pre-Commit Hooks | 1/1 | Complete    | 2026-03-22 |

---

## Coverage Map

| Requirement | Phase | Description |
|-------------|-------|-------------|
| SEC-01 | Phase 1 | RevenueCat webhook authorization hardening |
| SEC-02 | Phase 1 | Server-side coach rate limiting via GenerationLog |
| SEC-03 | Phase 2 | Apple OAuth routing fix in vercel.json |
| COMP-09 | Phase 3 | Terms of Service hosted on Next.js site |
| COMP-10 | Phase 3 | Privacy Policy hosted on Next.js site |
| COMP-11 | Phase 3 | Settings links to hosted Terms and Privacy Policy |
| COMP-01 | Phase 4 | Account deletion via Settings confirmation dialog |
| COMP-02 | Phase 4 | Soft-delete with deletedAt + 30-day deferred purge |
| COMP-03 | Phase 4 | Cascade deletes across all 14 user-related tables |
| COMP-06 | Phase 4 | Auth middleware rejects tokens for soft-deleted users |
| COMP-07 | Phase 4 | Data export endpoint GET /api/users/me/export |
| COMP-08 | Phase 4 | Export field allowlist (excludes sensitive fields) |
| COMP-04 | Phase 5 | Client-side storage wipe on account deletion |
| COMP-05 | Phase 5 | UI warns about subscription cancellation before deletion |
| SUB-01 | Phase 6 | Restore Purchases button on paywall and Settings |
| CLEAN-01 | Phase 7 | Remove 7 hidden feature screens (~7,000 lines) |
| AI-01 | Phase 8 | Sonnet AI model upgrade (deploy prepared files) |
| AI-02 | Phase 8 | Coach stale detection uses lastActivityAt |
| AI-03 | Phase 8 | extractJson() guard for Sonnet output format |
| COMP-12 | Phase 9 | Apple Privacy Manifests for Firebase, RevenueCat, PostHog |
| COMP-13 | Phase 9 | App Privacy Labels in App Store Connect |
| COMP-14 | Phase 9 | Data Safety Form in Google Play Console |
| DX-01 | Phase 10 | Pre-commit hooks via Lefthook |

**Total mapped: 23/23**

---

## Dependency Graph

```
Phase 1 (Security) ─────────────────────────────────┐
Phase 2 (Apple OAuth) ──────────────────────────────┤
Phase 3 (Legal Docs) ───────────────────────────────┤──> Phase 9 (App Store Assets)
Phase 4 (Deletion Backend) ─────────────────────────┤
  └──> Phase 5 (Deletion Flutter UX) ───────────────┤
Phase 6 (Restore Purchases) ────────────────────────┤
  └──> Phase 7 (Dead Code Cleanup) ────────────────┤
Phase 8 (Sonnet AI Upgrade) ────────────────────────┘──> Phase 9 (App Store Assets)
Phase 10 (Pre-Commit Hooks) ── independent, parallel with all
```

---

## Backlog

### Phase 999.1: Allow users to pause/shelve active hobbies without abandoning them (BACKLOG)

**Goal:** Captured for future planning
**Requirements:** TBD
**Plans:** 0 plans

Plans:
- [ ] TBD (promote with /gsd:review-backlog when ready)

---

*Roadmap created: 2026-03-21*
*Last updated: 2026-03-22 after Phase 10 planning*
