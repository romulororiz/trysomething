import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/features.dart';
import '../../providers/feature_providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_icons.dart';
import '../../theme/app_typography.dart';
import '../../theme/spacing.dart';

/// Weekly Challenge — current active challenge with progress + completed history.
class WeeklyChallengeScreen extends ConsumerWidget {
  const WeeklyChallengeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentChallenge = ref.watch(currentChallengeProvider);
    final allChallenges = ref.watch(challengeProvider);
    final completedChallenges =
        allChallenges.where((c) => c.isCompleted).toList();

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────
            _buildHeader(context),

            // ── Content ─────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Current challenge
                    if (currentChallenge != null) ...[
                      _buildCurrentChallenge(currentChallenge),
                      const SizedBox(height: 28),
                    ] else ...[
                      _buildNoChallengeState(),
                      const SizedBox(height: 28),
                    ],

                    // Completed section
                    if (completedChallenges.isNotEmpty) ...[
                      Text('Completed', style: AppTypography.sansSection),
                      const SizedBox(height: 14),
                      ...completedChallenges.map(
                        (c) => _buildCompletedTile(c),
                      ),
                    ],
                  ],
                ),
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
                border: Border.all(color: AppColors.sandDark),
              ),
              child: Center(
                child: Icon(AppIcons.arrowBack, size: 20, color: AppColors.nearBlack),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text('Weekly Challenge', style: AppTypography.serifHeading),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  //  CURRENT CHALLENGE CARD
  // ═══════════════════════════════════════════════════════

  Widget _buildCurrentChallenge(Challenge challenge) {
    final progress = challenge.targetCount > 0
        ? (challenge.currentCount / challenge.targetCount).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.warmWhite,
        borderRadius: BorderRadius.circular(Spacing.radiusCard),
        border: Border.all(color: AppColors.sandDark),
        boxShadow: Spacing.subtleShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: challenge icon + days left badge
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.coralPale,
                ),
                child: Center(
                  child: Icon(AppIcons.challenge, size: 20, color: AppColors.coral),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.amberPale,
                  borderRadius: BorderRadius.circular(Spacing.radiusBadge),
                  border: Border.all(color: AppColors.amber.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(AppIcons.fire, size: 14, color: AppColors.amber),
                    const SizedBox(width: 4),
                    Text(
                      '${challenge.daysLeft} days left',
                      style: AppTypography.monoBadge.copyWith(color: AppColors.amber),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Title
          Text(challenge.title, style: AppTypography.serifSubheading),
          const SizedBox(height: 8),

          // Description
          Text(
            challenge.description,
            style: AppTypography.sansBody.copyWith(
              color: AppColors.espresso,
              height: 1.55,
            ),
          ),

          const SizedBox(height: 20),

          // Progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress',
                    style: AppTypography.sansCaption,
                  ),
                  Text(
                    '${challenge.currentCount} / ${challenge.targetCount}',
                    style: AppTypography.monoBadge.copyWith(color: AppColors.coral),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                height: 10,
                decoration: BoxDecoration(
                  color: AppColors.coralPale,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.coral,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  //  NO ACTIVE CHALLENGE STATE
  // ═══════════════════════════════════════════════════════

  Widget _buildNoChallengeState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.warmWhite,
        borderRadius: BorderRadius.circular(Spacing.radiusCard),
        border: Border.all(color: AppColors.sandDark),
      ),
      child: Column(
        children: [
          Icon(AppIcons.trophy, size: 40, color: AppColors.amber),
          const SizedBox(height: 12),
          Text(
            'No active challenge',
            style: AppTypography.sansSection.copyWith(color: AppColors.driftwood),
          ),
          const SizedBox(height: 6),
          Text(
            'New challenges appear every week. Check back soon!',
            style: AppTypography.sansBodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  //  COMPLETED CHALLENGE TILE
  // ═══════════════════════════════════════════════════════

  Widget _buildCompletedTile(Challenge challenge) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.sagePale.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(Spacing.radiusTile),
          border: Border.all(color: AppColors.sage.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            // Check icon
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.sage,
              ),
              child: Center(
                child: Icon(AppIcons.check, size: 18, color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),

            // Title + label
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    challenge.title,
                    style: AppTypography.sansLabel.copyWith(
                      color: AppColors.espresso,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Completed',
                    style: AppTypography.sansCaption.copyWith(
                      color: AppColors.sage,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Trophy
            Icon(AppIcons.trophy, size: 18, color: AppColors.amber),
          ],
        ),
      ),
    );
  }
}
