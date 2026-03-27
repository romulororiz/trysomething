# Roadmap: TrySomething

## Milestones

- ✅ **v1.0 Launch Readiness** -- Phases 1-10 (shipped 2026-03-23)
- ✅ **v1.1 Hobby Lifecycle & Monetization** -- Phases 11-14 (shipped 2026-03-23)
- ✅ **v1.2 Separation of Concerns Refactor** -- Phases 15-18 (shipped 2026-03-26)
- **v1.3 Google Play Launch** -- Phases 21-26 (in progress)

---

## Phases

<details>
<summary>v1.0 Launch Readiness (Phases 1-10) -- SHIPPED 2026-03-23</summary>

- [x] **Phase 1: Server Security Hardening** -- Close the live webhook vulnerability and replace bypassable client-side rate limit with server-side enforcement (completed 2026-03-21)
- [x] **Phase 2: Apple OAuth Routing Fix** -- One-line vercel.json fix that unblocks Apple Sign-In testing on iOS (completed 2026-03-21)
- [x] **Phase 3: Legal Documents -- Host and Link** -- Publish Terms and Privacy Policy to the Next.js site and wire up Settings links (completed 2026-03-21)
- [x] **Phase 4: Account Deletion + Data Export -- Backend** -- Build DELETE and export endpoints with atomic cascade and FADP-compliant field allowlist (completed 2026-03-21)
- [x] **Phase 5: Account Deletion -- Flutter UX** -- Settings flow with confirmation dialog, subscription warning, and full client-side storage wipe (completed 2026-03-21)
- [x] **Phase 6: Restore Purchases** -- Add RevenueCat restore flow to paywall and Settings per Apple guideline 3.1.1 (completed 2026-03-21)
- [x] **Phase 7: Dead Code Cleanup** -- Remove 7 hidden feature screens (~7,000 lines) safely via impact analysis (completed 2026-03-21)
- [x] **Phase 8: Sonnet AI Upgrade** -- Deploy prepared Sonnet files; fix stale detection and add JSON extraction guard (completed 2026-03-22)
- [x] **Phase 9: App Store Assets and Admin** -- Screenshots, privacy manifests, privacy labels, data safety form, metadata (completed 2026-03-22)
- [x] **Phase 9.1: Session Screen Redesign -- The Breathing Ring** (INSERTED) -- Replace particle field with premium Apple Watch-style breathing ring (completed 2026-03-22)
- [x] **Phase 10: Pre-Commit Hooks** -- Install Lefthook for Flutter analyze + TypeScript lint on every commit (completed 2026-03-22)

See: `.planning/milestones/v1.0-ROADMAP.md` for full details

</details>

<details>
<summary>v1.1 Hobby Lifecycle & Monetization (Phases 11-14) -- SHIPPED 2026-03-23</summary>

- [x] **Phase 11: Lifecycle Schema Migration** -- Add `paused` enum value and pause tracking fields to Prisma schema and Dart model (completed 2026-03-23)
- [x] **Phase 12: Hobby Completion Flow + Stop** -- Server-side completion detection, celebration overlay, Home completed state, and free stop/abandon action (completed 2026-03-23)
- [x] **Phase 13: Detail Page Content Gating** -- Free vs Pro content sections with `ProGateSection` widget and server-side endpoint guards (completed 2026-03-23)
- [x] **Phase 14: Pause/Resume Lifecycle** -- Pro-gated pause action, paused state display, resume, Pro-lapse auto-resume, and streak-safe pause duration tracking (completed 2026-03-23)

See: `.planning/milestones/v1.0-ROADMAP.md` for full details (v1.1 section)

</details>

<details>
<summary>v1.2 Separation of Concerns Refactor (Phases 15-18) -- SHIPPED 2026-03-26</summary>

- [x] **Phase 15: Home Screen Refactor** -- Extract page variants, journal tiles, and roadmap widgets from home_screen.dart (2,375 -> 393 lines) (completed 2026-03-26)
- [x] **Phase 16: Settings Screen Refactor** -- Extract edit profile sheet, photo picker, and section builders from settings_screen.dart (2,082 -> 831 lines) (completed 2026-03-26)
- [x] **Phase 17: You Screen Refactor** -- Extract tab contents and hobby card variants from you_screen.dart (1,654 -> 336 lines) (completed 2026-03-26)
- [x] **Phase 18: Coach Screen Refactor** -- Extract CoachNotifier, message bubbles, composer, and mode selector from hobby_coach_screen.dart (1,741 -> 367 lines) (completed 2026-03-26)

**Known gaps:** Phases 19 (Onboarding) and 20 (Remaining Screens) were planned but deferred -- 7 requirements remain as tech debt.

See: `.planning/milestones/v1.2-ROADMAP.md` for full details

</details>

### v1.3 Google Play Launch (In Progress)

**Milestone Goal:** Complete every operational, configuration, and store requirement to submit TrySomething to the Google Play Store. After this milestone, the app is on the store.

- [x] **Phase 21: Server Deploy Fix + Signing Foundation** -- Fix Vercel root directory, generate release keystore, configure Gradle signing and Proguard keep rules (completed 2026-03-27)
- [x] **Phase 22: Service Keys & Build Pipeline** -- Wire all production API keys, register Firebase release fingerprints, create build script with dart-define injection, produce first release AAB (completed 2026-03-27)
- [ ] **Phase 23: Play Console & Products** -- Create app in Play Console, set up subscription products, link to RevenueCat, configure license testers
- [ ] **Phase 24: Store Listing** -- Write store copy, create feature graphic, capture screenshots, complete content rating and declarations
- [ ] **Phase 25: Internal Testing & Verification** -- Upload AAB, install from test track, verify Google Sign-In, purchases, and all core flows
- [ ] **Phase 26: Production Submission** -- Final server verification, submit to production track for Google Play review

## Phase Details

### Phase 21: Server Deploy Fix + Signing Foundation
**Goal**: Release builds can be signed and the server deploys correctly from Git pushes
**Depends on**: Nothing (first phase of v1.3)
**Requirements**: SRVR-01, SIGN-01, SIGN-02, SIGN-05
**Success Criteria** (what must be TRUE):
  1. Pushing to the server repo triggers a successful Vercel deploy without manual Root Directory override
  2. A release keystore exists in a documented, secure location with backup
  3. Running `flutter build appbundle --release` uses the release signing config from key.properties (not debug)
  4. Proguard/R8 does not strip RevenueCat, Firebase, or Sentry classes in release builds
**Plans**: TBD

Plans:
- [ ] 21-01: Vercel root directory fix + Gradle signing config + Proguard keep rules

### Phase 22: Service Keys & Build Pipeline
**Goal**: All production services are wired and a release AAB builds end-to-end with real keys
**Depends on**: Phase 21 (needs keystore for Firebase fingerprints, needs signing for AAB)
**Requirements**: SVC-01, SVC-02, SVC-03, SVC-04, SVC-05, SVC-06, SIGN-03, SIGN-04
**Success Criteria** (what must be TRUE):
  1. Firebase console shows the release SHA-1 and SHA-256 fingerprints and google-services.json includes them
  2. A build script (or documented command) injects RevenueCat, PostHog, Sentry, and Google OAuth keys via --dart-define
  3. Running the build script produces a signed release AAB without errors
  4. The AAB can be installed on a device and the app launches (smoke test)
**Plans**: TBD

Plans:
- [ ] 22-01: Register Firebase fingerprints, collect all production API keys, regenerate google-services.json
- [ ] 22-02: Create build script with --dart-define injection and verify release AAB

### Phase 23: Play Console & Products
**Goal**: Play Console app exists with functional subscription products linked to RevenueCat
**Depends on**: Phase 22 (needs signed AAB for Play Console setup; needs RevenueCat SDK key)
**Requirements**: PLAY-01, PLAY-02, PLAY-03, PLAY-04, PLAY-05
**Success Criteria** (what must be TRUE):
  1. App `com.romulororiz.trysomething` exists in Google Play Console
  2. Monthly (CHF 4.99) and annual (CHF 39.99) subscription products are active and visible in Play Console
  3. RevenueCat dashboard shows both products linked under entitlement `pro`
  4. At least one license test account is configured for sandbox purchase testing
**Plans**: TBD

Plans:
- [ ] 23-01: Create Play Console app, configure subscription products, link RevenueCat, add license testers

### Phase 24: Store Listing
**Goal**: Store listing is complete and ready for review -- all copy, visuals, and compliance forms filled
**Depends on**: Phase 23 (app must exist in Play Console)
**Requirements**: LIST-01, LIST-02, LIST-03, LIST-04, LIST-05, LIST-06, LIST-07
**Success Criteria** (what must be TRUE):
  1. Short description (80 chars) and full description (4,000 chars) are entered in Play Console
  2. Feature graphic (1024x500) and 5-8 phone screenshots are uploaded
  3. Category, contact email, privacy policy URL, and support URL are all configured
  4. Content rating questionnaire and app content declarations (including ads declaration) are completed with no warnings
**Plans**: TBD

Plans:
- [ ] 24-01: Write store copy (short + full description)
- [ ] 24-02: Create feature graphic, capture phone screenshots, complete compliance forms

### Phase 25: Internal Testing & Verification
**Goal**: App is verified working end-to-end on the Play internal testing track with real purchases
**Depends on**: Phase 22 (AAB), Phase 23 (products + license testers), Phase 24 (listing for track access)
**Requirements**: TEST-01, TEST-02, TEST-03, TEST-04, TEST-05
**Success Criteria** (what must be TRUE):
  1. Signed release AAB is uploaded and published on the internal testing track
  2. App installs and launches from the Play internal testing link on Nothing Phone 3a
  3. Google Sign-In completes successfully with the release signing key
  4. A real subscription purchase (monthly or annual) completes end-to-end on internal testing
  5. Core flows work in release build: onboarding, hobby start, session timer, coach chat, journal entry
**Plans**: TBD

Plans:
- [ ] 25-01: Upload AAB to internal testing, install and verify all flows including purchase

### Phase 26: Production Submission
**Goal**: App is submitted to Google Play production track for review
**Depends on**: Phase 25 (all testing passed)
**Requirements**: TEST-06, SRVR-02, SRVR-03
**Success Criteria** (what must be TRUE):
  1. All Vercel environment variables are verified present and correct for production traffic
  2. The purge-deleted-users cron job has executed successfully at least once in production
  3. App is submitted to the production track and Google Play review is in progress
**Plans**: TBD

Plans:
- [ ] 26-01: Verify server production readiness, submit app to production track

---

## Progress

**Execution Order:**
Phases execute in numeric order: 21 -> 22 -> 23 -> 24 -> 25 -> 26

| Phase | Milestone | Plans Complete | Status | Completed |
|-------|-----------|----------------|--------|-----------|
| 1-10 | v1.0 | 18/18 | Complete | 2026-03-22 |
| 11-14 | v1.1 | 8/8 | Complete | 2026-03-23 |
| 15-18 | v1.2 | 8/8 | Complete | 2026-03-26 |
| 21. Server Deploy Fix + Signing Foundation | 1/1 | Complete    | 2026-03-27 | - |
| 22. Service Keys & Build Pipeline | 2/2 | Complete    | 2026-03-27 | - |
| 23. Play Console & Products | v1.3 | 0/1 | Not started | - |
| 24. Store Listing | v1.3 | 0/2 | Not started | - |
| 25. Internal Testing & Verification | v1.3 | 0/1 | Not started | - |
| 26. Production Submission | v1.3 | 0/1 | Not started | - |

---

*Roadmap created: 2026-03-21 (v1.0)*
*v1.1 phases added: 2026-03-23*
*v1.2 phases added: 2026-03-26*
*v1.2 shipped: 2026-03-26 (Phases 15-18 complete, 19-20 deferred)*
*v1.3 phases added: 2026-03-27*
