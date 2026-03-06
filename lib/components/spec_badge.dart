import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import '../theme/app_typography.dart';
import '../theme/spacing.dart';

/// Badge type for spec pills
enum SpecBadgeType { cost, time, difficulty }

// ═══════════════════════════════════════════════════════
//  SPEC BADGE (single pill)
// ═══════════════════════════════════════════════════════

class SpecBadge extends StatelessWidget {
  final SpecBadgeType type;
  final String text;
  final bool small;
  final bool onDark;

  const SpecBadge({
    super.key,
    required this.type,
    required this.text,
    this.small = false,
    this.onDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final config = _config;
    final textStyle = small ? AppTypography.monoBadgeSmall : AppTypography.monoBadge;

    if (onDark) {
      // Frosted glass style for dark backgrounds (on card images)
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: small ? 8 : 10,
          vertical: small ? 3 : 5,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(Spacing.radiusBadge),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(config.icon, size: small ? 10 : 12, color: Colors.white),
            SizedBox(width: small ? 3 : 4),
            Text(text, style: textStyle.copyWith(color: Colors.white)),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 10,
        vertical: small ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(Spacing.radiusBadge),
        // No border — dark mode cards use bg color contrast
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, size: small ? 10 : 12, color: config.textColor),
          SizedBox(width: small ? 3 : 4),
          Text(text, style: textStyle.copyWith(color: config.textColor)),
        ],
      ),
    );
  }

  _BadgeConfig get _config {
    // All badges use the same muted monochrome style — sand bg, driftwood text.
    // Only coral should pop on any screen; badges stay restrained.
    final IconData icon;
    switch (type) {
      case SpecBadgeType.cost:
        icon = AppIcons.badgeCost;
      case SpecBadgeType.time:
        icon = AppIcons.badgeTime;
      case SpecBadgeType.difficulty:
        icon = AppIcons.badgeDifficulty;
    }
    return _BadgeConfig(
      icon: icon,
      backgroundColor: AppColors.sand,
      textColor: AppColors.driftwood,
      borderColor: AppColors.sandDark,
    );
  }
}

class _BadgeConfig {
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;

  const _BadgeConfig({
    required this.icon,
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
  });
}

// ═══════════════════════════════════════════════════════
//  SPEC BAR (row of 3 badges)
// ═══════════════════════════════════════════════════════

class SpecBar extends StatelessWidget {
  final String cost;
  final String time;
  final String difficulty;
  final bool small;
  final bool onDark;
  final bool withContainer;

  const SpecBar({
    super.key,
    required this.cost,
    required this.time,
    required this.difficulty,
    this.small = false,
    this.onDark = false,
    this.withContainer = false,
  });

  @override
  Widget build(BuildContext context) {
    final badges = Wrap(
      spacing: 5,
      runSpacing: 5,
      children: [
        SpecBadge(type: SpecBadgeType.cost, text: cost, small: small, onDark: onDark),
        SpecBadge(type: SpecBadgeType.time, text: time, small: small, onDark: onDark),
        SpecBadge(type: SpecBadgeType.difficulty, text: difficulty, small: small, onDark: onDark),
      ],
    );

    if (!withContainer) return badges;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.warmWhite,
        borderRadius: BorderRadius.circular(Spacing.radiusButton),
        boxShadow: Spacing.specBarShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SpecBadge(type: SpecBadgeType.cost, text: cost, small: small),
          SpecBadge(type: SpecBadgeType.time, text: time, small: small),
          SpecBadge(type: SpecBadgeType.difficulty, text: difficulty, small: small),
        ],
      ),
    );
  }
}
