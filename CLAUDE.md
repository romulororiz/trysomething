# TrySomething — CLAUDE.md

> This is the single source of truth for Claude Code working on this project.
> It contains: project overview, architecture, design system, v3 redesign plan, AI strategy, and task queue.

---

## Project Overview

TrySomething is an AI-powered hobby discovery mobile app. Tagline: "helps you actually start." It bridges the gap between "I want a hobby" and "I'm actually doing one" with curated content, step-by-step roadmaps, starter kits, cost breakdowns, and progress tracking.

**Target user:** Adults 18–45 who want new hobbies but are overwhelmed by options or don't know the first practical step.

**Current state:** Late MVP — 7 of 8 dev batches complete. Full API backend live on Vercel. 26 screens implemented. Auth, content, progress tracking, personal tools, social features, gamification all working. Now undergoing v3 redesign to match new mockups and add AI-powered dynamic hobby generation.

---

## Tech Stack

```
Frontend:   Flutter 3.6.0 + Riverpod 2.6.1 + GoRouter 14.8.1 + Freezed + google_fonts
Backend:    Node.js + Express (TypeScript) + Prisma 6.4.1 + bcryptjs + jsonwebtoken
Database:   Neon Postgres (serverless) with 25 Prisma models
Infra:      Vercel (serverless functions) + GitHub Actions CI
APIs:       REST (JSON) — 40+ endpoints in 11 serverless functions
External:   Google OAuth (3 client IDs), Claude API (AI hobby generation)
```

**Architecture:** Client-server with offline-first caching. Repository pattern with three fallback layers: API → Hive cache → static SeedData. Optimistic updates with rollback on all mutations.

---

## Project Structure

```
lib/
├── main.dart                 # Bootstrap: bindings, error handler, runZonedGuarded, ProviderScope
├── router.dart               # GoRouter: 26 routes, auth/onboarding redirect chain
├── models/                   # Freezed data classes (8 files + generated)
│   ├── hobby.dart            # Hobby, KitItem, RoadmapStep, HobbyCategory, UserHobby, UserPreferences
│   ├── auth.dart             # AuthUser, AuthResponse
│   ├── features.dart         # UserProfile, Challenge, ScheduleEvent, HobbyCombo, FaqItem, CostBreakdown
│   ├── social.dart           # JournalEntry, BuddyProfile, BuddyActivity, CommunityStory
│   ├── gamification.dart     # Achievement model
│   ├── seed_data.dart        # Static offline fallback data (9 categories)
│   └── feature_seed_data.dart
├── core/
│   ├── api/                  # Dio singleton, endpoint constants
│   ├── auth/                 # AuthInterceptor (JWT), TokenStorage (flutter_secure_storage)
│   ├── error/                # ErrorReporter (ring buffer), ErrorProvider (Riverpod observer)
│   ├── analytics/            # AnalyticsService (console stub — wire to PostHog)
│   ├── notifications/        # NotificationService (FCM stub — wire to Firebase)
│   └── storage/              # Hive initialization
├── data/repositories/        # Interface + API implementation pairs (7 repos)
├── providers/                # Riverpod providers for auth, hobbies, user, features
├── screens/                  # 26 screen files
│   ├── auth/                 # login, register
│   ├── onboarding/           # 3-page vibes/budget/social
│   ├── feed/                 # vertical card discovery feed
│   ├── explore/              # 2-column category grid
│   ├── search/               # full-text search
│   ├── my_stuff/             # Saved/Trying/Active/Done tabs
│   ├── profile/              # stats, heatmap, radar
│   ├── settings/
│   ├── detail/               # full hobby detail with roadmap
│   ├── quickstart/           # modal slide-up starter
│   └── features/             # 16 feature screens
├── components/               # Shared widgets (hobby_card, spec_badge, page_transitions, curved_nav)
└── theme/                    # "Midnight Neon" design tokens
    ├── app_colors.dart       # 37+ color tokens
    ├── app_typography.dart   # 20+ named text styles
    ├── spacing.dart          # 4px grid system
    └── motion.dart           # Animation durations and curves

server/
├── api/                      # 11 serverless handler files
├── lib/                      # auth, mappers, middleware, db, gamification
├── prisma/schema.prisma      # 25 models, 390 lines
└── test/                     # 32 tests
```

---

## Design System — "Midnight Neon"

**Color Tokens:**
| Token | Hex | Role |
|-------|-----|------|
| cream | #0A0A0F | App background (darkest) |
| warmWhite | #141420 | Surface/card bg |
| sand | #1E1E2E | Elevated surface |
| coral | #FF6B6B | CTA, primary accent |
| amber | #FBBF24 | Gold, badges |
| indigo | #7C3AED | Brand secondary |
| sage | #06D6A0 | Success, mint, selection accent |
| nearBlack | #F8F8FC | Headings (lightest) |

**Category colors:** Creative=#D946EF, Outdoors=#06D6A0, Fitness=#FF4757, Maker=#FBBF24, Music=#818CF8, Food=#FB923C, Collecting=#38BDF8, Mind=#7C3AED, Social=#F472B6

**Typography:** Source Serif 4 (headings), DM Sans (body), IBM Plex Mono (data/badges)

**Spacing:** 4px grid. Card radius=22, tile=16, button=14.

**Motion:** fast=150ms, normal=250ms, slow=350ms

**Aesthetic:** Deep dark space with glowing neon accents. Frosted glass containers. Parallax feed cards. Coral CTAs with glow effect.

### Spec Badge Rules (IMPORTANT)
- **Style:** ALL spec badges use the SAME muted treatment — `sand` (#1E1E2E) background with `driftwood` (#A0A0B8) text and subtle monochrome icon. Do NOT use different saturated colors per badge (no yellow/teal/purple rainbow). Only coral (#FF6B6B) should pop on any screen — everything else stays restrained and sophisticated.
- **Cost badge:** Always a CHF range representing starter cost. Format: "CHF 40–120". Never a single number.
- **Time badge:** Always weekly commitment with explicit "/week" suffix. Format: "2h/week". NEVER "3h" alone (reads as total time, which is misleading and kills credibility).
- **Difficulty badge:** One of Easy / Medium / Hard. Never a time estimate. Never "X hours to master."
- These rules apply everywhere badges appear: feed cards, detail page, search results, compare screen.

---

## UI Mockups — Source of Truth

**CRITICAL: Before implementing or modifying ANY screen, Claude Code MUST first view the corresponding mockup image in `docs/mockups/`. The mockup is the source of truth for layout, spacing, component design, and visual hierarchy. Do not rely on text descriptions alone.**

Mockup files are in `docs/mockups/` with these names:

| File | Screen |
|------|--------|
| `01_discover_feed.png` | Discovery Feed — TikTok-style full-bleed cards with side action icons |
| `02_hobby_detail.png` | Hobby Detail — hero, starter kit with product images, roadmap with milestones |
| `03_library.png` | Library / My Stuff — Saved/Trying/Active/Done tabs with progress cards |
| `04_profile.png` | Profile — stats grid, radar chart, activity heatmap, trophies |
| `05_mood_match.png` | Mood Match — 4 photo-backed mood tiles, Popular Today list |
| `06_journal.png` | Hobby Journal — timeline with entries, photos, tags, filters |
| `07_weekly_plan.png` | Weekly Planner — calendar strip, session timeline cards |
| `08_login.png` | Login — logo, email/password, Google + Apple social auth |
| `09_onboarding_vibes.png` | Onboarding Page 1 — "What vibes are you into?" category grid |
| `10_onboarding_ready.png` | Onboarding Page 3 — "You're ready!" floating cards with match % |
| `11_onboarding_budget.png` | Onboarding Page 2 — hours slider, budget cards, solo/social |
| `12_hobby_combos.png` | Hobby Combos — paired cards with reasons, filter chips |
| `13_seasonal_picks.png` | Seasonal Picks — featured collection, horizontal cards, trending |
| `14_hobby_battle.png` | Hobby Battle — side-by-side comparison, Head-to-Head grid |
| `15_cost_projection.png` | Cost Projection — year 1 total, bar chart, savings tips |
| `16_mood_match_alt.png` | Mood Match (alternate view, confirms design) |
| `17_quickstart.png` | Quickstart bottom sheet — beginner badge, roadmap preview |
| `18_search.png` | Search — type badges, ratings, prices, "you might also like" |
| `19_settings.png` | Settings — account, preferences, theme, log out |
| `20_explore.png` | Explore — photo-backed category grid with count badges |

### How to use mockups when implementing:
```
# Before working on any screen, ALWAYS view the mockup first:
view docs/mockups/02_hobby_detail.png

# Then implement to match what you see. The mockup defines:
# - Layout structure and component hierarchy
# - Spacing, sizing, and visual proportions
# - Color usage and accent placement
# - Typography scale and weight
# - Which elements exist and where they're positioned
```

---

## v3 Redesign — Vision

### The Three Pillars

1. **150 Pre-Seeded Hobbies** — Rich curated content with roadmaps, starter kits, cost breakdowns. The reliable foundation that serves 90%+ of users at zero API cost.

2. **AI-Generated Hobbies** — On-demand generation when pre-seeded content doesn't satisfy. Fires at 3 specific touchpoints only. Uses Claude Haiku 3.5 at ~$0.003/call. Every generated hobby cached to Postgres so the catalog grows organically.

3. **Personal Journey** — Journal, progress tracking, buddy system, weekly planner. The reason users return daily.

### Design Philosophy
This is a UI REFACTOR, not a rewrite. Backend, data models, state management, and API all stay as-is. Only UI components update to match the 20 new mockup screens.

---

## v3 Screen Map

| # | Screen | Route | Tab/Parent | Key Elements |
|---|--------|-------|------------|--------------|
| 1 | Discovery Feed | /discover | Discover (Tab 1) | Full-bleed TikTok cards, side action icons (heart/save/share), category badge, spec badges, TRY TODAY CTA |
| 2 | Hobby Detail | /hobby/:id | Push from Feed | Hero + TRENDING badge, star rating, Starter Kit with PRODUCT IMAGES + prices, Roadmap with checkmarks + MILESTONE badges, floating TRY TODAY |
| 3 | Quickstart Modal | /hobby/:id/start | Sheet from Detail | Bottom sheet, BEGINNER badge, roadmap preview, Start Now, "Free for first 3 lessons" |
| 4 | Explore Grid | /explore | Explore (Tab 2) | Photo-backed category cards with count badges (124+), filter chips (All/Trending/New/For You) |
| 5 | Search | /search | Push from Explore | Category chips, result cards with type badges (COURSE/WORKSHOP), star ratings, prices, "You might also like" |
| 6 | Library | /library | Library (Tab 3) | Segmented: Saved/Trying/Active/Done. Cards with image, progress %, streak days, Continue button |
| 7 | Journal | /journal/:hobbyId | Push from Library | Timeline entries with photos, tags. Filter: All/Photos/Notes/Milestones. FAB to add |
| 8 | Weekly Planner | /plan | Plan (Tab 4) | Calendar week strip, session cards with category colors, time + location |
| 9 | Profile | /profile | Profile (Tab 5) | Stats grid, Skill Balance radar, Activity heatmap, Recent Trophies |
| 10 | Settings | /settings | Push from Profile | Account, Preferences (budget, theme), Log Out |
| 11 | Mood Match | /mood | Push from Discover | "How are you feeling?" — 4 photo-backed mood tiles, Popular Today list |
| 12 | Hobby Combos | /combos | Push from Discover | Paired hobby cards with reasons, filter chips, user counts |
| 13 | Seasonal Picks | /seasonal | Push from Discover | Featured collection hero, horizontal cards, Trending in Community |
| 14 | Hobby Battle | /compare | Push from Explore | Side-by-side comparison, Head-to-Head grid, Community Winner poll, dual CTAs |
| 15 | Cost Projection | /hobby/:id/cost | Push from Detail | Year 1 total, bar chart, Smart Savings tips |
| 16 | Login | /login | Auth | Logo, email/password, Google + Apple social auth, Terms/Privacy links |
| 17 | Onboarding: Vibes | /onboarding/1 | Auth flow | "What vibes are you into?" — 2x4 category grid with icons, teal checkmarks |
| 18 | Onboarding: Budget | /onboarding/2 | Auth flow | Hours/week slider, Budget cards (Low/Med/High), Solo/Social toggle |
| 19 | Onboarding: Ready | /onboarding/3 | Auth flow | "You're ready!" — floating category cards with match %, Start Exploring CTA |

### Bottom Navigation — KEEP AS-IS
**DO NOT change the bottom nav bar.** The current curved navigation bar with its existing tab structure stays exactly as it is. Do not add tabs, remove tabs, or modify the curved_nav component. All new screens (Plan, etc.) are accessed via push navigation from existing tabs, not as new tabs.

### Transitions
- Auth screens: fade
- Push navigation: slideRight (350ms)
- Modals (Quickstart): modalSlideUp (300ms)
- Back: slideRight reverse (300ms)

---

## v3 Redesign — What Changes

### Bottom Nav — NO CHANGES
Keep the current curved navigation bar exactly as it is. Do not modify tabs, styling, or structure.

### Discovery Feed
Current parallax cards → full-screen TikTok-style. Right side: heart with count (2.4k), bookmark, share. Top-left: category badge ("CREATIVE"). Bottom-left: title, hook, spec badges (COST/TIME/LEVEL). Bottom: floating "TRY TODAY →" CTA with coral glow.

### Hobby Detail
Add TRENDING badge on hero, star rating (1.2k). Starter Kit: PRODUCT IMAGES in 2-column grid with category labels (MATERIAL/TOOLS/GEAR) and individual prices + total. Roadmap: green checkmarks completed, coral active, MILESTONE badges. Floating sticky TRY TODAY at bottom.

### Explore Grid
Photo-backed category cards with gradient overlays. Hobby count badges (124+, 86+) top-right. Category icons overlaid. Filter chips: All/Trending/New/For You.

### Library Cards
Full-bleed hobby images with category badge (bottom-left), streak flame + day count (bottom-right). Progress bar with percentage, "Continue Learning" CTA. Coral accent for top/active card.

### Profile
Stats grid (2x2): Tried/Active/Hours/Streak with colored icons. Skill Balance radar chart (6 axes: Creative/Physical/Culinary/Intellectual/Social/Technical). Activity heatmap (GitHub-style, 5 months). Recent Trophies list. Settings moved to separate screen via gear icon.

### Onboarding
Page 1: 2x4 category grid with custom icons, teal border + checkmark on multi-select. Page 2: Hours slider with coral track, budget cards with icons, Solo/Social toggle. Page 3: Floating animated category cards with match %, "Curated for you" badge, "Start Exploring →".

### Search
Type badges (COURSE/WORKSHOP/KIT+CLASS), star ratings, prices, arrow icons. "You might also like" section with horizontal scroll.

---

## AI Strategy

### When AI Fires (3 Touchpoints Only)

1. **Smart Search Fallback** — Search returns <3 pre-seeded results → show those instantly → shimmer + "Finding more..." → fire POST /api/generate/hobby → animate AI results into list
2. **Onboarding Personalization** — "You're ready!" screen shows 3 pre-seeded matches + 1 AI "Made for you" hobby with sparkle badge
3. **"Surprise Me" FAB** — Floating button on Discover → text prompt → AI generates full hobby → navigate to detail

### AI Details
- Model: Claude Haiku 3.5 (~$0.003/call)
- Endpoint: POST /api/generate/hobby (already exists)
- Caching: Every generated hobby saved to Postgres (isAiGenerated=true). Catalog grows from 150 → 500+ organically.
- Budget: ~$3-6/month at 1,000 MAU

### What NOT to Build (v1)
- AI Coach/Chat (v2+)
- Admin panel (use Prisma Studio)
- Content moderation (curated content only at launch)
- Email notifications (push is enough)
- Offline sync queue (optimistic updates sufficient)
- Custom landing page (use Carrd)

---

## Monetization — Affiliate Starter Kits

### The Concept
Every starter kit item links to where the user can actually buy it. This removes the biggest friction point: "I decided to try pottery... now where do I buy stoneware clay?" The affiliate link is a service, not an ad — the user was going to search for this product anyway.

### Data Model Change
Add two nullable fields to KitItem in Prisma:
```
affiliateUrl      String?   // product link with affiliate tag appended
affiliateSource   String?   // "amazon_de", "galaxus", "digitec", "amazon_br", "mercado_livre"
imageUrl          String?   // product image URL (Unsplash or product photo)
```
The `imageUrl` field is REQUIRED for all kit items. The Hobby Detail mockup shows product images for every starter kit item (e.g., bag of stoneware clay, carving set, split-leg apron). Every kit item must have a visible product image — never show a kit item as text-only.

### Affiliate Programs by Market
- **Switzerland:** Amazon.de Associates (covers CH delivery, 3-5% commission), Galaxus/Digitec partner program
- **Brazil:** Amazon.com.br Associados, Mercado Livre affiliate program
- **Fallback:** If no affiliate link exists for an item, show a "Search on Amazon" button that opens a pre-filled Amazon search with the item name + affiliate tag

### UI Implementation
On the Hobby Detail page Starter Kit section:
- Each kit item card shows: product IMAGE (required), category label (MATERIAL/TOOLS/GEAR), item name, price in CHF, and a subtle shopping bag icon or "Buy →" link
- Tapping the card opens the affiliate URL in system browser (url_launcher)
- If no affiliateUrl exists, tap opens Amazon search: `https://www.amazon.de/s?tag=YOUR_TAG&k={item_name}`
- Track affiliate clicks in analytics (PostHog event: `kit_item_clicked`)

### Shopping List Screen
The Shopping List feature screen (`lib/screens/features/shopping_screen.dart`) aggregates kit items across all saved hobbies into one checklist. Each item in the shopping list MUST also show:
- Product image (from KitItem.imageUrl)
- Item name and hobby it belongs to
- Price estimate
- "Buy →" affiliate link button
- Checkbox for marking as purchased
Never show shopping list items as text-only. Every item needs its product image.

### Revenue Projection
At 1,000 MAU × 1.5 hobbies tried × 30% buy-through rate × CHF 40 avg cart × 4% commission = ~CHF 720/month. Scales linearly. Covers Claude API costs 10x over.

### Seeding Affiliate Data
When seeding the 150 hobbies (task 1.4), each kit item needs:
- A real product image URL (Unsplash search or actual product photo)
- An affiliate URL for Amazon.de with your Associates tag (prioritize Swiss-available products)
- Realistic CHF pricing verified against actual Amazon.de listings

---

## 150 Hobby Seeding

| Category | Count | Examples |
|----------|-------|---------|
| Creative | 22 | Pottery, Watercolor, Sketching, Calligraphy, Knitting, Crochet, Embroidery, Photography, Digital Art, Woodburning, Origami, Scrapbooking, Jewelry Making, Resin Art, Screen Printing, Macramé, Collage, Sewing, Tie-Dye, Mosaic, Stained Glass, Candle Decorating |
| Outdoors | 18 | Hiking, Birdwatching, Kayaking, Gardening, Stargazing, Geocaching, Trail Running, Rock Climbing, Surfing, Camping, Fishing, Mountain Biking, Foraging, Nature Photography, Sailing, Skiing, Horseback Riding, Beach Volleyball |
| Fitness | 18 | Bouldering, Yoga, Swimming, Martial Arts, Dance, CrossFit, Boxing, Pilates, Cycling, Skateboarding, Parkour, Fencing, Archery, Rowing, Jump Rope, Aerial Silks, Ice Skating, Tai Chi |
| Maker | 16 | Woodworking, 3D Printing, Electronics, Leathercraft, Candle Making, Soap Making, Metalworking, Model Building, Bookbinding, Furniture Restoration, Knife Making, Pottery Wheel, Glassblowing, Loom Weaving, Clock Repair, Drone Building |
| Music | 16 | Guitar, Ukulele, Piano, Drumming, Singing, Violin, DJ/Mixing, Music Production, Harmonica, Bass Guitar, Flute, Saxophone, Cajon, Beatboxing, Songwriting, Music Theory |
| Food | 18 | Sourdough, Fermentation, Coffee Roasting, Pasta Making, Sushi, Smoking/BBQ, Bread Baking, Cocktails, Cheese Making, Chocolate, Pickling, Hot Sauce, Korean Cooking, Indian Curry, Pizza, Pastry, Tea Ceremony, Kombucha |
| Collecting | 14 | Vinyl Records, Vintage Cameras, Plants, Coins, Stamps, Sneakers, Watches, Antique Books, Crystals, Postcards, Board Games, Pokémon Cards, Vintage Posters, Enamel Pins |
| Mind | 14 | Chess, Journaling, Meditation, Language Learning, Puzzles, Reading Challenges, Philosophy, Creative Writing, Astronomy, Brain Teasers, Speed Cubing, Memory Training, Calligraphy, Lucid Dreaming |
| Social | 14 | Board Game Nights, Improv, Volunteering, Book Club, Trivia, Community Theater, Wine Tasting, Hiking Clubs, Cooking Classes, Dance Socials, Language Exchange, Toastmasters, Potluck Clubs, Running Groups |

Each hobby needs: title, hook, description, whyPeopleLoveIt, 3-5 kitItems (CHF prices, product imageUrl, affiliateUrl for Amazon.de), 5 roadmapSteps (minutes), 3+ pitfalls, difficulty explanation. Swiss market pricing. Unsplash images for hobby hero AND for each kit item product photo.

---

## Backend Reference

### Key Endpoints (No Changes Needed)
- **Auth:** POST /api/auth/register, /login, /refresh, /google
- **Content:** GET /api/hobbies, /hobbies/:id, /hobbies/search, /categories, /hobbies/combos, /hobbies/seasonal, /hobbies/mood
- **User:** CRUD /api/users/hobbies, /journal, /notes, /schedule, /shopping, /stories, /buddies, /challenges, /achievements
- **AI:** POST /api/generate/hobby, /generate/faq, /generate/cost, /generate/budget

### State Pattern
```
User action → snapshot → update UI immediately → save SharedPrefs → fire API → on fail: restore snapshot
```

---

## Testing

**Do NOT run full `flutter analyze` after every task — it's slow and blocks progress.**

After each task (fast, 2-3 seconds):
```bash
dart analyze lib/screens/THE_FILE_YOU_CHANGED.dart    # Only analyze changed files
```

After each sprint (~every 5 tasks, full sweep):
```bash
flutter analyze          # Full project analysis
dart test                # All 158 Flutter tests
cd server && npm test    # All 32 server tests (only if server files changed)
```

---

## Task Queue

See `CLAUDE_TASKS_v3.md` for full checklist. Sprint order:
1. **Foundation** — affiliate model migration, feed cards, onboarding, seed 150 hobbies with product images + affiliate links
2. **Core Screens** — detail page with buy buttons, explore, library, quickstart, search
3. **Rich Features** — profile, mood match, battle, journal/planner, shopping list with images, AI search + onboarding
4. **Polish & Ship** — "Surprise Me", Firebase, analytics, app store, performance, beta