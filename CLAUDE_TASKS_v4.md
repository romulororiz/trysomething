# TrySomething — Task List v4 (Focused Redesign)

> **Strategy shift:** Stop building features. Start proving the core loop.
> **Core loop:** Choose 1 hobby → Start it → Do step 1 → Come back tomorrow
> **North star metric:** First session completed + day-7 return

## Rules
- Read `CLAUDE.md` before every session
- `view docs/mockups/<file>.png` before any UI work (for visual style only — CLAUDE.md defines structure)
- `dart analyze` on changed files after each task (NOT full flutter analyze)
- Full `flutter analyze` + `dart test` after each sprint

---

## Sprint A: Fix the Foundation (Week 1)

The app currently has broken trust in its core promise. Fix that first.

- [x] **A.1 — Fix onboarding matching logic (MOST CRITICAL TASK)**
  - Current `_computeMatchedHobbies()` barely uses budget or time inputs
  - Rebuild matching to actually filter/rank by ALL onboarding inputs:
    - Budget: filter hobbies where starter cost fits user's selected range
    - Time: filter hobbies where weekly commitment fits user's selected range
    - Indoor/outdoor: match user's "where" preference
    - Solo/social: match user's preference
    - Emotional intent: boost hobbies tagged with matching mood/vibe
  - Each hobby in the database needs: `starterCostMin`, `starterCostMax`, `weeklyHoursMin`, `weeklyHoursMax`, `isIndoor`, `isOutdoor`, `isSolo`, `isSocial` fields (add to Prisma model if missing, or derive from existing data)
  - Result: 3 matches (1 best + 2 alternatives), ordered by composite fit score
  - **Test:** User selects "under CHF 30, 1h/week, solo, at home" → NEVER gets recommended a hobby costing CHF 150+ or requiring 4h/week

- [x] **A.2 — Add "Why this fits you" to match results**
  - On each match card, show 2-3 specific reasons:
    - "Fits your CHF 30 budget" / "Works in 1h/week" / "Great for solo evenings at home"
  - These must come from actual matching logic, not generic text
  - Edit `lib/screens/onboarding/` match results section
  - **Test:** reasons are specific to the user's quiz answers, not the same for everyone

- [x] **A.3 — Fix empty states → loading states** *(skipped)*
  - Screens showing "No FAQ available" / "No combos" etc. when data is loading
  - Add shimmer placeholders (animate between #141420 and #1E1E2E) for loading state
  - Show actual empty state ONLY when API returns zero results
  - Add error state with "Tap to retry"
  - Fix across ALL data-dependent screens
  - **Test:** no screen ever shows "No data" while an API call is in progress

- [x] **A.4 — Fix feed category filter black flash**
  - Switching categories causes black screen flash
  - Wrap feed content in `AnimatedSwitcher` with `FadeTransition` (200ms)
  - Use `ValueKey(selectedCategory)` so switcher knows when to animate
  - Filter chips stay pinned/static — only card list below animates
  - **Test:** category switching is smooth, no black flash

- [ ] **A.5 — Instrument core analytics events**
  - Set up PostHog tracking for these events BEFORE any other work:
    - `onboarding_completed` (with quiz answers as properties)
    - `match_selected` (hobbyId, position: best/alt1/alt2)
    - `hobby_started` (hobbyId, budget_version)
    - `first_session_completed` (hobbyId, duration)
    - `day_3_return`, `day_7_return` (requires tracking first_open date)
    - `coach_message_sent` (hobbyId, mode: start/momentum/rescue)
    - `paywall_shown` (trigger context)
    - `hobby_switched`, `hobby_abandoned` (14+ days inactive)
  - Replace ALL console.log stubs in analytics_service.dart with real PostHog calls
  - **Test:** events fire correctly, visible in PostHog dashboard

---

## Sprint B: Restructure the App (Week 2-3)

Reduce from current tabs to 3. Build around one active hobby.
**NOTE:** Monetization (RevenueCat, Pro locks, coach, paywall, trial) already exists from v3 work. When restructuring screens, ADAPT existing Pro/coach integrations to new locations — don't rebuild them.

- [ ] **B.1 — Restructure navigation to 3 tabs**
  - New tabs: Home / Discover / You
  - **Home:** active hobby dashboard (new screen — see CLAUDE.md)
  - **Discover:** personalized picks + category browse + search
  - **You:** saved/tried hobbies, journal archive, profile, settings, subscription
  - Update `lib/router.dart` — new route structure
  - Update bottom nav component
  - **Test:** all 3 tabs navigate correctly, deep links work

- [ ] **B.2 — Hide secondary features from navigation**
  - Remove routes and nav entries for (do NOT delete code):
    - Buddy mode, Community stories, Local discovery
    - Hobby passport, Year in review, Weekly challenge
    - Mood match as standalone, Seasonal picks as standalone
    - Compare/battle as standalone (keep as tool inside Discover)
  - These screens stay in codebase but are unreachable from UI
  - **Test:** none of these features are accessible from any navigation path

- [ ] **B.3 — Build Home tab (active hobby dashboard)**
  - New screen: `lib/screens/home/home_screen.dart`
  - If user has active hobby:
    - Hobby card (image, title, current stage)
    - **Next step** — one clear action with description
    - **This week** — simple plan (day/time/duration, merged from old planner)
    - **Coach entry** — "Need help?" button with starter chips
    - **Recent progress** — last journal entry, streak, steps completed
    - **Restart flow** — if 3+ days inactive: "Pick up where you left off" or "Try something different"
  - If user has NO active hobby:
    - Warm prompt: "Ready to find your thing?" → routes to Discover/onboarding
  - **Test:** home shows correct active hobby data, next step updates on completion

- [ ] **B.4 — Rebuild Discover tab**
  - Replace current feed/explore with focused discovery:
  - 4 rails: "For You" (from onboarding) / "Start Cheap" (under CHF 30) / "Start This Week" (low setup) / "Need a Different Vibe?" (category browse)
  - Search bar at top with natural language support
  - Simple category filters: creative / active / mindful / social / outdoors / at home
  - Remove excessive novelty modules, social teasers, browse clutter
  - **Test:** rails show relevant hobbies, search handles natural queries

- [ ] **B.5 — Rebuild "You" tab**
  - Merge profile, settings, library, journal into one tab
  - Sections: Active hobby / Saved for later / Tried before (3 clear states)
  - Journal archive (all entries across hobbies)
  - Profile (simple: name, avatar, stats)
  - Subscription status + link to Pro screen
  - Settings
  - **Test:** all sections accessible, hobby states display correctly

---

## Sprint C: Make the Detail Page Convert (Week 3-4)

The hobby detail page is where someone decides to start. Make it action-first.

- [ ] **C.1 — Redesign hobby detail page structure**
  - **FIRST: `view docs/mockups/02_hobby_detail.png` for visual style**
  - New section order (per CLAUDE.md):
    1. Quick start snapshot (budget, time, difficulty, solo/social, location)
    2. "Why it fits you" (personalized from onboarding — reuse matching reasons)
    3. Easiest way to start ("Try this in 20 minutes: buy these 2 things, do this tiny session")
    4. Common reasons people quit (honest list — trust builder)
    5. Week 1 plan (not full roadmap)
    6. Full roadmap (expandable, secondary)
    7. Starter kit (minimum / best value / premium tiers, with images + buy links)
    8. Coach teaser ("Want help starting without overthinking?")
  - CTAs: "Start the easy version" / "Build my week 1 plan" / "Ask the coach"
  - **Test:** all sections render, CTAs navigate correctly

- [ ] **C.2 — Build commitment flow (Save vs Start)**
  - After user taps "Start this hobby":
    - Choice: "Save for later" or "Start now"
    - If "Start now": mini setup flow:
      - Choose budget version (minimum / best value)
      - Pick first session length (15min / 30min / 1hr)
      - Set preferred day/time
      - Define one tiny first action
    - → Generate Week 1 plan
    - → Hobby status → "Trying"
    - → Navigate to Home tab with active hobby
  - **Test:** full flow works, hobby appears on Home tab after commitment

- [ ] **C.3 — Build 4-stage roadmap view**
  - Replace generic step list with 4 stages:
    - Week 1: Try it
    - Week 2: Repeat it
    - Week 3: Reduce friction
    - Week 4: Decide if it fits
  - Show one stage at a time (not giant ladder)
  - Each stage: what to do, what to ignore, what success looks like
  - "Stuck?" button on every stage → routes to coach
  - **Test:** stages progress correctly, stuck button opens coach

- [ ] **C.4 — Add "Common reasons people quit" to each hobby**
  - Add `quittingReasons` field to Hobby model (String[] or separate model)
  - Seed 3-5 honest reasons per hobby in the 150 pre-seeded hobbies
  - Display as a section on hobby detail: "Why people stop" with practical, non-judgmental framing
  - Example: "People overbuy gear early — start with the minimum kit"
  - **Test:** reasons display for all seeded hobbies

---

## Sprint D: Coach + Monetization — ALREADY BUILT (Adapt Only)

These were built in the v3 sprint cycle. They exist and work. During Sprint B/C restructuring, they need to be ADAPTED to the new 3-tab architecture but NOT rebuilt from scratch.

- [X] **D.1 — AI Hobby Coach** — EXISTS. Adapt: add starter chips if missing, add 3 modes (start/momentum/rescue), move chat icon to new Home tab + Detail page.
- [X] **D.2 — RevenueCat integration** — EXISTS. No changes needed.
- [X] **D.3 — Upgrade bottom sheet** — EXISTS. Adapt: rewrite copy to emotional transformation language ("Start hobbies you actually stick with" / "Know the next step / Get unstuck fast / Track progress"). Remove feature-list framing.
- [X] **D.4 — Coach message limits + paywall** — EXISTS. No changes needed.
- [X] **D.5 — Pro locks on features** — EXISTS. Adapt: add multi-hobby lock (free = one active hobby). Remove locks on features that are now hidden (buddy mode, passport, etc.).
- [X] **D.6 — Trial offer screen** — EXISTS. Adapt: update copy if needed to match new emotional framing.
- [X] **D.7 — Settings Pro screen** — EXISTS. No changes needed.

**Sprint D adaptation happens DURING Sprints B and C, not as a separate phase.**
When restructuring a screen that has Pro locks or coach integration, adapt it to the new architecture inline.

---

## Sprint E: Polish & Launch (Week 5-6)

- [ ] **E.1 — Adapt coach to new architecture**
  - Add 6 starter chips to coach screen if not present: "Help me start tonight" / "Make this cheaper" / "What should I do next?" / "I'm losing motivation" / "I skipped a few days" / "Maybe this isn't for me"
  - Add 3 modes (start/momentum/rescue) — system prompt adapts based on user hobby state
  - Move coach entry point to Home tab ("Need help?" section) + Hobby Detail page
  - Rewrite upgrade sheet copy to emotional framing: "Start hobbies you actually stick with" / benefits: "Know the next step" / "Get unstuck fast" / "Track progress with photos"
  - Update Pro locks: remove locks on hidden features (buddy, passport, etc.), add multi-hobby lock (free = one active)
  - **Test:** coach accessible from Home + Detail, chips work, modes adapt to state, Pro copy updated

- [ ] **E.2 — Brand assets (app icon + splash)**
  - App icon: brushstroke T, configure flutter_launcher_icons
  - Splash: wordmark + "Find a hobby you'll actually start" + tagline
  - Login: icon above "Welcome back"
  - **Test:** icon renders on both platforms, splash transitions

- [ ] **E.3 — Re-engagement notifications**
  - Build simple notification flow for:
    - User chose hobby but never started (24h after save): "Ready to try {hobby}? The first session is just {duration}."
    - User started but went silent (3 days): "Still interested in {hobby}? Try a quick 10-minute session tonight."
    - User completed a step (immediate): "{step} done! When you're ready, here's what comes next."
  - Use existing Firebase push notification system
  - Gentle, specific, action-oriented — NOT nagging
  - **Test:** notifications fire at correct triggers on physical device

- [ ] **E.4 — Performance pass**
  - 60fps scroll, CachedNetworkImage, APK < 30MB
  - Riverpod .select() where over-watching
  - **Test:** no jank, bundle size target met

- [ ] **E.5 — End-to-end testing**
  - Full flows on physical device:
    - Onboarding → match → start → complete step → day 7
    - Free → hit coach limit → upgrade → Pro
    - Trial → expire → lock → upgrade
  - **Test:** all flows work on Nothing Phone 3a

- [ ] **E.6 — App store prep**
  - Metadata, privacy policy, screenshots with final UI
  - iOS signing via Codemagic, Android release signing
  - **Test:** builds accessible on TestFlight + Play Console

- [ ] **E.7 — Beta launch**
  - 10 iOS + 10 Android testers
  - Mix of free and Pro testers
  - In-app feedback mechanism
  - **Test:** testers can install, use, submit feedback