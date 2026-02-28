import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/hobby.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_icons.dart';
import '../theme/spacing.dart';
import '../theme/motion.dart';
import 'spec_badge.dart';

/// Full-bleed discovery feed card with parallax-ready image,
/// gradient overlay, category chip, action buttons, and spec shelf.
class HobbyCard extends StatefulWidget {
  final Hobby hobby;
  final VoidCallback? onTap;
  final VoidCallback? onSave;
  final bool isSaved;
  final double parallaxOffset;

  const HobbyCard({
    super.key,
    required this.hobby,
    this.onTap,
    this.onSave,
    this.isSaved = false,
    this.parallaxOffset = 0,
  });

  @override
  State<HobbyCard> createState() => _HobbyCardState();
}

class _HobbyCardState extends State<HobbyCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final h = widget.hobby;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? Motion.cardPressScale : 1.0,
        duration: Motion.cardPress,
        curve: Motion.fastCurve,
        child: Container(
          height: Spacing.cardHeight,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: Spacing.cardBorderRadius,
            boxShadow: Spacing.cardShadow,
          ),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Parallax image
              _buildImage(h),

              // Gradient overlay
              const DecoratedBox(
                decoration: BoxDecoration(gradient: Spacing.cardOverlayGradient),
              ),

              // Category chip (top-left)
              Positioned(
                top: 14,
                left: 14,
                child: _buildCategoryChip(h),
              ),

              // Action buttons (top-right)
              Positioned(
                top: 14,
                right: 14,
                child: _buildActions(),
              ),

              // Bottom content
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildBottomContent(h),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(Hobby h) {
    return Hero(
      tag: 'hobby_image_${h.id}',
      child: Transform.translate(
        offset: Offset(0, widget.parallaxOffset * Motion.parallaxFactor),
        child: CachedNetworkImage(
          imageUrl: h.imageUrl,
          fit: BoxFit.cover,
          height: Spacing.cardHeight + Motion.maxParallaxOffset,
          width: double.infinity,
          placeholder: (context, url) => Container(
            color: AppColors.sand,
            child: Center(
              child: Icon(h.catIcon, size: 48, color: AppColors.warmGray),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: AppColors.sand,
            child: Center(
              child: Icon(h.catIcon, size: 48, color: AppColors.warmGray),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(Hobby h) {
    final catColor = AppColors.categoryColor(h.category);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: catColor,
        borderRadius: BorderRadius.circular(Spacing.radiusBadge),
        boxShadow: [
          BoxShadow(
            color: catColor.withValues(alpha: 0.40),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(h.catIcon, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            h.category.toUpperCase(),
            style: AppTypography.categoryLabel.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Column(
      children: [
        _ActionButton(
          icon: widget.isSaved ? AppIcons.heartFilled : AppIcons.heartOutline,
          onTap: widget.onSave,
          isActive: widget.isSaved,
        ),
        const SizedBox(height: 8),
        _ActionButton(
          icon: AppIcons.share,
          onTap: () {}, // Share placeholder
          showBurst: false,
        ),
      ],
    );
  }

  Widget _buildBottomContent(Hobby h) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tags
          Text(
            h.tags.join(' · '),
            style: AppTypography.sansCaption.copyWith(color: AppColors.amberLight),
          ),
          const SizedBox(height: 6),

          // Title
          Hero(
            tag: 'hobby_title_${h.id}',
            child: Material(
              color: Colors.transparent,
              child: Text(h.title, style: AppTypography.serifCardTitle),
            ),
          ),
          const SizedBox(height: 4),

          // Hook
          Text(
            h.hook,
            style: AppTypography.sansBodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),

          // Spec badges
          SpecBar(
            cost: h.costText,
            time: h.timeText,
            difficulty: h.difficultyText,
            small: true,
            onDark: true,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool isActive;
  final bool showBurst;

  const _ActionButton({
    required this.icon,
    this.onTap,
    this.isActive = false,
    this.showBurst = true,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with TickerProviderStateMixin {
  late AnimationController _popController;
  late Animation<double> _popScale;
  late AnimationController _burstController;
  late Animation<double> _burstRadius;
  late Animation<double> _burstOpacity;
  late AnimationController _particleController;
  late Animation<double> _particleProgress;

  // Particle directions (pre-computed)
  static const int _particleCount = 7;
  static final List<Offset> _particleDirs = List.generate(_particleCount, (i) {
    final angle = (i / _particleCount) * 2 * math.pi - 0.3;
    return Offset(math.cos(angle), math.sin(angle));
  });

  @override
  void initState() {
    super.initState();
    // Main pop bounce
    _popController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _popScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.75), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 0.75, end: 1.30), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.30, end: 0.95), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(parent: _popController, curve: Curves.easeOut));

    // Ring burst effect
    _burstController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _burstRadius = Tween<double>(begin: 0.0, end: 28.0).animate(
      CurvedAnimation(parent: _burstController, curve: Curves.easeOut),
    );
    _burstOpacity = Tween<double>(begin: 0.7, end: 0.0).animate(
      CurvedAnimation(parent: _burstController, curve: Curves.easeOut),
    );

    // Particle scatter
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _particleProgress = CurvedAnimation(
      parent: _particleController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _popController.dispose();
    _burstController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _popController.forward(from: 0);
    if (widget.showBurst && !widget.isActive) {
      // Only burst + particles when liking, not unliking
      _burstController.forward(from: 0);
      _particleController.forward(from: 0);
    }
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: SizedBox(
        width: 52,
        height: 52,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Button (rendered first = behind particles)
            ScaleTransition(
              scale: _popScale,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: widget.isActive
                      ? Colors.white.withValues(alpha: 0.85)
                      : Colors.black.withValues(alpha: 0.35),
                  shape: BoxShape.circle,
                  border: widget.isActive
                      ? null
                      : Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                        ),
                ),
                child: Icon(
                  widget.icon,
                  size: 18,
                  color: widget.isActive ? AppColors.redHeart : Colors.white,
                ),
              ),
            ),

            // Burst ring (on top of button)
            if (widget.isActive || _burstController.isAnimating)
              AnimatedBuilder(
                animation: _burstController,
                builder: (context, _) {
                  return Container(
                    width: _burstRadius.value * 2,
                    height: _burstRadius.value * 2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.redHeart.withValues(alpha: _burstOpacity.value),
                        width: 2.5,
                      ),
                    ),
                  );
                },
              ),

            // Particles (on top of everything)
            AnimatedBuilder(
              animation: _particleProgress,
              builder: (context, _) {
                if (!_particleController.isAnimating && !_particleController.isCompleted) {
                  return const SizedBox.shrink();
                }
                final t = _particleProgress.value;
                if (t == 0) return const SizedBox.shrink();
                final opacity = (1.0 - t).clamp(0.0, 1.0);
                if (opacity < 0.05) return const SizedBox.shrink();

                return SizedBox(
                  width: 52,
                  height: 52,
                  child: CustomPaint(
                    painter: _ParticlePainter(
                      progress: t,
                      opacity: opacity,
                      color: AppColors.redHeart,
                      directions: _particleDirs,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  PARTICLE PAINTER (heart burst particles)
// ═══════════════════════════════════════════════════════

class _ParticlePainter extends CustomPainter {
  final double progress;
  final double opacity;
  final Color color;
  final List<Offset> directions;

  _ParticlePainter({
    required this.progress,
    required this.opacity,
    required this.color,
    required this.directions,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const maxDist = 24.0;

    for (int i = 0; i < directions.length; i++) {
      final dir = directions[i];
      final dist = maxDist * progress;
      final pos = center + dir * dist;
      final radius = 3.0 * (1.0 - progress * 0.5);
      final paint = Paint()
        ..color = (i.isEven ? color : color.withValues(alpha: opacity * 0.7))
            .withValues(alpha: opacity);
      canvas.drawCircle(pos, radius, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) =>
      progress != old.progress || opacity != old.opacity;
}
