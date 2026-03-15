import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_icons.dart';
import '../theme/spacing.dart';
import '../theme/motion.dart';

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
          // No border — dark mode uses bg color contrast
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
                      Flexible(
                        child: Text(
                          category,
                          style: AppTypography.sansTiny.copyWith(color: catColor),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
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

// ═══════════════════════════════════════════════════════
//  REDESIGN COMPONENTS (Batch 10)
// ═══════════════════════════════════════════════════════

/// 40x40 circle with pale-tint background and accent-colored icon.
/// Used in settings tiles, tip cards, stat items, step indicators.
class IconCircle extends StatelessWidget {
  final Color color;
  final IconData icon;
  final double size;

  const IconCircle({
    super.key,
    required this.color,
    required this.icon,
    this.size = Spacing.iconCircleSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(icon, color: color, size: size * 0.45),
      ),
    );
  }
}

/// Screen header: circle back button + centered title + optional trailing.
class ScreenHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;

  const ScreenHeader({
    super.key,
    required this.title,
    this.onBack,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          // Back button — 40x40 circle
          GestureDetector(
            onTap: onBack ?? () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.sand,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.arrow_back_ios_new,
                    size: 16, color: AppColors.nearBlack),
              ),
            ),
          ),
          // Centered title
          Expanded(
            child: Text(
              title,
              style: AppTypography.sansSection,
              textAlign: TextAlign.center,
            ),
          ),
          // Trailing or spacer
          if (trailing != null)
            trailing!
          else
            const SizedBox(width: 40),
        ],
      ),
    );
  }
}

/// Horizontal pill-shaped filter tab bar.
/// Selected: coral bg + white text. Unselected: sand bg + driftwood text.
class FilterTabBar extends StatelessWidget {
  final List<String> tabs;
  final int selected;
  final ValueChanged<int> onTap;

  const FilterTabBar({
    super.key,
    required this.tabs,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final isSelected = i == selected;
          return GestureDetector(
            onTap: () => onTap(i),
            child: AnimatedContainer(
              duration: Motion.fast,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.coral : AppColors.sand,
                borderRadius: BorderRadius.circular(Spacing.radiusBadge),
              ),
              child: Text(
                tabs[i],
                style: AppTypography.sansLabel.copyWith(
                  color: isSelected ? Colors.white : AppColors.driftwood,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Full-width coral gradient CTA button with glow shadow and arrow suffix.
class PrimaryCtaButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;

  const PrimaryCtaButton({
    super.key,
    required this.label,
    this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        height: Spacing.buttonCtaHeight,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.coral, AppColors.coralDeep],
          ),
          borderRadius: BorderRadius.circular(Spacing.radiusCta),
          boxShadow: [
            BoxShadow(
              color: AppColors.coral.withValues(alpha: 0.40),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Text(
                  label,
                  style: AppTypography.sansCta.copyWith(color: Colors.white),
                ),
        ),
      ),
    );
  }
}
