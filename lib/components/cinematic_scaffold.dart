import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Scaffold wrapper that applies the Warm Cinematic Minimalism base:
/// - Deep black background
/// - Subtle noise grain overlay (painted, no asset needed)
///
/// Wrap every screen's Scaffold body with this for consistent texture.
///
/// ```dart
/// CinematicScaffold(
///   body: ListView(...),
/// )
/// ```
class CinematicScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool extendBody;
  final bool extendBodyBehindAppBar;
  final Color? backgroundColor;

  const CinematicScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.background,
      appBar: appBar,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      body: Stack(
        children: [
          body,
          // Noise grain overlay — very subtle organic texture
          Positioned.fill(
            child: IgnorePointer(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: _NoiseGrainPainter(),
                  willChange: false,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Paints a subtle noise grain texture over the entire screen.
///
/// Uses a fixed random seed for deterministic output (no flicker).
/// Very low density (~0.8%) and low opacity (3-4%) so it adds
/// organic warmth without being distracting.
class _NoiseGrainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(42);
    final paint = Paint();
    final count = (size.width * size.height * 0.008).toInt();

    for (int i = 0; i < count; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final grey = 128 + rng.nextInt(128); // Light dots on dark bg
      paint.color = Color.fromRGBO(grey, grey, grey, 0.03);
      canvas.drawCircle(Offset(x, y), 0.6, paint);
    }
  }

  @override
  bool shouldRepaint(_NoiseGrainPainter oldDelegate) => false;
}
