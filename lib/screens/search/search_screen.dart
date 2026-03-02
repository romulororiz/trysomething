import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../providers/hobby_provider.dart';
import '../../theme/category_ui.dart'; // ignore: unused_import
import '../../theme/app_colors.dart';
import '../../theme/app_icons.dart';
import '../../theme/app_typography.dart';
import '../../theme/spacing.dart';

/// Search screen — search bar, popular chips.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allHobbiesAsync = ref.watch(hobbyListProvider);

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
    // Filter hobbies by query
    final results = _query.isEmpty
        ? <dynamic>[]
        : allHobbies
            .where((h) =>
                h.title.toLowerCase().contains(_query.toLowerCase()) ||
                h.category.toLowerCase().contains(_query.toLowerCase()) ||
                h.tags.any((t) => t.toLowerCase().contains(_query.toLowerCase())))
            .toList();

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text('Search', style: AppTypography.serifHeading),
            const SizedBox(height: 14),

            // Search input
            Container(
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
            const SizedBox(height: 28),

            // Results or popular searches
            if (_query.isNotEmpty && results.isNotEmpty)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        '${results.length} results',
                        style: AppTypography.monoCaption.copyWith(
                          color: AppColors.warmGray,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: results.length,
                        itemBuilder: (context, i) {
                          final hobby = results[i];
                          return GestureDetector(
                            onTap: () => context.push('/hobby/${hobby.id}'),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: AppColors.warmWhite,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      hobby.imageUrl,
                                      width: 44,
                                      height: 44,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        width: 44,
                                        height: 44,
                                        color: AppColors.sand,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          hobby.title,
                                          style: AppTypography.sansBody.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            Icon(hobby.catIcon, size: 11, color: AppColors.warmGray),
                                            const SizedBox(width: 4),
                                            Text(
                                              hobby.category,
                                              style: AppTypography.sansCaption.copyWith(
                                                color: AppColors.warmGray,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right,
                                      color: AppColors.stone, size: 16),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              )
            else if (_query.isNotEmpty && results.isEmpty)
              Expanded(
                child: Center(
                  child: _buildGenerateCta(),
                ),
              )
            else ...[
              // Popular searches
              Center(
                child: Text('POPULAR SEARCHES', style: AppTypography.overline),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
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
      ),
    );
      },
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
