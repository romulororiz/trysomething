import 'dart:async';
import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../models/hobby.dart';
import '../../providers/hobby_provider.dart';
import '../../core/hobby_match.dart';
import '../../theme/category_ui.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_icons.dart';
import '../../theme/app_typography.dart';
import '../../theme/spacing.dart';
import '../../providers/subscription_provider.dart';
import '../../components/app_background.dart';

// ═══════════════════════════════════════════════════════
//  NATURAL LANGUAGE KEYWORD MAP
// ═══════════════════════════════════════════════════════

/// Maps common natural language terms to hobby tags/categories for fuzzy matching.
const _nlpKeywords = <String, List<String>>{
  'cheap': ['budget', 'free', 'affordable'],
  'free': ['budget', 'free'],
  'creative': ['creative'],
  'anxiety': ['relaxing', 'meditative', 'calming', 'mindful'],
  'stress': ['relaxing', 'meditative', 'calming'],
  'relax': ['relaxing', 'meditative', 'calming'],
  'calm': ['calming', 'meditative', 'relaxing'],
  'indoor': ['indoor', 'at-home', 'home'],
  'home': ['indoor', 'at-home', 'home'],
  'winter': ['indoor', 'at-home'],
  'outdoor': ['outdoors', 'outdoor', 'nature'],
  'outside': ['outdoors', 'outdoor'],
  'social': ['social', 'group'],
  'friends': ['social', 'group'],
  'couple': ['social', 'romantic'],
  'couples': ['social', 'romantic'],
  'partner': ['social', 'romantic'],
  'date': ['social', 'romantic'],
  'together': ['social'],
  'solo': ['solo'],
  'alone': ['solo', 'indoor'],
  'active': ['physical', 'active', 'fitness'],
  'exercise': ['physical', 'fitness', 'active'],
  'fitness': ['fitness', 'physical'],
  'craft': ['creative', 'maker'],
  'art': ['creative'],
  'music': ['music'],
  'cooking': ['culinary', 'food'],
  'food': ['culinary', 'food'],
  'nature': ['outdoors', 'nature'],
  'mindful': ['meditative', 'mindful', 'relaxing'],
  'meditation': ['meditative', 'mindful'],
  'hands': ['creative', 'maker'],
  'screen': ['physical', 'outdoors', 'creative'], // reduce screen time
  'easy': ['easy'],
  'beginner': ['easy'],
  'simple': ['easy'],
  'quick': ['easy'],
  'low': ['budget', 'easy'],
  'pressure': ['relaxing', 'solo', 'calming'],
  'gentle': ['relaxing', 'easy', 'calming'],
  'fun': ['playful', 'social'],
  'boring': ['creative', 'active', 'outdoors'],
  'lonely': ['social', 'group'],
  'tired': ['relaxing', 'easy', 'calming'],
  'energy': ['active', 'physical', 'fitness'],
  'focus': ['meditative', 'mindful', 'creative'],
  'productive': ['creative', 'maker'],
  'weekend': ['outdoors', 'social'],
  'evening': ['indoor', 'relaxing', 'creative'],
  'morning': ['active', 'outdoors', 'fitness'],
};

/// NLP-friendly search suggestions shown when the search bar is empty.
const _nlpSuggestions = [
  'cheap creative hobby',
  'hobby for anxiety',
  'indoor winter hobby',
  'social but low pressure',
  'something with my hands',
  'hobby for couples',
  'active outdoors',
  'easy solo at home',
  'reduce screen time',
  'mindful and calm',
];

/// Search screen — search bar, category chips, result cards with badges.
class SearchScreen extends ConsumerStatefulWidget {
  final String initialQuery;
  const SearchScreen({super.key, this.initialQuery = ''});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _searchController;
  late String _query;
  String? _selectedCategory;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _query = widget.initialQuery;
    _searchController = TextEditingController(text: widget.initialQuery);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    // Reset generation state when leaving the screen
    ref.read(generationProvider.notifier).reset();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) {
        // Clear stale error when user types a new query
        final gen = ref.read(generationProvider);
        if (gen.status == GenerationStatus.error) {
          ref.read(generationProvider.notifier).reset();
        }
        setState(() => _query = value);
      }
    });
  }

  void _onSearchSubmitted(String value) {
    _debounce?.cancel();
    setState(() => _query = value);
  }

  List<Hobby> _filterHobbies(List<Hobby> allHobbies) {
    if (_query.isEmpty) return [];
    final q = _query.toLowerCase();
    final words = q.split(RegExp(r'\s+')).where((w) => w.length > 1).toList();

    // Collect NLP-expanded tags from all query words
    final expandedTags = <String>{};
    for (final word in words) {
      for (final entry in _nlpKeywords.entries) {
        if (word.contains(entry.key) || entry.key.contains(word)) {
          expandedTags.addAll(entry.value);
        }
      }
    }

    // Score each hobby: direct match (title/category/tag) + NLP tag match
    final scored = <(Hobby, int)>[];
    for (final h in allHobbies) {
      int score = 0;

      // Direct title match (strong signal)
      if (h.title.toLowerCase().contains(q)) score += 10;

      // Per-word title match (partial)
      for (final w in words) {
        if (h.title.toLowerCase().contains(w)) score += 4;
      }

      // Category match
      if (h.category.toLowerCase().contains(q)) score += 5;

      // Hook / whyLove text match (natural language match)
      final hookLower = h.hook.toLowerCase();
      final whyLower = h.whyLove.toLowerCase();
      for (final w in words) {
        if (hookLower.contains(w)) score += 2;
        if (whyLower.contains(w)) score += 2;
      }

      // Tag match (direct)
      for (final t in h.tags) {
        if (words.any((w) => t.toLowerCase().contains(w))) score += 3;
      }

      // NLP-expanded tag match
      for (final t in h.tags) {
        if (expandedTags.contains(t.toLowerCase())) score += 2;
      }

      // Difficulty match for "easy"/"beginner" queries
      if (expandedTags.contains('easy') &&
          h.difficultyText.toLowerCase() == 'easy') {
        score += 2;
      }

      // Budget match for "cheap"/"free" queries
      if (expandedTags.contains('budget') || expandedTags.contains('free')) {
        final (_, max) = parseCostRange(h.costText);
        if (max <= 30) score += 3;
      }

      if (score > 0) scored.add((h, score));
    }

    // Sort by score descending
    scored.sort((a, b) => b.$2.compareTo(a.$2));
    var results = scored.map((e) => e.$1).toList();

    // Apply category filter if set
    if (_selectedCategory != null) {
      results = results
          .where((h) =>
              h.category.toLowerCase() == _selectedCategory!.toLowerCase())
          .toList();
    }
    return results;
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

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: AppBackground(
        child: allHobbiesAsync.when(
          loading: () =>
              const SafeArea(child: Center(child: CircularProgressIndicator())),
          error: (err, _) => SafeArea(child: Center(child: Text('$err'))),
          data: (allHobbies) {
            final results = _filterHobbies(allHobbies);

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
                  // Header — title left, X close right
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 16, 0),
                    child: Row(
                      children: [
                        Text('Search',
                            style: AppTypography.title.copyWith(
                              fontSize: 18,
                              color: AppColors.textPrimary,
                            )),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.glassBackground,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: AppColors.glassBorder, width: 0.5),
                            ),
                            child: const Icon(Icons.close_rounded,
                                size: 18, color: AppColors.textSecondary),
                          ),
                        ),
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
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Opacity(
                            opacity: 0.35,
                            child: Icon(Icons.search,
                                size: 15, color: AppColors.textMuted),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              autofocus: true,
                              onChanged: _onSearchChanged,
                              onSubmitted: _onSearchSubmitted,
                              textInputAction: TextInputAction.search,
                              style: AppTypography.sansBodySmall,
                              decoration: InputDecoration(
                                hintText: 'Search hobbies, categories...',
                                hintStyle: AppTypography.sansBodySmall
                                    .copyWith(color: AppColors.textMuted),
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
                                _debounce?.cancel();
                                setState(() => _query = '');
                              },
                              child: Icon(AppIcons.close,
                                  size: 16, color: AppColors.textMuted),
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
                                onTap: () => setState(
                                  () => _selectedCategory =
                                      _selectedCategory == cat.id
                                          ? null
                                          : cat.id,
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Results or popular searches
                  if (_query.isNotEmpty &&
                      ref.watch(generationProvider).status ==
                          GenerationStatus.generating &&
                      results.isEmpty)
                    Expanded(
                      child: Center(child: _AiGeneratingHero(query: _query)),
                    )
                  else if (_query.isNotEmpty && results.isNotEmpty)
                    Expanded(
                      child:
                          _buildResultsList(context, ref, results, suggestions),
                    )
                  else if (_query.isNotEmpty && results.isEmpty)
                    Expanded(
                      child: Center(child: _buildGenerateCta()),
                    )
                  else ...[
                    // Natural language search suggestions
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'Try searching for...',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _nlpSuggestions.map((suggestion) {
                          return GestureDetector(
                            onTap: () {
                              _searchController.text = suggestion;
                              setState(() => _query = suggestion);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius:
                                    BorderRadius.circular(Spacing.radiusBadge),
                                border: Border.all(
                                    color: AppColors.border, width: 0.5),
                              ),
                              child: Text(
                                suggestion,
                                style: AppTypography.caption.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
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
        ),
      ),
    );
  }

  Widget _buildResultsList(
    BuildContext context,
    WidgetRef ref,
    List<Hobby> results,
    List<Hobby> suggestions,
  ) {
    final genState = ref.watch(generationProvider);
    final isGenerating = genState.status == GenerationStatus.generating;
    final fewResults = results.length < 3;
    final isPro = ref.watch(isProProvider);

    return ListView(
      padding: EdgeInsets.only(bottom: Spacing.scrollBottom(context)),
      children: [
        // Top Results header
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
          child: Row(
            children: [
              Text('Top Results',
                  style: AppTypography.title.copyWith(fontSize: 17)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(Spacing.radiusBadge),
                ),
                child: Text(
                  '${results.length} found',
                  style: AppTypography.monoBadgeSmall.copyWith(
                    color: AppColors.textSecondary,
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

        // Pro: AI generating indicator (when <3 results)
        if (isPro && fewResults && isGenerating)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
            child: _AiSearchingTile(),
          ),

        // Pro: AI generation error with retry
        if (isPro && fewResults && genState.status == GenerationStatus.error)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
            child: GestureDetector(
              onTap: () {
                ref.read(generationProvider.notifier).generate(_query);
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.refresh_rounded,
                        size: 18, color: AppColors.coral),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'AI suggestion failed. Tap to retry.',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // "You might also like" — vertical premium cards
        if (suggestions.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
            child: Text('You might also like',
                style: AppTypography.title.copyWith(fontSize: 17)),
          ),
          ...suggestions.map((s) => _SuggestionCard(hobby: s)),
          const SizedBox(height: 20),
        ],
      ],
    );
  }

  Widget _buildGenerateCta() {
    final genState = ref.watch(generationProvider);
    final hasError = genState.status == GenerationStatus.error;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Opacity(
            opacity: 0.3,
            child: Icon(
              hasError ? Icons.error_outline_rounded : Icons.search,
              size: 44,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            hasError
                ? (genState.error ?? 'Something went wrong')
                : 'No results for "$_query"',
            style: AppTypography.body.copyWith(
              color: AppColors.textMuted,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          _generateButton(),
        ],
      ),
    );
  }

  Widget _generateButton() {
    final isPro = ref.watch(isProProvider);
    final isGenerating =
        ref.watch(generationProvider).status == GenerationStatus.generating;
    return GestureDetector(
      onTap: isGenerating
          ? null
          : () {
              if (!isPro) {
                context.push('/pro');
                return;
              }
              ref.read(generationProvider.notifier).generate(_query);
              // ref.read(generationProvider.notifier).debugFakeGenerating();
            },
      child: Opacity(
        opacity: isGenerating ? 0.5 : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            // Hobby image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: hobby.imageUrl,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(
                  width: 56,
                  height: 56,
                  color: AppColors.surfaceElevated,
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
                      const Icon(Icons.star_rounded,
                          size: 12, color: AppColors.amber),
                      const SizedBox(width: 2),
                      Text(
                        '4.${hobby.id.hashCode.abs() % 5 + 5}',
                        style: AppTypography.monoBadgeSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),

                  // Title
                  Text(
                    hobby.title,
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),

                  // Hook
                  Text(
                    hobby.hook,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textMuted,
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
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 12, color: AppColors.textWhisper),
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent.withValues(alpha: 0.15)
              : AppColors.glassBackground,
          borderRadius: BorderRadius.circular(Spacing.radiusBadge),
          border: Border.all(
            color: isSelected
                ? AppColors.accent.withValues(alpha: 0.4)
                : AppColors.glassBorder,
            width: 0.5,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.caption.copyWith(
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.accent : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  SUGGESTION CARD  (You might also like)
// ═══════════════════════════════════════════════════════

class _SuggestionCard extends StatelessWidget {
  final Hobby hobby;
  const _SuggestionCard({required this.hobby});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/hobby/${hobby.id}'),
      child: Container(
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero image
            SizedBox(
              height: 140,
              width: double.infinity,
              child: CachedNetworkImage(
                imageUrl: hobby.imageUrl,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) =>
                    Container(color: AppColors.surfaceElevated),
              ),
            ),
            // Info row
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hobby.category.toUpperCase(),
                          style: AppTypography.monoBadgeSmall.copyWith(
                            color: AppColors.accent,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          hobby.title,
                          style: AppTypography.body.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          hobby.hook,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.arrow_forward_ios_rounded,
                      size: 13, color: AppColors.textWhisper),
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
//  AI SEARCHING SHIMMER TILE
// ═══════════════════════════════════════════════════════

class _AiSearchingTile extends StatefulWidget {
  @override
  State<_AiSearchingTile> createState() => _AiSearchingTileState();
}

class _AiSearchingTileState extends State<_AiSearchingTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        // Eased progress: fast start, slow finish (never reaches 1.0)
        final t = _controller.value;
        final progress = 1.0 - math.pow(1.0 - t * 0.95, 3);

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.coral.withValues(alpha: 0.15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(MdiIcons.creationOutline,
                      size: 16, color: AppColors.coral),
                  const SizedBox(width: 8),
                  Text(
                    'Generating with AI...',
                    style: AppTypography.caption.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 3,
                  backgroundColor: AppColors.surfaceElevated,
                  valueColor: const AlwaysStoppedAnimation(AppColors.coral),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════
//  AI GENERATING HERO — full-screen premium generation state
// ═══════════════════════════════════════════════════════

class _AiGeneratingHero extends ConsumerStatefulWidget {
  final String query;
  const _AiGeneratingHero({required this.query});

  @override
  ConsumerState<_AiGeneratingHero> createState() => _AiGeneratingHeroState();
}

class _AiGeneratingHeroState extends ConsumerState<_AiGeneratingHero> {
  int _elapsed = 0;
  late Timer _timer;

  static const _phases = [
    'Understanding your interest...',
    'Researching the best approach...',
    'Crafting your roadmap...',
    'Building your hobby guide...',
    'Polishing the details...',
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _elapsed++);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get _phaseText {
    // Cycle through phases, spending ~4s on each
    final idx = (_elapsed ~/ 4).clamp(0, _phases.length - 1);
    return _phases[idx];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 120, 24, 0),
      child: Column(
        children: [
          // Animated icon
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            builder: (_, v, child) => Opacity(
              opacity: v,
              child: Transform.scale(scale: 0.8 + 0.2 * v, child: child),
            ),
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.coral.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(MdiIcons.creationOutline,
                  size: 28, color: AppColors.coral),
            ),
          ),
          const SizedBox(height: 24),

          // Query title
          Text(
            '"${widget.query}"',
            style: AppTypography.title.copyWith(fontSize: 20),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Phase text — animated crossfade
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              _phaseText,
              key: ValueKey(_phaseText),
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Indeterminate pulsing progress bar (honest — no fake percentage)
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: const LinearProgressIndicator(
              minHeight: 5,
              backgroundColor: AppColors.surfaceElevated,
              valueColor: AlwaysStoppedAnimation(AppColors.coral),
            ),
          ),
          const SizedBox(height: 12),

          // Elapsed time
          Text(
            '${_elapsed}s elapsed',
            style: AppTypography.caption.copyWith(
              color: AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 32),

          // Cancel button
          GestureDetector(
            onTap: () => ref.read(generationProvider.notifier).cancel(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.glassBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.glassBorder, width: 0.5),
              ),
              child: Text(
                'Cancel',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
