import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../models/hobby.dart';
import '../../core/hobby_match.dart';
import '../../theme/category_ui.dart';
import '../../providers/hobby_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_icons.dart';
import '../../theme/app_typography.dart';
import '../../theme/motion.dart';
import '../../theme/spacing.dart';
import '../../providers/subscription_provider.dart';

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
  final IconData icon;
  final Color color;
  const _VibeItem(this.label, this.key, this.icon, this.color);
}

final _vibeItems = [
  _VibeItem('Creative', 'creative', AppIcons.catCreative, AppColors.catCreative),
  _VibeItem('Relaxing', 'relaxing', MdiIcons.meditation, AppColors.sage),
  _VibeItem('Social', 'social', AppIcons.catSocial, AppColors.catSocial),
  _VibeItem('Active', 'physical', MdiIcons.flash, AppColors.catMusic),
  _VibeItem('Intellectual', 'intellectual', MdiIcons.bookOpenVariant, AppColors.amber),
  _VibeItem('Outdoors', 'outdoors', AppIcons.catOutdoors, AppColors.catOutdoors),
  _VibeItem('Tech', 'technical', MdiIcons.memory, AppColors.catCollecting),
  _VibeItem('Culinary', 'culinary', AppIcons.catFood, AppColors.catFood),
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
    setState(() {
      _currentPage = 2;
      _matchedHobbies = _computeMatchedHobbies();
    });
    _pageController.animateToPage(2,
        duration: Motion.onboardingPage, curve: Motion.normalCurve);
    _page3EntryCtrl.forward();
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

    // Fire-and-forget: sync preferences to server
    final repo = ref.read(authRepositoryProvider);
    repo.updatePreferences(
      hoursPerWeek: _hours.round(),
      budgetLevel: _budget,
      preferSocial: _social,
      vibes: _vibes,
    );

    context.go('/feed');
  }

  // ── Matching ──

  List<Hobby> _computeMatchedHobbies() {
    final all = ref.read(hobbyListProvider).valueOrNull ?? [];
    if (all.isEmpty) return [];

    return computeMatchedHobbies(
      allHobbies: all,
      userHours: _hours,
      userBudgetLevel: _budget,
      userPrefersSocial: _social,
      userVibes: _vibes,
    );
  }

  // ── Build ──

  @override
  Widget build(BuildContext context) {
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
                  if (_currentPage < 2)
                    GestureDetector(
                      onTap: _skip,
                      child: Text('Skip',
                          style: AppTypography.sansLabel
                              .copyWith(color: AppColors.driftwood)),
                    )
                  else
                    const SizedBox(width: 24),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 16),
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
                      style: AppTypography.sansButton),
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
            color: isSelected ? AppColors.sage : Colors.transparent,
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
                  Icon(item.icon, size: 32, color: item.color),
                  const SizedBox(height: 10),
                  Text(
                    item.label,
                    style: AppTypography.sansLabel.copyWith(
                      color: isSelected
                          ? AppColors.nearBlack
                          : AppColors.driftwood,
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
                    color: AppColors.sage,
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
  final Set<String> vibes;
  final double hours;
  final bool social;

  const _ReadyPage({
    required this.entryCtrl,
    required this.matchedHobbies,
    required this.vibes,
    required this.hours,
    required this.social,
  });

  @override
  ConsumerState<_ReadyPage> createState() => _ReadyPageState();
}

class _ReadyPageState extends ConsumerState<_ReadyPage>
    with SingleTickerProviderStateMixin {
  bool _aiGenFired = false;
  late AnimationController _floatCtrl;

  // Card positions: (leftPct, topPct, width, height)
  static const _cardLayouts = [
    (0.04, 0.04, 140.0, 160.0), // top-left
    (0.52, 0.06, 155.0, 170.0), // top-right
    (0.00, 0.42, 170.0, 180.0), // bottom-left (largest — top match)
    (0.50, 0.48, 145.0, 160.0), // bottom-right
  ];

  // Match percentages per card position
  static const _matchPcts = [92, 87, 98, 84];

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

    // Fire AI generation for a personalized 4th hobby
    _fireAiGeneration();
  }

  void _fireAiGeneration() {
    if (_aiGenFired) return;
    // Only fire AI generation for Pro/trial users
    if (!ref.read(isProProvider)) return;
    _aiGenFired = true;
    final vibeList = widget.vibes.join(', ');
    final socialPref = widget.social ? 'social/group' : 'solo';
    final prompt =
        'Suggest a unique hobby for someone who likes $vibeList, '
        'has ${widget.hours.round()}h/week, prefers $socialPref activities';
    Future.microtask(() {
      ref.read(generationProvider.notifier).generate(prompt);
    });
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final genState = ref.watch(generationProvider);
    final aiHobby = genState.status == GenerationStatus.success
        ? genState.hobby
        : null;

    // 3 pre-seeded + optionally 1 AI-generated
    final topMatches = widget.matchedHobbies.take(3).toList();

    return AnimatedBuilder(
      animation: Listenable.merge([widget.entryCtrl, _floatCtrl]),
      builder: (context, _) {
        final v = widget.entryCtrl.value;
        final badgeOp = _iv(v, 0.0, 0.2);
        final cardsOp = _iv(v, 0.1, 0.4);
        final titleOp = _iv(v, 0.4, 0.65);
        final titleScale = _iv(v, 0.4, 0.65, Curves.easeOutCubic);
        final bodyOp = _iv(v, 0.55, 0.8);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              // "Curated for you" badge
              Align(
                alignment: Alignment.centerRight,
                child: Opacity(
                  opacity: badgeOp,
                  child: Container(
                    margin: const EdgeInsets.only(top: 8, right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.sagePale,
                      borderRadius:
                          BorderRadius.circular(Spacing.radiusBadge),
                      border:
                          Border.all(color: AppColors.sage.withAlpha(60)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(MdiIcons.autoFix,
                            size: 14, color: AppColors.sage),
                        const SizedBox(width: 4),
                        Text('Curated for you',
                            style: AppTypography.sansCaption.copyWith(
                                color: AppColors.sage,
                                fontWeight: FontWeight.w600)),
                      ],
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
                          // Decorative dots
                          _dot(areaW * 0.85, areaH * 0.02, 6,
                              AppColors.coral),
                          _dot(areaW * 0.08, areaH * 0.30, 4,
                              AppColors.warmGray),
                          _dot(areaW * 0.92, areaH * 0.50, 5,
                              AppColors.amber),
                          _dot(areaW * 0.45, areaH * 0.75, 3,
                              AppColors.warmGray),

                          // Hobby cards (3 pre-seeded)
                          for (int i = 0;
                              i < 3 && i < topMatches.length;
                              i++)
                            _buildFloatingCard(
                                topMatches[i], areaW, areaH, i, v, false),

                          // 4th card — AI generated or placeholder
                          if (aiHobby != null)
                            _buildFloatingCard(
                                aiHobby, areaW, areaH, 3, v, true)
                          else
                            _buildAiPlaceholderCard(
                                areaW, areaH, v, genState.status),
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
      Hobby hobby, double areaW, double areaH, int i, double entryV, bool isAi) {
    final (leftPct, topPct, cardW, cardH) = _cardLayouts[i];
    final cardOp =
        _iv(entryV, 0.1 + i * 0.06, 0.35 + i * 0.06);
    final cardSlide =
        _iv(entryV, 0.1 + i * 0.06, 0.35 + i * 0.06, Curves.easeOutCubic);

    // Subtle floating bob per card
    final (amp, phase) = _floatParams[i];
    final floatOffset = math.sin(_floatCtrl.value * math.pi + phase) * amp;
    final matchPct = _matchPcts[i];
    final isTopMatch = i == 2; // bottom-left card is the top match

    return Positioned(
      left: areaW * leftPct,
      top: areaH * topPct + 12 * (1 - cardSlide) + floatOffset,
      child: Opacity(
        opacity: cardOp,
        child: Container(
          width: cardW,
          height: cardH,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isTopMatch
                  ? AppColors.coral.withAlpha(100)
                  : AppColors.sandDark.withAlpha(120),
              width: isTopMatch ? 1.5 : 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(40),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              color: AppColors.sand,
              child: Stack(
                children: [
                  // Centered icon + label
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(hobby.catIcon,
                            size: 36, color: hobby.catColor),
                        const SizedBox(height: 10),
                        Text(
                          hobby.category.toUpperCase(),
                          style: AppTypography.sansLabel.copyWith(
                            color: AppColors.nearBlack,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Match % badge
                  if (isTopMatch)
                    Positioned(
                      bottom: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.sage,
                          borderRadius:
                              BorderRadius.circular(Spacing.radiusBadge),
                        ),
                        child: Text(
                          '$matchPct% Match',
                          style: AppTypography.monoBadgeSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                  // AI sparkle badge or match % badge
                  if (isAi)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.indigo,
                          borderRadius:
                              BorderRadius.circular(Spacing.radiusBadge),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(MdiIcons.autoFix,
                                size: 10, color: Colors.white),
                            const SizedBox(width: 3),
                            Text(
                              'AI',
                              style: AppTypography.monoBadgeSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (!isTopMatch)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(80),
                          borderRadius:
                              BorderRadius.circular(Spacing.radiusBadge),
                        ),
                        child: Text(
                          '$matchPct%',
                          style: AppTypography.monoBadgeSmall.copyWith(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                  // "Made for you" label on AI card
                  if (isAi)
                    Positioned(
                      bottom: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.indigo,
                          borderRadius:
                              BorderRadius.circular(Spacing.radiusBadge),
                        ),
                        child: Text(
                          'Made for you',
                          style: AppTypography.monoBadgeSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
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

  Widget _buildAiPlaceholderCard(
      double areaW, double areaH, double entryV, GenerationStatus status) {
    const i = 3;
    final (leftPct, topPct, cardW, cardH) = _cardLayouts[i];
    final cardOp = _iv(entryV, 0.1 + i * 0.06, 0.35 + i * 0.06);
    final cardSlide =
        _iv(entryV, 0.1 + i * 0.06, 0.35 + i * 0.06, Curves.easeOutCubic);
    final (amp, phase) = _floatParams[i];
    final floatOffset = math.sin(_floatCtrl.value * math.pi + phase) * amp;
    final isLoading = status == GenerationStatus.generating;

    return Positioned(
      left: areaW * leftPct,
      top: areaH * topPct + 12 * (1 - cardSlide) + floatOffset,
      child: Opacity(
        opacity: cardOp,
        child: Container(
          width: cardW,
          height: cardH,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.indigo.withAlpha(100),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(40),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              color: AppColors.sand,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isLoading) ...[
                      SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.indigo.withAlpha(180)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Finding yours...',
                        style: AppTypography.sansCaption.copyWith(
                          color: AppColors.driftwood,
                          fontSize: 11,
                        ),
                      ),
                    ] else ...[
                      if (ref.watch(isProProvider)) ...[
                        Icon(MdiIcons.autoFix,
                            size: 32, color: AppColors.indigo),
                        const SizedBox(height: 10),
                        Text(
                          'AI PICK',
                          style: AppTypography.sansLabel.copyWith(
                            color: AppColors.nearBlack,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ] else ...[
                        Icon(Icons.lock_rounded,
                            size: 28, color: AppColors.driftwood.withAlpha(120)),
                        const SizedBox(height: 10),
                        Text(
                          'PRO',
                          style: AppTypography.sansLabel.copyWith(
                            color: AppColors.driftwood,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
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
