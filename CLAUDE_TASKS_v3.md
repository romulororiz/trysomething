# TrySomething — v3.0 Redesign Tasks

> **How to use:** Open Claude Code in `c:\dev\trysomething`. Say: "Work on the next unchecked task from CLAUDE.md"
> Claude Code reads your codebase, implements, runs `flutter analyze` + `dart test`, commits.

## Design Reference
- Theme: "Midnight Neon" — #0A0A0F backgrounds, #FF6B6B coral CTAs with glow, frosted glass
- Typography: Source Serif 4 headings, DM Sans body, IBM Plex Mono data
- 20 mockup screenshots are the source of truth for every screen

## Architecture (Do Not Change)
- Flutter 3.6.0 + Riverpod 2.6.1 + GoRouter 14.8.1 + Freezed
- Node.js + Express + Prisma 6.4.1 on Vercel + Neon Postgres
- Existing 40+ API endpoints, 25 Prisma models, auth system — all stay as-is
- **Bottom navigation bar: KEEP AS-IS.** Do not change tabs, structure, or the curved_nav component.
- This is a UI REFACTOR, not a rewrite. Same backend, same state management.

---

## Sprint 1: Foundation (Week 1-2)

- [ X ] **1.1 — Add affiliate fields + imageUrl to KitItem model**
  - Add to KitItem in `server/prisma/schema.prisma`:
    - `affiliateUrl String?` — product link with affiliate tag
    - `affiliateSource String?` — "amazon_de", "galaxus", "amazon_br"
    - `imageUrl String?` — product image URL (REQUIRED for all items in practice)
  - Run `npx prisma migrate dev --name add-kit-item-affiliate`
  - Update KitItem Freezed model in `lib/models/hobby.dart` to include new fields
  - Run `dart run build_runner build` to regenerate
  - **Test:** `flutter analyze` clean, `dart test` passes, migration runs

- [ X ] **1.2 — Redesign Discovery Feed cards**
  - Current: parallax HobbyCards (480px) with save button
  - Target: Full-screen TikTok-style cards (match mockup image_copy.png)
  - Right side column: heart icon with count (2.4k), bookmark/save, share
  - Top-left: category badge pill ("CREATIVE" with icon)
  - Bottom-left: hobby title (large), hook text, spec badges (COST $$, TIME 2-4hrs, LEVEL Medium)
  - Bottom: "TRY TODAY →" CTA button with coral glow
  - Background: full-bleed hobby image with gradient overlay
  - Edit `lib/components/hobby_card.dart` and `lib/screens/feed/`
  - **Test:** feed scrolls at 60fps, save animation works, card tap → detail

- [ X ] **1.3 — Redesign Onboarding (3 pages)**
  - Page 1 "What vibes are you into?": 2x4 grid of category tiles with custom icons
    - Teal (#06D6A0) border + checkmark on selection (multi-select)
    - Categories: Creative, Relaxing, Social, Active, Intellectual, Outdoors, Tech, Culinary
    - Continue + "Skip for now" buttons
  - Page 2 "Time & Budget": Hours/week slider (1h-10h+) with coral track
    - Budget cards (Low/Medium/High) with icons, coral border on selected
    - Solo/Social toggle with coral accent
  - Page 3 "You're ready!": Floating category cards with subtle animation
    - "98% Match" badge on top match, "Curated for you" pill
    - "Start Exploring →" CTA, "Join 10,000+ hobbyists" social proof
  - Edit `lib/screens/onboarding/`
  - **Test:** onboarding completes, preferences saved to SharedPrefs + API

- [ ] **1.4 — Seed 150 hobbies into Prisma (with affiliate data)**
  - Create `server/prisma/seed.ts` with 150 hobbies across 9 categories:
    - Creative (22), Outdoors (18), Fitness (18), Maker (16), Music (16), Food (18), Collecting (14), Mind (14), Social (14)
  - Each hobby needs: title, hook, description, whyPeopleLoveIt, 5 roadmapSteps with estimatedMinutes, 3+ beginnerPitfalls, difficulty explanation
  - Each kit item (3-5 per hobby) MUST have:
    - `imageUrl`: real product photo (Unsplash search or product image URL) — NEVER leave blank
    - `affiliateUrl`: Amazon.de link with Associates tag (search for actual products, use realistic URLs)
    - `affiliateSource`: "amazon_de" for Swiss market
    - `cost`: verified against actual Amazon.de listing price in CHF
  - Use real Unsplash image URLs for hobby hero images
  - Costs calibrated for Swiss market (CHF)
  - Also seed: HobbyCombo pairs (20+), SeasonalPick entries, MoodTag mappings
  - **Test:** `npx prisma db seed` runs clean, GET /api/hobbies returns 150+, all kit items have imageUrl

---

## Sprint 2: Core Screens (Week 3-4)

- [ ] **2.1 — Redesign Hobby Detail page**
  - Hero image with TRENDING badge (top-right), "4 weeks to master" overlay, star rating with count
  - "Why you'll love it" section with body text
  - Starter Kit: PRODUCT IMAGES (required, from KitItem.imageUrl) in 2-column grid, category labels (MATERIAL, TOOLS, GEAR), individual prices + "~ $XX Total"
    - Each kit item card is tappable → opens affiliateUrl in system browser (url_launcher)
    - If no affiliateUrl, tap opens Amazon.de search: `https://www.amazon.de/s?tag=YOUR_TAG&k={item_name}`
    - Subtle shopping bag icon or "Buy →" indicator on each card
    - Track taps: PostHog event `kit_item_clicked` with hobbyId + itemName
  - Roadmap: green checkmarks for completed, coral for active, MILESTONE badges, time per step
  - Floating "TRY TODAY →" CTA at bottom (sticky, coral glow)
  - Edit `lib/screens/detail/`
  - **Test:** detail loads with all sections, kit item images display, affiliate links open correctly
  - Roadmap: green checkmarks for completed steps, coral for active step, MILESTONE badges, estimated time per step
  - Floating "TRY TODAY →" CTA at bottom (sticky, with coral glow)
  - Share icon in top-right header
  - Edit `lib/screens/detail/`
  - **Test:** detail loads with all sections, roadmap steps toggle correctly

- [ ] **2.2 — Redesign Explore grid**
  - 2-column photo-backed category cards with gradient overlay
  - Hobby count badges (124+, 86+) in top-right corner
  - Category icon overlaid on image
  - Filter chips at top: All / Trending / New / For You
  - Search bar at top with filter icon
  - Edit `lib/screens/explore/`
  - **Test:** category tap filters correctly, search navigates to search screen

- [ ] **2.3 — Redesign Library (My Stuff) cards**
  - Full-bleed hobby images (like feed cards but shorter)
  - Category badge pill (bottom-left on image)
  - Streak flame icon + day count (bottom-right on image)
  - Below image: hobby title, current module/step text, progress bar with percentage
  - "Continue Learning" CTA button (coral for top card, gray for others)
  - Segmented control: Saved / Trying / Active / Done (Trying selected = coral bg)
  - Edit `lib/screens/my_stuff/`
  - **Test:** tab switching works, progress displays correctly

- [ ] **2.4 — Add Quickstart bottom sheet**
  - Bottom sheet (modalSlideUp) triggered from Detail page
  - BEGINNER badge, hobby title, description, small image
  - Roadmap preview: 3 steps with icons and descriptions
  - "Start Now →" CTA with "Free for first 3 lessons" subtitle
  - Edit `lib/screens/quickstart/` or create new
  - **Test:** sheet opens from detail, Start Now navigates correctly

- [ ] **2.5 — Redesign Search results**
  - Search input with clear button
  - Category filter chips below search (All, Arts & Crafts, Outdoor, Culinary...)
  - Result cards: hobby image (square), type badge (COURSE/WORKSHOP/KIT+CLASS), star rating, price
  - Arrow icon on right side of each result
  - "You might also like" section below results with horizontal scroll cards
  - Edit `lib/screens/search/`
  - **Test:** search returns results, category filter works

---

## Sprint 3: Rich Features (Week 5-6)

- [ ] **3.1 — Profile overhaul**
  - Avatar with edit badge, display name, title ("Hobby Explorer"), bio
  - "Online" + "Since 2023" badges
  - Stats grid (2x2): Tried (count), Active (count), Hours (total), Streak (days) — each with colored icon
  - Skill Balance: radar chart with 6 axes (Creative, Physical, Culinary, Intellectual, Social, Technical)
  - Activity heatmap: GitHub-style grid, 5 months, color scale from gray to teal
  - Recent Trophies: list with icon, title, description, time ago
  - Settings moved to separate screen (gear icon in header)
  - Edit `lib/screens/profile/`
  - **Test:** stats calculate correctly, radar chart renders, heatmap shows data

- [ ] **3.2 — Polish Mood Match**
  - "How are you feeling?" header
  - 4 photo-backed mood tiles in 2x2 grid: Energetic, Zen, Curious, Creative
  - Each tile: real photo background, mood icon (colored circle), mood name, subtitle with hobby examples
  - "Popular Today" section below with hobby list cards (image, ACTIVE/RELAXING badge, time, difficulty)
  - Edit `lib/screens/features/mood_match_screen.dart`
  - **Test:** mood selection filters hobbies correctly

- [ ] **3.3 — Polish Hobby Battle / Compare**
  - Two hobby images side-by-side with "VS" badge in center
  - Head-to-Head comparison grid: Cost, Time, Difficulty — each row with icons and labels
  - "Community Winner" section: progress bar with percentage, hobby name
  - Dual CTA: "Save Both" (outline) + "Start [Winner]" (coral filled)
  - Edit `lib/screens/features/compare_screen.dart`
  - **Test:** comparison data loads, CTAs save/start correctly

- [ ] **3.4 — Polish Journal & Weekly Planner**
  - Journal: colored timeline dots, photo grid (2-column), tag pills, filter bar
  - Planner: week strip calendar with active day circle, session cards with category color bar + time + location
  - Edit `lib/screens/features/journal_screen.dart` and `scheduler_screen.dart`
  - **Test:** entries display, new entry creation works, calendar navigation works

- [ ] **3.4b — Shopping List with product images + affiliate links**
  - The shopping list screen aggregates kit items from all saved hobbies
  - Each item MUST show: product image (KitItem.imageUrl), item name, which hobby it belongs to, price
  - "Buy →" button on each item → opens affiliateUrl in browser (or Amazon search fallback)
  - Checkbox for marking items as purchased (already exists in ShoppingCheck model)
  - Group items by hobby with hobby name as section header
  - Never show text-only items — every item needs its product image
  - Edit `lib/screens/features/shopping_screen.dart`
  - **Test:** shopping list shows images for all items, affiliate links open, checkboxes persist

- [ ] **3.5 — AI: Smart Search Fallback**
  - When search returns <3 results from pre-seeded hobbies:
    - Show pre-seeded results immediately
    - Below: shimmer placeholder + "Finding more for you..."
    - Fire POST /api/generate/hobby in background
    - When response arrives, animate new suggestions into list
  - Generated hobbies saved to Postgres (isAiGenerated=true) for caching
  - Edit `lib/screens/search/` + `lib/providers/hobby_provider.dart`
  - **Test:** search for obscure term → AI results appear after ~2s

- [ ] **3.6 — AI: Onboarding personalization**
  - On "You're ready!" screen (page 3 of onboarding):
    - Show 3 pre-seeded best-match hobbies based on quiz answers
    - 4th tile has sparkle icon + "Made for you" badge
    - Fire AI generation with user preferences as prompt
    - Animate in the generated hobby when ready
  - Edit `lib/screens/onboarding/` + `lib/providers/user_provider.dart`
  - **Test:** onboarding generates personalized hobby, saved to user's feed

---

## Sprint 4: Polish & Ship (Week 7-8)

- [ ] **4.1 — AI: "Surprise Me" FAB**
  - Floating action button on Discover feed (sparkle icon)
  - Tap → bottom sheet with text input: "What sounds fun right now?"
  - Submit → loading animation → AI generates full hobby → navigate to detail page
  - Generated hobby saved to Postgres + user's saved hobbies
  - Edit `lib/screens/feed/` + create new widget
  - **Test:** free text → generates hobby → detail page renders correctly

- [ ] **4.2 — Firebase push notifications**
  - Replace stubs in `lib/core/notifications/`
  - Add firebase_messaging + firebase_core to pubspec.yaml
  - FCM token → server via PUT /api/users/me
  - Triggers: buddy request, challenge completed, streak milestone (3/7/30 days)
  - **Test:** notification received on physical device

- [ ] **4.3 — Analytics + crash reporting**
  - PostHog: replace console logging in analytics_service.dart
  - Sentry: wrap runZonedGuarded in main.dart
  - Key events: hobby_saved, hobby_started, onboarding_completed, ai_hobby_generated
  - **Test:** events visible in PostHog dashboard, forced error in Sentry

- [ ] **4.4 — App store prep**
  - Create store/metadata.md (title, subtitle, keywords, description)
  - Create store/privacy-policy.md
  - iOS: configure signing, TestFlight upload in CI
  - Android: release signing, Play Console internal track
  - **Test:** TestFlight + Play Console builds accessible

- [ ] **4.5 — Performance pass**
  - Profile feed scroll (target: 60fps)
  - CachedNetworkImage with memCacheWidth
  - flutter build apk --analyze-size (target: <30MB)
  - Riverpod .select() where over-watching
  - **Test:** no jank in profile mode, APK under 30MB

- [ ] **4.6 — Beta launch**
  - TestFlight invites (10 iOS testers)
  - Play Console internal testing (10 Android testers)
  - In-app feedback shake-to-report
  - **Test:** testers can install, use, and submit feedback