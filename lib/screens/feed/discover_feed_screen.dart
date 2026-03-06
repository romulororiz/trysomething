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
import '../../theme/spacing.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

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

  void _showSurpriseMeSheet() {
    final textController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.warmWhite,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(
          24, 20, 24,
          MediaQuery.of(sheetContext).viewInsets.bottom + 110,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.stone,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text('What sounds fun right now?',
                style: AppTypography.sansBody.copyWith(
                  color: AppColors.nearBlack,
                  fontWeight: FontWeight.w600,
                )),
            const SizedBox(height: 12),
            TextField(
              controller: textController,
              autofocus: true,
              style: AppTypography.sansBody.copyWith(color: AppColors.nearBlack),
              decoration: InputDecoration(
                hintText: 'e.g. something creative with my hands',
                hintStyle: AppTypography.sansCaption.copyWith(color: AppColors.warmGray),
                filled: true,
                fillColor: AppColors.sand,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                suffixIcon: GestureDetector(
                  onTap: () {
                    final value = textController.text.trim();
                    if (value.isNotEmpty) {
                      Navigator.of(sheetContext).pop();
                      ref.read(generationProvider.notifier).generate(value);
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.coral,
                    ),
                    child: const Icon(Icons.arrow_forward_rounded,
                        size: 18, color: Colors.white),
                  ),
                ),
              ),
              textInputAction: TextInputAction.go,
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  Navigator.of(sheetContext).pop();
                  ref.read(generationProvider.notifier).generate(value.trim());
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hobbiesAsync = ref.watch(filteredHobbiesProvider);
    final categories = ref.watch(categoriesProvider).valueOrNull ?? [];
    final selectedCategory = ref.watch(selectedCategoryProvider);

    // Navigate to generated hobby on success
    ref.listen<GenerationState>(generationProvider, (prev, next) {
      if (next.status == GenerationStatus.success && next.hobby != null) {
        final hobbyId = next.hobby!.id;
        ref.read(generationProvider.notifier).reset();
        context.push('/hobby/$hobbyId');
      }
    });

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
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.coral,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text('TRYSOMETHING',
                                        style: AppTypography.sansLabel.copyWith(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1.2,
                                          color: Colors.white,
                                          shadows: [
                                            Shadow(
                                              blurRadius: 10,
                                              color: Colors.black.withValues(alpha: 0.4),
                                            ),
                                          ],
                                        )),
                                  ],
                                ),
                                const Spacer(),
                                GestureDetector(
                                  onTap: () => context.push('/search'),
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.black.withValues(alpha: 0.3),
                                    ),
                                    child: const Icon(Icons.search_rounded,
                                        size: 20, color: Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () => context.push('/mood-match'),
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.black.withValues(alpha: 0.3),
                                    ),
                                    child: Icon(MdiIcons.emoticon,
                                        size: 20, color: Colors.white),
                                  ),
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
                          const SizedBox(height: 6),
                          // Quick links row
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              children: [
                                _QuickLink(
                                  icon: Icons.local_fire_department_rounded,
                                  label: 'Combos',
                                  onTap: () => context.push('/combos'),
                                ),
                                const SizedBox(width: 8),
                                _QuickLink(
                                  icon: Icons.park_rounded,
                                  label: 'Seasonal',
                                  onTap: () => context.push('/seasonal'),
                                ),
                                const SizedBox(width: 8),
                                _QuickLink(
                                  icon: Icons.compare_arrows_rounded,
                                  label: 'Battle',
                                  onTap: () => context.push('/compare'),
                                ),
                              ],
                            ),
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
                    bottom: Spacing.scrollBottomPadding,
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

                // "Surprise Me" FAB — right side, above action column
                Positioned(
                  right: 16,
                  bottom: 200,
                  child: _SurpriseMeFab(onTap: _showSurpriseMeSheet),
                ),

                // Generation loading overlay
                if (ref.watch(generationProvider).status == GenerationStatus.generating)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.6),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 36, height: 36,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: AppColors.coral,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Creating your hobby...',
                              style: AppTypography.sansBody.copyWith(color: Colors.white),
                            ),
                          ],
                        ),
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

class _SurpriseMeFab extends StatelessWidget {
  final VoidCallback onTap;

  const _SurpriseMeFab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withValues(alpha: 0.4),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.15),
            width: 0.5,
          ),
        ),
        child: Center(
          child: Icon(MdiIcons.autoFix, size: 22, color: Colors.white),
        ),
      ),
    );
  }
}

class _QuickLink extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickLink({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(Spacing.radiusBadge),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: Colors.white70),
            const SizedBox(width: 5),
            Text(
              label,
              style: AppTypography.sansCaption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
