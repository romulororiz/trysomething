import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../providers/hobby_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../components/pro_upgrade_sheet.dart';
import '../../core/hobby_match.dart';
import '../../models/hobby.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_icons.dart';
import '../../theme/app_typography.dart';
import '../../theme/spacing.dart';
import '../../components/app_background.dart';
import '../../components/glass_card.dart';

// ═══════════════════════════════════════════════════════
//  NLP SEARCH KEYWORDS
// ═══════════════════════════════════════════════════════

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
  'solo': ['solo'],
  'alone': ['solo', 'indoor'],
  'active': ['physical', 'active', 'fitness'],
  'exercise': ['physical', 'fitness', 'active'],
  'fitness': ['fitness', 'physical'],
  'craft': ['creative', 'maker'],
  'art': ['creative'],
  'music': ['music'],
  'food': ['culinary', 'food'],
  'nature': ['outdoors', 'nature'],
  'mindful': ['meditative', 'mindful', 'relaxing'],
  'meditation': ['meditative', 'mindful'],
  'easy': ['easy'],
  'beginner': ['easy'],
  'simple': ['easy'],
  'low': ['budget', 'easy'],
  'pressure': ['relaxing', 'solo', 'calming'],
  'gentle': ['relaxing', 'easy', 'calming'],
  'screen': ['physical', 'outdoors', 'creative'],
  'tired': ['relaxing', 'easy', 'calming'],
  'focus': ['meditative', 'mindful', 'creative'],
  'productive': ['creative', 'maker'],
  'evening': ['indoor', 'relaxing', 'creative'],
  'morning': ['active', 'outdoors', 'fitness'],
};

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
  String? _selectedSearchCategory;
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
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
        bottom: false,
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
          data: (allHobbies) => Stack(
            children: [
              // Rails always present underneath — no rebuild on toggle
              _buildDiscoverRails(allHobbies, prefs),
              // Search overlay fades in on top
              AnimatedOpacity(
                opacity: _searchActive ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                child: IgnorePointer(
                  ignoring: !_searchActive,
                  child: _buildSearchViewScrollable(allHobbies),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  // ── Search bar as a SliverPersistentHeader delegate ──

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
                                filled: true,
                                fillColor: Colors.transparent,
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

  List<Hobby> _nlpSearch(List<Hobby> allHobbies) {
    if (_searchQuery.isEmpty) return [];
    final q = _searchQuery.toLowerCase();
    final words = q.split(RegExp(r'\s+')).where((w) => w.length > 1).toList();
    final expandedTags = <String>{};
    for (final word in words) {
      for (final entry in _nlpKeywords.entries) {
        if (word == entry.key || (word.length > 3 && entry.key.startsWith(word))) {
          expandedTags.addAll(entry.value);
        }
      }
    }
    final scored = <(Hobby, int)>[];
    for (final h in allHobbies) {
      int score = 0;
      if (h.title.toLowerCase().contains(q)) score += 10;
      for (final w in words) {
        if (h.title.toLowerCase().contains(w)) score += 4;
      }
      if (h.category.toLowerCase().contains(q)) score += 5;
      for (final w in words) {
        if (h.hook.toLowerCase().contains(w)) score += 2;
      }
      for (final t in h.tags) {
        if (words.any((w) => t.toLowerCase().contains(w))) score += 3;
        if (expandedTags.contains(t.toLowerCase())) score += 2;
      }
      if (expandedTags.contains('easy') && h.difficultyText.toLowerCase() == 'easy') score += 2;
      if (expandedTags.contains('budget') || expandedTags.contains('free')) {
        final (_, max) = parseCostRange(h.costText);
        if (max <= 30) score += 5;
      }
      // Time/quick matching
      if (words.any((w) => ['quick', 'fast', 'easy'].contains(w))) {
        final hours = parseWeeklyHours(h.timeText);
        if (hours <= 2) score += 5;
      }
      // WhyLove field matching
      if (words.any((w) => h.whyLove.toLowerCase().contains(w))) score += 2;
      if (score > 0) scored.add((h, score));
    }
    scored.sort((a, b) => b.$2.compareTo(a.$2));
    var results = scored.map((e) => e.$1).toList();
    if (_selectedSearchCategory != null) {
      results = results.where((h) =>
          h.category.toLowerCase() == _selectedSearchCategory!.toLowerCase()).toList();
    }
    return results;
  }

  // ── Search view wrapped in a CustomScrollView with floating search bar ──
  Widget _buildSearchViewScrollable(List<Hobby> allHobbies) {
    return ColoredBox(
      color: AppColors.background,
      child: CustomScrollView(
      key: const ValueKey('search-scroll'),
      slivers: [
        // Floating search bar header (pinned when search active)
        SliverPersistentHeader(
          pinned: _searchActive,
          floating: true,
          delegate: _SearchBarHeaderDelegate(
            child: _buildSearchBar(),
            searchActive: _searchActive,
          ),
        ),
        // Search content as slivers
        ..._buildSearchContentSlivers(allHobbies),
      ],
    ),
    );
  }

  List<Widget> _buildSearchContentSlivers(List<Hobby> allHobbies) {
    final genState = ref.watch(generationProvider);
    final isPro = ref.watch(isProProvider);

    // Auto-navigate on successful generation
    ref.listen<GenerationState>(generationProvider, (_, next) {
      if (next.status == GenerationStatus.success && next.hobby != null) {
        ref.read(generationProvider.notifier).reset();
        context.push('/hobby/${next.hobby!.id}');
      }
    });

    // Category chips — always visible at top of search view
    final categoryRow = SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: SizedBox(
          height: 34,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: [
              _SearchChip(
                label: 'All',
                isSelected: _selectedSearchCategory == null,
                onTap: () => setState(() => _selectedSearchCategory = null),
              ),
              const SizedBox(width: 6),
              ..._categoryFilters.map((f) => Padding(
                padding: const EdgeInsets.only(right: 6),
                child: _SearchChip(
                  label: f.label,
                  isSelected: _selectedSearchCategory == f.id,
                  onTap: () => setState(() =>
                      _selectedSearchCategory = _selectedSearchCategory == f.id ? null : f.id),
                ),
              )),
            ],
          ),
        ),
      ),
    );

    if (_searchQuery.isEmpty) {
      return [
        categoryRow,
        const SliverToBoxAdapter(child: SizedBox(height: 8)),
        SliverFillRemaining(
          hasScrollBody: true,
          child: _buildSearchSuggestions(),
        ),
      ];
    }

    final results = _nlpSearch(allHobbies);
    final fewResults = results.length < 3;
    final isGenerating = genState.status == GenerationStatus.generating;

    if (results.isEmpty) {
      return [
        categoryRow,
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(MdiIcons.magnifyClose, size: 36, color: AppColors.textMuted),
                  const SizedBox(height: 12),
                  Text('No results for "$_searchQuery"',
                      style: AppTypography.body.copyWith(color: AppColors.textMuted),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  if (isGenerating) ...[
                    const SizedBox(width: 24, height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.coral)),
                    const SizedBox(height: 10),
                    Text('Generating hobby...', style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
                  ] else if (genState.status == GenerationStatus.error) ...[
                    Text('Something went wrong. Try again?',
                        style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
                    const SizedBox(height: 10),
                    _buildGenerateButton(isPro, genState),
                  ] else
                    _buildGenerateButton(isPro, genState),
                ],
              ),
            ),
          ),
        ),
      ];
    }

    return [
      categoryRow,
      const SliverToBoxAdapter(child: SizedBox(height: 14)),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
        sliver: SliverToBoxAdapter(
          child: Row(children: [
            Text('Top Results', style: AppTypography.title.copyWith(fontSize: 17)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(Spacing.radiusBadge)),
              child: Text('${results.length} found',
                  style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontSize: 11)),
            ),
          ]),
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 12)),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _SearchResultItem(hobby: results[index]),
            childCount: results.length,
          ),
        ),
      ),
      // AI generation widgets
      if (isPro && fewResults && !isGenerating && genState.status != GenerationStatus.error)
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
          sliver: SliverToBoxAdapter(
            child: GestureDetector(
              onTap: () => ref.read(generationProvider.notifier).generate(_searchQuery),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.coral.withValues(alpha: 0.3))),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(MdiIcons.creationOutline, size: 16, color: AppColors.coral),
                  const SizedBox(width: 8),
                  Text('Find more with AI', style: AppTypography.body.copyWith(
                      color: AppColors.coral, fontWeight: FontWeight.w600)),
                ]),
              ),
            ),
          ),
        ),
      if (isPro && fewResults && isGenerating)
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
          sliver: SliverToBoxAdapter(child: _AiSearchingTile()),
        ),
      if (!isPro && fewResults)
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverToBoxAdapter(
            child: _AiSearchLockedTile(
              onTap: () => showProUpgrade(context, 'AI Search finds custom hobbies when results are limited.'),
            ),
          ),
        ),
      if (isPro && fewResults && genState.status == GenerationStatus.error)
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
          sliver: SliverToBoxAdapter(
            child: GestureDetector(
              onTap: () => ref.read(generationProvider.notifier).generate(_searchQuery),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border)),
                child: Row(children: [
                  Icon(Icons.refresh_rounded, size: 18, color: AppColors.coral),
                  const SizedBox(width: 10),
                  Expanded(child: Text('AI suggestion failed. Tap to retry.',
                      style: AppTypography.caption.copyWith(color: AppColors.textSecondary))),
                ]),
              ),
            ),
          ),
        ),
      SliverPadding(
        padding: EdgeInsets.only(bottom: Spacing.scrollBottom(context)),
      ),
    ];
  }

  Widget _buildGenerateButton(bool isPro, GenerationState genState) {
    final isGenerating = genState.status == GenerationStatus.generating;
    return GestureDetector(
      onTap: isGenerating ? null : () {
        if (!isPro) {
          showProUpgrade(context, 'AI hobby generation is a Pro feature.');
          return;
        }
        ref.read(generationProvider.notifier).generate(_searchQuery);
      },
      child: Opacity(
        opacity: isGenerating ? 0.5 : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
              color: AppColors.coral, borderRadius: BorderRadius.circular(Spacing.radiusButton)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(MdiIcons.creationOutline, size: 16, color: Colors.white),
            const SizedBox(width: 8),
            Text('Generate this hobby', style: AppTypography.body.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
          ]),
        ),
      ),
    );
  }

  Widget _buildSearchSuggestions() {
    return SingleChildScrollView(
      key: const ValueKey('suggestions'),
      padding: EdgeInsets.fromLTRB(24, 20, 24, Spacing.scrollBottom(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('TRY SEARCHING FOR',
              style: AppTypography.overline.copyWith(color: AppColors.textMuted)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: _nlpSuggestions.map((s) => GestureDetector(
              onTap: () => setState(() {
                _searchQuery = s;
                _searchController.text = s;
                _searchController.selection =
                    TextSelection.fromPosition(TextPosition(offset: s.length));
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(Spacing.radiusBadge),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(s,
                    style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600)),
              ),
            )).toList(),
          ),
        ],
      ),
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

    // "Need a Different Vibe?" rail — lowest match scores
    final vibeHobbies = _buildDifferentVibeList(allHobbies, prefs);

    final heroHobby = forYou.isNotEmpty ? forYou.first : null;
    final alternates =
        forYou.length > 1 ? forYou.skip(1).take(2).toList() : <Hobby>[];

    return CustomScrollView(
      key: const ValueKey('discover'),
      slivers: [
        // ── Floating search bar ──
        SliverPersistentHeader(
          pinned: false,
          floating: true,
          delegate: _SearchBarHeaderDelegate(
            child: _buildSearchBar(),
            searchActive: false,
          ),
        ),

        // ── Hero card ──
        if (heroHobby != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
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

        // ── NEED A DIFFERENT VIBE? rail ──
        if (vibeHobbies.isNotEmpty)
          _SliverVibeRail(
            hobbies: vibeHobbies,
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

        SliverPadding(
          padding: EdgeInsets.only(bottom: Spacing.scrollBottom(context)),
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

  /// Returns the lowest-scoring 6 hobbies for the "Need a Different Vibe?" rail.
  List<Hobby> _buildDifferentVibeList(List<Hobby> allHobbies, UserPreferences prefs) {
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
    scored.sort((a, b) => a.score.compareTo(b.score)); // ascending — lowest first
    return scored.take(6).map((e) => e.hobby).toList();
  }
}

// ═══════════════════════════════════════════════════════
//  SEARCH BAR PERSISTENT HEADER DELEGATE
// ═══════════════════════════════════════════════════════

class _SearchBarHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final bool searchActive;

  _SearchBarHeaderDelegate({required this.child, required this.searchActive});

  static const double _headerHeight = 70; // searchBarHeight + vertical padding

  @override
  double get minExtent => _headerHeight;

  @override
  double get maxExtent => _headerHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _SearchBarHeaderDelegate oldDelegate) =>
      searchActive != oldDelegate.searchActive || child != oldDelegate.child;
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
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
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                // Rail header glow line
                Container(
                  height: 1,
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppColors.coral.withValues(alpha: 0.3),
                        AppColors.coral.withValues(alpha: 0.3),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.3, 0.7, 1.0],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: hobbies.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) =>
                  _CompactCard(hobby: hobbies[index])
                      .animate()
                      .fadeIn(duration: 400.ms, delay: (index * 100).ms)
                      .slideX(begin: 0.1, end: 0, duration: 400.ms, delay: (index * 100).ms, curve: Curves.easeOutCubic),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  COMPACT CARD — Small card for horizontal rails (3D tilt)
// ═══════════════════════════════════════════════════════

class _CompactCard extends StatefulWidget {
  final Hobby hobby;

  const _CompactCard({required this.hobby});

  @override
  State<_CompactCard> createState() => _CompactCardState();
}

class _CompactCardState extends State<_CompactCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        context.push('/hobby/${widget.hobby.id}');
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: _isPressed ? 1.0 : 0.0),
        duration: const Duration(milliseconds: 150),
        builder: (context, value, child) {
          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // perspective
              ..rotateY(-0.03 * value) // subtle tilt
              // ignore: deprecated_member_use
              ..scale(1.0 - 0.03 * value, 1.0 - 0.03 * value, 1.0), // scale to 0.97
            alignment: FractionalOffset.center,
            child: child,
          );
        },
        child: GlassCard(
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
                    imageUrl: widget.hobby.imageUrl,
                    fit: BoxFit.cover,
                    memCacheWidth: 300,
                    placeholder: (_, __) =>
                        Container(color: AppColors.surfaceElevated),
                    errorWidget: (_, __, ___) => Container(
                      color: AppColors.surfaceElevated,
                      child: Icon(AppIcons.categoryIcon(widget.hobby.category),
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
                        widget.hobby.title,
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
                        '${widget.hobby.costText} · ${widget.hobby.timeText}',
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
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  "NEED A DIFFERENT VIBE?" RAIL
// ═══════════════════════════════════════════════════════

class _SliverVibeRail extends StatelessWidget {
  final List<Hobby> hobbies;

  const _SliverVibeRail({required this.hobbies});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('NEED A DIFFERENT VIBE?',
                    style: AppTypography.overline
                        .copyWith(color: AppColors.textMuted)),
                // Rail header glow line
                Container(
                  height: 1,
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppColors.coral.withValues(alpha: 0.3),
                        AppColors.coral.withValues(alpha: 0.3),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.3, 0.7, 1.0],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: hobbies.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) =>
                  _VibeCard(hobby: hobbies[index])
                      .animate()
                      .fadeIn(duration: 400.ms, delay: (index * 100).ms)
                      .slideX(begin: 0.1, end: 0, duration: 400.ms, delay: (index * 100).ms, curve: Curves.easeOutCubic),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  VIBE CARD — Larger card for "Different Vibe" rail
// ═══════════════════════════════════════════════════════

class _VibeCard extends StatelessWidget {
  final Hobby hobby;

  const _VibeCard({required this.hobby});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/hobby/${hobby.id}'),
      child: Container(
        width: 180,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.coral.withValues(alpha: 0.10),
            width: 0.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image
              CachedNetworkImage(
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

              // Dramatic gradient — heavier at bottom
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withAlpha(80),
                      Colors.black.withAlpha(190),
                      Colors.black.withAlpha(230),
                    ],
                    stops: const [0.0, 0.3, 0.65, 1.0],
                  ),
                ),
              ),

              // Hook text overlaid on image
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      hobby.title,
                      style: AppTypography.title.copyWith(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hobby.hook,
                      style: AppTypography.body.copyWith(
                        color: Colors.white.withAlpha(180),
                        fontSize: 12,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
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

// ═══════════════════════════════════════════════════════
//  SEARCH CATEGORY CHIP
// ═══════════════════════════════════════════════════════

class _SearchChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SearchChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.coral : AppColors.surface,
          borderRadius: BorderRadius.circular(Spacing.radiusBadge),
        ),
        child: Text(label,
            style: AppTypography.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            )),
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
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(color: AppColors.surfaceElevated, borderRadius: BorderRadius.circular(10)),
            child: Center(child: Icon(MdiIcons.creationOutline, size: 22, color: AppColors.coral)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Finding more for you...', style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            Text('AI is generating a custom hobby', style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
          ])),
          const SizedBox(width: 18, height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.coral)),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  AI SEARCH LOCKED TILE
// ═══════════════════════════════════════════════════════

class _AiSearchLockedTile extends StatelessWidget {
  final VoidCallback onTap;
  const _AiSearchLockedTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border)),
              child: Row(children: [
                Container(width: 56, height: 56,
                    decoration: BoxDecoration(color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(10))),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(width: 120, height: 12,
                      decoration: BoxDecoration(color: AppColors.surfaceElevated, borderRadius: BorderRadius.circular(4))),
                  const SizedBox(height: 8),
                  Container(width: 80, height: 10,
                      decoration: BoxDecoration(color: AppColors.surfaceElevated, borderRadius: BorderRadius.circular(4))),
                ])),
              ]),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(color: AppColors.background.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(14)),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.lock_rounded, size: 14, color: AppColors.coral),
                  const SizedBox(width: 6),
                  Text('Unlock AI search', style: AppTypography.caption.copyWith(
                      color: AppColors.coral, fontWeight: FontWeight.w600)),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
