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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Blurred real content (ImageFiltered, not BackdropFilter — avoids scroll jank)
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: IgnorePointer(child: child),
            ),

            // Semi-transparent overlay with lock UI
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.background.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock_outline_rounded,
                      size: 24,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      sectionTitle,
                      style: AppTypography.sansLabel.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        teaserText,
                        style: AppTypography.sansTiny.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Unlock with Pro',
                        style: AppTypography.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
