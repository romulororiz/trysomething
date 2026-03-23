import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../router.dart' show rootNavigatorKey;
import '../../components/cinematic_scaffold.dart';
import '../../components/glass_card.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/spacing.dart';

/// Full-screen celebration shown when a user completes their final roadmap step.
///
/// Replaces the generic step-complete phase with a warm, animated celebration.
/// No auto-exit timer -- user must tap the CTA to leave.
class HobbyCompletionScreen extends ConsumerWidget {
  final String hobbyId;
  final String hobbyTitle;

  const HobbyCompletionScreen({
    super.key,
    required this.hobbyId,
    required this.hobbyTitle,
  });

  /// Custom page route with cinematic fade transition (matches SessionScreen.route pattern).
  static Route<void> route({
    required String hobbyId,
    required String hobbyTitle,
  }) {
    return PageRouteBuilder(
      opaque: true,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => HobbyCompletionScreen(
        hobbyId: hobbyId,
        hobbyTitle: hobbyTitle,
      ),
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hobbies = ref.watch(userHobbiesProvider);
    final userHobby = hobbies[hobbyId];

    final stepsCompleted = userHobby?.completedStepIds.length ?? 0;
    final daysActive = userHobby?.startedAt != null
        ? DateTime.now().difference(userHobby!.startedAt!).inDays
        : 0;
    final streakDays = userHobby?.streakDays ?? 0;

    return CinematicScaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // 1. Animated checkmark
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 80,
              )
                  .animate()
                  .scale(
                    begin: const Offset(0.5, 0.5),
                    duration: 600.ms,
                    curve: Curves.elasticOut,
                  )
                  .fadeIn(duration: 300.ms),

              const SizedBox(height: 24),

              // 2. "HOBBY COMPLETE" overline
              Text(
                'HOBBY COMPLETE',
                style: AppTypography.overline,
              ).animate().fadeIn(duration: 300.ms, delay: 400.ms),

              const SizedBox(height: 12),

              // 3. Hobby title
              Text(
                hobbyTitle,
                style: AppTypography.display,
                textAlign: TextAlign.center,
              ).animate().fadeIn(duration: 300.ms, delay: 600.ms),

              const SizedBox(height: 20),

              // 4. Warm message
              Text(
                'You showed up, stayed curious, and made it yours. That takes something special.',
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(duration: 300.ms, delay: 800.ms),

              const SizedBox(height: 32),

              // 5. Stats row in a GlassCard
              GlassCard(
                blur: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatColumn(
                      value: '$stepsCompleted',
                      label: 'Steps',
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: AppColors.textWhisper,
                    ),
                    _StatColumn(
                      value: '$daysActive',
                      label: 'Days',
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: AppColors.textWhisper,
                    ),
                    _StatColumn(
                      value: '$streakDays',
                      label: 'Streak',
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms, delay: 1000.ms),

              const Spacer(flex: 1),

              // 6. Bottom coral CTA
              SizedBox(
                width: double.infinity,
                height: Spacing.buttonCtaHeight,
                child: ElevatedButton(
                  onPressed: () {
                    // Pop this full-screen overlay from the root navigator
                    rootNavigatorKey.currentState?.pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        Spacing.radiusButton,
                      ),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Discover your next hobby',
                    style: AppTypography.button,
                  ),
                ),
              ).animate().fadeIn(duration: 300.ms, delay: 1200.ms),

              const SizedBox(height: Spacing.scrollBottomPadding),
            ],
          ),
        ),
      ),
    );
  }
}

/// Single stat column: large number + small label.
class _StatColumn extends StatelessWidget {
  final String value;
  final String label;

  const _StatColumn({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: AppTypography.dataLarge.copyWith(fontSize: 32),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.caption,
        ),
      ],
    );
  }
}
