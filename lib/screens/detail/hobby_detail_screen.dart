import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/hobby.dart';
import '../../providers/hobby_provider.dart';
import '../../providers/user_provider.dart';
import '../../components/try_today_button.dart';
import '../../components/glass_card.dart';
import '../../components/pro_upgrade_sheet.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_icons.dart';
import '../../theme/app_typography.dart';
import '../../theme/spacing.dart';
import '../../theme/motion.dart';

/// Full hobby detail — cinematic hero, glass card sections, staggered reveals.
class HobbyDetailScreen extends ConsumerStatefulWidget {
  final String hobbyId;

  const HobbyDetailScreen({super.key, required this.hobbyId});

  @override
  ConsumerState<HobbyDetailScreen> createState() => _HobbyDetailScreenState();
}

class _HobbyDetailScreenState extends ConsumerState<HobbyDetailScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;
  bool _showBestValue = false;

  late final AnimationController _entryController;
  late final Animation<double> _overlayOpacity;
  late final Animation<double> _detailsOpacity;
  late final Animation<Offset> _detailsSlide;

  /// Stagger controller for below-fold glass cards
  late final AnimationController _staggerController;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _overlayOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.05, 0.65, curve: Curves.easeOut),
      ),
    );

    _detailsOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.15, 0.7, curve: Curves.easeOut),
      ),
    );
    _detailsSlide = Tween<Offset>(
      begin: const Offset(0, 8),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: Interval(0.15, 0.8, curve: Motion.heroCurve),
      ),
    );

    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _entryController.forward();
    // Delay stagger until hero is mostly done
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _staggerController.forward();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _entryController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  void _onScroll() {
    setState(() => _scrollOffset = _scrollController.offset);
  }

  double get _heroParallax {
    return (_scrollOffset * Motion.parallaxFactor)
        .clamp(0.0, Motion.maxParallaxOffset);
  }

  /// Build a staggered fade+slide animation for card at [index] (0-based).
  Animation<double> _cardOpacity(int index) {
    final start = (index * 0.12).clamp(0.0, 0.7);
    final end = (start + 0.4).clamp(0.0, 1.0);
    return Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: Interval(start, end, curve: Curves.easeOut),
      ),
    );
  }

  Animation<Offset> _cardSlide(int index) {
    final start = (index * 0.12).clamp(0.0, 0.7);
    final end = (start + 0.4).clamp(0.0, 1.0);
    return Tween<Offset>(
      begin: const Offset(0, 16),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: Interval(start, end, curve: Curves.easeOut),
      ),
    );
  }

  Widget _staggeredCard(int index, Widget child) {
    return AnimatedBuilder(
      animation: _staggerController,
      builder: (context, _) {
        return Transform.translate(
          offset: _cardSlide(index).value,
          child: Opacity(
            opacity: _cardOpacity(index).value,
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hobbyAsync = ref.watch(hobbyByIdProvider(widget.hobbyId));
    final hobby = hobbyAsync.valueOrNull;
    if (hobby == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: hobbyAsync.isLoading
              ? const CircularProgressIndicator()
              : Text('Hobby not found', style: AppTypography.body),
        ),
      );
    }

    final prefs = ref.watch(userPreferencesProvider);
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(child: _buildHeroImage(context, hobby)),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                    24,
                    0,
                    24,
                    MediaQuery.of(context).padding.bottom +
                        Spacing.scrollBottomPadding),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Specs middot line
                    const SizedBox(height: 20),
                    _buildSpecsLine(hobby),
                    const SizedBox(height: 24),

                    // 1. "Why this fits you" glass card
                    _staggeredCard(0, _buildWhyFitsYou(hobby, prefs)),
                    const SizedBox(height: 16),

                    // 2. "Start in 20 minutes" glass card
                    _staggeredCard(1, _buildStartIn20(hobby)),
                    const SizedBox(height: 16),

                    // 3. "What to expect" — 4-week roadmap preview
                    _staggeredCard(2, _buildWhatToExpect(hobby)),
                    const SizedBox(height: 16),

                    // 3b. "Why people stop" — pitfalls / quitting reasons
                    if (hobby.pitfalls.isNotEmpty ||
                        hobby.quittingReasons.isNotEmpty) ...[
                      _staggeredCard(3, _buildWhyPeopleStop(hobby)),
                      const SizedBox(height: 16),
                    ],

                    // 4. Starter Kit glass card
                    _staggeredCard(4, _buildStarterKit(hobby)),
                    const SizedBox(height: 16),

                    // 5. Coach teaser
                    _staggeredCard(5, _buildCoachTeaser()),
                    const SizedBox(height: 16),

                    // 6. Quick links
                    _staggeredCard(6, _buildQuickLinks()),
                  ]),
                ),
              ),
            ],
          ),

          // Header: back + title + share
          Positioned(
            top: topPad + 8,
            left: 16,
            right: 16,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: 0.35),
                    ),
                    child: const Icon(Icons.arrow_back_rounded,
                        size: 20, color: Colors.white),
                  ),
                ),
                const Spacer(),
                // Save / bookmark
                _SaveButton(hobbyId: widget.hobbyId),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: 0.35),
                    ),
                    child:
                        Icon(AppIcons.share, size: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          // Floating CTA at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
              decoration: const BoxDecoration(
                gradient: Spacing.ctaFadeGradient,
              ),
              child: SafeArea(
                top: false,
                child: TryTodayButton(
                  text: 'Start with the basics',
                  onPressed: () {
                    final canStart = ref.read(canStartHobbyProvider(widget.hobbyId));
                    if (!canStart) {
                      showProUpgrade(
                        context,
                        'Free users can have one active hobby. Upgrade to Pro for unlimited.',
                      );
                      return;
                    }
                    context.push('/quickstart/${widget.hobbyId}');
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  //  HERO IMAGE — 50% screen height
  // ═══════════════════════════════════════════════════════

  Widget _buildHeroImage(BuildContext context, Hobby hobby) {
    final screenH = MediaQuery.of(context).size.height;
    final heroH = screenH * 0.50;

    return SizedBox(
      height: heroH,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRect(
            child: Hero(
              tag: 'hobby_image_${hobby.id}',
              flightShuttleBuilder: (flightContext, animation, direction,
                  fromHeroContext, toHeroContext) {
                final Hero toHero = toHeroContext.widget as Hero;
                final radiusTween = Tween<double>(
                  begin: direction == HeroFlightDirection.push
                      ? Spacing.radiusCard
                      : 0,
                  end: direction == HeroFlightDirection.push
                      ? 0
                      : Spacing.radiusCard,
                );
                return AnimatedBuilder(
                  animation: animation,
                  child: toHero.child,
                  builder: (context, child) {
                    final r = radiusTween.evaluate(animation);
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(r),
                      child: child,
                    );
                  },
                );
              },
              child: Transform.translate(
                offset: Offset(0, -_heroParallax),
                child: CachedNetworkImage(
                  imageUrl: hobby.imageUrl,
                  fit: BoxFit.cover,
                  memCacheWidth: 800,
                  height: heroH + Motion.maxParallaxOffset,
                  width: double.infinity,
                  placeholder: (_, __) =>
                      Container(color: AppColors.surfaceElevated),
                  errorWidget: (_, __, ___) => Container(
                    color: AppColors.surfaceElevated,
                    child: const Icon(Icons.image,
                        size: 40, color: AppColors.textWhisper),
                  ),
                ),
              ),
            ),
          ),

          // Gradient overlay — fade to black at bottom
          AnimatedBuilder(
            animation: _overlayOpacity,
            builder: (context, child) {
              return Opacity(
                opacity: _overlayOpacity.value,
                child: child,
              );
            },
            child: const DecoratedBox(
              decoration:
                  BoxDecoration(gradient: Spacing.heroOverlayGradient),
            ),
          ),

          // Bottom text: category overline + title + hook
          Positioned(
            bottom: 20,
            left: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category overline
                AnimatedBuilder(
                  animation: _detailsOpacity,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: _detailsSlide.value,
                      child: Opacity(
                        opacity: _detailsOpacity.value,
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    hobby.category.toUpperCase(),
                    style: AppTypography.monoBadgeSmall.copyWith(
                      color: AppColors.textMuted,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Title
                Hero(
                  tag: 'hobby_title_${hobby.id}',
                  flightShuttleBuilder: (flightContext, animation, direction,
                      fromHeroContext, toHeroContext) {
                    final fromChild =
                        (fromHeroContext.widget as Hero).child;
                    final toChild =
                        (toHeroContext.widget as Hero).child;
                    return AnimatedBuilder(
                      animation: animation,
                      builder: (context, _) {
                        return Stack(
                          children: [
                            Opacity(
                                opacity: 1 - animation.value,
                                child: fromChild),
                            Opacity(
                                opacity: animation.value,
                                child: toChild),
                          ],
                        );
                      },
                    );
                  },
                  child: Material(
                    color: Colors.transparent,
                    child:
                        Text(hobby.title, style: AppTypography.hero),
                  ),
                ),
                const SizedBox(height: 6),

                // Hook line
                AnimatedBuilder(
                  animation: _detailsOpacity,
                  builder: (context, child) => Opacity(
                    opacity: _detailsOpacity.value,
                    child: child,
                  ),
                  child: Text(
                    hobby.hook,
                    style: AppTypography.body.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  //  SPECS MIDDOT LINE
  // ═══════════════════════════════════════════════════════

  Widget _buildSpecsLine(Hobby hobby) {
    final specs = <String>[
      hobby.costText,
      hobby.timeText,
      hobby.difficultyText,
    ];
    return Row(
      children: [
        for (int i = 0; i < specs.length; i++) ...[
          if (i > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text('\u00B7',
                  style: AppTypography.caption
                      .copyWith(color: AppColors.textMuted)),
            ),
          Text(
            specs[i],
            style: AppTypography.caption.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ],
    );
  }

  // ═══════════════════════════════════════════════════════
  //  1. WHY THIS FITS YOU
  // ═══════════════════════════════════════════════════════

  Widget _buildWhyFitsYou(Hobby hobby, UserPreferences prefs) {
    final reasons = _generateFitReasons(hobby, prefs);

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.favorite_outline_rounded,
                  size: 16, color: AppColors.coral),
              const SizedBox(width: 8),
              Text('Why this fits you',
                  style: AppTypography.sansLabel.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  )),
            ],
          ),
          const SizedBox(height: 14),
          ...reasons.map((reason) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Icon(Icons.check_rounded,
                          size: 14, color: AppColors.sage),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        reason,
                        style: AppTypography.sansBodySmall
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  List<String> _generateFitReasons(Hobby hobby, UserPreferences prefs) {
    final reasons = <String>[];

    // Budget fit
    final budgetLabels = ['free', 'under CHF 30', 'under CHF 75', 'under CHF 150', 'flexible'];
    if (prefs.budgetLevel < budgetLabels.length) {
      reasons.add('Fits your ${budgetLabels[prefs.budgetLevel]} budget');
    }

    // Time fit
    reasons.add('Works in ${prefs.hoursPerWeek}h/week');

    // Solo/social fit
    if (prefs.preferSocial) {
      reasons.add('Great for meeting people');
    } else {
      reasons.add('Perfect for solo sessions at home');
    }

    // Hobby-specific whyLove (truncated)
    if (hobby.whyLove.isNotEmpty) {
      final truncated = hobby.whyLove.length > 60
          ? '${hobby.whyLove.substring(0, 60)}...'
          : hobby.whyLove;
      reasons.add(truncated);
    }

    return reasons.take(4).toList();
  }

  // ═══════════════════════════════════════════════════════
  //  2. START IN 20 MINUTES
  // ═══════════════════════════════════════════════════════

  Widget _buildStartIn20(Hobby hobby) {
    final essentialKit = hobby.starterKit.where((k) => !k.isOptional).take(2).toList();
    final firstStep = hobby.roadmapSteps.isNotEmpty ? hobby.roadmapSteps.first : null;

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bolt_rounded, size: 16, color: AppColors.coral),
              const SizedBox(width: 8),
              Text('Start in 20 minutes',
                  style: AppTypography.sansLabel.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  )),
            ],
          ),
          const SizedBox(height: 14),

          // What to buy
          if (essentialKit.isNotEmpty) ...[
            Text('Buy only these:',
                style: AppTypography.sansTiny
                    .copyWith(color: AppColors.textMuted)),
            const SizedBox(height: 8),
            ...essentialKit.asMap().entries.map((entry) {
              final item = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppColors.coral.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          '${entry.key + 1}',
                          style: AppTypography.monoBadgeSmall.copyWith(
                            color: AppColors.coral,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item.name,
                        style: AppTypography.sansBodySmall
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                    if (item.cost > 0)
                      Text('CHF ${item.cost}',
                          style: AppTypography.monoBadgeSmall.copyWith(
                            color: AppColors.textMuted,
                          )),
                    if (item.cost == 0)
                      Text('FREE',
                          style: AppTypography.monoBadgeSmall.copyWith(
                            color: AppColors.sage,
                          )),
                  ],
                ),
              );
            }),
            const SizedBox(height: 12),
          ],

          // First tiny session
          if (firstStep != null) ...[
            Text('Your first tiny session:',
                style: AppTypography.sansTiny
                    .copyWith(color: AppColors.textMuted)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.play_circle_outline_rounded,
                      size: 20, color: AppColors.coral),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(firstStep.title,
                            style: AppTypography.sansLabel.copyWith(
                              color: AppColors.textPrimary,
                            )),
                        Text(
                          '${firstStep.estimatedMinutes} min',
                          style: AppTypography.sansTiny
                              .copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 10),
          Text(
            'Ignore everything else for now.',
            style: AppTypography.sansTiny.copyWith(
              color: AppColors.textMuted,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  //  3. WHAT TO EXPECT — 4-week preview
  // ═══════════════════════════════════════════════════════

  static const _weekPlan = [
    (
      title: 'Week 1 — Try it',
      desc: 'Do one tiny session. No pressure, no gear obsession.',
      icon: Icons.play_arrow_rounded,
    ),
    (
      title: 'Week 2 — Repeat it',
      desc: 'Do it again. Same thing, slightly longer.',
      icon: Icons.refresh_rounded,
    ),
    (
      title: 'Week 3 — Reduce friction',
      desc: 'Simplify your setup. Remove what annoys you.',
      icon: Icons.auto_fix_high_rounded,
    ),
    (
      title: 'Week 4 — Decide',
      desc: 'Keep going, switch hobbies, or level up.',
      icon: Icons.flag_rounded,
    ),
  ];

  Widget _buildWhatToExpect(Hobby hobby) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_month_outlined,
                  size: 16, color: AppColors.coral),
              const SizedBox(width: 8),
              Text('What to expect',
                  style: AppTypography.sansLabel.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  )),
            ],
          ),
          const SizedBox(height: 14),
          ...List.generate(_weekPlan.length, (i) {
            final week = _weekPlan[i];
            final isLast = i == _weekPlan.length - 1;
            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.coral.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(week.icon,
                            size: 14, color: AppColors.coral),
                      ),
                      if (!isLast)
                        Container(
                          width: 1,
                          height: 20,
                          color: AppColors.border,
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(week.title,
                            style: AppTypography.sansLabel.copyWith(
                              color: AppColors.textPrimary,
                            )),
                        const SizedBox(height: 2),
                        Text(week.desc,
                            style: AppTypography.sansTiny.copyWith(
                              color: AppColors.textSecondary,
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  //  3b. WHY PEOPLE STOP
  // ═══════════════════════════════════════════════════════

  Widget _buildWhyPeopleStop(Hobby hobby) {
    // Use quittingReasons if available, otherwise fall back to pitfalls
    final reasons = hobby.quittingReasons.isNotEmpty
        ? hobby.quittingReasons
        : hobby.pitfalls;
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded,
                  size: 16, color: AppColors.textMuted),
              const SizedBox(width: 8),
              Text('Why people stop',
                  style: AppTypography.sansLabel.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  )),
            ],
          ),
          const SizedBox(height: 14),
          ...reasons.map((reason) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(top: 6),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        reason,
                        style: AppTypography.sansBodySmall
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 4),
          Text(
            'Knowing this helps you avoid the common traps.',
            style: AppTypography.sansTiny.copyWith(
              color: AppColors.textMuted,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  //  4. STARTER KIT
  // ═══════════════════════════════════════════════════════

  Widget _buildStarterKit(Hobby hobby) {
    final essentialItems =
        hobby.starterKit.where((k) => !k.isOptional).toList();
    final allItems = hobby.starterKit;
    final displayItems = _showBestValue ? allItems : essentialItems;
    final total =
        displayItems.fold(0, (sum, item) => sum + item.cost);

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shopping_bag_outlined,
                  size: 16, color: AppColors.coral),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Starter kit',
                    style: AppTypography.sansLabel.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    )),
              ),
              if (total > 0)
                Text('~ CHF $total',
                    style: AppTypography.monoBadge
                        .copyWith(color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 12),

          // Minimum / Best Value toggle
          if (allItems.length > essentialItems.length)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  _KitToggle(
                    label: 'Minimum',
                    selected: !_showBestValue,
                    onTap: () => setState(() => _showBestValue = false),
                  ),
                  const SizedBox(width: 8),
                  _KitToggle(
                    label: 'Best value',
                    selected: _showBestValue,
                    onTap: () => setState(() => _showBestValue = true),
                  ),
                ],
              ),
            ),

          // Kit items
          ...displayItems.map((item) => _buildKitRow(item)),

          // Shopping checklist link
          if (hobby.starterKit.isNotEmpty) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => context.push('/shopping/${widget.hobbyId}'),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(AppIcons.shoppingList,
                      size: 14, color: AppColors.coral),
                  const SizedBox(width: 6),
                  Text('Open Shopping Checklist',
                      style: AppTypography.sansTiny
                          .copyWith(color: AppColors.coral)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildKitRow(KitItem item) {
    return GestureDetector(
      onTap: () => _openAffiliateLink(item),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 44,
                height: 44,
                child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: item.imageUrl!,
                        fit: BoxFit.cover,
                        memCacheWidth: 88,
                        placeholder: (_, __) =>
                            Container(color: AppColors.surfaceElevated),
                        errorWidget: (_, __, ___) => Container(
                          color: AppColors.surfaceElevated,
                          child: const Icon(Icons.image_outlined,
                              size: 16, color: AppColors.textWhisper),
                        ),
                      )
                    : Container(
                        color: AppColors.surfaceElevated,
                        child: Icon(
                          item.isOptional
                              ? Icons.add_circle_outline
                              : Icons.check_circle_outline,
                          size: 18,
                          color: AppColors.textWhisper,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name,
                      style: AppTypography.sansBodySmall.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  if (item.isOptional)
                    Text('Optional',
                        style: AppTypography.sansTiny
                            .copyWith(color: AppColors.textMuted)),
                ],
              ),
            ),
            if (item.cost > 0)
              Text('CHF ${item.cost}',
                  style: AppTypography.monoBadge.copyWith(
                    color: AppColors.coral,
                    fontWeight: FontWeight.w700,
                  ))
            else
              Text('FREE',
                  style: AppTypography.monoBadge.copyWith(
                    color: AppColors.sage,
                    fontWeight: FontWeight.w700,
                  )),
            const SizedBox(width: 6),
            const Icon(Icons.open_in_new_rounded,
                size: 12, color: AppColors.textWhisper),
          ],
        ),
      ),
    );
  }

  Future<void> _openAffiliateLink(KitItem item) async {
    final url = item.affiliateUrl ??
        'https://www.amazon.de/s?k=${Uri.encodeComponent(item.name)}&tag=trysomething-21';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // ═══════════════════════════════════════════════════════
  //  5. COACH TEASER
  // ═══════════════════════════════════════════════════════

  Widget _buildCoachTeaser() {
    return GlassCard(
      onTap: () => context.push('/coach/${widget.hobbyId}'),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.coral.withValues(alpha: 0.12),
            ),
            child: const Icon(Icons.auto_awesome,
                size: 20, color: AppColors.coral),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Want help starting?',
                    style: AppTypography.sansLabel.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    )),
                const SizedBox(height: 2),
                Text('Ask the coach without overthinking it.',
                    style: AppTypography.sansTiny.copyWith(
                      color: AppColors.textSecondary,
                    )),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              size: 20, color: AppColors.textMuted),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  //  6. QUICK LINKS
  // ═══════════════════════════════════════════════════════

  Widget _buildQuickLinks() {
    return Row(
      children: [
        Expanded(
          child: GlassCard(
            onTap: () => context.push('/cost/${widget.hobbyId}'),
            padding: const EdgeInsets.all(14),
            borderRadius: 14,
            child: Row(
              children: [
                Icon(AppIcons.badgeCost,
                    size: 16, color: AppColors.coral),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Cost Breakdown',
                          style: AppTypography.caption.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          )),
                      Text('Year 1 projection',
                          style: AppTypography.sansTiny
                              .copyWith(color: AppColors.textMuted)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GlassCard(
            onTap: () => context.push('/faq/${widget.hobbyId}'),
            padding: const EdgeInsets.all(14),
            borderRadius: 14,
            child: Row(
              children: [
                const Icon(Icons.help_outline_rounded,
                    size: 16, color: AppColors.textMuted),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Beginner FAQ',
                          style: AppTypography.caption.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          )),
                      Text('Common questions',
                          style: AppTypography.sansTiny
                              .copyWith(color: AppColors.textMuted)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════
//  KIT TOGGLE PILL
// ═══════════════════════════════════════════════════════

class _KitToggle extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _KitToggle({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Motion.fast,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.coral.withValues(alpha: 0.12)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(Spacing.radiusBadge),
          border: Border.all(
            color: selected ? AppColors.coral : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.sansTiny.copyWith(
            color: selected ? AppColors.coral : AppColors.textSecondary,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  SAVE / BOOKMARK BUTTON (detail header)
// ═══════════════════════════════════════════════════════

class _SaveButton extends ConsumerWidget {
  final String hobbyId;
  const _SaveButton({required this.hobbyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSaved = ref.watch(isHobbySavedProvider(hobbyId));

    return GestureDetector(
      onTap: () {
        ref.read(userHobbiesProvider.notifier).toggleSave(hobbyId);
      },
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withValues(alpha: 0.35),
        ),
        child: Icon(
          isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
          size: 18,
          color: isSaved ? AppColors.coral : Colors.white,
        ),
      ),
    );
  }
}
