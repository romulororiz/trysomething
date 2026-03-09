# TrySomething — Task List v4.1 (Focused Redesign + Visual Overhaul)

> **Strategy:** Prove the core loop. Make the app feel premium.
> **Core loop:** Choose 1 hobby → Start it → Do step 1 → Come back tomorrow
> **Visual direction:** Warm Cinematic Minimalism — DoReset restraint + Headspace warmth

## Rules
- Read `CLAUDE.md` before every session
- Read `VISUAL_REDESIGN_PROMPT.md` before any UI work — it defines the new aesthetic
- `dart analyze` on changed files after each task (NOT full flutter analyze)
- Full `flutter analyze` + `dart test` after each sprint

---

## Sprint A: Fix the Foundation ✅ DONE

- [x] **A.1 — Fix onboarding matching logic**
- [x] **A.2 — Add "Why this fits you" to match results**
- [x] **A.3 — Fix empty states → loading states** *(skipped)*
- [x] **A.4 — Fix feed category filter black flash**
- [x] **A.5 — Instrument core analytics events**

---

## Sprint B: Restructure the App ✅ DONE

- [x] **B.1 — Restructure navigation to 3 tabs**
- [x] **B.2 — Hide secondary features from navigation**
- [x] **B.3 — Build Home tab (active hobby dashboard)**
- [x] **B.4 — Rebuild Discover tab**
- [x] **B.5 — Rebuild "You" tab**

---

## Sprint C: Visual Overhaul — Warm Cinematic Minimalism (Week 3-4)

The app works but looks generic. This sprint transforms it from "competent dark mode" to "premium editorial." Follow `VISUAL_REDESIGN_PROMPT.md` for full details and code patterns.

- [X] **C.1 — Update color palette + typography scale**
  - Replace current palette in `lib/theme/app_colors.dart` with warm cinematic palette:
    - Text: warm cream (#F5F0EB), not pure white
    - Secondary: warm grays (#B0A89E, #6B6360), not cool grays
    - ONE accent: coral (#FF6B6B) for CTAs ONLY
    - Glass surfaces: white at 8% opacity with 12% border
    - REMOVE: amber, indigo, all category-specific colors from active use
  - Replace typography in `lib/theme/app_typography.dart`:
    - Hero: 36pt Source Serif 4 (cinematic headlines)
    - Display: 28pt (section titles)
    - Body: 15pt DM Sans warm gray
    - Caption: 12pt, Overline: 11pt uppercase
    - DataLarge: 48pt IBM Plex Mono (for big stats like "2%")
    - Ratio between hero and caption should be ~3.3x (cinematic contrast)
  - **Test:** `dart analyze` clean, app renders with new colors/fonts without crashes

- [X] **C.2 — Create glass card component**
  - Create `lib/components/glass_card.dart`:
    - Semi-transparent background (white at 8%)
    - Subtle border (white at 12%)
    - BackdropFilter blur (sigma 12) for static/hero elements
    - Simple glass (no blur) variant for scrollable lists (performance)
    - Scale-to-0.97 on press animation
    - Accepts: child, onTap, padding, blur (bool)
  - **Test:** glass card renders correctly, no performance issues

- [X] **C.3 — Redesign bottom navigation as floating glass dock**
  - Replace current curved_nav bar with floating glass dock:
    - Glass background with blur, rounded corners (28px radius)
    - Horizontal margins (40px each side), floating above bottom
    - 3 icons only: Home / Discover / You — NO labels
    - Active icon: warm cream, Inactive: warm dark gray (#3D3835)
    - NO coral on nav — coral is ONLY for CTAs
  - Account for safe area: `MediaQuery.of(context).padding.bottom + 12` as bottom margin
  - Ensure all screens account for new nav height in bottom padding
  - **Test:** nav floats correctly, icons switch, no overlap with content

- [X] **C.4 — Redesign Discover tab with hero card layout**
  - Replace current rail-based layout with cinematic discovery:
    - Search bar: glass-style, floating, subtle
    - NO category filter chips at top — move filtering to icon on search bar → opens bottom sheet
    - Hero card: FULL WIDTH, 55-60% screen height
      - Atmospheric hobby image (muted warm tones, editorial style)
      - Category overline in warm gray ("CREATIVE")
      - Hobby title in hero text (36pt) over gradient
      - One-line hook in body text
      - Specs as one warm gray line: "CHF 40-120 · 2h/week · Easy"
      - This is the user's #1 recommended hobby
    - Below hero: "MORE FOR YOU" overline section
      - 2 smaller glass cards side by side (alternatives #2 and #3)
    - Below: "START CHEAP" section — horizontal scroll of compact cards
    - Below: "START THIS WEEK" section — horizontal scroll
    - Far fewer elements visible at once. The hero dominates.
  - **Test:** hero shows personalized #1 match, rails scroll, search opens

- [X] **C.5 — Redesign Home tab with cinematic layout**
  - Apply warm cinematic aesthetic to the Home tab:
    - Warm greeting: "Good evening" in hero text (36pt)
    - "Week 2 of Pottery" in overline
    - Glass card: "Your next step" — one clear action in display text, specs in data text, coral CTA "Start session"
    - Glass card: "This week" — simple 3-line plan
    - Glass card: "Need help?" — coach entry with starter chips
    - If stalled 3+ days: warm message with "Let's go" (coral) / "Maybe later" (text)
    - NO stats/graphs/streaks on home — those live in You tab
    - Staggered fade-in animation on all elements (flutter_animate)
  - **Test:** layout matches cinematic style, animations play smoothly

- [X] **C.6 — Strip all colored badges → warm gray text**
  - REMOVE the current colored badge/pill system across EVERY screen
  - Replace with single-line warm gray text using middot separators:
    - Old: [💰 CHF 40-120] [⏱ 2h/week] [📊 Easy] (3 colored pills)
    - New: `CHF 40-120 · 2h/week · Easy` (one line, AppColors.textMuted, AppTypography.data)
  - Apply to: feed cards, detail page, search results, match results, library cards, everywhere badges appear
  - Remove all badge background colors, icons, and pill shapes
  - **Test:** no colored badges anywhere in the app, all specs render as warm gray text

- [x] **C.7 — Update CTA buttons + apply one-CTA-per-screen rule**
  - Primary CTA: coral background, rounded (16px), subtle glow shadow, dark text
  - Secondary CTA: no background, warm cream text, subtle underline or arrow
  - ONE coral CTA per screen maximum. Audit every screen:
    - If multiple coral buttons exist, demote all but the primary to secondary style
  - Update paywall/upgrade sheet copy to emotional language:
    - "Start hobbies you actually stick with"
    - Benefits: "Know the next step" / "Get unstuck fast" / "Track progress with photos"
    - No feature-list framing, no bullet points
  - **Test:** only one coral CTA visible per screen, upgrade sheet copy updated


 - [x] **Task C.7.1 — Redesign "You" tab with warm cinematic aesthetic**

Read CLAUDE.md and VISUAL_REDESIGN_PROMPT.md first for the full visual system.

Redesign the You tab (`lib/screens/profile/` or wherever the You/Profile tab lives) to match the warm cinematic minimalism direction. This tab should feel like a calm, personal space — not a dashboard.

### Layout (top to bottom):

**Header:**
- User name in serif (display, 28pt), warm cream
- Small avatar to the left
- No banner, no cover image, no elaborate header

**ACTIVE section:**
- "ACTIVE" overline label (11pt, uppercase, warm dark gray, letter-spaced)
- One prominent glass card showing current hobby:
  - Hobby image (small, rounded), title in title text (20pt serif)
  - Current stage: "Week 2 · Centering the clay" in data text (mono, warm gray)
  - Progress indicator (subtle, warm cream thin bar)
  - Tapping navigates to Home tab
- If no active hobby: warm prompt "Start your first hobby" with coral CTA linking to Discover

**SAVED FOR LATER section:**
- "SAVED FOR LATER" overline label
- Smaller glass cards in a vertical list, each showing:
  - Hobby title in warm cream
  - Specs in warm gray middot line: "CHF 40-120 · 2h/week · Easy"
  - Tapping navigates to hobby detail
- If empty: "Explore hobbies to save some for later" in warm gray, no card

**TRIED BEFORE section:**
- "TRIED BEFORE" overline label
- Even more subtle glass cards (lower opacity than Saved cards)
  - Hobby title, how long they tried it: "2 weeks in Oct 2025"
  - Warm dark gray text — this section is quiet, not prominent
- If empty: don't show this section at all

**Journal link:**
- Glass card or simple row: "Journal" with right arrow, warm cream text
- Tapping opens journal archive (all entries across all hobbies)

**Subscription row:**
- Glass card or simple row: "TrySomething Pro" with coral sparkle icon
- Shows status: "Free Plan" / "Pro (renews Mar 2027)" / "Trial (5 days left)" in warm gray
- Tapping opens Pro screen

**Settings row:**
- Simple row: "Settings" with right arrow, warm gray text
- Tapping opens settings screen

### What NOT to include:
- NO radar chart
- NO activity heatmap
- NO year-in-review
- NO hobby passport
- NO achievements grid
- NO stats dashboard
- NO elaborate profile header with bio/badges
- These are all deferred until core retention is proven

### Visual rules:
- All cards are glass cards (semi-transparent, subtle blur for static elements)
- Only coral element: the CTA if no active hobby. Everything else is warm cream / warm gray
- Staggered fade-in on screen entry (flutter_animate: 400ms, 100ms delay between elements)
- Scale-to-0.97 on card press
- Generous padding between sections
- The tab should feel quiet, personal, calm

### Test:
- `dart analyze` on changed files
- Active/Saved/Tried states display correctly
- Empty states render properly
- Navigation to Home, Detail, Journal, Pro, Settings all work
- Verify on Nothing Phone 3a — check safe areas and bottom nav clearance

- [X] **C.8 — Apply visual system to remaining screens**
  - Go through EVERY remaining screen and apply:
    - Warm cream text (not pure white)
    - Glass cards (not solid dark cards)
    - No colored badges (warm gray middot text)
    - Staggered fade-in on screen entry (flutter_animate)
    - Scale-down on card press
    - Noise texture on scaffold (via wrapper)
    - Dramatic typography hierarchy
    - Generous negative space
  - Screens to update:
    - Search results
    - Journal
    - Coach chat interface
    - Library (saved/tried/active in You tab)
    - Profile section (in You tab)
    - Settings
    - Pro/upgrade screen
    - Trial offer screen
    - Quickstart bottom sheet
    - Login
    - Onboarding (all pages) — option selection uses warm cream border highlight, not teal/green
  - **Test:** every screen follows the new visual system, no remnants of old colored badge style

- [X] **C.9 — Sprint C visual QA on physical device**
  - Run full `flutter analyze`
  - Test on Nothing Phone 3a:
    - Glass blur effects: smooth at 60fps? If jank on scrollable lists, switch to simple glass (no blur)
    - Noise texture: visible but not distracting?
    - Typography hierarchy: hero text feels cinematic, not just "big"?
    - Color: no stray amber/indigo/category colors anywhere?
    - One coral CTA per screen: verified?
    - Bottom nav: floating dock looks correct, no overlap?
    - Animations: stagger reveals feel smooth, not janky?
  - Fix any issues found
  - **Test:** entire app passes visual QA on physical device

---

## Sprint D: Make the Detail Page Convert (Week 5)

Now that the visual system is in place, build the detail page using it.

- [X] **D.1 — Redesign hobby detail page**
  - Full-bleed atmospheric image (50% screen height) with gradient fade to black
  - Category overline over image ("CREATIVE" in warm gray)
  - Hobby title in hero text (36pt) over image
  - Hook line in body text over image
  - Specs as warm gray middot line below image
  - Glass card: "Why this fits you" — personalized onboarding reasons
  - Glass card: "Start in 20 minutes" — minimum viable first session, 2 items to buy, one tiny action
  - Glass card: "What to expect" — 4-stage roadmap preview (Week 1-4) as simple text lines
  - Glass card: "Starter kit" — product images + prices + buy links, minimum/best value toggle
  - Coach teaser: "Want help starting without overthinking?"
  - Floating coral CTA at bottom: "Start the easy version"
  - All with staggered fade-in animation
  - **Test:** all sections render, CTA navigates to commitment flow

- [X] **D.2 — Build commitment flow (Save vs Start)**
  - After user taps main CTA:
    - Glass bottom sheet: "Save for later" or "Start now"
    - If "Start now": mini setup flow:
      - Choose budget version (minimum / best value)
      - Pick first session length (15min / 30min / 1hr)
      - Set preferred day/time
      - Define one tiny first action
    - → Generate Week 1 plan
    - → Hobby status → "Trying"
    - → Navigate to Home tab with active hobby
  - **Test:** full flow works, hobby appears on Home tab

- [X] **D.3 — Build 4-stage roadmap view**
  - Replace generic step list with 4 stages:
    - Week 1: Try it / Week 2: Repeat it / Week 3: Reduce friction / Week 4: Decide
  - Show one stage at a time in glass cards
  - Each stage: what to do, what to ignore, what success looks like
  - "Stuck?" button → routes to coach
  - **Test:** stages progress correctly, stuck button opens coach

- [X] **D.4 — Add "Common reasons people quit" to each hobby**
  - Add `quittingReasons` field to Hobby model (String[])
  - Seed 3-5 honest reasons per hobby
  - Display as glass card section: "Why people stop" — warm, non-judgmental framing
  - Example: "People overbuy gear early — start with the minimum kit"
  - **Test:** reasons display for seeded hobbies

---

## Sprint E: Coach + Monetization Adaptation — ALREADY BUILT

These exist from v3. Adapt during Sprints C and D inline.

- [X] **E.1 — AI Hobby Coach** — EXISTS. Adapt: add starter chips, 3 modes, move to Home + Detail.
- [X] **E.2 — RevenueCat integration** — EXISTS. No changes needed.
- [X] **E.3 — Upgrade bottom sheet** — EXISTS. Adapt: rewrite copy to emotional framing during C.7.
- [X] **E.4 — Coach message limits + paywall** — EXISTS. No changes needed.
- [X] **E.5 — Pro locks on features** — EXISTS. Adapt: add multi-hobby lock, remove hidden feature locks.
- [X] **E.6 — Trial offer screen** — EXISTS. Adapt: update to warm cinematic visual style during C.8.
- [X] **E.7 — Settings Pro screen** — EXISTS. Adapt: update visual style during C.8.

---

## Sprint F: Polish & Launch (Week 6-7)

- [X] **F.1 — Adapt coach to new architecture + visual system**
  - Add 6 starter chips if not present
  - Add 3 modes (start/momentum/rescue)
  - Move coach entry to Home tab + Detail page
  - Apply glass card styling to chat bubbles (coach = glass, user = coral tint)
  - Update Pro copy to emotional framing
  - Update Pro locks: remove hidden feature locks, add multi-hobby lock
  - **Test:** coach accessible from Home + Detail, visual style matches


- [X] **F.2 — Re-engagement notifications**
  - User saved but never started (24h): "Ready to try {hobby}? First session is just {duration}."
  - User went silent (3 days): "Still interested in {hobby}? Try a quick 10-minute session tonight."
  - User completed step (immediate): "{step} done! Here's what comes next."
  - Gentle, warm, action-oriented — matches brand voice
  - **Test:** notifications fire at correct triggers

- [X] **F.3 — Performance pass**
  - 60fps scroll with glass effects (switch to simple glass on heavy scroll lists if needed)
  - CachedNetworkImage with memCacheWidth
  - APK < 30MB
  - BackdropFilter limited to 3-5 per visible screen (performance guard)
  - **Test:** no jank on Nothing Phone 3a, bundle size target met

- [ ] **F.4 — End-to-end testing**
  - Full flows on physical device:
    - Onboarding → match → start → complete step → return day 7
    - Free → hit coach limit → upgrade → Pro
    - Trial → expire → lock → upgrade
    - Visual: every screen follows warm cinematic system, no old style remnants
  - **Test:** all flows work on Nothing Phone 3a

- [ ] **F.5 — App store prep**
  - Metadata, privacy policy, screenshots with FINAL premium visual design
  - iOS signing via Codemagic, Android release signing
  - Screenshots should showcase the cinematic hero cards, glass surfaces, warm typography
  - **Test:** builds accessible on TestFlight + Play Console

- [ ] **F.6 — Beta launch**
  - 10 iOS + 10 Android testers
  - Mix of free and Pro testers
  - In-app feedback mechanism
  - **Test:** testers can install, use, submit feedback