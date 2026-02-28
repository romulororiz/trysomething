import 'package:flutter/material.dart';

/// TrySomething custom scroll physics — slight rubber-band feel on all platforms.
///
/// Spec: BouncingScrollPhysics on iOS, ClampingScrollPhysics on Android,
/// with a gentle overscroll on both for a premium touch.
class TryScrollPhysics extends ScrollPhysics {
  const TryScrollPhysics({super.parent});

  @override
  TryScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return TryScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    // Default behavior for in-range scrolling
    if (!position.outOfRange) return offset;

    // Gentle rubber-band: increasing resistance as you pull further out
    final overscroll = position.pixels - position.minScrollExtent;
    final underscroll = position.maxScrollExtent - position.pixels;
    final isOver = overscroll < 0 ? -overscroll : (underscroll < 0 ? -underscroll : 0.0);

    // Dampen by a factor that increases with distance (softer rubber-band)
    final dampen = 0.5 * (1.0 - (isOver / 600).clamp(0.0, 0.6));
    return offset * dampen;
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    // Allow overscroll on all platforms (rubber-band)
    return 0.0;
  }

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    // If out of range, spring back
    if (position.outOfRange) {
      double target;
      if (position.pixels < position.minScrollExtent) {
        target = position.minScrollExtent;
      } else {
        target = position.maxScrollExtent;
      }

      return ScrollSpringSimulation(
        SpringDescription(
          mass: 1.0,
          stiffness: 300,
          damping: 22,
        ),
        position.pixels,
        target,
        velocity,
      );
    }

    // Normal deceleration
    if (velocity.abs() < toleranceFor(position).velocity) return null;
    return ClampingScrollSimulation(
      position: position.pixels,
      velocity: velocity,
    );
  }
}
