import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../models/hobby.dart';
import '../../providers/hobby_provider.dart';
import '../../theme/category_ui.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_icons.dart';
import '../../theme/app_typography.dart';
import '../../theme/spacing.dart';

/// Search screen — search bar, category chips, result cards with badges.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String? _selectedCategory;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  static const _typeLabels = ['COURSE', 'WORKSHOP', 'KIT + CLASS'];

  String _typeForHobby(Hobby hobby) {
    final hash = hobby.id.hashCode.abs();
    return _typeLabels[hash % _typeLabels.length];
  }

  @override
  Widget build(BuildContext context) {
    final allHobbiesAsync = ref.watch(hobbyListProvider);
    final categories = ref.watch(categoriesProvider).valueOrNull ?? [];

    // Auto-navigate on successful generation
    ref.listen<GenerationState>(generationProvider, (prev, next) {
      if (next.status == GenerationStatus.success && next.hobby != null) {
        ref.read(generationProvider.notifier).reset();
        context.push('/hobby/${next.hobby!.id}');
      }
    });

    return allHobbiesAsync.when(
      loading: () => const SafeArea(child: Center(child: CircularProgressIndicator())),
      error: (err, _) => SafeArea(child: Center(child: Text('$err'))),
      data: (allHobbies) {
    // Filter hobbies by query and category
    var results = _query.isEmpty
        ? <Hobby>[]
        : allHobbies
            .where((h) =>
                h.title.toLowerCase().contains(_query.toLowerCase()) ||
                h.category.toLowerCase().contains(_query.toLowerCase()) ||
                h.tags.any((t) => t.toLowerCase().contains(_query.toLowerCase())))
            .toList();

    if (_selectedCategory != null) {
      results = results
          .where((h) => h.category.toLowerCase() == _selectedCategory!.toLowerCase())
          .toList();
    }

    // "You might also like" — random hobbies not in results
    final resultIds = results.map((h) => h.id).toSet();
    final suggestions = allHobbies
        .where((h) => !resultIds.contains(h.id))
        .take(6)
        .toList();

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: const Icon(Icons.arrow_back,
                      size: 20, color: AppColors.espresso),
                ),
                const Spacer(),
                Text('Search Hobbies', style: AppTypography.sansSection),
                const Spacer(),
                const SizedBox(width: 20),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Search input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.warmWhite,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Opacity(
                    opacity: 0.35,
                    child: Icon(Icons.search, size: 15, color: AppColors.warmGray),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _query = v),
                      style: AppTypography.sansBodySmall,
                      decoration: InputDecoration(
                        hintText: 'Search hobbies, categories...',
                        hintStyle: AppTypography.sansBodySmall.copyWith(color: AppColors.warmGray),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                    ),
                  ),
                  if (_query.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                      child: Icon(AppIcons.close,
                          size: 16, color: AppColors.warmGray),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Category filter chips
          SizedBox(
            height: 32,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                _FilterChip(
                  label: 'All',
                  isSelected: _selectedCategory == null,
                  onTap: () => setState(() => _selectedCategory = null),
                ),
                const SizedBox(width: 6),
                ...categories.map((cat) => Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: _FilterChip(
                    label: cat.name,
                    isSelected: _selectedCategory == cat.id,
                    onTap: () => setState(() =>
                      _selectedCategory = _selectedCategory == cat.id ? null : cat.id,
                    ),
                  ),
                )),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Results or popular searches
          if (_query.isNotEmpty && results.isNotEmpty)
            Expanded(
              child: _buildResultsList(context, ref, results, suggestions),
            )
          else if (_query.isNotEmpty && results.isEmpty)
            Expanded(
              child: Center(child: _buildGenerateCta()),
            )
          else ...[
            // Popular searches
            const SizedBox(height: 12),
            Center(
              child: Text('POPULAR SEARCHES', style: AppTypography.overline),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: allHobbies.take(8).map((h) {
                  final term = h.title.toLowerCase();
                  return GestureDetector(
                    onTap: () {
                      _searchController.text = term;
                      setState(() => _query = term);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.sand,
                        borderRadius: BorderRadius.circular(Spacing.radiusBadge),
                      ),
                      child: Text(
                        term,
                        style: AppTypography.sansCaption.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.driftwood,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
      },
    );
  }

  // Track the last query we auto-fired generation for
  String? _lastAutoGenQuery;

  Widget _buildResultsList(
    BuildContext context,
    WidgetRef ref,
    List<Hobby> results,
    List<Hobby> suggestions,
  ) {
    final genState = ref.watch(generationProvider);
    final isGenerating = genState.status == GenerationStatus.generating;
    final fewResults = results.length < 3;

    // Auto-fire AI generation when <3 results (only once per query)
    if (fewResults && !isGenerating && _lastAutoGenQuery != _query &&
        genState.status != GenerationStatus.error) {
      _lastAutoGenQuery = _query;
      Future.microtask(() {
        ref.read(generationProvider.notifier).generate(_query);
      });
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: Spacing.scrollBottomPadding),
      children: [
        // Top Results header
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
          child: Row(
            children: [
              Text('Top Results', style: AppTypography.sansSection),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.sand,
                  borderRadius: BorderRadius.circular(Spacing.radiusBadge),
                ),
                child: Text(
                  '${results.length} found',
                  style: AppTypography.monoBadgeSmall.copyWith(
                    color: AppColors.driftwood,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Result cards
        ...results.map((hobby) => _SearchResultCard(
          hobby: hobby,
          typeLabel: _typeForHobby(hobby),
          onTap: () => context.push('/hobby/${hobby.id}'),
        )),

        // AI shimmer / generating indicator (when <3 results)
        if (fewResults && isGenerating)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
            child: _AiSearchingTile(),
          ),

        // AI generation error with retry
        if (fewResults && genState.status == GenerationStatus.error)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
            child: GestureDetector(
              onTap: () {
                _lastAutoGenQuery = null;
                ref.read(generationProvider.notifier).generate(_query);
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.warmWhite,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.sandDark),
                ),
                child: Row(
                  children: [
                    Icon(Icons.refresh_rounded, size: 18, color: AppColors.coral),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'AI suggestion failed. Tap to retry.',
                        style: AppTypography.sansCaption.copyWith(
                          color: AppColors.driftwood,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // "You might also like"
        if (suggestions.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
            child: Text('You might also like',
                style: AppTypography.sansSection),
          ),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: suggestions.length,
              itemBuilder: (context, i) {
                final s = suggestions[i];
                return GestureDetector(
                  onTap: () => context.push('/hobby/${s.id}'),
                  child: Container(
                    width: 110,
                    margin: const EdgeInsets.only(right: 10),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            s.imageUrl,
                            width: 110,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 110,
                              height: 80,
                              color: AppColors.sand,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          s.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.sansCaption.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.nearBlack,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildGenerateCta() {
    final genState = ref.watch(generationProvider);
    final isGenerating = genState.status == GenerationStatus.generating;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Opacity(
          opacity: 0.3,
          child: Icon(Icons.search, size: 44, color: AppColors.warmGray),
        ),
        const SizedBox(height: 12),
        Text(
          'No results for "$_query"',
          style: AppTypography.sansBody.copyWith(color: AppColors.warmGray),
        ),
        const SizedBox(height: 20),
        if (isGenerating)
          Column(
            children: [
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.coral,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Generating hobby...',
                style: AppTypography.sansCaption.copyWith(
                  color: AppColors.driftwood,
                ),
              ),
            ],
          )
        else if (genState.status == GenerationStatus.error)
          Column(
            children: [
              Text(
                'Something went wrong. Try again?',
                style: AppTypography.sansCaption.copyWith(
                  color: AppColors.warmGray,
                ),
              ),
              if (genState.error != null) ...[
                const SizedBox(height: 6),
                Text(
                  genState.error!,
                  style: AppTypography.monoTiny.copyWith(
                    color: AppColors.warmGray,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 10),
              _generateButton(),
            ],
          )
        else
          _generateButton(),
      ],
    );
  }

  Widget _generateButton() {
    return GestureDetector(
      onTap: () {
        ref.read(generationProvider.notifier).generate(_query);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.coral,
          borderRadius: BorderRadius.circular(Spacing.radiusButton),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(MdiIcons.creationOutline, size: 16, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              'Generate this hobby',
              style: AppTypography.sansCta.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  SEARCH RESULT CARD
// ═══════════════════════════════════════════════════════

class _SearchResultCard extends StatelessWidget {
  final Hobby hobby;
  final String typeLabel;
  final VoidCallback onTap;

  const _SearchResultCard({
    required this.hobby,
    required this.typeLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final catColor = hobby.catColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 10),
        decoration: BoxDecoration(
          color: AppColors.warmWhite,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            // Hobby image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                hobby.imageUrl,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 56,
                  height: 56,
                  color: AppColors.sand,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type badge + rating
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: catColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          typeLabel,
                          style: AppTypography.monoBadgeSmall.copyWith(
                            color: catColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.star_rounded,
                          size: 12, color: AppColors.amber),
                      const SizedBox(width: 2),
                      Text(
                        '4.${hobby.id.hashCode.abs() % 5 + 5}',
                        style: AppTypography.monoBadgeSmall.copyWith(
                          color: AppColors.driftwood,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),

                  // Title
                  Text(
                    hobby.title,
                    style: AppTypography.sansBody.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.nearBlack,
                    ),
                  ),
                  const SizedBox(height: 2),

                  // Hook
                  Text(
                    hobby.hook,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.sansCaption.copyWith(
                      color: AppColors.warmGray,
                    ),
                  ),
                ],
              ),
            ),

            // Price + arrow
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  hobby.costText,
                  style: AppTypography.monoBadge.copyWith(
                    color: AppColors.nearBlack,
                  ),
                ),
                const SizedBox(height: 8),
                Icon(Icons.arrow_forward_ios_rounded,
                    size: 12, color: AppColors.stone),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  FILTER CHIP
// ═══════════════════════════════════════════════════════

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.coral : AppColors.warmWhite,
          borderRadius: BorderRadius.circular(Spacing.radiusBadge),
        ),
        child: Text(
          label,
          style: AppTypography.sansCaption.copyWith(
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.driftwood,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  AI SEARCHING SHIMMER TILE
// ═══════════════════════════════════════════════════════

class _AiSearchingTile extends StatefulWidget {
  @override
  State<_AiSearchingTile> createState() => _AiSearchingTileState();
}

class _AiSearchingTileState extends State<_AiSearchingTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        final opacity = 0.4 + 0.3 * (0.5 + 0.5 * math.sin(_shimmerController.value * 2 * math.pi));
        return Opacity(opacity: opacity, child: child);
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.warmWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.sandDark),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.sand,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(MdiIcons.creationOutline,
                    size: 22, color: AppColors.coral),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Finding more for you...',
                    style: AppTypography.sansCaption.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.nearBlack,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'AI is generating a custom hobby',
                    style: AppTypography.sansTiny.copyWith(
                      color: AppColors.driftwood,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.coral,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

