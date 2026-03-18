import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../models/hobby.dart';
import '../../core/hobby_match.dart';
import '../../theme/category_ui.dart';
import '../../core/analytics/analytics_provider.dart';
import '../../providers/hobby_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_icons.dart';
import '../../theme/app_typography.dart';
import '../../theme/motion.dart';
import '../../theme/spacing.dart';

// ═══════════════════════════════════════════════════════
//  INTERVAL HELPER
// ═══════════════════════════════════════════════════════

double _iv(double v, double begin, double end,
    [Curve curve = Curves.easeOut]) {
  if (v <= begin) return 0.0;
  if (v >= end) return 1.0;
  return curve.transform((v - begin) / (end - begin));
}

// ═══════════════════════════════════════════════════════
//  VIBE GRID DATA
// ═══════════════════════════════════════════════════════

class _VibeItem {
  final String label;
  final String key;
  final IconData outlineIcon;
  final IconData filledIcon;
  const _VibeItem(this.label, this.key, this.outlineIcon, this.filledIcon);
}

final _vibeItems = [
  _VibeItem('Creative', 'creative', MdiIcons.paletteOutline, MdiIcons.palette),
  _VibeItem('Relaxing', 'relaxing', MdiIcons.yoga, MdiIcons.meditation),
  _VibeItem('Social', 'social', MdiIcons.accountGroupOutline, MdiIcons.accountGroup),
  _VibeItem('Active', 'physical', MdiIcons.flashOutline, MdiIcons.flash),
  _VibeItem('Intellectual', 'intellectual', MdiIcons.bookOpenPageVariantOutline, MdiIcons.bookOpenPageVariant),
  _VibeItem('Outdoors', 'outdoors', MdiIcons.pineTreeVariantOutline, MdiIcons.pineTree),
  _VibeItem('Tech', 'technical', MdiIcons.laptopAccount, MdiIcons.memory),
  _VibeItem('Culinary', 'culinary', MdiIcons.chefHat, MdiIcons.chefHat),
];

// ═══════════════════════════════════════════════════════
//  ONBOARDING SCREEN
// ═══════════════════════════════════════════════════════

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
  double _hours = 5;
  int _budget = 1; // 0=low, 1=medium, 2=high
  bool _social = false;
  final Set<String> _vibes = {};
  List<Hobby> _matchedHobbies = [];
  Map<String, List<String>> _matchReasons = {};
  Map<String, int> _matchScores = {};

  // Animation controllers
  late AnimationController _page1EntryCtrl;
  late AnimationController _page2EntryCtrl;
  late AnimationController _page3EntryCtrl;
  late AnimationController _glowCtrl;

  @override
  void initState() {
    super.initState();
    _page1EntryCtrl = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this);
    _page2EntryCtrl = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this);
    _page3EntryCtrl = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    _glowCtrl = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this)
      ..repeat(reverse: true);
    _page1EntryCtrl.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _page1EntryCtrl.dispose();
    _page2EntryCtrl.dispose();
    _page3EntryCtrl.dispose();
    _glowCtrl.dispose();
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
        if (next == 2) _matchedHobbies = _computeMatchedHobbies();
      });
      if (next == 1) _page2EntryCtrl.forward();
      if (next == 2) _page3EntryCtrl.forward();
    } else {
      _completeOnboarding();
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      final prev = _currentPage - 1;
      _pageController.animateToPage(prev,
          duration: Motion.onboardingPage, curve: Motion.normalCurve);
      setState(() => _currentPage = prev);
    }
  }

  void _skip() {
    _completeOnboarding();
  }

  void _completeOnboarding() {
    final prefsNotifier = ref.read(userPreferencesProvider.notifier);
    prefsNotifier.setHoursPerWeek(_hours.round());
    prefsNotifier.setBudgetLevel(_budget);
    prefsNotifier.setPreferSocial(_social);
    for (final vibe in _vibes) {
      prefsNotifier.toggleVibe(vibe);
    }
    ref.read(onboardingCompleteProvider.notifier).complete();

    // Track onboarding completion with quiz answers
    ref.read(analyticsProvider).trackEvent('onboarding_completed', {
      'hours_per_week': _hours.round(),
      'budget_level': _budget,
      'prefer_social': _social,
      'vibes': _vibes.toList(),
      'match_count': _matchedHobbies.length,
      'top_match': _matchedHobbies.isNotEmpty ? _matchedHobbies.first.id : null,
    });

    // Fire-and-forget: sync preferences to server
    final repo = ref.read(authRepositoryProvider);
    repo.updatePreferences(
      hoursPerWeek: _hours.round(),
      budgetLevel: _budget,
      preferSocial: _social,
      vibes: _vibes,
    );

    context.go('/match-results');
  }

  // ── Matching ──

  List<Hobby> _computeMatchedHobbies() {
    final all = ref.read(hobbyListProvider).valueOrNull ?? [];
    if (all.isEmpty) return [];

    final matched = computeMatchedHobbies(
      allHobbies: all,
      userHours: _hours,
      userBudgetLevel: _budget,
      userPrefersSocial: _social,
      userVibes: _vibes,
    );

    // Compute reasons and scores for each matched hobby
    _matchReasons = {
      for (final h in matched)
        h.id: computeMatchReasons(
          hobby: h,
          userHours: _hours,
          userBudgetLevel: _budget,
          userPrefersSocial: _social,
          userVibes: _vibes,
        ),
    };
    _matchScores = {
      for (final h in matched)
        h.id: computeMatchScore(
          hobby: h,
          userHours: _hours,
          userBudgetLevel: _budget,
          userPrefersSocial: _social,
          userVibes: _vibes,
        ),
    };

    return matched;
  }

  // ── Build ──

  @override
  Widget build(BuildContext context) {
    // Recompute matches when hobby data arrives (if we're on the results page
    // and matches are empty because hobbies hadn't loaded yet)
    ref.listen(hobbyListProvider, (prev, next) {
      if (_currentPage == 2 && _matchedHobbies.isEmpty && next.hasValue) {
        setState(() {
          _matchedHobbies = _computeMatchedHobbies();
        });
      }
    });

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            // Header — back on pages 2+, skip on pages 1-2
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    GestureDetector(
                      onTap: _prevPage,
                      child: const Icon(Icons.arrow_back_rounded,
                          size: 24, color: AppColors.nearBlack),
                    )
                  else
                    const SizedBox(width: 24),
                  const Spacer(),
                  if (_currentPage > 0)
                    Text('Onboarding',
                        style: AppTypography.sansLabel.copyWith(
                          color: AppColors.nearBlack,
                          fontWeight: FontWeight.w600,
                        )),
                  const Spacer(),
                ],
              ),
            ),

            // Progress dots
            _buildProgressDots(),

            // Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _VibesPage(
                    entryCtrl: _page1EntryCtrl,
                    vibes: _vibes,
                    onVibeToggled: (key) => setState(() {
                      _vibes.contains(key)
                          ? _vibes.remove(key)
                          : _vibes.add(key);
                    }),
                  ),
                  _TimeBudgetPage(
                    entryCtrl: _page2EntryCtrl,
                    hours: _hours,
                    budget: _budget,
                    social: _social,
                    onHoursChanged: (v) => setState(() => _hours = v),
                    onBudgetChanged: (v) => setState(() => _budget = v),
                    onSocialChanged: (v) => setState(() => _social = v),
                  ),
                  _ReadyPage(
                    entryCtrl: _page3EntryCtrl,
                    matchedHobbies: _matchedHobbies,
                    matchReasons: _matchReasons,
                    matchScores: _matchScores,
                    vibes: _vibes,
                    hours: _hours,
                    social: _social,
                  ),
                ],
              ),
            ),

            // Bottom CTA
            _buildBottomCta(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressDots() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (i) {
          final isActive = i == _currentPage;
          return AnimatedContainer(
            duration: Motion.normal,
            curve: Motion.normalCurve,
            width: isActive ? 24 : 8,
            height: 8,
            margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: isActive ? AppColors.coral : AppColors.sandDark,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBottomCta() {
    final labels = ['Continue  →', 'Continue  →', 'Start Exploring  →'];
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(28, 0, 28, 16 + bottomPad),
      child: Column(
        children: [
          // Coral gradient CTA button
          AnimatedBuilder(
            animation: _glowCtrl,
            builder: (context, child) {
              final glow = 12.0 + _glowCtrl.value * 8.0;
              return Container(
                width: double.infinity,
                height: Spacing.buttonCtaHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Spacing.radiusCta),
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
              height: Spacing.buttonCtaHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.coral, AppColors.coralDeep],
                  ),
                  borderRadius: BorderRadius.circular(Spacing.radiusCta),
                ),
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(Spacing.radiusCta),
                    ),
                    elevation: 0,
                  ),
                  child: Text(labels[_currentPage],
                      style: AppTypography.sansButton.copyWith(color: Colors.white)),
                ),
              ),
            ),
          ),

          // Skip text (page 1 only)
          if (_currentPage == 0) ...[
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _skip,
              child: Text('Skip for now',
                  style: AppTypography.sansCaption
                      .copyWith(color: AppColors.driftwood)),
            ),
          ],

          // Social proof (page 3)
          if (_currentPage == 2) ...[
            const SizedBox(height: 16),
            Text('Join 10,000+ hobbyists starting today',
                style: AppTypography.sansCaption
                    .copyWith(color: AppColors.warmGray)),
          ],

          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  PAGE 1 — VIBES GRID
// ═══════════════════════════════════════════════════════

class _VibesPage extends StatelessWidget {
  final AnimationController entryCtrl;
  final Set<String> vibes;
  final ValueChanged<String> onVibeToggled;

  const _VibesPage({
    required this.entryCtrl,
    required this.vibes,
    required this.onVibeToggled,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: entryCtrl,
      builder: (context, _) {
        final v = entryCtrl.value;
        final titleOp = _iv(v, 0.0, 0.3);
        final titleSlide = _iv(v, 0.0, 0.3, Curves.easeOutCubic);
        final subOp = _iv(v, 0.1, 0.35);
        final gridOp = _iv(v, 0.2, 0.5);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Title
              Transform.translate(
                offset: Offset(0, 20 * (1 - titleSlide)),
                child: Opacity(
                  opacity: titleOp,
                  child: Text(
                    'What vibes\nare you into?',
                    style: AppTypography.serifTitle.copyWith(fontSize: 34),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Subtitle
              Opacity(
                opacity: subOp,
                child: Text(
                  'Select a few categories to help us\npersonalize your recommendations.',
                  style: AppTypography.sansBody
                      .copyWith(color: AppColors.driftwood, height: 1.5),
                ),
              ),
              const SizedBox(height: 32),

              // 2×4 Grid
              Expanded(
                child: Opacity(
                  opacity: gridOp,
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.4,
                    physics: const NeverScrollableScrollPhysics(),
                    children: _vibeItems.map((item) {
                      final isSelected = vibes.contains(item.key);
                      return _VibeCard(
                        item: item,
                        isSelected: isSelected,
                        onTap: () => onVibeToggled(item.key),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _VibeCard extends StatelessWidget {
  final _VibeItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _VibeCard({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Motion.fast,
        decoration: BoxDecoration(
          color: AppColors.sand,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.coral : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Stack(
          children: [
            // Icon + label
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isSelected ? item.filledIcon : item.outlineIcon,
                    size: 32,
                    color: isSelected ? AppColors.coral : AppColors.textMuted,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item.label,
                    style: AppTypography.sansLabel.copyWith(
                      color: isSelected
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Checkmark badge
            if (isSelected)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.coral,
                  ),
                  child: const Icon(Icons.check,
                      size: 14, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  PAGE 2 — TIME & BUDGET
// ═══════════════════════════════════════════════════════

class _TimeBudgetPage extends StatelessWidget {
  final AnimationController entryCtrl;
  final double hours;
  final int budget;
  final bool social;
  final ValueChanged<double> onHoursChanged;
  final ValueChanged<int> onBudgetChanged;
  final ValueChanged<bool> onSocialChanged;

  const _TimeBudgetPage({
    required this.entryCtrl,
    required this.hours,
    required this.budget,
    required this.social,
    required this.onHoursChanged,
    required this.onBudgetChanged,
    required this.onSocialChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: entryCtrl,
      builder: (context, _) {
        final v = entryCtrl.value;
        final titleOp = _iv(v, 0.0, 0.25);
        final titleSlide = _iv(v, 0.0, 0.25, Curves.easeOutCubic);
        final sliderOp = _iv(v, 0.15, 0.4);
        final budgetOp = _iv(v, 0.3, 0.55);
        final prefOp = _iv(v, 0.45, 0.7);

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 8, 28, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title + subtitle
              Transform.translate(
                offset: Offset(0, 16 * (1 - titleSlide)),
                child: Opacity(
                  opacity: titleOp,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Time & Budget',
                          style: AppTypography.serifTitle),
                      const SizedBox(height: 8),
                      Text(
                        'Customize your journey constraints so we can\nfind hobbies that actually fit your life.',
                        style: AppTypography.sansBody
                            .copyWith(color: AppColors.driftwood, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Hours slider
              Opacity(
                opacity: sliderOp,
                child: _buildHoursSection(),
              ),
              const SizedBox(height: 36),

              // Budget cards
              Opacity(
                opacity: budgetOp,
                child: _buildBudgetSection(),
              ),
              const SizedBox(height: 36),

              // Preference toggle
              Opacity(
                opacity: prefOp,
                child: _buildPreferenceSection(),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Hours Slider ──

  Widget _buildHoursSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Hours per week',
                style: AppTypography.sansSection
                    .copyWith(color: AppColors.nearBlack)),
            const Spacer(),
            Text('${hours.round()} hrs',
                style: AppTypography.sansSection.copyWith(
                    color: AppColors.coral, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 16),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: AppColors.coral,
            inactiveTrackColor: AppColors.sandDark,
            thumbColor: Colors.white,
            overlayColor: AppColors.coral.withAlpha(30),
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 14,
              elevation: 4,
            ),
          ),
          child: Slider(
            value: hours,
            min: 1,
            max: 10,
            divisions: 9,
            onChanged: onHoursChanged,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('1h',
                  style: AppTypography.sansCaption
                      .copyWith(color: AppColors.warmGray)),
              Text('10h+',
                  style: AppTypography.sansCaption
                      .copyWith(color: AppColors.warmGray)),
            ],
          ),
        ),
      ],
    );
  }

  // ── Budget Cards ──

  Widget _buildBudgetSection() {
    final items = [
      (MdiIcons.piggyBank, 'Low', 'Free/Cheap'),
      (MdiIcons.walletOutline, 'Medium', '\$\$ Occasional'),
      (MdiIcons.diamondStone, 'High', '\$\$\$ Premium'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Budget Level',
            style: AppTypography.sansSection
                .copyWith(color: AppColors.nearBlack)),
        const SizedBox(height: 16),
        Row(
          children: List.generate(3, (i) {
            final isSelected = budget == i;
            final (icon, label, subtitle) = items[i];
            return Expanded(
              child: GestureDetector(
                onTap: () => onBudgetChanged(i),
                child: AnimatedContainer(
                  duration: Motion.fast,
                  margin: EdgeInsets.only(right: i < 2 ? 10 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: AppColors.sand,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.coral
                          : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? AppColors.coralPale
                              : AppColors.warmWhite,
                        ),
                        child: Icon(icon,
                            size: 22,
                            color: isSelected
                                ? AppColors.coral
                                : AppColors.driftwood),
                      ),
                      const SizedBox(height: 10),
                      Text(label,
                          style: AppTypography.sansLabel.copyWith(
                            color: isSelected
                                ? AppColors.nearBlack
                                : AppColors.driftwood,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          )),
                      const SizedBox(height: 4),
                      Text(subtitle,
                          style: AppTypography.sansTiny
                              .copyWith(color: AppColors.warmGray)),
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

  // ── Solo / Social Toggle ──

  Widget _buildPreferenceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Preference',
            style: AppTypography.sansSection
                .copyWith(color: AppColors.nearBlack)),
        const SizedBox(height: 16),
        Row(
          children: [
            // Solo
            Expanded(
              child: GestureDetector(
                onTap: () => onSocialChanged(false),
                child: AnimatedContainer(
                  duration: Motion.fast,
                  height: 48,
                  decoration: BoxDecoration(
                    color: !social ? AppColors.sand : AppColors.warmWhite,
                    borderRadius: BorderRadius.circular(Spacing.radiusBadge),
                    border: Border.all(
                      color:
                          !social ? AppColors.sandDark : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(AppIcons.solo,
                          size: 18,
                          color: !social
                              ? AppColors.nearBlack
                              : AppColors.driftwood),
                      const SizedBox(width: 8),
                      Text('Solo',
                          style: AppTypography.sansButton.copyWith(
                            color: !social
                                ? AppColors.nearBlack
                                : AppColors.driftwood,
                          )),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Social
            Expanded(
              child: GestureDetector(
                onTap: () => onSocialChanged(true),
                child: AnimatedContainer(
                  duration: Motion.fast,
                  height: 48,
                  decoration: BoxDecoration(
                    color: social ? AppColors.coral : AppColors.warmWhite,
                    borderRadius: BorderRadius.circular(Spacing.radiusBadge),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(AppIcons.group,
                          size: 18,
                          color:
                              social ? Colors.white : AppColors.driftwood),
                      const SizedBox(width: 8),
                      Text('Social',
                          style: AppTypography.sansButton.copyWith(
                            color: social
                                ? Colors.white
                                : AppColors.driftwood,
                          )),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        if (social) ...[
          const SizedBox(height: 12),
          Text("We'll prioritize group activities and clubs.",
              style: AppTypography.sansCaption
                  .copyWith(color: AppColors.warmGray)),
        ],
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════
//  PAGE 3 — READY
// ═══════════════════════════════════════════════════════

class _ReadyPage extends ConsumerStatefulWidget {
  final AnimationController entryCtrl;
  final List<Hobby> matchedHobbies;
  final Map<String, List<String>> matchReasons;
  final Map<String, int> matchScores;
  final Set<String> vibes;
  final double hours;
  final bool social;

  const _ReadyPage({
    required this.entryCtrl,
    required this.matchedHobbies,
    required this.matchReasons,
    required this.matchScores,
    required this.vibes,
    required this.hours,
    required this.social,
  });

  @override
  ConsumerState<_ReadyPage> createState() => _ReadyPageState();
}

class _ReadyPageState extends ConsumerState<_ReadyPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatCtrl;

  // Card positions: (leftPct, topPct, width, height)
  // Shifted right for better centering within padded area
  static const _cardLayouts = [
    (0.10, 0.02, 120.0, 130.0), // top-left — small
    (0.52, 0.00, 155.0, 175.0), // top-right — taller
    (0.02, 0.34, 185.0, 200.0), // bottom-left — largest, top match
    (0.54, 0.45, 130.0, 140.0), // bottom-right — small
  ];

  // 3D perspective transforms per card: (rotateX, rotateY, rotateZ)
  // Strong tilts to match the mockup's dramatic 3D-floating look
  static const _cardTransforms = [
    (-0.15, 0.10, -0.04),  // top-left: tilts back-right
    (0.10, -0.15, 0.04),   // top-right: tilts back-left
    (0.12, 0.10, -0.03),   // bottom-left: tilts forward-right
    (-0.10, -0.12, 0.05),  // bottom-right: tilts forward-left
  ];

  // Float offsets per card (amplitude, phase)
  static const _floatParams = [
    (3.0, 0.0),
    (2.5, 0.8),
    (3.5, 1.6),
    (2.0, 2.4),
  ];

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);

  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topMatches = widget.matchedHobbies.take(4).toList();

    return AnimatedBuilder(
      animation: Listenable.merge([widget.entryCtrl, _floatCtrl]),
      builder: (context, _) {
        final v = widget.entryCtrl.value;
        final cardsOp = _iv(v, 0.1, 0.4);
        final titleOp = _iv(v, 0.4, 0.65);
        final titleScale = _iv(v, 0.4, 0.65, Curves.easeOutCubic);
        final bodyOp = _iv(v, 0.55, 0.8);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              // "Curated for you" badge — left-aligned, smaller, synced with top-left card
              Align(
                alignment: Alignment.centerLeft,
                child: Opacity(
                  opacity: _iv(v, 0.1, 0.35), // synced with card index 0
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.003)
                      ..rotateX(-0.15)
                      ..rotateY(0.10)
                      ..rotateZ(-0.04),
                    child: Transform.translate(
                      offset: Offset(0, math.sin(_floatCtrl.value * math.pi + 0.0) * 3.0),
                      child: Container(
                      margin: const EdgeInsets.only(top: 8, left: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated.withAlpha(200),
                        borderRadius:
                            BorderRadius.circular(Spacing.radiusBadge),
                        border:
                            Border.all(color: AppColors.textWhisper),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(MdiIcons.autoFix,
                              size: 11, color: AppColors.textSecondary),
                          const SizedBox(width: 3),
                          Text('Curated for you',
                              style: AppTypography.sansTiny.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                  ),
                ),
              ),

              // Floating cards area
              Expanded(
                flex: 3,
                child: Opacity(
                  opacity: cardsOp,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final areaW = constraints.maxWidth;
                      final areaH = constraints.maxHeight;
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Subtle floating particles
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _ParticlePainter(
                                progress: _floatCtrl.value,
                              ),
                            ),
                          ),

                          // Decorative dots
                          _dot(areaW * 0.85, areaH * 0.02, 6,
                              AppColors.coral),
                          _dot(areaW * 0.08, areaH * 0.30, 4,
                              AppColors.warmGray),
                          _dot(areaW * 0.92, areaH * 0.50, 5,
                              AppColors.amber),
                          _dot(areaW * 0.45, areaH * 0.75, 3,
                              AppColors.warmGray),

                          // Hobby cards (4 matched)
                          for (int i = 0;
                              i < 4 && i < topMatches.length;
                              i++)
                            _buildFloatingCard(
                                topMatches[i],
                                areaW,
                                areaH,
                                i,
                                v,
                                widget.matchReasons[topMatches[i].id] ?? []),

                          // "98% Match" floating badge
                          _buildMatchBadge(areaW, areaH, v),
                        ],
                      );
                    },
                  ),
                ),
              ),

              // Title + body text
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    // "You're ready!" title with wave underline
                    Opacity(
                      opacity: titleOp,
                      child: Transform.scale(
                        scale: 0.9 + 0.1 * titleScale,
                        child: Column(
                          children: [
                            Text("You're ready!",
                                style: AppTypography.serifDisplay
                                    .copyWith(fontSize: 36)),
                            SizedBox(
                              width: 180,
                              height: 8,
                              child: CustomPaint(
                                painter: _WaveUnderlinePainter(
                                  progress: titleOp,
                                  color:
                                      AppColors.coral.withAlpha(160),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Body text
                    Opacity(
                      opacity: bodyOp,
                      child: Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          "We've curated a personalized list of\nhobbies just for you. Dive in and find\nyour next passion.",
                          textAlign: TextAlign.center,
                          style: AppTypography.sansBody.copyWith(
                            color: AppColors.driftwood,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFloatingCard(
      Hobby hobby, double areaW, double areaH, int i, double entryV,
      [List<String> reasons = const []]) {
    final (leftPct, topPct, cardW, cardH) = _cardLayouts[i];
    final cardOp = _iv(entryV, 0.1 + i * 0.06, 0.35 + i * 0.06);
    final cardSlide =
        _iv(entryV, 0.1 + i * 0.06, 0.35 + i * 0.06, Curves.easeOutCubic);

    // Subtle floating bob per card
    final (amp, phase) = _floatParams[i];
    final floatOffset = math.sin(_floatCtrl.value * math.pi + phase) * amp;
    final isTopMatch = i == 2; // bottom-left card is the top match
    final (rx, ry, rz) = _cardTransforms[i];

    final titleSize = isTopMatch ? 14.0 : 11.0;

    // 3D perspective matrix — strong tilted-in-space look matching mockup
    final matrix = Matrix4.identity()
      ..setEntry(3, 2, 0.003) // deeper perspective for dramatic 3D
      ..rotateX(rx)
      ..rotateY(ry)
      ..rotateZ(rz);

    return Positioned(
      left: areaW * leftPct,
      top: areaH * topPct + 12 * (1 - cardSlide) + floatOffset,
      child: Opacity(
        opacity: cardOp,
        child: Transform(
          alignment: Alignment.center,
          transform: matrix,
          child: Container(
            width: cardW,
            height: cardH,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: Colors.white.withAlpha(isTopMatch ? 30 : 18),
                width: isTopMatch ? 1.0 : 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(80),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Hobby image background
                  CachedNetworkImage(
                    imageUrl: hobby.imageUrl,
                    fit: BoxFit.cover,
                    memCacheWidth: 600,
                    placeholder: (_, __) =>
                        Container(color: AppColors.sand),
                    errorWidget: (_, __, ___) =>
                        Container(color: AppColors.sand),
                  ),

                  // Gradient overlay — small cards: dark bottom only; top match: clearer top, dark bottom
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: isTopMatch
                            ? const [0.0, 0.4, 1.0]
                            : const [0.0, 0.45, 1.0],
                        colors: isTopMatch
                            ? [
                                Colors.black.withAlpha(20),  // clear top
                                Colors.black.withAlpha(40),  // still visible middle
                                Colors.black.withAlpha(190), // dark bottom for text
                              ]
                            : [
                                Colors.black.withAlpha(10),  // almost clear top
                                Colors.black.withAlpha(30),  // light middle
                                Colors.black.withAlpha(200), // dark bottom for text
                              ],
                      ),
                    ),
                  ),

                  // Content: hobby title + subtitle specs
                  Padding(
                    padding: EdgeInsets.all(isTopMatch ? 14.0 : 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category icon badge
                        Container(
                          width: isTopMatch ? 32 : 24,
                          height: isTopMatch ? 32 : 24,
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(80),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            hobby.catIcon,
                            size: isTopMatch ? 18 : 14,
                            color: AppColors.textSecondary,
                          ),
                        ),

                        const Spacer(),

                        // Hobby title
                        Text(
                          hobby.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.sansLabel.copyWith(
                            color: Colors.white,
                            fontSize: titleSize,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        ),

                        // Subtitle: cost + time for all cards
                        const SizedBox(height: 3),
                        Text(
                          '${hobby.costText} · ${hobby.timeText}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.sansTiny.copyWith(
                            color: Colors.white.withAlpha(160),
                            fontSize: isTopMatch ? 10 : 9,
                            height: 1.3,
                          ),
                        ),

                        // Match reason (larger card only)
                        if (isTopMatch && reasons.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            reasons.first,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.sansTiny.copyWith(
                              color: Colors.white.withAlpha(140),
                              fontSize: 10,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the match percentage badge that floats between cards.
  /// Uses actual score from [computeMatchScore] / max possible score.
  Widget _buildMatchBadge(double areaW, double areaH, double entryV) {
    final badgeOp = _iv(entryV, 0.25, 0.45);
    final (amp, phase) = (2.0, 1.2);
    final floatOffset = math.sin(_floatCtrl.value * math.pi + phase) * amp;

    // Compute actual match percentage for top match (card index 2)
    final topMatches = widget.matchedHobbies;
    final topMatchId = topMatches.length > 2 ? topMatches[2].id : (topMatches.isNotEmpty ? topMatches.first.id : '');
    final score = widget.matchScores[topMatchId] ?? 0;
    // Max: 3 (budget) + 3 (time) + 2 (social) + vibes count
    final maxScore = 8 + widget.vibes.length;
    final pct = maxScore > 0 ? (score / maxScore * 100).round().clamp(0, 100) : 0;

    return Positioned(
      left: areaW * 0.22,
      top: areaH * 0.30 + floatOffset,
      child: Opacity(
        opacity: badgeOp,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.coral,
            borderRadius: BorderRadius.circular(Spacing.radiusBadge),
            boxShadow: [
              BoxShadow(
                color: AppColors.coral.withAlpha(80),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            '$pct% Match',
            style: AppTypography.monoBadgeSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _dot(double x, double y, double size, Color color) {
    return Positioned(
      left: x,
      top: y,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withAlpha(120),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  PAINTERS
// ═══════════════════════════════════════════════════════

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

    final drawn =
        metrics.first.extractPath(0, metrics.first.length * progress);
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

/// Subtle floating particles that drift slowly across the card area.
class _ParticlePainter extends CustomPainter {
  final double progress; // 0..1, oscillates from _floatCtrl

  _ParticlePainter({required this.progress});

  // Pre-defined particle positions and properties (deterministic, no random)
  static const _particles = [
    // (xPct, yPct, radius, colorIndex, speedFactor, phaseFactor)
    (0.12, 0.08, 2.5, 0, 1.0, 0.0),
    (0.88, 0.15, 1.8, 1, 0.7, 0.5),
    (0.06, 0.55, 2.0, 2, 1.2, 1.0),
    (0.94, 0.42, 1.5, 0, 0.8, 1.5),
    (0.50, 0.85, 2.2, 3, 0.9, 2.0),
    (0.75, 0.72, 1.6, 1, 1.1, 2.5),
    (0.20, 0.35, 1.3, 2, 0.6, 3.0),
    (0.65, 0.05, 1.8, 3, 1.0, 0.8),
    (0.35, 0.65, 1.4, 0, 0.85, 1.8),
    (0.82, 0.88, 2.0, 2, 0.75, 2.2),
  ];

  static const _colors = [
    Color(0x40FF6B6B), // coral
    Color(0x30FBBF24), // amber
    Color(0x307C3AED), // indigo
    Color(0x3006D6A0), // sage
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final (xPct, yPct, radius, colorIdx, speed, phase) in _particles) {
      final drift = math.sin(progress * math.pi * speed + phase) * 6;
      final driftY = math.cos(progress * math.pi * speed * 0.7 + phase) * 4;
      final x = size.width * xPct + drift;
      final y = size.height * yPct + driftY;
      // Gentle pulse
      final r = radius + math.sin(progress * math.pi * 2 + phase) * 0.4;

      paint.color = _colors[colorIdx];
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
}
