import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../theme/motion.dart';

/// Fade + upward slide transition for push routes.
/// Content fades in while sliding 20px upward over 300ms.
CustomTransitionPage<T> fadeSlideTransitionPage<T>({
  required Widget child,
  LocalKey? key,
}) {
  return CustomTransitionPage<T>(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fade = CurvedAnimation(
        parent: animation,
        curve: Motion.normalCurve,
      );
      final slide = Tween<Offset>(
        begin: const Offset(0, 0.04),
        end: Offset.zero,
      ).animate(fade);
      return FadeTransition(
        opacity: fade,
        child: SlideTransition(position: slide, child: child),
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: Motion.navBack,
  );
}

/// Slide-from-right transition with subtle scrim dimming the old page.
Widget buildSlideRightTransition(
    Animation<double> animation, Widget child) {
  final slideIn = Tween<Offset>(
    begin: const Offset(1, 0),
    end: Offset.zero,
  ).animate(CurvedAnimation(
    parent: animation,
    curve: Curves.easeInOutCubic,
  ));

  final scrimOpacity = Tween<double>(begin: 0, end: 0.05).animate(
    CurvedAnimation(parent: animation, curve: Curves.easeInOut),
  );

  return Stack(
    children: [
      FadeTransition(
        opacity: scrimOpacity,
        child: Container(color: Colors.black),
      ),
      SlideTransition(position: slideIn, child: child),
    ],
  );
}

/// Slide-up modal transition with backdrop blur for bottom sheets.
CustomTransitionPage<T> modalSlideUpTransitionPage<T>({
  required Widget child,
  LocalKey? key,
}) {
  return CustomTransitionPage<T>(
    key: key,
    child: child,
    opaque: false,
    barrierColor: Colors.transparent,
    transitionsBuilder: (context, animation, _, child) {
      final slideUp = Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Motion.normalCurve,
      ));

      final scrimOpacity = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeOut),
      );

      return Stack(
        children: [
          FadeTransition(
            opacity: scrimOpacity,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                color: AppColors.cream.withValues(alpha: 0.6),
              ),
            ),
          ),
          SlideTransition(position: slideUp, child: child),
        ],
      );
    },
    transitionDuration: Motion.bottomSheet,
  );
}
