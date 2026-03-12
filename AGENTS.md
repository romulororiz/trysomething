# AGENTS.md

## Project
TrySomething

## Product thesis
TrySomething is not a hobby super app.
TrySomething is the best app for helping overwhelmed adults choose one hobby and actually stick with it for 30 days.

The product must optimize for:
1. Trust in recommendations
2. Fast time-to-first-session
3. Low-friction continuation
4. Momentum recovery after dropoff
5. Calm, premium, emotionally credible UX

## Core user transformation
From:
- overwhelmed
- bored
- curious
- directionless
- doomscrolling

To:
- committed to one hobby
- started with a realistic first step
- supported through the first 30 days
- able to continue or switch without shame

## Product priorities in order
1. Core loop clarity
2. Recommendation trust
3. Hobby-start conversion
4. Retention and momentum support
5. Monetization tied to continuity
6. Visual polish
7. Secondary features

## Core loop
Onboarding -> 3 strong hobby matches -> choose 1 -> easiest version -> first session -> return for next step -> week 1-4 support -> continue or switch

## North star behavior
A user completes a real first hobby session and returns for step 2.

## What TrySomething is
- A guided-start app
- A practical hobby onboarding system
- A momentum and recovery tool
- A premium, calm, emotionally safe product

## What TrySomething is not
- Not a social network
- Not a content feed
- Not a hobby encyclopedia first
- Not a generic AI app
- Not a course marketplace
- Not a gamified productivity dashboard
- Not a community-heavy product at this stage

## Current strategic focus
All work should support one of these:
- better matching trust
- stronger action-first hobby detail pages
- one active hobby flow
- coach as momentum/rescue engine
- premium visual system
- clearer paywall tied to continuity

If a change does not support one of those, it is probably not a priority.

## Navigation direction
Prefer 3 primary tabs:
- Home
- Discover
- You

Avoid expanding top-level navigation unless strongly justified.

## Information architecture rules
- Reduce browse clutter
- Prefer fewer, stronger surfaces over many rails
- Promote action over browsing
- Home should focus on the active hobby
- Discover should support finding or switching
- You should stay utility-focused

## Recommendation system rules
The onboarding must materially influence recommendations.
Recommendations must use, at minimum:
- budget
- time availability
- solo/social preference
- location context (home / outdoors / studio / flexible)
- emotional intent
- friction tolerance if available

Every match should explain why it fits:
- budget fit
- time fit
- social fit
- environment fit
- emotional fit

Avoid cosmetic personalization.

## Hobby detail page rules
Hobby detail pages are conversion pages, not info dumps.

Order of importance:
1. Can I start this?
2. What is the cheapest/easiest version?
3. Why does this fit me?
4. What should I do this week?
5. What usually makes people quit?
6. Full roadmap
7. Full starter kit depth

Every hobby detail page should prioritize:
- easiest start
- minimum viable kit
- realistic beginner cost
- realistic weekly time
- first-session simplicity

## Coach rules
The coach is not a generic chatbot.
The coach is a progression, momentum, and rescue system.

The coach should help users:
- start tonight
- simplify the first session
- reduce cost/setup friction
- recover after inactivity
- decide whether to continue or switch

The coach should avoid:
- generic motivational fluff
- broad hobby trivia unless asked
- excessive verbosity
- sounding like a generic AI assistant

## Free vs Pro rules
Free helps users choose and begin.
Pro helps users continue.

Free can include:
- onboarding
- matches
- hobby detail pages
- one active hobby
- first-week support
- limited starter coaching
- text journaling

Pro should emphasize:
- adaptive coaching
- week 2-4 support
- recovery after dropoff
- photo journal
- deeper personalization
- richer progress summaries
- multi-hobby support if implemented

## Features to de-emphasize for now
Do not prioritize these unless explicitly requested:
- buddy mode
- community stories
- local discovery
- weekly challenge
- year in review
- hobby passport
- social-first features
- novelty-first compare/battle surfaces

## Visual design direction
TrySomething should feel:
- editorial
- tactile
- cinematic
- calm
- premium
- warm
- modern
- emotionally safe

Avoid:
- startup-neon overload
- generic dark card rails
- gimmicky fake-3D everywhere
- loud gamification
- cluttered dashboards

## Material system direction
Use a coherent hierarchy:
- level 0: atmospheric background
- level 1: grounded surfaces
- level 2: floating surfaces
- level 3: focal premium surfaces

Use glass sparingly.
Use depth, blur, edge lighting, gradients, and motion carefully.
Do not over-animate.

## Motion rules
Motion should be:
- soft
- tactile
- restrained
- slightly springy
- continuous
- premium

Every animation must support:
- clarity
- hierarchy
- delight without distraction

Avoid motion that feels gimmicky or busy.

## Card rules
Avoid repetitive generic rail-card layouts.
Prefer:
- hero card
- support cards
- fewer but higher-quality surfaces
- stronger focal hierarchy

## Copy rules
Tone should be:
- calm
- supportive
- practical
- emotionally intelligent
- low-pressure
- honest

Prefer:
- Start gently
- Try the easy version
- Keep it simple
- You can switch later
- Small progress still counts

Avoid:
- hustle language
- cringe self-help
- generic productivity slogans
- overhyped AI language

## Technical guardrails
- Keep Flutter as primary UI system
- Do not introduce 3.js for core app UI
- Prefer Flutter-native motion, blur, shaders, and transitions
- Use Rive only for focused premium moments if needed
- Refactor large screens into reusable sections/components
- Keep environment config out of hardcoded production constants when possible

## Delivery rules for Codex
When proposing changes:
1. State the product goal
2. State the UX rationale
3. State the implementation scope
4. Prefer the smallest high-leverage change first
5. Do not add features when simplification would solve the issue

When editing UI:
- improve hierarchy
- reduce clutter
- strengthen material consistency
- strengthen conversion to action

When editing product flows:
- optimize for first session and return session
- reduce cognitive load
- support momentum and recovery

## Success criteria for redesign work
A successful change should improve at least one of:
- onboarding trust
- match selection
- hobby start conversion
- first session completion
- day 3 retention
- day 7 retention
- paid conversion after meaningful value
- perceived premium quality

## If uncertain
Bias toward:
- simplification
- stronger hierarchy
- more believable recommendations
- action-first UX
- better retention support
- calmer premium design