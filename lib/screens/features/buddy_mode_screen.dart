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
    final buddyState = ref.watch(buddyProvider);
    final buddies = buddyState.profiles;
    final activities = buddyState.activities;
    final received = buddyState.pendingRequests
        .where((r) => r.direction == 'received')
        .toList();

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Header ──────────────────────────────────
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
                  Text('Buddy Mode', style: AppTypography.serifHeading),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // ── Scrollable content ──────────────────────
            Expanded(
              child: buddies.isEmpty && received.isEmpty
                  ? _EmptyState()
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
                      children: [
                        // ── Section: Pending Requests ───────
                        if (received.isNotEmpty) ...[
                          Text('BUDDY REQUESTS', style: AppTypography.overline),
                          const SizedBox(height: 16),
                          ...received.map((r) => _RequestCard(request: r)),
                          const SizedBox(height: 32),
                        ],

                        // ── Section: Current Buddies ────────
                        if (buddies.isNotEmpty) ...[
                          Text('YOUR BUDDIES', style: AppTypography.overline),
                          const SizedBox(height: 16),
                          ...buddies.map((buddy) => _BuddyCard(buddy: buddy)),
                          const SizedBox(height: 32),
                        ],

                        // ── Section: Activity Feed ──────────
                        if (activities.isNotEmpty) ...[
                          Text('ACTIVITY FEED', style: AppTypography.overline),
                          const SizedBox(height: 16),
                          ...activities
                              .map((a) => _ActivityTile(activity: a)),
                        ],
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
              onPressed: () => context.push('/local'),
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
//  EMPTY STATE
// ═══════════════════════════════════════════════════════

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(AppIcons.buddy, size: 48, color: AppColors.warmGray),
          const SizedBox(height: 16),
          Text(
            'No buddies yet',
            style: AppTypography.sansSection
                .copyWith(color: AppColors.warmGray),
          ),
          const SizedBox(height: 8),
          Text(
            'Find your first hobby buddy!',
            style: AppTypography.sansBodySmall
                .copyWith(color: AppColors.stone),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  REQUEST CARD (Accept / Reject)
// ═══════════════════════════════════════════════════════

class _RequestCard extends ConsumerWidget {
  final BuddyRequest request;
  const _RequestCard({required this.request});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.indigoPale,
        borderRadius: Spacing.cardBorderRadius,
        border: Border.all(color: AppColors.indigo.withAlpha(30)),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.indigo, AppColors.coral],
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              request.avatarInitial,
              style: AppTypography.sansSection
                  .copyWith(color: Colors.white, fontSize: 18),
            ),
          ),
          const SizedBox(width: 12),

          // Name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(request.name, style: AppTypography.sansSection),
                const SizedBox(height: 2),
                Text(
                  'Wants to be your buddy',
                  style: AppTypography.sansCaption
                      .copyWith(color: AppColors.warmGray),
                ),
              ],
            ),
          ),

          // Accept button
          GestureDetector(
            onTap: () =>
                ref.read(buddyProvider.notifier).acceptRequest(request.id),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.sage,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                'Accept',
                style: AppTypography.sansCaption
                    .copyWith(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Reject button
          GestureDetector(
            onTap: () =>
                ref.read(buddyProvider.notifier).rejectRequest(request.id),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.sand,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                'Decline',
                style: AppTypography.sansCaption
                    .copyWith(color: AppColors.warmGray),
              ),
            ),
          ),
        ],
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
    final initial = activity.userName.isNotEmpty
        ? activity.userName[0].toUpperCase()
        : '?';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mini avatar
          Container(
            width: 36,
            height: 36,
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
