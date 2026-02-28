import 'package:flutter/material.dart';

/// TrySomething — Motion & Animation Tokens
///
/// Motion communicates hierarchy, not decoration.
/// Every animation serves a purpose: guide attention, confirm action,
/// or show spatial relationship.
class Motion {
  Motion._();

  // ═══════════════════════════════════════════════════
  //  TIMING TOKENS
  // ═══════════════════════════════════════════════════

  /// Micro-interactions, toggles — 150ms
  static const Duration fast = Duration(milliseconds: 150);
  static const Curve fastCurve = Curves.easeInOut;

  /// Standard transitions, fades — 250ms
  static const Duration normal = Duration(milliseconds: 250);
  static const Curve normalCurve = Cubic(0.33, 1, 0.68, 1); // easeOutCubic

  /// Page transitions, reveals — 350ms
  static const Duration slow = Duration(milliseconds: 350);
  static const Curve slowCurve = Curves.easeInOutCubic;

  /// Shared element transitions — 500ms
  static const Duration hero = Duration(milliseconds: 500);
  static const Curve heroCurve = Cubic(0.33, 1, 0.68, 1); // easeOutCubic

  /// Checkbox, button press — 400ms
  static const Duration spring = Duration(milliseconds: 400);
  static const Curve springCurve = Curves.elasticOut;

  // ═══════════════════════════════════════════════════
  //  SPECIFIC DURATIONS
  // ═══════════════════════════════════════════════════

  /// TryToday button breathing glow cycle
  static const Duration breathingGlow = Duration(milliseconds: 1800);

  /// Card press effect
  static const Duration cardPress = Duration(milliseconds: 150);

  /// Button press
  static const Duration buttonPress = Duration(milliseconds: 120);

  /// Button release
  static const Duration buttonRelease = Duration(milliseconds: 200);

  /// Onboarding page transition
  static const Duration onboardingPage = Duration(milliseconds: 400);

  /// Progress bar fill
  static const Duration progressBar = Duration(milliseconds: 300);

  /// Tab switch indicator
  static const Duration tabSwitch = Duration(milliseconds: 250);

  /// Filter panel expand/collapse
  static const Duration filterToggle = Duration(milliseconds: 200);

  /// Forward navigation (push)
  static const Duration navForward = Duration(milliseconds: 350);

  /// Back navigation (pop)
  static const Duration navBack = Duration(milliseconds: 300);

  /// Bottom sheets
  static const Duration bottomSheet = Duration(milliseconds: 350);

  // ═══════════════════════════════════════════════════
  //  SCALE VALUES
  // ═══════════════════════════════════════════════════

  /// Card press scale
  static const double cardPressScale = 0.975;

  /// Button press scale
  static const double buttonPressScale = 0.97;

  /// Save button bounce max scale
  static const double saveBounceScale = 1.2;

  /// Category icon press scale
  static const double categoryPressScale = 1.12;

  // ═══════════════════════════════════════════════════
  //  PHYSICS
  // ═══════════════════════════════════════════════════

  /// Card swipe velocity threshold (px/s)
  static const double swipeVelocityThreshold = 300;

  /// Feed viewportFraction (peek edges)
  static const double feedViewportFraction = 0.92;

  /// Parallax factor
  static const double parallaxFactor = 0.5;

  /// Max parallax offset
  static const double maxParallaxOffset = 80;

  // ═══════════════════════════════════════════════════
  //  HELPERS
  // ═══════════════════════════════════════════════════

  /// Returns whether reduced motion is preferred.
  static bool shouldReduceMotion(BuildContext context) {
    return MediaQuery.of(context).disableAnimations;
  }

  /// Returns the given duration or zero if reduced motion is preferred.
  static Duration adaptive(BuildContext context, Duration duration) {
    return shouldReduceMotion(context) ? Duration.zero : duration;
  }

  /// Stagger delay for list item at [index].
  static Duration stagger(int index, {int intervalMs = 50}) {
    return Duration(milliseconds: index * intervalMs);
  }
}
