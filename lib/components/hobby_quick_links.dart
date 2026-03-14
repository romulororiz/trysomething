import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'glass_card.dart';
import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import '../theme/app_typography.dart';

/// Quick link row with Cost Breakdown and Beginner FAQ cards.
/// Shared between HobbyDetailScreen and HomeScreen.
class HobbyQuickLinks extends StatelessWidget {
  final String hobbyId;
  const HobbyQuickLinks({super.key, required this.hobbyId});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GlassCard(
            onTap: () => context.push('/cost/$hobbyId'),
            padding: const EdgeInsets.all(14),
            borderRadius: 14,
            child: Row(
              children: [
                Icon(AppIcons.badgeCost,
                    size: 16, color: AppColors.coral),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Cost Breakdown',
                          style: AppTypography.caption.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          )),
                      Text('Year 1 projection',
                          style: AppTypography.sansTiny
                              .copyWith(color: AppColors.textMuted)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GlassCard(
            onTap: () => context.push('/faq/$hobbyId'),
            padding: const EdgeInsets.all(14),
            borderRadius: 14,
            child: Row(
              children: [
                const Icon(Icons.help_outline_rounded,
                    size: 16, color: AppColors.textMuted),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Beginner FAQ',
                          style: AppTypography.caption.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          )),
                      Text('Common questions',
                          style: AppTypography.sansTiny
                              .copyWith(color: AppColors.textMuted)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
