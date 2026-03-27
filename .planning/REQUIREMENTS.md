# Requirements: TrySomething

**Defined:** 2026-03-27
**Core Value:** A user can discover a hobby that fits them, start it with clear first steps, and stick with it for 30 days.

## v1.3 Requirements

Requirements for Google Play Store submission. After this milestone, the app is on the store.

### Signing & Build

- [ ] **SIGN-01**: Release keystore generated and stored securely (documented location)
- [ ] **SIGN-02**: Gradle signing config references keystore via key.properties (gitignored)
- [ ] **SIGN-03**: Release AAB builds successfully with `flutter build appbundle --release`
- [ ] **SIGN-04**: Build script exists that injects all --dart-define production keys
- [ ] **SIGN-05**: Proguard/R8 keep rules configured for RevenueCat, Firebase, Sentry SDKs

### Service Configuration

- [ ] **SVC-01**: Firebase release SHA-1 and SHA-256 fingerprints registered in console
- [ ] **SVC-02**: google-services.json regenerated with release fingerprints
- [ ] **SVC-03**: RevenueCat Google Play SDK key obtained and wired into build config
- [ ] **SVC-04**: PostHog production API key obtained and wired into build config
- [ ] **SVC-05**: Sentry production DSN obtained and wired into build config
- [ ] **SVC-06**: Google OAuth server client ID obtained and wired into build config

### Play Console & Products

- [ ] **PLAY-01**: App created in Google Play Console with package `com.romulororiz.trysomething`
- [ ] **PLAY-02**: Monthly subscription product created (CHF 4.99/month)
- [ ] **PLAY-03**: Annual subscription product created (CHF 39.99/year)
- [ ] **PLAY-04**: Products linked to RevenueCat with entitlement `pro`
- [ ] **PLAY-05**: License test accounts configured for sandbox purchases

### Store Listing

- [ ] **LIST-01**: Short description written (80 chars max)
- [ ] **LIST-02**: Full description written (4,000 chars max)
- [ ] **LIST-03**: Feature graphic created (1024x500 px)
- [ ] **LIST-04**: Phone screenshots captured (5-8 screens covering key flows)
- [ ] **LIST-05**: Category, contact email, privacy policy URL, and support URL configured
- [ ] **LIST-06**: Content rating questionnaire completed
- [ ] **LIST-07**: App content declarations and ads declaration completed

### Testing & Submission

- [ ] **TEST-01**: Signed release AAB uploaded to internal testing track
- [ ] **TEST-02**: App installs and launches from Play internal testing link
- [ ] **TEST-03**: Google Sign-In works with release signing key
- [ ] **TEST-04**: Real purchase flow completes on internal testing track
- [ ] **TEST-05**: All core flows verified (onboarding, hobby start, session, coach, journal)
- [ ] **TEST-06**: App submitted to production track for Google Play review

### Server & Deployment

- [ ] **SRVR-01**: Vercel Root Directory set to `server/` so Git-triggered deploys work
- [ ] **SRVR-02**: All Vercel environment variables verified for production
- [ ] **SRVR-03**: Cron job (purge-deleted-users) verified working on production

## Out of Scope

| Feature | Reason |
|---------|--------|
| iOS App Store submission | Android-first launch, iOS later |
| Closed beta with external testers | Can do after production approval |
| New app features or UI changes | Code is frozen for launch |
| Onboarding/screen refactoring | Deferred from v1.2, not blocking launch |
| Launch monitoring dashboards | PostHog already integrated, just needs production key |
| Internationalization | English-only for initial launch |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| SIGN-01 | TBD | Pending |
| SIGN-02 | TBD | Pending |
| SIGN-03 | TBD | Pending |
| SIGN-04 | TBD | Pending |
| SIGN-05 | TBD | Pending |
| SVC-01 | TBD | Pending |
| SVC-02 | TBD | Pending |
| SVC-03 | TBD | Pending |
| SVC-04 | TBD | Pending |
| SVC-05 | TBD | Pending |
| SVC-06 | TBD | Pending |
| PLAY-01 | TBD | Pending |
| PLAY-02 | TBD | Pending |
| PLAY-03 | TBD | Pending |
| PLAY-04 | TBD | Pending |
| PLAY-05 | TBD | Pending |
| LIST-01 | TBD | Pending |
| LIST-02 | TBD | Pending |
| LIST-03 | TBD | Pending |
| LIST-04 | TBD | Pending |
| LIST-05 | TBD | Pending |
| LIST-06 | TBD | Pending |
| LIST-07 | TBD | Pending |
| TEST-01 | TBD | Pending |
| TEST-02 | TBD | Pending |
| TEST-03 | TBD | Pending |
| TEST-04 | TBD | Pending |
| TEST-05 | TBD | Pending |
| TEST-06 | TBD | Pending |
| SRVR-01 | TBD | Pending |
| SRVR-02 | TBD | Pending |
| SRVR-03 | TBD | Pending |

**Coverage:**
- v1.3 requirements: 32 total
- Mapped to phases: 0 (pending roadmap)
- Unmapped: 32

---
*Requirements defined: 2026-03-27*
*Last updated: 2026-03-27 after initial definition*
