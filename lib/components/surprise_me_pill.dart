import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/motion.dart';
import '../theme/spacing.dart';

/// Glass pill that launches the Surprise Me reveal.
///
/// Shape mirrors the Discover screen's filter pills (For You, Start Cheap…)
/// so it sits flush at the leftmost position in the same horizontal row.
/// A coral-tinted dice icon and a gentle breathing pulse on the icon
/// distinguish it as an *action* affordance rather than another filter,
/// without competing with the screen's single coral CTA.
///
/// Behaviour matches the original FAB:
/// - Tap fires [HapticFeedback.lightImpact] then [onSurprise] once.
/// - Internal [_inFlight] debounce holds for [Motion.spring] so a
///   fast double-tap can't open two reveals.
/// - When [enabled] is false the pill is dimmed to 40% and not interactive.
class SurpriseMePill extends StatefulWidget {
  final VoidCallback onSurprise;
  final bool enabled;

  const SurpriseMePill({
    super.key,
    required this.onSurprise,
    this.enabled = true,
  });

  @override
  State<SurpriseMePill> createState() => _SurpriseMePillState();
}

class _SurpriseMePillState extends State<SurpriseMePill>
    with TickerProviderStateMixin {
  late final AnimationController _spinController;
  late final AnimationController _breathController;
  late final AnimationController _pressController;
  bool _inFlight = false;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: Motion.spring,
    );
    _breathController = AnimationController(
      vsync: this,
      duration: Motion.breathingGlow,
    );
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    if (widget.enabled) {
      _breathController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant SurpriseMePill oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled && !_breathController.isAnimating) {
      _breathController.repeat(reverse: true);
    } else if (!widget.enabled && _breathController.isAnimating) {
      _breathController.stop();
    }
  }

  @override
  void dispose() {
    _spinController.dispose();
    _breathController.dispose();
    _pressController.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (!widget.enabled || _inFlight) return;
    setState(() => _inFlight = true);

    HapticFeedback.lightImpact();
    _spinController.forward(from: 0);
    _pressController.forward(from: 0);
    widget.onSurprise();

    // Release the debounce after the spring settles so a fast double-tap
    // doesn't fire two reveals.
    await Future<void>.delayed(Motion.spring);
    if (mounted) setState(() => _inFlight = false);
  }

  /// Maps press-controller progress to a scale value:
  /// 0 → 1.0, 0.5 → 0.96, 1 → 1.0 (linear down then up).
  double _pressScale(double t) {
    return t < 0.5 ? 1.0 - (t * 0.08) : 0.96 + ((t - 0.5) * 0.08);
  }

  @override
  Widget build(BuildContext context) {
    final dim = !widget.enabled;

    final icon = AnimatedBuilder(
      animation: Listenable.merge([_spinController, _breathController]),
      builder: (context, child) {
        final breath = dim ? 1.0 : (0.7 + _breathController.value * 0.3);
        return Transform.rotate(
          angle: _spinController.value * 2 * math.pi,
          child: Opacity(opacity: breath, child: child),
        );
      },
      child: const Icon(
        PhosphorIconsRegular.diceFive,
        size: 14,
        color: AppColors.coral,
      ),
    );

    Widget pill = GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: Motion.filterToggle,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.glassBackground,
          borderRadius: BorderRadius.circular(Spacing.radiusBadge),
          border: Border.all(
            color: AppColors.coral.withValues(alpha: 0.35),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            const SizedBox(width: 6),
            Text(
              'Surprise me',
              style: AppTypography.caption.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.coral,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );

    // Press-scale feedback — small amplitude (1.0 → 0.96 → 1.0). Pills sit
    // in a row of siblings, so an aggressive overshoot would feel out of
    // place.
    pill = AnimatedBuilder(
      animation: _pressController,
      builder: (context, child) {
        return Transform.scale(
          scale: _pressScale(_pressController.value),
          child: child,
        );
      },
      child: pill,
    );

    if (dim) {
      pill = Opacity(opacity: 0.4, child: pill);
    }

    return Semantics(
      button: true,
      enabled: widget.enabled,
      label: 'Surprise me with a random hobby',
      child: pill,
    );
  }
}
