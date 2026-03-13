# TrySomething — Session Screen Implementation
# Paste this into Claude Code. This is the single most important feature in the entire app.
# Read CLAUDE.md and VISUAL_REDESIGN_PROMPT.md first.

---

## CONTEXT

The session screen is where TrySomething stops being a to-do list and becomes an experience. Currently, users can tap "complete" on roadmap steps in 10 seconds without doing anything. That's the core retention problem.

This task builds a FULL-SCREEN immersive session experience with three phases: Prepare → Do → Reflect. The user cannot fake progress. They spend real time with their hobby, then reflect on it. Every animation, every word, every transition should say: "This is YOUR time."

Rive assets are NOT ready yet. Use animated placeholders built with CustomPainter + flutter_animate that look premium on their own. Design the placeholder to be easily swappable with a Rive widget later.

---

## PACKAGES NEEDED

Add these to pubspec.yaml if not already present:
```yaml
flutter_animate: ^4.5.0    # Staggered animations, springs, fades
wakelock_plus: ^1.2.1      # Keep screen awake during session
```

Run `flutter pub get` after adding.

---

## FILE STRUCTURE

Create these files:
```
lib/screens/session/
├── session_screen.dart           # Main session screen (manages phases)
├── session_prepare_phase.dart    # Phase 1: Prepare
├── session_timer_phase.dart      # Phase 2: Timer (the core)
├── session_reflect_phase.dart    # Phase 3: Reflect
├── session_complete_phase.dart   # Completion moment
├── hold_to_complete_widget.dart  # Hold-to-complete for check-in mode steps

lib/components/
├── brushstroke_timer_painter.dart   # CustomPainter placeholder for Rive brushstroke
├── category_shape_painter.dart      # Abstract category background shapes
├── radial_hold_painter.dart         # Radial fill for hold-to-complete
├── session_glow_widget.dart         # Warm ambient glow background

lib/models/
├── session.dart                     # Session data model (Freezed)

lib/providers/
├── session_provider.dart            # Session state management
```

---

## DATA MODEL

Create `lib/models/session.dart` with Freezed:

```dart
enum CompletionMode { timer, photoProof, checkIn }

enum ReflectionChoice { lovedIt, okay, struggled }

@freezed
class SessionState with _$SessionState {
  const factory SessionState({
    required String hobbyId,
    required String hobbyTitle,
    required String hobbyCategory,      // "Creative", "Outdoors", etc.
    required String stepId,
    required String stepTitle,
    required String stepDescription,
    required String stepInstructions,    // Detailed instructions shown during timer
    required String whatYouNeed,         // "Clay, a flat surface, your hands"
    required int recommendedMinutes,
    required CompletionMode completionMode,
    @Default(15) int selectedMinutes,
    @Default(0) int elapsedSeconds,
    @Default(false) bool isPaused,
    @Default(false) bool isComplete,
    ReflectionChoice? reflection,
    String? journalText,
    String? photoPath,
  }) = _SessionState;
}
```

Run `dart run build_runner build` after creating.

---

## STEP 1: BRUSHSTROKE TIMER PLACEHOLDER (CustomPainter)

Create `lib/components/brushstroke_timer_painter.dart`:

This is the placeholder that will later be replaced by the Rive asset. It must look premium on its own.

Paint an organic, calligraphic brushstroke path using CustomPainter. The stroke draws itself based on a `progress` value (0.0 to 1.0).

```dart
class BrushstrokeTimerPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  final Color strokeColor;

  BrushstrokeTimerPainter({required this.progress, this.strokeColor = const Color(0xFFF5F0EB)});

  @override
  void paint(Canvas canvas, Size size) {
    // Define the brushstroke as a flowing S-curve path
    final path = Path();
    
    // Scale path to widget size
    final sx = size.width / 300;
    final sy = size.height / 300;
    
    path.moveTo(35 * sx, 230 * sy);
    path.cubicTo(42*sx, 210*sy, 52*sx, 188*sy, 68*sx, 168*sy);
    path.cubicTo(84*sx, 148*sy, 105*sx, 132*sy, 128*sx, 125*sy);
    path.cubicTo(151*sx, 118*sy, 172*sx, 122*sy, 188*sx, 135*sy);
    path.cubicTo(204*sx, 148*sy, 212*sx, 168*sy, 210*sx, 188*sy);
    path.cubicTo(208*sx, 208*sy, 195*sx, 222*sy, 178*sx, 228*sy);
    path.cubicTo(161*sx, 234*sy, 148*sx, 225*sy, 142*sx, 212*sy);
    path.cubicTo(136*sx, 199*sy, 140*sx, 185*sy, 152*sx, 176*sy);
    path.cubicTo(164*sx, 167*sy, 180*sx, 168*sy, 192*sx, 175*sy);
    path.cubicTo(204*sx, 182*sy, 215*sx, 195*sy, 222*sx, 210*sy);
    path.cubicTo(229*sx, 225*sy, 238*sx, 240*sy, 252*sx, 248*sy);

    // Use PathMetric to draw only the portion matching progress
    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      final extractedPath = metric.extractPath(0, metric.length * progress);
      
      // Layer 1: thick glow (behind)
      final glowPaint = Paint()
        ..color = strokeColor.withOpacity(0.15 * progress)
        ..strokeWidth = 14
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawPath(extractedPath, glowPaint);
      
      // Layer 2: medium body
      final bodyPaint = Paint()
        ..color = strokeColor.withOpacity(0.5)
        ..strokeWidth = 8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(extractedPath, bodyPaint);
      
      // Layer 3: thin sharp core
      final corePaint = Paint()
        ..color = strokeColor
        ..strokeWidth = 3.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(extractedPath, corePaint);
    }
  }

  @override
  bool shouldRepaint(BrushstrokeTimerPainter oldDelegate) => oldDelegate.progress != progress;
}
```

Wrap this in a widget called `BrushstrokeTimer`:
```dart
class BrushstrokeTimer extends StatelessWidget {
  final double progress;
  final double size;
  
  // TODO: When Rive asset is ready, swap CustomPaint for:
  // RiveAnimation.asset('assets/rive/brushstroke_timer.riv', 
  //   stateMachines: ['State Machine 1'],
  //   onInit: (artboard) { /* bind progress input */ })
  
  Widget build(context) => CustomPaint(
    size: Size(size, size),
    painter: BrushstrokeTimerPainter(progress: progress),
  );
}
```

---

## STEP 2: CATEGORY BACKGROUND SHAPES

Create `lib/components/category_shape_painter.dart`:

Each hobby category has a unique abstract shape rendered at very low opacity behind the session content. These are NOT icons — they're large, abstract, ambient forms.

```dart
class CategoryShapePainter extends CustomPainter {
  final String category; // "Creative", "Outdoors", etc.
  final double opacity;  // typically 0.03-0.05

  // Define 9 unique abstract paths, one per category:
  // Creative: organic blob
  // Outdoors: gentle horizon arc
  // Fitness: smooth wave
  // Music: flowing sine curve
  // Food: soft spiral
  // Maker: angular crystal form
  // Mind: concentric circles
  // Collecting: overlapping rounded squares
  // Social: two intersecting circles
  
  // Each shape should be simple (10-20 control points max), large,
  // and painted in warm cream (#F5F0EB) at the given opacity.
}
```

Design each shape as a simple, elegant, abstract form. NOT detailed. NOT literal. These should be barely visible — atmospheric, not decorative.

---

## STEP 3: SESSION GLOW WIDGET

Create `lib/components/session_glow_widget.dart`:

A soft radial warm glow that fades in when the session screen appears. Sits behind all content.

```dart
class SessionGlow extends StatelessWidget {
  final bool active;
  
  // AnimatedContainer or AnimatedOpacity
  // When active: show a RadialGradient centered on screen
  // Colors: [Color(0x0CF5F0EB), Color(0x00F5F0EB)] — warm cream at ~5% in center, fading to transparent
  // Radius: 0.6 of screen width
  // Animate opacity from 0 to 1 over 600ms with Curves.easeOut
}
```

---

## STEP 4: RADIAL HOLD PAINTER

Create `lib/components/radial_hold_painter.dart`:

For check-in mode steps. A circular arc that fills clockwise as the user holds the button.

```dart
class RadialHoldPainter extends CustomPainter {
  final double holdProgress; // 0.0 to 1.0

  // Draw an arc starting from -pi/2 (12 o'clock)
  // Sweep angle: 2*pi * holdProgress
  // Stroke: coral (#FF6B6B), 4px width, round cap
  // Behind it: a faint track circle in warm dark gray at 10% opacity
  // The arc should feel smooth — use with an AnimationController
}
```

Wrap in a `HoldToCompleteButton` widget:
- Shows instruction text in center: "Hold to complete"
- On long press down: starts animating holdProgress from 0 to 1 over 2.5 seconds
- On release before 1.0: animate smoothly back to 0 (spring curve, 300ms)
- On reaching 1.0: trigger haptic feedback (HapticFeedback.mediumImpact), call onComplete callback
- The button itself is a large circle (80x80) with glass background
- During hold: the circle subtly scales up to 1.05

---

## STEP 5: SESSION PROVIDER

Create `lib/providers/session_provider.dart`:

StateNotifier that manages the entire session lifecycle:

```dart
class SessionNotifier extends StateNotifier<SessionState?> {
  Timer? _timer;
  
  // startSession(hobbyId, stepId, ...) — creates SessionState, starts prepare phase
  // selectDuration(minutes) — updates selectedMinutes
  // beginTimer() — starts the countdown, transitions to timer phase
  // pauseTimer() — pauses countdown
  // resumeTimer() — resumes
  // endTimerEarly() — only from pause menu, confirms first
  // completeTimer() — timer hit 0, transition to reflect phase
  // submitReflection(ReflectionChoice, String? journalText, String? photoPath) 
  //   — saves to journal, marks step complete via API, updates streak
  // holdComplete() — for check-in mode, marks step done
  // dispose() — cancel timer, release wakelock
}
```

The timer should:
- Use `Timer.periodic(Duration(seconds: 1))` to tick
- Calculate elapsed from actual DateTime difference (not just counter) so it survives background
- Activate wakelock when timer starts, release when session ends
- Fire analytics events: `session_started`, `session_paused`, `session_completed`

---

## STEP 6: SESSION SCREEN (Main orchestrator)

Create `lib/screens/session/session_screen.dart`:

This is a FULL-SCREEN route that takes over the entire screen. No bottom nav. No app bar. Immersive.

```dart
class SessionScreen extends StatefulWidget {
  final String hobbyId;
  final String stepId;
  // ... other required params passed from route
}
```

**Entry transition:**
When navigating to this screen, use a custom page route with:
- The previous screen fades back (opacity 0, scale 0.95) over 400ms
- Background deepens to pure black
- Session content fades up from below over 500ms
- The SessionGlow widget activates

Use `PageRouteBuilder` with custom `transitionsBuilder` for this.

**Phase management:**
The screen manages 4 phases internally using a state variable:
1. `prepare` — SessionPreparePhase widget
2. `timer` — SessionTimerPhase widget  
3. `reflect` — SessionReflectPhase widget
4. `complete` — SessionCompletePhase widget

Phase transitions use `AnimatedSwitcher` with custom fade+slide transitions (400ms).

**Layout:**
```dart
Scaffold(
  backgroundColor: Color(0xFF0A0A0F),
  body: Stack(
    children: [
      // Layer 1: Category background shape (ambient, very low opacity)
      Positioned.fill(child: CategoryShape(category: hobby.category)),
      
      // Layer 2: Session glow (warm radial gradient)
      Positioned.fill(child: SessionGlow(active: true)),
      
      // Layer 3: Phase content (switches between prepare/timer/reflect/complete)
      SafeArea(
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: 400),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween(begin: Offset(0, 0.03), end: Offset.zero).animate(animation),
                child: child,
              ),
            );
          },
          child: currentPhaseWidget,
        ),
      ),
    ],
  ),
)
```

---

## STEP 7: PREPARE PHASE

Create `lib/screens/session/session_prepare_phase.dart`:

The moment before the timer starts. Give the user a breath.

```
Layout (centered, generous padding):

[Category overline] — "CREATIVE" in 11pt uppercase, warm dark gray, letter-spaced
  → animate: fadeIn 400ms + slideY 0.05

[Hobby title] — "Pottery" in 28pt Source Serif 4, warm cream
  → animate: fadeIn 400ms, delay 100ms + slideY 0.05

[Step title] — "Shape your first pinch pot" in 15pt DM Sans, warm gray
  → animate: fadeIn 400ms, delay 200ms + slideY 0.05

[What you need] — "Clay, a flat surface, and your hands" in 12pt, warm dark gray
  → animate: fadeIn 400ms, delay 300ms

[Spacer — generous, at least 40px]

[Duration selector] — 3 glass pills side by side: [10 min] [15 min] [30 min]
  → default selected based on step's recommendedMinutes
  → selected pill: warm cream border, warm cream text
  → unselected: no border, warm dark gray text
  → glass background on all pills
  → animate: fadeIn 400ms, delay 400ms

[Spacer — generous]

[CTA] — "I'm ready" in coral, full width, 16px radius, glow shadow
  → animate: fadeIn 400ms, delay 500ms + slideY 0.05
  → on tap: transition to timer phase

[Below CTA] — "Not now" warm gray text link, 14pt
  → tapping exits the session screen with reverse transition
  → animate: fadeIn 400ms, delay 600ms
```

Every element staggers in with flutter_animate. The whole phase should feel like a calm invitation, not an interface.

---

## STEP 8: TIMER PHASE

Create `lib/screens/session/session_timer_phase.dart`:

The core of the entire app. This screen should feel sacred.

```
Layout:

[Top center, small]
"POTTERY · STEP 1" in 11pt overline, warm dark gray

[Center — the star]
BrushstrokeTimer widget — 240x240
  progress: elapsedSeconds / (selectedMinutes * 60)
  The stroke draws itself as time passes
  Animate progress smoothly (not jumpy per-second)
  Use AnimatedBuilder with the timer to interpolate

[Below brushstroke]
Time remaining — "12:34" in 48pt IBM Plex Mono (dataLarge), warm cream
  This counts DOWN from selectedMinutes to 0:00
  Animate number changes with a subtle crossfade (not just instant text swap)
  At under 1 minute: text color shifts slightly warmer (subtle)

[Below time]  
Step instructions — stepInstructions text, 15pt DM Sans, warm gray, centered
  Max 3 lines. If longer, make scrollable within a constrained height.
  This is the actual guidance: "Roll a ball of clay the size of your fist.
  Press your thumb into the center. Slowly pinch and rotate to form a bowl."

[Bottom center]
Pause button — a custom icon (two vertical rounded rectangles, not Material icon)
  Color: warm dark gray (#6B6360)
  Size: 44x44 tap target, icon 20x20
  On tap: toggles pause state

NO other buttons. NO nav. NO back. NO distractions.
The bottom nav is HIDDEN on this screen.
```

**Pause state:**
When paused:
- Brushstroke freezes at current progress
- Time display stops
- "Paused" label appears below the time in 12pt warm dark gray, fades in
- Pause icon morphs to play icon (single triangle) with AnimatedSwitcher
- A subtle "End session early" text link appears below the play button in warm dark gray
  - Tapping shows a confirmation: "End without completing this step?" Yes/No
  - If yes: exit session, step NOT marked complete
- Resume: tap play, everything continues smoothly

**Timer behavior:**
- Use actual DateTime tracking, not just incrementing a counter
  - On start: record `_startTime = DateTime.now()`
  - On tick: `elapsed = DateTime.now().difference(_startTime) - totalPauseDuration`
  - This survives app backgrounding
- Wakelock active during timer (WakelockPlus.enable())
- At halfway: subtle haptic (HapticFeedback.lightImpact)
- At 1 minute remaining: subtle haptic
- At 0:00: transition to reflect phase

**Transition to reflect:**
- The brushstroke holds at 1.0 for 500ms (the complete stroke visible)
- Then: the glow behind the brushstroke intensifies slightly over 300ms
- "Session complete" fades in below the brushstroke in 28pt serif, warm cream
- Time display changes to show total: "15 minutes"
- Hold for 1.5 seconds on this completion moment — let the user SIT with it
- Then: crossfade to reflect phase

---

## STEP 9: REFLECT PHASE

Create `lib/screens/session/session_reflect_phase.dart`:

Quick, warm, not a chore.

```
Layout:

[Top — generous space from top]
"How was that?" in 28pt Source Serif 4, warm cream, centered
  → fadeIn 400ms

[3 reflection cards — vertical stack with 16px gaps]
Each card is a glass card with:
  - An abstract symbol on the left (48x48, CustomPainter — see below)
  - Label on the right: warm cream, 18pt DM Sans semibold
  - Description below label: warm gray, 13pt DM Sans
  - Card height: ~80px, full width with 24px horizontal padding
  → stagger fadeIn: 400ms each, 100ms delay between cards

Card 1: "Loved it"
  Symbol: a flowing upward curve (CustomPainter — 3 bezier curves rising)
  Description: "I could do this again"

Card 2: "It was okay"
  Symbol: a gentle horizontal wave (CustomPainter — sine wave shape)
  Description: "Still figuring it out"

Card 3: "Struggled"
  Symbol: a soft knot (CustomPainter — overlapping loop)
  Description: "Something felt off"

Selected state:
  - Card gets warm cream border (1px, animated in over 200ms)
  - Symbol brightens slightly
  - Other cards fade to 50% opacity over 200ms
  - Subtle haptic on selection

[Below cards — appears after selection, slides up]
"Want to remember anything?" in 13pt warm gray

[Glass text input — single line expanding to multi-line]
  Placeholder: "What went well? What was tricky?" in warm dark gray
  Text input: warm cream on glass background
  Optional — user can skip this

[If Pro + creative/maker hobby:]
  Camera icon button next to input: "Add a photo" warm gray text
  Tapping opens camera, photo is stored for journal entry

[Bottom — full width]
"Save & finish" — coral CTA
  → on tap: saves everything, transitions to complete phase
"Skip" — warm gray text link below
  → saves only the reflection choice (no journal text), transitions to complete
```

**Reflection symbols (CustomPainter placeholders):**

These are abstract marks in the same brushstroke visual language as the timer. NOT emoji. NOT icons.

```dart
// "Loved it" — upward flowing curves
// Paint 2-3 bezier curves that sweep upward, warm cream, stroke 2.5px, round cap

// "It was okay" — gentle wave
// Paint a smooth sine wave, ~2 periods, warm cream, stroke 2.5px

// "Struggled" — soft knot
// Paint a figure-8 or trefoil knot shape, warm cream, stroke 2.5px
```

Each symbol should feel hand-drawn and organic, matching the brushstroke timer's aesthetic.

---

## STEP 10: COMPLETE PHASE (Brief)

Create `lib/screens/session/session_complete_phase.dart`:

This is a 2-3 second moment before returning to the app. Don't rush it.

```
Layout:

[Center]
The completed brushstroke at full progress (1.0), slightly larger than during timer (260x260)
  → the glow behind it is slightly brighter than during the timer

[Below]
"Step complete" in 13pt overline, warm dark gray
  → fadeIn 300ms, delay 500ms

[Below]  
Step title: "Shape your first pinch pot" in 20pt serif, warm cream, with subtle line-through or checkmark
  → fadeIn 300ms, delay 700ms

[Below]
"Next: Learn to center on the wheel" in 14pt warm gray — preview of what's coming
  → fadeIn 300ms, delay 900ms

Auto-transition after 3 seconds:
  → Session screen fades out (opacity 0, scale 0.98, 400ms)
  → Home tab fades back in
  → The completed step now shows a sage green left border on its glass card
  → The next step slides into view
```

**Background saves (happen during this phase):**
- Journal entry created automatically: reflection choice + optional text + optional photo
- Step marked complete via API (POST /api/users/hobbies/{hobbyId}/steps/{stepId}/complete)
- Streak updated
- Analytics: `session_completed` with hobbyId, stepId, duration, reflection choice
- If first ever session: `first_session_completed` event
- Wakelock released

---

## STEP 11: HOLD-TO-COMPLETE (Check-in mode)

Create `lib/screens/session/hold_to_complete_widget.dart`:

For setup/purchase steps only (like "Buy your starter clay"). Not a full session — just a deliberate confirmation.

This is a standalone widget that can be used on the hobby detail page or step view.

```
Layout:

[Glass card, generous padding]
  Step title: "Buy stoneware clay" in 20pt serif, warm cream
  Step description in warm gray body text
  
  [Center below]
  Large circle (80x80) with glass background
    Inside: "Hold to complete" in 12pt warm gray, centered
    
    On long press:
      RadialHoldPainter draws a coral arc clockwise from 12 o'clock
      The circle subtly scales up to 1.05 (AnimatedScale, 2500ms)
      
    On release before complete:
      Arc animates back to 0 (spring curve, 300ms)
      Scale returns to 1.0
      
    On reaching 1.0 (2.5 seconds held):
      Haptic: HapticFeedback.mediumImpact
      Circle fills briefly with coral at 20% opacity (flash, 200ms)
      "Done" replaces "Hold to complete" text with checkmark
      Step marked complete
      Card border changes to sage green at 30%
```

---

## STEP 12: ROUTING AND INTEGRATION

**Add route:**
In `lib/router.dart`, add the session screen route:
```dart
GoRoute(
  path: '/session/:hobbyId/:stepId',
  builder: (context, state) => SessionScreen(
    hobbyId: state.pathParameters['hobbyId']!,
    stepId: state.pathParameters['stepId']!,
  ),
  // Custom page transition — the world-falls-away effect
  pageBuilder: (context, state) => CustomTransitionPage(
    child: SessionScreen(...),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
    transitionDuration: Duration(milliseconds: 500),
  ),
)
```

**Replace all step completion buttons:**
Every place in the app where a step can be marked complete must now route to the session screen instead:
- Home tab "Start session" CTA → `/session/{hobbyId}/{stepId}`
- Roadmap step view "Begin" button → `/session/{hobbyId}/{stepId}`
- Step detail "Complete" button → REMOVED. No more direct completion.

The ONLY ways to complete a step now:
1. Timer mode: sit through the full timer + reflect
2. Photo proof: sit through timer + take photo + reflect
3. Check-in: hold button for 2.5 seconds

**Update the RoadmapStep model:**
Add `completionMode` field to RoadmapStep:
```dart
enum CompletionMode { timer, photoProof, checkIn }
```
Default: `timer`. Steps that are purchases/setup: `checkIn`. Creative/maker final steps: `photoProof` (Pro only, falls back to `timer` on free).

Update seed data to assign correct completion modes to each step across all 150 hobbies.

---

## STEP 13: STEP COMPLETION MODE ASSIGNMENT

When updating seed data, follow these rules:

**Timer mode (default):**
- Any step where the user is actively practicing/doing the hobby
- "Practice centering clay" → timer
- "Learn basic chess openings" → timer
- "Do a 15-minute sketch" → timer

**Check-in mode:**
- Purchase/setup steps
- "Buy starter clay" → checkIn
- "Set up your workspace" → checkIn
- "Download chess app" → checkIn

**Photo proof mode (Pro):**
- Creative output steps where visual proof makes sense
- "Shape your first pinch pot" → photoProof
- "Complete your first sketch" → photoProof
- "Bake your first sourdough" → photoProof
- Falls back to timer mode for free users

---

## VISUAL QUALITY CHECKLIST

Before marking this task done, verify each of these:

- [ ] Brushstroke timer draws smoothly (not jumpy per-second, interpolated)
- [ ] Brushstroke has visible glow effect behind it (3 layers: glow/body/core)
- [ ] Category background shape is barely visible (3-5% opacity, large, ambient)
- [ ] Session glow is warm and subtle, not a spotlight
- [ ] All text uses warm cream (#F5F0EB), NOT pure white
- [ ] All secondary text uses warm grays, NOT cool grays
- [ ] Only ONE coral element per phase (the CTA in prepare, nothing in timer, save button in reflect)
- [ ] Staggered fade-in animations on prepare phase (each element delays 100ms)
- [ ] Phase transitions are smooth crossfades (400ms), not instant
- [ ] Timer numbers crossfade on change, don't just swap
- [ ] Pause icon morphs to play icon, doesn't just swap
- [ ] Reflection cards have scale/opacity animation on selection
- [ ] Hold-to-complete arc is smooth, springs back on early release
- [ ] Glass cards are semi-transparent with subtle blur, NOT solid dark rectangles
- [ ] Screen stays awake during timer (wakelock active)
- [ ] No bottom nav visible during session
- [ ] No app bar during session
- [ ] Back gesture is disabled during active timer (only pause → end early)
- [ ] Haptics fire at halfway, 1-minute, and completion
- [ ] Works correctly on Nothing Phone 3a (safe areas, performance)
- [ ] 60fps throughout all animations

---

## ORDER OF IMPLEMENTATION

1. Data model + provider (session.dart, session_provider.dart)
2. Brushstroke timer painter (the visual centerpiece)
3. Category shape painter + session glow + radial hold painter
4. Session screen shell (phase management + transitions + routing)
5. Prepare phase
6. Timer phase (the most complex — get this right)
7. Reflect phase
8. Complete phase
9. Hold-to-complete widget
10. Integration: replace all step completion buttons with session routing
11. Update seed data with completionMode per step
12. Visual QA on physical device

After each file: `dart analyze` on that file.
After all files: full `flutter analyze` + test on Nothing Phone 3a.
