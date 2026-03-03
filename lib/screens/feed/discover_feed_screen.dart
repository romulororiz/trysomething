import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/hobby_provider.dart';
import '../../providers/user_provider.dart';
import '../../components/hobby_card.dart';
import '../../components/category_tile.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_icons.dart';
import '../../theme/app_typography.dart';
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
  bool _showSwipeHint = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: Motion.feedViewportFraction);

    // Fade out the swipe hint after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _showSwipeHint = false);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hobbiesAsync = ref.watch(filteredHobbiesProvider);
    final categories = ref.watch(categoriesProvider).valueOrNull ?? [];
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 10),
            child: Row(
              children: [
                Text('Discover', style: AppTypography.serifHeading),
                const Spacer(),
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

          // Card feed with dot indicators overlay
          Expanded(
            child: hobbiesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('$err')),
              data: (hobbies) => hobbies.isEmpty
                ? _buildEmptyState()
                : Stack(
                    children: [
                      // Main feed
                      PageView.builder(
                        controller: _pageController,
                        scrollDirection: Axis.vertical,
                        itemCount: hobbies.length,
                        onPageChanged: (i) => setState(() => _currentIndex = i),
                        itemBuilder: (context, index) {
                          final hobby = hobbies[index];
                          final isSaved = ref.watch(isHobbySavedProvider(hobby.id));

                          // AnimatedBuilder scoped to page controller —
                          // only rebuilds this card's parallax, NOT the
                          // header, chips, or Riverpod watches above.
                          return AnimatedBuilder(
                            animation: _pageController,
                            builder: (context, _) {
                              double offset = 0;
                              if (_pageController.hasClients) {
                                final page = _pageController.page;
                                if (page != null) {
                                  offset = (page - index) * Motion.maxParallaxOffset * Motion.parallaxFactor;
                                }
                              }

                              return Padding(
                                padding: const EdgeInsets.only(top: 4, bottom: 90),
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
                          );
                        },
                      ),

                      // Dot indicators on the right edge
                      Positioned(
                        right: 16,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: _buildDotIndicators(hobbies.length),
                        ),
                      ),

                      // Swipe hint at the bottom
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 24,
                        child: AnimatedOpacity(
                          opacity: _showSwipeHint ? 1.0 : 0.0,
                          duration: Motion.normal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.keyboard_arrow_up_rounded,
                                size: 18,
                                color: AppColors.warmGray,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Swipe up to explore',
                                style: AppTypography.sansCaption.copyWith(
                                  color: AppColors.warmGray,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the vertical dot indicators.
  ///
  /// Shows at most 7 dots. When there are more items than 7, the dots act
  /// as a sliding window that follows the current index.
  Widget _buildDotIndicators(int total) {
    const int maxDots = 7;
    final int dotCount = total.clamp(0, maxDots);

    // Calculate the window start index when total exceeds maxDots
    int windowStart = 0;
    if (total > maxDots) {
      // Keep the active dot roughly centered in the window
      windowStart = (_currentIndex - maxDots ~/ 2).clamp(0, total - maxDots);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(dotCount, (i) {
        final actualIndex = windowStart + i;
        final isActive = actualIndex == _currentIndex;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: AnimatedContainer(
            duration: Motion.fast,
            curve: Motion.fastCurve,
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? AppColors.coral : AppColors.sand,
            ),
          ),
        );
      }),
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
