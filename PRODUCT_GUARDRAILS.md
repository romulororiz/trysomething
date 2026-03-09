# TrySomething — Product Guardrails

> Reference document for every design and development decision.
> If a choice conflicts with this document, this document wins.

---

## Product Thesis

**"The best app for helping overwhelmed adults choose one hobby and actually stick with it for 30 days."**

Every feature, screen, and interaction must directly help someone:
1. **Choose** a hobby (onboarding, matching, discover)
2. **Start** it (detail page, commitment flow, first session)
3. **Keep doing it** for 30 days (home dashboard, coach, journal, roadmap)

If a feature does not serve one of these three goals, it is not priority.

---

## North Star Metric

**User completes their first real session AND returns for step 2.**

Not "saved a hobby." Not "opened the app." Not "browsed the feed."
Did they DO the hobby and come back?

### Supporting Metrics
- `first_session_completed` — did they actually try it?
- `day_3_return` — did they come back early?
- `day_7_return` — did they survive the first week?
- `day_30_active` — did they stick with it?

---

## Non-Negotiables

### 1. Three Tabs Only
- **Home** — the user's operating center for their active hobby
- **Discover** — where users find hobbies
- **You** — utility, personal history, settings

No fourth tab. No hidden drawers with secondary navigation. Three tabs.

### 2. One Active Hobby Focus
The entire Home tab revolves around ONE hobby. Free users get one active hobby at a time. The app is not a buffet — it is a guided commitment tool.

### 3. Warm Cinematic Minimalism
The visual system is defined, locked, and non-negotiable:
- **Background:** #0A0A0F (deep black)
- **Text:** #F5F0EB (warm cream, NOT pure white)
- **Secondary text:** #B0A89E (warm gray)
- **Muted text:** #6B6360 (warm dark gray)
- **Glass surfaces:** white at 8% opacity, 12% border
- **Typography:** Source Serif 4 for headlines (36pt hero), DM Sans for body (15pt), IBM Plex Mono for data (48pt large stats)
- **Cinematic contrast:** hero-to-caption ratio of 3.3x

### 4. Coral Accent for CTAs Only
- Coral (#FF6B6B) appears on ONE primary CTA per screen
- No coral in navigation, badges, icons, decorations, or secondary elements
- Everything else is warm cream or warm gray
- No amber, indigo, or category-specific colors in active use

### 5. Action-First UX
- Home tab shows the NEXT step, not a feed
- Detail page leads with "Start in 20 minutes", not feature lists
- Coach opens with starter chips, not a blank chat
- Every screen answers: "What should the user DO right now?"

### 6. Spec Badges Are Dead
All hobby specs rendered as one warm gray text line with middot separators:
`CHF 40-120 · 2h/week · Easy`
No colored pills. No icons. No backgrounds.

### 7. Glass Cards Everywhere
Semi-transparent cards with subtle blur replace all solid dark cards. Scale-to-0.97 on press. Staggered fade-in on screen entry.

### 8. Floating Glass Dock Navigation
Bottom nav is a floating glass dock — 3 icons, no labels, rounded, floating above the bottom edge. All screens must account for its height.

---

## What We Ship

These are the core screens and flows that make up the product:

1. **Splash** — "Find a hobby you'll actually start" + "Get my matches"
2. **Onboarding** — 6 questions that materially affect recommendations (motivation, budget, time, location, solo/social, current state)
3. **Match Results** — exactly 3 matches with "why this fits you" explanations
4. **Discover Tab** — 4 rails (For You / Start Cheap / Start This Week / Need a Different Vibe?), category browse, natural language search
5. **Hobby Detail** — the conversion screen: quick start snapshot, why it fits you, easiest way to start, common reasons people quit, week 1 plan, starter kit, coach teaser
6. **Commitment Flow** — save for later or start now, mini setup (budget version, session length, day/time, first action), generates week 1 plan
7. **Home Tab** — active hobby card, next step, this week's plan, coach entry, recent progress, restart flow if stalled
8. **Roadmap/Progress** — 4 stages (Try it / Repeat it / Reduce friction / Decide if it fits), one stage at a time, "Stuck?" routes to coach
9. **AI Hobby Coach** — starter chips, 3 modes (start/momentum/rescue), message limits by tier
10. **Journal** — reflection + friction diagnosis, text (free) and photo (Pro) entries
11. **You Tab** — active/saved/tried hobbies, journal archive, profile, subscription, settings
12. **Paywall/Pro** — emotional framing ("Start hobbies you actually stick with"), 3 benefit blocks, CHF 4.99/month or CHF 39.99/year

---

## What We Hide (Not Delete)

These features exist in the codebase. Their code is preserved. They are removed from navigation, routes, and visible UI:

- **Buddy mode** — social pairing feature
- **Community stories** — user-generated content feed
- **Local discovery** — location-based hobby finding
- **Hobby passport** — collection/achievement system
- **Year in review** — annual summary
- **Weekly challenge** — gamification mechanic
- **Compare as standalone** — hobby comparison tool (kept as secondary inside Discover)
- **Mood match as standalone** — emotional hobby matching (best parts folded into Discover rails)
- **Seasonal picks as standalone** — time-based recommendations (folded into Discover rails)

These become relevant AFTER core loop retention is proven. Do not build on top of them. Do not refactor them. Do not delete them.

---

## Voice Guidelines

### Prefer
- "Start gently"
- "Try the easy version"
- "Keep it simple"
- "Small progress counts"
- "You don't need the perfect hobby. You just need a good one to try."

### Avoid
- "Crush it"
- "Unlock everything"
- "Level up"
- "Become your best self"
- Any language that frames hobby-starting as a competitive achievement

### Tone Principles
- Warm, not peppy
- Honest, not salesy ("Common reasons people quit" builds trust)
- Action-oriented, not aspirational
- Permission-giving ("Tried Before" is a valid state, not failure)

---

## Free vs Pro Boundary

### Free: Choose + Begin
- Onboarding + 3 personalized matches
- All hobby detail pages with roadmaps and starter kits
- One active hobby at a time
- First-week plan
- Limited coach (3 messages/month for active hobby)
- Text journal
- Basic progress tracking
- Affiliate buy links (revenue regardless of tier)

### Pro: Continue + Recover
- Adaptive coach (unlimited, all 3 modes)
- 30-day guided support
- Rescue mode after inactivity
- Photo journal
- Advanced weekly planning
- More than one active hobby
- Richer progress summaries
- Deeper personalization

The paywall activates where motivation meets friction — when the hobby stops being easy and the user needs support to continue.
