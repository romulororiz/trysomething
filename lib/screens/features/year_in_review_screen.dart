import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/hobby.dart';
import '../../providers/feature_providers.dart';
import '../../providers/hobby_provider.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_icons.dart';
import '../../theme/app_typography.dart';

/// Year in Review — beautiful hobby journey summary.
class YearInReviewScreen extends ConsumerWidget {
  const YearInReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userHobbies = ref.watch(userHobbiesProvider);
    final allHobbies = ref.watch(hobbyListProvider).valueOrNull ?? [];
    final prefs = ref.watch(userPreferencesProvider);

    final tryingCount =
        ref.watch(hobbyCountByStatusProvider(HobbyStatus.trying));
    final activeCount =
        ref.watch(hobbyCountByStatusProvider(HobbyStatus.active));
    final doneCount = ref.watch(hobbyCountByStatusProvider(HobbyStatus.done));
    final totalTried = tryingCount + activeCount + doneCount;

    int totalSteps = 0;
    int longestStreak = 0;
    final categoryCount = <String, int>{};

    for (final uh in userHobbies.values) {
      totalSteps += uh.completedStepIds.length;
      if (uh.streakDays > longestStreak) longestStreak = uh.streakDays;

      final hobby = allHobbies.cast<Hobby?>().firstWhere(
            (h) => h!.id == uh.hobbyId,
            orElse: () => null,
          );
      if (hobby != null) {
        categoryCount[hobby.category] =
            (categoryCount[hobby.category] ?? 0) + 1;
      }
    }

    // Sort categories by count
    final sortedCategories = categoryCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Heatmap data (real activity from server)
    final heatmap = ref.watch(activityHeatmapProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.sand,
                        ),
                        child: const Icon(Icons.arrow_back,
                            size: 20, color: AppColors.espresso),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text('Your ${DateTime.now().year}',
                        style: AppTypography.serifHeading),
                  ],
                ),
              ),

              // Hero summary card
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.coral, AppColors.amber],
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x30E25C3D),
                        blurRadius: 24,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(AppIcons.trophy,
                          size: 32, color: Colors.white.withAlpha(220)),
                      const SizedBox(height: 14),
                      Text(
                        'Year in Review',
                        style: AppTypography.serifSubheading
                            .copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Your hobby journey so far',
                        style: AppTypography.sansBodySmall.copyWith(
                          color: Colors.white.withAlpha(200),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Stats row
                      Row(
                        children: [
                          _HeroStat(
                            number: '$totalTried',
                            label: 'Hobbies\ntried',
                          ),
                          _HeroStat(
                            number: '$totalSteps',
                            label: 'Steps\ncompleted',
                          ),
                          _HeroStat(
                            number: '${longestStreak}d',
                            label: 'Longest\nstreak',
                          ),
                          _HeroStat(
                            number: '${prefs.hoursPerWeek * 4}h',
                            label: 'Monthly\nhours',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Mini heatmap
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(AppIcons.fire,
                            size: 16, color: AppColors.coral),
                        const SizedBox(width: 6),
                        Text('Recent Activity',
                            style: AppTypography.sansSection),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 3,
                      runSpacing: 3,
                      children: List.generate(56, (i) {
                        final date = DateTime.now()
                            .subtract(Duration(days: 55 - i));
                        final normalized = DateTime(
                            date.year, date.month, date.day);
                        final level = heatmap[normalized] ?? 0;
                        return Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: _heatColor(level),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text('Less',
                            style: AppTypography.sansTiny
                                .copyWith(fontSize: 9)),
                        const SizedBox(width: 4),
                        for (int i = 0; i <= 3; i++)
                          Container(
                            width: 10,
                            height: 10,
                            margin: const EdgeInsets.only(right: 3),
                            decoration: BoxDecoration(
                              color: _heatColor(i),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        const SizedBox(width: 2),
                        Text('More',
                            style: AppTypography.sansTiny
                                .copyWith(fontSize: 9)),
                      ],
                    ),
                  ],
                ),
              ),

              // Top categories
              if (sortedCategories.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 14),
                  child: Text('Top Categories',
                      style: AppTypography.sansSection),
                ),
                ...sortedCategories.take(5).toList().asMap().entries.map(
                    (entry) {
                  final rank = entry.key + 1;
                  final cat = entry.value;

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 10),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.warmWhite,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.sandDark),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.sand,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                '#$rank',
                                style: AppTypography.monoBadge
                                    .copyWith(color: AppColors.driftwood),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(cat.key,
                                style: AppTypography.sansLabel),
                          ),
                          Text(
                            '${cat.value} ${cat.value == 1 ? 'hobby' : 'hobbies'}',
                            style: AppTypography.monoCaption
                                .copyWith(color: AppColors.warmGray),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],

              // Share button
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final text = 'My ${DateTime.now().year} on TrySomething\n'
                          '$totalTried hobbies tried \u2022 $totalSteps steps completed\n'
                          'Longest streak: ${longestStreak}d';
                      Share.share(text);
                    },
                    icon: Icon(AppIcons.share, size: 18),
                    label: const Text('Share Your Year'),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  static Color _heatColor(int level) {
    switch (level) {
      case 0:
        return AppColors.sand;
      case 1:
        return AppColors.coralPale;
      case 2:
        return AppColors.coralLight;
      case 3:
        return AppColors.coral;
      default:
        return AppColors.sand;
    }
  }
}

class _HeroStat extends StatelessWidget {
  final String number;
  final String label;

  const _HeroStat({required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            number,
            style: AppTypography.monoLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.sansTiny.copyWith(
              color: Colors.white.withAlpha(180),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
