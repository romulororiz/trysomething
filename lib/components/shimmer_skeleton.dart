import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/spacing.dart';

/// Shimmer loading skeleton — spec says "no spinners > 200ms, use skeleton shimmer instead".
///
/// A lightweight shimmer effect that sweeps a highlight gradient
/// across placeholder shapes.
class ShimmerSkeleton extends StatefulWidget {
  final Widget child;

  const ShimmerSkeleton({super.key, required this.child});

  @override
  State<ShimmerSkeleton> createState() => _ShimmerSkeletonState();
}

class _ShimmerSkeletonState extends State<ShimmerSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Sine-based offset for smoother wave motion
        final wave = (math.sin(_controller.value * math.pi * 2 - math.pi / 2) + 1) / 2;
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                AppColors.warmWhite,
                AppColors.sand,
                AppColors.warmWhite,
              ],
              stops: [
                (wave - 0.3).clamp(0.0, 1.0),
                wave,
                (wave + 0.3).clamp(0.0, 1.0),
              ],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// A single shimmer bone — rectangular placeholder shape.
class ShimmerBone extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerBone({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.warmWhite,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  PRE-BUILT SKELETON LAYOUTS
// ═══════════════════════════════════════════════════════

/// Feed card skeleton — matches HobbyCard proportions.
class FeedCardSkeleton extends StatelessWidget {
  const FeedCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerSkeleton(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Spacing.radiusCard),
          child: Container(
            height: double.infinity,
            color: AppColors.sand,
            child: Stack(
              children: [
                // Title bone — bottom left
                Positioned(
                  left: 20,
                  bottom: 80,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      ShimmerBone(width: 180, height: 22, borderRadius: 6),
                      SizedBox(height: 8),
                      ShimmerBone(width: 240, height: 14, borderRadius: 4),
                    ],
                  ),
                ),
                // Spec badges — bottom
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 30,
                  child: Row(
                    children: const [
                      ShimmerBone(width: 60, height: 26, borderRadius: 13),
                      SizedBox(width: 8),
                      ShimmerBone(width: 70, height: 26, borderRadius: 13),
                      SizedBox(width: 8),
                      ShimmerBone(width: 55, height: 26, borderRadius: 13),
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

/// Explore grid tile skeleton — matches CategoryTile.
class ExploreTileSkeleton extends StatelessWidget {
  const ExploreTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerSkeleton(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Spacing.radiusTile),
        child: Container(
          color: AppColors.sand,
          child: Stack(
            children: [
              Positioned(
                left: 12,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    ShimmerBone(width: 80, height: 15, borderRadius: 4),
                    SizedBox(height: 4),
                    ShimmerBone(width: 50, height: 11, borderRadius: 3),
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

/// Detail screen content skeleton — for below the hero image.
class DetailContentSkeleton extends StatelessWidget {
  const DetailContentSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerSkeleton(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            ShimmerBone(height: 18, borderRadius: 6),
            SizedBox(height: 12),
            ShimmerBone(height: 14, borderRadius: 4),
            SizedBox(height: 8),
            ShimmerBone(width: 200, height: 14, borderRadius: 4),
            SizedBox(height: 24),
            ShimmerBone(height: 50, borderRadius: 12),
            SizedBox(height: 16),
            ShimmerBone(height: 50, borderRadius: 12),
            SizedBox(height: 16),
            ShimmerBone(height: 50, borderRadius: 12),
          ],
        ),
      ),
    );
  }
}

/// FAQ list skeleton — matches BeginnerFaqScreen card proportions.
class FaqListSkeleton extends StatelessWidget {
  const FaqListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerSkeleton(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
        child: Column(
          children: List.generate(4, (i) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.warmWhite,
                borderRadius: BorderRadius.circular(Spacing.radiusTile),
              ),
              child: const Row(
                children: [
                  ShimmerBone(width: 28, height: 28, borderRadius: 14),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerBone(height: 14, borderRadius: 4),
                        SizedBox(height: 6),
                        ShimmerBone(width: 160, height: 12, borderRadius: 4),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )),
        ),
      ),
    );
  }
}

/// Cost calculator skeleton — matches cost columns + bar chart layout.
class CostCalculatorSkeleton extends StatelessWidget {
  const CostCalculatorSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerSkeleton(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(
          children: [
            // Cost columns card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.warmWhite,
                borderRadius: BorderRadius.circular(Spacing.radiusCard),
              ),
              child: const Row(
                children: [
                  Expanded(child: Column(children: [
                    ShimmerBone(width: 60, height: 10, borderRadius: 3),
                    SizedBox(height: 8),
                    ShimmerBone(width: 80, height: 22, borderRadius: 6),
                  ])),
                  Expanded(child: Column(children: [
                    ShimmerBone(width: 60, height: 10, borderRadius: 3),
                    SizedBox(height: 8),
                    ShimmerBone(width: 80, height: 22, borderRadius: 6),
                  ])),
                  Expanded(child: Column(children: [
                    ShimmerBone(width: 60, height: 10, borderRadius: 3),
                    SizedBox(height: 8),
                    ShimmerBone(width: 80, height: 22, borderRadius: 6),
                  ])),
                ],
              ),
            ),
            const SizedBox(height: 28),
            // Bar chart card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.warmWhite,
                borderRadius: BorderRadius.circular(Spacing.radiusCard),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBone(width: 120, height: 16, borderRadius: 4),
                  SizedBox(height: 20),
                  ShimmerBone(height: 20, borderRadius: 10),
                  SizedBox(height: 12),
                  ShimmerBone(height: 20, borderRadius: 10),
                  SizedBox(height: 12),
                  ShimmerBone(height: 20, borderRadius: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Combo cards skeleton — matches HobbyCombosScreen card layout.
class ComboListSkeleton extends StatelessWidget {
  const ComboListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerSkeleton(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(
          children: List.generate(3, (i) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.warmWhite,
                borderRadius: BorderRadius.circular(Spacing.radiusCard),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(child: ShimmerBone(height: 80, borderRadius: 12)),
                    SizedBox(width: 12),
                    ShimmerBone(width: 36, height: 36, borderRadius: 18),
                    SizedBox(width: 12),
                    Expanded(child: ShimmerBone(height: 80, borderRadius: 12)),
                  ]),
                  SizedBox(height: 14),
                  ShimmerBone(height: 14, borderRadius: 4),
                  SizedBox(height: 6),
                  ShimmerBone(width: 200, height: 14, borderRadius: 4),
                  SizedBox(height: 12),
                  Row(children: [
                    ShimmerBone(width: 60, height: 24, borderRadius: 12),
                    SizedBox(width: 8),
                    ShimmerBone(width: 70, height: 24, borderRadius: 12),
                  ]),
                ],
              ),
            ),
          )),
        ),
      ),
    );
  }
}

/// Budget alternatives skeleton — matches 3-column tier cards.
class BudgetListSkeleton extends StatelessWidget {
  const BudgetListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerSkeleton(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
        child: Column(
          children: List.generate(3, (i) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.warmWhite,
                borderRadius: BorderRadius.circular(Spacing.radiusCard),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  Container(
                    height: 36,
                    color: AppColors.sand,
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(8, 12, 8, 12),
                    child: Row(children: [
                      Expanded(child: ShimmerBone(height: 90, borderRadius: 12)),
                      SizedBox(width: 8),
                      Expanded(child: ShimmerBone(height: 90, borderRadius: 12)),
                      SizedBox(width: 8),
                      Expanded(child: ShimmerBone(height: 90, borderRadius: 12)),
                    ]),
                  ),
                ],
              ),
            ),
          )),
        ),
      ),
    );
  }
}

/// Seasonal picks skeleton — matches expandable season sections.
class SeasonalSkeleton extends StatelessWidget {
  const SeasonalSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerSkeleton(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
        child: Column(
          children: List.generate(4, (i) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.warmWhite,
                borderRadius: BorderRadius.circular(Spacing.radiusCard),
              ),
              child: const Row(
                children: [
                  ShimmerBone(width: 40, height: 40, borderRadius: 20),
                  SizedBox(width: 12),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBone(width: 140, height: 16, borderRadius: 4),
                      SizedBox(height: 6),
                      ShimmerBone(width: 80, height: 12, borderRadius: 4),
                    ],
                  )),
                  ShimmerBone(width: 24, height: 24, borderRadius: 4),
                ],
              ),
            ),
          )),
        ),
      ),
    );
  }
}

/// Reusable error state with tap-to-retry.
class ErrorRetryWidget extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const ErrorRetryWidget({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 44, color: AppColors.warmGray),
            const SizedBox(height: 14),
            Text(
              'Something went wrong',
              style: AppTypography.sansSection.copyWith(color: AppColors.driftwood),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap to retry',
              style: AppTypography.sansCaption,
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.sand,
                  borderRadius: BorderRadius.circular(Spacing.radiusButton),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.refresh_rounded, size: 18, color: AppColors.coral),
                    const SizedBox(width: 8),
                    Text('Retry', style: AppTypography.sansLabel.copyWith(color: AppColors.coral)),
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

/// Detail screen hero + content skeleton — full page loading state.
class DetailHeroSkeleton extends StatelessWidget {
  const DetailHeroSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerSkeleton(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero image placeholder
          const ShimmerBone(height: Spacing.heroHeight, borderRadius: 0),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ShimmerBone(width: 220, height: 24, borderRadius: 6),
                SizedBox(height: 12),
                ShimmerBone(height: 14, borderRadius: 4),
                SizedBox(height: 8),
                ShimmerBone(width: 180, height: 14, borderRadius: 4),
                SizedBox(height: 24),
                // Spec badges row
                Row(
                  children: [
                    ShimmerBone(width: 70, height: 30, borderRadius: 15),
                    SizedBox(width: 8),
                    ShimmerBone(width: 80, height: 30, borderRadius: 15),
                    SizedBox(width: 8),
                    ShimmerBone(width: 65, height: 30, borderRadius: 15),
                  ],
                ),
                SizedBox(height: 28),
                ShimmerBone(height: 56, borderRadius: 12),
                SizedBox(height: 16),
                ShimmerBone(height: 56, borderRadius: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
