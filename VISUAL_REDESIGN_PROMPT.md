# TrySomething — Premium Visual Redesign
# Paste this into Claude Code. This is a major aesthetic overhaul.

Read CLAUDE.md first. Then execute this visual redesign across the entire app.

---

## DESIGN PHILOSOPHY

The app is shifting from "Midnight Neon" (colorful dark mode with coral/amber/indigo accents) to **"Warm Cinematic Minimalism"** — inspired by editorial magazines, Kinfolk, and apps like DoReset/Opal/Headspace.

The core principles:
- **Restrained.** Almost no color. Black + warm cream + ONE coral accent for CTAs only.
- **Typographic.** Typography IS the design. Massive hero text, dramatic size contrast.
- **Breathing.** Far fewer elements per screen. Generous negative space.
- **Warm.** Not cold minimalism. Warm cream text, warm grays, muted warm tones.
- **Cinematic.** Photography and imagery should evoke feelings, not show literal objects.
- **One thing at a time.** Each screen asks the user to do ONE thing.

---

## STEP 1: Update the color palette

Edit `lib/theme/app_colors.dart`. Replace the current palette with:

```dart
// === WARM CINEMATIC MINIMALISM PALETTE ===

// Backgrounds
static const Color background = Color(0xFF0A0A0F);       // Deep black (keep)
static const Color surface = Color(0xFF111116);           // Barely lighter than bg
static const Color surfaceElevated = Color(0xFF1A1A20);   // Card/elevated surfaces

// Text — WARM, not pure white
static const Color textPrimary = Color(0xFFF5F0EB);       // Warm cream (headlines, primary)
static const Color textSecondary = Color(0xFFB0A89E);      // Warm gray (body text)
static const Color textMuted = Color(0xFF6B6360);          // Warm dark gray (metadata, captions)
static const Color textWhisper = Color(0xFF3D3835);        // Barely visible (dividers, hints)

// ONE accent color — coral for CTAs ONLY
static const Color accent = Color(0xFFFF6B6B);             // Coral — primary CTA only
static const Color accentMuted = Color(0x33FF6B6B);        // Coral at 20% — subtle backgrounds

// Success — used sparingly for completed states only
static const Color success = Color(0xFF06D6A0);            // Sage green — completed steps only
static const Color successMuted = Color(0x3306D6A0);       // Sage at 20%

// Borders and dividers — barely visible
static const Color border = Color(0xFF1E1E24);             // Subtle border
static const Color borderLight = Color(0x331E1E24);        // Even more subtle

// Glass/overlay
static const Color glassBackground = Color(0x15FFFFFF);    // White at 8% — glass surfaces
static const Color glassBorder = Color(0x20FFFFFF);        // White at 12% — glass borders
```

**REMOVE all of these from active use:**
- amber / gold (#FBBF24) — NO more gold badges
- indigo (#7C3AED) — NO more purple accents
- All category-specific colors (Creative=#D946EF, Fitness=#FF4757, etc.) — REMOVE
- Any multi-color badge scheme

Category differentiation should come from TYPOGRAPHY and LABELS, not from color. All categories use the same warm gray text.

---

## STEP 2: Update typography scale

Edit `lib/theme/app_typography.dart`. Create a much more dramatic hierarchy:

```dart
// === CINEMATIC TYPOGRAPHY SCALE ===

// Hero — massive, cinematic, used for screen headlines
static TextStyle hero = GoogleFonts.sourceSerif4(
  fontSize: 36,
  fontWeight: FontWeight.w700,
  color: AppColors.textPrimary,
  height: 1.1,
  letterSpacing: -0.5,
);

// Display — large, for section titles and emphasis
static TextStyle display = GoogleFonts.sourceSerif4(
  fontSize: 28,
  fontWeight: FontWeight.w600,
  color: AppColors.textPrimary,
  height: 1.2,
  letterSpacing: -0.3,
);

// Title — medium, for card titles and sub-sections
static TextStyle title = GoogleFonts.sourceSerif4(
  fontSize: 20,
  fontWeight: FontWeight.w600,
  color: AppColors.textPrimary,
  height: 1.3,
);

// Body — standard reading text
static TextStyle body = GoogleFonts.dmSans(
  fontSize: 15,
  fontWeight: FontWeight.w400,
  color: AppColors.textSecondary,
  height: 1.6,
  letterSpacing: 0.1,
);

// Caption — small, for metadata and labels
static TextStyle caption = GoogleFonts.dmSans(
  fontSize: 12,
  fontWeight: FontWeight.w500,
  color: AppColors.textMuted,
  height: 1.4,
  letterSpacing: 0.3,
);

// Overline — tiny, uppercase, for section labels
static TextStyle overline = GoogleFonts.dmSans(
  fontSize: 11,
  fontWeight: FontWeight.w600,
  color: AppColors.textMuted,
  height: 1.4,
  letterSpacing: 1.5,
).copyWith(textBaseline: TextBaseline.alphabetic);

// Data — monospace for numbers, stats, badges
static TextStyle data = GoogleFonts.ibmPlexMono(
  fontSize: 13,
  fontWeight: FontWeight.w500,
  color: AppColors.textSecondary,
  height: 1.4,
);

// DataLarge — for big stat numbers (like "2%" in DoReset)
static TextStyle dataLarge = GoogleFonts.ibmPlexMono(
  fontSize: 48,
  fontWeight: FontWeight.w300,
  color: AppColors.textPrimary,
  height: 1.0,
);

// Button — for CTA text
static TextStyle button = GoogleFonts.dmSans(
  fontSize: 16,
  fontWeight: FontWeight.w600,
  color: AppColors.background,  // Dark text on coral button
  height: 1.0,
  letterSpacing: 0.5,
);
```

The KEY change: hero text is 36pt, caption is 11pt. That's a 3.3x ratio. The current app probably has a 1.5-2x ratio. This dramatic contrast is what creates the cinematic feel.

---

## STEP 3: Create glass card component

Create `lib/components/glass_card.dart`:

A reusable glass surface card that replaces ALL current card styles in the app.

```dart
// Glass card with subtle blur, warm border, and elevation
// Usage: GlassCard(child: ..., onTap: ..., padding: ...)

Container(
  decoration: BoxDecoration(
    color: AppColors.glassBackground,  // White at 8%
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: AppColors.glassBorder, width: 0.5),
  ),
  child: ClipRRect(
    borderRadius: BorderRadius.circular(20),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Padding(
        padding: padding ?? EdgeInsets.all(20),
        child: child,
      ),
    ),
  ),
)
```

This replaces the current solid-color dark cards with semi-transparent glass surfaces. Every card in the app should use this component.

---

## STEP 4: Add flutter_animate for motion

Add `flutter_animate: ^4.5.0` to pubspec.yaml.

Apply these motion patterns EVERYWHERE:

### Screen entry — staggered fade up
Every screen's content should fade in with a slight upward slide, staggered by element:
```dart
Column(
  children: [
    heroText.animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0),
    bodyText.animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.05, end: 0),
    ctaButton.animate().fadeIn(duration: 400.ms, delay: 200.ms).slideY(begin: 0.05, end: 0),
  ],
)
```

### Card press — scale down
Cards should scale to 0.97 on press:
```dart
GestureDetector(
  onTapDown: (_) => setState(() => pressed = true),
  onTapUp: (_) => setState(() => pressed = false),
  onTapCancel: () => setState(() => pressed = false),
  child: AnimatedScale(
    scale: pressed ? 0.97 : 1.0,
    duration: Duration(milliseconds: 150),
    curve: Curves.easeOut,
    child: GlassCard(...),
  ),
)
```

### Tab transitions — cross fade
Tab switching uses FadeTransition (250ms), never instant rebuilds.

### Scroll parallax
Hero images on detail pages move at 0.7x scroll speed for parallax depth.

---

## STEP 5: Add noise texture overlay

Create or download a subtle noise/grain PNG texture (256x256, grayscale noise at ~3-5% opacity).

Place at `assets/textures/noise.png`.

Apply as an overlay on the main Scaffold background of EVERY screen:

```dart
Stack(
  children: [
    // Main content
    scaffold,
    // Noise overlay — makes flat black feel organic
    Positioned.fill(
      child: IgnorePointer(
        child: Opacity(
          opacity: 0.03,  // Very subtle
          child: Image.asset(
            'assets/textures/noise.png',
            repeat: ImageRepeat.repeat,
            fit: BoxFit.none,
          ),
        ),
      ),
    ),
  ],
)
```

This single addition makes the entire app feel less digital and more organic/cinematic.

---

## STEP 6: Redesign Discover tab layout

The current Discover has: search bar + chips + For You rail + Start Cheap rail + Start This Week rail. Too dense.

**New layout:**

```
[Search bar — floating, glass-style, subtle]

[Hero card — FULL WIDTH, tall (60% of screen height)]
  - Atmospheric hobby image (muted warm tones, editorial quality)
  - Large serif text over gradient: "Pottery"
  - One line in warm gray: "Get your hands dirty. Make something real."
  - Subtle spec info at bottom: "CHF 40-120 · 2h/week · Easy"
  - This is the #1 recommended hobby for this user

[Small gap]

[Section label in overline: "MORE FOR YOU"]

[2 smaller cards side by side — glass cards]
  - Each: muted image, title, one spec line
  - These are alternatives #2 and #3

[Section label: "START CHEAP"]
[Horizontal scroll of compact cards — 3 visible]

[Section label: "START THIS WEEK"]  
[Horizontal scroll of compact cards — 3 visible]
```

The hero card is the star. Everything else is secondary. The user's eye goes to ONE hobby first.

Remove the filter chips from the top. Move category filtering to a filter icon on the search bar that opens a bottom sheet.

---

## STEP 7: Redesign Home tab layout

The Home tab should feel like opening a journal, not an app dashboard.

**New layout:**

```
[Top: warm greeting — "Good evening, Romulo" in hero text]
[Below: "Week 2 of Pottery" in overline]

[Glass card — full width, generous padding]
  - "Your next step" in caption/overline
  - "Practice centering the clay" in display text
  - "15 minutes · At home" in data text
  - [Coral CTA: "Start session"]

[Subtle divider]

[Glass card — smaller]
  - "This week" in overline
  - Simple 3-line plan (Mon / Wed / Sat with times)
  - Tap to expand

[Glass card — smaller]
  - "Need help?" with coach icon
  - 3 starter chips: "I'm stuck" / "Simplify this" / "Motivate me"

[Bottom: if stalled 3+ days]
  - Warm message: "It's been a few days. Want to try a quick 10-minute session?"
  - Two options: "Let's go" (coral) / "Maybe later" (text link)
```

NO metrics/stats/graphs/streaks on the home screen. Those live in the You tab. Home is about the NEXT ACTION, not the past.

---

## STEP 8: Redesign Hobby Detail page

Current detail page has too many sections competing. New approach:

```
[Full-bleed atmospheric image — 50% of screen, with gradient fade to black at bottom]
[Over image: category overline "CREATIVE" in warm gray]
[Over image: "Pottery" in hero text]
[Over image: "Get your hands dirty. Make something real." in body]

[Spec row — warm gray text, no colored badges]
  "CHF 40-120 · 2h/week · Easy · Solo · At home"
  All one line, all same muted color, separated by middots

[Glass card: "Why this fits you"]
  - Personalized reasons from onboarding
  - Warm, encouraging tone

[Glass card: "Start in 20 minutes"]
  - Minimum viable first session
  - 2 items to buy, one tiny action
  - This should feel like the easiest possible entry

[Glass card: "What to expect"]
  - Week 1: Try it
  - Week 2: Repeat it
  - Week 3: Reduce friction
  - Week 4: Decide
  - Shown as 4 simple lines, not a complex roadmap widget

[Glass card: "Starter kit"]
  - Product images + names + prices + buy links
  - Minimum / Best value toggle
  - Clean, not cluttered

[Floating coral CTA at bottom: "Start the easy version"]
```

---

## STEP 9: Redesign all spec badges

REMOVE the current colored badge system entirely. Replace with simple warm gray text:

**Old:** Three separate colored pills — [💰 CHF 40-120] [⏱ 2h/week] [📊 Easy]
**New:** One line of warm gray text — `CHF 40-120 · 2h/week · Easy`

Use `AppColors.textMuted` and `AppTypography.data` for this text. Middot (·) as separator. No background, no border, no icons, no color. Just quiet information.

Apply everywhere: feed cards, detail pages, search results, match results.

---

## STEP 10: Redesign bottom navigation

The bottom nav should feel like a floating glass dock, not a solid bar.

```dart
Container(
  margin: EdgeInsets.only(left: 40, right: 40, bottom: MediaQuery.of(context).padding.bottom + 12),
  decoration: BoxDecoration(
    color: AppColors.glassBackground,
    borderRadius: BorderRadius.circular(28),
    border: Border.all(color: AppColors.glassBorder, width: 0.5),
  ),
  child: ClipRRect(
    borderRadius: BorderRadius.circular(28),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Home icon — filled when active, outline when inactive
            // Discover icon
            // You icon
          ],
        ),
      ),
    ),
  ),
)
```

3 icons only. No labels. The active icon is warm cream, inactive icons are warm dark gray. No coral on the nav — coral is ONLY for CTAs.

If the current curved nav bar is too different from this, replace it. The glass floating dock is part of the new identity.

---

## STEP 11: Update the CTA button style

All primary CTAs should be warm coral with subtle glow:

```dart
Container(
  decoration: BoxDecoration(
    color: AppColors.accent,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: AppColors.accent.withOpacity(0.3),
        blurRadius: 20,
        offset: Offset(0, 8),
      ),
    ],
  ),
  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
  child: Text("Start the easy version", style: AppTypography.button),
)
```

Secondary CTAs: no background, just warm cream text with subtle underline or arrow.

There should only be ONE coral CTA visible per screen at any time. If there are multiple actions, only the primary one gets coral.

---

## STEP 12: Update onboarding

The onboarding should feel cinematic and calm, not quizzy.

Each page: one question, large serif text, minimal options, generous spacing.
Background: subtle gradient from #0A0A0F to #0F0F18 (barely perceptible deep purple-black).

Option cards: glass cards, warm cream text, subtle border highlight on selection (warm cream border, not teal/green).

The "You're ready" page: large serif "You're ready" text, one recommended hobby below in a beautiful glass card with atmospheric image, warm cream text. No floating animated tiles, no match percentages. Just: "We think you'll love Pottery" with a coral CTA.

---

## STEP 13: Apply to all remaining screens

Go through EVERY screen in `lib/screens/` and apply:

1. Warm cream text instead of pure white
2. Glass cards instead of solid dark cards
3. No colored badges — warm gray text with middot separators
4. One coral CTA per screen max
5. Staggered fade-in animation on screen entry (flutter_animate)
6. Scale-down on card press (0.97)
7. Noise texture overlay on scaffold
8. Dramatic typography hierarchy (hero 36pt → caption 11pt)
9. Generous negative space — when in doubt, add more padding

Screens to update:
- Search
- Journal
- Coach
- Library (You tab saved/tried/active)
- Profile section
- Settings
- Pro/upgrade sheet
- Trial offer screen
- Quickstart bottom sheet
- Compare (if still accessible)

---

## STEP 14: Update the upgrade sheet / paywall

The paywall should feel editorial, not salesy.

```
[Glass surface bottom sheet]

"Start hobbies you
actually stick with"          ← hero text, 32pt

"Step-by-step guidance for    ← body text, warm gray
your first 30 days"

[3 benefit lines — warm cream text, no icons, no checkmarks]
"Know the next right step"
"Get unstuck fast"
"Track progress with photos"

[Plan toggle — glass pills]
Monthly CHF 4.99 | Annual CHF 39.99 (save 33%)

[Coral CTA: "Try free for 7 days"]

[Warm gray text link: "Restore purchase"]
```

No feature comparison tables. No bullet lists. No lock icons in the sheet. Just the emotional promise in beautiful typography.

---

## ORDER OF EXECUTION

1. Update colors (app_colors.dart) — everything downstream depends on this
2. Update typography (app_typography.dart)
3. Add flutter_animate to pubspec, create noise texture, create glass_card component
4. Redesign bottom nav
5. Redesign Home tab
6. Redesign Discover tab
7. Redesign Hobby Detail
8. Update all spec badges across the app
9. Update CTA button style
10. Update onboarding
11. Update remaining screens (search, journal, coach, library, settings, paywall)
12. Run `dart analyze` on all changed files
13. Full `flutter analyze` at the end

After each major screen change, verify on physical device (Nothing Phone 3a). Chrome is NOT sufficient — check that glass blur effects perform well and don't cause jank.

---

## PERFORMANCE NOTES

- `BackdropFilter` is expensive. Use it on glass cards but NOT on every tiny element. Limit to ~3-5 visible blur surfaces per screen.
- If blur causes jank on the feed (many cards scrolling), use a simpler glass effect: just the semi-transparent background + border WITHOUT BackdropFilter. Reserve real blur for static/hero elements.
- The noise texture image should be small (256x256) and repeated. Don't use a full-screen image.
- `flutter_animate` is performant but don't over-animate. Stagger reveals on screen entry, scale on press. That's it. No constant motion.
