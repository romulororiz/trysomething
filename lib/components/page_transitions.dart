import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../theme/motion.dart';

/// Slide-up modal transition with backdrop blur for bottom sheets.
/// (Pushed screens use CupertinoPage in router.dart — native slide with
/// iOS interactive swipe-back. Only this modal remains custom.)
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
