import 'package:flutter/material.dart';

/// Cinematic layered background:
/// 1. Dark linear gradient top→bottom (#10121C → #07070C)
/// 2. Optional corner tints: teal top-left + burgundy bottom-right
///
/// [tintTopLeft]     — teal glow at top-left (disable on hero-image screens)
/// [tintBottomRight] — burgundy glow at bottom-right (usually always on)
class AppBackground extends StatelessWidget {
  final Widget child;
  final bool tintTopLeft;
  final bool tintBottomRight;

  const AppBackground({
    super.key,
    required this.child,
    this.tintTopLeft = true,
    this.tintBottomRight = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base: dark linear gradient top→bottom
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.35, 0.65, 1.0],
                colors: [
                  Color(0xFF10121C),
                  Color(0xFF0B0B12),
                  Color(0xFF09090F),
                  Color(0xFF07070C),
                ],
              ),
            ),
          ),
        ),
        // Teal top-left tint
        if (tintTopLeft)
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.center,
                  stops: [0.0, 1.0],
                  colors: [
                    Color(0x3D068BA8),
                    Color(0x00000000),
                  ],
                ),
              ),
            ),
          ),
        // Burgundy bottom-right tint
        if (tintBottomRight)
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomRight,
                  end: Alignment.center,
                  stops: [0.0, 1.0],
                  colors: [
                    Color(0x3D7A3050),
                    Color(0x00000000),
                  ],
                ),
              ),
            ),
          ),
        child,
      ],
    );
  }
}
