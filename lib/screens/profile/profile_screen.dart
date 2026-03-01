import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../models/hobby.dart';
import '../../models/feature_seed_data.dart';
import '../../theme/category_ui.dart';
import '../../providers/hobby_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/feature_providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_icons.dart';
import '../../theme/app_typography.dart';

/// Profile tab — photo, editable name/bio, heatmap, radar, gallery, passport.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  // Heatmap tooltip
  DateTime? _hoveredDate;
  int _hoveredLevel = 0;
  Offset _tooltipOffset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(userPreferencesProvider);
    final userHobbies = ref.watch(userHobbiesProvider);
    final allHobbies = ref.watch(hobbyListProvider).valueOrNull ?? [];
    final profile = ref.watch(profileProvider);

    // Counts
    final tryingCount = ref.watch(hobbyCountByStatusProvider(HobbyStatus.trying));
    final activeCount = ref.watch(hobbyCountByStatusProvider(HobbyStatus.active));
    final doneCount = ref.watch(hobbyCountByStatusProvider(HobbyStatus.done));
    final savedCount = ref.watch(hobbyCountByStatusProvider(HobbyStatus.saved));
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
            uh.status == HobbyStatus.active || uh.status == HobbyStatus.trying)
        .map((uh) => allHobbies.firstWhere(
              (h) => h.id == uh.hobbyId,
              orElse: () => allHobbies.first,
            ))
        .toList();

    // Dynamic identity
    final identity = _deriveIdentity(prefs.vibes, totalTried);
    final level = _identityLevel(totalTried);
    final nextLevelNeeded = _nextLevelThreshold(totalTried);
    final levelProgress = _levelProgress(totalTried);

    // Skill categories for radar
    final skillScores = _computeSkillScores(activeHobbies, doneHobbies);

    // Photos from journal
    final journalPhotos = ref.watch(journalProvider)
        .where((e) => e.photoUrl != null)
        .map((e) => e.photoUrl!)
        .toList();
    final allPhotos = [...journalPhotos, ...FeatureSeedData.profilePhotos];

    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ═══════════════════════════════════════════
              //  HEADER
              // ═══════════════════════════════════════════
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                  child: Row(
                    children: [
                      Text('Profile', style: AppTypography.serifHeading),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => context.push('/settings'),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.sand,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Icon(AppIcons.settings, size: 18, color: AppColors.driftwood),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ═══════════════════════════════════════════
              //  PROFILE CARD — photo + name + bio + level
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
                        // ── Profile photo with camera badge ──
                        GestureDetector(
                          onTap: () => _showPhotoOptions(context),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 96,
                                height: 96,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: profile.avatarUrl == null
                                      ? const LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [AppColors.indigo, AppColors.indigoDeep],
                                        )
                                      : null,
                                  border: Border.all(color: AppColors.indigo, width: 3),
                                  image: profile.avatarUrl != null
                                      ? DecorationImage(
                                          image: NetworkImage(profile.avatarUrl!),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: profile.avatarUrl == null
                                    ? Center(
                                        child: Text(
                                          profile.username != 'Your Name'
                                              ? profile.username[0].toUpperCase()
                                              : '?',
                                          style: AppTypography.serifHeading
                                              .copyWith(color: AppColors.coral),
                                        ),
                                      )
                                    : null,
                              ),
                              // Camera badge
                              Positioned(
                                bottom: 0,
                                right: -2,
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: AppColors.coral,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.warmWhite, width: 2.5),
                                  ),
                                  child: const Icon(Icons.camera_alt_rounded,
                                      size: 14, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // ── Level pill ──
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.sand,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            'LEVEL $level',
                            style: AppTypography.monoBadgeSmall
                                .copyWith(color: AppColors.coral, letterSpacing: 2),
                          ),
                        ),
                        const SizedBox(height: 6),

                        // ── Next level progress ──
                        SizedBox(
                          width: 120,
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: LinearProgressIndicator(
                                  value: levelProgress,
                                  backgroundColor: AppColors.sand,
                                  color: AppColors.coral,
                                  minHeight: 3,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '$nextLevelNeeded more to Level ${level + 1}',
                                style: AppTypography.sansTiny.copyWith(fontSize: 9),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),

                        // ── Editable username ──
                        GestureDetector(
                          onTap: () => _editUsername(context, ref, profile.username),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                profile.username,
                                style: AppTypography.serifSubheading.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(AppIcons.edit, size: 14, color: AppColors.warmGray),
                            ],
                          ),
                        ),

                        // ── Identity title ──
                        Text(
                          identity,
                          style: AppTypography.sansCaption.copyWith(color: AppColors.coral),
                        ),
                        const SizedBox(height: 4),

                        // ── Editable bio ──
                        GestureDetector(
                          onTap: () => _editBio(context, ref, profile.bio),
                          child: Text(
                            profile.bio.isEmpty ? 'Tap to add a bio...' : profile.bio,
                            style: AppTypography.sansBodySmall.copyWith(
                              color: profile.bio.isEmpty
                                  ? AppColors.warmGray
                                  : AppColors.driftwood,
                              fontStyle: profile.bio.isEmpty
                                  ? FontStyle.italic
                                  : FontStyle.normal,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // ── Active hobby tags ──
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
                                  color: AppColors.sand,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(h.catIcon, size: 13, color: h.catColor),
                                    const SizedBox(width: 5),
                                    Text(
                                      h.title.length > 14
                                          ? '${h.title.substring(0, 14)}…'
                                          : h.title,
                                      style: AppTypography.sansCaption
                                          .copyWith(color: AppColors.driftwood),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        const SizedBox(height: 16),

                        // ── Share profile button ──
                        OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Profile sharing coming soon!',
                                    style: AppTypography.sansLabel
                                        .copyWith(color: Colors.white)),
                                backgroundColor: AppColors.coral,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                            );
                          },
                          icon: Icon(AppIcons.shareProfile, size: 16),
                          label: const Text('Share Profile Card'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(180, 38),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                          ),
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
              //  ACTIVITY HEATMAP (GitHub-style)
              // ═══════════════════════════════════════════
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                  child: _buildHeatmap(),
                ),
              ),

              // ═══════════════════════════════════════════
              //  SKILLS RADAR
              // ═══════════════════════════════════════════
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                  child: _buildSkillsRadar(skillScores),
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
                      Text('Year in Hobbies', style: AppTypography.serifSubheading),
                      const SizedBox(height: 16),
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
              //  MY PHOTOS
              // ═══════════════════════════════════════════
              if (allPhotos.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
                    child: Row(
                      children: [
                        Icon(AppIcons.image, size: 18, color: AppColors.coral),
                        const SizedBox(width: 8),
                        Text('My Photos', style: AppTypography.sansSection),
                        const Spacer(),
                        Text(
                          '${allPhotos.length} photos',
                          style: AppTypography.monoCaption
                              .copyWith(color: AppColors.warmGray),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 6,
                      crossAxisSpacing: 6,
                      childAspectRatio: 1,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return GestureDetector(
                          onTap: () => _showPhotoViewer(context, allPhotos, index),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              allPhotos[index],
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: AppColors.sand,
                                child: Icon(AppIcons.image,
                                    color: AppColors.warmGray, size: 24),
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: allPhotos.take(9).length,
                    ),
                  ),
                ),
              ],

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
                          Icon(AppIcons.trophy, size: 18, color: AppColors.amber),
                          const SizedBox(width: 8),
                          Text('Hobby Passport', style: AppTypography.sansSection),
                          const Spacer(),
                          Text(
                            '${doneHobbies.length}/50',
                            style: AppTypography.monoCaption
                                .copyWith(color: AppColors.warmGray),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
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
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                          Text('My Preferences', style: AppTypography.sansSection),
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
                                color: AppColors.sand,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                v[0].toUpperCase() + v.substring(1),
                                style: AppTypography.sansCaption
                                    .copyWith(color: AppColors.driftwood),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Quick Links', style: AppTypography.sansSection),
                      const SizedBox(height: 14),
                      _LinkTile(
                        icon: AppIcons.journal,
                        title: 'Hobby Journal',
                        subtitle: 'Photos, notes & memories',
                        onTap: () => context.push('/journal'),
                      ),
                      const SizedBox(height: 10),
                      _LinkTile(
                        icon: AppIcons.calendar,
                        title: 'Hobby Scheduler',
                        subtitle: 'Plan your weekly sessions',
                        onTap: () => context.push('/scheduler'),
                      ),
                      const SizedBox(height: 10),
                      _LinkTile(
                        icon: AppIcons.buddy,
                        title: 'Buddy Mode',
                        subtitle: 'Find a hobby partner',
                        onTap: () => context.push('/buddy'),
                      ),
                      const SizedBox(height: 10),
                      _LinkTile(
                        icon: AppIcons.challenge,
                        title: 'Weekly Challenge',
                        subtitle: 'This week\'s hobby challenge',
                        onTap: () => context.push('/challenge'),
                      ),
                      const SizedBox(height: 10),
                      _LinkTile(
                        icon: AppIcons.yearReview,
                        title: 'Year in Review',
                        subtitle: 'Your hobby journey wrapped',
                        onTap: () => context.push('/year-review'),
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

          // ── Heatmap tooltip overlay ──
          if (_hoveredDate != null)
            Positioned(
              left: _tooltipOffset.dx,
              top: _tooltipOffset.dy,
              child: _HeatmapTooltip(
                date: _hoveredDate!,
                level: _hoveredLevel,
              ),
            ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  //  ACTIVITY HEATMAP (GitHub-style)
  // ══════════════════════════════════════════════════════════

  Widget _buildHeatmap() {
    final data = FeatureSeedData.generateHeatmapData(days: 112);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 16 weeks of data
    const weeks = 20;
    const cellSize = 14.0;
    const cellGap = 3.0;

    // Find the start date (beginning of the week, 16 weeks ago)
    final startDate = today.subtract(Duration(days: today.weekday - 1 + (weeks - 1) * 7));

    // Day labels
    const dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(AppIcons.fire, size: 18, color: AppColors.coral),
            const SizedBox(width: 8),
            Text('Activity', style: AppTypography.sansSection),
          ],
        ),
        const SizedBox(height: 14),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Month labels
              Row(
                children: [
                  const SizedBox(width: 20), // offset for day labels
                  ...List.generate(weeks, (weekIdx) {
                    final weekStart = startDate.add(Duration(days: weekIdx * 7));
                    // Show month label on first week of each month
                    final showLabel = weekIdx == 0 ||
                        weekStart.month !=
                            startDate.add(Duration(days: (weekIdx - 1) * 7)).month;
                    return SizedBox(
                      width: cellSize + cellGap,
                      child: showLabel
                          ? Text(
                              DateFormat.MMM().format(weekStart),
                              style: AppTypography.sansTiny.copyWith(fontSize: 8),
                            )
                          : null,
                    );
                  }),
                ],
              ),
              const SizedBox(height: 4),
              // Grid
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Day-of-week labels
                  Column(
                    children: List.generate(7, (dayIdx) {
                      return SizedBox(
                        height: cellSize + cellGap,
                        width: 18,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            dayLabels[dayIdx],
                            style: AppTypography.sansTiny.copyWith(fontSize: 8),
                          ),
                        ),
                      );
                    }),
                  ),
                  // Weeks
                  ...List.generate(weeks, (weekIdx) {
                    return Column(
                      children: List.generate(7, (dayIdx) {
                        final cellDate = startDate
                            .add(Duration(days: weekIdx * 7 + dayIdx));
                        final level = data[cellDate] ?? 0;
                        final isFuture = cellDate.isAfter(today);

                        return Padding(
                          padding: const EdgeInsets.only(
                              right: cellGap, bottom: cellGap),
                          child: GestureDetector(
                            onTapDown: isFuture
                                ? null
                                : (details) {
                                    setState(() {
                                      _hoveredDate = cellDate;
                                      _hoveredLevel = level;
                                      // Position tooltip above the cell
                                      final renderBox =
                                          context.findRenderObject()
                                              as RenderBox;
                                      final localPos = renderBox
                                          .globalToLocal(
                                              details.globalPosition);
                                      _tooltipOffset = Offset(
                                        (localPos.dx - 80).clamp(8, MediaQuery.of(context).size.width - 200),
                                        localPos.dy - 65,
                                      );
                                    });
                                  },
                            onTapUp: (_) {
                              Future.delayed(const Duration(seconds: 2), () {
                                if (mounted) {
                                  setState(() => _hoveredDate = null);
                                }
                              });
                            },
                            child: Container(
                              width: cellSize,
                              height: cellSize,
                              decoration: BoxDecoration(
                                color: isFuture
                                    ? AppColors.sand.withAlpha(100)
                                    : _heatmapColor(level),
                                borderRadius: BorderRadius.circular(3),
                                border: cellDate == today
                                    ? Border.all(
                                        color: AppColors.coral, width: 1.5)
                                    : null,
                              ),
                            ),
                          ),
                        );
                      }),
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Legend
        Row(
          children: [
            Text('Less', style: AppTypography.sansTiny.copyWith(fontSize: 9)),
            const SizedBox(width: 4),
            ...List.generate(4, (i) {
              return Padding(
                padding: const EdgeInsets.only(right: 3),
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _heatmapColor(i),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
            const SizedBox(width: 2),
            Text('More', style: AppTypography.sansTiny.copyWith(fontSize: 9)),
          ],
        ),
      ],
    );
  }

  Color _heatmapColor(int level) {
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

  // ══════════════════════════════════════════════════════════
  //  SKILLS RADAR (CustomPainter spider chart)
  // ══════════════════════════════════════════════════════════

  Widget _buildSkillsRadar(Map<String, double> scores) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(AppIcons.radar, size: 18, color: AppColors.indigo),
            const SizedBox(width: 8),
            Text('Skills Radar', style: AppTypography.sansSection),
          ],
        ),
        const SizedBox(height: 16),
        Center(
          child: SizedBox(
            width: 220,
            height: 220,
            child: CustomPaint(
              painter: _RadarPainter(
                scores: scores,
                lineColor: AppColors.sandDark,
                fillColor: AppColors.coral.withAlpha(40),
                strokeColor: AppColors.coral,
                labelStyle: AppTypography.sansTiny.copyWith(
                  fontSize: 10,
                  color: AppColors.driftwood,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════
  //  EDIT USERNAME / BIO
  // ══════════════════════════════════════════════════════════

  void _editUsername(BuildContext context, WidgetRef ref, String current) {
    final controller = TextEditingController(
        text: current == 'Your Name' ? '' : current);
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Edit Name', style: AppTypography.sansSection),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(hintText: 'Enter your name'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  ref.read(profileProvider.notifier).updateUsername(name);
                }
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _editBio(BuildContext context, WidgetRef ref, String current) {
    final controller = TextEditingController(text: current);
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Edit Bio', style: AppTypography.sansSection),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              autofocus: true,
              maxLines: 3,
              maxLength: 150,
              decoration: const InputDecoration(
                  hintText: 'Tell us about yourself...'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(profileProvider.notifier)
                    .updateBio(controller.text.trim());
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showPhotoOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Profile Photo', style: AppTypography.sansSection),
            const SizedBox(height: 20),
            _PhotoOptionTile(
              icon: Icons.camera_alt_rounded,
              label: 'Take Photo',
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Camera coming soon!',
                        style: AppTypography.sansLabel
                            .copyWith(color: Colors.white)),
                    backgroundColor: AppColors.coral,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            _PhotoOptionTile(
              icon: Icons.photo_library_rounded,
              label: 'Choose from Library',
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Gallery coming soon!',
                        style: AppTypography.sansLabel
                            .copyWith(color: Colors.white)),
                    backgroundColor: AppColors.coral,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPhotoViewer(
      BuildContext context, List<String> photos, int initialIndex) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            PageView.builder(
              controller: PageController(initialPage: initialIndex),
              itemCount: photos.length,
              itemBuilder: (_, i) => Center(
                child: Image.network(
                  photos[i].replaceAll('w=300', 'w=800'),
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(AppIcons.image,
                      color: AppColors.warmGray, size: 48),
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: SafeArea(
                child: IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                ),
              ),
            ),
          ],
        ),
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

  static int _nextLevelThreshold(int totalTried) {
    if (totalTried >= 10) return 0;
    if (totalTried >= 5) return 10 - totalTried;
    if (totalTried >= 2) return 5 - totalTried;
    return 2 - totalTried;
  }

  static double _levelProgress(int totalTried) {
    if (totalTried >= 10) return 1.0;
    if (totalTried >= 5) return (totalTried - 5) / 5.0;
    if (totalTried >= 2) return (totalTried - 2) / 3.0;
    return totalTried / 2.0;
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

  static Map<String, double> _computeSkillScores(
      List<Hobby> active, List<Hobby> done) {
    final categories = {
      'Creative': 0.0,
      'Physical': 0.0,
      'Technical': 0.0,
      'Outdoors': 0.0,
      'Social': 0.0,
      'Relaxing': 0.0,
    };

    final all = [...active, ...done];
    if (all.isEmpty) {
      // Default small values so chart isn't empty
      return categories.map((k, _) => MapEntry(k, 0.15));
    }

    for (final hobby in all) {
      for (final tag in hobby.tags) {
        final key = tag[0].toUpperCase() + tag.substring(1);
        if (categories.containsKey(key)) {
          categories[key] = (categories[key]! + 0.35).clamp(0.0, 1.0);
        }
      }
      // Category mapping
      switch (hobby.category.toLowerCase()) {
        case 'creative':
          categories['Creative'] =
              (categories['Creative']! + 0.2).clamp(0.0, 1.0);
          break;
        case 'fitness':
          categories['Physical'] =
              (categories['Physical']! + 0.2).clamp(0.0, 1.0);
          break;
        case 'outdoors':
          categories['Outdoors'] =
              (categories['Outdoors']! + 0.2).clamp(0.0, 1.0);
          break;
        case 'mind':
          categories['Technical'] =
              (categories['Technical']! + 0.2).clamp(0.0, 1.0);
          break;
        case 'social':
          categories['Social'] =
              (categories['Social']! + 0.2).clamp(0.0, 1.0);
          break;
      }
    }

    // Ensure minimum visibility
    return categories.map(
        (k, v) => MapEntry(k, v == 0.0 ? 0.08 : v));
  }
}

// ═══════════════════════════════════════════════════════
//  HEATMAP TOOLTIP
// ═══════════════════════════════════════════════════════

class _HeatmapTooltip extends StatelessWidget {
  final DateTime date;
  final int level;

  const _HeatmapTooltip({required this.date, required this.level});

  @override
  Widget build(BuildContext context) {
    final tooltip = FeatureSeedData.heatmapTooltip(date, level);
    final dateStr = DateFormat('MMM d').format(date);
    final levelText = ['No activity', 'Light', 'Moderate', 'Heavy'][level];

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.sandDark,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Color.fromARGB(95, 0, 0, 0),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$dateStr — $levelText',
              style: AppTypography.sansTiny.copyWith(
                  color: AppColors.nearBlack, fontWeight: FontWeight.w600),
            ),
            if (tooltip != null) ...[
              const SizedBox(height: 2),
              Text(
                tooltip,
                style: AppTypography.sansTiny
                    .copyWith(color: AppColors.driftwood, fontSize: 10),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  RADAR / SPIDER CHART PAINTER
// ═══════════════════════════════════════════════════════

class _RadarPainter extends CustomPainter {
  final Map<String, double> scores;
  final Color lineColor;
  final Color fillColor;
  final Color strokeColor;
  final TextStyle labelStyle;

  _RadarPainter({
    required this.scores,
    required this.lineColor,
    required this.fillColor,
    required this.strokeColor,
    required this.labelStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 28;
    final labels = scores.keys.toList();
    final values = scores.values.toList();
    final count = labels.length;
    final angleStep = (2 * math.pi) / count;
    // Start from top (–π/2)
    const startAngle = -math.pi / 2;

    final gridPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw grid rings (3 levels)
    for (int ring = 1; ring <= 3; ring++) {
      final r = radius * ring / 3;
      final path = Path();
      for (int i = 0; i <= count; i++) {
        final angle = startAngle + angleStep * (i % count);
        final point = Offset(
          center.dx + r * math.cos(angle),
          center.dy + r * math.sin(angle),
        );
        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      canvas.drawPath(path, gridPaint);
    }

    // Draw axis lines
    for (int i = 0; i < count; i++) {
      final angle = startAngle + angleStep * i;
      canvas.drawLine(
        center,
        Offset(
          center.dx + radius * math.cos(angle),
          center.dy + radius * math.sin(angle),
        ),
        gridPaint,
      );
    }

    // Draw value polygon
    final valuePath = Path();
    for (int i = 0; i <= count; i++) {
      final idx = i % count;
      final angle = startAngle + angleStep * idx;
      final r = radius * values[idx];
      final point = Offset(
        center.dx + r * math.cos(angle),
        center.dy + r * math.sin(angle),
      );
      if (i == 0) {
        valuePath.moveTo(point.dx, point.dy);
      } else {
        valuePath.lineTo(point.dx, point.dy);
      }
    }
    canvas.drawPath(valuePath, fillPaint);
    canvas.drawPath(valuePath, strokePaint);

    // Draw data points
    final dotPaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.fill;
    for (int i = 0; i < count; i++) {
      final angle = startAngle + angleStep * i;
      final r = radius * values[i];
      canvas.drawCircle(
        Offset(
          center.dx + r * math.cos(angle),
          center.dy + r * math.sin(angle),
        ),
        3.5,
        dotPaint,
      );
    }

    // Draw labels
    for (int i = 0; i < count; i++) {
      final angle = startAngle + angleStep * i;
      final labelRadius = radius + 18;
      final pos = Offset(
        center.dx + labelRadius * math.cos(angle),
        center.dy + labelRadius * math.sin(angle),
      );

      final tp = TextPainter(
        text: TextSpan(text: labels[i], style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(
        canvas,
        Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) =>
      scores != oldDelegate.scores;
}

// ═══════════════════════════════════════════════════════
//  QUICK STAT
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
//  STAT TILE
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
        ),
        child: Center(
          child: Opacity(
            opacity: 0.3,
            child: Icon(AppIcons.lock, size: 18, color: AppColors.warmGray),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: (color ?? AppColors.coral).withAlpha(25),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: (color ?? AppColors.coral).withAlpha(60)),
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
//  LINK TILE
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
            const Icon(Icons.chevron_right_rounded,
                size: 20, color: AppColors.warmGray),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  PHOTO OPTION TILE
// ═══════════════════════════════════════════════════════

class _PhotoOptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PhotoOptionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.warmWhite,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.coralPale,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(icon, size: 20, color: AppColors.coral),
              ),
            ),
            const SizedBox(width: 14),
            Text(label, style: AppTypography.sansLabel),
          ],
        ),
      ),
    );
  }
}
