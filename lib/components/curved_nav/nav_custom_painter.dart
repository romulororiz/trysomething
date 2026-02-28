import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';

const _s = 0.2;

class NavCustomPainter extends CustomPainter {
  late double loc;
  late double bottom;
  Color color;
  bool hasLabel;
  TextDirection textDirection;

  NavCustomPainter({
    required double startingLoc,
    required int itemsLength,
    required this.color,
    required this.textDirection,
    this.hasLabel = false,
  }) {
    final span = 1.0 / itemsLength;
    final l = startingLoc + (span - _s) / 2;
    loc = textDirection == TextDirection.rtl ? 0.8 - l : l;
    final isAndroid = defaultTargetPlatform == TargetPlatform.android;
    bottom = hasLabel
        ? (isAndroid ? 0.55 : 0.45)
        : (isAndroid ? 0.6 : 0.5);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * (loc - 0.05), 0)
      ..cubicTo(
        size.width * (loc + _s * 0.2),
        size.height * 0.05,
        size.width * loc,
        size.height * bottom,
        size.width * (loc + _s * 0.5),
        size.height * bottom,
      )
      ..cubicTo(
        size.width * (loc + _s),
        size.height * bottom,
        size.width * (loc + _s * 0.8),
        size.height * 0.05,
        size.width * (loc + _s + 0.05),
        0,
      )
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return this != oldDelegate;
  }
}
