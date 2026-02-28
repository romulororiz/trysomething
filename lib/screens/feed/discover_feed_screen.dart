import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/hobby.dart';
import '../../providers/hobby_provider.dart';
import '../../providers/user_provider.dart';
import '../../components/hobby_card.dart';
import '../../components/category_tile.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_icons.dart';
import '../../theme/app_typography.dart';
import '../../theme/spacing.dart';
import '../../theme/motion.dart';

/// TikTok-like vertical discovery feed with parallax, category chips, dot indicators.
class DiscoverFeedScreen extends ConsumerStatefulWidget {
  const DiscoverFeedScreen({super.key});

  @override
  ConsumerState<DiscoverFeedScreen> createState() => _DiscoverFeedScreenState();
}

class _DiscoverFeedScreenState extends ConsumerState<DiscoverFeedScreen> {
  late PageController _pageController;
  int _currentIndex = 0;
  double _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: Motion.feedViewportFraction);
    _pageController.addListener(() {
      setState(() => _currentPage = _pageController.page ?? 0);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hobbies = ref.watch(filteredHobbiesProvider);
    final categories = ref.watch(categoriesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 10),
            child: Text('Discover', style: AppTypography.serifHeading),
          ),

          // Category chips
          CategoryChipBar(
            categories: categories,
            selectedId: selectedCategory,
            onSelected: (id) {
              ref.read(selectedCategoryProvider.notifier).state = id;
            },
          ),

          const SizedBox(height: 4),

          // Card feed
          Expanded(
            child: hobbies.isEmpty
                ? _buildEmptyState()
                : PageView.builder(
                    controller: _pageController,
                    scrollDirection: Axis.vertical,
                    itemCount: hobbies.length,
                    onPageChanged: (i) => setState(() => _currentIndex = i),
                    itemBuilder: (context, index) {
                      // Parallax offset
                      final offset = (_currentPage - index) * Motion.maxParallaxOffset * Motion.parallaxFactor;

                      final hobby = hobbies[index];
                      final isSaved = ref.watch(isHobbySavedProvider(hobby.id));

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: HobbyCard(
                          hobby: hobby,
                          parallaxOffset: offset,
                          isSaved: isSaved,
                          onTap: () => context.push('/hobby/${hobby.id}'),
                          onSave: () {
                            ref.read(userHobbiesProvider.notifier).toggleSave(hobby.id);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(AppIcons.navDiscover, size: 44, color: AppColors.warmGray),
          const SizedBox(height: 14),
          Text(
            'No hobbies in this category',
            style: AppTypography.sansBody.copyWith(color: AppColors.warmGray),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              ref.read(selectedCategoryProvider.notifier).state = null;
            },
            child: Text(
              'Show all →',
              style: AppTypography.sansLabel.copyWith(
                color: AppColors.coral,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
