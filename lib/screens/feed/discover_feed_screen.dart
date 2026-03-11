import 'dart:ui';
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
import '../../theme/spacing.dart';
import '../../components/glass_card.dart';

// ═══════════════════════════════════════════════════════
//  CATEGORY FILTERS (used in bottom sheet)
// ═══════════════════════════════════════════════════════

class _CategoryFilter {
  final String id;
  final String label;
  final IconData icon;
  final bool Function(Hobby) matches;

  const _CategoryFilter({
    required this.id,
    required this.label,
    required this.icon,
    required this.matches,
  });
}

final _categoryFilters = <_CategoryFilter>[
  _CategoryFilter(
    id: 'creative',
    label: 'Creative',
    icon: MdiIcons.palette,
    matches: (h) =>
        h.category.toLowerCase() == 'creative' ||
        h.tags.any((t) => t.toLowerCase() == 'creative'),
  ),
  _CategoryFilter(
    id: 'active',
    label: 'Active',
    icon: MdiIcons.dumbbell,
    matches: (h) =>
        h.category.toLowerCase() == 'fitness' ||
        h.tags.any(
            (t) => ['physical', 'active', 'fitness'].contains(t.toLowerCase())),
  ),
  _CategoryFilter(
    id: 'mindful',
    label: 'Mindful',
    icon: MdiIcons.meditation,
    matches: (h) =>
        h.category.toLowerCase() == 'mind' ||
        h.tags.any((t) => ['meditative', 'relaxing', 'mindful', 'calming']
            .contains(t.toLowerCase())),
  ),
  _CategoryFilter(
    id: 'social',
    label: 'Social',
    icon: MdiIcons.accountGroup,
    matches: (h) =>
        h.category.toLowerCase() == 'social' ||
        h.tags.any((t) => t.toLowerCase() == 'social'),
  ),
  _CategoryFilter(
    id: 'outdoors',
    label: 'Outdoors',
    icon: MdiIcons.pineTree,
    matches: (h) =>
        h.category.toLowerCase() == 'outdoors' ||
        h.tags.any(
            (t) => ['outdoors', 'outdoor', 'nature'].contains(t.toLowerCase())),
  ),
  _CategoryFilter(
    id: 'at-home',
    label: 'At Home',
    icon: MdiIcons.homeOutline,
    matches: (h) => h.tags
        .any((t) => ['indoor', 'at-home', 'home'].contains(t.toLowerCase())),
  ),
];

/// Cinematic Discover tab with hero card layout.
class DiscoverFeedScreen extends ConsumerStatefulWidget {
  const DiscoverFeedScreen({super.key});

  @override
  ConsumerState<DiscoverFeedScreen> createState() => _DiscoverFeedScreenState();
}

class _DiscoverFeedScreenState extends ConsumerState<DiscoverFeedScreen> {
  String? _selectedFilter;
  bool _searchActive = false;
  String _searchQuery = '';
  late final TextEditingController _searchController;
  late final FocusNode _searchFocus;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocus = FocusNode();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _activateSearch() {
    setState(() {
      _searchActive = true;
      _searchQuery = '';
    });
    _searchFocus.requestFocus();
  }

  void _deactivateSearch() {
    setState(() {
      _searchActive = false;
      _searchQuery = '';
      _searchController.clear();
    });
    _searchFocus.unfocus();
  }

  List<Hobby> _applyFilter(List<Hobby> hobbies) {
    if (_selectedFilter == null) return hobbies;
    final filter =
        _categoryFilters.firstWhere((f) => f.id == _selectedFilter);
    return hobbies.where(filter.matches).toList();
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Filter by category',
                  style: AppTypography.title
                      .copyWith(color: AppColors.textPrimary)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categoryFilters.map((f) {
                  final isSelected = _selectedFilter == f.id;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedFilter =
                            _selectedFilter == f.id ? null : f.id;
                      });
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.accent
                            : AppColors.glassBackground,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: isSelected
                                ? AppColors.accent
                                : AppColors.glassBorder),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(f.icon,
                              size: 16,
                              color: isSelected
                                  ? AppColors.background
                                  : AppColors.textSecondary),
                          const SizedBox(width: 6),
                          Text(f.label,
                              style: AppTypography.body.copyWith(
                                fontSize: 13,
                                color: isSelected
                                    ? AppColors.background
                                    : AppColors.textPrimary,
                              )),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (_selectedFilter != null) ...[
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    setState(() => _selectedFilter = null);
                    Navigator.pop(ctx);
                  },
                  child: Text('Clear filter',
                      style: AppTypography.body
                          .copyWith(color: AppColors.accent)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hobbiesAsync = ref.watch(hobbyListProvider);
    final prefs = ref.watch(userPreferencesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: _buildSearchBar(),
            ),
            Expanded(
              child: hobbiesAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.accent),
                ),
                error: (e, _) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(MdiIcons.alertCircleOutline,
                          size: 32, color: AppColors.textMuted),
                      const SizedBox(height: 12),
                      Text('Something went wrong',
                          style: AppTypography.body
                              .copyWith(color: AppColors.textMuted)),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => ref.invalidate(hobbyListProvider),
                        child: Text('Tap to retry',
                            style: AppTypography.body
                                .copyWith(color: AppColors.accent)),
                      ),
                    ],
                  ),
                ),
                data: (allHobbies) => AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  transitionBuilder: (child, anim) =>
                      FadeTransition(opacity: anim, child: child),
                  child: _searchActive
                      ? _buildSearchView(allHobbies)
                      : _buildDiscoverRails(allHobbies, prefs),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                height: Spacing.searchBarHeight,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.glassBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _searchActive
                        ? AppColors.accent.withValues(alpha: 0.3)
                        : AppColors.glassBorder,
                    width: 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(MdiIcons.magnify,
                        size: 18,
                        color: _searchActive
                            ? AppColors.accent
                            : AppColors.textMuted),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _searchActive
                          ? TextField(
                              controller: _searchController,
                              focusNode: _searchFocus,
                              autofocus: true,
                              onChanged: (q) =>
                                  setState(() => _searchQuery = q),
                              style: AppTypography.body.copyWith(
                                fontSize: 13,
                                color: AppColors.textPrimary,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                hintText: 'Search hobbies...',
                                hintStyle: AppTypography.body.copyWith(
                                  fontSize: 13,
                                  color: AppColors.textMuted,
                                ),
                                contentPadding: EdgeInsets.zero,
                              ),
                              cursorColor: AppColors.accent,
                              cursorWidth: 1.5,
                            )
                          : GestureDetector(
                              onTap: _activateSearch,
                              behavior: HitTestBehavior.opaque,
                              child: SizedBox(
                                height: Spacing.searchBarHeight,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    '"cheap creative hobby", "indoor winter"...',
                                    style: AppTypography.body.copyWith(
                                      fontSize: 13,
                                      color: AppColors.textMuted,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                    ),
                    if (_searchActive && _searchQuery.isNotEmpty)
                      GestureDetector(
                        onTap: () => setState(() {
                          _searchQuery = '';
                          _searchController.clear();
                        }),
                        child: Icon(MdiIcons.close,
                            size: 16, color: AppColors.textMuted),
                      ),
                    if (!_searchActive)
                      GestureDetector(
                        onTap: _showFilterSheet,
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Icon(
                            _selectedFilter != null
                                ? MdiIcons.filterCheck
                                : MdiIcons.filterVariant,
                            size: 18,
                            color: _selectedFilter != null
                                ? AppColors.accent
                                : AppColors.textMuted,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (_searchActive) ...[
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _deactivateSearch,
            child: Text(
              'Cancel',
              style: AppTypography.body.copyWith(
                color: AppColors.accent,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSearchView(List<Hobby> allHobbies) {
    if (_searchQuery.isEmpty) {
      return _buildSearchSuggestions();
    }

    final query = _searchQuery.toLowerCase();
    final results = allHobbies.where((h) {
      return h.title.toLowerCase().contains(query) ||
          h.category.toLowerCase().contains(query) ||
          h.tags.any((t) => t.toLowerCase().contains(query)) ||
          h.hook.toLowerCase().contains(query);
    }).toList();

    if (results.isEmpty) {
      return Center(
        key: const ValueKey('no-results'),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(MdiIcons.magnifyClose, size: 36, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text('No hobbies found',
                style:
                    AppTypography.body.copyWith(color: AppColors.textMuted)),
            const SizedBox(height: 6),
            Text('Try "creative", "outdoor", or "social"',
                style: AppTypography.caption
                    .copyWith(color: AppColors.textWhisper)),
          ],
        ),
      );
    }

    return ListView.builder(
      key: ValueKey('results-$_searchQuery'),
      padding:
          const EdgeInsets.fromLTRB(24, 16, 24, Spacing.scrollBottomPadding),
      itemCount: results.length,
      itemBuilder: (context, i) => _SearchResultItem(hobby: results[i]),
    );
  }

  Widget _buildSearchSuggestions() {
    const suggestions = [
      'cheap creative hobby',
      'hobby for anxiety',
      'indoor winter hobby',
      'social but low pressure',
      'hobby for couples',
      'solo at home',
    ];

    return ListView(
      key: const ValueKey('suggestions'),
      padding:
          const EdgeInsets.fromLTRB(24, 20, 24, Spacing.scrollBottomPadding),
      children: [
        Text('TRY SEARCHING FOR',
            style: AppTypography.overline.copyWith(color: AppColors.textMuted)),
        const SizedBox(height: 12),
        ...suggestions.map((s) => GestureDetector(
              onTap: () => setState(() {
                _searchQuery = s;
                _searchController.text = s;
                _searchController.selection = TextSelection.fromPosition(
                    TextPosition(offset: s.length));
              }),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Icon(MdiIcons.magnify, size: 16, color: AppColors.textMuted),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(s,
                          style: AppTypography.body
                              .copyWith(color: AppColors.textSecondary)),
                    ),
                    Icon(Icons.north_west_rounded,
                        size: 14, color: AppColors.textWhisper),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildDiscoverRails(List<Hobby> allHobbies, UserPreferences prefs) {
    final forYou = _applyFilter(_buildForYouList(allHobbies, prefs));
    final startCheap = _applyFilter(allHobbies.where((h) {
      final (_, max) = parseCostRange(h.costText);
      return max <= 30;
    }).toList());
    final startThisWeek = _applyFilter(allHobbies.where((h) {
      final hours = parseWeeklyHours(h.timeText);
      return hours <= 2 && h.difficultyText.toLowerCase() == 'easy';
    }).toList());

    final heroHobby = forYou.isNotEmpty ? forYou.first : null;
    final alternates =
        forYou.length > 1 ? forYou.skip(1).take(2).toList() : <Hobby>[];

    return CustomScrollView(
      key: const ValueKey('discover'),
      slivers: [
        // ── Hero card ──
        if (heroHobby != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: _HeroCard(hobby: heroHobby),
            ),
          ),

        // ── MORE FOR YOU — 2 alternates ──
        if (alternates.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('MORE FOR YOU',
                      style: AppTypography.overline
                          .copyWith(color: AppColors.textMuted)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      for (int i = 0; i < alternates.length; i++) ...[
                        if (i > 0) const SizedBox(width: 12),
                        Expanded(
                            child: _AlternateCard(hobby: alternates[i])),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),

        // ── START CHEAP rail ──
        if (startCheap.isNotEmpty)
          _SliverCompactRail(
            title: 'START CHEAP',
            hobbies: startCheap,
            routeId: 'start-cheap',
          ),

        // ── START THIS WEEK rail ──
        if (startThisWeek.isNotEmpty)
          _SliverCompactRail(
            title: 'START THIS WEEK',
            hobbies: startThisWeek,
            routeId: 'start-this-week',
          ),

        // Empty state
        if (heroHobby == null && startCheap.isEmpty && startThisWeek.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              child: Column(
                children: [
                  Icon(MdiIcons.magnifyClose,
                      size: 36, color: AppColors.textMuted),
                  const SizedBox(height: 12),
                  Text('No hobbies match this filter',
                      style: AppTypography.body
                          .copyWith(color: AppColors.textMuted)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => setState(() => _selectedFilter = null),
                    child: Text('Show all hobbies',
                        style: AppTypography.body
                            .copyWith(color: AppColors.accent)),
                  ),
                ],
              ),
            ),
          ),

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
}

// ═══════════════════════════════════════════════════════
//  HERO CARD — Full width, 55-60% height, #1 match
// ═══════════════════════════════════════════════════════

class _HeroCard extends StatelessWidget {
  final Hobby hobby;

  const _HeroCard({required this.hobby});

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final cardH = screenH * 0.55;

    return GestureDetector(
      onTap: () => context.push('/hobby/${hobby.id}'),
      child: Container(
        height: cardH,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.glassBorder, width: 0.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            CachedNetworkImage(
              imageUrl: hobby.imageUrl,
              fit: BoxFit.cover,
              memCacheWidth: 800,
              placeholder: (_, __) =>
                  Container(color: AppColors.surfaceElevated),
              errorWidget: (_, __, ___) => Container(
                color: AppColors.surfaceElevated,
                child: Icon(AppIcons.categoryIcon(hobby.category),
                    size: 48, color: AppColors.textMuted),
              ),
            ),

            // Gradient overlay — editorial fade to dark at bottom
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withAlpha(20),
                    Colors.black.withAlpha(180),
                    Colors.black.withAlpha(220),
                  ],
                  stops: const [0.0, 0.35, 0.7, 1.0],
                ),
              ),
            ),

            // Content at bottom
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Category overline
                  Text(
                    hobby.category.toUpperCase(),
                    style: AppTypography.overline.copyWith(
                      color: AppColors.textSecondary,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Hobby title — hero text
                  Text(
                    hobby.title,
                    style: AppTypography.hero.copyWith(
                      color: Colors.white,
                      fontSize: 32,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Hook line
                  Text(
                    hobby.hook,
                    style: AppTypography.body.copyWith(
                      color: Colors.white.withAlpha(200),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),

                  // Specs — warm gray middot line
                  Text(
                    '${hobby.costText} · ${hobby.timeText} · ${hobby.difficultyText}',
                    style: AppTypography.data.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  ALTERNATE CARD — Glass card for "More For You"
// ═══════════════════════════════════════════════════════

class _AlternateCard extends StatelessWidget {
  final Hobby hobby;

  const _AlternateCard({required this.hobby});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: () => context.push('/hobby/${hobby.id}'),
      padding: EdgeInsets.zero,
      borderRadius: 16,
      child: SizedBox(
        height: 200,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl: hobby.imageUrl,
                fit: BoxFit.cover,
                memCacheWidth: 400,
                placeholder: (_, __) =>
                    Container(color: AppColors.surfaceElevated),
                errorWidget: (_, __, ___) => Container(
                  color: AppColors.surfaceElevated,
                  child: Icon(AppIcons.categoryIcon(hobby.category),
                      size: 28, color: AppColors.textMuted),
                ),
              ),
            ),

            // Gradient
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withAlpha(160),
                    Colors.black.withAlpha(210),
                  ],
                  stops: const [0.2, 0.65, 1.0],
                ),
              ),
            ),

            // Content
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    hobby.category.toUpperCase(),
                    style: AppTypography.overline.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 9,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hobby.title,
                    style: AppTypography.title.copyWith(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${hobby.costText} · ${hobby.timeText}',
                    style: AppTypography.data.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  COMPACT RAIL — Horizontal scroll for cheap/quick
// ═══════════════════════════════════════════════════════

class _SliverCompactRail extends StatelessWidget {
  final String title;
  final List<Hobby> hobbies;
  final String routeId;

  const _SliverCompactRail({
    required this.title,
    required this.hobbies,
    required this.routeId,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
            child: Row(
              children: [
                Text(title,
                    style: AppTypography.overline
                        .copyWith(color: AppColors.textMuted)),
                const Spacer(),
                GestureDetector(
                  onTap: () => context.push(
                      '/rail-feed/$routeId?title=${Uri.encodeComponent(title)}'),
                  child: Text('See all',
                      style: AppTypography.caption
                          .copyWith(color: AppColors.textSecondary)),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: hobbies.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) =>
                  _CompactCard(hobby: hobbies[index]),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  COMPACT CARD — Small card for horizontal rails
// ═══════════════════════════════════════════════════════

class _CompactCard extends StatelessWidget {
  final Hobby hobby;

  const _CompactCard({required this.hobby});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: () => context.push('/hobby/${hobby.id}'),
      padding: EdgeInsets.zero,
      borderRadius: 14,
      child: SizedBox(
        width: 140,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: CachedNetworkImage(
                imageUrl: hobby.imageUrl,
                fit: BoxFit.cover,
                memCacheWidth: 300,
                placeholder: (_, __) =>
                    Container(color: AppColors.surfaceElevated),
                errorWidget: (_, __, ___) => Container(
                  color: AppColors.surfaceElevated,
                  child: Icon(AppIcons.categoryIcon(hobby.category),
                      size: 24, color: AppColors.textMuted),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withAlpha(150),
                    Colors.black.withAlpha(200),
                  ],
                  stops: const [0.3, 0.7, 1.0],
                ),
              ),
            ),
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
                    style: AppTypography.body.copyWith(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${hobby.costText} · ${hobby.timeText}',
                    style: AppTypography.data.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  SEARCH RESULT ITEM — Inline search result row
// ═══════════════════════════════════════════════════════

class _SearchResultItem extends StatelessWidget {
  final Hobby hobby;
  const _SearchResultItem({required this.hobby});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/hobby/${hobby.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        height: 88,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            // Image
            SizedBox(
              width: 88,
              child: CachedNetworkImage(
                imageUrl: hobby.imageUrl,
                fit: BoxFit.cover,
                memCacheWidth: 176,
                placeholder: (_, __) =>
                    Container(color: AppColors.surfaceElevated),
                errorWidget: (_, __, ___) => Container(
                  color: AppColors.surfaceElevated,
                  child: Icon(AppIcons.categoryIcon(hobby.category),
                      size: 24, color: AppColors.textMuted),
                ),
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      hobby.category.toUpperCase(),
                      style: AppTypography.overline.copyWith(
                          color: AppColors.accent, fontSize: 9),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hobby.title,
                      style: AppTypography.title.copyWith(fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${hobby.costText} · ${hobby.timeText}',
                      style: AppTypography.caption.copyWith(
                          color: AppColors.textMuted, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Icon(Icons.chevron_right_rounded,
                  size: 18, color: AppColors.textWhisper),
            ),
          ],
        ),
      ),
    );
  }
}
