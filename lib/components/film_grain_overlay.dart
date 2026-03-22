import 'package:flutter/material.dart';

/// A full-screen tiled film grain noise overlay for cinematic warmth (D-08).
///
/// Renders a pre-rendered 256x256 grayscale noise PNG at 1-2% opacity.
/// Uses [Positioned.fill] so it must be placed inside a [Stack].
/// [IgnorePointer] ensures it does not capture touch events.
class FilmGrainOverlay extends StatelessWidget {
  /// Opacity of the grain texture (1.5% by default).
  final double opacity;

  const FilmGrainOverlay({super.key, this.opacity = 0.015});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Opacity(
          opacity: opacity,
          child: Image.asset(
            'assets/textures/film_grain.png',
            repeat: ImageRepeat.repeat,
            filterQuality: FilterQuality.none,
          ),
        ),
      ),
    );
  }
}
