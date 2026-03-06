import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/hobby.dart';
import '../../theme/category_ui.dart';
import '../../providers/hobby_provider.dart';
import '../../providers/user_provider.dart';
import '../../components/try_today_button.dart';
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

  /// Hero parallax offset: image moves at 0.5x scroll velocity
  double get _heroParallax {
    return (_scrollOffset * Motion.parallaxFactor).clamp(0.0, Motion.maxParallaxOffset);
  }

  @override
  Widget build(BuildContext context) {
    final hobbyAsync = ref.watch(hobbyByIdProvider(widget.hobbyId));
    final hobby = hobbyAsync.valueOrNull;
    if (hobby == null) {
      return Scaffold(
        backgroundColor: AppColors.cream,
        body: Center(
          child: hobbyAsync.isLoading
              ? const CircularProgressIndicator()
              : Text('Hobby not found', style: AppTypography.sansBody),
        ),
      );
    }

    final relatedHobbies = ref.watch(relatedHobbiesProvider(widget.hobbyId)).valueOrNull ?? [];
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

              // Content sections
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Why you'll love it
                    const SizedBox(height: 24),
                    SectionHeader(title: "Why you'll love it"),
                    Text(
                      hobby.whyLove,
                      style: AppTypography.sansBody.copyWith(
                        height: 1.65,
                        color: AppColors.espresso,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Starter Kit — 2-column image grid
                    SectionHeader(
                      title: 'Starter Kit',
                      rightText: _kitTotal(hobby.starterKit) > 0
                          ? '~ \$${_kitTotal(hobby.starterKit)} Total'
                          : null,
                    ),
                    _buildKitGrid(hobby.starterKit, hobby.id),
                    const SizedBox(height: 28),

                    // Roadmap
                    SectionHeader(
                      title: 'Your Roadmap',
                      rightText: '${hobby.roadmapSteps.length} steps',
                    ),
                    _buildRoadmapTimeline(hobby, userHobby),

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

          // Header: back + title + share (always visible)
          Positioned(
            top: topPad + 8,
            left: 16,
            right: 16,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: const Icon(Icons.arrow_back_rounded, size: 24, color: Colors.white),
                ),
                Expanded(
                  child: Text(
                    hobby.title,
                    style: AppTypography.sansLabel.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // Share hobby
                  },
                  child: Icon(AppIcons.share, size: 20, color: Colors.white),
                ),
              ],
            ),
          ),

          // Floating CTA at bottom (above 85px nav bar)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
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

          // TRENDING badge + mastery time (top-right, below safe area)
          Positioned(
            top: MediaQuery.of(context).padding.top + 52,
            right: 16,
            child: AnimatedBuilder(
              animation: _detailsOpacity,
              builder: (context, child) => Opacity(
                opacity: _detailsOpacity.value,
                child: child,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.coral,
                      borderRadius: BorderRadius.circular(Spacing.radiusBadge),
                    ),
                    child: Text(
                      'TRENDING',
                      style: AppTypography.monoBadgeSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.sand.withAlpha(200),
                      borderRadius: BorderRadius.circular(Spacing.radiusBadge),
                    ),
                    child: Text(
                      _masteryTimeText(hobby.roadmapSteps),
                      style: AppTypography.monoBadgeSmall.copyWith(
                        color: AppColors.driftwood,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom info: category chip + title + hook + star rating
          Positioned(
            bottom: 16,
            left: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category chip (animated entry)
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

                // Title — Hero with cross-fade
                Hero(
                  tag: 'hobby_title_${hobby.id}',
                  flightShuttleBuilder: (flightContext, animation, direction,
                      fromHeroContext, toHeroContext) {
                    final fromChild = (fromHeroContext.widget as Hero).child;
                    final toChild = (toHeroContext.widget as Hero).child;
                    return AnimatedBuilder(
                      animation: animation,
                      builder: (context, _) {
                        return Stack(
                          children: [
                            Opacity(opacity: 1 - animation.value, child: fromChild),
                            Opacity(opacity: animation.value, child: toChild),
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

                // Hook + star rating row
                AnimatedBuilder(
                  animation: _detailsOpacity,
                  builder: (context, child) => Opacity(
                    opacity: _detailsOpacity.value,
                    child: child,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          hobby.hook,
                          style: AppTypography.sansBodySmall.copyWith(color: AppColors.driftwood),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Star rating
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, size: 14, color: AppColors.amber),
                          const SizedBox(width: 3),
                          Text(
                            '4.8',
                            style: AppTypography.monoBadge.copyWith(color: AppColors.amber),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '(1.2k)',
                            style: AppTypography.sansTiny.copyWith(color: AppColors.warmGray),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _masteryTimeText(List<RoadmapStep> steps) {
    final totalMinutes = steps.fold(0, (sum, s) => sum + s.estimatedMinutes);
    final totalHours = totalMinutes / 60;
    if (totalHours < 10) return '${totalHours.round()} hours to master';
    final weeks = (totalHours / 5).ceil(); // ~5 hrs/week
    return '$weeks weeks to master';
  }

  int _kitTotal(List<KitItem> items) {
    return items.where((i) => !i.isOptional).fold(0, (sum, i) => sum + i.cost);
  }

  Widget _buildKitGrid(List<KitItem> items, String hobbyId) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: items.map((item) => _buildKitCard(item, hobbyId)).toList(),
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

  String _kitLabel(KitItem item) {
    final name = item.name.toLowerCase();
    if (name.contains('tool') || name.contains('saw') || name.contains('knife') ||
        name.contains('needle') || name.contains('scissors')) return 'TOOLS';
    if (name.contains('book') || name.contains('app') || name.contains('course') ||
        name.contains('guide') || name.contains('account')) return 'RESOURCE';
    if (name.contains('bag') || name.contains('case') || name.contains('pad') ||
        name.contains('mat') || name.contains('stand')) return 'GEAR';
    return 'MATERIAL';
  }

  Widget _buildKitCard(KitItem item, String hobbyId) {
    final hasImage = item.imageUrl != null && item.imageUrl!.isNotEmpty;
    return GestureDetector(
      onTap: () => _openAffiliateLink(item),
      child: SizedBox(
        width: (MediaQuery.of(context).size.width - 24 * 2 - 10) / 2,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.warmWhite,
            borderRadius: BorderRadius.circular(14),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product image
              SizedBox(
                height: 100,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (hasImage)
                      CachedNetworkImage(
                        imageUrl: item.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(color: AppColors.sand),
                        errorWidget: (_, __, ___) => Container(
                          color: AppColors.sand,
                          child: const Icon(Icons.image, size: 24, color: AppColors.stone),
                        ),
                      )
                    else
                      Container(
                        color: AppColors.sand,
                        child: Center(
                          child: Icon(
                            item.isOptional ? Icons.add_circle_outline : AppIcons.check,
                            size: 24,
                            color: AppColors.stone,
                          ),
                        ),
                      ),
                    // Category label badge (top-left)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(140),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _kitLabel(item),
                          style: AppTypography.monoBadgeSmall.copyWith(
                            color: Colors.white,
                            fontSize: 8,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                    // Optional badge (top-right)
                    if (item.isOptional)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.warmGray.withAlpha(180),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'OPT',
                            style: AppTypography.monoBadgeSmall.copyWith(
                              color: Colors.white,
                              fontSize: 8,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Item details
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: AppTypography.sansCaption.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.nearBlack,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (item.cost > 0)
                          Text(
                            'CHF ${item.cost}',
                            style: AppTypography.monoBadge.copyWith(
                              color: AppColors.coral,
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        else
                          Text(
                            'FREE',
                            style: AppTypography.monoBadge.copyWith(
                              color: AppColors.sage,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        const Spacer(),
                        Icon(Icons.shopping_bag_outlined,
                            size: 14, color: AppColors.driftwood),
                      ],
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

  Widget _buildRoadmapTimeline(Hobby hobby, UserHobby? userHobby) {
    final steps = hobby.roadmapSteps;
    return Column(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        final isCompleted = userHobby?.completedStepIds.contains(step.id) ?? false;
        final isCurrent = !isCompleted &&
            (index == 0 ||
                (userHobby?.completedStepIds.contains(steps[index - 1].id) ?? false));
        final isLast = index == steps.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline column: circle + connecting line
              SizedBox(
                width: 32,
                child: Column(
                  children: [
                    // Step circle indicator
                    GestureDetector(
                      onTap: () {
                        ref.read(userHobbiesProvider.notifier).toggleStep(widget.hobbyId, step.id);
                      },
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCompleted
                              ? AppColors.sage
                              : isCurrent
                                  ? AppColors.coral
                                  : Colors.transparent,
                          border: Border.all(
                            color: isCompleted
                                ? AppColors.sage
                                : isCurrent
                                    ? AppColors.coral
                                    : AppColors.sandDark,
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: isCompleted
                              ? const Icon(Icons.check, size: 16, color: Colors.white)
                              : Text(
                                  '${index + 1}',
                                  style: AppTypography.monoTiny.copyWith(
                                    color: isCurrent ? Colors.white : AppColors.warmGray,
                                    fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    // Connecting line
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 1.5,
                          color: isCompleted ? AppColors.sage.withValues(alpha: 0.4) : AppColors.sandDark,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Step content
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isCurrent ? AppColors.coralPale : AppColors.warmWhite,
                    borderRadius: BorderRadius.circular(Spacing.radiusButton),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              step.title,
                              style: AppTypography.sansLabel.copyWith(
                                decoration: isCompleted ? TextDecoration.lineThrough : null,
                                color: isCompleted ? AppColors.warmGray : AppColors.nearBlack,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isCompleted
                                  ? AppColors.sand.withValues(alpha: 0.5)
                                  : AppColors.sand,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _formatStepTime(step.estimatedMinutes),
                              style: AppTypography.monoTiny.copyWith(
                                color: isCompleted ? AppColors.stone : AppColors.driftwood,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        step.description,
                        style: AppTypography.sansTiny.copyWith(
                          color: isCompleted ? AppColors.stone : AppColors.warmGray,
                        ),
                      ),
                      if (step.milestone != null) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.coralPale,
                            borderRadius: BorderRadius.circular(Spacing.radiusBadge),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(AppIcons.trophy, size: 12, color: AppColors.coral),
                              const SizedBox(width: 4),
                              Text(
                                step.milestone!,
                                style: AppTypography.monoMilestone.copyWith(
                                  color: AppColors.coral,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _formatStepTime(int minutes) {
    if (minutes >= 60) {
      final hours = minutes / 60;
      return '${hours.toStringAsFixed(hours.truncateToDouble() == hours ? 0 : 1)}h';
    }
    return '${minutes}min';
  }
}
