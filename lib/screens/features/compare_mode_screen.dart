import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/hobby.dart';
import '../../providers/feature_providers.dart';
import '../../providers/hobby_provider.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_icons.dart';
import '../../theme/app_typography.dart';
import '../../theme/spacing.dart';

/// Hobby Battle — side-by-side comparison of two hobbies.
class CompareModeScreen extends ConsumerWidget {
  const CompareModeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allHobbies = ref.watch(hobbyListProvider).valueOrNull ?? [];
    final selectedIds = ref.watch(selectedCompareProvider);

    final hobbies = selectedIds
        .map((id) => ref.watch(hobbyByIdProvider(id)).valueOrNull)
        .where((h) => h != null)
        .cast<Hobby>()
        .toList();

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: hobbies.length < 2
            ? _buildSelector(context, ref, allHobbies, selectedIds)
            : _buildBattle(context, ref, hobbies[0], hobbies[1]),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  //  HOBBY SELECTOR (when < 2 selected)
  // ═══════════════════════════════════════════════════════

  Widget _buildSelector(
      BuildContext context, WidgetRef ref, List<Hobby> hobbies, List<String> selectedIds) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(context),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          child: Text(
            'Select 2 hobbies to battle',
            style: AppTypography.sansSection.copyWith(color: AppColors.driftwood),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: hobbies.length,
            itemBuilder: (context, i) {
              final h = hobbies[i];
              final isSelected = selectedIds.contains(h.id);
              return GestureDetector(
                onTap: () {
                  final notifier = ref.read(selectedCompareProvider.notifier);
                  if (isSelected) {
                    notifier.state = selectedIds.where((id) => id != h.id).toList();
                  } else if (selectedIds.length < 2) {
                    notifier.state = [...selectedIds, h.id];
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.coral.withValues(alpha: 0.1)
                        : AppColors.warmWhite,
                    borderRadius: BorderRadius.circular(14),
                    border: isSelected
                        ? Border.all(color: AppColors.coral, width: 1.5)
                        : null,
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(h.imageUrl,
                            width: 44, height: 44, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                Container(width: 44, height: 44, color: AppColors.sand)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(h.title,
                            style: AppTypography.sansBody
                                .copyWith(fontWeight: FontWeight.w600)),
                      ),
                      if (isSelected)
                        Icon(AppIcons.check, size: 18, color: AppColors.coral),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════
  //  BATTLE VIEW
  // ═══════════════════════════════════════════════════════

  Widget _buildBattle(
      BuildContext context, WidgetRef ref, Hobby left, Hobby right) {
    // Determine "winner" based on simulated community vote
    final leftVote = (left.id.hashCode.abs() % 40) + 30;
    final rightVote = 100 - leftVote;
    final winnerName = leftVote >= rightVote ? left.title : right.title;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(context),
          const SizedBox(height: 16),

          // Side-by-side images with VS badge
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(
              height: 160,
              child: Stack(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(Spacing.radiusTile),
                          child: Image.network(left.imageUrl,
                              height: 160, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  Container(height: 160, color: AppColors.sand)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(Spacing.radiusTile),
                          child: Image.network(right.imageUrl,
                              height: 160, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  Container(height: 160, color: AppColors.sand)),
                        ),
                      ),
                    ],
                  ),
                  // VS badge
                  Center(
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.coral,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.cream, width: 3),
                      ),
                      child: Center(
                        child: Text(
                          'VS',
                          style: AppTypography.monoBadge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Hobby names
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(left.title,
                          style: AppTypography.sansSection,
                          textAlign: TextAlign.center),
                      Text(left.category.toUpperCase(),
                          style: AppTypography.monoBadgeSmall
                              .copyWith(color: AppColors.warmGray)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    children: [
                      Text(right.title,
                          style: AppTypography.sansSection,
                          textAlign: TextAlign.center),
                      Text(right.category.toUpperCase(),
                          style: AppTypography.monoBadgeSmall
                              .copyWith(color: AppColors.warmGray)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Head-to-Head section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text('Head-to-Head', style: AppTypography.serifSubheading),
          ),
          const SizedBox(height: 16),

          _comparisonRow(
            icon: AppIcons.badgeCost,
            label: 'COST',
            leftValue: left.costText,
            rightValue: right.costText,
            leftDesc: _costDesc(left),
            rightDesc: _costDesc(right),
            color: AppColors.coral,
          ),
          const SizedBox(height: 10),
          _comparisonRow(
            icon: AppIcons.badgeTime,
            label: 'TIME',
            leftValue: left.timeText,
            rightValue: right.timeText,
            leftDesc: _timeDesc(left),
            rightDesc: _timeDesc(right),
            color: AppColors.sky,
          ),
          const SizedBox(height: 10),
          _comparisonRow(
            icon: AppIcons.badgeDifficulty,
            label: 'DIFF',
            leftValue: left.difficultyText,
            rightValue: right.difficultyText,
            leftDesc: left.difficultyExplain.length > 40
                ? '${left.difficultyExplain.substring(0, 40)}...'
                : left.difficultyExplain,
            rightDesc: right.difficultyExplain.length > 40
                ? '${right.difficultyExplain.substring(0, 40)}...'
                : right.difficultyExplain,
            color: AppColors.indigo,
          ),
          const SizedBox(height: 28),

          // Community Winner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Community Winner', style: AppTypography.sansSection),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(Spacing.radiusBadge),
                  child: SizedBox(
                    height: 36,
                    child: Row(
                      children: [
                        Expanded(
                          flex: leftVote,
                          child: Container(
                            color: AppColors.coral,
                            alignment: Alignment.center,
                            child: Text(
                              '${left.title} ($leftVote%)',
                              style: AppTypography.monoBadge.copyWith(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: rightVote,
                          child: Container(
                            color: AppColors.sand,
                            alignment: Alignment.center,
                            child: Text(
                              right.title,
                              style: AppTypography.monoBadge.copyWith(
                                color: AppColors.driftwood,
                                fontSize: 11,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Dual CTAs
          Padding(
            padding: EdgeInsets.fromLTRB(24, 0, 24, Spacing.scrollBottom(context)),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      ref.read(userHobbiesProvider.notifier).saveHobby(left.id);
                      ref.read(userHobbiesProvider.notifier).saveHobby(right.id);
                      context.pop();
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      side: const BorderSide(color: AppColors.stone),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Spacing.radiusButton),
                      ),
                    ),
                    child: Text('Save Both',
                        style: AppTypography.sansLabel
                            .copyWith(color: AppColors.nearBlack)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final winnerId =
                          leftVote >= rightVote ? left.id : right.id;
                      final canStart = ref.read(canStartHobbyProvider(winnerId));
                      if (!canStart) {
                        context.push('/pro');
                        return;
                      }
                      ref
                          .read(userHobbiesProvider.notifier)
                          .startTrying(winnerId);
                      context.go('/home?hobby=$winnerId');
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      backgroundColor: AppColors.coral,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Spacing.radiusButton),
                      ),
                    ),
                    child: Text('Start $winnerName',
                        style: AppTypography.sansCta,
                        overflow: TextOverflow.ellipsis),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  //  HELPERS
  // ═══════════════════════════════════════════════════════

  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: const Icon(Icons.arrow_back,
                size: 20, color: AppColors.espresso),
          ),
          const Spacer(),
          Text('Hobby Battle', style: AppTypography.sansSection),
          const Spacer(),
          const Icon(Icons.ios_share_rounded,
              size: 18, color: AppColors.espresso),
        ],
      ),
    );
  }

  Widget _comparisonRow({
    required IconData icon,
    required String label,
    required String leftValue,
    required String rightValue,
    required String leftDesc,
    required String rightDesc,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // Left side
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.warmWhite,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, size: 16, color: color),
                      const SizedBox(width: 6),
                      Text(leftValue,
                          style: AppTypography.sansLabel
                              .copyWith(color: color, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(leftDesc,
                      style: AppTypography.sansTiny
                          .copyWith(color: AppColors.driftwood),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ),

          // Center label
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: RotatedBox(
              quarterTurns: 3,
              child: Text(label,
                  style: AppTypography.monoBadgeSmall
                      .copyWith(color: AppColors.warmGray)),
            ),
          ),

          // Right side
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.warmWhite,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, size: 16, color: color),
                      const SizedBox(width: 6),
                      Text(rightValue,
                          style: AppTypography.sansLabel
                              .copyWith(color: color, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(rightDesc,
                      style: AppTypography.sansTiny
                          .copyWith(color: AppColors.driftwood),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _costDesc(Hobby h) =>
      'Equipment & supplies for getting started';

  String _timeDesc(Hobby h) =>
      '${h.timeText} commitment weekly';
}
