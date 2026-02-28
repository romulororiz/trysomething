import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';

/// Frosted glass surface widget — Kinetic Glass signature element.
///
/// Uses BackdropFilter with blur for the glass effect,
/// dark surface overlay for Midnight Neon dark glass,
/// plus a subtle noise grain texture for realism.
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final double opacity;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? borderColor;
  final Color? backgroundColor;

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 16,
    this.blur = 8,
    this.opacity = 0.85,
    this.padding,
    this.margin,
    this.borderColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: CustomPaint(
            foregroundPainter: _NoisePainter(),
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                color: (backgroundColor ?? const Color(0xFF1E1E2E)).withValues(alpha: opacity),
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: borderColor ?? const Color(0xFF2A2A3C).withValues(alpha: 0.8),
                  width: 1,
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Paints a subtle random-dot noise texture for glass realism.
class _NoisePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(42); // fixed seed for deterministic grain
    final paint = Paint();
    final count = (size.width * size.height * 0.012).toInt(); // ~1.2% density

    for (int i = 0; i < count; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final grey = rng.nextInt(80); // 0–80 dark range
      paint.color = Color.fromRGBO(grey, grey, grey, 0.04);
      canvas.drawCircle(Offset(x, y), 0.5, paint);
    }
  }

  @override
  bool shouldRepaint(_NoisePainter oldDelegate) => false;
}
