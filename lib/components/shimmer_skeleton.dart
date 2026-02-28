import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
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
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                AppColors.sand,
                AppColors.sandDark.withValues(alpha: 0.5),
                AppColors.sand,
              ],
              stops: [
                (_controller.value - 0.3).clamp(0.0, 1.0),
                _controller.value,
                (_controller.value + 0.3).clamp(0.0, 1.0),
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
        color: AppColors.sand,
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
