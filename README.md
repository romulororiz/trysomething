<p align="center">
  <img src="https://img.shields.io/badge/TrySomething-Find%20hobbies%20you'll%20actually%20do-E8734A?style=for-the-badge&labelColor=1E1A17" alt="TrySomething" />
</p>

<h1 align="center">
  🧭 TrySomething
</h1>

<p align="center">
  <strong>A hobby discovery and onboarding platform that helps people find activities they'll actually stick with.</strong>
</p>

<p align="center">
  <a href="#-the-problem"><img src="https://img.shields.io/badge/Problem-Why%20this%20exists-E8734A?style=flat-square" /></a>
  <a href="#-how-it-works"><img src="https://img.shields.io/badge/Solution-How%20it%20works-E5A630?style=flat-square" /></a>
  <a href="#-features"><img src="https://img.shields.io/badge/Features-What%20it%20does-5B6AAF?style=flat-square" /></a>
  <a href="#-tech-stack"><img src="https://img.shields.io/badge/Stack-Built%20with-7EA47E?style=flat-square" /></a>
</p>

---

## 💡 The Problem

Most people *want* hobbies but never start — or start and quit within two weeks.

The friction isn't motivation. It's **overwhelm**: *What do I need? How much does it cost? Where do I begin? Will I even like this?*

Existing solutions are either full-blown course platforms (too much commitment), Reddit threads (too scattered), or Pinterest boards (pretty but useless for actually starting). There's no app that sits in the sweet spot of *"here's a hobby that fits your life, here's exactly how to start in the next 30 minutes, and here's what to do when you get stuck."*

**TrySomething fills that gap.**

---

## 🧭 How It Works

TrySomething guides users through three phases:

### 1. Discover → *"What fits me?"*
A 30-second vibe quiz captures your time, budget, social preference, and energy — then matches you with hobbies that fit your actual life. Not "top 50 hobbies" listicles. Personalized, filtered, and honest about what each hobby demands.

### 2. Decide → *"Should I try this?"*
Every hobby has a detail page that answers the questions people actually ask before starting: how much it really costs, what makes it hard, what gear you truly need (and what's optional), common beginner mistakes, and why people who do it love it. No fluff.

### 3. Do → *"Okay, now what?"*
A step-by-step roadmap with a **"First 30 Minutes"** quickstart — a checklist of 3–5 things you can do *right now* with a built-in timer. Progress tracking, milestones, and soft streaks keep momentum without gamification pressure.

---

## ✨ Features

### Discovery & Matching
- **Onboarding Quiz** — Time, budget, solo/social, vibe preferences in 30 seconds
- **Discovery Feed** — Swipeable hobby cards with cost, time, and difficulty badges
- **Explore** — Browse by dynamic categories, quick-pick filters, and curated packs
- **Search** — Find any hobby by name, tag, or intent (*"something relaxing"*)
- **Mood Match** — Emotional entry point: *"I'm stressed"* → calming hobbies

### Hobby Detail
- **Spec Bar** — Cost range, weekly time, difficulty — always visible
- **Why People Love It** — The emotional hook, not a Wikipedia summary
- **Starter Kit** — Minimum gear with prices, optional items flagged
- **Beginner Pitfalls** — Mistakes to avoid before you waste time or money
- **Difficulty Explainer** — What specifically makes it hard (and what doesn't)

### Progress & Engagement
- **First 30 Minutes** — Quickstart checklist with focus timer
- **Roadmap** — Step-by-step progression with checkable milestones
- **Soft Streaks** — Day count without aggressive gamification
- **My Stuff** — Organized tabs: Saved → Trying → Active → Done
- **Hobby Journal** — Photo + text entries per hobby, private by default

### Social & Community
- **Buddy Mode** — Invite a friend, shared progress, gentle nudges
- **Local Discovery** — See who near you is trying the same hobby (opt-in, privacy-first)
- **Community Stories** — Curated real stories, not UGC chaos
- **Shareable Cards** — *"I'm trying pottery this week"* → social sharing

### Smart Recommendations
- **Hobby Combos** — *"People who love pottery also try sketching"*
- **Seasonal Picks** — Context-aware: outdoor hobbies in spring, crafts in winter
- **Re-engagement Quiz** — After 2 weeks inactive, re-personalize without starting over

### Utility
- **Cost Calculator** — Starter vs 3-month vs 1-year cost breakdown
- **Shopping List** — Aggregated starter kit items across saved hobbies
- **Compare Mode** — Side-by-side comparison of 2–3 hobbies
- **Hobby Scheduler** — Block time in your calendar with Google/Apple integration
- **60-Second Tips** — Short curated video clips per roadmap step

### Tasteful Gamification
- **Identity Badges** — *"Curious Maker"* → evolving title as you progress
- **Weekly Challenge** — One micro-challenge, opt-in, low pressure
- **Hobby Passport** — Stamp collection for each hobby you try
- **Year in Hobbies** — Annual recap, Spotify Wrapped–style, shareable

### AI-Powered *(v2+)*
- **AI Roadmap Generator** — *"I have 1h/week and want to make a mug in 30 days"*
- **AI Beginner Coach** — Context-aware chat that knows your progress
- **Smart Summaries** — Personalized hobby descriptions based on your preferences
- **Progress Vision** — Upload a photo of your work, get coaching (not judgment)

---

## 🛠 Tech Stack

| Layer | Technology |
|-------|-----------|
| Mobile | Flutter |
| Backend | Supabase (Auth, DB, Storage, Realtime) |
| AI Features | Anthropic Claude API |
| Payments | Stripe / RevenueCat |
| Analytics | PostHog |
| Push Notifications | OneSignal |

---

## 🗺 Roadmap

**Phase 1 — MVP**
Core discovery feed, hobby detail pages, onboarding quiz, first 30 minutes quickstart, basic progress tracking.

**Phase 2 — Engagement**
Buddy mode, journal, streaks, identity system, weekly challenges, hobby passport.

**Phase 3 — Smart**
AI coach, AI roadmap generator, mood matching, seasonal picks, cost calculator, compare mode.

**Phase 4 — Community**
Local discovery, community stories, creator roadmaps, curated packs marketplace.

---

## 🚀 Getting Started

```bash
# Clone the repository
git clone https://github.com/yourusername/trysomething.git
cd trysomething

# Install dependencies
flutter pub get

# Set up environment variables
cp .env.example .env
# Fill in your Supabase URL, anon key, and other secrets

# Run the app
flutter run
```

---

## 📁 Project Structure

```
trysomething/
├── lib/
│   ├── core/           # Theme, constants, utils, palette
│   ├── features/       # Feature-based modules
│   │   ├── onboarding/ # Quiz flow & vibe matching
│   │   ├── discover/   # Feed, cards, category browsing
│   │   ├── detail/     # Hobby detail & starter kit
│   │   ├── quickstart/ # First 30 minutes flow
│   │   ├── progress/   # Roadmap, streaks, milestones
│   │   ├── my_stuff/   # Saved/Trying/Active/Done tabs
│   │   ├── explore/    # Search, filters, curated packs
│   │   ├── social/     # Buddy mode, journal, local
│   │   └── ai/         # Coach, roadmap gen, summaries
│   ├── shared/         # Reusable widgets & components
│   └── main.dart
├── assets/             # Images, icons, animations
├── supabase/           # Migrations, edge functions, seed data
├── test/               # Unit & widget tests
└── pubspec.yaml
```

---

## 📄 License

This project is licensed under the MIT License — see [LICENSE](LICENSE) for details.

---

<p align="center">
  <sub>Built with ☕ and curiosity in Zürich 🇨🇭</sub>
</p>
