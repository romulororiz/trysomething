import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_icons.dart';
import '../../theme/app_typography.dart';
import '../../theme/spacing.dart';
import '../../theme/motion.dart';
import '../../providers/user_provider.dart';

/// 3-page onboarding: Welcome → Preferences → Results
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Preferences state
  int _hours = 3;
  int _budget = 1; // 0=low, 1=medium, 2=high
  bool _social = false;
  final Set<String> _vibes = {};

  // Floating ambient icon animations — each independent
  late List<AnimationController> _floatControllers;
  late List<Animation<double>> _floatYAnimations;
  late List<Animation<double>> _floatXAnimations;

  // Staggered entry animations for vibe icons
  late List<AnimationController> _iconEntryControllers;
  late List<Animation<double>> _iconEntryFade;
  late List<Animation<double>> _iconEntryScale;

  @override
  void initState() {
    super.initState();

    // 8 floating icons, each with slightly different duration for organic feel
    const durations = [5200, 6800, 4500, 7400, 5800, 6200, 4900, 7100];
    _floatControllers = List.generate(8, (i) {
      return AnimationController(
        duration: Duration(milliseconds: durations[i]),
        vsync: this,
      );
    });

    // Staggered entry — each icon 150ms apart, fade + scale in
    _iconEntryControllers = List.generate(8, (i) {
      return AnimationController(
        duration: Motion.normal,
        vsync: this,
      );
    });
    _iconEntryFade = List.generate(8, (i) {
      return CurvedAnimation(
        parent: _iconEntryControllers[i],
        curve: Curves.easeOut,
      );
    });
    _iconEntryScale = List.generate(8, (i) {
      return Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(
          parent: _iconEntryControllers[i],
          curve: Motion.normalCurve,
        ),
      );
    });

    // Stagger the entries: 150ms apart, then start floating
    for (int i = 0; i < 8; i++) {
      Future.delayed(Duration(milliseconds: 150 * i), () {
        if (mounted) {
          _iconEntryControllers[i].forward().then((_) {
            if (mounted) _floatControllers[i].repeat(reverse: true);
          });
        }
      });
    }

    // Vertical drift — each icon bobs up/down a different amount
    const yRanges = [12.0, -10.0, 8.0, -14.0, 10.0, -8.0, 11.0, -9.0];
    _floatYAnimations = List.generate(8, (i) {
      return Tween<double>(begin: 0, end: yRanges[i]).animate(
        CurvedAnimation(parent: _floatControllers[i], curve: Curves.easeInOut),
      );
    });

    // Horizontal drift — subtle side-to-side
    const xRanges = [5.0, -6.0, 4.0, -3.0, -5.0, 6.0, -4.0, 3.0];
    _floatXAnimations = List.generate(8, (i) {
      return Tween<double>(begin: 0, end: xRanges[i]).animate(
        CurvedAnimation(parent: _floatControllers[i], curve: Curves.easeInOut),
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final c in _floatControllers) {
      c.dispose();
    }
    for (final c in _iconEntryControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: Motion.onboardingPage,
        curve: Motion.normalCurve,
      );
      setState(() => _currentPage++);
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() {
    // Save preferences
    final prefsNotifier = ref.read(userPreferencesProvider.notifier);
    prefsNotifier.setHoursPerWeek(_hours);
    prefsNotifier.setBudgetLevel(_budget);
    prefsNotifier.setPreferSocial(_social);
    for (final vibe in _vibes) {
      prefsNotifier.toggleVibe(vibe);
    }

    // Mark onboarding complete
    ref.read(onboardingCompleteProvider.notifier).complete();

    // Navigate to feed
    context.go('/feed');
  }

  @override
  Widget build(BuildContext context) {
    // Gradient wraps entire screen on welcome page, cream on others
    final isWelcome = _currentPage == 0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        decoration: BoxDecoration(
          gradient: isWelcome
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFFFF9F5), // cream top
                    Color(0xFFFFF0EB), // coralPale
                    Color(0xFFFFE4D6), // warm peach
                    Color(0xFFF5D0B8), // deeper warm
                  ],
                  stops: [0.0, 0.3, 0.65, 1.0],
                )
              : const LinearGradient(
                  colors: [AppColors.cream, AppColors.cream],
                ),
        ),
        child: SafeArea(
        child: Column(
          children: [
            // Progress bar
            _buildProgressBar(),

            // Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _WelcomePage(
                    floatYAnimations: _floatYAnimations,
                    floatXAnimations: _floatXAnimations,
                    entryFadeAnimations: _iconEntryFade,
                    entryScaleAnimations: _iconEntryScale,
                  ),
                  _PreferencesPage(
                    hours: _hours,
                    budget: _budget,
                    social: _social,
                    vibes: _vibes,
                    onHoursChanged: (v) => setState(() => _hours = v),
                    onBudgetChanged: (v) => setState(() => _budget = v),
                    onSocialChanged: (v) => setState(() => _social = v),
                    onVibeToggled: (v) => setState(() {
                      _vibes.contains(v) ? _vibes.remove(v) : _vibes.add(v);
                    }),
                  ),
                  const _ResultsPage(),
                ],
              ),
            ),

            // CTA button
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 36),
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
                  ),
                  child: Text(
                    _currentPage == 0
                        ? "Let's find your thing →"
                        : _currentPage == 1
                            ? 'Almost there →'
                            : 'Show me hobbies →',
                    style: AppTypography.sansCta,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 0),
      child: Row(
        children: List.generate(3, (i) {
          return Expanded(
            child: AnimatedContainer(
              duration: Motion.progressBar,
              curve: Motion.normalCurve,
              height: 3,
              margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
              decoration: BoxDecoration(
                color: i <= _currentPage ? AppColors.coral : AppColors.sandDark,
                borderRadius: BorderRadius.circular(Spacing.radiusBadge),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  PAGE 1 — WELCOME (Editorial hero)
// ═══════════════════════════════════════════════════════

class _WelcomePage extends StatelessWidget {
  final List<Animation<double>> floatYAnimations;
  final List<Animation<double>> floatXAnimations;
  final List<Animation<double>> entryFadeAnimations;
  final List<Animation<double>> entryScaleAnimations;

  const _WelcomePage({
    required this.floatYAnimations,
    required this.floatXAnimations,
    required this.entryFadeAnimations,
    required this.entryScaleAnimations,
  });

  // Icon config: phosphorIcon, color, containerSize, iconSize, x%, y%, rotationDeg
  static final _ambientIcons = [
    (PhosphorIconsDuotone.palette, AppColors.catCreative, 58.0, 28.0, 0.06, 0.08, -12.0),
    (PhosphorIconsDuotone.tree, AppColors.catOutdoors, 54.0, 26.0, 0.80, 0.06, 8.0),
    (PhosphorIconsDuotone.musicNotes, AppColors.catMusic, 50.0, 24.0, 0.12, 0.36, 15.0),
    (PhosphorIconsDuotone.barbell, AppColors.catFitness, 52.0, 26.0, 0.85, 0.32, -8.0),
    (PhosphorIconsDuotone.cookingPot, AppColors.catFood, 54.0, 26.0, 0.04, 0.65, 10.0),
    (PhosphorIconsDuotone.sparkle, AppColors.amber, 46.0, 22.0, 0.88, 0.60, -15.0),
    (PhosphorIconsDuotone.wrench, AppColors.catMaker, 50.0, 24.0, 0.76, 0.78, 6.0),
    (PhosphorIconsDuotone.brain, AppColors.catMind, 48.0, 22.0, 0.16, 0.80, -10.0),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        return Stack(
            children: [
              // ── Floating ambient icons ──
              for (int i = 0; i < _ambientIcons.length; i++)
                _buildFloatingIcon(i, w, h),

              // ── Main content centered ──
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 24),

                      // ── App icon — rounded square with coral gradient ──
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppColors.coral, AppColors.coralDeep],
                          ),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.coral.withValues(alpha: 0.30),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: PhosphorIcon(
                          PhosphorIconsDuotone.compassTool,
                          size: 42,
                          color: Colors.white.withValues(alpha: 0.95),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ── App name ──
                      Text(
                        'TrySomething',
                        style: AppTypography.serifDisplay.copyWith(
                          fontSize: 34,
                          letterSpacing: -0.5,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ── Tagline ──
                      Text(
                        'Discover hobbies you\'ll actually start.',
                        style: AppTypography.sansBody.copyWith(
                          color: AppColors.espresso,
                          fontSize: 16,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 32),

                      // ── Feature highlights — three small rows ──
                      _FeatureRow(
                        icon: PhosphorIconsDuotone.timer,
                        text: 'See how long it really takes',
                        color: AppColors.amber,
                      ),
                      const SizedBox(height: 14),
                      _FeatureRow(
                        icon: PhosphorIconsDuotone.wallet,
                        text: 'Know the cost before you start',
                        color: AppColors.sage,
                      ),
                      const SizedBox(height: 14),
                      _FeatureRow(
                        icon: PhosphorIconsDuotone.rocketLaunch,
                        text: 'Step-by-step beginner roadmaps',
                        color: AppColors.indigo,
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
        );
      },
    );
  }

  Widget _buildFloatingIcon(int i, double w, double h) {
    final (icon, color, containerSize, iconSize, xPct, yPct, rotDeg) =
        _ambientIcons[i];
    final baseX = w * xPct;
    final baseY = h * yPct;
    final radians = rotDeg * 3.14159 / 180;

    return Positioned(
      left: baseX,
      top: baseY,
      child: FadeTransition(
        opacity: entryFadeAnimations[i],
        child: ScaleTransition(
          scale: entryScaleAnimations[i],
          child: AnimatedBuilder(
            animation: floatYAnimations[i],
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(floatXAnimations[i].value, floatYAnimations[i].value),
                child: child,
              );
            },
            child: Transform.rotate(
              angle: radians,
              child: Container(
                width: containerSize,
                height: containerSize,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(containerSize * 0.28),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.70),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.08),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: PhosphorIcon(icon, size: iconSize, color: color.withValues(alpha: 0.85)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Small feature highlight row with colored icon + text
class _FeatureRow extends StatelessWidget {
  final PhosphorIconData icon;
  final String text;
  final Color color;

  const _FeatureRow({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: PhosphorIcon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            text,
            style: AppTypography.sansBody.copyWith(
              color: AppColors.darkBrown,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════
//  PAGE 2 — PREFERENCES
// ═══════════════════════════════════════════════════════

class _PreferencesPage extends StatelessWidget {
  final int hours;
  final int budget;
  final bool social;
  final Set<String> vibes;
  final ValueChanged<int> onHoursChanged;
  final ValueChanged<int> onBudgetChanged;
  final ValueChanged<bool> onSocialChanged;
  final ValueChanged<String> onVibeToggled;

  const _PreferencesPage({
    required this.hours,
    required this.budget,
    required this.social,
    required this.vibes,
    required this.onHoursChanged,
    required this.onBudgetChanged,
    required this.onSocialChanged,
    required this.onVibeToggled,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tell us\nabout you.', style: AppTypography.serifTitle),
          const SizedBox(height: 8),
          Text(
            'We\'ll find hobbies that fit your life.',
            style: AppTypography.sansBody.copyWith(color: AppColors.driftwood),
          ),
          const SizedBox(height: 32),

          // Time slider
          _buildSectionLabel('HOW MUCH TIME DO YOU HAVE?'),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: hours.toDouble(),
                  min: 1,
                  max: 7,
                  divisions: 6,
                  onChanged: (v) => onHoursChanged(v.round()),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.coralPale,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${hours}h/wk',
                  style: AppTypography.monoLarge.copyWith(color: AppColors.coral),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Budget
          _buildSectionLabel('BUDGET'),
          Row(
            children: List.generate(3, (i) {
              final labels = ['Low\n<CHF 30', 'Medium\nCHF 30–100', 'High\nCHF 100+'];
              final isSelected = budget == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onBudgetChanged(i),
                  child: AnimatedContainer(
                    duration: Motion.fast,
                    margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.coralPale : AppColors.warmWhite,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.coral.withValues(alpha: 0.5)
                            : AppColors.sandDark,
                      ),
                    ),
                    child: Text(
                      labels[i],
                      style: AppTypography.sansCaption.copyWith(
                        color: isSelected ? AppColors.coral : AppColors.driftwood,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 28),

          // Solo / Social
          _buildSectionLabel('YOUR STYLE'),
          Row(
            children: [
              _buildToggleButton(AppIcons.solo, 'Solo', !social, () => onSocialChanged(false)),
              const SizedBox(width: 8),
              _buildToggleButton(AppIcons.group, 'Social', social, () => onSocialChanged(true)),
            ],
          ),
          const SizedBox(height: 28),

          // Vibes
          _buildSectionLabel('WHAT\'S YOUR VIBE?'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['Creative', 'Physical', 'Relaxing', 'Technical', 'Outdoors', 'Competitive']
                .map((vibe) {
              final isSelected = vibes.contains(vibe.toLowerCase());
              return GestureDetector(
                onTap: () => onVibeToggled(vibe.toLowerCase()),
                child: AnimatedContainer(
                  duration: Motion.fast,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.indigoPale : AppColors.warmWhite,
                    borderRadius: BorderRadius.circular(Spacing.radiusBadge),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.indigo.withValues(alpha: 0.5)
                          : AppColors.sandDark,
                    ),
                  ),
                  child: Text(
                    vibe,
                    style: AppTypography.sansLabel.copyWith(
                      color: isSelected ? AppColors.indigo : AppColors.driftwood,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(text, style: AppTypography.overline),
    );
  }

  Widget _buildToggleButton(IconData icon, String label, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: Motion.fast,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.coralPale : AppColors.warmWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.coral.withValues(alpha: 0.5)
                  : AppColors.sandDark,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: isSelected ? AppColors.coral : AppColors.driftwood),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTypography.sansButton.copyWith(
                  color: isSelected ? AppColors.coral : AppColors.driftwood,
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
//  PAGE 3 — RESULTS
// ═══════════════════════════════════════════════════════

class _ResultsPage extends StatelessWidget {
  const _ResultsPage();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Gradient badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Spacing.radiusBadge),
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
          const SizedBox(height: 20),

          // Title
          Text(
            'Creative\nExplorer',
            style: AppTypography.serifDisplay,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Count
          Text(
            'We found 12 hobbies for you',
            style: AppTypography.sansBody.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.coral,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),

          // Suggestion pills
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: ['Pottery', 'Calligraphy', 'Hiking', 'Guitar', 'Sourdough']
                .map((hobby) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.sand,
                        borderRadius: BorderRadius.circular(Spacing.radiusBadge),
                        border: Border.all(color: AppColors.sandDark),
                      ),
                      child: Text(
                        hobby,
                        style: AppTypography.sansLabel.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
