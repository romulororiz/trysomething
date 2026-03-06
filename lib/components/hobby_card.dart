import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/hobby.dart';
import '../theme/category_ui.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_icons.dart';
import '../theme/spacing.dart';
import 'spec_badge.dart';

/// Full-screen TikTok-style discovery card.
/// Full-bleed image, right action column, bottom content shelf, CTA button.
class HobbyCard extends StatelessWidget {
  final Hobby hobby;
  final VoidCallback? onTap;
  final VoidCallback? onSave;
  final VoidCallback? onShare;
  final bool isSaved;

  const HobbyCard({
    super.key,
    required this.hobby,
    this.onTap,
    this.onSave,
    this.onShare,
    this.isSaved = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Full-bleed background image
          _buildImage(),

          // Gradient overlay (heavier at bottom for readability)
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x00000000),
                  Color(0x0D000000),
                  Color(0x80000000),
                  Color(0xD9000000),
                ],
                stops: [0.0, 0.35, 0.65, 1.0],
              ),
            ),
          ),

          // Right side: action column (above nav: 85px + CTA: 56px + content + gap)
          Positioned(
            right: 12,
            bottom: 300,
            child: _buildActionColumn(),
          ),

          // Bottom content shelf (above CTA + nav clearance)
          Positioned(
            left: 16,
            right: 72,
            bottom: 200,
            child: _buildContentShelf(),
          ),

          // Bottom CTA (must clear 85px nav bar)
          Positioned(
            left: 20,
            right: 20,
            bottom: 120,
            child: _buildCta(),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return Hero(
      tag: 'hobby_image_${hobby.id}',
      child: CachedNetworkImage(
        imageUrl: hobby.imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholder: (context, url) => Container(
          color: AppColors.sand,
          child: Center(
            child: Icon(hobby.catIcon, size: 48, color: AppColors.warmGray),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: AppColors.sand,
          child: Center(
            child: Icon(hobby.catIcon, size: 48, color: AppColors.warmGray),
          ),
        ),
      ),
    );
  }

  Widget _buildActionColumn() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _FeedActionButton(
          icon: isSaved ? AppIcons.heartFilled : AppIcons.heartOutline,
          label: '2.4k',
          onTap: onSave,
          isActive: isSaved,
          activeColor: AppColors.redHeart,
        ),
        const SizedBox(height: 20),
        _FeedActionButton(
          icon: AppIcons.share,
          label: 'Share',
          onTap: onShare ?? () {},
        ),
      ],
    );
  }

  Widget _buildContentShelf() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Hero(
          tag: 'hobby_title_${hobby.id}',
          child: Material(
            color: Colors.transparent,
            child: Text(
              hobby.title,
              style: AppTypography.serifCardTitle.copyWith(
                fontSize: 28,
                height: 1.15,
                shadows: [
                  Shadow(
                    blurRadius: 12,
                    color: Colors.black.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          hobby.hook,
          style: AppTypography.sansBodySmall.copyWith(
            color: Colors.white.withValues(alpha: 0.85),
            shadows: [
              Shadow(
                blurRadius: 8,
                color: Colors.black.withValues(alpha: 0.4),
              ),
            ],
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 12),
        SpecBar(
          cost: hobby.costText,
          time: hobby.timeText,
          difficulty: hobby.difficultyText,
          small: true,
          onDark: true,
        ),
      ],
    );
  }

  Widget _buildCta() {
    return Container(
      height: Spacing.buttonCtaHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Spacing.radiusCta),
        gradient: const LinearGradient(
          colors: [AppColors.coral, Color(0xFFFF5252)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.coral.withValues(alpha: 0.45),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(Spacing.radiusCta),
          onTap: onTap,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'TRY TODAY',
                  style: AppTypography.sansCta.copyWith(
                    fontSize: 16,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded,
                    size: 20, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// TikTok-style action button with icon + label
class _FeedActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isActive;
  final Color? activeColor;

  const _FeedActionButton({
    required this.icon,
    required this.label,
    this.onTap,
    this.isActive = false,
    this.activeColor,
  });

  @override
  State<_FeedActionButton> createState() => _FeedActionButtonState();
}

class _FeedActionButtonState extends State<_FeedActionButton>
    with TickerProviderStateMixin {
  late AnimationController _popController;
  late Animation<double> _popScale;
  late AnimationController _burstController;
  late Animation<double> _burstRadius;
  late Animation<double> _burstOpacity;
  late AnimationController _particleController;
  late Animation<double> _particleProgress;

  static const int _particleCount = 7;
  static final List<Offset> _particleDirs = List.generate(_particleCount, (i) {
    final angle = (i / _particleCount) * 2 * math.pi - 0.3;
    return Offset(math.cos(angle), math.sin(angle));
  });

  @override
  void initState() {
    super.initState();
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
    if (!widget.isActive && widget.activeColor != null) {
      _burstController.forward(from: 0);
      _particleController.forward(from: 0);
    }
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isActive
        ? (widget.activeColor ?? Colors.white)
        : Colors.white;

    return GestureDetector(
      onTap: _handleTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                ScaleTransition(
                  scale: _popScale,
                  child: Icon(widget.icon, size: 30, color: color,
                    shadows: [
                      Shadow(
                        blurRadius: 12,
                        color: Colors.black.withValues(alpha: 0.5),
                      ),
                    ],
                  ),
                ),
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
                            color: (widget.activeColor ?? AppColors.coral)
                                .withValues(alpha: _burstOpacity.value),
                            width: 2.5,
                          ),
                        ),
                      );
                    },
                  ),
                AnimatedBuilder(
                  animation: _particleProgress,
                  builder: (context, _) {
                    if (!_particleController.isAnimating &&
                        !_particleController.isCompleted) {
                      return const SizedBox.shrink();
                    }
                    final t = _particleProgress.value;
                    if (t == 0) return const SizedBox.shrink();
                    final opacity = (1.0 - t).clamp(0.0, 1.0);
                    if (opacity < 0.05) return const SizedBox.shrink();

                    return SizedBox(
                      width: 48,
                      height: 48,
                      child: CustomPaint(
                        painter: _ParticlePainter(
                          progress: t,
                          opacity: opacity,
                          color: widget.activeColor ?? AppColors.coral,
                          directions: _particleDirs,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            widget.label,
            style: AppTypography.sansTiny.copyWith(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              shadows: [
                Shadow(
                  blurRadius: 8,
                  color: Colors.black.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
