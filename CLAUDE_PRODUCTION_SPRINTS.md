# CLAUDE_PRODUCTION_SPRINTS.md

> **Goal:** Finish all remaining in-repo work needed to make TrySomething production-ready.
> **Scope:** Code changes, UI/UX completion, coach premiumization, payments wiring in code, backend endpoints, QA implementation, cleanup.
> **Out of scope:** RevenueCat dashboard, Play Console, Firebase console, screenshots, legal publishing, tester ops. Those are in `HUMAN_LAUNCH_CHECKLIST.md`.

## Rules
- [ ] Read `CLAUDE.md` before every session
- [ ] Read `AGENTS.md` before every session
- [ ] Read `PRODUCT_GUARDRAILS.md` before every session
- [ ] Read `VISUAL_REDESIGN_PROMPT.md` before any UI work
- [ ] One sprint per branch
- [ ] `dart analyze` on changed files after each task
- [ ] Full `flutter analyze` + `dart test` after each sprint
- [ ] Do not add new features unless listed here
- [ ] Keep teal + burgundy atmosphere
- [ ] Keep Home / Discover / You architecture
- [ ] Prioritize production blockers before premium polish

---

## Sprint P0 — App identity and release-blocker setup

- [ ] **P0.1 — Replace placeholder package IDs**
  - Replace `com.example.trysomething` everywhere in Android
  - Replace placeholder iOS bundle identifiers everywhere if iOS remains in scope
  - Update Kotlin package path
  - Update app display naming consistency
  - **Test:** no placeholder IDs remain in repo

- [ ] **P0.2 — Prepare production release signing**
  - Add secure release signing config support
  - Remove debug signing from release build path
  - Verify release AAB builds successfully
  - **Test:** signed release AAB builds without debug signing

- [ ] **P0.3 — Harden RevenueCat code config**
  - Remove any fallback test RevenueCat key
  - Require explicit production SDK keys
  - Fail loudly in release if keys are missing
  - Confirm entitlement string matches real production entitlement
  - Confirm offering/package assumptions match intended dashboard setup
  - **Test:** app is code-ready for real purchases

- [ ] **P0.4 — Fix Android paywall compatibility**
  - Ensure `MainActivity` uses `FlutterFragmentActivity` if RevenueCat paywalls require it
  - Verify manifest launchMode remains compatible
  - **Test:** Android paywall flow is compatible with RevenueCat docs

- [ ] **P0.5 — Finish critical core-loop TODOs**
  - Complete session → journal save path
  - Complete step completion persistence
  - Complete progress/streak updates if intended
  - Complete analytics for critical funnel events
  - Decide on photo journal: finish or hide for production
  - **Test:** no critical TODO remains in onboarding → start → session → return flow

- [ ] **P0.6 — Production error handling**
  - Replace placeholder error reporting with real production Sentry usage
  - Capture framework + async errors
  - Add safe user-facing error states for payment, coach, session, and API failures
  - **Test:** app fails gracefully and reports errors correctly

---

## Sprint P1 — Backend production hardening

- [ ] **P1.1 — Environment and API safety**
  - Audit production environment variables
  - Remove unsafe defaults
  - Verify production base API URL handling
  - Verify auth refresh handling
  - **Test:** release build uses correct backend config

- [ ] **P1.2 — Account deletion**
  - Add backend endpoint for account deletion
  - Add necessary auth checks and cleanup flow
  - Add app-side integration path if not already implemented
  - **Test:** user can request real account deletion

- [ ] **P1.3 — Data export**
  - Add backend endpoint for user data export if required by product/policy
  - Add app-side trigger or support path if needed
  - **Test:** export path exists and is usable

- [ ] **P1.4 — AI / coach / generation safeguards**
  - Verify rate limits
  - Verify logs do not expose sensitive payloads
  - Verify backend errors are structured safely
  - **Test:** backend is safer for real-user traffic

- [ ] **P1.5 — Apple auth route fix**
  - Fix backend Apple auth route/config if iOS remains in launch scope
  - **Test:** Apple auth route works correctly in non-local environments

---

## Sprint P2 — Coach premium rebuild

> This is the most important remaining premiumization sprint.

- [ ] **P2.1 — Rebuild coach screen architecture**
  - Turn coach into a guidance workspace, not generic chat
  - Add premium context hero:
    - hobby
    - stage/week
    - next step
    - mode
    - last active context
  - Add segmented mode switch:
    - Start
    - Momentum
    - Rescue
  - Replace current empty state
  - Reduce composer dominance
  - **Test:** coach feels valuable before typing

- [ ] **P2.2 — Structured coach responses**
  - Add renderer for structured assistant cards
  - Build:
    - Tonight’s easiest plan card
    - Cheaper way to start card
    - Restart gently card
    - Reflection card
    - Week-plan update card
  - Keep plain text as fallback only
  - **Test:** assistant can return structured premium guidance

- [ ] **P2.3 — Premium quick actions**
  - Replace simple chips with richer quick-action surfaces
  - Add:
    - Help me start tonight
    - Make this cheaper
    - What should I do next?
    - I skipped a few days
    - I’m losing motivation
    - Maybe this hobby isn’t for me
  - Make actions mode-aware
  - **Test:** users can use coach without typing

- [ ] **P2.4 — Integrate coach into main product flow**
  - Improve Home → Coach context
  - Improve Detail → Coach context
  - Improve Roadmap stuck → Coach flow
  - Improve Journal ↔ Coach connection
  - Let coach-driven week-plan updates affect Home
  - **Test:** coach no longer feels isolated

- [ ] **P2.5 — Coach premium value**
  - Reframe free coach around starter value + rescue proof
  - Reframe Pro around continuity/adaptive guidance
  - Improve coach-related upgrade timing and language
  - **Test:** coach feels like a strong reason to subscribe

---

## Sprint P3 — Overlay system rebuild

- [ ] **P3.1 — Create shared overlay primitives**
  - Build `AppSheet`
  - Build `AppConfirmDialog`
  - Build `AppSnackbar`
  - Build fullscreen modal pattern if needed
  - **Test:** all new overlays use one system

- [ ] **P3.2 — Replace legacy popups/dialogs**
  - Audit Settings
  - Audit Profile edit
  - Audit Detail quick actions
  - Audit Home prompts
  - Audit Journal prompts
  - Replace stock-looking dialog patterns
  - **Test:** no stock Material dialog remains in primary UX

- [ ] **P3.3 — Standardize overlay design**
  - Radius
  - Padding
  - CTA hierarchy
  - Handle styling
  - Typography
  - Blur/material
  - **Test:** overlays feel premium and coherent

---

## Sprint P4 — Typography reset

- [ ] **P4.1 — Simplify type system**
  - Make primary UI/system font consistent
  - Restrict serif to rare editorial moments
  - Remove decorative mono use except real functional need
  - **Test:** type system feels unified

- [ ] **P4.2 — Apply hierarchy cleanup**
  - Audit Welcome, Onboarding, Discover, Search, Detail, Home, Roadmap, Coach, Journal, You, Settings, Paywall
  - Reduce over-designed moments
  - Tighten spacing, line-height, and emphasis
  - **Test:** typography feels premium-modern everywhere

---

## Sprint P5 — Full visual consistency pass

- [ ] **P5.1 — Keep atmosphere, unify surfaces**
  - Retain teal + burgundy background
  - Harmonize all cards/surfaces with it
  - **Test:** atmosphere feels intentional, not conflicting

- [ ] **P5.2 — Reduce accent overuse**
  - Audit coral usage
  - Keep one clear primary accent moment per screen where possible
  - **Test:** screens feel calmer and more expensive

- [ ] **P5.3 — Material hierarchy pass**
  - Audit grounded vs floating vs focal surfaces
  - Standardize metadata treatment
  - Standardize CTA hierarchy
  - Standardize loading/empty/error states
  - **Test:** app feels like one brand

---

## Sprint P6 — Screen-by-screen premium cleanup

- [ ] **P6.1 — Welcome**
  - Make hero statement more iconic
  - Reduce extra explanation
  - Improve CTA confidence

- [ ] **P6.2 — Onboarding**
  - Simplify question screens
  - Improve selected states
  - Improve progress treatment

- [ ] **P6.3 — Match Results**
  - Strengthen best-match dominance
  - Quiet alternatives
  - Improve why-it-fits scanability

- [ ] **P6.4 — Discover**
  - Tighten feed/list hierarchy
  - Refine tab treatment
  - Refine card density
  - Reduce residual feed/content feel

- [ ] **P6.5 — Search**
  - Improve intelligence feel
  - Better result grouping
  - Better premium transition from Discover

- [ ] **P6.6 — Hobby Detail**
  - Tighten easiest-start emphasis
  - Tighten CTA stack
  - Reduce upper-half visual competition

- [ ] **P6.7 — Start Now / Week 1**
  - Reduce configuration feel
  - Improve setup progression
  - Improve generated plan confirmation state

- [ ] **P6.8 — Session**
  - Final QA on completion states
  - Final QA on reflection handoff

- [ ] **P6.9 — Home**
  - Reduce dashboard feel
  - Strengthen one-hobby centrality
  - Tighten support module hierarchy

- [ ] **P6.10 — Roadmap**
  - Emphasize current stage
  - Quiet future stages
  - Reduce task-management tone

- [ ] **P6.11 — Journal**
  - Make softer and more reflective
  - Improve progression integration

- [ ] **P6.12 — You**
  - Reduce accent overload
  - Clarify Active / Saved / Tried hierarchy
  - Reduce account-area feel

- [ ] **P6.13 — Settings**
  - Improve spacing/hierarchy
  - Ensure overlay system is applied
  - Remove remaining stock-feel

- [ ] **P6.14 — Paywall**
  - Tighten hero composition
  - Improve plan selector
  - Ensure purchase UI states are polished

### Done when
- [ ] Every primary screen feels finished, not “implemented then improved”

---

## Sprint P7 — Analytics, QA, and performance

- [ ] **P7.1 — Analytics completion**
  - Verify all critical events fire
  - Verify purchase-related events
  - Verify coach-related events
  - Verify funnel continuity metrics
  - **Test:** analytics are trustworthy

- [ ] **P7.2 — Performance/device pass**
  - Verify Discover feed smoothness
  - Verify Search transition smoothness
  - Verify Session performance
  - Verify overlay performance
  - Verify keyboard handling on Coach/Journal/Login
  - Verify safe-area handling with floating dock
  - **Test:** no major jank or clipping on real device

- [ ] **P7.3 — Purchase QA in-app**
  - Verify paywall opens correctly
  - Verify purchase success state
  - Verify restore success state
  - Verify logged-in/logged-out state transitions
  - **Test:** app-side purchase UX is stable

---

## Sprint P8 — Refactor and cleanup

- [ ] **P8.1 — Refactor oversized screens**
  - Break Home into sections
  - Break Discover into sections
  - Break Search into sections
  - Break Detail into sections
  - Break Coach into sections
  - Break You into sections
  - Break Settings into sections
  - **Test:** files are easier to maintain and polish

- [ ] **P8.2 — Remove dead/legacy code pressure**
  - Remove retired paths where safe
  - Isolate legacy product mass where not removed
  - Clean leftover naming and structural artifacts
  - **Test:** main product direction is not being dragged by old code

---

## Final definition of done

- [ ] Final package IDs are implemented
- [ ] Signed release AAB builds
- [ ] RevenueCat code is production-safe
- [ ] Core-loop TODOs are complete
- [ ] Coach feels premium and worth paying for
- [ ] Overlays are unified
- [ ] Typography is resolved
- [ ] Visual consistency is strong
- [ ] Analytics/crash handling are production-ready
- [ ] Primary screens feel launch-ready