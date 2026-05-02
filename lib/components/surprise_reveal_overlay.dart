import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../models/hobby.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/category_ui.dart';
import '../theme/motion.dart';
import '../theme/spacing.dart';
import 'glass_card.dart';

/// Shows the Surprise Me reveal as a full-screen overlay with a flip-card
/// reveal animation. The overlay is dismissable by tapping the scrim, the
/// system back gesture, or pressing Escape on a keyboard.
///
/// [pickAnother] is called when the user taps "Surprise me again" — it
/// must return a *different* [Hobby] (the caller is responsible for ensuring
/// a different id is returned). When it returns null the reveal stays on
/// the current hobby (defensive — should not happen in practice).
Future<void> showSurpriseReveal(
  BuildContext context, {
  required Hobby initial,
  required Hobby? Function(String currentId) pickAnother,
}) async {
  HapticFeedback.mediumImpact();
  await Navigator.of(context, rootNavigator: true).push(
    PageRouteBuilder<void>(
      opaque: false,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      transitionDuration: Motion.hero,
      reverseTransitionDuration: Motion.normal,
      pageBuilder: (context, anim, _) {
        return _SurpriseRevealRoute(
          initial: initial,
          pickAnother: pickAnother,
          entrance: anim,
        );
      },
    ),
  );
}

class _SurpriseRevealRoute extends StatefulWidget {
  final Hobby initial;
  final Hobby? Function(String currentId) pickAnother;
  final Animation<double> entrance;

  const _SurpriseRevealRoute({
    required this.initial,
    required this.pickAnother,
    required this.entrance,
  });

  @override
  State<_SurpriseRevealRoute> createState() => _SurpriseRevealRouteState();
}

class _SurpriseRevealRouteState extends State<_SurpriseRevealRoute>
    with SingleTickerProviderStateMixin {
  late Hobby _hobby;
  late final AnimationController _flipController;
  Hobby? _pendingHobby; // Shown after flip lands.

  @override
  void initState() {
    super.initState();
    _hobby = widget.initial;
    _flipController = AnimationController(
      vsync: this,
      duration: Motion.hero,
    );
    // Initial card is "facing" — no flip yet.
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  Future<void> _shuffleAgain() async {
    if (_flipController.isAnimating) return;
    final next = widget.pickAnother(_hobby.id);
    if (next == null) return;
    HapticFeedback.lightImpact();
    _pendingHobby = next;
    _flipController.forward(from: 0);
    // Swap content at the half-flip moment (when the card edge is on us).
    Future<void>.delayed(
      Duration(milliseconds: Motion.hero.inMilliseconds ~/ 2),
      () {
        if (!mounted) return;
        setState(() {
          _hobby = _pendingHobby!;
          _pendingHobby = null;
        });
        HapticFeedback.mediumImpact();
      },
    );
  }

  void _tryThis() {
    HapticFeedback.lightImpact();
    final id = _hobby.id;
    Navigator.of(context, rootNavigator: true).pop();
    // Push detail after pop so the back stack reads naturally.
    Future<void>.microtask(() {
      if (context.mounted) {
        context.push('/hobby/$id');
      }
    });
  }

  void _dismiss() {
    HapticFeedback.selectionClick();
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: GestureDetector(
          onTap: _dismiss,
          behavior: HitTestBehavior.opaque,
          child: Stack(
            children: [
              // Animated backdrop blur for the full-screen scrim.
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: widget.entrance,
                  builder: (context, _) {
                    final t = Curves.easeOutCubic
                        .transform(widget.entrance.value.clamp(0.0, 1.0));
                    return BackdropFilter(
                      filter: ui.ImageFilter.blur(
                        sigmaX: 12 * t,
                        sigmaY: 12 * t,
                      ),
                      child: const SizedBox.expand(),
                    );
                  },
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Center(
                    child: GestureDetector(
                      // Absorb taps on the card itself so the scrim dismiss
                      // only fires for outside-the-card taps.
                      onTap: () {},
                      child: AnimatedBuilder(
                        animation: Listenable.merge(
                            [_flipController, widget.entrance]),
                        builder: (context, _) {
                          final flip = _flipController.value;
                          // Half-rotation either side of pi.
                          final angle = flip * math.pi;
                          // Flip the content the moment we cross the spine
                          // so the back of the card is the new hobby, never
                          // a mirrored version of the old one.
                          final showFront = flip < 0.5;
                          return Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001) // perspective
                              ..rotateY(showFront ? angle : angle - math.pi),
                            child: Opacity(
                              opacity: widget.entrance.value,
                              child: Transform.scale(
                                scale: 0.92 +
                                    Curves.easeOutCubic
                                            .transform(widget.entrance.value) *
                                        0.08,
                                child: _RevealCard(
                                  hobby: _hobby,
                                  onTryThis: _tryThis,
                                  onShuffle: _shuffleAgain,
                                  onDismiss: _dismiss,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RevealCard extends StatelessWidget {
  final Hobby hobby;
  final VoidCallback onTryThis;
  final VoidCallback onShuffle;
  final VoidCallback onDismiss;

  const _RevealCard({
    required this.hobby,
    required this.onTryThis,
    required this.onShuffle,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360, maxHeight: 560),
      child: GlassCard(
        blur: true,
        padding: EdgeInsets.zero,
        borderRadius: 28,
        backgroundColor: AppColors.surface.withValues(alpha: 0.85),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            fit: StackFit.passthrough,
            children: [
              // Hobby image, fading into the card.
              SizedBox(
                height: 320,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: hobby.imageUrl,
                      fit: BoxFit.cover,
                      memCacheWidth: 720,
                      placeholder: (_, __) => Container(color: AppColors.sand),
                      errorWidget: (_, __, ___) => Container(
                        color: AppColors.sand,
                        child: Center(
                          child: Icon(
                            hobby.catIcon,
                            size: 56,
                            color: AppColors.warmGray,
                          ),
                        ),
                      ),
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0x00000000),
                            Color(0x66000000),
                            Color(0xCC000000),
                          ],
                          stops: [0.4, 0.75, 1.0],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Readability scrim covering the bottom half of the entire
              // card so title, hook, and CTAs stay legible regardless of
              // the underlying hobby image.
              const Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x00000000),
                          Color(0xB3000000),
                          Color(0xF2000000),
                        ],
                        stops: [0.5, 0.8, 1.0],
                      ),
                    ),
                  ),
                ),
              ),

              // Top-right close affordance.
              Positioned(
                top: 14,
                right: 14,
                child: GestureDetector(
                  onTap: onDismiss,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),

              // Body content.
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const SizedBox(height: 6),
                      Text(
                        hobby.title,
                        style: AppTypography.display.copyWith(
                          color: AppColors.textPrimary,
                          height: 1.1,
                        ),
                      )
                          .animate()
                          .fadeIn(
                              duration: Motion.normal,
                              delay: const Duration(milliseconds: 60))
                          .slideY(
                              begin: 0.2,
                              end: 0,
                              duration: Motion.slow,
                              curve: Motion.normalCurve),
                      const SizedBox(height: 10),
                      Text(
                        hobby.hook,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.body.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ).animate().fadeIn(
                          duration: Motion.normal,
                          delay: const Duration(milliseconds: 120)),
                      const SizedBox(height: Spacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: _PrimaryCta(
                              label: 'Try this',
                              onTap: onTryThis,
                            ),
                          ),
                          const SizedBox(width: 12),
                          _GhostCta(
                            label: 'Surprise me again',
                            onTap: onShuffle,
                          ),
                        ],
                      ).animate().fadeIn(
                          duration: Motion.normal,
                          delay: const Duration(milliseconds: 180)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrimaryCta extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PrimaryCta({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.coral,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.coral.withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Text(
          label,
          style: AppTypography.button.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}

class _GhostCta extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _GhostCta({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.glassBorder,
            width: 0.8,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.button.copyWith(color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
