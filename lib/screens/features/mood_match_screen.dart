import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../models/hobby.dart';
import '../../theme/category_ui.dart';
import '../../providers/feature_providers.dart';
import '../../providers/hobby_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/spacing.dart';
import '../../theme/motion.dart';

/// Mood-based hobby recommendation screen.
/// Presents 4 photo-backed mood tiles; on selection, filters hobbies.
class MoodMatchScreen extends ConsumerStatefulWidget {
  const MoodMatchScreen({super.key});

  @override
  ConsumerState<MoodMatchScreen> createState() => _MoodMatchScreenState();
}

class _MoodMatchScreenState extends ConsumerState<MoodMatchScreen> {
  String? _selectedMood;

  static final List<_MoodTileData> _moods = [
    _MoodTileData(
      mood: 'Energetic',
      subtitle: 'Climbing, running, dance',
      color: AppColors.coral,
      icon: Icons.local_fire_department_rounded,
      imageUrl: 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=400',
    ),
    _MoodTileData(
      mood: 'Zen',
      subtitle: 'Yoga, pottery, gardening',
      color: AppColors.sage,
      icon: MdiIcons.meditation,
      imageUrl: 'https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=400',
    ),
    _MoodTileData(
      mood: 'Curious',
      subtitle: 'Coding, puzzles, trivia',
      color: AppColors.sky,
      icon: MdiIcons.magnify,
      imageUrl: 'https://images.unsplash.com/photo-1456513080510-7bf3a84b82f8?w=400',
    ),
    _MoodTileData(
      mood: 'Creative',
      subtitle: 'Painting, writing, DIY',
      color: AppColors.rose,
      icon: MdiIcons.palette,
      imageUrl: 'https://images.unsplash.com/photo-1513364776144-60967b0f800f?w=400',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final allHobbies = ref.watch(hobbyListProvider).valueOrNull ?? [];
    final moodTagsData = ref.watch(moodTagsProvider).valueOrNull ?? {};
    final topPad = MediaQuery.of(context).padding.top;

    // Filter hobbies by mood
    final moodHobbyIds = _selectedMood != null
        ? moodTagsData[_selectedMood] ?? <String>[]
        : <String>[];
    final matchedHobbies = _selectedMood != null
        ? allHobbies.where((h) => moodHobbyIds.contains(h.id)).toList()
        : <Hobby>[];

    // Popular Today — show a curated selection regardless of mood
    final popular = allHobbies.take(5).toList();

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: topPad + 8, left: 16, right: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Icon(Icons.arrow_back,
                        size: 20, color: AppColors.espresso),
                  ),
                  const Spacer(),
                  Text('Mood Match', style: AppTypography.sansSection),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => context.push('/search'),
                    child: const Icon(Icons.search_rounded,
                        size: 20, color: AppColors.espresso),
                  ),
                ],
              ),
            ),
          ),

          // Title
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 6),
              child: Text(
                'How are you feeling?',
                style: AppTypography.serifHeading,
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: Text(
                'Pick a mood to uncover your next obsession.',
                style: AppTypography.sansBodySmall,
              ),
            ),
          ),

          // 2x2 Mood grid with photo backgrounds
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final data = _moods[index];
                  final isSelected = _selectedMood == data.mood;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedMood =
                            _selectedMood == data.mood ? null : data.mood;
                      });
                    },
                    child: AnimatedContainer(
                      duration: Motion.normal,
                      curve: Curves.easeOut,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Spacing.radiusTile),
                        border: isSelected
                            ? Border.all(color: data.color, width: 2)
                            : null,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                            isSelected ? Spacing.radiusTile - 2 : Spacing.radiusTile),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Photo background
                            Image.network(
                              data.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: data.color.withValues(alpha: 0.15),
                              ),
                            ),
                            // Dark overlay
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.2),
                                    Colors.black.withValues(alpha: 0.65),
                                  ],
                                ),
                              ),
                            ),
                            // Content
                            Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(data.icon, size: 28, color: data.color),
                                  const SizedBox(height: 8),
                                  Text(
                                    data.mood,
                                    style: AppTypography.sansLabel.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    data.subtitle,
                                    style: AppTypography.sansTiny.copyWith(
                                      color: Colors.white.withValues(alpha: 0.8),
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
                },
                childCount: _moods.length,
              ),
            ),
          ),

          // Results or Popular Today
          if (_selectedMood != null && matchedHobbies.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
                child: Text(
                  'Perfect for "$_selectedMood"',
                  style: AppTypography.sansSection,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final hobby = matchedHobbies[index];
                    return _PopularCard(
                      hobby: hobby,
                      onTap: () => context.push('/hobby/${hobby.id}'),
                    );
                  },
                  childCount: matchedHobbies.length,
                ),
              ),
            ),
          ] else ...[
            // Popular Today
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
                child: Row(
                  children: [
                    Text('Popular Today', style: AppTypography.sansSection),
                    const Spacer(),
                    Text(
                      'View all',
                      style: AppTypography.sansLabel
                          .copyWith(color: AppColors.coral),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final hobby = popular[index];
                    return _PopularCard(
                      hobby: hobby,
                      onTap: () => context.push('/hobby/${hobby.id}'),
                    );
                  },
                  childCount: popular.length,
                ),
              ),
            ),
          ],

          // Bottom padding
          const SliverToBoxAdapter(
              child: SizedBox(height: Spacing.scrollBottomPadding)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  MOOD TILE DATA
// ═══════════════════════════════════════════════════════

class _MoodTileData {
  final String mood;
  final String subtitle;
  final Color color;
  final IconData icon;
  final String imageUrl;

  const _MoodTileData({
    required this.mood,
    required this.subtitle,
    required this.color,
    required this.icon,
    required this.imageUrl,
  });
}

// ═══════════════════════════════════════════════════════
//  POPULAR / RESULT CARD
// ═══════════════════════════════════════════════════════

class _PopularCard extends StatelessWidget {
  final Hobby hobby;
  final VoidCallback onTap;

  const _PopularCard({required this.hobby, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final catColor = hobby.catColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: catColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      hobby.category.toUpperCase(),
                      style: AppTypography.monoBadgeSmall.copyWith(
                        color: catColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    hobby.title,
                    style: AppTypography.sansBody.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.nearBlack,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        hobby.timeText,
                        style: AppTypography.sansCaption
                            .copyWith(color: AppColors.warmGray),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        hobby.difficultyText,
                        style: AppTypography.sansCaption
                            .copyWith(color: AppColors.warmGray),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 12, color: AppColors.stone),
          ],
        ),
      ),
    );
  }
}
