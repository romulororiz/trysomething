import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../theme/app_colors.dart';
import '../theme/motion.dart';

/// A floating glassy button that rolls a "surprise" hobby on tap.
///
/// Visual language:
/// - Circular glass surface (56dp), frosted, faint coral border.
/// - Subtle breathing glow at [Motion.breathingGlow] cadence — matches
///   the established TryToday button rhythm.
/// - On tap: spring scale (1.0 → 0.92 → 1.05 → 1.0) over [Motion.spring]
///   plus a 360° dice rotation.
///
/// Behaviour:
/// - Tapping fires [HapticFeedback.lightImpact] then calls [onSurprise]
///   exactly once per tap (debounced via internal [_inFlight]).
/// - When [enabled] is false the button is non-interactive and dimmed
///   to 40% opacity with no breathing glow (use during loading / errors).
class SurpriseMeButton extends StatefulWidget {
  final VoidCallback onSurprise;
  final bool enabled;

  const SurpriseMeButton({
    super.key,
    required this.onSurprise,
    this.enabled = true,
  });

  @override
  State<SurpriseMeButton> createState() => _SurpriseMeButtonState();
}

class _SurpriseMeButtonState extends State<SurpriseMeButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spinController;
  bool _inFlight = false;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: Motion.spring,
    );
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (!widget.enabled || _inFlight) return;
    setState(() => _inFlight = true);

    HapticFeedback.lightImpact();
    _spinController.forward(from: 0);
    widget.onSurprise();

    // Release the debounce after the spring settles so a fast double-tap
    // doesn't fire two reveals.
    await Future<void>.delayed(Motion.spring);
    if (mounted) setState(() => _inFlight = false);
  }

  @override
  Widget build(BuildContext context) {
    final dim = !widget.enabled;

    Widget button = GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.glassBackground,
          border: Border.all(
            color: AppColors.coral.withValues(alpha: 0.45),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.coral.withValues(alpha: 0.18),
              blurRadius: 18,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _spinController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _spinController.value * 2 * 3.1415926,
                child: child,
              );
            },
            child: Icon(
              MdiIcons.dice5,
              size: 26,
              color: AppColors.coral,
            ),
          ),
        ),
      ),
    );

    // Press-scale feedback (independent of the spin animation so the
    // user feels the tap immediately).
    button = Animate(
      key: ValueKey(_inFlight),
      effects: _inFlight
          ? [
              ScaleEffect(
                begin: const Offset(1, 1),
                end: const Offset(0.92, 0.92),
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeOut,
              ),
              ScaleEffect(
                begin: const Offset(0.92, 0.92),
                end: const Offset(1.05, 1.05),
                duration: const Duration(milliseconds: 160),
                curve: Curves.easeOut,
                delay: const Duration(milliseconds: 120),
              ),
              ScaleEffect(
                begin: const Offset(1.05, 1.05),
                end: const Offset(1, 1),
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeOut,
                delay: const Duration(milliseconds: 280),
              ),
            ]
          : const [],
      child: button,
    );

    if (dim) {
      button = Opacity(opacity: 0.4, child: button);
    } else {
      // Breathing glow when idle — pulses the shadow, not the button itself,
      // to avoid pulling focus from list content.
      button = button
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scaleXY(
            begin: 1.0,
            end: 1.03,
            duration: Motion.breathingGlow,
            curve: Curves.easeInOut,
          );
    }

    return Semantics(
      button: true,
      enabled: widget.enabled,
      label: 'Surprise me with a random hobby',
      child: button,
    );
  }
}
