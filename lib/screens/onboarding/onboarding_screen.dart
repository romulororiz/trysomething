import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../models/hobby.dart';
import '../../models/seed_data.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_icons.dart';
import '../../theme/app_typography.dart';
import '../../theme/motion.dart';
import '../../theme/spacing.dart';

// ═══════════════════════════════════════════════════════
//  INTERVAL HELPER
// ═══════════════════════════════════════════════════════

/// Maps a controller value [v] through an interval [begin..end] with optional curve.
double _iv(double v, double begin, double end,
    [Curve curve = Curves.easeOut]) {
  if (v <= begin) return 0.0;
  if (v >= end) return 1.0;
  return curve.transform((v - begin) / (end - begin));
}

// ═══════════════════════════════════════════════════════
//  ONBOARDING SCREEN
// ═══════════════════════════════════════════════════════

/// 3-page onboarding: Welcome → Preferences → Results
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  final _pageController = PageController();
  int _currentPage = 0;

  // Preferences state
  int _hours = 3;
  int _budget = 1; // 0=low, 1=medium, 2=high
  bool _social = false;
  final Set<String> _vibes = {};
  List<Hobby> _matchedHobbies = [];

  // ── Animation Controllers ──
  late AnimationController _page1EntryCtrl;
  late List<AnimationController> _gradientCtrls;
  late List<AnimationController> _floatCtrls;
  late List<AnimationController> _iconEntryCtrls;
  late AnimationController _page2EntryCtrl;
  late AnimationController _page3EntryCtrl;
  late AnimationController _particleCtrl;
  late AnimationController _glowCtrl;

  // ── Derived Animations ──
  late List<Animation<double>> _floatYAnims;
  late List<Animation<double>> _floatXAnims;
  late List<Animation<double>> _iconFadeAnims;
  late List<Animation<double>> _iconScaleAnims;
  late List<Animation<Offset>> _blobAnims;

  // ── Particles ──
  late List<_Particle> _particles;

  @override
  void initState() {
    super.initState();

    // Page entry controllers
    _page1EntryCtrl = AnimationController(
        duration: const Duration(milliseconds: 1200), vsync: this);
    _page2EntryCtrl = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this);
    _page3EntryCtrl = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);

    // CTA glow
    _glowCtrl = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this)
      ..repeat(reverse: true);

    // Particle controller (page 3)
    _particleCtrl = AnimationController(
        duration: const Duration(milliseconds: 4000), vsync: this);

    // ── Gradient blob controllers (3 blobs, slow drift) ──
    _gradientCtrls = [
      AnimationController(
          duration: const Duration(milliseconds: 22000), vsync: this)
        ..repeat(reverse: true),
      AnimationController(
          duration: const Duration(milliseconds: 28000), vsync: this)
        ..repeat(reverse: true),
      AnimationController(
          duration: const Duration(milliseconds: 25000), vsync: this)
        ..repeat(reverse: true),
    ];
    _blobAnims = [
      Tween<Offset>(
              begin: const Offset(0.2, 0.25), end: const Offset(0.4, 0.12))
          .animate(CurvedAnimation(
              parent: _gradientCtrls[0], curve: Curves.easeInOut)),
      Tween<Offset>(
              begin: const Offset(0.85, 0.15), end: const Offset(0.6, 0.4))
          .animate(CurvedAnimation(
              parent: _gradientCtrls[1], curve: Curves.easeInOut)),
      Tween<Offset>(
              begin: const Offset(0.25, 0.8), end: const Offset(0.55, 0.62))
          .animate(CurvedAnimation(
              parent: _gradientCtrls[2], curve: Curves.easeInOut)),
    ];

    // ── Floating icon controllers (5 icons) ──
    const floatDurations = [5200, 6800, 4800, 7000, 5500];
    _floatCtrls = List.generate(
        5,
        (i) => AnimationController(
            duration: Duration(milliseconds: floatDurations[i]), vsync: this));

    const yRanges = [8.0, -7.0, 6.0, -9.0, 7.0];
    _floatYAnims = List.generate(
        5,
        (i) => Tween<double>(begin: 0, end: yRanges[i]).animate(
            CurvedAnimation(
                parent: _floatCtrls[i], curve: Curves.easeInOut)));

    const xRanges = [4.0, -5.0, 3.0, -3.0, 4.0];
    _floatXAnims = List.generate(
        5,
        (i) => Tween<double>(begin: 0, end: xRanges[i]).animate(
            CurvedAnimation(
                parent: _floatCtrls[i], curve: Curves.easeInOut)));

    // ── Icon entry (stagger 200ms apart) ──
    _iconEntryCtrls = List.generate(
        5,
        (i) => AnimationController(
            duration: const Duration(milliseconds: 300), vsync: this));
    _iconFadeAnims = List.generate(
        5,
        (i) => CurvedAnimation(
            parent: _iconEntryCtrls[i], curve: Curves.easeOut));
    _iconScaleAnims = List.generate(
        5,
        (i) => Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(
            parent: _iconEntryCtrls[i], curve: Motion.normalCurve)));

    for (int i = 0; i < 5; i++) {
      Future.delayed(Duration(milliseconds: 200 * i), () {
        if (mounted) {
          _iconEntryCtrls[i].forward().then((_) {
            if (mounted) _floatCtrls[i].repeat(reverse: true);
          });
        }
      });
    }

    // ── Particles ──
    final rng = Random(42);
    final pColors = [
      AppColors.coral,
      AppColors.amber,
      AppColors.indigo,
      AppColors.sage,
      AppColors.rose
    ];
    // 3 depth bands: far (small/dim/slow), mid, near (large/bright/fast)
    _particles = List.generate(30, (i) {
      final depth = i < 10 ? 0 : (i < 20 ? 1 : 2); // far, mid, near
      final depthScale = [0.3, 0.6, 1.0][depth];
      final depthAlpha = [0.20, 0.35, 0.50][depth];
      final depthSpeed = [0.15, 0.30, 0.50][depth];
      return _Particle(
        startX: 0.04 + rng.nextDouble() * 0.92,
        startPhase: rng.nextDouble(),
        speed: depthSpeed + rng.nextDouble() * 0.2,
        wobbleAmp: (10 + rng.nextDouble() * 18) * depthScale,
        wobbleFreq: 1.0 + rng.nextDouble() * 2.5,
        wobbleAmp2: (5 + rng.nextDouble() * 10) * depthScale,
        wobbleFreq2: 0.5 + rng.nextDouble() * 1.5,
        size: (4.0 + rng.nextDouble() * 6.0) * depthScale,
        color: pColors[rng.nextInt(pColors.length)],
        maxAlpha: depthAlpha,
        depth: depth,
      );
    });

    // ── Start page 1 entry ──
    _page1EntryCtrl.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _page1EntryCtrl.dispose();
    _page2EntryCtrl.dispose();
    _page3EntryCtrl.dispose();
    _glowCtrl.dispose();
    _particleCtrl.dispose();
    for (final c in _gradientCtrls) {
      c.dispose();
    }
    for (final c in _floatCtrls) {
      c.dispose();
    }
    for (final c in _iconEntryCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  // ── Navigation ──

  void _nextPage() {
    if (_currentPage < 2) {
      final next = _currentPage + 1;
      _pageController.animateToPage(next,
          duration: Motion.onboardingPage, curve: Motion.normalCurve);
      setState(() {
        _currentPage = next;
        if (next == 2) {
          _matchedHobbies = _computeMatchedHobbies();
        }
      });
      if (next == 1) {
        _page2EntryCtrl.forward();
      } else if (next == 2) {
        _page3EntryCtrl.forward();
        _particleCtrl.repeat();
      }
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() {
    final prefsNotifier = ref.read(userPreferencesProvider.notifier);
    prefsNotifier.setHoursPerWeek(_hours);
    prefsNotifier.setBudgetLevel(_budget);
    prefsNotifier.setPreferSocial(_social);
    for (final vibe in _vibes) {
      prefsNotifier.toggleVibe(vibe);
    }
    ref.read(onboardingCompleteProvider.notifier).complete();
    context.go('/feed');
  }

  // ── Matching & Persona ──

  List<Hobby> _computeMatchedHobbies() {
    final all = SeedData.hobbies;
    if (_vibes.isEmpty) return all.toList();

    final scored = all.map((h) {
      int score = h.tags.where((t) => _vibes.contains(t)).length;
      if (_social && h.tags.contains('social')) score += 1;
      if (!_social && h.tags.contains('solo')) score += 1;
      return (hobby: h, score: score);
    }).toList();

    scored.sort((a, b) => b.score.compareTo(a.score));
    final filtered = scored.where((e) => e.score > 0).toList();
    if (filtered.length < 3) return all.toList();
    return filtered.map((e) => e.hobby).toList();
  }

  String _derivePersona() {
    if (_vibes.contains('creative') && _vibes.contains('relaxing')) {
      return 'Mindful\nMaker';
    }
    if (_vibes.contains('physical') && _vibes.contains('outdoors')) {
      return 'Wild\nExplorer';
    }
    if (_vibes.contains('creative')) return 'Creative\nSoul';
    if (_vibes.contains('physical')) return 'Active\nSpirit';
    if (_vibes.contains('technical')) return 'Curious\nBuilder';
    if (_vibes.contains('competitive')) return 'Bold\nChallenger';
    if (_vibes.contains('relaxing')) return 'Zen\nSeeker';
    if (_vibes.contains('outdoors')) return 'Nature\nLover';
    return 'Open\nExplorer';
  }

  String _buildSummary() {
    String identity = 'Explorer';
    if (_vibes.contains('creative')) {
      identity = 'Creative';
    } else if (_vibes.contains('physical')) {
      identity = 'Active';
    } else if (_vibes.contains('technical')) {
      identity = 'Builder';
    } else if (_vibes.contains('relaxing')) {
      identity = 'Mindful';
    } else if (_vibes.contains('outdoors')) {
      identity = 'Adventurer';
    } else if (_vibes.contains('competitive')) {
      identity = 'Competitor';
    }
    final style = _social ? 'social' : 'solo';
    const budgetLabels = ['low', 'mid', 'high'];
    return '$identity $style · ${_hours}h/wk · ${budgetLabels[_budget]} budget';
  }

  // ── Build ──

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Animated gradient background (welcome page only)
          AnimatedOpacity(
            opacity: _currentPage == 0 ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 500),
            child: AnimatedBuilder(
              animation: Listenable.merge(_gradientCtrls),
              builder: (context, _) => CustomPaint(
                painter: _GradientBlobPainter(
                  positions: _blobAnims.map((a) => a.value).toList(),
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                _buildProgressBar(),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    children: [
                      _WelcomePage(
                        entryCtrl: _page1EntryCtrl,
                        floatYAnims: _floatYAnims,
                        floatXAnims: _floatXAnims,
                        iconFadeAnims: _iconFadeAnims,
                        iconScaleAnims: _iconScaleAnims,
                      ),
                      _PreferencesPage(
                        entryCtrl: _page2EntryCtrl,
                        hours: _hours,
                        budget: _budget,
                        social: _social,
                        vibes: _vibes,
                        summary: _vibes.isEmpty ? '' : _buildSummary(),
                        onHoursChanged: (v) => setState(() => _hours = v),
                        onBudgetChanged: (v) => setState(() => _budget = v),
                        onSocialChanged: (v) => setState(() => _social = v),
                        onVibeToggled: (v) => setState(() {
                          _vibes.contains(v)
                              ? _vibes.remove(v)
                              : _vibes.add(v);
                        }),
                      ),
                      _ResultsPage(
                        entryCtrl: _page3EntryCtrl,
                        particleCtrl: _particleCtrl,
                        particles: _particles,
                        matchedHobbies: _matchedHobbies,
                        persona: _derivePersona(),
                      ),
                    ],
                  ),
                ),
                _buildCtaButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 0),
      child: Row(
        children: List.generate(3, (i) {
          final isActive = i <= _currentPage;
          return Expanded(
            child: AnimatedContainer(
              duration: Motion.progressBar,
              curve: Motion.normalCurve,
              height: 4,
              margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
              decoration: BoxDecoration(
                gradient: isActive
                    ? const LinearGradient(
                        colors: [AppColors.coral, AppColors.coralLight])
                    : null,
                color: isActive ? null : AppColors.sandDark,
                borderRadius: BorderRadius.circular(Spacing.radiusBadge),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                            color: AppColors.coral.withAlpha(38), blurRadius: 6)
                      ]
                    : null,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCtaButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 36),
      child: AnimatedBuilder(
        animation: _glowCtrl,
        builder: (context, child) {
          final glow = 12.0 + _glowCtrl.value * 8.0;
          return Container(
            width: double.infinity,
            height: Spacing.buttonPrimaryHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Spacing.radiusButton),
              boxShadow: [
                BoxShadow(
                  color: AppColors.coral.withAlpha(50),
                  blurRadius: glow,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: child,
          );
        },
        child: SizedBox(
          width: double.infinity,
          height: Spacing.buttonPrimaryHeight,
          child: ElevatedButton(
            onPressed: _nextPage,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.coral,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Spacing.radiusButton),
              ),
              elevation: 0,
            ),
            child: Text(
              _currentPage == 0
                  ? "Let's find your thing →"
                  : _currentPage == 1
                      ? 'Almost there →'
                      : "Let's go →",
              style: AppTypography.sansCta,
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  PAGE 1 — WELCOME
// ═══════════════════════════════════════════════════════

class _WelcomePage extends StatelessWidget {
  final AnimationController entryCtrl;
  final List<Animation<double>> floatYAnims;
  final List<Animation<double>> floatXAnims;
  final List<Animation<double>> iconFadeAnims;
  final List<Animation<double>> iconScaleAnims;

  const _WelcomePage({
    required this.entryCtrl,
    required this.floatYAnims,
    required this.floatXAnims,
    required this.iconFadeAnims,
    required this.iconScaleAnims,
  });

  // 5 floating icons: (phosphorIcon, color, containerSize, xPct, yPct, rotDeg)
  static final _ambientIcons = [
    (PhosphorIconsDuotone.palette, AppColors.catCreative, 68.0, 0.08, 0.08, -10.0),
    (PhosphorIconsDuotone.tree, AppColors.catOutdoors, 64.0, 0.80, 0.06, 8.0),
    (PhosphorIconsDuotone.musicNotes, AppColors.catMusic, 60.0, 0.04, 0.52, 12.0),
    (PhosphorIconsDuotone.barbell, AppColors.catFitness, 66.0, 0.84, 0.46, -8.0),
    (PhosphorIconsDuotone.cookingPot, AppColors.catFood, 62.0, 0.12, 0.82, 6.0),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        return Stack(
          children: [
            // Floating glassmorphic icons
            for (int i = 0; i < _ambientIcons.length; i++)
              _buildFloatingIcon(i, w, h),

            // Center content with staggered entry
            Center(
              child: AnimatedBuilder(
                animation: entryCtrl,
                builder: (context, _) {
                  final v = entryCtrl.value;
                  final iconOp = _iv(v, 0.0, 0.25);
                  final iconScale = _iv(v, 0.0, 0.25, Curves.easeOutCubic);
                  final titleOp = _iv(v, 0.15, 0.42);
                  final titleSlide =
                      _iv(v, 0.15, 0.42, Curves.easeOutCubic);
                  final underline =
                      _iv(v, 0.38, 0.62, Curves.easeInOut);
                  final tagOp = _iv(v, 0.48, 0.68);
                  final stat0 = _iv(v, 0.58, 0.78);
                  final stat1 = _iv(v, 0.64, 0.84);
                  final stat2 = _iv(v, 0.70, 0.90);

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 36),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 32),

                        // App icon
                        Opacity(
                          opacity: iconOp,
                          child: Transform.scale(
                            scale: 0.8 + 0.2 * iconScale,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.coral,
                                    AppColors.coralDeep
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(26),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        AppColors.coral.withAlpha(76),
                                    blurRadius: 32,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: PhosphorIcon(
                                  PhosphorIconsDuotone.compassTool,
                                  size: 46,
                                  color:
                                      Colors.white.withAlpha(240),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Title
                        Transform.translate(
                          offset: Offset(0, 24 * (1 - titleSlide)),
                          child: Opacity(
                            opacity: titleOp,
                            child: Text(
                              'TrySomething',
                              style:
                                  AppTypography.serifDisplay.copyWith(
                                fontSize: 36,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                        ),

                        // Wave underline
                        SizedBox(
                          width: 150,
                          height: 8,
                          child: CustomPaint(
                            painter: _WaveUnderlinePainter(
                              progress: underline,
                              color: AppColors.coral.withAlpha(160),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Tagline
                        Opacity(
                          opacity: tagOp,
                          child: Text(
                            'Discover hobbies you\'ll\nactually stick with.',
                            style: AppTypography.sansBody.copyWith(
                              color: AppColors.espresso,
                              fontSize: 16,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Three stat-style value props
                        Row(
                          children: [
                            _buildStatCol('30 min', 'to your first\nsession',
                                AppColors.coral, stat0),
                            _buildStatCol('CHF 0–30', 'to get\nstarted',
                                AppColors.amber, stat1),
                            _buildStatCol('5 steps', 'from zero\nto doing',
                                AppColors.indigo, stat2),
                          ],
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCol(
      String value, String label, Color color, double progress) {
    return Expanded(
      child: Opacity(
        opacity: progress,
        child: Transform.translate(
          offset: Offset(0, 16 * (1 - progress)),
          child: Column(
            children: [
              Text(
                value,
                style: AppTypography.monoLarge.copyWith(
                  color: color,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: AppTypography.sansTiny.copyWith(
                  color: AppColors.driftwood,
                  fontSize: 11,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingIcon(int i, double w, double h) {
    final (icon, color, size, xPct, yPct, rotDeg) = _ambientIcons[i];
    final baseX = w * xPct;
    final baseY = h * yPct;
    final radians = rotDeg * pi / 180;
    final iconSize = size * 0.42;

    return Positioned(
      left: baseX,
      top: baseY,
      child: FadeTransition(
        opacity: iconFadeAnims[i],
        child: ScaleTransition(
          scale: iconScaleAnims[i],
          child: AnimatedBuilder(
            animation: floatYAnims[i],
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                    floatXAnims[i].value, floatYAnims[i].value),
                child: child,
              );
            },
            child: Transform.rotate(
              angle: radians,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E2E).withAlpha(180),
                  borderRadius: BorderRadius.circular(size * 0.28),
                  boxShadow: [
                    BoxShadow(
                      color: color.withAlpha(40),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Center(
                  child: PhosphorIcon(icon,
                      size: iconSize,
                      color: color.withAlpha(200)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  PAGE 2 — PREFERENCES
// ═══════════════════════════════════════════════════════

class _PreferencesPage extends StatelessWidget {
  final AnimationController entryCtrl;
  final int hours;
  final int budget;
  final bool social;
  final Set<String> vibes;
  final String summary;
  final ValueChanged<int> onHoursChanged;
  final ValueChanged<int> onBudgetChanged;
  final ValueChanged<bool> onSocialChanged;
  final ValueChanged<String> onVibeToggled;

  const _PreferencesPage({
    required this.entryCtrl,
    required this.hours,
    required this.budget,
    required this.social,
    required this.vibes,
    required this.summary,
    required this.onHoursChanged,
    required this.onBudgetChanged,
    required this.onSocialChanged,
    required this.onVibeToggled,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: entryCtrl,
      builder: (context, _) {
        final v = entryCtrl.value;
        final titleOp = _iv(v, 0.0, 0.2);
        final titleSlide = _iv(v, 0.0, 0.2, Curves.easeOutCubic);
        final subOp = _iv(v, 0.05, 0.25);
        final timeOp = _iv(v, 0.15, 0.4);
        final timeSlide = _iv(v, 0.15, 0.4, Curves.easeOutCubic);
        final budgetOp = _iv(v, 0.3, 0.55);
        final budgetSlide = _iv(v, 0.3, 0.55, Curves.easeOutCubic);
        final styleOp = _iv(v, 0.45, 0.7);
        final styleSlide = _iv(v, 0.45, 0.7, Curves.easeOutCubic);
        final vibeOp = _iv(v, 0.55, 0.8);
        final vibeSlide = _iv(v, 0.55, 0.8, Curves.easeOutCubic);
        final summaryOp = _iv(v, 0.7, 1.0);

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Transform.translate(
                offset: Offset(0, 20 * (1 - titleSlide)),
                child: Opacity(
                  opacity: titleOp,
                  child: Text('Tell us\nabout you.',
                      style: AppTypography.serifTitle),
                ),
              ),
              const SizedBox(height: 8),
              Opacity(
                opacity: subOp,
                child: Text(
                  'We\'ll find hobbies that fit your life.',
                  style: AppTypography.sansBody
                      .copyWith(color: AppColors.driftwood),
                ),
              ),
              const SizedBox(height: 36),

              // ── TIME ──
              Transform.translate(
                offset: Offset(0, 16 * (1 - timeSlide)),
                child: Opacity(
                  opacity: timeOp,
                  child: _buildTimeSection(),
                ),
              ),
              const SizedBox(height: 32),

              // ── BUDGET ──
              Transform.translate(
                offset: Offset(0, 16 * (1 - budgetSlide)),
                child: Opacity(
                  opacity: budgetOp,
                  child: _buildBudgetSection(),
                ),
              ),
              const SizedBox(height: 32),

              // ── STYLE ──
              Transform.translate(
                offset: Offset(0, 16 * (1 - styleSlide)),
                child: Opacity(
                  opacity: styleOp,
                  child: _buildStyleSection(),
                ),
              ),
              const SizedBox(height: 32),

              // ── VIBES ──
              Transform.translate(
                offset: Offset(0, 16 * (1 - vibeSlide)),
                child: Opacity(
                  opacity: vibeOp,
                  child: _buildVibesSection(),
                ),
              ),
              const SizedBox(height: 24),

              // ── DYNAMIC SUMMARY ──
              if (summary.isNotEmpty)
                Opacity(
                  opacity: summaryOp,
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: Motion.normal,
                      child: Container(
                        key: ValueKey(summary),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.amberPale,
                          borderRadius:
                              BorderRadius.circular(Spacing.radiusBadge),
                          border: Border.all(
                              color: AppColors.amber.withAlpha(60)),
                        ),
                        child: Text(
                          summary,
                          style: AppTypography.monoCaption
                              .copyWith(color: AppColors.amberDeep),
                        ),
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  // ── Time Stepper ──

  Widget _buildTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('HOW MUCH TIME DO YOU HAVE?'),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Minus
            GestureDetector(
              onTap: hours > 1 ? () => onHoursChanged(hours - 1) : null,
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: hours > 1 ? AppColors.sand : AppColors.warmWhite,
                ),
                child: Center(
                  child: Icon(Icons.remove,
                      size: 20,
                      color: hours > 1
                          ? AppColors.espresso
                          : AppColors.stone),
                ),
              ),
            ),

            // Animated number
            SizedBox(
              width: 110,
              child: Center(
                child: AnimatedSwitcher(
                  duration: Motion.normal,
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.8, end: 1.0)
                          .animate(animation),
                      child: child,
                    ),
                  ),
                  child: Text(
                    '${hours}h',
                    key: ValueKey(hours),
                    style: AppTypography.monoTimer.copyWith(
                      fontSize: 38,
                      color: AppColors.coral,
                    ),
                  ),
                ),
              ),
            ),

            // Plus
            GestureDetector(
              onTap: hours < 7 ? () => onHoursChanged(hours + 1) : null,
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: hours < 7 ? AppColors.sand : AppColors.warmWhite,
                ),
                child: Center(
                  child: Icon(Icons.add,
                      size: 20,
                      color: hours < 7
                          ? AppColors.espresso
                          : AppColors.stone),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Dot scale
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(7, (i) {
            final active = i < hours;
            return AnimatedContainer(
              duration: Motion.fast,
              width: 8,
              height: 8,
              margin: EdgeInsets.only(right: i < 6 ? 8 : 0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active ? AppColors.coral : AppColors.sandDark,
              ),
            );
          }),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            'per week',
            style: AppTypography.sansTiny
                .copyWith(color: AppColors.warmGray),
          ),
        ),
      ],
    );
  }

  // ── Budget Cards ──

  Widget _buildBudgetSection() {
    const labels = ['Low', 'Medium', 'High'];
    const costs = ['<CHF 30', 'CHF 30–100', 'CHF 100+'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('BUDGET'),
        Row(
          children: List.generate(3, (i) {
            final isSelected = budget == i;
            return Expanded(
              child: GestureDetector(
                onTap: () => onBudgetChanged(i),
                child: AnimatedContainer(
                  duration: Motion.fast,
                  margin: EdgeInsets.only(right: i < 2 ? 10 : 0),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  decoration: BoxDecoration(
                    color:
                        isSelected ? AppColors.coralPale : AppColors.sand,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                                color: AppColors.coral.withAlpha(20),
                                blurRadius: 12,
                                offset: const Offset(0, 4))
                          ]
                        : null,
                  ),
                  child: Column(
                    children: [
                      // Budget intensity dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(i + 1, (j) {
                          return Container(
                            width: 6,
                            height: 6,
                            margin: EdgeInsets.only(right: j < i ? 3 : 0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? AppColors.coral
                                  : AppColors.stone,
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        labels[i],
                        style: AppTypography.sansLabel.copyWith(
                          color: isSelected
                              ? AppColors.coral
                              : AppColors.nearBlack,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        costs[i],
                        style: AppTypography.monoCaption.copyWith(
                          color: isSelected
                              ? AppColors.coral.withAlpha(180)
                              : AppColors.warmGray,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ── Segmented Style Toggle ──

  Widget _buildStyleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('YOUR STYLE'),
        Container(
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.sand,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Stack(
            children: [
              // Sliding indicator
              AnimatedAlign(
                duration: Motion.normal,
                curve: Motion.normalCurve,
                alignment:
                    social ? Alignment.centerRight : Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: 0.5,
                  child: Container(
                    height: 44,
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.coral,
                      borderRadius: BorderRadius.circular(11),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.coral.withAlpha(40),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Labels
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => onSocialChanged(false),
                      behavior: HitTestBehavior.opaque,
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(AppIcons.solo,
                                size: 16,
                                color: !social
                                    ? Colors.white
                                    : AppColors.driftwood),
                            const SizedBox(width: 6),
                            Text(
                              'Solo',
                              style: AppTypography.sansButton.copyWith(
                                color: !social
                                    ? Colors.white
                                    : AppColors.driftwood,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => onSocialChanged(true),
                      behavior: HitTestBehavior.opaque,
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(AppIcons.group,
                                size: 16,
                                color: social
                                    ? Colors.white
                                    : AppColors.driftwood),
                            const SizedBox(width: 6),
                            Text(
                              'Social',
                              style: AppTypography.sansButton.copyWith(
                                color: social
                                    ? Colors.white
                                    : AppColors.driftwood,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Vibe Chips ──

  Widget _buildVibesSection() {
    const vibeList = [
      'Creative',
      'Physical',
      'Relaxing',
      'Technical',
      'Outdoors',
      'Competitive'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('WHAT\'S YOUR VIBE?', style: AppTypography.overline),
            const SizedBox(width: 8),
            Text('pick any',
                style: AppTypography.sansTiny.copyWith(
                    color: AppColors.stone, fontStyle: FontStyle.italic)),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 10,
          children: vibeList.map((vibe) {
            final isSelected = vibes.contains(vibe.toLowerCase());
            return GestureDetector(
              onTap: () => onVibeToggled(vibe.toLowerCase()),
              child: AnimatedContainer(
                duration: Motion.fast,
                padding: EdgeInsets.only(
                  left: isSelected ? 12 : 18,
                  right: 18,
                  top: 10,
                  bottom: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.indigo : AppColors.sand,
                  borderRadius: BorderRadius.circular(Spacing.radiusBadge),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                              color: AppColors.indigo.withAlpha(30),
                              blurRadius: 8,
                              offset: const Offset(0, 2))
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedSize(
                      duration: Motion.fast,
                      child: isSelected
                          ? const Padding(
                              padding: EdgeInsets.only(right: 6),
                              child: Icon(Icons.check_rounded,
                                  size: 14, color: Colors.white),
                            )
                          : const SizedBox.shrink(),
                    ),
                    Text(
                      vibe,
                      style: AppTypography.sansLabel.copyWith(
                        color:
                            isSelected ? Colors.white : AppColors.driftwood,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(text, style: AppTypography.overline),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  PAGE 3 — RESULTS
// ═══════════════════════════════════════════════════════

class _ResultsPage extends StatelessWidget {
  final AnimationController entryCtrl;
  final AnimationController particleCtrl;
  final List<_Particle> particles;
  final List<Hobby> matchedHobbies;
  final String persona;

  const _ResultsPage({
    required this.entryCtrl,
    required this.particleCtrl,
    required this.particles,
    required this.matchedHobbies,
    required this.persona,
  });

  @override
  Widget build(BuildContext context) {
    final topMatches = matchedHobbies.take(5).toList();

    return Stack(
      children: [
        // Celebration particles
        AnimatedBuilder(
          animation: particleCtrl,
          builder: (context, _) => CustomPaint(
            painter: _ParticlePainter(
              progress: particleCtrl.value,
              particles: particles,
            ),
            child: const SizedBox.expand(),
          ),
        ),

        // Content
        Center(
          child: AnimatedBuilder(
            animation: entryCtrl,
            builder: (context, _) {
              final v = entryCtrl.value;
              final badgeOp = _iv(v, 0.0, 0.2);
              final badgeScale = _iv(v, 0.0, 0.2, Curves.easeOutBack);
              final personaOp = _iv(v, 0.1, 0.35);
              final personaScale =
                  _iv(v, 0.1, 0.35, Curves.easeOutCubic);
              final countProgress =
                  _iv(v, 0.25, 0.55, Curves.easeOutCubic);
              final displayCount =
                  (matchedHobbies.length * countProgress).round();

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Gradient badge
                    Opacity(
                      opacity: badgeOp,
                      child: Transform.scale(
                        scale: 0.6 + 0.4 * badgeScale,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(Spacing.radiusBadge),
                            gradient: const LinearGradient(
                              colors: [AppColors.coral, AppColors.amber],
                            ),
                          ),
                          child: Text(
                            'YOUR VIBE',
                            style: AppTypography.categoryLabel.copyWith(
                              color: Colors.white,
                              letterSpacing: 3,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Persona title
                    Opacity(
                      opacity: personaOp,
                      child: Transform.scale(
                        scale: 0.85 + 0.15 * personaScale,
                        child: Text(
                          persona,
                          style: AppTypography.serifDisplay,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Animated count
                    Opacity(
                      opacity: _iv(v, 0.25, 0.45),
                      child: Text(
                        'We found $displayCount hobbies for you',
                        style: AppTypography.sansBody.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.coral,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Top 5 matched hobbies
                    ...List.generate(topMatches.length, (i) {
                      final hobby = topMatches[i];
                      final cardOp = _iv(
                          v, 0.4 + i * 0.08, 0.6 + i * 0.08);
                      final cardSlide = _iv(v, 0.4 + i * 0.08,
                          0.6 + i * 0.08, Curves.easeOutCubic);

                      return Opacity(
                        opacity: cardOp,
                        child: Transform.translate(
                          offset: Offset(0, 12 * (1 - cardSlide)),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.warmWhite,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                // Category dot
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: hobby.catColor,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Title
                                Expanded(
                                  child: Text(
                                    hobby.title,
                                    style: AppTypography.sansLabel,
                                  ),
                                ),
                                // Matching tag badge
                                if (hobby.tags.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.indigoPale,
                                      borderRadius:
                                          BorderRadius.circular(100),
                                    ),
                                    child: Text(
                                      hobby.tags.first,
                                      style: AppTypography.monoBadgeSmall
                                          .copyWith(
                                              color: AppColors.indigo),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════
//  PAINTERS
// ═══════════════════════════════════════════════════════

/// Slowly drifting gradient blobs for the welcome page background.
class _GradientBlobPainter extends CustomPainter {
  final List<Offset> positions;

  _GradientBlobPainter({required this.positions});

  static const _colors = [
    Color(0x28FF6B6B), // hot coral at ~16%
    Color(0x20FBBF24), // gold at ~13%
    Color(0x187C3AED), // electric violet at ~10%
  ];

  @override
  void paint(Canvas canvas, Size size) {
    // Base warm wash
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0A0A0F),
            Color(0xFF0E0E18),
            Color(0xFF121220),
            Color(0xFF161628),
          ],
          stops: [0.0, 0.3, 0.6, 1.0],
        ).createShader(Offset.zero & size),
    );

    // Floating blobs
    for (int i = 0; i < 3; i++) {
      final center = Offset(
        size.width * positions[i].dx,
        size.height * positions[i].dy,
      );
      final radius = size.width * 0.55;
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..shader = RadialGradient(
            colors: [_colors[i], _colors[i].withAlpha(0)],
          ).createShader(
              Rect.fromCircle(center: center, radius: radius)),
      );
    }
  }

  @override
  bool shouldRepaint(_GradientBlobPainter old) => true;
}

/// Animated hand-drawn-style wave underline.
class _WaveUnderlinePainter extends CustomPainter {
  final double progress;
  final Color color;

  _WaveUnderlinePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final w = size.width;
    final h = size.height / 2;
    final path = Path()
      ..moveTo(0, h)
      ..quadraticBezierTo(w * 0.18, h - 3, w * 0.35, h + 0.5)
      ..quadraticBezierTo(w * 0.52, h + 3.5, w * 0.68, h - 1)
      ..quadraticBezierTo(w * 0.84, h - 3.5, w, h + 1);

    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;

    final drawn = metrics.first.extractPath(
        0, metrics.first.length * progress);
    canvas.drawPath(
      drawn,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_WaveUnderlinePainter old) =>
      old.progress != progress;
}

/// Celebration particles — glowing 3D orbs with depth parallax.
class _ParticlePainter extends CustomPainter {
  final double progress;
  final List<_Particle> particles;

  _ParticlePainter({required this.progress, required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      // Y: moves upward, wraps around
      final yFrac = ((p.startPhase + progress * p.speed) % 1.0);
      final y = size.height * (1.0 - yFrac);

      // X: dual-sine wobble for organic motion
      final wobble1 = sin(yFrac * p.wobbleFreq * 2 * pi) * p.wobbleAmp;
      final wobble2 = sin(yFrac * p.wobbleFreq2 * 2 * pi + 1.7) * p.wobbleAmp2;
      final x = size.width * p.startX + wobble1 + wobble2;

      // Fade near top and bottom to hide wrap
      final fadeIn = (yFrac / 0.2).clamp(0.0, 1.0);
      final fadeOut = ((1.0 - yFrac) / 0.2).clamp(0.0, 1.0);
      final alpha = (fadeIn * fadeOut * p.maxAlpha).clamp(0.0, 1.0);

      final center = Offset(x.clamp(0, size.width), y);
      final radius = p.size;

      // Radial gradient: bright center → transparent edge = 3D glowing orb
      final gradient = RadialGradient(
        colors: [
          p.color.withValues(alpha: alpha),
          p.color.withValues(alpha: alpha * 0.4),
          p.color.withValues(alpha: 0),
        ],
        stops: const [0.0, 0.5, 1.0],
      );

      final paint = Paint()
        ..shader = gradient.createShader(
          Rect.fromCircle(center: center, radius: radius * 1.8),
        );

      canvas.drawCircle(center, radius * 1.8, paint);

      // Bright inner core for the glow effect
      canvas.drawCircle(
        center,
        radius * 0.4,
        Paint()..color = p.color.withValues(alpha: (alpha * 0.8).clamp(0.0, 1.0)),
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => true;
}

// ═══════════════════════════════════════════════════════
//  DATA
// ═══════════════════════════════════════════════════════

class _Particle {
  final double startX;
  final double startPhase;
  final double speed;
  final double wobbleAmp;
  final double wobbleFreq;
  final double wobbleAmp2;
  final double wobbleFreq2;
  final double size;
  final Color color;
  final double maxAlpha;
  final int depth;

  const _Particle({
    required this.startX,
    required this.startPhase,
    required this.speed,
    required this.wobbleAmp,
    required this.wobbleFreq,
    required this.wobbleAmp2,
    required this.wobbleFreq2,
    required this.size,
    required this.color,
    required this.maxAlpha,
    required this.depth,
  });
}
