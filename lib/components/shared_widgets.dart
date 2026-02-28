import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_icons.dart';
import '../theme/spacing.dart';

/// Reusable section header with title and optional right-side text/widget.
class SectionHeader extends StatelessWidget {
  final String title;
  final String? rightText;
  final Widget? rightWidget;
  final EdgeInsetsGeometry? padding;

  const SectionHeader({
    super.key,
    required this.title,
    this.rightText,
    this.rightWidget,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTypography.sansSection),
          if (rightText != null)
            Text(rightText!, style: AppTypography.monoCaption),
          if (rightWidget != null) rightWidget!,
        ],
      ),
    );
  }
}

/// Overline label (small caps style)
class OverlineLabel extends StatelessWidget {
  final String text;
  final EdgeInsetsGeometry? padding;

  const OverlineLabel({
    super.key,
    required this.text,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.only(bottom: 12),
      child: Text(
        text.toUpperCase(),
        style: AppTypography.overline,
      ),
    );
  }
}

/// Mini hobby card for related hobbies carousel and list items
class HobbyMiniCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String category;
  final IconData catIcon;
  final Color catColor;
  final String? cost;
  final String? time;
  final double? progress;
  final String? streakText;
  final VoidCallback? onTap;

  const HobbyMiniCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.category,
    required this.catIcon,
    required this.catColor,
    this.cost,
    this.time,
    this.progress,
    this.streakText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.warmWhite,
          borderRadius: BorderRadius.circular(Spacing.radiusButton),
          border: Border.all(color: AppColors.sandDark),
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(Spacing.radiusSmall),
              child: Image.network(
                imageUrl,
                width: Spacing.thumbnailSize,
                height: Spacing.thumbnailSize,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: Spacing.thumbnailSize,
                  height: Spacing.thumbnailSize,
                  color: AppColors.sand,
                  child: Center(child: Icon(catIcon, size: 20, color: AppColors.warmGray)),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.sansLabel),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(catIcon, size: 11, color: catColor),
                      const SizedBox(width: 4),
                      Text(
                        category,
                        style: AppTypography.sansTiny.copyWith(color: catColor),
                      ),
                      if (cost != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          cost!,
                          style: AppTypography.monoBadgeSmall.copyWith(color: AppColors.warmGray),
                        ),
                      ],
                    ],
                  ),
                  // Progress bar
                  if (progress != null) ...[
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: progress!,
                        minHeight: 4,
                        backgroundColor: AppColors.sandDark,
                        valueColor: const AlwaysStoppedAnimation(AppColors.coral),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Streak badge
            if (streakText != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.amberPale,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(AppIcons.fire, size: 11, color: AppColors.amberDeep),
                    const SizedBox(width: 3),
                    Text(
                      streakText!,
                      style: AppTypography.monoTiny.copyWith(
                        color: AppColors.amberDeep,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(width: 4),
            Icon(Icons.chevron_right, color: AppColors.stone, size: 20),
          ],
        ),
      ),
    );
  }
}
