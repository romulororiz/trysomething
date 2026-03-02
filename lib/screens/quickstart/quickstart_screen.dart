import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/hobby_provider.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_icons.dart';
import '../../theme/app_typography.dart';
import '../../theme/spacing.dart';
import '../../theme/motion.dart';

/// First-30-minutes quickstart: timer, task checklist, progress bar.
class QuickstartScreen extends ConsumerStatefulWidget {
  final String hobbyId;

  const QuickstartScreen({super.key, required this.hobbyId});

  @override
  ConsumerState<QuickstartScreen> createState() => _QuickstartScreenState();
}

class _QuickstartScreenState extends ConsumerState<QuickstartScreen> {
  int _seconds = 30 * 60;
  bool _running = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleTimer() {
    if (_running) {
      _timer?.cancel();
      setState(() => _running = false);
    } else {
      setState(() => _running = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() {
          if (_seconds <= 1) {
            _seconds = 0;
            _running = false;
            _timer?.cancel();
          } else {
            _seconds--;
          }
        });
      });
    }
  }

  String get _formattedTime {
    final min = _seconds ~/ 60;
    final sec = _seconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final hobby = ref.watch(hobbyByIdProvider(widget.hobbyId)).valueOrNull;
    if (hobby == null) return const SizedBox.shrink();

    final steps = hobby.roadmapSteps.take(3).toList();
    final userHobbies = ref.watch(userHobbiesProvider);
    final userHobby = userHobbies[widget.hobbyId];
    final completedSteps = userHobby?.completedStepIds ?? <String>{};
    final progress = steps.isEmpty ? 0.0 : completedSteps.length / steps.length;
    final allDone = completedSteps.length >= steps.length;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Icon(AppIcons.close,
                          size: 22, color: AppColors.nearBlack),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          hobby.title,
                          style: AppTypography.sansLabel.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 36), // balance the close button
                  ],
                ),
              ),

              // Title
              Text('First 30\nMinutes', style: AppTypography.serifTitle),
              const SizedBox(height: 4),
              Text(
                'Complete these steps to get started. No pressure.',
                style: AppTypography.sansBodySmall.copyWith(color: AppColors.driftwood),
              ),
              const SizedBox(height: 20),

              // Timer
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.sand,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formattedTime,
                      style: AppTypography.monoTimer.copyWith(
                        color: _running ? AppColors.coral : AppColors.warmGray,
                      ),
                    ),
                    GestureDetector(
                      onTap: _toggleTimer,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _running ? AppColors.coralPale : AppColors.sand,
                        ),
                        child: Center(
                          child: Icon(
                            _running ? AppIcons.pause : AppIcons.play,
                            size: 20,
                            color: _running ? AppColors.coral : AppColors.driftwood,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Progress bar
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(Spacing.radiusBadge),
                      child: SizedBox(
                        height: 6,
                        child: Stack(
                          children: [
                            Container(color: AppColors.sandDark),
                            AnimatedFractionallySizedBox(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeOutCubic,
                              widthFactor: progress.clamp(0.0, 1.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.coral,
                                  borderRadius: BorderRadius.circular(Spacing.radiusBadge),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${completedSteps.length}/${steps.length}',
                    style: AppTypography.monoMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.coral,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Task list
              Expanded(
                child: ListView.separated(
                  itemCount: steps.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final step = steps[index];
                    final isDone = completedSteps.contains(step.id);

                    return GestureDetector(
                      onTap: () {
                        ref.read(userHobbiesProvider.notifier).toggleStep(
                          widget.hobbyId, step.id,
                        );
                      },
                      child: AnimatedContainer(
                        duration: Motion.normal,
                        curve: Motion.normalCurve,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDone ? AppColors.coralPale : AppColors.warmWhite,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            // Checkbox
                            AnimatedContainer(
                              duration: Motion.fast,
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDone ? AppColors.coral : Colors.transparent,
                                border: Border.all(
                                  width: 2,
                                  color: isDone ? AppColors.coral : AppColors.stone,
                                ),
                              ),
                              child: isDone
                                  ? const Center(
                                      child: Icon(Icons.check,
                                          color: Colors.white,
                                          size: 16),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 14),

                            // Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AnimatedDefaultTextStyle(
                                    duration: Motion.fast,
                                    style: AppTypography.sansBody.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: isDone ? AppColors.warmGray : AppColors.nearBlack,
                                      decoration:
                                          isDone ? TextDecoration.lineThrough : TextDecoration.none,
                                    ),
                                    child: Text(step.title),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '~${step.estimatedMinutes} min',
                                    style: AppTypography.monoTiny.copyWith(color: AppColors.warmGray),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Celebration banner (when all done)
              if (allDone) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.indigo, AppColors.indigoDeep],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(AppIcons.trophy, size: 28, color: AppColors.amber),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nice work!',
                              style: AppTypography.sansLabel.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.coral,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'You completed your first ${hobby.title} session.',
                              style: AppTypography.sansCaption.copyWith(
                                color: AppColors.driftwood,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Bottom button
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: allDone ? Spacing.buttonPrimaryHeight : Spacing.buttonSecondaryHeight,
                child: allDone
                    ? ElevatedButton(
                        onPressed: () => context.pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.coral,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(Spacing.radiusButton),
                          ),
                        ),
                        child: Text('NEXT STEP →', style: AppTypography.sansCta),
                      )
                    : OutlinedButton(
                        onPressed: () => context.pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.coral,
                          side: BorderSide(color: AppColors.coral.withValues(alpha: 0.25)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(Spacing.radiusButton),
                          ),
                        ),
                        child: Text('Skip for now →', style: AppTypography.sansCtaSecondary),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Animated fractionally sized box for progress bar
class AnimatedFractionallySizedBox extends ImplicitlyAnimatedWidget {
  final double widthFactor;
  final Widget child;

  const AnimatedFractionallySizedBox({
    super.key,
    required this.widthFactor,
    required this.child,
    required super.duration,
    super.curve,
  });

  @override
  AnimatedWidgetBaseState<AnimatedFractionallySizedBox> createState() =>
      _AnimatedFractionallySizedBoxState();
}

class _AnimatedFractionallySizedBoxState
    extends AnimatedWidgetBaseState<AnimatedFractionallySizedBox> {
  Tween<double>? _widthFactor;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _widthFactor = visitor(
      _widthFactor,
      widget.widthFactor,
      (dynamic value) => Tween<double>(begin: value as double),
    ) as Tween<double>?;
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: _widthFactor?.evaluate(animation) ?? widget.widthFactor,
      alignment: Alignment.centerLeft,
      child: widget.child,
    );
  }
}
