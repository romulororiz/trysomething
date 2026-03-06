import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../models/hobby.dart';
import '../../theme/category_ui.dart';
import '../../providers/hobby_provider.dart';
import '../../components/category_tile.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_icons.dart';
import '../../theme/app_typography.dart';
import '../../theme/spacing.dart';
import '../../theme/motion.dart';
import '../../theme/scroll_physics.dart';

/// Explore — category grid, quick picks, curated packs, filter panel.
class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  bool _showFilters = false;
  double _maxCost = 200;
  double _maxHours = 5;
  int _selectedFilter = 0; // 0=All, 1=Trending, 2=New, 3=For You

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';

  bool get _searchActive => _searchFocusNode.hasFocus || _searchQuery.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    _searchFocusNode.unfocus();
    setState(() => _searchQuery = '');
  }

  List<Hobby> _getSearchResults(List<Hobby> all) {
    if (_searchQuery.isEmpty) return [];
    final q = _searchQuery.toLowerCase();
    return all.where((h) =>
      h.title.toLowerCase().contains(q) ||
      h.category.toLowerCase().contains(q) ||
      h.tags.any((t) => t.toLowerCase().contains(q)) ||
      h.hook.toLowerCase().contains(q),
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider).valueOrNull ?? [];
    final allHobbies = ref.watch(hobbyListProvider).valueOrNull ?? [];
    final searchResults = _getSearchResults(allHobbies);

    // Auto-navigate on successful generation
    ref.listen<GenerationState>(generationProvider, (prev, next) {
      if (next.status == GenerationStatus.success && next.hobby != null) {
        ref.read(generationProvider.notifier).reset();
        // Clear search so user returns to explore grid (hobby is now in the list)
        _searchController.clear();
        _searchFocusNode.unfocus();
        setState(() => _searchQuery = '');
        context.push('/hobby/${next.hobby!.id}');
      }
    });

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header + search bar (always visible)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Explore', style: AppTypography.serifHeading),
                    const Spacer(),
                    // Notification bell with green dot
                    Stack(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.sand,
                          ),
                          child: const Icon(Icons.notifications_none_rounded,
                              size: 20, color: AppColors.driftwood),
                        ),
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.sage,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: _buildSearchField()),
                    if (!_searchActive) ...[
                      const SizedBox(width: 8),
                      _buildFilterButton(),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Filter panel (only in explore mode)
          if (!_searchActive)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: AnimatedCrossFade(
                firstChild: const SizedBox(width: double.infinity, height: 0),
                secondChild: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: _buildFilterPanel(),
                ),
                crossFadeState: _showFilters
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: Motion.filterToggle,
                sizeCurve: Motion.normalCurve,
              ),
            ),

          // Filter chips (only in explore mode)
          if (!_searchActive)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: ['All', 'Trending', 'New', 'For You']
                      .asMap()
                      .entries
                      .map((e) {
                    final isActive = _selectedFilter == e.key;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _selectedFilter = e.key),
                        child: AnimatedContainer(
                          duration: Motion.fast,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.coral
                                : AppColors.warmWhite,
                            borderRadius: BorderRadius.circular(
                                Spacing.radiusBadge),
                          ),
                          child: Text(
                            e.value,
                            style: AppTypography.sansCaption.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isActive
                                  ? Colors.white
                                  : AppColors.driftwood,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

          // Body — switches between search results and explore content
          Expanded(
            child: _searchActive
                ? _buildSearchResults(searchResults)
                : _buildExploreContent(categories),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return AnimatedContainer(
      duration: Motion.fast,
      height: 46,
      decoration: BoxDecoration(
        color: AppColors.warmWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Opacity(
            opacity: 0.35,
            child: Icon(Icons.search, size: 15, color: AppColors.warmGray),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onChanged: (val) => setState(() => _searchQuery = val),
              style: AppTypography.sansBodySmall.copyWith(color: AppColors.nearBlack),
              decoration: InputDecoration(
                hintText: 'Search hobbies, skills, interests...',
                hintStyle: AppTypography.sansBodySmall.copyWith(color: AppColors.warmGray),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (_searchActive)
            GestureDetector(
              onTap: _clearSearch,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(Icons.close, size: 16, color: AppColors.warmGray),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterButton() {
    return GestureDetector(
      onTap: () => setState(() => _showFilters = !_showFilters),
      child: AnimatedContainer(
        duration: Motion.fast,
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: _showFilters ? AppColors.coralPale : AppColors.warmWhite,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Icon(
            AppIcons.settings,
            size: 16,
            color: _showFilters ? AppColors.coral : AppColors.driftwood,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterPanel() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      decoration: BoxDecoration(
        color: AppColors.warmWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.sandDark, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header + reset
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('FILTER', style: AppTypography.overline),
              GestureDetector(
                onTap: () => setState(() {
                  _maxCost = 200;
                  _maxHours = 5;
                }),
                child: Text(
                  'Reset',
                  style: AppTypography.sansCaption.copyWith(
                    color: AppColors.coral,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Cost row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(AppIcons.badgeCost, size: 13, color: AppColors.coral),
                  const SizedBox(width: 6),
                  Text(
                    'Max starter cost',
                    style: AppTypography.sansCaption.copyWith(color: AppColors.driftwood),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.coralPale,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'CHF ${_maxCost.round()}',
                  style: AppTypography.monoBadgeSmall.copyWith(color: AppColors.coral),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 2.5,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
              activeTrackColor: AppColors.coral,
              inactiveTrackColor: AppColors.sandDark,
              thumbColor: AppColors.coral,
              overlayColor: AppColors.coral.withValues(alpha: 0.15),
            ),
            child: Slider(
              value: _maxCost,
              min: 0,
              max: 500,
              divisions: 10,
              onChanged: (v) => setState(() => _maxCost = v),
            ),
          ),
          const SizedBox(height: 4),

          // Hours row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(AppIcons.badgeTime, size: 13, color: AppColors.amber),
                  const SizedBox(width: 6),
                  Text(
                    'Max hours / week',
                    style: AppTypography.sansCaption.copyWith(color: AppColors.driftwood),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.amberPale,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${_maxHours.round()}h',
                  style: AppTypography.monoBadgeSmall.copyWith(color: AppColors.amber),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 2.5,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
              activeTrackColor: AppColors.amber,
              inactiveTrackColor: AppColors.sandDark,
              thumbColor: AppColors.amber,
              overlayColor: AppColors.amber.withValues(alpha: 0.15),
            ),
            child: Slider(
              value: _maxHours,
              min: 1,
              max: 10,
              divisions: 9,
              onChanged: (v) => setState(() => _maxHours = v),
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  // ─── Search Results ────────────────────────────────────────────────────────

  Widget _buildSearchResults(List<Hobby> results) {
    if (_searchQuery.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search, size: 42, color: AppColors.sand),
            const SizedBox(height: 12),
            Text(
              'Start typing to find hobbies',
              style: AppTypography.sansBodySmall.copyWith(color: AppColors.driftwood),
            ),
          ],
        ),
      );
    }

    if (results.isEmpty) {
      final genState = ref.watch(generationProvider);
      final isGenerating = genState.status == GenerationStatus.generating;

      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.sentiment_neutral, size: 42, color: AppColors.sand),
              const SizedBox(height: 12),
              Text(
                'Nothing found for "$_searchQuery"',
                textAlign: TextAlign.center,
                style: AppTypography.sansBodySmall.copyWith(color: AppColors.driftwood),
              ),
              const SizedBox(height: 20),
              if (isGenerating) ...[
                const SizedBox(
                  width: 24, height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.coral),
                ),
                const SizedBox(height: 10),
                Text('Generating hobby...', style: AppTypography.sansCaption.copyWith(color: AppColors.driftwood)),
              ] else if (genState.status == GenerationStatus.error) ...[
                Text('Something went wrong. Try again?', style: AppTypography.sansCaption.copyWith(color: AppColors.warmGray)),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => ref.read(generationProvider.notifier).generate(_searchQuery),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(color: AppColors.coral, borderRadius: BorderRadius.circular(Spacing.radiusButton)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(MdiIcons.creationOutline, size: 16, color: Colors.white),
                        const SizedBox(width: 8),
                        Text('Generate this hobby', style: AppTypography.sansCta.copyWith(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ] else
                GestureDetector(
                  onTap: () => ref.read(generationProvider.notifier).generate(_searchQuery),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(color: AppColors.coral, borderRadius: BorderRadius.circular(Spacing.radiusButton)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(MdiIcons.creationOutline, size: 16, color: Colors.white),
                        const SizedBox(width: 8),
                        Text('Generate this hobby', style: AppTypography.sansCta.copyWith(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, Spacing.scrollBottomPadding),
      itemCount: results.length,
      itemBuilder: (context, i) => _buildSearchTile(results[i]),
    );
  }

  Widget _buildSearchTile(Hobby hobby) {
    return GestureDetector(
      onTap: () {
        _searchFocusNode.unfocus();
        context.push('/hobby/${hobby.id}');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.warmWhite,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: hobby.imageUrl,
                width: 58,
                height: 58,
                fit: BoxFit.cover,
                placeholder: (_, __) =>
                    Container(color: AppColors.sand, width: 58, height: 58),
                errorWidget: (_, __, ___) =>
                    Container(color: AppColors.sand, width: 58, height: 58),
              ),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hobby.title,
                    style: AppTypography.sansBodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.nearBlack,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(hobby.catIcon, size: 11, color: hobby.catColor),
                      const SizedBox(width: 4),
                      Text(
                        hobby.category,
                        style: AppTypography.sansCaption.copyWith(
                          color: AppColors.driftwood,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _MiniSpec(
                        label: hobby.costText,
                        color: AppColors.coral,
                      ),
                      const SizedBox(width: 6),
                      _MiniSpec(
                        label: hobby.difficultyText,
                        color: AppColors.indigo,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Icon(Icons.chevron_right, size: 18, color: AppColors.warmGray),
          ],
        ),
      ),
    );
  }

  // ─── Explore Content ───────────────────────────────────────────────────────

  Widget _buildExploreContent(List<HobbyCategory> categories) {
    return SingleChildScrollView(
      physics: const TryScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 4, 24, Spacing.scrollBottomPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Categories grid
          Text('BROWSE CATEGORIES', style: AppTypography.overline),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: categories.length,
            itemBuilder: (context, i) {
              return CategoryTile(
                category: categories[i],
                onTap: () {
                  ref.read(selectedCategoryProvider.notifier).state =
                      categories[i].id;
                  context.go('/feed');
                },
              );
            },
          ),
          const SizedBox(height: 16),

          // Show all link
          Center(
            child: GestureDetector(
              onTap: () {
                ref.read(selectedCategoryProvider.notifier).state = null;
                context.go('/feed');
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Show All Categories',
                    style: AppTypography.sansLabel.copyWith(
                      color: AppColors.coral,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward,
                      size: 14, color: AppColors.coral),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Quick Actions
          Text('QUICK ACTIONS', style: AppTypography.overline),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.compare_arrows_rounded,
                  label: 'Hobby Battle',
                  subtitle: 'Compare 2 hobbies',
                  color: AppColors.coral,
                  onTap: () => context.push('/compare'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.park_rounded,
                  label: 'Seasonal',
                  subtitle: 'What\'s trending',
                  color: AppColors.sage,
                  onTap: () => context.push('/seasonal'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.local_fire_department_rounded,
                  label: 'Combos',
                  subtitle: 'Paired hobbies',
                  color: AppColors.amber,
                  onTap: () => context.push('/combos'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.people_outline_rounded,
                  label: 'Community',
                  subtitle: 'Stories & tips',
                  color: AppColors.sky,
                  onTap: () => context.push('/stories'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Curated Packs
          Text('Curated Packs', style: AppTypography.sansSection),
          const SizedBox(height: 14),
          ..._buildCuratedPacks(),
        ],
      ),
    );
  }

  static final _packIcons = <String, IconData>{
    'introvert': AppIcons.packIntroverts,
    'budget': AppIcons.packBudget,
    'community': AppIcons.packCommunity,
  };

  List<Widget> _buildCuratedPacks() {
    final packsAsync = ref.watch(curatedPacksProvider);

    return packsAsync.when(
      loading: () => [
        for (var i = 0; i < 3; i++)
          Container(
            height: 56,
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: AppColors.warmWhite,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
      ],
      error: (_, __) => [
        // Fallback to static labels on error
        for (final label in [
          '10 Hobbies for Introverts',
          'Weekend Hobbies Under CHF 50',
          'Hobbies That Build Community',
        ])
          Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: AppColors.warmWhite,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(AppIcons.packIntroverts, size: 26, color: AppColors.indigo),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: AppTypography.sansBody.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
      ],
      data: (packs) => packs.map((pack) {
        final icon = _packIcons[pack.icon] ?? AppIcons.packIntroverts;
        return GestureDetector(
          onTap: () {
            // Search for the first tag keyword from the pack title
            final keyword = pack.title.split(' ').last;
            _searchController.text = keyword;
            _searchFocusNode.requestFocus();
            setState(() => _searchQuery = keyword);
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: AppColors.warmWhite,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(icon, size: 26, color: AppColors.indigo),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pack.title,
                        style: AppTypography.sansBody.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${pack.hobbies.length} hobbies',
                        style: AppTypography.sansTiny.copyWith(color: AppColors.warmGray),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, size: 16, color: AppColors.warmGray),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Mini spec label (for search tiles) ──────────────────────────────────────

class _MiniSpec extends StatelessWidget {
  final String label;
  final Color color;

  const _MiniSpec({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(Spacing.radiusBadge),
      ),
      child: Text(
        label,
        style: AppTypography.monoBadgeSmall.copyWith(color: color),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.warmWhite,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.sansCaption.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.nearBlack,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTypography.sansTiny.copyWith(
                      color: AppColors.warmGray,
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
