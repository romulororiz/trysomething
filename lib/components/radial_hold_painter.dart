import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Circular arc that fills clockwise as the user holds the button.
///
/// Draws from 12 o'clock (−π/2) sweeping clockwise. A faint track
/// circle sits behind the active coral arc.
class RadialHoldPainter extends CustomPainter {
  final double holdProgress;

  RadialHoldPainter({required this.holdProgress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 4;

    // Track circle
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppColors.textMuted.withValues(alpha: 0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    // Active arc
    if (holdProgress > 0) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      canvas.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * holdProgress.clamp(0.0, 1.0),
        false,
        Paint()
          ..color = AppColors.accent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(RadialHoldPainter old) =>
      old.holdProgress != holdProgress;
}

/// Interactive hold-to-complete button.
///
/// On long press: animates [RadialHoldPainter] from 0→1 over 2.5 s.
/// On early release: springs back to 0.
/// On reaching 1.0: fires haptic + calls [onComplete].
class HoldToCompleteButton extends StatefulWidget {
  final VoidCallback onComplete;
  final double size;

  const HoldToCompleteButton({
    super.key,
    required this.onComplete,
    this.size = 80,
  });

  @override
  State<HoldToCompleteButton> createState() => _HoldToCompleteButtonState();
}

class _HoldToCompleteButtonState extends State<HoldToCompleteButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _completed = false;
  bool _holding = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed && !_completed) {
          _completed = true;
          HapticFeedback.mediumImpact();
          widget.onComplete();
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPanDown() {
    if (_completed) return;
    _holding = true;
    _controller.forward();
  }

  void _onPanUp() {
    if (_completed || !_holding) return;
    _holding = false;
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (_) => _onPanDown(),
      onLongPressEnd: (_) => _onPanUp(),
      onLongPressCancel: _onPanUp,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final scale = 1.0 + _controller.value * 0.05;
          return Transform.scale(
            scale: _completed ? 1.0 : scale,
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Glass circle background
                  Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _completed
                          ? AppColors.accent.withValues(alpha: 0.2)
                          : AppColors.glassBackground,
                      border: Border.all(
                        color: AppColors.glassBorder,
                        width: 0.5,
                      ),
                    ),
                  ),
                  // Radial arc
                  CustomPaint(
                    size: Size(widget.size, widget.size),
                    painter:
                        RadialHoldPainter(holdProgress: _controller.value),
                  ),
                  // Label
                  Text(
                    _completed ? 'Done' : 'Hold to\ncomplete',
                    textAlign: TextAlign.center,
                    style: AppTypography.caption.copyWith(
                      color: _completed
                          ? AppColors.textPrimary
                          : AppColors.textMuted,
                      fontSize: 11,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
