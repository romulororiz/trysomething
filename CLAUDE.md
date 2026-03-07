# TrySomething — CLAUDE.md (v4 — Focused Redesign)

> Single source of truth for Claude Code. Read this before every task.
> This version reflects a strategic refocus: fewer features, stronger core loop.

---

## Product Thesis

**Old:** "A hobby discovery platform with AI, social, progress, and community features."

**New:** "The best app for helping overwhelmed adults choose one hobby and actually stick with it for 30 days."

Every decision filters through this. If a feature doesn't directly help someone choose a hobby, start it, or keep doing it for 30 days — it's not priority.

---

## Tech Stack (No Changes)

```
Frontend:   Flutter 3.6.0 + Riverpod 2.6.1 + GoRouter 14.8.1 + Freezed + google_fonts
Backend:    Node.js + Express (TypeScript) + Prisma 6.4.1 on Vercel + Neon Postgres
AI:         Claude Haiku 3.5 via Anthropic API
Auth:       JWT + Google OAuth
Payments:   RevenueCat (purchases_flutter)
Analytics:  PostHog + Sentry
```

---

## App Structure — 3 Tabs Only

### Tab 1: Home (Active Hobby)
The user's operating system for their current hobby.
- Current hobby card with image
- Next step (one clear action)
- This week's plan (simple: when, how long, what)
- Coach entry ("Need help?" with starter chips)
- Recent progress summary
- Restart flow if stalled ("Pick up where you left off" or "Try something different")

### Tab 2: Discover
Where users find hobbies.
- Personalized picks (from onboarding)
- 4 practical rails: For You / Start Cheap / Start This Week / Need a Different Vibe?
- Category browse (simplified)
- Search (natural language: "cheap creative hobby", "hobby for couples")
- Compare tool (secondary, inside Discover, not a separate tab)

### Tab 3: You
Utility and personal.
- Active / Saved / Tried hobbies (3 clear states)
- Journal archive
- Profile (simple)
- Subscription status + Pro screen
- Settings
- Basic stats

### Removed from Primary Navigation
These features exist in code but are HIDDEN from navigation for now. Do NOT delete the code — just remove routes and nav entries:
- Buddy mode
- Community stories
- Local discovery
- Hobby passport
- Year in review
- Weekly challenge
- Mood match (fold best parts into Discover rails)
- Seasonal picks (fold into Discover rails)
- Hobby battle/compare as standalone (keep as secondary tool inside Discover)

---

## Core User Journey (North Star)

```
Open app → Onboarding → 3 matches → Pick 1 → See easiest version
→ Start plan → First session → Return next day → Week 1-4 support
→ Continue or switch
```

**North star metric:** User completes first real session AND returns for step 2.

Not "saved hobby." Not "opened app." Not "browsed feed."
Did they DO the hobby and come back?

---

## Design System — "Midnight Neon" (Keep, with tone shift)

**Colors:** Keep the existing palette. #0A0A0F bg, #FF6B6B coral, #06D6A0 sage, etc.

**Typography:** Source Serif 4 headings, DM Sans body, IBM Plex Mono data.

**Tone shift:** The visual system stays. But the VOICE of the app shifts:
- Less: "neon AI lifestyle app"
- More: "warm, honest, practical guide"

**Prefer:** "Start gently" / "Try the easy version" / "Keep it simple" / "Small progress counts"
**Avoid:** "Crush it" / "Unlock everything" / "Level up" / "Become your best self"

The app should feel emotionally safe for overwhelmed adults.

### Spec Badge Rules (Unchanged)
- ALL spec badges: muted `sand` (#1E1E2E) bg, `driftwood` (#A0A0B8) text, monochrome icons
- Cost: CHF range ("CHF 40–120"), never single number
- Time: "/week" suffix always ("2h/week"), NEVER bare hours
- Difficulty: Easy / Medium / Hard

### Responsive Rules (Unchanged)
- `SafeArea` or `MediaQuery.of(context).padding` on every screen
- Never hardcode system UI dimensions
- Test device: Nothing Phone 3a
- Bottom nav bar = 85px, account for it in all bottom-positioned elements

---

## UI Mockups

Mockups are in `docs/mockups/`. Before implementing ANY screen, `view docs/mockups/<filename>.png` first. The mockup is source of truth for visual design. HOWEVER — the STRUCTURE and CONTENT of screens now follows this CLAUDE.md, not the old mockup layout. Mockups guide visual style; this document guides what appears on each screen.

---

## Screen-by-Screen Blueprint

### Splash
- Logo + "Find a hobby you'll actually start" + "Personalized to your time, budget, and energy"
- CTA: "Get my matches"
- No vague lifestyle language. No AI framing. This is a guided-start app.

### Onboarding (CRITICAL — This is the trust engine)

**Questions (only ones that materially affect recommendations):**
1. "Why do you want a hobby right now?" — relax / meet people / be creative / get active / reduce screen time / feel progress
2. "How much can you spend to start?" — free / under CHF 30 / under CHF 75 / under CHF 150 / flexible
3. "How much time per week?" — under 1h / 1-2h / 2-4h / 5+h
4. "Where will you mostly do it?" — home / outdoors / anywhere / studio/community
5. "Solo or social?" — solo / mostly solo / mixed / social
6. "What describes you right now?" — overwhelmed / curious / bored / burned out / motivated but directionless

**CRITICAL BACKEND FIX:** The matching logic in `_computeMatchedHobbies()` MUST use ALL of these inputs — especially budget and time. Currently it mostly uses vibe tags. This destroys trust. Fix matching to filter/rank by: budget fit, time fit, indoor/outdoor, solo/social, then emotional intent.

**Add to results:** "Why this fits you" explanation on each match card.
- "Fits your CHF 50 budget"
- "Works in 1-2h/week"
- "Great for solo evenings at home"

**Tone:** "You don't need the perfect hobby. You just need a good one to try."

### Match Results
- Show exactly 3 matches: 1 Best Match + 2 Alternatives
- Each card: hobby name, one-line promise, starter cost, weekly time, solo/social, where, "why it fits you"
- CTAs: "Start this hobby" / "See the easiest version" / "Compare matches"
- This screen should feel decisive, not browsable.

### Discover (Tab 2)
- 4 rails: For You / Start Cheap / Start This Week / Need a Different Vibe?
- Simple category filters: creative / active / mindful / social / outdoors / at home
- Search bar with natural language support
- NO excessive novelty modules, social teasers, or browse clutter

### Search
- Handle natural language: "hobby for anxiety", "cheap creative", "indoor winter hobby", "social but low pressure"
- Results with "Best fits for your situation" section
- AI search fallback for Pro users (blurred extra results for free)

### Hobby Detail (CONVERSION SCREEN — Most important after onboarding)

**New section order:**
1. **Quick start snapshot** — budget, time, difficulty, solo/social, location, setup friction
2. **Why it fits you** — personalized from onboarding context
3. **Easiest way to start** — minimum viable kit, first tiny session, under-20-minute option. "Try this in 20 minutes: buy only these 2 things, do this first tiny session, ignore the rest for now"
4. **Common reasons people quit** — honest. "People overbuy gear early" / "People expect fast visible results" / "Setup feels annoying so people skip practice." THIS BUILDS TRUST.
5. **Week 1 plan** — not full mastery roadmap. Just week 1.
6. **Full roadmap** — secondary, expandable
7. **Starter kit** — minimum / best value / premium tiers. Product images + affiliate buy links.
8. **Coach teaser** — "Want help starting without overthinking?"

**CTAs:** "Start the easy version" / "Build my week 1 plan" / "Ask the coach how to begin"
NOT generic "Try Today."

### Commitment Flow (After user chooses a hobby)
- "Save for later" or "Start now" — two clear options
- If "Start now":
  - Choose budget version (minimum / best value)
  - Pick first session length (15min / 30min / 1hr)
  - Set preferred day/time
  - Define one tiny first action
  - → Generates Week 1 plan
  - → Hobby moves to "Trying" status
  - → Navigate to Home tab with active hobby

### Home Tab (Tab 1 — Heart of the app)
- Current hobby card (image, title, status)
- **Next step** — one clear action. "Do a 10-minute line practice tonight"
- **This week's plan** — simple schedule (merged from old planner)
- **Coach entry** — "Need help?" with starter chips
- **Recent progress** — last journal entry, streak count
- **Restart flow** — if stalled: "Pick up where you left off" or "Try something different"
- NO feed behavior. NO exploration modules. Action-first.

### Roadmap / Progress (Inside Home, not separate)
- 4 stages: Week 1 (Try it) → Week 2 (Repeat it) → Week 3 (Reduce friction) → Week 4 (Decide if it fits)
- Show: what to do next, what to ignore, what success looks like this week
- "Stuck?" button on every stage → routes to coach
- Do NOT show giant mastery ladder upfront. Show one stage at a time.

### AI Hobby Coach (Premium feature)

**NOT a blank chat.** Opens with starter chips:
- "Help me start tonight"
- "Make this cheaper"
- "What should I do next?"
- "I'm losing motivation"
- "I skipped a few days"
- "Maybe this hobby isn't for me"

**3 modes (determined by user state):**
- **Start mode** (not started yet): what to buy, how to begin cheap, nervous about starting
- **Momentum mode** (active): next step, simplify session, maintain consistency
- **Rescue mode** (stalled): restart, easiest re-entry, maybe switch hobbies

**System prompt:** Include hobby data (roadmap, kit, pitfalls) + user progress (steps completed, journal entries, streak, last active date). See previous CLAUDE.md versions for full template.

**Message limits:**
- Browsing (unsaved): unlimited but short responses
- Saved: 5 free messages
- Active: 3 free messages/month (this is where Pro converts)
- Pro: unlimited

**Premium framing:** "Personal guidance that helps you keep going when the hobby stops feeling easy."

### Journal
- Purpose: reflection + friction diagnosis, NOT diary for diary's sake
- Prompts: "What did you try?" / "What felt good?" / "What was annoying?" / "What should be simpler next time?"
- Text entries: free. Photo entries: Pro.
- Premium sell: "Visual proof of progress, your hobby journey, visible momentum"

### Library (Inside "You" tab)
- 3 states: Active / Saved for Later / Tried Before
- "Tried Before" is important — gives permission to switch without feeling like failure
- Active hobby dominates visually
- Tapping active hobby → Home tab

### Profile / You (Tab 3)
- Simple, calm, functional
- Current plan status
- Subscription management
- Settings + notification preferences
- Journal archive
- Hobby history + basic stats
- NO ambitious dashboard, radar charts, or heatmaps for now

### Paywall / Pro

**Headline:** "Start hobbies you actually stick with"
**Subheadline:** "Get step-by-step support for your first 30 days, plus tools to keep momentum when motivation drops."

**3 benefit blocks only:**
1. Know the next right step
2. Get unstuck fast
3. Track real progress with photos and reflections

**DO NOT lead with:** "Unlimited AI" / feature buffet / generic unlock language.

**Plans:** CHF 4.99/month or CHF 39.99/year (save 33%)
**Trial:** 7-day free, offered once after onboarding

**Free vs Pro boundary:**
- Free: choose + begin (onboarding, matches, hobby detail, one active hobby, week 1 plan, limited coach, text journal)
- Pro: continue + recover (adaptive coach, 30-day support, rescue mode, photo journal, advanced planning, multi-hobby)

---

## Business Model

### Free Tier
- Onboarding + 3 personalized matches
- All hobby detail pages with roadmaps and starter kits
- One active hobby at a time
- First-week plan
- Limited coach (3 messages/month for active hobby)
- Text journal
- Basic progress tracking
- Affiliate buy links on all starter kit items (revenue regardless of tier)

### TrySomething Pro (CHF 4.99/month or CHF 39.99/year)
- Adaptive coach (unlimited, all 3 modes)
- 30-day guided support
- Rescue mode after inactivity
- Photo journal
- Advanced weekly planning
- More than one active hobby
- Richer progress summaries
- Deeper personalization

### Affiliate Revenue
- Amazon.de Associates on all starter kit items
- 24-hour cookie, commission on entire cart
- Revenue from both free and Pro users
- Treat as supplementary income, not core revenue

---

## What's NOT Being Built Now

These features exist in code. Do NOT delete them. Just hide from navigation:
- Buddy mode
- Community stories
- Local discovery
- Hobby passport / Year in review
- Weekly challenge
- Compare mode as standalone
- Mood match as standalone
- Seasonal picks as standalone

These become relevant AFTER core loop retention is proven.

---

## Analytics Events to Track (CRITICAL)

These events determine if the product works. Instrument them BEFORE polishing anything else:
- `onboarding_completed`
- `match_selected` (which hobby, which position)
- `hobby_saved`
- `hobby_started` (tapped "Start now")
- `first_session_completed`
- `day_3_return`
- `day_7_return`
- `day_30_active`
- `coach_message_sent`
- `coach_limit_reached`
- `paywall_shown` (with trigger context)
- `trial_started`
- `subscription_purchased`
- `hobby_switched`
- `hobby_abandoned` (no activity 14+ days)

---

## Testing

After each task: `dart analyze` on changed files only.
After each sprint: full `flutter analyze` + `dart test`.
Server changes: `cd server && npm test`.

---

## Brand Identity

### App Icon
Coral brushstroke "T" on dark background (#0A0A0F). File: `assets/icon/app_icon.png`

### Wordmark
"TrySomething" — Source Serif 4, "Try" in coral, "Something" in off-white. FINAL.

### Tagline
"Stop scrolling. Start something." — login/splash/marketing only.

### Where assets appear
- Home screen / notifications: app icon
- Splash / login: wordmark + tagline
- Feed header: "TRYSOMETHING" small caps with coral dot
- Settings footer: small icon + version
- Nowhere else