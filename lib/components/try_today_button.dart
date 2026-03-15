import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/motion.dart';

/// Primary CTA with breathing glow animation and press feedback.
/// The coral "try this" energy button.
class TryTodayButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String text;
  final IconData? icon;

  const TryTodayButton({
    super.key,
    this.onPressed,
    this.text = 'Start hobby',
    this.icon,
  });

  @override
  State<TryTodayButton> createState() => _TryTodayButtonState();
}

class _TryTodayButtonState extends State<TryTodayButton>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  late AnimationController _pressController;
  late Animation<double> _pressAnimation;

  @override
  void initState() {
    super.initState();

    // Breathing glow — 1800ms repeat reverse
    _glowController = AnimationController(
      duration: Motion.breathingGlow,
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Press scale
    _pressController = AnimationController(
      duration: Motion.buttonPress,
      vsync: this,
    );

    _pressAnimation = Tween<double>(begin: 1.0, end: Motion.buttonPressScale).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    _pressController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    _pressController.forward();
  }

  void _onTapUp(TapUpDetails _) {
    _pressController.reverse();
    widget.onPressed?.call();
  }

  void _onTapCancel() {
    _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = Motion.shouldReduceMotion(context);

    if (reduceMotion) {
      _glowController.stop();
    } else if (!_glowController.isAnimating) {
      _glowController.repeat(reverse: true);
    }

    return AnimatedBuilder(
      animation: Listenable.merge([_glowAnimation, _pressAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _pressAnimation.value,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                color: AppColors.coral,
                borderRadius: BorderRadius.circular(16),
                boxShadow: reduceMotion
                    ? [
                        BoxShadow(
                          color: AppColors.coral.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: AppColors.coral.withValues(alpha: _glowAnimation.value),
                          blurRadius: 16 + (_glowAnimation.value - 0.25) * 40,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: child,
            ),
          ),
        );
      },
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.icon ?? Icons.play_arrow_rounded, size: 16, color: Colors.white),
            const SizedBox(width: 8),
            Text(widget.text, style: AppTypography.sansCta),
          ],
        ),
      ),
    );
  }
}
