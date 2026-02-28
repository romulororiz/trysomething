import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/hobby.dart';
import '../../providers/hobby_provider.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_icons.dart';
import '../../theme/app_typography.dart';

/// Profile tab — avatar, identity badge, stats, passport, preferences.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(userPreferencesProvider);
    final userHobbies = ref.watch(userHobbiesProvider);
    final allHobbies = ref.watch(hobbyListProvider);

    // Counts
    final tryingCount =
        ref.watch(hobbyCountByStatusProvider(HobbyStatus.trying));
    final activeCount =
        ref.watch(hobbyCountByStatusProvider(HobbyStatus.active));
    final doneCount = ref.watch(hobbyCountByStatusProvider(HobbyStatus.done));
    final savedCount =
        ref.watch(hobbyCountByStatusProvider(HobbyStatus.saved));
    final totalTried = tryingCount + activeCount + doneCount;

    // Completed steps & longest streak
    int totalSteps = 0;
    int totalStreak = 0;
    for (final uh in userHobbies.values) {
      totalSteps += uh.completedStepIds.length;
      if (uh.streakDays > totalStreak) totalStreak = uh.streakDays;
    }

    // Done hobbies for passport
    final doneHobbies = userHobbies.values
        .where((uh) => uh.status == HobbyStatus.done)
        .map((uh) => allHobbies.firstWhere(
              (h) => h.id == uh.hobbyId,
              orElse: () => allHobbies.first,
            ))
        .toList();

    // Active/trying hobbies for tag pills
    final activeHobbies = userHobbies.values
        .where((uh) =>
            uh.status == HobbyStatus.active ||
            uh.status == HobbyStatus.trying)
        .map((uh) => allHobbies.firstWhere(
              (h) => h.id == uh.hobbyId,
              orElse: () => allHobbies.first,
            ))
        .toList();

    // Dynamic identity
    final identity = _deriveIdentity(prefs.vibes, totalTried);
    final level = _identityLevel(totalTried);

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          // ═══════════════════════════════════════════
          //  HEADER — title + gear icon → settings
          // ═══════════════════════════════════════════
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Row(
                children: [
                  Text('Profile', style: AppTypography.serifHeading),
                ],
              ),
            ),
          ),

          // ═══════════════════════════════════════════
          //  PROFILE CARD — avatar + identity
          // ═══════════════════════════════════════════
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.warmWhite,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x08000000),
                      blurRadius: 16,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Avatar
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.coralPale, AppColors.amberPale],
                        ),
                        border: Border.all(color: AppColors.coral, width: 3),
                      ),
                      child: Center(
                        child: Icon(AppIcons.sparkle,
                            size: 34, color: AppColors.coral),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Level pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.coralPale,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        'LEVEL $level',
                        style: AppTypography.monoBadgeSmall
                            .copyWith(color: AppColors.coral, letterSpacing: 2),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Identity title
                    Text(
                      identity,
                      style: AppTypography.serifSubheading.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _identitySubtitle(prefs.vibes),
                      style: AppTypography.sansBodySmall
                          .copyWith(color: AppColors.warmGray),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // Active hobby tags
                    if (activeHobbies.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: activeHobbies.take(5).map((h) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: h.catColor.withAlpha(20),
                              borderRadius: BorderRadius.circular(100),
                              border:
                                  Border.all(color: h.catColor.withAlpha(50)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(h.catIcon,
                                    size: 13, color: h.catColor),
                                const SizedBox(width: 5),
                                Text(
                                  h.title.length > 14
                                      ? '${h.title.substring(0, 14)}…'
                                      : h.title,
                                  style: AppTypography.sansCaption
                                      .copyWith(color: h.catColor),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // ═══════════════════════════════════════════
          //  QUICK STATS ROW
          // ═══════════════════════════════════════════
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                children: [
                  _QuickStat(
                      number: '$savedCount',
                      label: 'Saved',
                      color: AppColors.indigo),
                  const SizedBox(width: 10),
                  _QuickStat(
                      number: '$tryingCount',
                      label: 'Trying',
                      color: AppColors.coral),
                  const SizedBox(width: 10),
                  _QuickStat(
                      number: '$activeCount',
                      label: 'Active',
                      color: AppColors.sage),
                  const SizedBox(width: 10),
                  _QuickStat(
                      number: '$doneCount',
                      label: 'Done',
                      color: AppColors.amber),
                ],
              ),
            ),
          ),

          // ═══════════════════════════════════════════
          //  YEAR IN HOBBIES
          // ═══════════════════════════════════════════
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'YOUR ${DateTime.now().year}',
                    style: AppTypography.overline
                        .copyWith(color: AppColors.coral, letterSpacing: 3),
                  ),
                  const SizedBox(height: 6),
                  Text('Year in Hobbies',
                      style: AppTypography.serifSubheading),
                  const SizedBox(height: 16),

                  // 2×2 stat grid
                  Row(
                    children: [
                      Expanded(
                        child: _StatTile(
                          number: '$totalTried',
                          label: 'Hobbies tried',
                          color: AppColors.coral,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatTile(
                          number: '${prefs.hoursPerWeek * 4}h',
                          label: 'Monthly hours',
                          color: AppColors.amber,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatTile(
                          number: '$totalSteps',
                          label: 'Steps done',
                          color: AppColors.indigo,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatTile(
                          number: '${totalStreak}d',
                          label: 'Best streak',
                          color: AppColors.sage,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ═══════════════════════════════════════════
          //  HOBBY PASSPORT
          // ═══════════════════════════════════════════
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(AppIcons.trophy,
                          size: 18, color: AppColors.amber),
                      const SizedBox(width: 8),
                      Text('Hobby Passport',
                          style: AppTypography.sansSection),
                      const Spacer(),
                      Text(
                        '${doneHobbies.length}/50',
                        style: AppTypography.monoCaption
                            .copyWith(color: AppColors.warmGray),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: doneHobbies.length / 50,
                      backgroundColor: AppColors.sand,
                      color: AppColors.amber,
                      minHeight: 4,
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),
          ),

          // Passport grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverGrid(
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index < doneHobbies.length) {
                    final hobby = doneHobbies[index];
                    return _PassportStamp(
                      icon: hobby.catIcon,
                      name: hobby.title.split(' ').first,
                      color: hobby.catColor,
                      isCollected: true,
                    );
                  }
                  return const _PassportStamp(isCollected: false);
                },
                childCount: math.max(8, doneHobbies.length),
              ),
            ),
          ),

          // ═══════════════════════════════════════════
          //  MY PREFERENCES
          // ═══════════════════════════════════════════
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('My Preferences',
                          style: AppTypography.sansSection),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => context.push('/settings'),
                        child: Text(
                          'Edit',
                          style: AppTypography.sansLabel
                              .copyWith(color: AppColors.coral),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _PrefRow(
                    label: 'Weekly time',
                    value: '${prefs.hoursPerWeek}h / week',
                    icon: AppIcons.badgeTime,
                  ),
                  _PrefRow(
                    label: 'Budget',
                    value: _budgetLabel(prefs.budgetLevel),
                    icon: AppIcons.badgeCost,
                  ),
                  _PrefRow(
                    label: 'Style',
                    value: prefs.preferSocial ? 'Social' : 'Solo',
                    icon: Icons.people_outline_rounded,
                  ),
                  if (prefs.vibes.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: prefs.vibes.map((v) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.indigoPale,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            v[0].toUpperCase() + v.substring(1),
                            style: AppTypography.sansCaption
                                .copyWith(color: AppColors.indigo),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // ═══════════════════════════════════════════
          //  QUICK LINKS
          // ═══════════════════════════════════════════
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
              child: Column(
                children: [
                  _LinkTile(
                    icon: AppIcons.settings,
                    title: 'Settings',
                    subtitle: 'Preferences, notifications, theme',
                    onTap: () => context.push('/settings'),
                  ),
                  const SizedBox(height: 10),
                  _LinkTile(
                    icon: Icons.info_outline_rounded,
                    title: 'About TrySomething',
                    subtitle: 'Version 1.0 — Made with love',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),

          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  // ── Helpers ──

  static String _deriveIdentity(Set<String> vibes, int totalTried) {
    if (totalTried == 0) return 'Curious Explorer';
    final hasCreative = vibes.contains('creative');
    final hasPhysical = vibes.contains('physical');
    final hasOutdoors = vibes.contains('outdoors');
    final hasTechnical = vibes.contains('technical');
    if (hasCreative && hasPhysical) return 'Creative Athlete';
    if (hasCreative) return 'Curious Maker';
    if (hasPhysical && hasOutdoors) return 'Wild Adventurer';
    if (hasPhysical) return 'Active Explorer';
    if (hasOutdoors) return 'Nature Seeker';
    if (hasTechnical) return 'Builder Tinkerer';
    return 'Curious Explorer';
  }

  static int _identityLevel(int totalTried) {
    if (totalTried >= 10) return 4;
    if (totalTried >= 5) return 3;
    if (totalTried >= 2) return 2;
    return 1;
  }

  static String _identitySubtitle(Set<String> vibes) {
    if (vibes.isEmpty) return 'Start exploring to discover your identity';
    final topVibe = vibes.first;
    return "You're drawn to $topVibe experiences";
  }

  static String _budgetLabel(int level) {
    switch (level) {
      case 0:
        return 'Low budget';
      case 1:
        return 'Medium budget';
      case 2:
        return 'High budget';
      default:
        return 'Any budget';
    }
  }
}

// ═══════════════════════════════════════════════════════
//  QUICK STAT (horizontal row under profile card)
// ═══════════════════════════════════════════════════════

class _QuickStat extends StatelessWidget {
  final String number;
  final String label;
  final Color color;

  const _QuickStat(
      {required this.number, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withAlpha(15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withAlpha(25)),
        ),
        child: Column(
          children: [
            Text(
              number,
              style: AppTypography.monoMedium
                  .copyWith(fontWeight: FontWeight.w700, color: color),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTypography.sansTiny.copyWith(color: AppColors.warmGray),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  STAT TILE (Year in Hobbies 2×2 grid)
// ═══════════════════════════════════════════════════════

class _StatTile extends StatelessWidget {
  final String number;
  final String label;
  final Color color;

  const _StatTile(
      {required this.number, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            number,
            style: AppTypography.monoLarge
                .copyWith(fontWeight: FontWeight.w700, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style:
                AppTypography.sansCaption.copyWith(color: AppColors.driftwood),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  PASSPORT STAMP
// ═══════════════════════════════════════════════════════

class _PassportStamp extends StatelessWidget {
  final IconData? icon;
  final String? name;
  final Color? color;
  final bool isCollected;

  const _PassportStamp({
    this.icon,
    this.name,
    this.color,
    required this.isCollected,
  });

  @override
  Widget build(BuildContext context) {
    if (!isCollected) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.sand,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.sandDark),
        ),
        child: Center(
          child: Opacity(
            opacity: 0.3,
            child:
                Icon(AppIcons.lock, size: 18, color: AppColors.warmGray),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: (color ?? AppColors.coral).withAlpha(25),
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: (color ?? AppColors.coral).withAlpha(60)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon ?? AppIcons.check,
              size: 20, color: color ?? AppColors.coral),
          const SizedBox(height: 4),
          Text(
            name ?? '',
            style: AppTypography.monoBadgeSmall
                .copyWith(color: AppColors.driftwood),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  PREFERENCE ROW
// ═══════════════════════════════════════════════════════

class _PrefRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _PrefRow(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.sand,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(icon, size: 16, color: AppColors.driftwood),
            ),
          ),
          const SizedBox(width: 12),
          Text(label,
              style: AppTypography.sansBodySmall
                  .copyWith(color: AppColors.warmGray)),
          const Spacer(),
          Text(value,
              style: AppTypography.sansLabel
                  .copyWith(color: AppColors.espresso)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  LINK TILE (settings, about)
// ═══════════════════════════════════════════════════════

class _LinkTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _LinkTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.warmWhite,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.sand,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(icon, size: 16, color: AppColors.driftwood),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTypography.sansLabel
                          .copyWith(color: AppColors.espresso)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: AppTypography.sansTiny
                          .copyWith(color: AppColors.warmGray)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                size: 20, color: AppColors.warmGray),
          ],
        ),
      ),
    );
  }
}
