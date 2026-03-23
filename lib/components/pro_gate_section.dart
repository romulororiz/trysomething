import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Wraps any child with a blur + lock overlay when [isLocked] is true.
/// When unlocked, returns [child] directly with zero overhead.
class ProGateSection extends StatelessWidget {
  final Widget child;
  final bool isLocked;
  final String sectionTitle;
  final String teaserText;
  final VoidCallback? onLockTap;

  const ProGateSection({
    super.key,
    required this.child,
    required this.isLocked,
    required this.sectionTitle,
    required this.teaserText,
    this.onLockTap,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLocked) return child;

    return GestureDetector(
      onTap: onLockTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.glassBorder, width: 0.5),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            // Fixed height — gives the blur and Stack concrete dimensions
            height: 160,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Blurred real content clipped to the fixed height
                ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 6.5, sigmaY: 6.5),
                  child: IgnorePointer(
                    child: OverflowBox(
                      alignment: Alignment.topCenter,
                      maxHeight: 400,
                      child: child,
                    ),
                  ),
                ),

                // Dark overlay to dim the blur
                Container(
                  color: AppColors.background.withValues(alpha: 0.45),
                ),

                // Lock UI centered
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lock_outline_rounded,
                        size: 24,
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        sectionTitle,
                        style: AppTypography.sansLabel.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (teaserText.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          teaserText,
                          style: AppTypography.sansTiny.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 10),
                      Text(
                        'Unlock with Pro',
                        style: AppTypography.sansTiny.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
