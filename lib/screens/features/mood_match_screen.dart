import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../models/hobby.dart';
import '../../models/feature_seed_data.dart';
import '../../theme/category_ui.dart';
import '../../providers/hobby_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_icons.dart';
import '../../theme/spacing.dart';

/// Mood-based hobby recommendation screen.
/// Presents 6 mood cards; on selection, filters hobbies by matching tags.
class MoodMatchScreen extends ConsumerStatefulWidget {
  const MoodMatchScreen({super.key});

  @override
  ConsumerState<MoodMatchScreen> createState() => _MoodMatchScreenState();
}

class _MoodMatchScreenState extends ConsumerState<MoodMatchScreen> {
  String? _selectedMood;

  // Mood card display data: mood name → (icon, color)
  static final Map<String, _MoodCardData> _moodCards = {
    'Stressed': _MoodCardData(MdiIcons.meditation, AppColors.sage),
    'Bored': _MoodCardData(MdiIcons.flashOutline, AppColors.amber),
    'Lonely': _MoodCardData(MdiIcons.accountHeartOutline, AppColors.coral),
    'Creative': _MoodCardData(MdiIcons.palette, AppColors.rose),
    'Restless': _MoodCardData(MdiIcons.runFast, AppColors.indigo),
    'Curious': _MoodCardData(MdiIcons.magnify, AppColors.sky),
  };

  @override
  Widget build(BuildContext context) {
    final allHobbies = ref.watch(hobbyListProvider);
    final topPad = MediaQuery.of(context).padding.top;

    // Filter hobbies by mood tags
    final moodTags = _selectedMood != null
        ? FeatureSeedData.moodToTags[_selectedMood] ?? <String>[]
        : <String>[];
    final matchedHobbies = _selectedMood != null
        ? allHobbies.where((h) => h.tags.any((t) => moodTags.contains(t))).toList()
        : <Hobby>[];

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: CustomScrollView(
        slivers: [
          // ── Header ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: topPad + 8, left: 16, right: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.warmWhite,
                        border: Border.all(color: AppColors.sandDark),
                      ),
                      child: const Center(
                        child: Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.nearBlack),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(AppIcons.mood, size: 22, color: AppColors.coral),
                  const SizedBox(width: 8),
                  Text('Mood Match', style: AppTypography.sansSection),
                ],
              ),
            ),
          ),

          // ── Title ───────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
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
                'Tap a mood and we\'ll find hobbies that fit.',
                style: AppTypography.sansBodySmall,
              ),
            ),
          ),

          // ── Mood Grid ───────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.0,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final mood = _moodCards.keys.elementAt(index);
                  final data = _moodCards[mood]!;
                  final isSelected = _selectedMood == mood;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedMood = _selectedMood == mood ? null : mood;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? data.color.withValues(alpha: 0.12)
                            : AppColors.warmWhite,
                        borderRadius: BorderRadius.circular(Spacing.radiusTile),
                        border: Border.all(
                          color: isSelected
                              ? data.color.withValues(alpha: 0.5)
                              : AppColors.sandDark,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected ? Spacing.subtleShadow : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            data.icon,
                            size: 30,
                            color: isSelected ? data.color : AppColors.driftwood,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            mood,
                            style: AppTypography.sansLabel.copyWith(
                              color: isSelected ? data.color : AppColors.espresso,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: _moodCards.length,
              ),
            ),
          ),

          // ── Results Section ─────────────────────────────
          if (_selectedMood != null) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 6),
                child: Text(
                  'Perfect for your mood',
                  style: AppTypography.serifSubheading,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: Text(
                  '${matchedHobbies.length} hobbies match "$_selectedMood"',
                  style: AppTypography.sansCaption,
                ),
              ),
            ),

            if (matchedHobbies.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(MdiIcons.emoticonSadOutline, size: 40, color: AppColors.warmGray),
                        const SizedBox(height: 12),
                        Text(
                          'No matches found for this mood yet.',
                          style: AppTypography.sansBody.copyWith(color: AppColors.driftwood),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final hobby = matchedHobbies[index];
                      // Find which tags matched
                      final matchingTags = hobby.tags
                          .where((t) => moodTags.contains(t))
                          .toList();

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () => context.push('/hobby/${hobby.id}'),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.warmWhite,
                              borderRadius: BorderRadius.circular(Spacing.radiusCard),
                              border: Border.all(color: AppColors.sandDark),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Row(
                              children: [
                                // Hobby image
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(Spacing.radiusCard - 1),
                                    bottomLeft: Radius.circular(Spacing.radiusCard - 1),
                                  ),
                                  child: Image.network(
                                    hobby.imageUrl,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 100,
                                      height: 100,
                                      color: AppColors.sand,
                                      child: Icon(hobby.catIcon, color: AppColors.warmGray),
                                    ),
                                  ),
                                ),

                                // Info
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 12,
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          hobby.title,
                                          style: AppTypography.sansSection,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          hobby.hook,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTypography.sansCaption,
                                        ),
                                        const SizedBox(height: 8),
                                        Wrap(
                                          spacing: 6,
                                          runSpacing: 4,
                                          children: matchingTags.map((tag) {
                                            return Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 3,
                                              ),
                                              decoration: BoxDecoration(
                                                color: _moodCards[_selectedMood]!
                                                    .color
                                                    .withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(
                                                  Spacing.radiusBadge,
                                                ),
                                              ),
                                              child: Text(
                                                tag,
                                                style: AppTypography.sansTiny.copyWith(
                                                  color: _moodCards[_selectedMood]!.color,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Chevron
                                const Padding(
                                  padding: EdgeInsets.only(right: 12),
                                  child: Icon(
                                    Icons.chevron_right,
                                    color: AppColors.stone,
                                    size: 22,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: matchedHobbies.length,
                  ),
                ),
              ),
          ],

          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

/// Internal data class for mood card display configuration.
class _MoodCardData {
  final IconData icon;
  final Color color;

  const _MoodCardData(this.icon, this.color);
}
