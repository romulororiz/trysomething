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

/// Full-screen TikTok-style vertical discovery feed.
class DiscoverFeedScreen extends ConsumerStatefulWidget {
  const DiscoverFeedScreen({super.key});

  @override
  ConsumerState<DiscoverFeedScreen> createState() => _DiscoverFeedScreenState();
}

class _DiscoverFeedScreenState extends ConsumerState<DiscoverFeedScreen> {
  late PageController _pageController;
  bool _showSwipeHint = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showSwipeHint = false);
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

    return hobbiesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('$err')),
      data: (hobbies) => hobbies.isEmpty
          ? _buildEmptyState()
          : Stack(
              children: [
                // Full-screen card PageView
                PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.vertical,
                  itemCount: hobbies.length,
                  itemBuilder: (context, index) {
                    final hobby = hobbies[index];
                    final isSaved = ref.watch(isHobbySavedProvider(hobby.id));

                    return HobbyCard(
                      hobby: hobby,
                      isSaved: isSaved,
                      onTap: () => context.push('/hobby/${hobby.id}'),
                      onSave: () {
                        ref.read(userHobbiesProvider.notifier).toggleSave(hobby.id);
                      },
                    );
                  },
                ),

                // Overlay: header + category chips (fades over image)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xCC000000),
                          Color(0x00000000),
                        ],
                      ),
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                            child: Row(
                              children: [
                                Text('Discover',
                                    style: AppTypography.serifHeading.copyWith(
                                      shadows: [
                                        Shadow(
                                          blurRadius: 10,
                                          color: Colors.black.withValues(alpha: 0.4),
                                        ),
                                      ],
                                    )),
                                const Spacer(),
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black.withValues(alpha: 0.3),
                                  ),
                                  child: const Icon(Icons.notifications_none_rounded,
                                      size: 20, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          CategoryChipBar(
                            categories: categories,
                            selectedId: selectedCategory,
                            onSelected: (id) {
                              ref.read(selectedCategoryProvider.notifier).state = id;
                            },
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),

                // Swipe hint
                if (_showSwipeHint)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 100,
                    child: AnimatedOpacity(
                      opacity: _showSwipeHint ? 1.0 : 0.0,
                      duration: Motion.normal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.keyboard_arrow_up_rounded,
                            size: 18,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Swipe up to explore',
                            style: AppTypography.sansCaption.copyWith(
                              color: Colors.white70,
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
