import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/hobby.dart';
import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import '../theme/app_typography.dart';
import '../theme/spacing.dart';
import '../theme/motion.dart';

// ═══════════════════════════════════════════════════════
//  CATEGORY TILE (Explore grid item — full-bleed image)
// ═══════════════════════════════════════════════════════

class CategoryTile extends StatefulWidget {
  final HobbyCategory category;
  final VoidCallback? onTap;

  const CategoryTile({
    super.key,
    required this.category,
    this.onTap,
  });

  @override
  State<CategoryTile> createState() => _CategoryTileState();
}

class _CategoryTileState extends State<CategoryTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: Motion.categoryPressScale).animate(
      CurvedAnimation(parent: _scaleController, curve: Motion.normalCurve),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cat = widget.category;

    return GestureDetector(
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) {
        _scaleController.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _scaleController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Spacing.radiusTile),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Full-bleed background image
              CachedNetworkImage(
                imageUrl: cat.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: cat.color.withValues(alpha: 0.15),
                ),
                errorWidget: (context, url, error) => Container(
                  color: cat.color.withValues(alpha: 0.15),
                  child: Center(
                    child: Icon(cat.icon, size: 32, color: cat.color),
                  ),
                ),
              ),

              // Dark gradient overlay (bottom-heavy)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.05),
                      Colors.black.withValues(alpha: 0.15),
                      Colors.black.withValues(alpha: 0.55),
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
              ),

              // Text — bottom left
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      cat.name,
                      style: AppTypography.sansLabel.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 8,
                            color: Colors.black.withValues(alpha: 0.5),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${cat.count} hobbies',
                      style: AppTypography.sansTiny.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                        shadows: [
                          Shadow(
                            blurRadius: 6,
                            color: Colors.black.withValues(alpha: 0.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  CATEGORY CHIP BAR (horizontal filter bar)
// ═══════════════════════════════════════════════════════

class CategoryChipBar extends StatelessWidget {
  final List<HobbyCategory> categories;
  final String? selectedId;
  final ValueChanged<String?> onSelected;
  final bool showForYou;

  const CategoryChipBar({
    super.key,
    required this.categories,
    this.selectedId,
    required this.onSelected,
    this.showForYou = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          if (showForYou) ...[
            _Chip(
              label: 'For you',
              icon: AppIcons.sparkle,
              isSelected: selectedId == null,
              onTap: () => onSelected(null),
            ),
            const SizedBox(width: 6),
          ],
          ...categories.map((cat) => Padding(
                padding: const EdgeInsets.only(right: 6),
                child: _Chip(
                  label: cat.name,
                  icon: cat.icon,
                  color: cat.color,
                  isSelected: selectedId == cat.id,
                  onTap: () => onSelected(cat.id),
                ),
              )),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;
  final bool isSelected;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    this.icon,
    this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.coral;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Motion.fast,
        curve: Motion.fastCurve,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? chipColor.withValues(alpha: 0.15)
              : AppColors.sand,
          borderRadius: BorderRadius.circular(Spacing.radiusBadge),
          border: Border.all(
            color: isSelected
                ? chipColor.withValues(alpha: 0.4)
                : AppColors.sandDark,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon!, size: 13, color: isSelected ? chipColor : chipColor.withValues(alpha: 0.6)),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: AppTypography.sansCaption.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: isSelected ? chipColor : AppColors.driftwood,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
