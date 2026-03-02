import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/hobby.dart';
import '../../providers/feature_providers.dart';
import '../../providers/hobby_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_icons.dart';
import '../../theme/app_typography.dart';
import '../../theme/spacing.dart';

/// Compare Mode — select up to 3 hobbies and compare cost, time, difficulty.
class CompareModeScreen extends ConsumerWidget {
  const CompareModeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allHobbies = ref.watch(hobbyListProvider).valueOrNull ?? [];
    final selectedIds = ref.watch(selectedCompareProvider);

    // Resolve selected hobbies
    final selectedHobbies = selectedIds
        .map((id) => ref.watch(hobbyByIdProvider(id)).valueOrNull)
        .where((h) => h != null)
        .cast<Hobby>()
        .toList();

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────
            _buildHeader(context),

            // ── Hobby selector ──────────────────────
            _buildHobbySelector(ref, allHobbies, selectedIds),

            const SizedBox(height: 16),

            // ── Comparison table ────────────────────
            Expanded(
              child: selectedHobbies.isEmpty
                  ? _buildEmptyState()
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                      child: _buildComparisonTable(selectedHobbies),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 24, 8),
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
              ),
              child: Center(
                child: Icon(AppIcons.arrowBack, size: 20, color: AppColors.nearBlack),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text('Compare Hobbies', style: AppTypography.serifHeading),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  //  HOBBY SELECTOR PILLS
  // ═══════════════════════════════════════════════════════

  Widget _buildHobbySelector(WidgetRef ref, List<Hobby> hobbies, List<String> selectedIds) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: hobbies.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final hobby = hobbies[index];
          final isSelected = selectedIds.contains(hobby.id);
          final isMaxed = selectedIds.length >= 3 && !isSelected;

          return GestureDetector(
            onTap: isMaxed
                ? null
                : () {
                    final notifier = ref.read(selectedCompareProvider.notifier);
                    if (isSelected) {
                      notifier.state = selectedIds.where((id) => id != hobby.id).toList();
                    } else {
                      notifier.state = [...selectedIds, hobby.id];
                    }
                  },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.coral : AppColors.sand,
                borderRadius: BorderRadius.circular(Spacing.radiusBadge),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSelected) ...[
                    Icon(AppIcons.check, size: 14, color: Colors.white),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    hobby.title,
                    style: AppTypography.sansLabel.copyWith(
                      color: isSelected
                          ? Colors.white
                          : isMaxed
                              ? AppColors.warmGray
                              : AppColors.nearBlack,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  //  EMPTY STATE
  // ═══════════════════════════════════════════════════════

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(AppIcons.compare, size: 48, color: AppColors.sandDark),
          const SizedBox(height: 16),
          Text(
            'Select hobbies to compare',
            style: AppTypography.sansSection.copyWith(color: AppColors.driftwood),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap up to 3 hobbies above to see them side-by-side.',
            style: AppTypography.sansBodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  //  COMPARISON TABLE
  // ═══════════════════════════════════════════════════════

  Widget _buildComparisonTable(List<Hobby> hobbies) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.warmWhite,
        borderRadius: BorderRadius.circular(Spacing.radiusCard),
      ),
      child: Column(
        children: [
          // ── Column headers (hobby images + names) ──
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            decoration: BoxDecoration(
              color: AppColors.sand.withValues(alpha: 0.5),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(Spacing.radiusCard),
                topRight: Radius.circular(Spacing.radiusCard),
              ),
            ),
            child: Row(
              children: [
                // Label column
                const SizedBox(width: 80),

                // Hobby columns
                ...hobbies.map((h) => Expanded(
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(Spacing.radiusTile),
                            child: CachedNetworkImage(
                              imageUrl: h.imageUrl,
                              width: 52,
                              height: 52,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(
                                width: 52, height: 52, color: AppColors.sand,
                              ),
                              errorWidget: (_, __, ___) => Container(
                                width: 52, height: 52, color: AppColors.sand,
                                child: Icon(AppIcons.image, size: 20, color: AppColors.warmGray),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            h.title,
                            style: AppTypography.sansLabel,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),

          // Separator
          Container(height: 1, color: AppColors.sandDark),

          // ── Rows ──────────────────────────────────
          _tableRow(
            'Cost',
            hobbies.map((h) => h.costText).toList(),
            AppColors.coralPale,
            AppColors.coral,
            AppIcons.badgeCost,
          ),
          Container(height: 1, color: AppColors.sandDark.withValues(alpha: 0.5)),
          _tableRow(
            'Time',
            hobbies.map((h) => h.timeText).toList(),
            AppColors.amberPale,
            AppColors.amber,
            AppIcons.badgeTime,
          ),
          Container(height: 1, color: AppColors.sandDark.withValues(alpha: 0.5)),
          _tableRow(
            'Difficulty',
            hobbies.map((h) => h.difficultyText).toList(),
            AppColors.indigoPale,
            AppColors.indigo,
            AppIcons.badgeDifficulty,
          ),
        ],
      ),
    );
  }

  Widget _tableRow(
    String label,
    List<String> values,
    Color cellBg,
    Color cellColor,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      child: Row(
        children: [
          // Label column
          SizedBox(
            width: 80,
            child: Row(
              children: [
                Icon(icon, size: 16, color: cellColor),
                const SizedBox(width: 6),
                Text(label, style: AppTypography.sansLabel),
              ],
            ),
          ),

          // Value cells
          ...values.map((val) => Expanded(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: cellBg,
                      borderRadius: BorderRadius.circular(Spacing.radiusBadge),
                    ),
                    child: Text(
                      val,
                      style: AppTypography.monoBadge.copyWith(color: cellColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
