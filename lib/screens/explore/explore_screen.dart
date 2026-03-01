import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
    final categories = ref.watch(categoriesProvider);
    final allHobbies = ref.watch(hobbyListProvider);
    final searchResults = _getSearchResults(allHobbies);

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
                Text('Explore', style: AppTypography.serifHeading),
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
                hintText: 'I want something relaxing...',
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warmWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Max starter cost',
                  style: AppTypography.sansCaption.copyWith(color: AppColors.driftwood)),
              Text('CHF ${_maxCost.round()}',
                  style: AppTypography.monoCaption.copyWith(color: AppColors.coral)),
            ],
          ),
          Slider(
            value: _maxCost,
            min: 0,
            max: 500,
            divisions: 10,
            onChanged: (v) => setState(() => _maxCost = v),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Max hours/week',
                  style: AppTypography.sansCaption.copyWith(color: AppColors.driftwood)),
              Text('${_maxHours.round()}h',
                  style: AppTypography.monoCaption.copyWith(color: AppColors.amber)),
            ],
          ),
          Slider(
            value: _maxHours,
            min: 1,
            max: 10,
            divisions: 9,
            activeColor: AppColors.amber,
            onChanged: (v) => setState(() => _maxHours = v),
          ),
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
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sentiment_neutral, size: 42, color: AppColors.sand),
            const SizedBox(height: 12),
            Text(
              'Nothing found for "$_searchQuery"',
              style: AppTypography.sansBodySmall.copyWith(color: AppColors.driftwood),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 100),
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
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick picks
          Text('QUICK PICKS', style: AppTypography.overline),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                (AppIcons.relaxing, 'Relaxing', AppColors.indigo),
                (AppIcons.social, 'Social', AppColors.coral),
                (AppIcons.cheap, 'Cheap', AppColors.sage),
                (AppIcons.quickStart, 'Quick start', AppColors.amber),
                (AppIcons.outdoors, 'Outdoors', AppColors.catOutdoors),
              ].map((pick) {
                return GestureDetector(
                  onTap: () {
                    _searchController.text = pick.$2;
                    _searchFocusNode.requestFocus();
                    setState(() => _searchQuery = pick.$2);
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: pick.$3.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(Spacing.radiusBadge),
                      border: Border.all(color: pick.$3.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(pick.$1, size: 14, color: pick.$3),
                        const SizedBox(width: 6),
                        Text(
                          pick.$2,
                          style: AppTypography.sansCaption.copyWith(
                            fontWeight: FontWeight.w600,
                            color: pick.$3,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),

          // Categories grid
          Text('CATEGORIES', style: AppTypography.overline),
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
                      categories[i].name;
                  context.go('/feed');
                },
              );
            },
          ),
          const SizedBox(height: 28),

          // Curated Packs
          Row(
            children: [
              Text('Curated Packs', style: AppTypography.sansSection),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.indigoPale,
                  borderRadius: BorderRadius.circular(Spacing.radiusBadge),
                ),
                child: Text(
                  'COMING SOON',
                  style: AppTypography.monoBadgeSmall.copyWith(
                    color: AppColors.indigo,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ..._buildCuratedPacks(),
        ],
      ),
    );
  }

  List<Widget> _buildCuratedPacks() {
    final packs = [
      (AppIcons.packIntroverts, '10 Hobbies for Introverts'),
      (AppIcons.packBudget, 'Weekend Hobbies Under CHF 50'),
      (AppIcons.packCommunity, 'Hobbies That Build Community'),
    ];

    return packs.map((pack) {
      return Container(
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.warmWhite,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(pack.$1, size: 26, color: AppColors.indigo),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                pack.$2,
                style: AppTypography.sansBody.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            Opacity(
              opacity: 0.2,
              child: Icon(AppIcons.lock, size: 14, color: AppColors.warmGray),
            ),
          ],
        ),
      );
    }).toList();
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
