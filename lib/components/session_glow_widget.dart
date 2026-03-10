import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Soft radial warm glow that sits behind all session content.
///
/// When [active] is true, a warm cream radial gradient fades in
/// from the center of the screen over 600 ms. Creates an ambient
/// "spotlight" that makes the session feel intimate and focused.
class SessionGlow extends StatelessWidget {
  final bool active;

  const SessionGlow({super.key, this.active = false});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: active ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 0.6,
            colors: [
              AppColors.textPrimary.withValues(alpha: 0.05),
              AppColors.textPrimary.withValues(alpha: 0.0),
            ],
          ),
        ),
      ),
    );
  }
}
