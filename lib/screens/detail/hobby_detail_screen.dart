import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/hobby.dart';
import '../../theme/category_ui.dart';
import '../../providers/hobby_provider.dart';
import '../../providers/user_provider.dart';
import '../../components/spec_badge.dart';
import '../../components/try_today_button.dart';
import '../../components/roadmap_step_tile.dart';
import '../../components/shared_widgets.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_icons.dart';
import '../../theme/app_typography.dart';
import '../../theme/spacing.dart';
import '../../theme/motion.dart';

/// Full hobby detail — hero parallax, sticky spec bar, entry animations.
class HobbyDetailScreen extends ConsumerStatefulWidget {
  final String hobbyId;

  const HobbyDetailScreen({super.key, required this.hobbyId});

  @override
  ConsumerState<HobbyDetailScreen> createState() => _HobbyDetailScreenState();
}

class _HobbyDetailScreenState extends ConsumerState<HobbyDetailScreen>
    with TickerProviderStateMixin {

  final ScrollController _scrollController = ScrollController();

  /// Scroll offset for parallax + appbar fade
  double _scrollOffset = 0;

  /// Entry animation controllers
  late final AnimationController _entryController;
  late final Animation<double> _overlayOpacity;
  late final Animation<double> _specBadgeOpacity;
  late final Animation<Offset> _specBadgeSlide;
  late final Animation<double> _detailsOpacity;
  late final Animation<Offset> _detailsSlide;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Entry animation: 600ms total, starts immediately.
    // Overlay fades in early and smooth (no flicker), spec badges arrive
    // after the Hero flight lands (~350ms).
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Gradient overlay: 30ms–390ms (smooth 360ms fade, no flicker)
    _overlayOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.05, 0.65, curve: Curves.easeOut),
      ),
    );

    // Details (category chip, hook): 90ms–420ms
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

    // Spec badge: 210ms–480ms (appears after hero lands at ~350ms)
    _specBadgeOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.35, 0.8, curve: Curves.easeOut),
      ),
    );
    _specBadgeSlide = Tween<Offset>(
      begin: const Offset(0, 10),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: Interval(0.35, 0.9, curve: Motion.heroCurve),
      ),
    );

    // Start immediately — no delay so animations stay in sync with the Hero flight
    _entryController.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
  }

  /// AppBar opacity: fades in as hero scrolls out of view
  double get _appBarOpacity {
    const fadeStart = 180.0; // start fading in
    const fadeEnd = 300.0; // fully visible
    return ((_scrollOffset - fadeStart) / (fadeEnd - fadeStart)).clamp(0.0, 1.0);
  }

  /// Hero parallax offset: image moves at 0.5x scroll velocity
  double get _heroParallax {
    return (_scrollOffset * Motion.parallaxFactor).clamp(0.0, Motion.maxParallaxOffset);
  }

  @override
  Widget build(BuildContext context) {
    final hobby = ref.watch(hobbyByIdProvider(widget.hobbyId));
    if (hobby == null) {
      return Scaffold(
        backgroundColor: AppColors.cream,
        body: Center(
          child: Text('Hobby not found', style: AppTypography.sansBody),
        ),
      );
    }

    final relatedHobbies = ref.watch(relatedHobbiesProvider(widget.hobbyId));
    final userHobbies = ref.watch(userHobbiesProvider);
    final userHobby = userHobbies[widget.hobbyId];
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Stack(
        children: [
          // Scrollable content
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Hero image with parallax
              SliverToBoxAdapter(child: _buildHeroImage(context, hobby)),

              // Spec bar (animated entry — no longer a SliverPersistentHeader
              // because the slide animation was pushing content beyond the
              // sliver's geometry bounds, causing layoutExtent > paintExtent)
              SliverToBoxAdapter(
                child: AnimatedBuilder(
                  animation: _specBadgeOpacity,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: _specBadgeSlide.value,
                      child: Opacity(
                        opacity: _specBadgeOpacity.value,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                    color: AppColors.cream,
                    child: SpecBar(
                      cost: hobby.costText,
                      time: hobby.timeText,
                      difficulty: hobby.difficultyText,
                      withContainer: true,
                    ),
                  ),
                ),
              ),

              // Content sections
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Why people love it
                    const SizedBox(height: 24),
                    SectionHeader(title: 'Why people love it'),
                    Text(
                      hobby.whyLove,
                      style: AppTypography.sansBody.copyWith(
                        height: 1.65,
                        color: AppColors.espresso,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Difficulty explanation
                    SectionHeader(title: 'What makes it ${hobby.difficultyText.toLowerCase()}'),
                    Text(
                      hobby.difficultyExplain,
                      style: AppTypography.sansBody.copyWith(
                        height: 1.65,
                        color: AppColors.espresso,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Starter Kit
                    SectionHeader(title: 'Starter Kit', rightText: 'Start small.'),
                    ...hobby.starterKit.map((item) => _buildKitItem(item)),
                    const SizedBox(height: 28),

                    // Beginner Pitfalls
                    SectionHeader(title: 'Beginner Pitfalls'),
                    ...hobby.pitfalls.map((p) => _buildPitfall(p)),
                    const SizedBox(height: 28),

                    // Roadmap
                    SectionHeader(
                      title: 'Your Roadmap',
                      rightText: '${hobby.roadmapSteps.length} steps',
                    ),
                    ...hobby.roadmapSteps.asMap().entries.map((entry) {
                      final index = entry.key;
                      final step = entry.value;
                      final isCompleted = userHobby?.completedStepIds.contains(step.id) ?? false;
                      final isCurrent = !isCompleted &&
                          (index == 0 ||
                              (userHobby?.completedStepIds.contains(
                                      hobby.roadmapSteps[index - 1].id) ??
                                  false));

                      return RoadmapStepTile(
                        step: step,
                        stepNumber: index + 1,
                        isCompleted: isCompleted,
                        isCurrent: isCurrent,
                        onToggle: () {
                          ref.read(userHobbiesProvider.notifier).toggleStep(widget.hobbyId, step.id);
                        },
                      );
                    }),

                    // Related hobbies
                    if (relatedHobbies.isNotEmpty) ...[
                      const SizedBox(height: 28),
                      SectionHeader(title: 'You might also like'),
                      SizedBox(
                        height: 80,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: relatedHobbies.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 10),
                          itemBuilder: (context, i) {
                            final related = relatedHobbies[i];
                            return SizedBox(
                              width: 260,
                              child: HobbyMiniCard(
                                title: related.title,
                                imageUrl: related.imageUrl,
                                category: related.category,
                                catIcon: related.catIcon,
                                catColor: related.catColor,
                                cost: related.costText,
                                onTap: () => context.push('/hobby/${related.id}'),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ]),
                ),
              ),
            ],
          ),

          // Fading AppBar overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              ignoring: _appBarOpacity < 0.1,
              child: AnimatedOpacity(
                opacity: _appBarOpacity,
                duration: const Duration(milliseconds: 50),
                child: Container(
                  height: topPad + 56,
                  padding: EdgeInsets.only(top: topPad),
                  decoration: BoxDecoration(
                    color: AppColors.cream,
                    border: Border(
                      bottom: BorderSide(color: AppColors.sandDark.withValues(alpha: 0.5)),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      ref.read(hobbyByIdProvider(widget.hobbyId))?.title ?? '',
                      style: AppTypography.sansBodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.nearBlack,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Back button (always visible, above AppBar)
          Positioned(
            top: topPad + 8,
            left: 16,
            child: GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xCC1E1E2E),
                ),
                child: const Center(
                  child: Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.nearBlack),
                ),
              ),
            ),
          ),

          // Floating CTA at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.cream.withValues(alpha: 0),
                    AppColors.cream,
                  ],
                  stops: const [0.0, 0.3],
                ),
              ),
              child: SafeArea(
                top: false,
                child: TryTodayButton(
                  onPressed: () => context.push('/quickstart/${widget.hobbyId}'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroImage(BuildContext context, Hobby hobby) {
    return SizedBox(
      height: Spacing.heroHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image with parallax + custom Hero flightShuttleBuilder
          ClipRect(
            child: Hero(
              tag: 'hobby_image_${hobby.id}',
              flightShuttleBuilder: (flightContext, animation, direction,
                  fromHeroContext, toHeroContext) {
                // Use Hero's child directly — passing the full Hero widget
                // into the overlay causes null check failures in the flight system.
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
                  height: Spacing.heroHeight + Motion.maxParallaxOffset,
                  width: double.infinity,
                  placeholder: (_, __) => Container(color: AppColors.sand),
                  errorWidget: (_, __, ___) => Container(
                    color: AppColors.sand,
                    child: const Icon(Icons.image, size: 40, color: AppColors.stone),
                  ),
                ),
              ),
            ),
          ),

          // Gradient overlay — synchronized fade with details
          AnimatedBuilder(
            animation: _overlayOpacity,
            builder: (context, child) {
              return Opacity(
                opacity: _overlayOpacity.value,
                child: child,
              );
            },
            child: const DecoratedBox(
              decoration: BoxDecoration(gradient: Spacing.heroOverlayGradient),
            ),
          ),

          // Bottom info: category chip + title + hook
          Positioned(
            bottom: 16,
            left: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category chip (animated entry — not a Hero)
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
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Spacing.radiusBadge),
                      color: AppColors.sand,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(hobby.catIcon, size: 12, color: hobby.catColor),
                        const SizedBox(width: 5),
                        Text(
                          hobby.category.toUpperCase(),
                          style: AppTypography.categoryLabel.copyWith(color: AppColors.driftwood),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Title — Hero with flightShuttleBuilder for smooth color transition
                Hero(
                  tag: 'hobby_title_${hobby.id}',
                  flightShuttleBuilder: (flightContext, animation, direction,
                      fromHeroContext, toHeroContext) {
                    // Cross-fade text: use Hero children, not the Hero wrappers
                    final fromChild = (fromHeroContext.widget as Hero).child;
                    final toChild = (toHeroContext.widget as Hero).child;
                    return AnimatedBuilder(
                      animation: animation,
                      builder: (context, _) {
                        return Stack(
                          children: [
                            Opacity(
                              opacity: 1 - animation.value,
                              child: fromChild,
                            ),
                            Opacity(
                              opacity: animation.value,
                              child: toChild,
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Material(
                    color: Colors.transparent,
                    child: Text(hobby.title, style: AppTypography.serifHero),
                  ),
                ),
                const SizedBox(height: 4),

                // Hook text (animated entry — not a Hero)
                AnimatedBuilder(
                  animation: _detailsOpacity,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _detailsOpacity.value,
                      child: child,
                    );
                  },
                  child: Text(
                    hobby.hook,
                    style: AppTypography.sansBodySmall.copyWith(color: AppColors.driftwood),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKitItem(KitItem item) {
    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.warmWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon circle
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: item.isOptional ? AppColors.sand : AppColors.coralPale,
            ),
            child: Center(
              child: Icon(
                item.isOptional ? Icons.add : AppIcons.check,
                size: 14,
                color: item.isOptional ? AppColors.warmGray : AppColors.coral,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        item.name,
                        style: AppTypography.sansBodySmall.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    if (item.isOptional) ...[
                      const SizedBox(width: 6),
                      Text(
                        'OPTIONAL',
                        style: AppTypography.monoBadgeSmall.copyWith(
                          color: AppColors.warmGray,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  item.description,
                  style: AppTypography.sansCaption.copyWith(color: AppColors.driftwood),
                ),
              ],
            ),
          ),

          // Cost
          if (item.cost > 0)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                '~${item.cost}',
                style: AppTypography.monoMedium.copyWith(
                  color: AppColors.coral,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPitfall(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 7),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.amber,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTypography.sansBodySmall.copyWith(
                height: 1.5,
                color: AppColors.espresso,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
