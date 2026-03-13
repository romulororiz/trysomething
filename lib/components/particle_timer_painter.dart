import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════
//  PREMIUM 3D PARTICLE FIELD — Full-screen session visual
// ═══════════════════════════════════════════════════════

/// Category-themed color palettes for the particle field.
/// Each category gets 3 tonal colors that blend beautifully.
class ParticlePalette {
  final Color primary;
  final Color secondary;
  final Color tertiary;

  const ParticlePalette(this.primary, this.secondary, this.tertiary);

  static ParticlePalette forCategory(String category) {
    switch (category.toLowerCase()) {
      case 'creative':
        return const ParticlePalette(
          Color(0xFFFF6B6B), // Coral
          Color(0xFFFF9E9E), // Rose
          Color(0xFFFFCBA4), // Peach
        );
      case 'outdoors':
        return const ParticlePalette(
          Color(0xFF06D6A0), // Sage
          Color(0xFF4AEDC4), // Mint
          Color(0xFF88F7E2), // Foam
        );
      case 'fitness':
        return const ParticlePalette(
          Color(0xFFFFB347), // Amber
          Color(0xFFFF8C42), // Tangerine
          Color(0xFFFFD166), // Gold
        );
      case 'music':
        return const ParticlePalette(
          Color(0xFF7B68EE), // Slate blue
          Color(0xFF9B8FFF), // Periwinkle
          Color(0xFFC4B5FD), // Lavender
        );
      case 'food':
        return const ParticlePalette(
          Color(0xFFDAA520), // Goldenrod
          Color(0xFFE8C547), // Warm gold
          Color(0xFFF5E6D8), // Cream
        );
      case 'maker':
        return const ParticlePalette(
          Color(0xFF87CEEB), // Sky blue
          Color(0xFF60A5FA), // Steel blue
          Color(0xFFBAE6FD), // Ice
        );
      case 'mind':
        return const ParticlePalette(
          Color(0xFFDDA0DD), // Plum
          Color(0xFFC084FC), // Violet
          Color(0xFFE9D5FF), // Mauve
        );
      case 'collecting':
        return const ParticlePalette(
          Color(0xFFF5F0EB), // Warm cream
          Color(0xFFD4C5B9), // Sand
          Color(0xFFE8DDD4), // Linen
        );
      case 'social':
        return const ParticlePalette(
          Color(0xFFFFB6C1), // Light pink
          Color(0xFFFF8FAB), // Rose
          Color(0xFFFFC8DD), // Blush
        );
      default:
        return const ParticlePalette(
          Color(0xFFF5F0EB),
          Color(0xFFD4C5B9),
          Color(0xFFE8DDD4),
        );
    }
  }

  /// Legacy accessor used by other widgets.
  Color get themeColor => primary;
}

/// Kept for backward compat — maps to palette primary.
Color getSessionThemeColor(String category) =>
    ParticlePalette.forCategory(category).primary;

// ─────────────────────────────────────────────────
//  Simple 2D value noise for organic movement
// ─────────────────────────────────────────────────

class _Noise {
  static double _hash(int x, int y) {
    int h = x * 374761393 + y * 668265263;
    h = (h ^ (h >> 13)) * 1274126177;
    return (h & 0x7fffffff) / 0x7fffffff;
  }

  static double _lerp(double a, double b, double t) => a + (b - a) * t;

  static double _smooth(double t) => t * t * (3.0 - 2.0 * t);

  /// Returns noise value in range [-1, 1].
  static double value2D(double x, double y) {
    final ix = x.floor();
    final iy = y.floor();
    final fx = _smooth(x - ix);
    final fy = _smooth(y - iy);

    final n00 = _hash(ix, iy);
    final n10 = _hash(ix + 1, iy);
    final n01 = _hash(ix, iy + 1);
    final n11 = _hash(ix + 1, iy + 1);

    return _lerp(_lerp(n00, n10, fx), _lerp(n01, n11, fx), fy) * 2.0 - 1.0;
  }

  /// Fractional Brownian motion — layered noise for richer organic flow.
  static double fbm(double x, double y, {int octaves = 3}) {
    double value = 0.0;
    double amplitude = 1.0;
    double frequency = 1.0;
    double maxAmp = 0.0;

    for (int i = 0; i < octaves; i++) {
      value += amplitude * value2D(x * frequency, y * frequency);
      maxAmp += amplitude;
      amplitude *= 0.5;
      frequency *= 2.0;
    }
    return value / maxAmp;
  }
}

// ─────────────────────────────────────────────────
//  Particle data
// ─────────────────────────────────────────────────

enum _DepthLayer { far, mid, near }

class _Particle3D {
  double x; // normalized 0..1
  double y;
  double z; // depth: 0 = far, 1 = near
  _DepthLayer layer;
  double baseAngle; // initial orbital angle
  double orbitRadius; // distance from center (normalized)
  double orbitSpeed; // angular velocity multiplier
  double baseSize; // base radius in px
  double phase; // unique phase offset
  int colorIndex; // 0, 1, or 2 (palette color)
  double noiseOffsetX; // unique noise seed
  double noiseOffsetY;

  _Particle3D({
    required this.x,
    required this.y,
    required this.z,
    required this.layer,
    required this.baseAngle,
    required this.orbitRadius,
    required this.orbitSpeed,
    required this.baseSize,
    required this.phase,
    required this.colorIndex,
    required this.noiseOffsetX,
    required this.noiseOffsetY,
  });
}

// ─────────────────────────────────────────────────
//  Full-screen particle field widget
// ─────────────────────────────────────────────────

/// Premium full-screen particle background for sessions.
///
/// Renders 3 depth layers of particles with noise-based organic movement,
/// glow halos, constellation connections, and progress-based activation.
/// Replaces both CategoryShape and the old ParticleTimerWidget.
class SessionParticleField extends StatefulWidget {
  /// Timer progress 0.0 → 1.0. Controls clockwise activation sweep.
  final double progress;

  /// Hobby category — determines color palette and subtle movement style.
  final String category;

  /// Whether the session is actively running (particles more alive).
  final bool isActive;

  /// Completion burst moment.
  final bool isCompleting;

  const SessionParticleField({
    super.key,
    this.progress = 0.0,
    required this.category,
    this.isActive = false,
    this.isCompleting = false,
  });

  @override
  State<SessionParticleField> createState() => _SessionParticleFieldState();
}

class _SessionParticleFieldState extends State<SessionParticleField>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle3D> _particles;
  late ParticlePalette _palette;
  final Random _rng = Random(42);

  double _time = 0.0;
  double _burstProgress = 0.0;
  bool _wasBursting = false;

  // Layer counts
  static const int _farCount = 50;
  static const int _midCount = 35;
  static const int _nearCount = 18;

  @override
  void initState() {
    super.initState();
    _palette = ParticlePalette.forCategory(widget.category);
    _particles = _generateParticles();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    _controller.addListener(_tick);
  }

  @override
  void didUpdateWidget(SessionParticleField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.category != widget.category) {
      _palette = ParticlePalette.forCategory(widget.category);
      _particles = _generateParticles();
    }
    if (widget.isCompleting && !_wasBursting) {
      _wasBursting = true;
      _burstProgress = 0.0;
    }
    if (!widget.isCompleting && _wasBursting) {
      _wasBursting = false;
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_tick);
    _controller.dispose();
    super.dispose();
  }

  List<_Particle3D> _generateParticles() {
    final particles = <_Particle3D>[];

    void addLayer(_DepthLayer layer, int count, double zMin, double zMax,
        double sizeMin, double sizeMax) {
      for (int i = 0; i < count; i++) {
        // Golden angle distribution for even spacing
        final goldenAngle = pi * (3.0 - sqrt(5.0));
        final angle = goldenAngle * (particles.length + i);
        final radiusFrac = 0.05 + _rng.nextDouble() * 0.42;

        particles.add(_Particle3D(
          x: 0.5 + radiusFrac * cos(angle),
          y: 0.5 + radiusFrac * sin(angle),
          z: zMin + _rng.nextDouble() * (zMax - zMin),
          layer: layer,
          baseAngle: angle,
          orbitRadius: radiusFrac,
          orbitSpeed: 0.08 + _rng.nextDouble() * 0.25,
          baseSize: sizeMin + _rng.nextDouble() * (sizeMax - sizeMin),
          phase: _rng.nextDouble() * 2 * pi,
          colorIndex: _rng.nextInt(3),
          noiseOffsetX: _rng.nextDouble() * 100.0,
          noiseOffsetY: _rng.nextDouble() * 100.0,
        ));
      }
    }

    addLayer(_DepthLayer.far, _farCount, 0.0, 0.3, 1.0, 2.5);
    addLayer(_DepthLayer.mid, _midCount, 0.3, 0.7, 2.5, 5.0);
    addLayer(_DepthLayer.near, _nearCount, 0.7, 1.0, 5.0, 10.0);

    return particles;
  }

  void _tick() {
    const dt = 1.0 / 60.0;
    _time += dt;

    // Burst animation
    if (_wasBursting) {
      _burstProgress = (_burstProgress + dt * 1.0).clamp(0.0, 2.0);
    } else {
      _burstProgress = (_burstProgress - dt * 0.5).clamp(0.0, 2.0);
    }

    // Update particle positions with noise-based organic movement
    for (final p in _particles) {
      final depthSpeed = 0.3 + p.z * 0.7; // far=0.3x, near=1.0x

      // Slow orbital drift
      p.baseAngle += p.orbitSpeed * dt * 0.15 * depthSpeed;

      // Noise-displaced position
      final noiseT = _time * 0.12 * depthSpeed;
      final nx = _Noise.fbm(
        p.noiseOffsetX + noiseT,
        p.noiseOffsetY,
        octaves: 2,
      );
      final ny = _Noise.fbm(
        p.noiseOffsetX,
        p.noiseOffsetY + noiseT,
        octaves: 2,
      );

      // Orbital base + noise displacement
      final noiseStrength = 0.06 + p.z * 0.04;
      p.x = 0.5 + p.orbitRadius * cos(p.baseAngle) + nx * noiseStrength;
      p.y = 0.5 + p.orbitRadius * sin(p.baseAngle) + ny * noiseStrength;

      // Breathing oscillation
      final breath = sin(_time * 0.5 + p.phase) * 0.008;
      p.x += breath;
      p.y += breath * 0.7;

      // Burst effect — expand then contract
      if (_burstProgress > 0) {
        final dx = p.x - 0.5;
        final dy = p.y - 0.5;
        if (_burstProgress < 1.0) {
          final expand = _burstProgress * 0.15;
          p.x += dx * expand;
          p.y += dy * expand;
        } else {
          final contract = (_burstProgress - 1.0) * 0.1;
          p.x -= dx * contract;
          p.y -= dy * contract;
        }
      }

      // Soft containment — gently pull back if drifting too far
      final distSq = (p.x - 0.5) * (p.x - 0.5) + (p.y - 0.5) * (p.y - 0.5);
      if (distSq > 0.22) {
        p.x += (0.5 - p.x) * 0.01;
        p.y += (0.5 - p.y) * 0.01;
      }
    }

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _ParticleField3DPainter(
          particles: _particles,
          progress: widget.progress,
          palette: _palette,
          isActive: widget.isActive,
          burstProgress: _burstProgress,
          time: _time,
        ),
        size: Size.infinite,
      ),
    );
  }
}

// ─────────────────────────────────────────────────
//  3D Particle Field Painter
// ─────────────────────────────────────────────────

class _ParticleField3DPainter extends CustomPainter {
  final List<_Particle3D> particles;
  final double progress;
  final ParticlePalette palette;
  final bool isActive;
  final double burstProgress;
  final double time;

  // Pre-allocated paints
  final Paint _glowPaint = Paint()..style = PaintingStyle.fill;
  final Paint _dotPaint = Paint()..style = PaintingStyle.fill;
  final Paint _linePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.4;
  final Paint _centerPaint = Paint()..style = PaintingStyle.fill;

  _ParticleField3DPainter({
    required this.particles,
    required this.progress,
    required this.palette,
    required this.isActive,
    required this.burstProgress,
    required this.time,
  });

  Color _colorForIndex(int index) {
    switch (index) {
      case 0:
        return palette.primary;
      case 1:
        return palette.secondary;
      default:
        return palette.tertiary;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Global breathing scale
    final breathScale = 1.0 + 0.012 * sin(time * 0.4);
    canvas.save();
    canvas.translate(cx, cy);
    canvas.scale(breathScale, breathScale);
    canvas.translate(-cx, -cy);

    // 1. Deep ambient center glow
    _drawCenterGlow(canvas, cx, cy, size);

    // 2. Render layers back-to-front: far → mid → near
    _drawLayer(canvas, size, _DepthLayer.far);
    _drawConnections(canvas, size, _DepthLayer.mid);
    _drawLayer(canvas, size, _DepthLayer.mid);
    _drawLayer(canvas, size, _DepthLayer.near);

    canvas.restore();
  }

  void _drawCenterGlow(Canvas canvas, double cx, double cy, Size size) {
    final baseIntensity = isActive ? 0.04 : 0.015;
    final progressBoost = progress * 0.06;
    final burstBoost =
        burstProgress > 0 && burstProgress < 1.0 ? burstProgress * 0.08 : 0.0;
    final intensity = baseIntensity + progressBoost + burstBoost;
    final radius = size.shortestSide * (0.35 + progress * 0.1);

    _centerPaint.shader = ui.Gradient.radial(
      Offset(cx, cy),
      radius,
      [
        palette.primary.withValues(alpha: intensity),
        palette.secondary.withValues(alpha: intensity * 0.3),
        palette.primary.withValues(alpha: 0.0),
      ],
      [0.0, 0.5, 1.0],
    );
    canvas.drawCircle(Offset(cx, cy), radius, _centerPaint);
  }

  void _drawLayer(Canvas canvas, Size size, _DepthLayer layer) {
    for (final p in particles) {
      if (p.layer != layer) continue;

      final px = p.x * size.width;
      final py = p.y * size.height;
      final activation = _activationStrength(p);
      final color = _colorForIndex(p.colorIndex);

      // Depth-based properties
      double opacityBase, opacityActive, glowRadius, blurSigma;
      switch (layer) {
        case _DepthLayer.far:
          opacityBase = 0.06;
          opacityActive = 0.25;
          glowRadius = 0.0;
          blurSigma = 0.0;
        case _DepthLayer.mid:
          opacityBase = 0.08;
          opacityActive = 0.55;
          glowRadius = p.baseSize * 2.5;
          blurSigma = 4.0;
        case _DepthLayer.near:
          opacityBase = 0.06;
          opacityActive = 0.7;
          glowRadius = p.baseSize * 3.5;
          blurSigma = 8.0;
      }

      // Edge fade — particles near screen edges dim out
      final dx = (p.x - 0.5).abs();
      final dy = (p.y - 0.5).abs();
      final edgeDist = max(dx, dy);
      final edgeFade = (1.0 - (edgeDist / 0.55)).clamp(0.0, 1.0);

      // Final opacity
      final opacity =
          (opacityBase + (opacityActive - opacityBase) * activation) * edgeFade;

      // Burst flash
      final burstFlash = burstProgress > 0 && burstProgress < 0.4
          ? (1.0 - burstProgress / 0.4) * 0.3
          : 0.0;

      final finalOpacity = (opacity + burstFlash).clamp(0.0, 1.0);
      if (finalOpacity < 0.005) continue;

      // Size pulses slightly with activation
      final drawSize = p.baseSize * (1.0 + activation * 0.25);

      // Glow halo (mid + near layers, active particles)
      if (glowRadius > 0 && activation > 0.05) {
        _glowPaint.color =
            color.withValues(alpha: finalOpacity * 0.12 * activation);
        _glowPaint.maskFilter =
            MaskFilter.blur(BlurStyle.normal, blurSigma);
        canvas.drawCircle(Offset(px, py), glowRadius, _glowPaint);
      }

      // Near-layer particles get a soft depth-of-field blur
      if (layer == _DepthLayer.near && activation > 0.3) {
        _dotPaint.maskFilter =
            const MaskFilter.blur(BlurStyle.normal, 1.5);
      } else {
        _dotPaint.maskFilter = null;
      }

      // Draw particle dot
      _dotPaint.color = color.withValues(alpha: finalOpacity);
      canvas.drawCircle(Offset(px, py), drawSize, _dotPaint);
    }
    // Reset
    _dotPaint.maskFilter = null;
    _glowPaint.maskFilter = null;
  }

  /// Draws subtle constellation lines between nearby mid-layer particles.
  void _drawConnections(Canvas canvas, Size size, _DepthLayer layer) {
    final layerParticles =
        particles.where((p) => p.layer == layer).toList();
    final maxDist = size.shortestSide * 0.12;

    for (int i = 0; i < layerParticles.length; i++) {
      final a = layerParticles[i];
      final aStrength = _activationStrength(a);
      if (aStrength < 0.1) continue;

      final ax = a.x * size.width;
      final ay = a.y * size.height;

      for (int j = i + 1; j < layerParticles.length; j++) {
        final b = layerParticles[j];
        final bStrength = _activationStrength(b);
        if (bStrength < 0.1) continue;

        final bx = b.x * size.width;
        final by = b.y * size.height;
        final dist = sqrt((ax - bx) * (ax - bx) + (ay - by) * (ay - by));

        if (dist < maxDist) {
          final fade = 1.0 - (dist / maxDist);
          final alpha = fade * 0.08 * min(aStrength, bStrength);
          final lineColor =
              _colorForIndex(a.colorIndex).withValues(alpha: alpha);
          _linePaint.color = lineColor;
          canvas.drawLine(Offset(ax, ay), Offset(bx, by), _linePaint);
        }
      }
    }
  }

  /// Activation sweeps clockwise from 12 o'clock.
  double _activationStrength(_Particle3D p) {
    // In non-active mode, show subtle ambient life
    if (!isActive && progress <= 0) {
      // Gentle ambient pulse based on time
      return 0.15 + 0.1 * sin(time * 0.3 + p.phase);
    }

    if (progress >= 1.0) return 1.0;

    // Convert position angle to clockwise-from-top [0, 1]
    final dx = p.x - 0.5;
    final dy = p.y - 0.5;
    final angle = atan2(dx, -dy); // clockwise from top
    double normalized = angle / (2 * pi);
    if (normalized < 0) normalized += 1.0;

    if (normalized <= progress) return 1.0;

    // Soft activation wave edge
    final waveDist = normalized - progress;
    if (waveDist < 0.06) {
      return 1.0 - (waveDist / 0.06);
    }

    // Ambient glow for inactive particles
    return 0.08 + 0.05 * sin(time * 0.25 + p.phase);
  }

  @override
  bool shouldRepaint(_ParticleField3DPainter old) => true;
}

// ─────────────────────────────────────────────────
//  Legacy API — kept for any external references
// ─────────────────────────────────────────────────

/// Legacy widget — now wraps [SessionParticleField] in a sized box.
class ParticleTimerWidget extends StatelessWidget {
  final double progress;
  final double size;
  final String category;
  final bool isCompleting;

  const ParticleTimerWidget({
    super.key,
    required this.progress,
    this.size = 240,
    required this.category,
    this.isCompleting = false,
  });

  static Color getThemeColor(String category) =>
      ParticlePalette.forCategory(category).primary;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: SessionParticleField(
        progress: progress,
        category: category,
        isActive: progress > 0,
        isCompleting: isCompleting,
      ),
    );
  }
}
