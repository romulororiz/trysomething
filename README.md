<div align="center">
  <img src="assets/icon/app_icon_foreground.png" width="120" height="120" alt="TrySomething" />

  <p>
    <img src="assets/icon/title.svg" width="420" alt="TrySomething">
  </p>

  **Choose a hobby. Start it. Stick with it for 30 days.**

  A mobile app for overwhelmed adults who want a new hobby but don't know where to start.

  [![Flutter](https://img.shields.io/badge/Flutter-3.6-02569B?style=flat&logo=flutter&logoColor=white)](#tech-stack)
  [![Dart](https://img.shields.io/badge/Dart-3.6-0175C2?style=flat&logo=dart&logoColor=white)](#tech-stack)
  [![Claude](https://img.shields.io/badge/AI-Claude_Sonnet_4.6-CC785C?style=flat)](#ai-powered)
  [![License](https://img.shields.io/badge/License-MIT-FF6B6B?style=flat)](LICENSE)
</div>

---

## The Problem

Most people want hobbies but never start — or quit within two weeks.

The friction isn't motivation. It's **overwhelm**: too many options, unclear costs, no starting point, and no structure for the critical first weeks. Existing solutions are either full course platforms (too much commitment), scattered Reddit threads, or Pinterest boards (pretty but useless for actually beginning).

There's no app that says: _"Here's a hobby that fits your life. Here's exactly how to start in 30 minutes. And here's what to do when you get stuck."_

TrySomething fills that gap.

---

## How It Works

```
Onboarding quiz ─► 4 personalized matches ─► Pick one ─► See the easiest way to start
       │
       ▼
Commitment flow ─► Personalized step-by-step roadmap ─► Immersive session with timer
       │
       ▼
   Reflect ─► Return tomorrow ─► AI-guided support
```

### 1. Discover — _"What fits me?"_

A 4-question quiz captures your budget, time, location, social preference, and emotional state. The matching algorithm filters 150+ hobbies and returns 4 personalized recommendations with honest cost estimates, time commitments, and a "why this fits you" explanation.

### 2. Decide — _"Should I try this?"_

Every hobby has a conversion-focused detail page: the easiest way to start, common reasons people quit (trust-building honesty), a starter kit with real CHF prices, and a progressive roadmap. No fluff, no Wikipedia summaries.

### 3. Do — _"Now what?"_

An immersive session screen takes over the device. After the timer: structured reflection prompts. An AI coach provides guidance through three modes — helping you start, maintain momentum, or recover after a gap.

---

## Features

### Discovery & Matching

- **Onboarding Quiz** — 4 questions: which vibes you're into, time, budget, and whether you're more of a solo/social person
- **Smart Matching** — Ranks hobbies by budget fit, time fit, social preference, and vibe
- **Discover Feed** — 4 curated tabs: For You, Start Cheap, This Week, Different Vibe
- **Feed/List Toggle** — Switch between cinematic card feed and compact list view
- **Search** — Natural language: _"cheap creative hobby"_, _"indoor winter hobby"_, _"hobby for anxiety"_

### Hobby Detail

- **"Why This Fits You"** — Personalized match explanation from onboarding data
- **Common Reasons People Quit** — Honest, trust-building section
- **Starter Kit** — Essential items with CHF prices, product images, and affiliate buy links
- **Step-by-step Roadmap** — Personalized to each and every hobby
- **Beginner FAQ** — AI-generated, practical Q&A
- **Cost Calculator** — Starter / 3-month / 1-year projections with money-saving tips

### Session Experience

- **Immersive Timer** — Full-screen, no distractions
- **Structured Reflection** — "What did you try?" / "What felt good?" / "What was annoying?"
- **Session Glow** — Ambient visual feedback during active sessions

### AI Hobby Coach (Claude Sonnet 4.6)

- **3 Auto-Detected Modes** — START (pre-commitment), MOMENTUM (active), RESCUE (stalled 7+ days)
- **Structured Response Cards** — Tonight's plan, cheaper alternatives, restart gently, reflection prompts
- **Quick Actions** — Contextual suggestion chips, not a blank chatbot
- **Full Context** — Knows your hobby, roadmap progress, journal entries, and conversation history
- **On-Demand Generation** — Search for any hobby not in the catalog; AI creates a complete profile

### Personal Tools

- **Hobby Journal** — Text entries (free) + photo entries (Pro) with reflection prompts
- **Personal Notes** — Per roadmap step
- **Schedule Planner** — Set recurring practice times
- **Shopping Checklist** — Track kit items you've purchased

### Progress

- **Active / Saved / Tried** — Three clear hobby states, permission to switch
- **Streak Tracking** — Soft encouragement, not aggressive gamification
- **Step Completion** — Track progress through roadmap milestones

---

## Tech Stack

### Mobile App

| Layer | Technology |
|---|---|
| Framework | Flutter 3.6 + Dart 3.6 |
| State | Riverpod 2.6 |
| Routing | GoRouter 14.8 |
| Models | Freezed + json_serializable |
| Typography | Google Fonts (Manrope, Instrument Serif, IBM Plex Mono) |
| Animation | flutter_animate 4.5 |
| Networking | Dio 5.7 + cached_network_image |
| Auth | flutter_secure_storage + Google Sign-In + Apple Sign-In |
| Payments | RevenueCat 9.14 (native paywall UI) |
| Analytics | PostHog |
| Crash Reporting | Sentry |
| Push | Firebase Cloud Messaging |
| Storage | Hive (encrypted cache) + SharedPreferences |

### Backend

| Layer | Technology |
|---|---|
| Runtime | Node.js + TypeScript on Vercel Serverless |
| Database | PostgreSQL (Neon, EU Frankfurt) |
| ORM | Prisma 6.4 |
| AI | Claude Sonnet 4.6 via Anthropic API |
| Auth | bcrypt (12 rounds) + JWT (15-min access / 30-day refresh) |
| Images | Unsplash API |
| Testing | Vitest |

### Website

| Layer | Technology |
|---|---|
| Framework | Next.js 16 + React 19 |
| Styling | Tailwind CSS 4 |
| Animation | GSAP + Framer Motion + Lenis |
| 3D | Three.js + React Three Fiber |

---

## AI-Powered

TrySomething uses **Claude Sonnet 4.6** for two core features:

### Hobby Generation

When you search for a hobby that doesn't exist in the catalog, the AI generates a complete profile in ~3-5 seconds: title, description, category, cost estimate (CHF), time commitment, difficulty, starter kit (2-6 items with prices), roadmap (3-7 progressive steps), pitfalls, and emotional hook.

Content safety: 4-layer defense with input blocklists, prompt constraints, output schema validation with runtime type checking, and rate limiting (20 generations per user per day).

### AI Coach

A conversational hobby coach that knows your specific hobby, your progress, your journal entries, and adapts its guidance based on your state. Three modes (auto-detected or manually selectable): START helps you begin, MOMENTUM keeps you going, RESCUE brings you back after a gap — without guilt-tripping.

---

## Design

**"Warm Cinematic Minimalism"** — editorial + tactile + warm. Inspired by DoReset's restraint, Headspace's warmth, and Kinfolk magazine's editorial quality.

- **Palette:** Deep black (`#0A0A0F`) + warm cream text (`#F5F0EB`) + ONE coral accent (`#FF6B6B`) for CTAs only
- **Typography:** Single-voice system built on **Manrope** (warm geometric humanist sans) for everything. Instrument Serif appears in ≤5 hero moments across the entire app (splash, onboarding, match results, detail hero, paywall). IBM Plex Mono for data/timer only.
- **Surfaces:** Glass cards (white at 8% opacity) with subtle blur
- **Navigation:** Floating glass dock — 3 icons, no labels
- **Motion:** Staggered fade-ups, scale-on-press (0.975), crossfade transitions, haptic feedback, reduced-motion support
- **Spacing:** 4px grid system, 22px card radius, 24px page padding
- **Rule:** One coral CTA per screen. Everything else is secondary.

---

## Project Structure

```
trysomething/
├── lib/                               # Flutter app (~42K LOC)
│   ├── main.dart                      # Entry point
│   ├── router.dart                    # All routes (GoRouter)
│   ├── core/                          # Services: analytics, API, auth, notifications, storage, subscriptions
│   ├── components/                    # 31 shared UI components (glass cards, timers, overlays, coach cards)
│   ├── data/repositories/             # Repository pattern: interface → API → Hive cache → seed fallback
│   ├── models/                        # Freezed data classes (hobby, session, auth, social, gamification)
│   ├── providers/                     # Riverpod state management (auth, hobby, session, subscription)
│   ├── screens/                       # 43 screens across auth, tabs, detail, session, coach, settings
│   └── theme/                         # Colors, typography, motion, spacing
├── server/                            # Backend API (~17K LOC)
│   ├── api/                           # Vercel serverless endpoints (auth, generate, users, hobbies)
│   ├── lib/                           # AI generator, auth, content guard, mappers, middleware
│   ├── prisma/schema.prisma           # 25 database models
│   └── scripts/                       # Seed generation, kit image backfill
├── website/                           # Next.js 16 landing page
├── test/                              # 37 test files (golden, unit, widget)
├── assets/                            # Fonts, icons, images
└── docs/                              # Mockups, plans, superpowers research
```

---

## Getting Started

```bash
# Clone
git clone https://github.com/romulofreires1/trysomething.git
cd trysomething

# Flutter app
flutter pub get
flutter run

# Server (requires .env with DATABASE_URL, ANTHROPIC_API_KEY, JWT_SECRET, etc.)
cd server
npm install
npx prisma generate
npm run dev
```

### Prerequisites

- Flutter 3.6+ / Dart 3.6+
- Node.js 18+
- PostgreSQL (Neon free tier works)
- Anthropic API key
- RevenueCat account (for subscriptions)

### Environment Variables

**Flutter** (compile-time via `--dart-define`):

- `POSTHOG_API_KEY`
- `REVENUECAT_API_KEY`
- `SENTRY_DSN`

**Server** (`.env`):

- `DATABASE_URL` — Neon PostgreSQL connection string
- `ANTHROPIC_API_KEY` — Claude API
- `JWT_SECRET` / `JWT_REFRESH_SECRET`
- `UNSPLASH_ACCESS_KEY`

---

## Business Model

| | Free | Pro (CHF 4.99/mo · CHF 39.99/yr · Lifetime) |
|---|:---:|:---:|
| Hobby catalog (150+) | ✓ | ✓ |
| Roadmaps & starter kits | ✓ | ✓ |
| Active hobbies | 1 | Unlimited |
| AI coach | 3 msg/month | Unlimited |
| Journal | Text only | Text + photo |
| Rescue mode | — | ✓ |

Affiliate revenue from starter kit buy links supplements subscription income.

---

## License

MIT License — see [LICENSE](LICENSE) for details.

---

<div align="center">

**TrySomething** — because the best hobby is the one you actually start.

Built with ☕ and curiosity in Zurich 🇨🇭

</div>
