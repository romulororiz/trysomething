import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/app_colors.dart';

/// Full-screen loading state: centered app logo pulsing with a fade in/out.
/// Use this wherever a CircularProgressIndicator was shown — it fills the
/// available space with the app background so partial UI never bleeds through.
class LogoLoader extends StatelessWidget {
  const LogoLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: Center(
        child: Image.asset(
          'assets/images/app_logo.png',
          width: 56,
          height: 56,
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .fadeIn(duration: 700.ms, curve: Curves.easeInOut),
      ),
    );
  }
}
