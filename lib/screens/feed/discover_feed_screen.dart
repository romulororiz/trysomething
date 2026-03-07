import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../providers/hobby_provider.dart';
import '../../providers/user_provider.dart';
import '../../core/hobby_match.dart';
import '../../models/hobby.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_icons.dart';
import '../../theme/app_typography.dart';
import '../../theme/motion.dart';
import '../../theme/spacing.dart';

// ═══════════════════════════════════════════════════════
//  SIMPLE CATEGORY FILTERS
// ═══════════════════════════════════════════════════════

/// Fixed category filters per CLAUDE.md: creative / active / mindful / social / outdoors / at home
class _CategoryFilter {
  final String id;
  final String label;
  final IconData icon;
  final Color color;
  final bool Function(Hobby) matches;

  const _CategoryFilter({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
    required this.matches,
  });
}

final _categoryFilters = <_CategoryFilter>[
  _CategoryFilter(
    id: 'creative',
    label: 'Creative',
    icon: MdiIcons.palette,
    color: AppColors.catCreative,
    matches: (h) =>
        h.category.toLowerCase() == 'creative' ||
        h.tags.any((t) => t.toLowerCase() == 'creative'),
  ),
  _CategoryFilter(
    id: 'active',
    label: 'Active',
    icon: MdiIcons.dumbbell,
    color: AppColors.catFitness,
    matches: (h) =>
        h.category.toLowerCase() == 'fitness' ||
        h.tags.any(
            (t) => ['physical', 'active', 'fitness'].contains(t.toLowerCase())),
  ),
  _CategoryFilter(
    id: 'mindful',
    label: 'Mindful',
    icon: MdiIcons.meditation,
    color: AppColors.catMind,
    matches: (h) =>
        h.category.toLowerCase() == 'mind' ||
        h.tags.any((t) => ['meditative', 'relaxing', 'mindful', 'calming']
            .contains(t.toLowerCase())),
  ),
  _CategoryFilter(
    id: 'social',
    label: 'Social',
    icon: MdiIcons.accountGroup,
    color: AppColors.catSocial,
    matches: (h) =>
        h.category.toLowerCase() == 'social' ||
        h.tags.any((t) => t.toLowerCase() == 'social'),
  ),
  _CategoryFilter(
    id: 'outdoors',
    label: 'Outdoors',
    icon: MdiIcons.pineTree,
    color: AppColors.catOutdoors,
    matches: (h) =>
        h.category.toLowerCase() == 'outdoors' ||
        h.tags.any(
            (t) => ['outdoors', 'outdoor', 'nature'].contains(t.toLowerCase())),
  ),
  _CategoryFilter(
    id: 'at-home',
    label: 'At Home',
    icon: MdiIcons.homeOutline,
    color: AppColors.sky,
    matches: (h) => h.tags
        .any((t) => ['indoor', 'at-home', 'home'].contains(t.toLowerCase())),
  ),
];

/// Scrollable Discover tab with horizontal rails, search, and category filters.
class DiscoverFeedScreen extends ConsumerStatefulWidget {
  const DiscoverFeedScreen({super.key});

  @override
  ConsumerState<DiscoverFeedScreen> createState() => _DiscoverFeedScreenState();
}

class _DiscoverFeedScreenState extends ConsumerState<DiscoverFeedScreen> {
  String? _selectedFilter;

  List<Hobby> _applyFilter(List<Hobby> hobbies) {
    if (_selectedFilter == null) return hobbies;
    final filter = _categoryFilters.firstWhere((f) => f.id == _selectedFilter);
    return hobbies.where(filter.matches).toList();
  }

  @override
  Widget build(BuildContext context) {
    final hobbiesAsync = ref.watch(hobbyListProvider);
    final prefs = ref.watch(userPreferencesProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: hobbiesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.coral),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(MdiIcons.alertCircleOutline,
                  size: 32, color: AppColors.warmGray),
              const SizedBox(height: 12),
              Text('Something went wrong',
                  style: AppTypography.sansBody
                      .copyWith(color: AppColors.warmGray)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => ref.invalidate(hobbyListProvider),
                child: Text('Tap to retry',
                    style: AppTypography.sansLabel
                        .copyWith(color: AppColors.coral)),
              ),
            ],
          ),
        ),
        data: (allHobbies) => _buildContent(allHobbies, prefs),
      ),
    );
  }

  Widget _buildContent(List<Hobby> allHobbies, UserPreferences prefs) {
    // Build rails, then apply category filter
    final forYou = _applyFilter(_buildForYouList(allHobbies, prefs));
    final startCheap = _applyFilter(allHobbies.where((h) {
      final (_, max) = parseCostRange(h.costText);
      return max <= 30;
    }).toList());
    final startThisWeek = _applyFilter(allHobbies.where((h) {
      final hours = parseWeeklyHours(h.timeText);
      return hours <= 2 && h.difficultyText.toLowerCase() == 'easy';
    }).toList());
    final differentVibe =
        _applyFilter(_buildDifferentVibeList(allHobbies, prefs));

    return CustomScrollView(
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.coral,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'TRYSOMETHING',
                        style: AppTypography.sansLabel.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: AppColors.nearBlack,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => context.push('/search'),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.warmWhite,
                          ),
                          child: const Icon(Icons.search_rounded,
                              size: 20, color: AppColors.driftwood),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Search bar with NLP hints
                  GestureDetector(
                    onTap: () => context.push('/search'),
                    child: Container(
                      height: Spacing.searchBarHeight,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.warmWhite,
                        borderRadius:
                            BorderRadius.circular(Spacing.radiusButton),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search_rounded,
                              size: 18, color: AppColors.warmGray),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '"cheap creative hobby", "hobby for anxiety"...',
                              style: AppTypography.sansCaption.copyWith(
                                color: AppColors.warmGray,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),
          ),
        ),

        // Category filter bar — outside parent padding so it scrolls edge-to-edge
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: _CategoryFilterBar(
              selectedId: _selectedFilter,
              onSelected: (id) {
                setState(() {
                  _selectedFilter = _selectedFilter == id ? null : id;
                });
              },
            ),
          ),
        ),

        // For You rail
        if (forYou.isNotEmpty)
          _SliverRail(
            key: ValueKey('for-you-$_selectedFilter'),
            title: 'For You',
            icon: AppIcons.sparkle,
            iconColor: AppColors.coral,
            hobbies: forYou,
            onExploreAll: () => context.push('/rail-feed/for-you?title=For+You'),
          ),

        // Start Cheap rail
        if (startCheap.isNotEmpty)
          _SliverRail(
            key: ValueKey('start-cheap-$_selectedFilter'),
            title: 'Start Cheap',
            icon: AppIcons.cheap,
            iconColor: AppColors.sage,
            hobbies: startCheap,
            onExploreAll: () => context.push('/rail-feed/start-cheap?title=Start+Cheap'),
          ),

        // Start This Week rail
        if (startThisWeek.isNotEmpty)
          _SliverRail(
            key: ValueKey('start-week-$_selectedFilter'),
            title: 'Start This Week',
            icon: AppIcons.quickStart,
            iconColor: AppColors.amber,
            hobbies: startThisWeek,
            onExploreAll: () => context.push('/rail-feed/start-this-week?title=Start+This+Week'),
          ),

        // Need a Different Vibe? rail
        if (differentVibe.isNotEmpty)
          _SliverRail(
            key: ValueKey('vibe-$_selectedFilter'),
            title: 'Need a Different Vibe?',
            icon: MdiIcons.shuffle,
            iconColor: AppColors.indigo,
            hobbies: differentVibe,
            onExploreAll: () => context.push('/rail-feed/different-vibe?title=Need+a+Different+Vibe'),
          ),

        // Empty state when all rails are empty (category filter too narrow)
        if (forYou.isEmpty &&
            startCheap.isEmpty &&
            startThisWeek.isEmpty &&
            differentVibe.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              child: Column(
                children: [
                  Icon(MdiIcons.magnifyClose,
                      size: 36, color: AppColors.warmGray),
                  const SizedBox(height: 12),
                  Text(
                    'No hobbies match this filter',
                    style: AppTypography.sansBody
                        .copyWith(color: AppColors.warmGray),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => setState(() => _selectedFilter = null),
                    child: Text(
                      'Show all hobbies',
                      style: AppTypography.sansLabel
                          .copyWith(color: AppColors.coral),
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Bottom padding
        const SliverPadding(
          padding: EdgeInsets.only(bottom: Spacing.scrollBottomPadding),
        ),
      ],
    );
  }

  List<Hobby> _buildForYouList(List<Hobby> allHobbies, UserPreferences prefs) {
    final scored = allHobbies.map((h) {
      final score = computeMatchScore(
        hobby: h,
        userHours: prefs.hoursPerWeek.toDouble(),
        userBudgetLevel: prefs.budgetLevel,
        userPrefersSocial: prefs.preferSocial,
        userVibes: prefs.vibes,
      );
      return (hobby: h, score: score);
    }).toList();
    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored.take(10).map((e) => e.hobby).toList();
  }

  List<Hobby> _buildDifferentVibeList(
      List<Hobby> allHobbies, UserPreferences prefs) {
    final scored = allHobbies.map((h) {
      final score = computeMatchScore(
        hobby: h,
        userHours: prefs.hoursPerWeek.toDouble(),
        userBudgetLevel: prefs.budgetLevel,
        userPrefersSocial: prefs.preferSocial,
        userVibes: prefs.vibes,
      );
      return (hobby: h, score: score);
    }).toList();
    scored.sort((a, b) => a.score.compareTo(b.score));
    return scored.take(8).map((e) => e.hobby).toList();
  }
}

// ═══════════════════════════════════════════════════════
//  SLIVER RAIL — Horizontal scrolling hobby row
// ═══════════════════════════════════════════════════════

class _SliverRail extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color iconColor;
  final List<Hobby> hobbies;
  final VoidCallback? onExploreAll;

  const _SliverRail({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.hobbies,
    this.onExploreAll,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 15, color: iconColor),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.sansSection.copyWith(
                          fontSize: 16,
                          color: AppColors.nearBlack,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: AppTypography.sansTiny.copyWith(
                            color: AppColors.warmGray,
                          ),
                        ),
                    ],
                  ),
                ),
                if (onExploreAll != null)
                  GestureDetector(
                    onTap: onExploreAll,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8, bottom: 2),
                      child: Text(
                        'Explore all →',
                        style: AppTypography.sansCaption.copyWith(
                          color: AppColors.coral,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Horizontal card list
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: hobbies.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return _RailCard(hobby: hobbies[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  RAIL CARD — Compact hobby card for horizontal rails
// ═══════════════════════════════════════════════════════

class _RailCard extends StatefulWidget {
  final Hobby hobby;

  const _RailCard({required this.hobby});

  @override
  State<_RailCard> createState() => _RailCardState();
}

class _RailCardState extends State<_RailCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: Motion.cardPress,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: Motion.cardPressScale)
        .animate(
            CurvedAnimation(parent: _scaleController, curve: Motion.fastCurve));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hobby = widget.hobby;

    return GestureDetector(
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) {
        _scaleController.reverse();
        context.push('/hobby/${hobby.id}');
      },
      onTapCancel: () => _scaleController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: 155,
          decoration: BoxDecoration(
            color: AppColors.sand,
            borderRadius: BorderRadius.circular(Spacing.radiusTile),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Full-bleed background image
              CachedNetworkImage(
                imageUrl: hobby.imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: AppColors.sand),
                errorWidget: (_, __, ___) => Container(
                  color: AppColors.sand,
                  child: Icon(
                    AppIcons.categoryIcon(hobby.category),
                    size: 28,
                    color: AppColors.warmGray,
                  ),
                ),
              ),

              // Dark overlay gradient — heavier at bottom for text
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.1),
                      Colors.black.withValues(alpha: 0.25),
                      Colors.black.withValues(alpha: 0.65),
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
              ),

              // Content on top
              Positioned(
                left: 10,
                right: 10,
                bottom: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      hobby.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.sansLabel.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 6,
                            color: Colors.black.withValues(alpha: 0.5),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Spec badges row
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _SpecMini(
                          icon: AppIcons.badgeCost,
                          text: hobby.costText.replaceAll('CHF ', ''),
                        ),
                        _SpecMini(
                          icon: AppIcons.badgeTime,
                          text: hobby.timeText,
                        ),
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
}

// ═══════════════════════════════════════════════════════
//  SPEC MINI — Tiny spec badge for rail cards
// ═══════════════════════════════════════════════════════

class _SpecMini extends StatelessWidget {
  final IconData icon;
  final String text;

  const _SpecMini({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 9, color: Colors.white.withValues(alpha: 0.7)),
          const SizedBox(width: 3),
          Text(
            text,
            style: AppTypography.monoTiny.copyWith(
              fontSize: 9,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  CATEGORY FILTER BAR — 6 simple fixed filters
// ═══════════════════════════════════════════════════════

class _CategoryFilterBar extends StatelessWidget {
  final String? selectedId;
  final ValueChanged<String?> onSelected;

  const _CategoryFilterBar({
    required this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: _categoryFilters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final filter = _categoryFilters[index];
          final isSelected = selectedId == filter.id;
          return GestureDetector(
            onTap: () => onSelected(filter.id),
            child: AnimatedContainer(
              duration: Motion.fast,
              curve: Motion.fastCurve,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? filter.color : AppColors.warmWhite,
                borderRadius: BorderRadius.circular(Spacing.radiusBadge),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    filter.icon,
                    size: 12,
                    color: isSelected
                        ? Colors.white
                        : filter.color.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    filter.label,
                    style: AppTypography.sansCaption.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      color: isSelected ? Colors.white : AppColors.driftwood,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// End of file
