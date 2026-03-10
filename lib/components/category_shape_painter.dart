import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Large ambient background shape unique to each hobby category.
///
/// Rendered at very low opacity (3–5%) behind session content. These are
/// abstract, atmospheric forms — NOT icons, NOT literal. Barely visible,
/// they add a subtle sense of place without being decorative.
class CategoryShapePainter extends CustomPainter {
  final String category;
  final double opacity;

  CategoryShapePainter({
    required this.category,
    this.opacity = 0.04,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textPrimary.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = math.min(cx, cy) * 0.7;

    switch (category.toLowerCase()) {
      case 'creative':
        _drawOrganicBlob(canvas, cx, cy, r, paint);
      case 'outdoors':
        _drawHorizonArc(canvas, cx, cy, r, paint);
      case 'fitness':
        _drawWave(canvas, cx, cy, r, paint);
      case 'music':
        _drawFlowingSine(canvas, cx, cy, r, paint);
      case 'food':
        _drawSpiral(canvas, cx, cy, r, paint);
      case 'maker':
        _drawCrystal(canvas, cx, cy, r, paint);
      case 'mind':
        _drawConcentricCircles(canvas, cx, cy, r, paint);
      case 'collecting':
        _drawOverlappingSquares(canvas, cx, cy, r, paint);
      case 'social':
        _drawIntersectingCircles(canvas, cx, cy, r, paint);
      default:
        _drawOrganicBlob(canvas, cx, cy, r, paint);
    }
  }

  /// Irregular flowing blob with organic curves.
  void _drawOrganicBlob(
      Canvas canvas, double cx, double cy, double r, Paint paint) {
    final path = Path()
      ..moveTo(cx - r * 0.3, cy - r * 0.8)
      ..cubicTo(cx + r * 0.4, cy - r * 1.0, cx + r * 0.9, cy - r * 0.4,
          cx + r * 0.7, cy + r * 0.1)
      ..cubicTo(cx + r * 0.9, cy + r * 0.6, cx + r * 0.3, cy + r * 0.9,
          cx - r * 0.1, cy + r * 0.7)
      ..cubicTo(cx - r * 0.6, cy + r * 0.8, cx - r * 0.9, cy + r * 0.3,
          cx - r * 0.8, cy - r * 0.2)
      ..cubicTo(cx - r * 0.7, cy - r * 0.6, cx - r * 0.5, cy - r * 0.7,
          cx - r * 0.3, cy - r * 0.8);
    canvas.drawPath(path, paint);
  }

  /// Gentle mountain/horizon silhouette.
  void _drawHorizonArc(
      Canvas canvas, double cx, double cy, double r, Paint paint) {
    final path = Path()
      ..moveTo(cx - r, cy + r * 0.3)
      ..cubicTo(cx - r * 0.5, cy - r * 0.4, cx - r * 0.2, cy - r * 0.7,
          cx, cy - r * 0.5)
      ..cubicTo(cx + r * 0.15, cy - r * 0.3, cx + r * 0.3, cy - r * 0.6,
          cx + r * 0.5, cy - r * 0.2)
      ..cubicTo(
          cx + r * 0.7, cy + r * 0.1, cx + r * 0.9, cy + r * 0.2, cx + r, cy + r * 0.3);
    canvas.drawPath(path, paint);
  }

  /// Dynamic smooth wave.
  void _drawWave(
      Canvas canvas, double cx, double cy, double r, Paint paint) {
    final path = Path()..moveTo(cx - r, cy);
    for (double x = -r; x <= r; x += 1) {
      final y = math.sin(x / r * math.pi * 2.5) * r * 0.35;
      path.lineTo(cx + x, cy + y);
    }
    canvas.drawPath(path, paint);
  }

  /// Flowing musical sine curve with varying amplitude.
  void _drawFlowingSine(
      Canvas canvas, double cx, double cy, double r, Paint paint) {
    final path = Path()..moveTo(cx - r, cy);
    for (double x = -r; x <= r; x += 1) {
      final t = (x + r) / (2 * r);
      final amp = r * 0.4 * math.sin(t * math.pi);
      final y = math.sin(x / r * math.pi * 3) * amp;
      path.lineTo(cx + x, cy + y);
    }
    canvas.drawPath(path, paint);
  }

  /// Archimedes spiral.
  void _drawSpiral(
      Canvas canvas, double cx, double cy, double r, Paint paint) {
    final path = Path();
    const turns = 3.0;
    const steps = 200;
    for (int i = 0; i <= steps; i++) {
      final t = i / steps;
      final angle = turns * 2 * math.pi * t;
      final radius = r * t * 0.8;
      final x = cx + math.cos(angle) * radius;
      final y = cy + math.sin(angle) * radius;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  /// Angular crystal / geometric faceted form.
  void _drawCrystal(
      Canvas canvas, double cx, double cy, double r, Paint paint) {
    final path = Path()
      ..moveTo(cx, cy - r * 0.9)
      ..lineTo(cx + r * 0.5, cy - r * 0.3)
      ..lineTo(cx + r * 0.8, cy + r * 0.1)
      ..lineTo(cx + r * 0.4, cy + r * 0.7)
      ..lineTo(cx - r * 0.2, cy + r * 0.8)
      ..lineTo(cx - r * 0.7, cy + r * 0.3)
      ..lineTo(cx - r * 0.5, cy - r * 0.4)
      ..close();
    // Inner facet lines
    canvas.drawPath(path, paint);
    canvas.drawLine(
        Offset(cx, cy - r * 0.9), Offset(cx + r * 0.4, cy + r * 0.7), paint);
    canvas.drawLine(
        Offset(cx, cy - r * 0.9), Offset(cx - r * 0.7, cy + r * 0.3), paint);
  }

  /// Concentric circles radiating outward.
  void _drawConcentricCircles(
      Canvas canvas, double cx, double cy, double r, Paint paint) {
    for (int i = 1; i <= 4; i++) {
      canvas.drawCircle(Offset(cx, cy), r * i / 4, paint);
    }
  }

  /// Overlapping rounded rectangles.
  void _drawOverlappingSquares(
      Canvas canvas, double cx, double cy, double r, Paint paint) {
    final s = r * 0.55;
    final radius = Radius.circular(s * 0.2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: Offset(cx - s * 0.25, cy - s * 0.25),
              width: s * 1.4,
              height: s * 1.4),
          radius),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: Offset(cx + s * 0.25, cy + s * 0.25),
              width: s * 1.4,
              height: s * 1.4),
          radius),
      paint,
    );
  }

  /// Two intersecting circles (Venn diagram).
  void _drawIntersectingCircles(
      Canvas canvas, double cx, double cy, double r, Paint paint) {
    final offset = r * 0.35;
    canvas.drawCircle(Offset(cx - offset, cy), r * 0.55, paint);
    canvas.drawCircle(Offset(cx + offset, cy), r * 0.55, paint);
  }

  @override
  bool shouldRepaint(CategoryShapePainter old) =>
      old.category != category || old.opacity != opacity;
}

/// Full-screen ambient category background shape.
///
/// Renders the category-specific abstract form at very low opacity.
/// Place as the bottom layer in a [Stack] behind session content.
class CategoryShape extends StatelessWidget {
  final String category;
  final double opacity;

  const CategoryShape({
    super.key,
    required this.category,
    this.opacity = 0.04,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: CategoryShapePainter(category: category, opacity: opacity),
      size: Size.infinite,
    );
  }
}
