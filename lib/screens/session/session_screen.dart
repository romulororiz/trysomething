import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../components/category_shape_painter.dart';
import '../../components/session_glow_widget.dart';
import '../../models/session.dart';
import '../../providers/session_provider.dart';
import '../../theme/app_colors.dart';
import 'session_complete_phase.dart';
import 'session_prepare_phase.dart';
import 'session_reflect_phase.dart';
import 'session_timer_phase.dart';

/// Full-screen immersive session experience.
///
/// Takes over the entire screen — no app bar, no bottom nav.
/// Manages four phases internally via [SessionNotifier]:
///   prepare → timer → completing → reflect → complete
///
/// Entry/exit transitions are handled by the route's [PageRouteBuilder].
/// For now, use [SessionScreen.route] to get the custom route.
class SessionScreen extends ConsumerStatefulWidget {
  final String hobbyId;
  final String stepId;
  final String hobbyTitle;
  final String hobbyCategory;
  final String stepTitle;
  final String stepDescription;
  final String stepInstructions;
  final String whatYouNeed;
  final int recommendedMinutes;
  final CompletionMode completionMode;
  final String? nextStepTitle;

  const SessionScreen({
    super.key,
    required this.hobbyId,
    required this.stepId,
    required this.hobbyTitle,
    required this.hobbyCategory,
    required this.stepTitle,
    required this.stepDescription,
    required this.stepInstructions,
    required this.whatYouNeed,
    required this.recommendedMinutes,
    required this.completionMode,
    this.nextStepTitle,
  });

  /// Custom page route with cinematic fade transition.
  static Route<void> route({
    required String hobbyId,
    required String stepId,
    required String hobbyTitle,
    required String hobbyCategory,
    required String stepTitle,
    required String stepDescription,
    required String stepInstructions,
    required String whatYouNeed,
    required int recommendedMinutes,
    required CompletionMode completionMode,
    String? nextStepTitle,
  }) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 500),
      reverseTransitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) => SessionScreen(
        hobbyId: hobbyId,
        stepId: stepId,
        hobbyTitle: hobbyTitle,
        hobbyCategory: hobbyCategory,
        stepTitle: stepTitle,
        stepDescription: stepDescription,
        stepInstructions: stepInstructions,
        whatYouNeed: whatYouNeed,
        recommendedMinutes: recommendedMinutes,
        completionMode: completionMode,
        nextStepTitle: nextStepTitle,
      ),
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  @override
  ConsumerState<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends ConsumerState<SessionScreen> {
  @override
  void initState() {
    super.initState();
    // Initialise the session in the provider.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sessionProvider.notifier).startSession(
            hobbyId: widget.hobbyId,
            stepId: widget.stepId,
            hobbyTitle: widget.hobbyTitle,
            hobbyCategory: widget.hobbyCategory,
            stepTitle: widget.stepTitle,
            stepDescription: widget.stepDescription,
            stepInstructions: widget.stepInstructions,
            whatYouNeed: widget.whatYouNeed,
            recommendedMinutes: widget.recommendedMinutes,
            completionMode: widget.completionMode,
            nextStepTitle: widget.nextStepTitle,
          );
    });
  }

  void _exitSession() {
    ref.read(sessionProvider.notifier).completeSession();
    if (mounted) Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);

    // Guard: provider not yet initialised
    if (session == null) {
      return const Scaffold(backgroundColor: AppColors.background);
    }

    final isTimerActive =
        session.phase == SessionPhase.timer && !session.isPaused;

    return PopScope(
      canPop: !isTimerActive,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && isTimerActive) {
          // During active timer, back gesture is blocked.
          // User must pause first, then "End session early".
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            // Layer 1: Ambient category shape
            Positioned.fill(
              child: CategoryShape(category: session.hobbyCategory),
            ),

            // Layer 2: Warm radial glow
            Positioned.fill(
              child: SessionGlow(
                active: session.phase != SessionPhase.prepare,
              ),
            ),

            // Layer 3: Phase content
            SafeArea(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween(
                        begin: const Offset(0, 0.03),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: _buildPhase(session),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhase(SessionState session) {
    final notifier = ref.read(sessionProvider.notifier);

    switch (session.phase) {
      case SessionPhase.prepare:
        return SessionPreparePhase(
          key: const ValueKey('prepare'),
          session: session,
          onSelectDuration: notifier.selectDuration,
          onReady: notifier.beginTimer,
          onCancel: () => Navigator.of(context).maybePop(),
        );

      case SessionPhase.timer:
      case SessionPhase.completing:
        return SessionTimerPhase(
          key: const ValueKey('timer'),
          session: session,
          onPause: notifier.pauseTimer,
          onResume: notifier.resumeTimer,
          onEndEarly: notifier.endTimerEarly,
          onEndEarlyExit: () {
            if (mounted) Navigator.of(context).maybePop();
          },
        );

      case SessionPhase.reflect:
        return SessionReflectPhase(
          key: const ValueKey('reflect'),
          session: session,
          onSubmit: (choice, {String? journalText, String? photoPath}) {
            notifier.submitReflection(
              choice,
              journalText: journalText,
              photoPath: photoPath,
            );
          },
          onSkip: notifier.skipReflection,
        );

      case SessionPhase.complete:
        return SessionCompletePhase(
          key: const ValueKey('complete'),
          session: session,
          onExit: _exitSession,
        );
    }
  }
}
