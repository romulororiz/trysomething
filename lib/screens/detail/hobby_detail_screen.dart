import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/hobby.dart';
import '../../providers/hobby_provider.dart';
import '../../providers/user_provider.dart';
import '../../components/app_background.dart';
import '../../components/try_today_button.dart';
import '../../components/glass_card.dart';
import '../../components/starter_kit_card.dart';
import '../../components/hobby_quick_links.dart';
import '../../components/logo_loader.dart';
import '../../components/pro_upgrade_sheet.dart';
import '../../components/share_card.dart';
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

  late final AnimationController _entryController;
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
        curve: const Interval(0.15, 0.8, curve: Motion.heroCurve),
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
      if (hobbyAsync.isLoading) {
        return const Scaffold(
          backgroundColor: Colors.transparent,
          body: AppBackground(tintTopLeft: false, child: LogoLoader()),
        );
      }
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: AppBackground(tintTopLeft: false, child: Center(child: Text('Hobby not found', style: AppTypography.body))),
      );
    }

    final prefs = ref.watch(userPreferencesProvider);
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        tintTopLeft: false,
        child: Stack(
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
                    MediaQuery.of(context).padding.bottom + 110),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
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
                    _staggeredCard(4, StarterKitCard(hobby: hobby)),
                    const SizedBox(height: 16),

                    // 5. Coach teaser
                    _staggeredCard(5, _buildCoachTeaser()),
                    const SizedBox(height: 16),

                    // 6. Quick links
                    _staggeredCard(6, HobbyQuickLinks(hobbyId: widget.hobbyId)),
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
                  onTap: () => shareHobby(context, hobby),
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
                        'You\'re already working on a hobby. Pro lets you explore multiple hobbies at once.',
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
          // Hero image — ShaderMask fades image to transparent at bottom (same as home hero)
          ClipRect(
            child: Hero(
              tag: 'hobby_image_${hobby.id}',
              flightShuttleBuilder: (flightContext, animation, direction,
                  fromHeroContext, toHeroContext) {
                final Hero toHero = toHeroContext.widget as Hero;
                final radiusTween = Tween<double>(
                  begin: direction == HeroFlightDirection.push ? Spacing.radiusCard : 0,
                  end: direction == HeroFlightDirection.push ? 0 : Spacing.radiusCard,
                );
                return AnimatedBuilder(
                  animation: animation,
                  child: toHero.child,
                  builder: (context, child) => ClipRRect(
                    borderRadius: BorderRadius.circular(radiusTween.evaluate(animation)),
                    child: child,
                  ),
                );
              },
              child: ShaderMask(
                shaderCallback: (rect) => const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white, Colors.white, Colors.transparent],
                  stops: [0.0, 0.4, 1.0],
                ).createShader(rect),
                blendMode: BlendMode.dstIn,
                child: Transform.translate(
                  offset: Offset(0, -_heroParallax),
                  child: CachedNetworkImage(
                    imageUrl: hobby.imageUrl,
                    fit: BoxFit.cover,
                    memCacheWidth: 800,
                    height: heroH + Motion.maxParallaxOffset,
                    width: double.infinity,
                    placeholder: (_, __) => Container(color: AppColors.surfaceElevated),
                    errorWidget: (_, __, ___) => Container(
                      color: AppColors.surfaceElevated,
                      child: const Icon(Icons.image, size: 40, color: AppColors.textWhisper),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Bottom text: category + title + hook + specs
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: AnimatedBuilder(
              animation: _detailsOpacity,
              builder: (context, child) => Transform.translate(
                offset: _detailsSlide.value,
                child: Opacity(opacity: _detailsOpacity.value, child: child),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hobby.category.toUpperCase(),
                    style: AppTypography.monoBadgeSmall.copyWith(
                      color: AppColors.textMuted, letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 8),
                  Hero(
                    tag: 'hobby_title_${hobby.id}',
                    flightShuttleBuilder: (flightContext, animation, direction,
                        fromHeroContext, toHeroContext) {
                      final fromChild = (fromHeroContext.widget as Hero).child;
                      final toChild = (toHeroContext.widget as Hero).child;
                      return AnimatedBuilder(
                        animation: animation,
                        builder: (context, _) => Stack(children: [
                          Opacity(opacity: 1 - animation.value, child: fromChild),
                          Opacity(opacity: animation.value, child: toChild),
                        ]),
                      );
                    },
                    child: Material(
                      color: Colors.transparent,
                      child: Builder(builder: (_) {
                        final words = hobby.title.split(' ');
                        if (words.length <= 1) {
                          return Text(hobby.title, style: AppTypography.hero);
                        }
                        return Text.rich(TextSpan(children: [
                          TextSpan(
                            text: words.first,
                            style: AppTypography.hero.copyWith(color: AppColors.coral),
                          ),
                          TextSpan(
                            text: ' ${words.skip(1).join(' ')}',
                            style: AppTypography.hero,
                          ),
                        ]));
                      }),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    hobby.hook,
                    style: AppTypography.body.copyWith(color: AppColors.textSecondary, height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  // Specs on the overlay
                  Text(
                    '${hobby.costText}  ·  ${hobby.timeText}  ·  ${hobby.difficultyText}',
                    style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
              const Icon(Icons.favorite_outline_rounded,
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
              const Icon(Icons.bolt_rounded, size: 16, color: AppColors.coral),
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
                  const Icon(Icons.play_circle_outline_rounded,
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
              const Icon(Icons.calendar_month_outlined,
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
              const Icon(Icons.info_outline_rounded,
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
  //  5. COACH TEASER
  // ═══════════════════════════════════════════════════════

  Widget _buildCoachTeaser() {
    final hobby = ref.watch(hobbyByIdProvider(widget.hobbyId)).valueOrNull;
    final hobbyTitle = hobby?.title ?? 'this hobby';
    return GlassCard(
      onTap: () => context.push('/coach/${widget.hobbyId}', extra: {
        'message':
            'Help me start $hobbyTitle tonight. What\'s the easiest first step?',
        'mode': 'start',
        'autoSend': false,
      }),
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
                Text('Plan your first session',
                    style: AppTypography.sansLabel.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    )),
                const SizedBox(height: 2),
                Text('Get a tiny first-session plan, no experience needed.',
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

}

// ═══════════════════════════════════════════════════════
//  SAVE / BOOKMARK BUTTON (detail header)
// ═══════════════════════════════════════════════════════

class _SaveButton extends ConsumerStatefulWidget {
  final String hobbyId;
  const _SaveButton({required this.hobbyId});

  @override
  ConsumerState<_SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends ConsumerState<_SaveButton>
    with TickerProviderStateMixin {
  late AnimationController _popController;
  late Animation<double> _popScale;
  late AnimationController _burstController;
  late Animation<double> _burstRadius;
  late Animation<double> _burstOpacity;
  late AnimationController _particleController;
  late Animation<double> _particleProgress;

  static const int _particleCount = 7;
  static final List<Offset> _particleDirs = List.generate(_particleCount, (i) {
    final angle = (i / _particleCount) * 2 * math.pi - 0.3;
    return Offset(math.cos(angle), math.sin(angle));
  });

  @override
  void initState() {
    super.initState();
    _popController = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    _popScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.75), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 0.75, end: 1.30), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.30, end: 0.95), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(parent: _popController, curve: Curves.easeOut));
    _burstController = AnimationController(
        duration: const Duration(milliseconds: 400), vsync: this);
    _burstRadius = Tween<double>(begin: 0.0, end: 22.0).animate(
        CurvedAnimation(parent: _burstController, curve: Curves.easeOut));
    _burstOpacity = Tween<double>(begin: 0.7, end: 0.0).animate(
        CurvedAnimation(parent: _burstController, curve: Curves.easeOut));
    _particleController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    _particleProgress = CurvedAnimation(
        parent: _particleController, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _popController.dispose();
    _burstController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  void _handleTap(bool isSaved) {
    _popController.forward(from: 0);
    if (!isSaved) {
      _burstController.forward(from: 0);
      _particleController.forward(from: 0);
    }
    ref.read(userHobbiesProvider.notifier).toggleSave(widget.hobbyId);
  }

  @override
  Widget build(BuildContext context) {
    final isSaved = ref.watch(isHobbySavedProvider(widget.hobbyId));
    return GestureDetector(
      onTap: () => _handleTap(isSaved),
      child: SizedBox(
        width: 36,
        height: 36,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Circle background
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withValues(alpha: 0.35),
              ),
            ),
            // Burst ring
            if (isSaved || _burstController.isAnimating)
              AnimatedBuilder(
                animation: _burstController,
                builder: (_, __) => Container(
                  width: _burstRadius.value * 2,
                  height: _burstRadius.value * 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.coral
                          .withValues(alpha: _burstOpacity.value),
                      width: 2,
                    ),
                  ),
                ),
              ),
            // Particles
            AnimatedBuilder(
              animation: _particleProgress,
              builder: (_, __) {
                if (!_particleController.isAnimating &&
                    !_particleController.isCompleted) {
                  return const SizedBox.shrink();
                }
                final t = _particleProgress.value;
                if (t == 0) return const SizedBox.shrink();
                final opacity = (1.0 - t).clamp(0.0, 1.0);
                if (opacity < 0.05) return const SizedBox.shrink();
                return SizedBox(
                  width: 36,
                  height: 36,
                  child: CustomPaint(
                    painter: _HeartParticlePainter(
                      progress: t,
                      opacity: opacity,
                      directions: _particleDirs,
                    ),
                  ),
                );
              },
            ),
            // Icon
            ScaleTransition(
              scale: _popScale,
              child: Icon(
                isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                size: 18,
                color: isSaved ? AppColors.coral : Colors.white,
                shadows: const [Shadow(blurRadius: 8, color: Colors.black54)],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeartParticlePainter extends CustomPainter {
  final double progress;
  final double opacity;
  final List<Offset> directions;

  const _HeartParticlePainter({
    required this.progress,
    required this.opacity,
    required this.directions,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const maxDist = 18.0;
    for (int i = 0; i < directions.length; i++) {
      final dist = maxDist * progress;
      final pos = center + directions[i] * dist;
      final radius = 2.5 * (1.0 - progress * 0.5);
      canvas.drawCircle(
        pos,
        radius,
        Paint()
          ..color = (i.isEven
                  ? AppColors.coral
                  : AppColors.coral.withValues(alpha: opacity * 0.7))
              .withValues(alpha: opacity),
      );
    }
  }

  @override
  bool shouldRepaint(_HeartParticlePainter old) =>
      progress != old.progress || opacity != old.opacity;
}
