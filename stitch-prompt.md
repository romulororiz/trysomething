# TrySomething — Design Brief for Google Stitch

## App Concept

**TrySomething** is a hobby discovery app that "helps you actually start." It removes the intimidation barrier from trying new hobbies by giving users everything they need: curated hobby cards with honest hooks, starter kits with real costs, step-by-step roadmaps, and personal tracking tools. Think "Duolingo meets Pinterest for real-world hobbies."

**Tagline:** "Stop scrolling. Start something."

**Target audience:** Adults 20–40 who feel stuck in routines, scroll hobby content on TikTok/Reddit but never start, want structure without overwhelm.

**Platform:** Mobile-first (iOS + Android), dark-mode-only.

---

## Design System — "Midnight Neon"

Dark-mode-first. Bold, vibrant, premium. The aesthetic is a moody editorial magazine crossed with a neon-lit city — deep dark backgrounds with punchy accent colors that pop.

### Color Palette

**Neutrals (dark → light):**
| Token | Hex | Usage |
|-------|-----|-------|
| cream | `#0A0A0F` | App background (darkest) |
| warmWhite | `#141420` | Surface / card background |
| sand | `#1E1E2E` | Elevated surface / chip background |
| sandDark | `#2A2A3C` | Borders, dividers |
| stone | `#363650` | Subtle borders |
| warmGray | `#6B6B80` | Muted text, placeholders |
| driftwood | `#A0A0B8` | Secondary text |
| espresso | `#C0C0D0` | Body text |
| darkBrown | `#D8D8E8` | Emphasized body text |
| nearBlack | `#F8F8FC` | Headings, primary text (lightest) |

**Accent Colors:**
| Token | Hex | Usage |
|-------|-----|-------|
| coral | `#FF6B6B` | Primary CTA — the "try this" spark |
| amber | `#FBBF24` | Gold — milestones, streaks, badges |
| indigo | `#7C3AED` | Electric violet — brand identity |
| sage | `#06D6A0` | Mint cyan — success, progress |

**Pale Backgrounds (dark-tinted for selected/active states):**
| Token | Hex |
|-------|-----|
| coralPale | `#2E1820` |
| amberPale | `#2E2518` |
| indigoPale | `#201540` |
| sagePale | `#0A2A1A` |

**9 Category Colors (vibrant on dark):**
| Category | Color | Hex |
|----------|-------|-----|
| Creative | Fuchsia | `#D946EF` |
| Outdoors | Mint | `#06D6A0` |
| Fitness | Red | `#FF4757` |
| Maker/DIY | Gold | `#FBBF24` |
| Music | Lavender | `#818CF8` |
| Food | Orange | `#FB923C` |
| Collecting | Sky blue | `#38BDF8` |
| Mind | Violet | `#7C3AED` |
| Social | Pink | `#F472B6` |

### Typography

Three font families for distinct roles:

| Role | Font | Weights | Usage |
|------|------|---------|-------|
| Headings | **Source Serif 4** | 700 | Hero titles, screen headings, card titles — warm editorial feel |
| Body | **DM Sans** | 400, 500, 600, 700 | Body text, labels, buttons, navigation — clean geometric |
| Data | **IBM Plex Mono** | 400, 500, 600, 700 | Numbers, stats, badges, timers — friendly data density |

**Type Scale:**
- Display: Source Serif 4, 38px, bold (screen heroes)
- Hero: Source Serif 4, 36px, bold (feed card titles)
- Title: Source Serif 4, 32px, bold (section titles)
- Heading: Source Serif 4, 26px, bold (screen headings)
- Subheading: Source Serif 4, 22px, bold
- Card Title: Source Serif 4, 30px, bold, white (text on image overlays)
- Section: DM Sans, 19px, bold (section headers)
- Body: DM Sans, 15px, regular (main content)
- Body Small: DM Sans, 14px, regular, driftwood color
- Label: DM Sans, 13px, semibold
- Caption: DM Sans, 12px, medium, driftwood color
- Tiny: DM Sans, 11px, medium, warmGray color
- Overline: DM Sans, 11px, semibold, 2px letter-spacing, warmGray
- CTA: DM Sans, 14px, bold, 0.8px letter-spacing, white
- Mono Large: IBM Plex Mono, 18px, bold, coral (stats)
- Mono Badge: IBM Plex Mono, 11px, semibold (pill badges)

### Spacing (4px Grid)

| Token | Value |
|-------|-------|
| xs | 4px |
| sm | 8px |
| md | 12px |
| lg | 16px |
| xl | 24px |
| xxl | 32px |
| xxxl | 48px |

**Border Radii:** Card=22px, Tile=16px, Button=14px, Input=12px, Badge=100px (pill)

**Key Sizes:** Feed card height=480px, Hero image=350px, Primary button=54px height, Search bar=46px, Icon button=40px

### Motion & Animation

Motion communicates hierarchy, not decoration. Every animation serves a purpose.

- Micro-interactions: 150ms ease-in-out (toggles, presses)
- Standard transitions: 250ms ease-out-cubic (fades, state changes)
- Page transitions: 350ms ease-in-out-cubic (navigation)
- Hero transitions: 500ms ease-out-cubic (shared element)
- Spring animations: 400ms elastic-out (checkboxes, saves)
- Breathing glow: 1800ms cycle (CTA button pulse)
- Parallax: 0.5 factor on feed cards while scrolling

---

## Navigation Structure

**Bottom Navigation Bar:** Curved bar with floating notch (custom forked component). 4 tabs:

| Tab | Icon | Label | Screen |
|-----|------|-------|--------|
| 0 | Compass | Discover | Vertical swipe feed |
| 1 | Grid | Explore | Category grid browser |
| 2 | Bookmark | My Stuff | Personal library |
| 3 | User | Profile | Stats & settings |

The nav bar has a curved notch that travels between tabs with a 450ms ease-in-out-cubic animation. Height: 85px.

---

## Screens & User Flows

### Flow 1: Onboarding (First Launch)

**Screen: Onboarding (3 pages, swipeable)**
- Animated gradient blob background (custom painter with floating colorful blobs)
- Page 1: "What vibes are you into?" — Multi-select chip grid (tags like: creative, relaxing, social, competitive, meditative, physical, maker, outdoor)
- Page 2: "Time & budget" — Slider for hours/week (1-10+), budget level selector (low/medium/high), solo vs social toggle
- Page 3: "You're ready!" — Celebration animation with confetti particles, CTA "Start Exploring"
- Wave underline animation on headings
- Each page has staggered entrance animations

### Flow 2: Discovery Feed (Main Screen)

**Screen: Discover Feed**
- Full-screen vertical PageView (TikTok-style swipe between hobby cards)
- Category chip filter bar at top (horizontal scroll: All, Creative, Outdoors, Fitness, etc.)
- Each card is 480px tall with:
  - Full-bleed hobby photo with parallax effect on scroll
  - Dark gradient overlay (transparent top → 92% opacity bottom)
  - Category pill badge (sand bg, driftwood text, category-colored icon)
  - Hobby title (Source Serif 4, 30px, white)
  - Hook text (DM Sans, 14px, white 70% opacity) — one-line elevator pitch
  - 3 spec badges in a row: Cost (coral), Time (amber), Difficulty (sage) — glass-morphism style pills
  - Save button (heart icon, with particle burst animation on tap)
  - "Try Today" breathing-glow coral CTA button at bottom
- Hero animation: Card image + title animate to detail screen on tap
- Swipe hint on first visit (subtle bouncing arrow)

### Flow 3: Explore (Category Browser)

**Screen: Explore**
- 2-column grid of category tiles
- Each tile: Category image, category name, hobby count badge
- Category-colored gradient overlay on each tile
- Filter panel (expandable): Budget range, time commitment, difficulty
- Tapping a category → filtered feed view of hobbies in that category

### Flow 4: Search

**Screen: Search**
- Full-width search input (no visible border when focused — minimal style)
- Real-time results as you type
- Results show HobbyMiniCard (thumbnail, title, category pill, cost badge)
- Empty state: "Try searching for 'pottery' or 'bouldering'"

### Flow 5: Hobby Detail

**Screen: Hobby Detail (push from feed card)**
- Hero image (350px, shared element animation from feed card)
- Scrollable content below:
  - Title (serif, 32px) + category pill
  - "Why you'll love it" section — editorial paragraph
  - Spec bar: Cost, Time, Difficulty badges (larger, more detailed)
  - **Starter Kit** — List of items with name, description, cost. Optional items marked. Total cost at bottom
  - **Common Pitfalls** — Numbered list of beginner mistakes to avoid
  - **Your Roadmap** — Animated checklist with steps. Each step has:
    - Checkbox with elastic spring animation on complete
    - Step title, description, estimated time (mono font)
    - Milestone markers (amber/gold badges)
    - Progress bar showing completion percentage
  - Floating "Try Today" CTA button at bottom

### Flow 6: Quickstart (Bottom Sheet)

**Screen: Quickstart (modal slide-up)**
- Backdrop blur behind sheet
- Condensed hobby info: image, title, first 3 roadmap steps
- "Start Now" CTA that marks hobby as "Trying"
- Swipe down or tap backdrop to dismiss

### Flow 7: My Stuff (Personal Library)

**Screen: My Stuff**
- Segmented control tabs: Saved | Trying | Active | Done
- Each tab shows a list/grid of hobby cards in that status
- Cards show: Thumbnail, title, progress bar (if Trying/Active), streak counter
- Empty states per tab with encouraging copy
- Swipe actions on cards to change status

### Flow 8: Profile

**Screen: Profile**
- User avatar (initial-based if no photo), display name, bio
- Stats row: Hobbies tried, Active hobbies, Total hours, Current streak
- Activity heatmap (GitHub-style contribution grid, green shades)
- Skills radar chart (showing proficiency across categories)
- Recent activity timeline
- Settings gear icon → Settings screen

### Flow 9: Auth

**Screen: Login**
- Email + password fields
- "Sign in with Google" button (with Google logo)
- Per-button loading spinners (not a full-screen loader)
- Link to Register screen
- Error messages inline below fields

**Screen: Register**
- Display name, email, password fields
- "Sign up with Google" button
- Same loading/error pattern as login

---

## Feature Screens (16 total)

### Discovery Features
| Screen | Purpose | Key UI |
|--------|---------|--------|
| **Mood Match** | "How are you feeling?" → hobby suggestions | Mood emoji grid, matched hobby cards |
| **Seasonal Picks** | Hobbies that suit the current season | Season banner, curated list |
| **Hobby Combos** | Complementary hobby pairs | Split-view cards showing 2 hobbies + why they pair well |
| **Compare Mode** | Side-by-side hobby comparison | 2-column layout, shared metrics (cost, time, difficulty) |

### Per-Hobby Tools
| Screen | Purpose | Key UI |
|--------|---------|--------|
| **Beginner FAQ** | Common questions per hobby | Expandable accordion cards, upvote count |
| **Cost Calculator** | 3-tier cost projection (starter/3mo/1yr) | Bar chart visualization, saving tips |
| **Budget Alternatives** | DIY / Budget / Premium options for starter kit items | 3-column comparison table |
| **Shopping List** | Checkable starter kit list | Checkbox list with cost, total at bottom |
| **Personal Notes** | Per-roadmap-step notes | Text areas tied to each roadmap step |

### Personal Tools
| Screen | Purpose | Key UI |
|--------|---------|--------|
| **Hobby Journal** | Photo journal entries | Card feed with photo, text, date. Add entry FAB |
| **Hobby Scheduler** | Weekly session planner | 7-day calendar grid, time slot blocks, add event modal |

### Social Features (planned)
| Screen | Purpose | Key UI |
|--------|---------|--------|
| **Buddy Mode** | Friend activity feed | Buddy list with avatars, activity stream, pairing requests |
| **Community Stories** | Success stories from other users | Quote cards with reactions (emoji buttons with counts) |
| **Local Discovery** | Nearby users doing similar hobbies | Map/list view with distance badges |

### Gamification (planned)
| Screen | Purpose | Key UI |
|--------|---------|--------|
| **Weekly Challenge** | Timed challenges with progress tracking | Challenge card, progress ring, countdown timer (mono 40px), leaderboard |
| **Year in Review** | Annual stats dashboard | Animated stat cards, category breakdown chart, highlights reel |

---

## Key UI Components

### Hobby Card (Feed)
- Full-bleed image with parallax
- Dark gradient overlay bottom 70%
- Category pill (sand bg, driftwood text, category icon in its color)
- Title: Source Serif 4, 30px, white
- Hook: DM Sans, 14px, white/70%
- Spec badges row: 3 glass pills (cost=coral, time=amber, difficulty=sage)
- Heart/save button with particle burst animation
- "Try Today" breathing-glow coral CTA

### Spec Badge
- Two styles: Glass (translucent dark bg, light border) and Solid (colored bg)
- Icon + label + value
- IBM Plex Mono for value text

### Glass Container
- Frosted dark glass surface
- Background: warmWhite with 60% opacity
- Noise grain texture overlay
- Subtle border (sandDark)
- Backdrop blur: 20px

### Category Chip/Pill
- Sand (#1E1E2E) background, no border
- Driftwood (#A0A0B8) text
- Category icon keeps its category color
- Rounded pill shape (radius 100)

### Try Today Button
- Coral (#FF6B6B) background
- White bold text "TRY TODAY"
- Breathing glow animation: Subtle coral shadow that pulses every 1.8s
- Press scale: 0.97

### Roadmap Step Tile
- Checkbox on left with elastic spring animation when checked
- Step title (label weight), description (body small), time estimate (mono caption)
- Milestone badge (amber pill) on milestone steps
- Checked state: coral checkmark, slight opacity on text

### Section Header
- Overline text (11px, uppercase, 2px letter-spacing, warmGray)
- Title text below (serif heading)

### Shimmer Skeleton
- Loading placeholder shapes
- Animated shimmer sweep (gradient moving left to right)
- Matches layout shape of the content it replaces

---

## Sample Hobby Content

**9 Categories:** Creative, Outdoors, Fitness, Maker/DIY, Music, Food, Collecting, Mind, Social

**Example Hobbies:**
- **Pottery** — "Get your hands dirty. Make something real." (Creative, CHF 40-120, 2h/week, Moderate)
- **Bouldering** — "Solve puzzles with your body." (Fitness, CHF 20-60, 3h/week, Moderate)
- **Sourdough** — "Slow food. Real bread." (Food, CHF 10-25, 1h/week, Easy)
- **Urban Sketching** — "Draw the world around you." (Creative, CHF 15-40, 2h/week, Easy)
- **Trail Running** — "Your gym is the mountain." (Outdoors, CHF 80-200, 3h/week, Moderate)
- **Vinyl Collecting** — "The ritual of analog music." (Collecting, CHF 30-100, 2h/week, Easy)
- **Meditation** — "Do nothing. Feel everything." (Mind, Free, 15min/day, Easy)
- **Board Games** — "Strategy, laughter, connection." (Social, CHF 20-50, 2h/week, Easy)

Each hobby includes: hook (one-line pitch), cost range, time commitment, difficulty, "why you'll love it" paragraph, starter kit with prices, common pitfalls list, and a 5-step roadmap with time estimates and milestone markers.

---

## User Data & States

**Hobby Status Flow:** Browse → Save → Try → Active → Done

**User Preferences (set in onboarding):**
- Vibes: multi-select tags (creative, relaxing, social, etc.)
- Hours per week: 1-10+
- Budget level: low / medium / high
- Solo vs social preference

**Tracking per hobby:**
- Status (saved/trying/active/done)
- Completed roadmap steps (checkbox set)
- Start date, last activity date
- Streak days (consecutive activity)
- Progress percentage (completed steps / total steps)

**Personal tools per hobby:**
- Journal entries (text + optional photo)
- Personal notes per roadmap step
- Weekly schedule events (day, time, duration)
- Shopping list checks

---

## Design Principles

1. **Dark-first:** Everything designed for #0A0A0F backgrounds. Light text, vibrant accents that pop on dark.
2. **Editorial feel:** Source Serif 4 headings give magazine-quality warmth. Not a cold tech app.
3. **Honest & actionable:** No fluff. Real costs, real time estimates, real starter kits. Content reads like advice from a friend.
4. **Reduce friction:** One-tap saves, breathing CTA buttons, pre-built roadmaps. Make starting feel easy.
5. **Celebrate progress:** Spring animations on checkboxes, streak counters, gold milestone badges, particle bursts on saves.
6. **Content-forward:** Full-bleed images, minimal chrome, the hobby imagery is the hero.
7. **Consistent tokens:** Every color, spacing, font, and animation follows the token system. Nothing ad-hoc.

---

## What to Design

Please design the complete app with all screens and flows described above. Key priorities:

1. **Onboarding flow** (3 pages with animated transitions)
2. **Discovery feed** (TikTok-style swipeable hobby cards)
3. **Explore grid** (category browser)
4. **Hobby detail** (full content page with roadmap checklist)
5. **My Stuff** (personal library with status tabs)
6. **Profile** (stats, heatmap, activity)
7. **Auth screens** (login + register)
8. **All 16 feature screens** (mood match, journal, scheduler, budget, FAQ, etc.)
9. **Bottom navigation bar** with curved notch
10. **Quickstart bottom sheet**
11. **Search screen**
12. **Settings screen**

Use the exact color palette, typography, and spacing tokens defined above. The app should feel premium, editorial, and encouraging — like a beautiful magazine that actually helps you start something new.
