import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Paints a 4-layer progress ring: track, glow halo, progress arc, leading dot.
///
/// All layers are drawn in a single [CustomPainter] for efficiency.
/// The ring starts from 12 o'clock (-pi/2) and sweeps clockwise.
class BreathingRingPainter extends CustomPainter {
  /// Progress from 0.0 (empty) to 1.0 (full circle).
  final double progress;

  /// Sinusoidal breathing scale, typically 1.0 to 1.008.
  final double breathScale;

  /// Glow halo intensity: 0.15 normal, 0.25 for last minute (D-24).
  final double glowIntensity;

  /// Overall ring opacity: 1.0 normal, 0.4 when paused (D-21).
  final double ringOpacity;

  BreathingRingPainter({
    required this.progress,
    this.breathScale = 1.0,
    this.glowIntensity = 0.15,
    this.ringOpacity = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Apply breathing scale around center
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(breathScale, breathScale);
    canvas.translate(-center.dx, -center.dy);

    final rect = Rect.fromCircle(center: center, radius: radius);
    const startAngle = -pi / 2; // 12 o'clock
    final sweepAngle = 2 * pi * progress;

    // Layer 1: Track ring (D-05) — full circle at 6% white
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = const Color(0x0FFFFFFF) // 6% white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.5,
    );

    // Layer 2: Glow halo (D-01) — blurred arc behind progress
    if (progress > 0) {
      canvas.drawArc(
        rect,
        startAngle,
        sweepAngle,
        false,
        Paint()
          ..color = AppColors.accent.withValues(alpha: glowIntensity * ringOpacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8.0
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0),
      );
    }

    // Layer 3: Progress arc (D-01, D-02) — solid coral stroke
    if (progress > 0) {
      canvas.drawArc(
        rect,
        startAngle,
        sweepAngle,
        false,
        Paint()
          ..color = AppColors.accent.withValues(alpha: ringOpacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.5
          ..strokeCap = StrokeCap.round,
      );
    }

    // Layer 4: Leading dot (D-04) — glow + solid dot at arc tip
    if (progress > 0 && progress < 1.0) {
      final dotAngle = startAngle + sweepAngle;
      final dotX = center.dx + radius * cos(dotAngle);
      final dotY = center.dy + radius * sin(dotAngle);

      // Soft glow behind dot
      canvas.drawCircle(
        Offset(dotX, dotY),
        8,
        Paint()
          ..color = AppColors.accent.withValues(alpha: 0.15 * ringOpacity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );

      // Solid dot
      canvas.drawCircle(
        Offset(dotX, dotY),
        3,
        Paint()
          ..color = AppColors.accent.withValues(alpha: 0.8 * ringOpacity),
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(BreathingRingPainter old) =>
      old.progress != progress ||
      old.breathScale != breathScale ||
      old.glowIntensity != glowIntensity ||
      old.ringOpacity != ringOpacity;
}

/// A breathing progress ring with sinusoidal scale animation.
///
/// The ring pulses subtly at [breathCycleDuration] using a sin() curve,
/// scaling between 1.0 and 1.008 (D-10). Supports milestone pulse (D-23)
/// via [triggerMilestonePulse].
class BreathingRing extends StatefulWidget {
  /// Progress from 0.0 to 1.0.
  final double progress;

  /// Breathing cycle duration (D-10: 4s active, D-11: 8s paused, D-12: 3s last minute).
  final Duration breathCycleDuration;

  /// Glow halo intensity (D-24: 0.25 for last minute).
  final double glowIntensity;

  /// Ring opacity (D-21: 0.4 when paused).
  final double ringOpacity;

  /// Ring diameter in logical pixels (D-03: ~270dp).
  final double ringSize;

  const BreathingRing({
    super.key,
    required this.progress,
    this.breathCycleDuration = const Duration(milliseconds: 4000),
    this.glowIntensity = 0.15,
    this.ringOpacity = 1.0,
    this.ringSize = 270,
  });

  @override
  State<BreathingRing> createState() => BreathingRingState();
}

class BreathingRingState extends State<BreathingRing>
    with TickerProviderStateMixin {
  late AnimationController _breathController;
  late AnimationController _pulseController;
  double _breathScale = 1.0;
  double _pulseScale = 0.0;

  @override
  void initState() {
    super.initState();

    _breathController = AnimationController(
      vsync: this,
      duration: widget.breathCycleDuration,
    )..addListener(_onBreathTick);
    _breathController.repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..addListener(_onPulseTick);
  }

  void _onBreathTick() {
    setState(() {
      _breathScale = 1.0 + 0.008 * sin(_breathController.value * 2 * pi);
    });
  }

  void _onPulseTick() {
    setState(() {
      // Rise to 0.012 at halfway (0.5), then back to 0
      final v = _pulseController.value;
      _pulseScale = v < 0.5
          ? v * 2 * 0.012
          : (1.0 - v) * 2 * 0.012;
    });
  }

  @override
  void didUpdateWidget(BreathingRing oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Per Pitfall 3: stop, update duration, restart to avoid jumps
    if (oldWidget.breathCycleDuration != widget.breathCycleDuration) {
      _breathController.stop();
      _breathController.duration = widget.breathCycleDuration;
      _breathController.repeat();
    }
  }

  /// Trigger a milestone pulse animation (D-23: scale 1.02 over 600ms).
  void triggerMilestonePulse() {
    _pulseController.forward(from: 0.0);
  }

  @override
  void dispose() {
    _breathController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final finalScale = _breathScale + _pulseScale;

    return RepaintBoundary(
      child: SizedBox(
        width: widget.ringSize,
        height: widget.ringSize,
        child: CustomPaint(
          painter: BreathingRingPainter(
            progress: widget.progress,
            breathScale: finalScale,
            glowIntensity: widget.glowIntensity,
            ringOpacity: widget.ringOpacity,
          ),
        ),
      ),
    );
  }
}
