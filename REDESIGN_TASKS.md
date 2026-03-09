# TrySomething — Redesign Task Tracker

> Master tracking document for the focused redesign.
> Reference: `CLAUDE.md` for specs, `PRODUCT_GUARDRAILS.md` for principles, `VISUAL_REDESIGN_PROMPT.md` for visual patterns.

---

## Phase 0: Planning

- [x] Create PRODUCT_GUARDRAILS.md
- [x] Create REDESIGN_TASKS.md (this file)
- [ ] Audit current codebase: identify all screens, routes, and nav entries that need changes
- [ ] Map current state to target state for each of the 3 tabs

---

## Phase 1: Fix the Foundation (Sprint A)

- [x] A.1 — Fix onboarding matching logic (use ALL inputs: budget, time, indoor/outdoor, solo/social, emotional intent)
- [x] A.2 — Add "Why this fits you" to match results (personalized explanation on each card)
- [x] A.3 — Fix empty states / loading states
- [x] A.4 — Fix feed category filter black flash
- [x] A.5 — Instrument core analytics events (onboarding_completed, match_selected, hobby_started, first_session_completed, day_3_return, day_7_return, day_30_active, coach_message_sent, coach_limit_reached, paywall_shown, trial_started, subscription_purchased, hobby_switched, hobby_abandoned)

---

## Phase 2: Restructure the App (Sprint B)

- [x] B.1 — Restructure navigation to 3 tabs (Home / Discover / You)
- [x] B.2 — Hide secondary features from navigation (buddy mode, community stories, local discovery, hobby passport, year in review, weekly challenge, compare standalone, mood match standalone, seasonal picks standalone)
- [x] B.3 — Build Home tab (active hobby dashboard with next step, weekly plan, coach entry, progress, restart flow)
- [x] B.4 — Rebuild Discover tab (4 rails, category browse, NL search, compare as secondary tool)
- [x] B.5 — Rebuild You tab (active/saved/tried hobbies, journal archive, profile, subscription, settings)

---

## Phase 3: Visual Overhaul — Color & Typography (Sprint C.1)

- [x] C.1 — Update color palette in app_colors.dart (warm cream text, warm grays, coral for CTAs only, glass surfaces, remove amber/indigo/category colors)
- [x] C.1 — Update typography in app_typography.dart (hero 36pt Source Serif 4, display 28pt, body 15pt DM Sans, caption 12pt, overline 11pt, dataLarge 48pt IBM Plex Mono)

---

## Phase 4: Visual Overhaul — Components (Sprint C.2-C.3)

- [x] C.2 — Create glass card component (semi-transparent bg, subtle border, blur variant, scale-to-0.97 press, child/onTap/padding/blur params)
- [x] C.3 — Redesign bottom navigation as floating glass dock (3 icons, no labels, glass background, rounded corners, floating, safe area aware)

---

## Phase 5: Visual Overhaul — Screen Redesigns (Sprint C.4-C.8)

- [x] C.4 — Redesign Discover tab with hero card layout (full-width hero, "More for You" pairs, "Start Cheap" rail, "Start This Week" rail)
- [x] C.5 — Redesign Home tab with cinematic layout (warm greeting, next step glass card, weekly plan, coach entry, stalled state, staggered fade-in)
- [x] C.6 — Strip all colored badges everywhere and replace with warm gray middot text lines
- [x] C.7 — Update CTA buttons + enforce one-coral-CTA-per-screen rule across all screens
- [x] C.7.1 — Redesign You tab with warm cinematic aesthetic (active/saved/tried sections, journal link, subscription row, settings row)
- [x] C.8 — Apply visual system to all remaining screens (search results, journal, coach chat, library, profile, settings, pro screen, trial offer, quickstart sheet, login, onboarding)

---

## Phase 6: Visual QA (Sprint C.9)

- [x] C.9 — Sprint C visual QA on physical device (60fps glass effects, noise texture, typography hierarchy, no stray colors, one coral CTA per screen, floating dock, smooth animations)

---

## Phase 7: Detail Page & Conversion (Sprint D)

- [x] D.1 — Redesign hobby detail page (full-bleed image, gradient fade, category overline, hero title, specs, "Why this fits you", "Start in 20 minutes", roadmap preview, starter kit, coach teaser, floating coral CTA)
- [x] D.2 — Build commitment flow (save vs start, mini setup: budget version, session length, day/time, first action, generate week 1 plan, hobby → "Trying", navigate to Home)
- [x] D.3 — Build 4-stage roadmap view (Week 1: Try it, Week 2: Repeat it, Week 3: Reduce friction, Week 4: Decide, one stage at a time, "Stuck?" → coach)
- [x] D.4 — Add "Common reasons people quit" to each hobby (quittingReasons field, 3-5 reasons per hobby, glass card section)

---

## Phase 8: Coach & Monetization Adaptation (Sprint E)

- [x] E.1 — Adapt AI Hobby Coach (add 6 starter chips, 3 modes: start/momentum/rescue, move entry to Home + Detail)
- [x] E.2 — RevenueCat integration (exists, no changes)
- [x] E.3 — Adapt upgrade bottom sheet (rewrite copy to emotional framing)
- [x] E.4 — Coach message limits + paywall (exists, no changes)
- [x] E.5 — Adapt Pro locks (add multi-hobby lock, remove hidden feature locks)
- [x] E.6 — Adapt trial offer screen (warm cinematic visual style)
- [x] E.7 — Adapt settings Pro screen (warm cinematic visual style)

---

## Phase 9: Polish — Coach & Notifications (Sprint F.1-F.2)

- [x] F.1 — Adapt coach to new architecture + visual system (starter chips, 3 modes, Home + Detail entry, glass chat bubbles, Pro copy, Pro locks)
- [x] F.2 — Re-engagement notifications (saved but not started 24h, silent 3 days, completed step immediate)

---

## Phase 10: Performance & Testing (Sprint F.3-F.4)

- [x] F.3 — Performance pass (60fps scroll with glass effects, CachedNetworkImage with memCacheWidth, APK < 30MB, BackdropFilter limit 3-5 per screen)
- [ ] F.4 — End-to-end testing on physical device (onboarding → match → start → complete step → day 7 return; free → coach limit → upgrade → Pro; trial → expire → lock → upgrade; visual QA every screen)

---

## Phase 11: Launch Prep (Sprint F.5-F.6)

- [ ] F.5 — App store prep (metadata, privacy policy, screenshots with cinematic design, iOS signing via Codemagic, Android release signing)
- [ ] F.6 — Beta launch (10 iOS + 10 Android testers, mix free/Pro, in-app feedback mechanism)
