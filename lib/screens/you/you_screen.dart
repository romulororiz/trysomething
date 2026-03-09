import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../components/glass_card.dart';
import '../../models/hobby.dart';
import '../../providers/hobby_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/feature_providers.dart';
import '../../providers/auth_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/spacing.dart';

/// You tab — calm, personal space.
/// Active hobby, saved for later, tried before, journal, subscription, settings.
class YouScreen extends ConsumerWidget {
  const YouScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userHobbies = ref.watch(userHobbiesProvider);
    final allHobbiesAsync = ref.watch(hobbyListProvider);
    final authUser = ref.watch(authProvider).user;
    final profile = ref.watch(profileProvider);
    final proStatus = ref.watch(proStatusProvider);

    final displayName = authUser?.displayName ?? profile.username;
    final avatarUrl = authUser?.avatarUrl ?? profile.avatarUrl;

    final allHobbies = allHobbiesAsync.valueOrNull ?? [];

    // Categorize user hobbies
    final activeEntries = <_HobbyWithMeta>[];
    final savedEntries = <_HobbyWithMeta>[];
    final triedEntries = <_HobbyWithMeta>[];

    for (final entry in userHobbies.entries) {
      final uh = entry.value;
      final hobby = allHobbies.where((h) => h.id == uh.hobbyId).firstOrNull;
      if (hobby == null) continue;

      final meta = _HobbyWithMeta(hobby: hobby, userHobby: uh);
      switch (uh.status) {
        case HobbyStatus.trying:
        case HobbyStatus.active:
          activeEntries.add(meta);
        case HobbyStatus.saved:
          savedEntries.add(meta);
        case HobbyStatus.done:
          triedEntries.add(meta);
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
              24, 16, 24, Spacing.scrollBottomPadding),
          children: [
            // ── Header: avatar + name ──
            Row(
              children: [
                _Avatar(url: avatarUrl),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    displayName,
                    style: AppTypography.display,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // ── ACTIVE section ──
            _SectionLabel('ACTIVE'),
            const SizedBox(height: 12),
            if (activeEntries.isNotEmpty)
              ...activeEntries.map((m) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ActiveHobbyCard(meta: m),
                  ))
            else
              _EmptyActivePrompt(),
            const SizedBox(height: 20),

            // ── SAVED FOR LATER section ──
            if (savedEntries.isNotEmpty) ...[
              _SectionLabel('SAVED FOR LATER'),
              const SizedBox(height: 12),
              ...savedEntries.map((m) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _SavedHobbyCard(meta: m),
                  )),
              const SizedBox(height: 20),
            ],

            // ── TRIED BEFORE section (only if non-empty) ──
            if (triedEntries.isNotEmpty) ...[
              _SectionLabel('TRIED BEFORE'),
              const SizedBox(height: 12),
              ...triedEntries.map((m) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _TriedHobbyCard(meta: m),
                  )),
              const SizedBox(height: 20),
            ],

            // ── Journal link ──
            GlassCard(
              onTap: () => context.push('/journal'),
              child: Row(
                children: [
                  Icon(MdiIcons.bookOpenPageVariantOutline,
                      size: 20, color: AppColors.textSecondary),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text('Journal',
                        style:
                            AppTypography.title.copyWith(fontSize: 16)),
                  ),
                  Icon(MdiIcons.chevronRight,
                      size: 20, color: AppColors.textMuted),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Subscription row ──
            GlassCard(
              onTap: () => context.push('/pro'),
              child: Row(
                children: [
                  Icon(MdiIcons.starFourPointsOutline,
                      size: 20, color: AppColors.accent),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('TrySomething Pro',
                            style: AppTypography.title
                                .copyWith(fontSize: 16)),
                        const SizedBox(height: 2),
                        Text(
                          _subscriptionLabel(proStatus),
                          style: AppTypography.caption
                              .copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  Icon(MdiIcons.chevronRight,
                      size: 20, color: AppColors.textMuted),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Settings row ──
            GlassCard(
              onTap: () => context.push('/settings'),
              child: Row(
                children: [
                  Icon(MdiIcons.cogOutline,
                      size: 20, color: AppColors.textSecondary),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text('Settings',
                        style: AppTypography.body
                            .copyWith(color: AppColors.textSecondary)),
                  ),
                  Icon(MdiIcons.chevronRight,
                      size: 20, color: AppColors.textMuted),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _subscriptionLabel(ProStatus status) {
    if (status.isPro && status.isTrialing) {
      return 'Trial (${status.trialDaysRemaining} days left)';
    }
    if (status.isPro) return 'Pro';
    return 'Free Plan';
  }
}

// ═══════════════════════════════════════════════════════
//  DATA HELPER
// ═══════════════════════════════════════════════════════

class _HobbyWithMeta {
  final Hobby hobby;
  final UserHobby userHobby;
  const _HobbyWithMeta({required this.hobby, required this.userHobby});
}

// ═══════════════════════════════════════════════════════
//  SECTION LABEL
// ═══════════════════════════════════════════════════════

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTypography.overline.copyWith(color: AppColors.textMuted),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  AVATAR
// ═══════════════════════════════════════════════════════

class _Avatar extends StatelessWidget {
  final String? url;
  const _Avatar({this.url});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: SizedBox(
        width: 44,
        height: 44,
        child: url != null && url!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: url!,
                fit: BoxFit.cover,
                memCacheWidth: 88,
                placeholder: (_, __) => _placeholder(),
                errorWidget: (_, __, ___) => _placeholder(),
              )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.surfaceElevated,
      child: Icon(MdiIcons.accountCircleOutline,
          size: 28, color: AppColors.textMuted),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  ACTIVE HOBBY CARD (prominent, glass with blur)
// ═══════════════════════════════════════════════════════

class _ActiveHobbyCard extends StatelessWidget {
  final _HobbyWithMeta meta;
  const _ActiveHobbyCard({required this.meta});

  @override
  Widget build(BuildContext context) {
    final hobby = meta.hobby;
    final uh = meta.userHobby;

    final validStepIds = hobby.roadmapSteps.map((s) => s.id).toSet();
    final completedValid = uh.completedStepIds.intersection(validStepIds);
    final totalSteps = hobby.roadmapSteps.length;
    final progress =
        totalSteps > 0 ? completedValid.length / totalSteps : 0.0;

    final startedAt = uh.startedAt ?? DateTime.now();
    final weekNum =
        (DateTime.now().difference(startedAt).inDays / 7).floor() + 1;

    // Find current step description
    String? currentStepLabel;
    for (int i = 0; i < hobby.roadmapSteps.length; i++) {
      final step = hobby.roadmapSteps[i];
      if (!completedValid.contains(step.id)) {
        final prevDone = i == 0 ||
            completedValid.contains(hobby.roadmapSteps[i - 1].id);
        if (prevDone) {
          currentStepLabel = step.title;
          break;
        }
      }
    }

    return GlassCard(
      blur: true,
      onTap: () => context.go('/home'),
      child: Row(
        children: [
          // Hobby image (small, rounded)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 56,
              height: 56,
              child: CachedNetworkImage(
                imageUrl: hobby.imageUrl,
                fit: BoxFit.cover,
                memCacheWidth: 112,
                placeholder: (_, __) =>
                    Container(color: AppColors.surfaceElevated),
                errorWidget: (_, __, ___) =>
                    Container(color: AppColors.surfaceElevated),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(hobby.title,
                    style: AppTypography.title.copyWith(fontSize: 17)),
                const SizedBox(height: 4),
                Text(
                  'Week $weekNum${currentStepLabel != null ? ' · $currentStepLabel' : ''}',
                  style: AppTypography.data
                      .copyWith(color: AppColors.textMuted, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    minHeight: 3,
                    backgroundColor: AppColors.textWhisper,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  EMPTY ACTIVE PROMPT
// ═══════════════════════════════════════════════════════

class _EmptyActivePrompt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        children: [
          Text(
            'Start your first hobby',
            style: AppTypography.title.copyWith(fontSize: 17),
          ),
          const SizedBox(height: 6),
          Text(
            'Find something that fits your life and try it for a week.',
            textAlign: TextAlign.center,
            style:
                AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => context.go('/discover'),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text('Discover hobbies',
                    style: AppTypography.button
                        .copyWith(color: AppColors.background)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  SAVED HOBBY CARD
// ═══════════════════════════════════════════════════════

class _SavedHobbyCard extends StatelessWidget {
  final _HobbyWithMeta meta;
  const _SavedHobbyCard({required this.meta});

  @override
  Widget build(BuildContext context) {
    final hobby = meta.hobby;
    return GlassCard(
      onTap: () => context.push('/hobby/${hobby.id}'),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(hobby.title,
              style: AppTypography.title.copyWith(fontSize: 16)),
          const SizedBox(height: 4),
          Text(
            '${hobby.costText} · ${hobby.timeText} · ${hobby.difficultyText}',
            style: AppTypography.data
                .copyWith(color: AppColors.textMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  TRIED HOBBY CARD (quieter, lower opacity)
// ═══════════════════════════════════════════════════════

class _TriedHobbyCard extends StatelessWidget {
  final _HobbyWithMeta meta;
  const _TriedHobbyCard({required this.meta});

  @override
  Widget build(BuildContext context) {
    final hobby = meta.hobby;
    final uh = meta.userHobby;

    // How long they tried it
    String triedLabel = '';
    if (uh.startedAt != null && uh.lastActivityAt != null) {
      final days = uh.lastActivityAt!.difference(uh.startedAt!).inDays;
      final weeks = (days / 7).ceil();
      if (weeks <= 1) {
        triedLabel = '1 week';
      } else {
        triedLabel = '$weeks weeks';
      }
      final month = _monthName(uh.lastActivityAt!.month);
      final year = uh.lastActivityAt!.year;
      triedLabel = '$triedLabel in $month $year';
    }

    return GlassCard(
      onTap: () => context.push('/hobby/${hobby.id}'),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      backgroundColor: AppColors.glassBackground.withAlpha(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(hobby.title,
              style: AppTypography.body
                  .copyWith(color: AppColors.textSecondary)),
          if (triedLabel.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(triedLabel,
                style: AppTypography.caption
                    .copyWith(color: AppColors.textMuted)),
          ],
        ],
      ),
    );
  }

  String _monthName(int month) {
    const names = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return names[month - 1];
  }
}
