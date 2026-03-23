# HUMAN_LAUNCH_CHECKLIST.md

> Goal: complete everything outside the codebase needed to launch TrySomething safely.
> Scope: RevenueCat dashboard, Play Console, Firebase console, signing assets, store listing, compliance, legal publishing, testing operations, launch operations.
> Out of scope: repo/code changes. Those are in `CLAUDE_PRODUCTION_SPRINTS.md`.

---

## How to use this checklist

- [ ] Work top to bottom
- [ ] Do not mark anything complete until it is actually done
- [ ] Save screenshots/records of every important console configuration
- [ ] Keep one folder with:
  - [ ] keystore backup
  - [ ] Firebase config files
  - [ ] RevenueCat keys
  - [ ] Play product IDs
  - [ ] listing copy
  - [ ] privacy policy URL
  - [ ] screenshots/assets

---

# Phase 1 — Identity and account setup

## App identity
- [ ] Confirm final app name: `TrySomething`
- [ ] Choose final Android package name
- [ ] Choose final iOS bundle ID if launching iOS
- [ ] Confirm support email
- [ ] Confirm privacy policy URL
- [ ] Confirm website/support page if you have one

## Accounts
- [ ] Google Play Console account is active
- [ ] Apple Developer account is active if launching iOS
- [ ] RevenueCat account/project is final
- [ ] Firebase account/project is final
- [ ] Domain/hosting for privacy policy/support is ready

---

# Phase 2 — Firebase external setup

- [ ] Create/finalize production Firebase project
- [ ] Register Android app with final package name
- [ ] Register iOS app with final bundle ID if needed
- [ ] Download final Android `google-services.json`
- [ ] Download final iOS `GoogleService-Info.plist` if needed
- [ ] Add release SHA-1 and SHA-256 fingerprints after signing config is ready
- [ ] Verify Google Sign-In works with final package name
- [ ] Verify auth providers enabled correctly
- [ ] Verify Analytics enabled

### Done when
- [ ] Firebase matches the final production app identity

---

# Phase 3 — RevenueCat dashboard setup

- [ ] Create/verify entitlement `pro`
- [ ] Create/verify current/default offering
- [ ] Add monthly package
- [ ] Add annual package
- [ ] Add lifetime only if you truly want it
- [ ] Verify package names match the app’s expected package structure
- [ ] Verify paywall is attached to the intended offering
- [ ] Copy final Android public SDK key
- [ ] Copy final iOS public SDK key if needed
- [ ] Store keys safely
- [ ] Decide/verify anonymous → authenticated user behavior expectations
- [ ] Decide/verify restore behavior expectations

### Done when
- [ ] RevenueCat dashboard is production-configured and matches app assumptions

---

# Phase 4 — Google Play product setup

- [ ] Create app in Google Play Console
- [ ] Confirm app type/basic setup
- [ ] Enroll in Play App Signing if needed
- [ ] Create monthly subscription product
- [ ] Create annual subscription product
- [ ] Configure base plans
- [ ] Configure pricing
- [ ] Configure trial if desired
- [ ] Wait until products are available enough for testing
- [ ] Link/import products into RevenueCat
- [ ] Add license test accounts
- [ ] Prepare internal testing group/testers

### Done when
- [ ] Real Play billing products exist and are ready for internal testing

---

# Phase 5 — Release signing assets

- [ ] Generate upload keystore
- [ ] Save keystore in secure storage
- [ ] Save keystore password in secure storage
- [ ] Save alias and alias password in secure storage
- [ ] Back up everything in at least two safe places
- [ ] Document where these are stored

### Done when
- [ ] You can safely upload future releases without risk of losing signing access

---

# Phase 6 — Privacy, legal, and compliance

## Hosted legal pages
- [ ] Publish privacy policy on a public URL
- [ ] Publish terms if you use them
- [ ] Verify in-app legal text matches hosted policy

## Store policy prep
- [ ] Review all SDKs/data flows before answering forms:
  - [ ] RevenueCat
  - [ ] Firebase
  - [ ] PostHog
  - [ ] Sentry
  - [ ] Anthropic
  - [ ] Google Sign-In
  - [ ] Apple Sign-In if used
- [ ] Complete Play Data safety accurately
- [ ] Complete App content declarations
- [ ] Complete content rating questionnaire
- [ ] Complete ads declaration accurately
- [ ] Confirm subscription/trial disclosures are clear in app and store
- [ ] Confirm account deletion/data export expectations are covered

### Done when
- [ ] There are no obvious Play review policy blockers

---

# Phase 7 — Store listing assets

## Copy
- [ ] Final app title
- [ ] Short description
- [ ] Full description
- [ ] Category chosen
- [ ] Contact email added
- [ ] Website/support URL added
- [ ] Privacy policy URL added

## Visual assets
- [ ] Final app icon
- [ ] Feature graphic
- [ ] Phone screenshots
- [ ] Optional tablet screenshots if needed

## Screenshot checklist
- [ ] Welcome / app value
- [ ] Discover feed
- [ ] Hobby detail
- [ ] Home / active hobby
- [ ] Coach
- [ ] You / journal
- [ ] Paywall

### Done when
- [ ] Store listing is polished enough to publish

---

# Phase 8 — Internal testing

- [ ] Create internal testing track
- [ ] Upload signed AAB
- [ ] Add release notes
- [ ] Add testers
- [ ] Publish to internal testing
- [ ] Install app from Play internal track link

## Test this manually
- [ ] App install works
- [ ] App update works
- [ ] Onboarding works
- [ ] Login works
- [ ] Google Sign-In works
- [ ] Hobby start works
- [ ] Session works
- [ ] Coach works
- [ ] Monthly purchase works
- [ ] Annual purchase works
- [ ] Restore works
- [ ] Pro unlock persists
- [ ] Logout/login entitlement state is correct
- [ ] Basic offline / poor network states are acceptable

### Done when
- [ ] You complete at least one real successful end-to-end purchase flow from Play internal testing

---

# Phase 9 — Closed testing / beta

- [ ] Decide whether your Play account requires closed testing before production
- [ ] Prepare tester list
- [ ] Prepare beta instructions
- [ ] Prepare feedback collection method
- [ ] Prepare support flow for testers

## What to ask beta testers
- [ ] Was onboarding clear?
- [ ] Did Discover feel useful?
- [ ] Was it easy to start a hobby?
- [ ] Was the session experience good?
- [ ] Does the coach feel useful?
- [ ] Does the paywall feel fair?
- [ ] Did anything crash or feel broken?
- [ ] Would you pay for Pro?

### Done when
- [ ] You have real external feedback, not just internal/dev testing

---

# Phase 10 — Launch monitoring setup

- [ ] Decide who checks crashes daily after launch
- [ ] Decide who checks purchase failures
- [ ] Decide who checks support inbox
- [ ] Decide which dashboard metrics you’ll watch daily

## Metrics to watch
- [ ] install → onboarding completion
- [ ] onboarding → hobby start
- [ ] hobby start → first session completion
- [ ] first session → day-2/day-3 return
- [ ] coach usage
- [ ] paywall conversion
- [ ] monthly vs annual mix
- [ ] crash-free sessions

### Done when
- [ ] You know exactly how you’ll judge launch health

---

# Phase 11 — Final pre-launch gate

Before production submission, confirm:

- [ ] Final package IDs are live everywhere
- [ ] Firebase matches final app identity
- [ ] Signed release AAB uploads successfully
- [ ] RevenueCat dashboard matches app expectations
- [ ] Play subscription products exist and are linked
- [ ] Purchases work in internal testing
- [ ] Privacy policy is public
- [ ] Data safety is completed accurately
- [ ] Store listing is complete
- [ ] Internal testing completed successfully
- [ ] Support email is monitored
- [ ] Launch monitoring is ready

### Done when
- [ ] You are actually ready to submit for review / production rollout

---

# Phase 12 — First thing to do now

## External Sprint 1
- [ ] Choose final package/bundle IDs
- [ ] Finalize Firebase app registrations
- [ ] Generate release keystore
- [ ] Create Play Console app
- [ ] Finalize RevenueCat entitlement/offering structure
- [ ] Create Play subscription products
- [ ] Prepare internal testing

That is the fastest route from “great beta” to “real release candidate.”