# Feature Research: Hobby Lifecycle & Monetization (v1.1)

**Domain:** Mobile hobby guidance app — completion flows, pause/stop lifecycle, Pro content gating
**Researched:** 2026-03-23
**Confidence:** MEDIUM-HIGH (web research + competitive analysis; no Context7 equivalent for UX patterns)

---

## Context

TrySomething v1.0 shipped with a working session screen, step completion tracking, and RevenueCat Pro subscription. v1.1 adds three new feature areas on top of this existing foundation:

1. **Hobby completion flow** — auto-transition when all roadmap steps are done, celebration, "pick next hobby" state
2. **Pause/stop lifecycle** — free users can stop (abandon) a hobby, Pro users can pause (preserve progress)
3. **Detail page content gating** — free users see hero + Stage 1 only; Pro sees full FAQ, cost, budget alternatives

Research question: how do apps like Headspace, Duolingo, Strava, and habit trackers handle these three mechanics? What are the table stakes, differentiators, and anti-features?

---

## Competitive Benchmarks

### Completion Celebrations

**Duolingo:** Lesson completion triggers immediate full-screen "celebration moment" — confetti animation, mascot character reacts, XP awarded with counter animation. Course (unit) completion earns a trophy ("Golden Owl") with triumphant audio. The celebration is a *transition point*, not an endpoint — it leads directly into a next-step recommendation ("deepen your skills," "try a harder path"). Key pattern: acknowledge the win, then redirect immediately.

**Headspace:** Course completion surfaces a badge + milestone screen with the user's total stats ("You've meditated X minutes"). Warm, low-key — not confetti. Then prompts: "Explore what's next." The celebration is proportional to the effort (a 3-session beginner course gets a smaller celebration than completing a full series).

**Habit trackers (Loop, Streaks, Habi):** Day-level completion is lightweight — checkmark animation, streak counter increments. Milestone completions (7-day, 30-day streak) trigger a distinct celebration state: full-screen modal with the streak number prominent, brief animation, share prompt. The pattern: micro-celebration for daily tasks, macro-celebration for milestones.

**Pattern consensus:** Completion celebrations should be *proportional and immediate*, then pivot to next action. A roadmap stage completion (e.g., Stage 1 done) warrants a mid-level celebration. Completing the entire 4-stage hobby roadmap warrants the largest celebration the app has. Never leave the user at a dead end after celebrating — always present a clear next step.

### Pause/Resume Mechanics

**Strava:** Activities have explicit pause (mid-session) and save (end-session) states. "Auto-pause" detects rest via GPS/accelerometer and pauses the timer without user action. The recording is not deleted on pause — it is preserved in full. There is no "soft stop" — you either pause (continue later in the same session) or save/discard (end the session permanently). Strava does not have a concept of "pausing" a training plan across days.

**Habit trackers (modern, 2025):** Apps like Loop and Habi now offer habit-level pause — "archive" a habit without deleting its history. Archived habits stop appearing in the daily checklist but preserve all past completion data. Resuming restores the habit to active with full history intact. Streaks freeze on archive rather than resetting. This emerged from user feedback: life happens, users needed to stop tracking without losing progress.

**Duolingo:** Has a "streak freeze" item (purchasable in the in-app shop) that protects against a broken streak for one missed day. No explicit "pause course" — the course simply waits. There is no progress loss from inactivity, only streak loss.

**Pattern consensus:** Pause = freeze state, preserve progress, remove from active queue. Resume = restore to active queue with full history. The distinction from "stop" is purely about progress preservation — stopped hobbies lose their current position in the roadmap. Pause is universally a premium mechanic in 2025 (competitors charge for it or offer limited freezes in the free tier).

### Content Gating

**Headspace:** Free tier gives access to a small set of "basics" content (a few sessions, intro meditations). The majority of the catalog is locked — visible in browse but tapping a locked session shows a paywall. The lock is shown inline: sessions display a padlock icon overlay on the thumbnail. No blur, just a lock icon + greyed-out state. Tapping the locked content immediately surfaces a full-screen paywall, not an inline prompt. The free tier is intentionally small to create upgrade pressure. Conversion: 12% of free users convert (14-day trial is a key driver).

**Masterclass/Skillshare pattern (MEDIUM confidence):** Show the first lesson/chapter free, lock subsequent content. The locked content is visible in the chapter list with a lock icon. Tapping it opens a full-screen upgrade prompt. The preview of lesson 1 is the sales pitch.

**RevenueCat / industry research (2025):** The winning freemium content gating pattern is *not* "blur everything" — it is "show enough to create conviction, gate the depth." Research from analyzing 20 successful mobile paywalls (fline.dev): 95% of high-converting paywalls use full-screen overlays when the user actively tries to access premium content, rather than row-level blur. Freemium conversion: 2-5% typical in fitness/learning apps; trial-to-paid conversion much higher (23-40%).

**Blinkist's "Honest Paywall":** User can read the first few paragraphs of any summary, then hits a soft gate that offers the trial. The preview is genuine value, not teaser text. This raised conversion by 23% over a hard gate. The pattern: give real value in the preview, make the gap between preview and full access obvious without being hostile.

**Key finding:** Blur overlays are common but research suggests they underperform vs. lock icon + clear upgrade CTA. The best pattern for TrySomething's detail page: show Stage 1 in full, then a "locked" divider before Stages 2-4 with a clear upgrade prompt. Not a blur, not a full-screen block — an inline gate at the content boundary.

---

## Feature Landscape

### Table Stakes (Users Expect These)

Features users assume exist. Missing these = product feels incomplete or broken.

| Feature | Why Expected | Complexity | Existing Dependencies |
|---------|--------------|------------|----------------------|
| Completion celebration distinct from step completion | Every learning/habit app has a different moment for "you finished the whole thing" vs "you did one step" | LOW | `session_complete_phase.dart` exists; need a separate `hobby_complete_screen.dart` |
| Completed hobbies visible in You tab "Tried" section | Users expect to see their history; "Tried" status already exists in `UserHobby` enum | LOW | `you_screen.dart` + `UserHobby.status == done` already modeled |
| Home shows a "what's next" state after hobby completion | Users don't know what to do after finishing; dead-end state feels broken | LOW | `home_screen.dart` needs a new conditional branch for `status == done` |
| Stop/abandon action available | Users need an exit ramp that isn't "delete account"; standard in every app with ongoing commitments | LOW | `UserHobby.status = tried` path exists in model, needs UI |
| Stop action asks for a reason | Every app with abandon/cancel flows asks "why are you stopping" — provides feedback + makes the user pause | LOW | Quit reasons pattern already exists in the codebase (Sprint D's commitment flow) |
| Paused hobbies visually distinct from active hobbies | A "paused" hobby must look different in the You tab and Home tab — same look as active is confusing | LOW | New `paused` status needed in `UserHobby` enum (schema change) |
| Resume paused hobby single-tap | If pause exists, resume must be frictionless — not buried in settings | LOW | Depends on paused status existing |
| Detail page load speed unchanged after gating | Users expect the page to feel the same speed — gating logic must not add visible latency | LOW | Existing detail page loads; just conditional rendering, no new API calls needed |

### Differentiators (Competitive Advantage)

Features that set TrySomething apart. Not required, but reinforce the product thesis.

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| Completion celebration that feels earned, not generic | Most apps use the same confetti + badge. A celebration that references the specific hobby ("You tried 4 sessions of Watercolor painting") feels personal | MEDIUM | Requires passing hobby name + session count into the celebration screen; Lottie animation or existing particle painter could power the visual |
| Home "pick your next hobby" state with personalized recommendations | After completing a hobby, showing 3 curated next recommendations (same category, adjacent difficulty, or user-expressed interest) is more likely to retain the user than a generic "explore" CTA | MEDIUM | Needs `hobby_repository.getSimilarHobbies()` call + a home state branch; leverages existing recommendation infrastructure |
| Pause reasons (brief optional capture) | "What made you want to pause?" — optional single-tap (not a form) gives product insight and helps the AI coach restart better when resumed | LOW | Single bottom sheet with 3-4 tap options; stored in `UserHobby.pauseReason` (new field) |
| Coach-aware resume (uses `lastActivityAt` to tailor first message) | When a user resumes a paused hobby, the AI coach's first message acknowledges the gap: "You paused 3 weeks ago — want to pick up from Step 4, or ease back in?" | MEDIUM | `lastActivityAt` already tracked; coach system prompt needs a "returning after pause" mode |
| Stage 1 preview that feels complete, not teaser-y | Free users get the full Stage 1 roadmap steps — not a preview of 2 steps. Completing Stage 1 is a real milestone. This builds enough conviction to upgrade for Stages 2-4 | LOW | Just conditional rendering — show all steps in Stage 1, lock the rest |
| Inline upgrade prompt uses hobby-specific value copy | "See what's next in your Woodcarving journey" is more effective than a generic "Upgrade to Pro" | LOW | Pass hobby title into the paywall copy; existing `pro_upgrade_sheet.dart` needs parameterization |

### Anti-Features (Commonly Requested, Often Problematic)

| Feature | Why Requested | Why Problematic | Better Approach |
|---------|---------------|-----------------|-----------------|
| Streak reset on stop/abandon | Strava/Duolingo discipline model; "consequences make habits stick" | TrySomething users are already overwhelmed adults — punishing them for stopping makes quitting the app the rational choice | Record the stop without penalty; celebrate what they did try ("You completed Stage 1!") |
| Blur overlay on locked content | Looks premium, creates visual tension | Research shows blur underperforms vs clean lock + upgrade CTA; blur also degrades performance on lower-end Android devices | Lock icon + warm-toned divider section at the stage boundary |
| Full-screen paywall on every locked content tap | Maximizes upgrade prompt exposure | Breaks the browsing flow; users learn to avoid tapping; trains avoidance not desire | Inline upgrade prompt at the gating boundary, dismissible; full-screen paywall only when user explicitly taps "Upgrade" CTA |
| "Pause" available to free users | Fairness argument; "why punish free users?" | Pause is the clearest Pro differentiator in this feature set — it is the feature that converts. Giving it away removes upgrade pressure | Free users get "Stop" (no progress loss in history, but position resets); Pro users get "Pause" (position preserved) |
| Auto-complete hobby after N days of inactivity | "Move on" logic — detect stale hobbies | Creates resentment; user comes back after a vacation to find their hobby marked as abandoned | Never auto-complete or auto-stop. Only status changes the user initiates. Surface "still going?" prompt after 14 days of inactivity instead |
| Gamification points/XP for completion | Duolingo-style motivation | Out of scope for v1.1; adds complexity to UI and data model; misaligned with TrySomething's "quiet support" voice | Celebrate with copy and imagery, not a points counter |
| Share completion to social | "This milestone deserves an audience" | Hidden features (community) were deleted in v1.0 for scope reasons; reintroducing social surface contradicts that decision | Let users screenshot naturally; no share sheet needed |

---

## Feature Dependencies

```
[Paused status in UserHobby enum] (schema migration)
    └──required by──> [Pause action UI]
    └──required by──> [Resume action UI]
    └──required by──> [Home shows paused state]
    └──required by──> [You tab shows paused hobbies]

[Hobby auto-complete detection] (all steps done → status = done)
    └──required by──> [Completion celebration screen]
    └──required by──> [Home completed state]
    └──required by──> [You tab "Tried" population]

[Completion celebration screen] (new screen or overlay)
    └──enhances──> [Home completed state] (same data, different surface)

[Pro entitlement check] (RevenueCat, already exists)
    └──gates──> [Pause action] (free users see "Stop" only)
    └──gates──> [Detail page Stages 2-4]
    └──gates──> [Full FAQ / cost / budget sections]

[Stage 1 free preview] (conditional rendering on detail page)
    └──depends on──> [Hobby roadmap steps already loaded] (already done)
    └──feeds──> [Inline upgrade prompt] (shown at the stage boundary)

[Inline upgrade prompt] (new widget, parameterized by hobby)
    └──navigates to──> [pro_upgrade_sheet.dart] (already exists, needs parameterization)
```

### Dependency Notes

- **Paused status requires schema migration:** `UserHobby.status` enum currently has `saved / trying / active / done`. Adding `paused` requires a Prisma migration + server-side handling. This is the single schema change in v1.1. Must happen before any pause UI is built.
- **Auto-complete detection has two candidates:** Either the Flutter client detects "all steps done" after a step completion event and calls `PATCH /api/users/hobbies/:id` with `status: done`, OR the server triggers it on step-complete. Client-side is simpler and sufficient for v1.1 — no background job needed.
- **Content gating has no schema dependency:** Free vs Pro rendering is purely conditional on `subscriptionProvider.isPro`. No new backend endpoints needed. All gating is client-side rendering logic.
- **Inline upgrade prompt conflicts with full-screen paywall:** Do not navigate to a full-screen paywall when the user taps a locked section header. Show an inline sheet. Full-screen paywall is reserved for the explicit "Upgrade to Pro" CTA tap in Settings or the paywall sheet CTA.

---

## MVP Definition

This milestone has a defined scope from `PROJECT.md`. Everything below maps directly to the 9 active requirements.

### Launch With (v1.1 — all required)

- [x] **Auto-complete detection** — Client detects all steps done, PATCHes hobby status to `done` — *why essential: broken without it; users have no completion state*
- [x] **Completion celebration screen** — Distinct from step completion; hobby-specific copy; next-step CTA — *why essential: completing a 30-day hobby deserves acknowledgement; without it the app feels broken at its most important moment*
- [x] **Home completed state** — Shows "You finished [Hobby]! Pick your next one" with 2-3 recommendations — *why essential: dead-end home screen after completion is a retention killer*
- [x] **Completed hobbies in You tab "Tried" section** — Status `done` → renders in Tried section — *why essential: Tried section exists, just not populated*
- [x] **Stop/abandon action (free)** — Moves to `tried` status; asks for a stop reason (optional); coral CTA is "Stop this hobby" — *why essential: users need an exit; missing this creates frustration*
- [x] **Pause action (Pro)** — Requires schema migration to add `paused` status; preserves step progress; shows in Home as paused state — *why essential: key Pro differentiator; directly on the active requirements list*
- [x] **Resume paused hobby (Pro)** — Single-tap from Home or You tab paused section — *why essential: pause without resume is a trap*
- [x] **Detail page Stage 1 free, Stages 2-4 locked** — Conditional rendering based on `isPro`; inline upgrade prompt at boundary — *why essential: current detail page shows everything to everyone, removing monetization leverage*
- [x] **Detail page FAQ + cost + budget locked for free** — Same gating pattern; free users see a 1-line teaser ("5 questions beginners ask") + lock — *why essential: required by active milestone requirements*

### Add After Validation (v1.2)

- [ ] **Personalized "pick your next hobby" recommendations** — After completion, surface similar hobbies based on category/difficulty — *trigger: if completion→discover funnel drop-off is measurable in PostHog*
- [ ] **Coach-aware resume message** — AI coach detects pause gap and opens with a re-engagement message — *trigger: if resume rate is below 30% (paused hobbies not being resumed)*
- [ ] **Pause reason capture** — Optional single-tap reason on pause (Life got busy / Trying something else / Need a break) — *trigger: product feedback value; add once pause adoption is measurable*

### Future Consideration (v2+)

- [ ] **Completion milestone sharing** — Let users share a "I completed 30 days of [Hobby]" card — *why defer: social sharing requires design investment; community features previously removed*
- [ ] **Hobby streak tracking** — Days-in-a-row streak counter displayed on Home — *why defer: streaks create anxiety in TrySomething's "overwhelmed adult" target user; contradicts product thesis*
- [ ] **Progress recovery after stop** — Free users who stopped can "undo" within 24h — *why defer: adds state complexity; stop is intentional*

---

## Feature Prioritization Matrix

| Feature | User Value | Implementation Cost | Priority |
|---------|------------|---------------------|----------|
| Auto-complete detection + status update | HIGH | LOW | P1 |
| Completion celebration screen | HIGH | LOW-MEDIUM | P1 |
| Home completed state | HIGH | LOW | P1 |
| Stop/abandon action (free) | HIGH | LOW | P1 |
| Pause action (Pro) + schema migration | HIGH | MEDIUM | P1 |
| Resume paused hobby | HIGH | LOW | P1 |
| Detail page Stage 1 free / Stages 2-4 locked | HIGH | LOW | P1 |
| Detail page FAQ + cost + budget gating | MEDIUM | LOW | P1 |
| Completed hobbies in You tab Tried section | MEDIUM | LOW | P1 |
| Inline upgrade prompt (parameterized) | MEDIUM | LOW | P2 |
| Personalized next-hobby recommendations | HIGH | MEDIUM | P2 |
| Coach-aware resume message | MEDIUM | MEDIUM | P2 |
| Pause reason capture | LOW | LOW | P3 |

**Priority key:**
- P1: Required for v1.1 milestone closure
- P2: High-value follow-on, target v1.2
- P3: Nice to have, v2+

---

## Competitor Feature Analysis

| Feature | Duolingo | Headspace | Habit Trackers (Loop/Habi) | TrySomething Approach |
|---------|----------|-----------|----------------------------|-----------------------|
| Completion celebration | Full-screen, mascot animation, trophy award, immediate next-step redirect | Badge + stats milestone, low-key, next-step prompt | Full-screen modal for milestone streaks (7d/30d), lightweight for daily completion | Hobby-specific copy ("You did it with [Hobby]"), particle painter or animated icon, next-step CTA to Discover |
| Course/plan completion transition | Redirects to "Daily Refresh" or harder path immediately | Prompts "what's next" in catalog | None (habits are indefinite) | Home switches to completed state with "pick your next" recommendations |
| Pause/resume | Streak freeze (limited, purchasable) | No pause concept | Archive (free) / resume (free) | Stop (free, position resets) / Pause (Pro, position preserved) |
| Content gating | Locked units/skills visible with lock icon, tapping opens full-screen paywall | Locked sessions show padlock on thumbnail, tap = full-screen paywall | No content gating (no premium content tiers in most habit trackers) | Stage 1 fully unlocked; inline upgrade prompt at Stage 2 boundary; locked sections show faded rows + lock icon |
| Inline vs full-screen paywall | Full-screen only when tapping locked content | Full-screen on locked content tap | N/A | Inline prompt at boundary (new), full-screen on explicit "Upgrade" CTA tap only |
| Free tier depth | Several starter units free (enough to feel the product) | A small set of basics (meditation fundamentals) | Usually fully free (revenue from paid plan or no monetization) | Full Stage 1 (Try It) free — 3-5 real sessions; meaningful enough to build conviction for Pro upgrade |

---

## Implementation Notes Specific to TrySomething

### Completion Detection

The cleanest approach: in `SessionNotifier` (or wherever the final step completion is confirmed), check if all `UserCompletedStep` records exist for this hobby's roadmap steps. If yes, PATCH `UserHobby.status = done`. This is a client-side check on an event that already happens. No background job, no server-side trigger.

Existing infrastructure: `UserCompletedStep` table with `@@unique([userId, hobbyId, stepId])`. Count the user's completed steps for this hobby and compare to the hobby's total step count. If equal, auto-complete.

### Pause Schema Migration

`UserHobby.status` enum needs `paused` added. Prisma migration is a one-liner. The server's hobby endpoint needs to accept `paused` as a valid status in PATCH requests. The Flutter `UserHobby` Freezed model needs the enum value added. Both are small changes but require careful coordination (migration before code deploys).

### Content Gating on Detail Page

No new API calls. The `hobby_detail_screen.dart` already loads all data (roadmap steps, FAQ, cost, budget). Gating is purely `if (isPro) { ... } else { showLockedSection() }`. The locked section widget needs to be built once and reused for FAQ, cost, and budget gating. Inline upgrade prompt is a bottom sheet, not a navigation push.

### Stop vs. Pause UX Language

Research shows the terminology matters. Use:
- "Stop this hobby" (free) — not "Quit," not "Abandon," not "Delete"
- "Pause this hobby" (Pro) — not "Archive," not "Freeze"
- "Resume" (Pro, from paused state) — not "Restart"

"Stop" implies intentional completion of what was tried. "Pause" implies temporary. "Resume" implies continuation. These are the least loaded terms in the domain.

---

## Sources

- [Duolingo: Streak Milestone Design](https://blog.duolingo.com/streak-milestone-design-animation/) — MEDIUM confidence (official Duolingo blog, 2024)
- [Duolingo Home Screen Redesign — Science Behind It](https://blog.duolingo.com/new-duolingo-home-screen-design/) — MEDIUM confidence (official, 2024)
- [Learnings from Analyzing 20 Successful Mobile Paywalls — fline.dev](https://www.fline.dev/freemiumkit-learnings-from-analyzing-mobile-paywalls/) — MEDIUM confidence (independent research, verified patterns match industry consensus)
- [How Blinkist Increased Trial Conversions by 23%](https://growth.design/case-studies/trial-paywall-challenge) — MEDIUM confidence (case study, widely cited)
- [Strava: Auto-Pause Support Doc](https://support.strava.com/hc/en-us/articles/216919277-Auto-Pause) — HIGH confidence (official Strava support, 2025)
- [Top Fitness App Paywalls: UX Patterns + Pricing Insights](https://dev.to/paywallpro/top-fitness-app-paywalls-ux-patterns-pricing-insights-2868) — MEDIUM confidence (industry analysis, 2025)
- [Headspace Free vs Paid Features](https://livetoplant.com/free-vs-paid-features-of-the-headspace-meditation-app-explained/) — MEDIUM confidence (independent review, 2025)
- [RevenueCat: Hard Paywall vs Soft Paywall](https://www.revenuecat.com/blog/growth/hard-paywall-vs-soft-paywall/) — HIGH confidence (RevenueCat official, primary paywall infrastructure provider)
- [RevenueCat: Freemium Playbook](https://www.revenuecat.com/docs/playbooks/guides/freemium) — HIGH confidence (official RevenueCat docs)
- [Streaks and Milestones for Gamification — Plotline](https://www.plotline.so/blog/streaks-for-gamification-in-mobile-apps/) — MEDIUM confidence (2025, industry analysis)
- [Best Habit Tracker Apps 2026 — Reclaim](https://reclaim.ai/blog/habit-tracker-apps) — MEDIUM confidence (product comparison, 2026)

---

*Feature research for: TrySomething v1.1 — hobby completion flow, pause/stop lifecycle, Pro content gating*
*Researched: 2026-03-23*
