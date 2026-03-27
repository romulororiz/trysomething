import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'glass_card.dart';
import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import '../theme/app_typography.dart';

/// Quick link buttons: Cost Breakdown, Beginner FAQ, and Budget Alternatives.
/// Shared between HobbyDetailScreen and HomeScreen.
///
/// When [isLocked] is true, buttons show lock badges and tapping calls
/// [onLockTap] instead of navigating to feature screens.
class HobbyQuickLinks extends StatelessWidget {
  final String hobbyId;
  final bool isLocked;
  final VoidCallback? onLockTap;

  const HobbyQuickLinks({
    super.key,
    required this.hobbyId,
    this.isLocked = false,
    this.onLockTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Row 1: Cost + FAQ
        Row(
          children: [
            Expanded(
              child: _QuickLinkButton(
                icon: AppIcons.badgeCost,
                iconColor: AppColors.coral,
                title: 'Cost Breakdown',
                subtitle: 'Year 1 projection',
                isLocked: isLocked,
                onTap: isLocked
                    ? () => onLockTap?.call()
                    : () => context.push('/cost/$hobbyId'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _QuickLinkButton(
                icon: Icons.help_outline_rounded,
                iconColor: AppColors.textMuted,
                title: 'Beginner FAQ',
                subtitle: 'Common questions',
                isLocked: isLocked,
                onTap: isLocked
                    ? () => onLockTap?.call()
                    : () => context.push('/faq/$hobbyId'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Internal button widget for quick links with optional lock badge.
class _QuickLinkButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool isLocked;
  final VoidCallback? onTap;

  const _QuickLinkButton({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.isLocked,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      borderRadius: 14,
      child: Row(
        children: [
          // Icon with optional lock badge
          SizedBox(
            width: 20,
            height: 20,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, size: 16, color: iconColor),
                if (isLocked)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surfaceElevated,
                      ),
                      child: const Icon(
                        Icons.lock_rounded,
                        size: 8,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTypography.caption.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    )),
                Text(subtitle,
                    style: AppTypography.sansTiny
                        .copyWith(color: AppColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
