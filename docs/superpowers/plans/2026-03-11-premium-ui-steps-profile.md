# Premium UI — Steps & Profile Redesign Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Redesign the roadmap step tiles into a `timelines_plus` vertical timeline and redesign the You/Profile screen into a cinematic Collector Card layout.

**Architecture:** `RoadmapStepTile` internal rewrite using `timelines_plus` `TimelineTile` — public constructor API unchanged. `PageDots` extracted from `home_screen.dart` to a shared component. `YouScreen` converted from `ConsumerWidget` to `ConsumerStatefulWidget` to hold `PageController` state for the swipeable hobby card.

**Tech Stack:** Flutter 3.6.0, Riverpod 2.6.1, `timelines_plus ^1.0.0` (new), `google_fonts ^6.2.1`, `material_design_icons_flutter`, `cached_network_image`, `flutter_animate ^4.5.2`

---

## File Map

| File | Action | Responsibility |
|------|--------|----------------|
| `pubspec.yaml` | Modify | Add `timelines_plus: ^1.0.0` dependency |
| `lib/components/page_dots.dart` | Create | Shared `PageDots` widget extracted from home screen |
| `lib/components/roadmap_step_tile.dart` | Rewrite internals | Timeline-based step tile (public API unchanged) |
| `lib/screens/home/home_screen.dart` | Modify | Import `page_dots.dart`, replace inline `_PageDots`, wrap steps with `FixedTimeline` |
| `lib/screens/you/you_screen.dart` | Rewrite | Full P6 Collector Card redesign with PageView, chip row, icon-square nav rows |

---

## Chunk 1: Package + Shared PageDots

### Task 1: Add `timelines_plus` to pubspec

**Files:**
- Modify: `pubspec.yaml` (project root)

- [ ] **Step 1: Add the dependency**

In `pubspec.yaml`, add under the `# Animations` section (after `flutter_animate`):

```yaml
  # Timeline UI
  timelines_plus: ^1.0.0
```

- [ ] **Step 2: Fetch the package**

```bash
cd d:/programming/projetos/trysomething && flutter pub get
```

Expected: resolves `timelines_plus` without conflicts. If version conflict, try `^1.0.0` → `any` or check `flutter pub outdated`.

- [ ] **Step 3: Verify analyze clean**

```bash
dart analyze lib/components/roadmap_step_tile.dart
```

Expected: no issues (file unchanged yet — confirms baseline is clean).

---

### Task 2: Extract `PageDots` to shared component

**Files:**
- Create: `lib/components/page_dots.dart`
- Modify: `lib/screens/home/home_screen.dart`

The inline `_PageDots` class currently lives at `home_screen.dart:122-158`. Extract it verbatim as a public `PageDots` widget.

- [ ] **Step 1: Create `lib/components/page_dots.dart`**

```dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Shared page indicator dots — animated pill style.
/// Active dot expands to 20px wide; inactive dots are 6px circles.
class PageDots extends StatelessWidget {
  final int count;
  final int current;

  const PageDots({super.key, required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.background.withAlpha(160),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(count, (i) {
            final isActive = i == current;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.accent
                    : AppColors.textPrimary.withAlpha(80),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Update `home_screen.dart` — import + swap**

At the top of `home_screen.dart`, add the import (after existing component imports):

```dart
import '../../components/page_dots.dart';
```

Find `_PageDots` class at lines 122-158 and **delete the entire `_PageDots` class**.

In `_HomeScreenState.build()` around line 106-110, replace:
```dart
child: _PageDots(
  count: activeEntries.length,
  current: _currentPage,
),
```
with:
```dart
child: PageDots(
  count: activeEntries.length,
  current: _currentPage,
),
```

- [ ] **Step 3: Verify**

```bash
dart analyze lib/screens/home/home_screen.dart lib/components/page_dots.dart
```

Expected: no issues.

- [ ] **Step 4: Commit**

```bash
git add lib/components/page_dots.dart lib/screens/home/home_screen.dart pubspec.yaml pubspec.lock
git commit -m "feat: add timelines_plus package and extract PageDots to shared component"
```

---

## Chunk 2: RoadmapStepTile Rewrite

### Task 3: Rewrite `RoadmapStepTile` internals with `timelines_plus`

**Files:**
- Modify: `lib/components/roadmap_step_tile.dart`

**Key facts:**
- Public constructor signature is **unchanged** — all 5 params stay identical.
- The `AnimationController` spring/elastic check animation is preserved.
- `timelines_plus` exports: `FixedTimeline`, `TimelineTile`, `TimelineNode`, `DotIndicator`, `SolidLineConnector`.
- Each `RoadmapStepTile` renders its own `TimelineTile`. Both `startConnector` and `endConnector` are always shown — first/last edge connectors will use `AppColors.border` color which is visually indistinguishable from the background at the edges.
- Colors: done spine = `AppColors.success.withValues(alpha: 0.25)`, done→current = `AppColors.accent.withValues(alpha: 0.25)`, future = `AppColors.border`.
- Note: `AppColors.coral` == `AppColors.accent` (legacy alias).

- [ ] **Step 1: Full rewrite of `roadmap_step_tile.dart`**

Replace the entire file contents with:

```dart
import 'package:flutter/material.dart';
import 'package:timelines_plus/timelines_plus.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/spacing.dart';
import '../theme/motion.dart';
import '../models/hobby.dart';
import 'package:google_fonts/google_fonts.dart';

/// Timeline-journey step tile.
/// Public constructor API is identical to the previous flat-card version.
class RoadmapStepTile extends StatefulWidget {
  final RoadmapStep step;
  final int stepNumber;
  final bool isCompleted;
  final bool isCurrent;
  final VoidCallback? onToggle;

  const RoadmapStepTile({
    super.key,
    required this.step,
    required this.stepNumber,
    this.isCompleted = false,
    this.isCurrent = false,
    this.onToggle,
  });

  @override
  State<RoadmapStepTile> createState() => _RoadmapStepTileState();
}

class _RoadmapStepTileState extends State<RoadmapStepTile>
    with TickerProviderStateMixin {
  // ── Animation controllers (preserved from original) ──
  late AnimationController _checkController;
  late AnimationController _uncheckController;
  late Animation<double> _fillAnimation;
  late Animation<double> _checkmarkScaleAnimation;
  late Animation<double> _checkmarkOpacityAnimation;
  late Animation<double> _uncheckFillAnimation;
  late Animation<double> _uncheckScaleAnimation;
  late Animation<double> _uncheckOpacityAnimation;

  bool _isReversing = false;

  @override
  void initState() {
    super.initState();
    _checkController = AnimationController(
      duration: Motion.spring,
      vsync: this,
    );

    _fillAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _checkController,
        curve: const Interval(0, 0.5, curve: Curves.easeInOut),
      ),
    );
    _checkmarkScaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _checkController,
        curve: const Interval(0, 0.6, curve: Curves.elasticOut),
      ),
    );
    _checkmarkOpacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _checkController,
        curve: const Interval(0, 0.3, curve: Curves.easeIn),
      ),
    );

    _uncheckController = AnimationController(
      duration: Motion.normal,
      vsync: this,
    );
    _uncheckFillAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _uncheckController, curve: Curves.easeInOut),
    );
    _uncheckScaleAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _uncheckController, curve: Curves.easeInOut),
    );
    _uncheckOpacityAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _uncheckController, curve: Curves.easeInOut),
    );

    if (widget.isCompleted) {
      _checkController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(RoadmapStepTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCompleted && !oldWidget.isCompleted) {
      _isReversing = false;
      _uncheckController.reset();
      _checkController.forward();
    } else if (!widget.isCompleted && oldWidget.isCompleted) {
      _isReversing = true;
      _checkController.value = 1.0;
      _uncheckController.forward().then((_) {
        if (mounted) {
          _checkController.reset();
          _isReversing = false;
        }
      });
    }
  }

  @override
  void dispose() {
    _checkController.dispose();
    _uncheckController.dispose();
    super.dispose();
  }

  double get _activeFill =>
      _isReversing ? _uncheckFillAnimation.value : _fillAnimation.value;
  double get _activeScale =>
      _isReversing ? _uncheckScaleAnimation.value : _checkmarkScaleAnimation.value;
  double get _activeOpacity =>
      _isReversing ? _uncheckOpacityAnimation.value : _checkmarkOpacityAnimation.value;

  // ── Connector colors ──

  // startConnector = the segment ENTERING this node (from the tile above)
  // endConnector = the segment LEAVING this node (to the tile below)
  //
  // Known approximation: because a single tile doesn't know its neighbor's
  // state, endConnector for a completed step always uses accent (done→current)
  // rather than success (done→done). In practice this means consecutive done
  // steps show coral connectors between them instead of teal. Visually
  // acceptable since consecutive done steps are 45% opacity and the connector
  // color difference is subtle.
  Color get _startConnectorColor {
    if (widget.isCompleted) return AppColors.success.withValues(alpha: 0.25);  // done→done
    if (widget.isCurrent) return AppColors.accent.withValues(alpha: 0.25);    // done→current
    return AppColors.border;                                                    // future
  }

  Color get _endConnectorColor {
    if (widget.isCompleted) return AppColors.accent.withValues(alpha: 0.25);  // done→current (approximated)
    if (widget.isCurrent) return AppColors.border;                             // current→future
    return AppColors.border;                                                    // future→future
  }

  @override
  Widget build(BuildContext context) {
    return TimelineTile(
      nodeAlign: TimelineNodeAlign.start,
      node: TimelineNode(
        indicator: GestureDetector(
          onTap: widget.onToggle,
          child: AnimatedBuilder(
            animation: Listenable.merge([_checkController, _uncheckController]),
            builder: (context, _) => _buildNode(),
          ),
        ),
        startConnector: SolidLineConnector(
          color: _startConnectorColor,
          thickness: 1.5,
        ),
        endConnector: SolidLineConnector(
          color: _endConnectorColor,
          thickness: 1.5,
        ),
      ),
      contents: GestureDetector(
        onTap: widget.onToggle,
        child: Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 12, top: 2),
          child: _buildCard(),
        ),
      ),
    );
  }

  Widget _buildNode() {
    if (widget.isCompleted) {
      // Done: teal ring with check icon
      return Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.success.withValues(alpha: 0.15),
          border: Border.all(color: AppColors.success, width: 1.5),
        ),
        child: Opacity(
          opacity: _activeOpacity,
          child: Transform.scale(
            scale: _activeScale,
            child: const Icon(Icons.check, size: 13, color: AppColors.success),
          ),
        ),
      );
    }

    if (widget.isCurrent) {
      // Current: coral filled circle with glow
      return Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color.lerp(
            AppColors.accent,
            AppColors.accent,
            _activeFill,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.25),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Center(
          child: Opacity(
            opacity: 1 - _activeOpacity,
            child: Text(
              '${widget.stepNumber}',
              style: GoogleFonts.ibmPlexMono(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
    }

    // Future: transparent with border
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.transparent,
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Center(
        child: Text(
          '${widget.stepNumber}',
          style: GoogleFonts.ibmPlexMono(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.textWhisper,
          ),
        ),
      ),
    );
  }

  Widget _buildCard() {
    if (widget.isCompleted) {
      return Opacity(
        opacity: 0.45,
        child: Text(
          widget.step.title,
          style: AppTypography.sansLabel.copyWith(
            decoration: TextDecoration.lineThrough,
            color: AppColors.textWhisper,
          ),
        ),
      );
    }

    if (widget.isCurrent) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.06),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.step.title,
                    style: AppTypography.sansLabel.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                // Time badge
                Text(
                  '${widget.step.estimatedMinutes}min',
                  style: GoogleFonts.ibmPlexMono(
                    fontSize: 9,
                    color: AppColors.accent.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              widget.step.description,
              style: AppTypography.sansTiny.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            // Milestone badge
            if (widget.step.milestone != null) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.accentMuted,
                  borderRadius: BorderRadius.circular(Spacing.radiusBadge),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.emoji_events_outlined,
                        size: 12, color: AppColors.accent),
                    const SizedBox(width: 4),
                    Text(
                      widget.step.milestone!,
                      style: AppTypography.monoMilestone.copyWith(
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    }

    // Future: title only, no description, no background
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        widget.step.title,
        style: AppTypography.sansLabel.copyWith(
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Analyze**

```bash
dart analyze lib/components/roadmap_step_tile.dart
```

Expected: no issues. If `withValues` is unavailable (Flutter < 3.7), use `.withOpacity()` instead: `AppColors.success.withOpacity(0.25)`.

- [ ] **Step 3: Commit**

```bash
git add lib/components/roadmap_step_tile.dart
git commit -m "feat: rewrite RoadmapStepTile internals with timelines_plus timeline layout"
```

---

### Task 4: Update `home_screen.dart` — wrap steps with `FixedTimeline`

**Files:**
- Modify: `lib/screens/home/home_screen.dart`

The step list at `home_screen.dart:384-422` currently uses `...List.generate(...)` spread directly into the parent `Column`. Wrap it in `FixedTimeline`.

- [ ] **Step 1: Add import for `timelines_plus`**

At the top of `home_screen.dart`, add after the existing component imports:

```dart
import 'package:timelines_plus/timelines_plus.dart';
```

- [ ] **Step 2: Wrap the step list**

Find the step list section (around line 380-424). Change from:

```dart
              Text('YOUR STEPS',
                  style: AppTypography.overline
                      .copyWith(color: AppColors.textMuted)),
              const SizedBox(height: 10),
              ...List.generate(hobby.roadmapSteps.length, (i) {
                // ...
                return RoadmapStepTile(
                  // ...
                );
              }),
```

To:

```dart
              Text('YOUR STEPS',
                  style: AppTypography.overline
                      .copyWith(color: AppColors.textMuted)),
              const SizedBox(height: 10),
              FixedTimeline(
                theme: TimelineThemeData(
                  nodePosition: 0,
                  color: AppColors.border,
                  connectorTheme: const ConnectorThemeData(
                    thickness: 1.5,
                    color: AppColors.border,
                  ),
                  indicatorTheme: const IndicatorThemeData(
                    size: 26,
                  ),
                ),
                children: List.generate(hobby.roadmapSteps.length, (i) {
                  final step = hobby.roadmapSteps[i];
                  final isCompleted = completedValid.contains(step.id);
                  final isCurrent = step.id == nextStep?.id;
                  final followingTitle = i + 1 < hobby.roadmapSteps.length
                      ? hobby.roadmapSteps[i + 1].title
                      : null;
                  return RoadmapStepTile(
                    step: step,
                    stepNumber: i + 1,
                    isCompleted: isCompleted,
                    isCurrent: isCurrent,
                    onToggle: () {
                      if (isCompleted) {
                        ref
                            .read(userHobbiesProvider.notifier)
                            .toggleStep(hobby.id, step.id);
                      } else {
                        context.push(
                          '/session/${hobby.id}/${step.id}',
                          extra: <String, dynamic>{
                            'hobbyTitle': hobby.title,
                            'hobbyCategory': hobby.category,
                            'stepTitle': step.title,
                            'stepDescription': step.description,
                            'stepInstructions': '',
                            'whatYouNeed': '',
                            'recommendedMinutes': step.estimatedMinutes,
                            'completionMode': step.effectiveMode,
                            'nextStepTitle': followingTitle,
                          },
                        );
                      }
                    },
                  );
                }),
              ),
```

- [ ] **Step 3: Analyze**

```bash
dart analyze lib/screens/home/home_screen.dart
```

Expected: no issues.

- [ ] **Step 4: Commit**

```bash
git add lib/screens/home/home_screen.dart
git commit -m "feat: wrap roadmap steps in FixedTimeline on home screen"
```

---

## Chunk 3: You Screen Redesign

### Task 5: Rewrite `you_screen.dart` — P6 Collector Card layout

**Files:**
- Modify: `lib/screens/you/you_screen.dart`

**Key decisions:**
- `YouScreen` converts from `ConsumerWidget` to `ConsumerStatefulWidget` to hold `PageController`.
- `streakDays` is already a field on `UserHobby` (confirmed in `lib/models/hobby.dart:146`). The spec calls for a `_computeStreak(UserHobby uh) → int` helper — implement it as a top-level function that returns `uh.streakDays`. This satisfies the spec's named-helper requirement while using the authoritative model value.
- Header streak dot displays the streak for the **currently visible hobby page** (same index as `_currentHobbyPage`), not always the first hobby.
- Sessions chip shows `userHobby.completedStepIds.length` as a proxy for sessions.
- `_SavedHobbyCard`, `_TriedHobbyCard`, `_EmptyActivePrompt`, `_SectionLabel`, `_HobbyWithMeta` helper class are all preserved unchanged.
- The `_Avatar` widget is replaced by the new 48px rounded-square avatar.
- `_ActiveHobbyCard` is replaced by the new `_CollectorCard` + chip row.
- GlassCard nav rows are replaced by icon-square + hairline divider style.
- `_PageDots` from `home_screen.dart` is now `PageDots` from `page_dots.dart`.

- [ ] **Step 1: Full rewrite of `you_screen.dart`**

Replace the entire file with:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../components/page_dots.dart';
import '../../models/hobby.dart';
import '../../providers/hobby_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/feature_providers.dart';
import '../../providers/auth_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/spacing.dart';

/// You tab — Collector Card redesign (P6).
/// Active hobby shown as cinematic full-width card, swipeable for multi-hobby.
class YouScreen extends ConsumerStatefulWidget {
  const YouScreen({super.key});

  @override
  ConsumerState<YouScreen> createState() => _YouScreenState();
}

class _YouScreenState extends ConsumerState<YouScreen> {
  late PageController _hobbyPageController;
  int _currentHobbyPage = 0;

  @override
  void initState() {
    super.initState();
    _hobbyPageController = PageController();
  }

  @override
  void dispose() {
    _hobbyPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userHobbies = ref.watch(userHobbiesProvider);
    final allHobbiesAsync = ref.watch(hobbyListProvider);
    final authUser = ref.watch(authProvider).user;
    final profile = ref.watch(profileProvider);
    final proStatus = ref.watch(proStatusProvider);

    final displayName = authUser?.displayName ?? profile.username;
    final avatarUrl = authUser?.avatarUrl ?? profile.avatarUrl;

    final allHobbies = allHobbiesAsync.valueOrNull ?? [];

    final activeEntries = <_HobbyWithMeta>[];
    final savedEntries = <_HobbyWithMeta>[];
    final triedEntries = <_HobbyWithMeta>[];

    for (final entry in userHobbies.entries) {
      final uh = entry.value;
      final hobby = allHobbies.where((h) => h.id == uh.hobbyId).firstOrNull;
      if (hobby == null) continue;

      final meta = _HobbyWithMeta(hobby: hobby, userHobby: uh);
      switch (uh.status) {
        case HobbyStatus.trying:
        case HobbyStatus.active:
          activeEntries.add(meta);
        case HobbyStatus.saved:
          savedEntries.add(meta);
        case HobbyStatus.done:
          triedEntries.add(meta);
      }
    }

    // Clamp current page if hobbies removed
    if (_currentHobbyPage >= activeEntries.length && activeEntries.isNotEmpty) {
      _currentHobbyPage = activeEntries.length - 1;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
              24, 16, 24, Spacing.scrollBottomPadding),
          children: [
            // ── Header: rounded-square avatar + name + streak ──
            _ProfileHeader(
              displayName: displayName,
              avatarUrl: avatarUrl,
              streakDays: activeEntries.isNotEmpty
                  ? _computeStreak(activeEntries[
                      _currentHobbyPage.clamp(0, activeEntries.length - 1)]
                      .userHobby)
                  : 0,
            ),
            const SizedBox(height: 24),

            // ── ACTIVE section ──
            _SectionLabel('ACTIVE'),
            const SizedBox(height: 12),

            if (activeEntries.isEmpty)
              _EmptyActivePrompt()
            else ...[
              // Collector card — static if 1 hobby, PageView if 2+
              if (activeEntries.length == 1)
                _CollectorCard(meta: activeEntries.first)
              else ...[
                SizedBox(
                  height: 130,
                  child: PageView.builder(
                    controller: _hobbyPageController,
                    itemCount: activeEntries.length,
                    onPageChanged: (i) =>
                        setState(() => _currentHobbyPage = i),
                    itemBuilder: (context, i) =>
                        _CollectorCard(meta: activeEntries[i]),
                  ),
                ),
                const SizedBox(height: 8),
                PageDots(
                  count: activeEntries.length,
                  current: _currentHobbyPage,
                ),
              ],
              const SizedBox(height: 12),

              // Chip row — stats for currently visible hobby
              _StatsChipRow(
                meta: activeEntries.length > _currentHobbyPage
                    ? activeEntries[_currentHobbyPage]
                    : activeEntries.first,
              ),
            ],

            const SizedBox(height: 24),

            // ── SAVED FOR LATER section ──
            if (savedEntries.isNotEmpty) ...[
              _SectionLabel('SAVED FOR LATER'),
              const SizedBox(height: 12),
              ...savedEntries.map((m) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _SavedHobbyCard(meta: m),
                  )),
              const SizedBox(height: 20),
            ],

            // ── TRIED BEFORE section ──
            if (triedEntries.isNotEmpty) ...[
              _SectionLabel('TRIED BEFORE'),
              const SizedBox(height: 12),
              ...triedEntries.map((m) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _TriedHobbyCard(meta: m),
                  )),
              const SizedBox(height: 20),
            ],

            // ── Nav rows: Journal / Pro / Settings ──
            _NavRow(
              icon: MdiIcons.bookOpenPageVariantOutline,
              iconBg: AppColors.surface,
              iconBorder: AppColors.border,
              iconColor: AppColors.textSecondary,
              title: 'Journal',
              titleStyle: AppTypography.sansLabel.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              chevronColor: AppColors.textMuted,
              onTap: () => context.push('/journal'),
            ),
            const _HairlineDivider(),

            _ProNavRow(proStatus: proStatus),
            const _HairlineDivider(),

            _NavRow(
              icon: MdiIcons.cogOutline,
              iconBg: Colors.transparent,
              iconBorder: Colors.transparent,
              iconColor: AppColors.textMuted.withValues(alpha: 0.4),
              title: 'Settings',
              titleStyle: AppTypography.body.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
              ),
              chevronColor: AppColors.textWhisper,
              onTap: () => context.push('/settings'),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  STREAK HELPER
// ═══════════════════════════════════════════════════════

/// Returns the streak day count for a given UserHobby.
/// Uses the authoritative `streakDays` field already maintained by the model.
/// Returns 0 when lastActivityAt is null or >1 day ago (handled by the model).
int _computeStreak(UserHobby uh) => uh.streakDays;

// ═══════════════════════════════════════════════════════
//  DATA HELPER (unchanged)
// ═══════════════════════════════════════════════════════

class _HobbyWithMeta {
  final Hobby hobby;
  final UserHobby userHobby;
  const _HobbyWithMeta({required this.hobby, required this.userHobby});
}

// ═══════════════════════════════════════════════════════
//  PROFILE HEADER — 48px rounded-square avatar
// ═══════════════════════════════════════════════════════

class _ProfileHeader extends StatelessWidget {
  final String displayName;
  final String? avatarUrl;
  final int streakDays;

  const _ProfileHeader({
    required this.displayName,
    required this.avatarUrl,
    required this.streakDays,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Rounded-square avatar
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            gradient: const LinearGradient(
              colors: [Color(0xFF1A1520), Color(0xFF151A25)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.07),
              width: 1,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: avatarUrl != null && avatarUrl!.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: avatarUrl!,
                  fit: BoxFit.cover,
                  memCacheWidth: 96,
                  placeholder: (_, __) => const SizedBox.shrink(),
                  errorWidget: (_, __, ___) => const SizedBox.shrink(),
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              displayName,
              style: GoogleFonts.sourceSerif4(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            if (streakDays > 0) ...[
              const SizedBox(height: 3),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '$streakDays DAY STREAK',
                    style: GoogleFonts.ibmPlexMono(
                      fontSize: 9,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════
//  COLLECTOR CARD (~130px tall, full-width cinematic)
// ═══════════════════════════════════════════════════════

class _CollectorCard extends StatelessWidget {
  final _HobbyWithMeta meta;
  const _CollectorCard({required this.meta});

  @override
  Widget build(BuildContext context) {
    final hobby = meta.hobby;
    final uh = meta.userHobby;

    final validStepIds = hobby.roadmapSteps.map((s) => s.id).toSet();
    final completedValid = uh.completedStepIds.intersection(validStepIds);
    final totalSteps = hobby.roadmapSteps.length;
    final progress =
        totalSteps > 0 ? completedValid.length / totalSteps : 0.0;

    final startedAt = uh.startedAt ?? DateTime.now();
    final weekNum =
        (DateTime.now().difference(startedAt).inDays / 7).floor() + 1;

    return GestureDetector(
      onTap: () => context.go('/home'),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 130,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background image
              Transform.scale(
                scale: 1.05,
                child: CachedNetworkImage(
                  imageUrl: hobby.imageUrl,
                  fit: BoxFit.cover,
                  memCacheWidth: 800,
                  placeholder: (_, __) =>
                      Container(color: AppColors.surfaceElevated),
                  errorWidget: (_, __, ___) =>
                      Container(color: AppColors.surfaceElevated),
                ),
              ),
              // Gradient overlay: transparent top → near-black bottom
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x1A0A0A0F), // rgba(10,10,15,0.1)
                      Color(0xF80A0A0F), // rgba(10,10,15,0.97)
                    ],
                  ),
                ),
              ),
              // Content overlay
              Positioned(
                left: 14,
                right: 14,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Week label
                    Text(
                      'WEEK ${weekNum.toString().padLeft(2, '0')} / 04',
                      style: GoogleFonts.ibmPlexMono(
                        fontSize: 8.5,
                        color: AppColors.textPrimary.withValues(alpha: 0.35),
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Hobby name + progress % (side by side)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            hobby.title,
                            style: GoogleFonts.sourceSerif4(
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${(progress * 100).round()}',
                                    style: GoogleFonts.ibmPlexMono(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.accent,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '%',
                                    style: GoogleFonts.ibmPlexMono(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.accent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              'COMPLETE',
                              style: GoogleFonts.ibmPlexMono(
                                fontSize: 8,
                                color: AppColors.textPrimary
                                    .withValues(alpha: 0.3),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(1),
                      child: LinearProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        minHeight: 2,
                        backgroundColor:
                            Colors.white.withValues(alpha: 0.08),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.accent),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  STATS CHIP ROW
// ═══════════════════════════════════════════════════════

class _StatsChipRow extends StatelessWidget {
  final _HobbyWithMeta meta;
  const _StatsChipRow({required this.meta});

  @override
  Widget build(BuildContext context) {
    final hobby = meta.hobby;
    final uh = meta.userHobby;

    final validStepIds = hobby.roadmapSteps.map((s) => s.id).toSet();
    final completedValid = uh.completedStepIds.intersection(validStepIds);
    final totalSteps = hobby.roadmapSteps.length;
    final sessionsProxy = uh.completedStepIds.length;
    final streakDays = _computeStreak(uh);

    return Wrap(
      spacing: 8,
      children: [
        _Chip(
          label: '${completedValid.length}/$totalSteps steps',
          bg: AppColors.surface,
          border: AppColors.border,
          textColor: AppColors.textMuted,
        ),
        _Chip(
          label: '$sessionsProxy sessions',
          bg: AppColors.surface,
          border: AppColors.border,
          textColor: AppColors.textMuted,
        ),
        if (streakDays > 0)
          _Chip(
            label: '🔥 $streakDays days',
            bg: AppColors.accentMuted,
            border: AppColors.accent.withValues(alpha: 0.2),
            textColor: AppColors.accent,
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color bg;
  final Color border;
  final Color textColor;
  const _Chip({
    required this.label,
    required this.bg,
    required this.border,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.ibmPlexMono(
          fontSize: 8.5,
          color: textColor,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  NAV ROWS — icon-square + hairline divider style
// ═══════════════════════════════════════════════════════

class _NavRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconBorder;
  final Color iconColor;
  final String title;
  final TextStyle titleStyle;
  final Color chevronColor;
  final VoidCallback onTap;

  const _NavRow({
    required this.icon,
    required this.iconBg,
    required this.iconBorder,
    required this.iconColor,
    required this.title,
    required this.titleStyle,
    required this.chevronColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            // Icon square
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: iconBg,
                border: iconBorder != Colors.transparent
                    ? Border.all(color: iconBorder)
                    : null,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, size: 15, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: titleStyle)),
            Icon(MdiIcons.chevronRight, size: 18, color: chevronColor),
          ],
        ),
      ),
    );
  }
}

class _ProNavRow extends StatelessWidget {
  final ProStatus proStatus;
  const _ProNavRow({required this.proStatus});

  String _label(ProStatus s) {
    if (s.isPro && s.isTrialing) return 'Trial (${s.trialDaysRemaining} days left)';
    if (s.isPro) return 'Pro';
    return 'Free Plan';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/pro'),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.03),
          border: Border.all(
            color: AppColors.accent.withValues(alpha: 0.1),
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.accentMuted,
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.18),
                ),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(MdiIcons.starFourPointsOutline,
                  size: 15, color: AppColors.accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TrySomething Pro',
                    style: AppTypography.sansLabel.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _label(proStatus),
                    style: GoogleFonts.ibmPlexMono(
                      fontSize: 9,
                      color: AppColors.accent.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
            Icon(MdiIcons.chevronRight,
                size: 18,
                color: AppColors.accent.withValues(alpha: 0.4)),
          ],
        ),
      ),
    );
  }
}

class _HairlineDivider extends StatelessWidget {
  const _HairlineDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: const Color(0xFF0E0E13),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  SECTION LABEL (unchanged)
// ═══════════════════════════════════════════════════════

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTypography.overline.copyWith(color: AppColors.textMuted),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  EMPTY ACTIVE PROMPT (unchanged)
// ═══════════════════════════════════════════════════════

class _EmptyActivePrompt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            'Start your first hobby',
            style: AppTypography.title.copyWith(fontSize: 17),
          ),
          const SizedBox(height: 6),
          Text(
            'Find something that fits your life and try it for a week.',
            textAlign: TextAlign.center,
            style:
                AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => context.go('/discover'),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text('Discover hobbies',
                    style: AppTypography.button
                        .copyWith(color: AppColors.background)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  SAVED HOBBY CARD (styling unchanged)
// ═══════════════════════════════════════════════════════

class _SavedHobbyCard extends StatelessWidget {
  final _HobbyWithMeta meta;
  const _SavedHobbyCard({required this.meta});

  @override
  Widget build(BuildContext context) {
    final hobby = meta.hobby;
    return GestureDetector(
      onTap: () => context.push('/hobby/${hobby.id}'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(hobby.title,
                style: AppTypography.title.copyWith(fontSize: 16)),
            const SizedBox(height: 4),
            Text(
              '${hobby.costText} · ${hobby.timeText} · ${hobby.difficultyText}',
              style: AppTypography.data
                  .copyWith(color: AppColors.textMuted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  TRIED HOBBY CARD (styling unchanged)
// ═══════════════════════════════════════════════════════

class _TriedHobbyCard extends StatelessWidget {
  final _HobbyWithMeta meta;
  const _TriedHobbyCard({required this.meta});

  @override
  Widget build(BuildContext context) {
    final hobby = meta.hobby;
    final uh = meta.userHobby;

    String triedLabel = '';
    if (uh.startedAt != null && uh.lastActivityAt != null) {
      final days = uh.lastActivityAt!.difference(uh.startedAt!).inDays;
      final weeks = (days / 7).ceil();
      triedLabel = weeks <= 1 ? '1 week' : '$weeks weeks';
      final month = _monthName(uh.lastActivityAt!.month);
      final year = uh.lastActivityAt!.year;
      triedLabel = '$triedLabel in $month $year';
    }

    return GestureDetector(
      onTap: () => context.push('/hobby/${hobby.id}'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface.withAlpha(10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(hobby.title,
                style: AppTypography.body
                    .copyWith(color: AppColors.textSecondary)),
            if (triedLabel.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(triedLabel,
                  style: AppTypography.caption
                      .copyWith(color: AppColors.textMuted)),
            ],
          ],
        ),
      ),
    );
  }

  String _monthName(int month) {
    const names = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return names[month - 1];
  }
}
```

- [ ] **Step 2: Analyze**

```bash
dart analyze lib/screens/you/you_screen.dart
```

Expected: no issues. Common issues to fix:
- If `ProStatus` doesn't have `isTrialing` or `trialDaysRemaining` properties, check `lib/providers/subscription_provider.dart` for the actual field names and update `_ProNavRow._label()` accordingly.
- If `AppTypography.sansLabel` doesn't exist, substitute `AppTypography.title` (check `lib/theme/app_typography.dart`).
- If `hobby.costText`, `hobby.timeText`, `hobby.difficultyText` don't exist, check `lib/models/hobby.dart` for the correct getter names.

- [ ] **Step 3: Fix any analyze errors from Step 2**

After fixing, re-run:
```bash
dart analyze lib/screens/you/you_screen.dart
```

- [ ] **Step 4: Full project analyze**

```bash
dart analyze lib/
```

Expected: no new issues introduced.

- [ ] **Step 5: Commit**

```bash
git add lib/screens/you/you_screen.dart
git commit -m "feat: redesign You screen with P6 Collector Card layout and swipeable hobby cards"
```

---

## Final Verification

- [ ] **Run full analyze**

```bash
dart analyze lib/
```

Expected: 0 errors, 0 warnings.

- [ ] **Verify `RoadmapStepTile` call sites still compile**

The constructor API (`step`, `stepNumber`, `isCompleted`, `isCurrent`, `onToggle`) must be unchanged. Confirm:
```bash
dart analyze lib/screens/home/home_screen.dart
```

- [ ] **Check for any other `RoadmapStepTile` call sites**

```bash
grep -r "RoadmapStepTile" lib/ --include="*.dart" -l
```

If additional call sites exist beyond `home_screen.dart`, wrap their step list with `FixedTimeline` following the same pattern as Task 4.

- [ ] **Final commit (if any cleanup needed)**

```bash
git add -p
git commit -m "fix: address any final analyze issues from premium UI redesign"
```
