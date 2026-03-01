import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/social.dart';
import '../../providers/feature_providers.dart';
import '../../providers/hobby_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_icons.dart';
import '../../theme/app_typography.dart';
import '../../theme/spacing.dart';

/// Buddy Mode — see your buddies, their progress, and activity feed.
class BuddyModeScreen extends ConsumerWidget {
  const BuddyModeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final buddies = ref.watch(buddyProfilesProvider);
    final activities = ref.watch(buddyActivitiesProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Header ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 24, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(AppIcons.arrowBack, color: AppColors.nearBlack),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 4),
                  Text('Buddy Mode', style: AppTypography.serifHeading),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // ── Scrollable content ──────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
                children: [
                  // ── Section: Current Buddies ───────────
                  Text(
                    'YOUR BUDDIES',
                    style: AppTypography.overline,
                  ),
                  const SizedBox(height: 16),
                  ...buddies.map((buddy) => _BuddyCard(buddy: buddy)),

                  const SizedBox(height: 32),

                  // ── Section: Activity Feed ────────────
                  Text(
                    'ACTIVITY FEED',
                    style: AppTypography.overline,
                  ),
                  const SizedBox(height: 16),
                  ...activities.map(
                    (activity) => _ActivityTile(activity: activity),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // ── Find a Buddy CTA ────────────────────────────
      bottomSheet: Container(
        color: AppColors.cream,
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: SizedBox(
          width: double.infinity,
          height: Spacing.buttonPrimaryHeight,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.coral, AppColors.indigo],
              ),
              borderRadius: Spacing.buttonBorderRadius,
              boxShadow: Spacing.subtleShadow,
            ),
            child: MaterialButton(
              shape: RoundedRectangleBorder(
                borderRadius: Spacing.buttonBorderRadius,
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Coming soon!')),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(AppIcons.buddy, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Text('Find a Buddy', style: AppTypography.sansCta),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  BUDDY CARD
// ═══════════════════════════════════════════════════════

class _BuddyCard extends ConsumerWidget {
  final BuddyProfile buddy;
  const _BuddyCard({required this.buddy});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hobby = ref.watch(hobbyByIdProvider(buddy.currentHobbyId)).valueOrNull;
    final hobbyName = hobby?.title ?? buddy.currentHobbyId;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warmWhite,
        borderRadius: Spacing.cardBorderRadius,
        boxShadow: Spacing.subtleShadow,
      ),
      child: Row(
        children: [
          // Avatar circle with gradient
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.coral, AppColors.indigo],
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              buddy.avatarInitial,
              style: AppTypography.sansSection.copyWith(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Name, hobby, progress
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(buddy.name, style: AppTypography.sansSection),
                const SizedBox(height: 2),
                Text(
                  hobbyName,
                  style: AppTypography.sansCaption,
                ),
                const SizedBox(height: 10),
                // Progress bar
                ClipRRect(
                  borderRadius: Spacing.badgeBorderRadius,
                  child: LinearProgressIndicator(
                    value: buddy.progress,
                    minHeight: 6,
                    backgroundColor: AppColors.sand,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppColors.coral),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Progress percentage
          Text(
            '${(buddy.progress * 100).round()}%',
            style: AppTypography.monoBadge.copyWith(color: AppColors.coral),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  ACTIVITY TILE
// ═══════════════════════════════════════════════════════

class _ActivityTile extends StatelessWidget {
  final BuddyActivity activity;
  const _ActivityTile({required this.activity});

  @override
  Widget build(BuildContext context) {
    final isYou = activity.userId == 'you';
    final initial = isYou ? 'Y' : activity.userId[0].toUpperCase();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mini avatar
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isYou
                    ? [AppColors.amber, AppColors.coral]
                    : [AppColors.coral, AppColors.indigo],
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              initial,
              style: AppTypography.sansLabel.copyWith(
                color: Colors.white,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Text + timestamp
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activity.text, style: AppTypography.sansBodySmall),
                const SizedBox(height: 4),
                Text(
                  _relativeTime(activity.timestamp),
                  style: AppTypography.sansTiny,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays}d ago';
  }
}
