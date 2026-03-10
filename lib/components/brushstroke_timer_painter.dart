import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Organic calligraphic brushstroke that draws itself based on [progress].
///
/// Three-layer rendering for depth:
/// 1. **Glow** — thick, blurred, low opacity (ambient warmth)
/// 2. **Body** — medium stroke, half opacity
/// 3. **Core** — thin, sharp, full opacity (the "ink")
///
/// This is a placeholder for a future Rive asset. When the Rive file is
/// ready, swap [CustomPaint] in [BrushstrokeTimer] for `RiveAnimation.asset`.
class BrushstrokeTimerPainter extends CustomPainter {
  final double progress;
  final Color strokeColor;

  BrushstrokeTimerPainter({
    required this.progress,
    this.strokeColor = const Color(0xFFF5F0EB),
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final p = progress.clamp(0.0, 1.0);
    final path = _buildStrokePath(size);
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      final visible = metric.extractPath(0, metric.length * p);

      // Layer 1: glow
      canvas.drawPath(
        visible,
        Paint()
          ..color = strokeColor.withValues(alpha: 0.15 * p)
          ..strokeWidth = 14
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );

      // Layer 2: body
      canvas.drawPath(
        visible,
        Paint()
          ..color = strokeColor.withValues(alpha: 0.5)
          ..strokeWidth = 8
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );

      // Layer 3: core
      canvas.drawPath(
        visible,
        Paint()
          ..color = strokeColor
          ..strokeWidth = 3.5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  /// Flowing S-curve path scaled to the given [size].
  Path _buildStrokePath(Size size) {
    final sx = size.width / 300;
    final sy = size.height / 300;
    return Path()
      ..moveTo(35 * sx, 230 * sy)
      ..cubicTo(42 * sx, 210 * sy, 52 * sx, 188 * sy, 68 * sx, 168 * sy)
      ..cubicTo(84 * sx, 148 * sy, 105 * sx, 132 * sy, 128 * sx, 125 * sy)
      ..cubicTo(151 * sx, 118 * sy, 172 * sx, 122 * sy, 188 * sx, 135 * sy)
      ..cubicTo(204 * sx, 148 * sy, 212 * sx, 168 * sy, 210 * sx, 188 * sy)
      ..cubicTo(208 * sx, 208 * sy, 195 * sx, 222 * sy, 178 * sx, 228 * sy)
      ..cubicTo(161 * sx, 234 * sy, 148 * sx, 225 * sy, 142 * sx, 212 * sy)
      ..cubicTo(136 * sx, 199 * sy, 140 * sx, 185 * sy, 152 * sx, 176 * sy)
      ..cubicTo(164 * sx, 167 * sy, 180 * sx, 168 * sy, 192 * sx, 175 * sy)
      ..cubicTo(204 * sx, 182 * sy, 215 * sx, 195 * sy, 222 * sx, 210 * sy)
      ..cubicTo(229 * sx, 225 * sy, 238 * sx, 240 * sy, 252 * sx, 248 * sy);
  }

  @override
  bool shouldRepaint(BrushstrokeTimerPainter old) => old.progress != progress;
}

/// Widget wrapper for the brushstroke timer placeholder.
///
/// TODO: When Rive asset is ready, swap CustomPaint for:
/// ```dart
/// RiveAnimation.asset('assets/rive/brushstroke_timer.riv',
///   stateMachines: ['State Machine 1'],
///   onInit: (artboard) { /* bind progress input */ })
/// ```
class BrushstrokeTimer extends StatelessWidget {
  final double progress;
  final double size;
  final Color? strokeColor;

  const BrushstrokeTimer({
    super.key,
    required this.progress,
    this.size = 240,
    this.strokeColor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: BrushstrokeTimerPainter(
        progress: progress,
        strokeColor: strokeColor ?? AppColors.textPrimary,
      ),
    );
  }
}
