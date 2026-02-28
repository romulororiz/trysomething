import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/hobby_provider.dart';
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
    final allHobbies = ref.watch(hobbyListProvider);

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
                border: Border.all(color: AppColors.sandDark),
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
                          border: Border.all(color: AppColors.sandDark),
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
              )
            else if (_query.isNotEmpty && results.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Opacity(
                        opacity: 0.3,
                        child: Icon(Icons.search, size: 44, color: AppColors.warmGray),
                      ),
                      const SizedBox(height: 12),
                      Text('No results for "$_query"',
                          style: AppTypography.sansBody.copyWith(color: AppColors.warmGray)),
                    ],
                  ),
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
                  children: [
                    ('pottery', AppColors.catCreative),
                    ('bouldering', AppColors.catFitness),
                    ('sourdough', AppColors.catFood),
                    ('chess', AppColors.catMind),
                    ('skateboarding', AppColors.catOutdoors),
                    ('journaling', AppColors.indigo),
                    ('archery', AppColors.sage),
                    ('calligraphy', AppColors.coral),
                  ].map((item) {
                    final term = item.$1;
                    final color = item.$2;
                    return GestureDetector(
                      onTap: () {
                        _searchController.text = term;
                        setState(() => _query = term);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(Spacing.radiusBadge),
                          border: Border.all(color: color.withValues(alpha: 0.22)),
                        ),
                        child: Text(
                          term,
                          style: AppTypography.sansCaption.copyWith(
                            fontWeight: FontWeight.w600,
                            color: color,
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
  }
}
