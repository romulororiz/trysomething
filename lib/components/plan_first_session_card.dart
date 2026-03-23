import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/hobby_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'glass_card.dart';
import 'pro_gate_section.dart';

/// Shared coach entry card — used on both detail page (gated) and Home (ungated).
///
/// Renders a GlassCard with coral circle icon, title, subtitle, and chevron.
/// When [isLocked], wraps itself in [ProGateSection] with blur overlay.
/// Optional overrides allow Home screen to pass 3-mode logic (rescue/start/momentum).
class PlanFirstSessionCard extends ConsumerWidget {
  final String hobbyId;
  final bool isLocked;
  final VoidCallback? onLockTap;
  final String? title;
  final String? subtitle;
  final String? coachMessage;
  final String? coachMode;
  final bool autoSend;

  const PlanFirstSessionCard({
    super.key,
    required this.hobbyId,
    required this.isLocked,
    this.onLockTap,
    this.title,
    this.subtitle,
    this.coachMessage,
    this.coachMode,
    this.autoSend = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hobby = ref.watch(hobbyByIdProvider(hobbyId)).valueOrNull;
    final hobbyTitle = hobby?.title ?? 'this hobby';

    final cardTitle = title ?? 'Plan your first session';
    final cardSubtitle =
        subtitle ?? 'Get a tiny first-session plan, no experience needed.';
    final message = coachMessage ??
        'Help me start $hobbyTitle tonight. What\'s the easiest first step?';
    final mode = coachMode ?? 'start';

    final card = GlassCard(
      onTap: isLocked
          ? null
          : () => context.push('/coach/$hobbyId', extra: {
                'message': message,
                'mode': mode,
                'autoSend': autoSend,
              }),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.coral.withValues(alpha: 0.12),
            ),
            child: const Icon(Icons.auto_awesome,
                size: 20, color: AppColors.coral),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cardTitle,
                    style: AppTypography.sansLabel.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    )),
                const SizedBox(height: 2),
                Text(cardSubtitle,
                    style: AppTypography.sansTiny.copyWith(
                      color: AppColors.textSecondary,
                    )),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              size: 20, color: AppColors.textMuted),
        ],
      ),
    );

    if (!isLocked) return card;

    return ProGateSection(
      isLocked: true,
      sectionTitle: 'Plan First Session',
      teaserText: 'Get a personalized first-session plan',
      onLockTap: onLockTap,
      child: card,
    );
  }
}
