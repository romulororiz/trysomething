import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../components/breathing_ring.dart';
import '../../models/session.dart';
import '../../models/social.dart';
import '../../providers/feature_providers.dart';
import '../../providers/session_provider.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_colors.dart';
import 'session_prepare_phase.dart';
import 'session_reflect_phase.dart';
import 'session_timer_phase.dart';

/// Full-screen immersive session experience.
///
/// Takes over the entire screen — no app bar, no bottom nav.
/// Manages four phases internally via [SessionNotifier]:
///   prepare -> timer -> completing -> reflect -> complete
///
/// Renders a 5-layer cinematic Stack:
///   1. Breathing background (subtle pulse synced with ring)
///   2. Ambient gradient spotlight (radial coral at 4%)
///   3. Film grain overlay (cinematic warmth)
///   4. Breathing ring (the visual constant across all phases)
///   5. Phase content (AnimatedSwitcher)
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
  final String? completionMessage;
  final String? coachTip;

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
    this.completionMessage,
    this.coachTip,
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
    String? completionMessage,
    String? coachTip,
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
        completionMessage: completionMessage,
        coachTip: coachTip,
      ),
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  @override
  ConsumerState<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends ConsumerState<SessionScreen>
    with SingleTickerProviderStateMixin {
  /// Key to access BreathingRing's triggerMilestonePulse() method (D-23).
  final _ringKey = GlobalKey<BreathingRingState>();

  /// Tracks whether the halfway milestone pulse has been fired (D-23).
  bool _halfwayPulseFired = false;

  /// Ticker for smooth 60fps progress interpolation (Issue 4).
  late final Ticker _progressTicker;

  /// Smoothly interpolated progress value updated every frame.
  double _smoothProgress = 0.0;

  /// Timestamp of the last provider elapsedSeconds snapshot.
  int _lastElapsedSeconds = 0;

  /// DateTime when we last received a new elapsedSeconds value.
  DateTime _lastTickTime = DateTime.now();

  @override
  void initState() {
    super.initState();

    _progressTicker = createTicker(_onProgressTick);
    _progressTicker.start();

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
            completionMessage: widget.completionMessage,
            coachTip: widget.coachTip,
          );
    });
  }

  @override
  void dispose() {
    _progressTicker.dispose();
    super.dispose();
  }

  /// Called every frame by the Ticker for smooth progress interpolation.
  void _onProgressTick(Duration elapsed) {
    final session = ref.read(sessionProvider);
    if (session == null) return;

    if (session.phase == SessionPhase.timer && !session.isPaused) {
      final total = session.selectedMinutes * 60;
      if (total <= 0) return;

      // Track when provider seconds change for interpolation base
      if (session.elapsedSeconds != _lastElapsedSeconds) {
        _lastElapsedSeconds = session.elapsedSeconds;
        _lastTickTime = DateTime.now();
      }

      // Interpolate sub-second fraction from the last integer tick
      final sinceLastTick =
          DateTime.now().difference(_lastTickTime).inMicroseconds /
              Duration.microsecondsPerSecond;
      final fractionalElapsed = session.elapsedSeconds + sinceLastTick;
      final newProgress = (fractionalElapsed / total).clamp(0.0, 1.0);

      if ((newProgress - _smoothProgress).abs() > 0.0001) {
        setState(() => _smoothProgress = newProgress);
      }
    }
  }

  double _computeProgress(SessionState session) {
    if (session.phase == SessionPhase.prepare) {
      return 0.0;
    }
    if (session.phase == SessionPhase.completing ||
        session.phase == SessionPhase.reflect ||
        session.phase == SessionPhase.complete) {
      return 1.0;
    }
    // During timer phase, return the smooth 60fps-interpolated value
    if (session.phase == SessionPhase.timer) {
      return _smoothProgress;
    }
    final total = session.selectedMinutes * 60;
    if (total <= 0) {
      return 0.0;
    }
    return (session.elapsedSeconds / total).clamp(0.0, 1.0);
  }

  /// Persist a session reflection as a journal entry (fire and forget).
  ///
  /// Prefixes the text with a reflection emoji so the journal UI can
  /// identify session-sourced entries later.
  void _saveSessionJournal({
    required String hobbyId,
    required ReflectionChoice choice,
    required String journalText,
  }) {
    final emoji = switch (choice) {
      ReflectionChoice.lovedIt => '\u2764\uFE0F',   // ❤️
      ReflectionChoice.okay    => '\uD83D\uDC4C',   // 👌
      ReflectionChoice.struggled => '\u2601\uFE0F',  // ☁️
    };
    final label = switch (choice) {
      ReflectionChoice.lovedIt   => 'Loved it',
      ReflectionChoice.okay      => 'It was okay',
      ReflectionChoice.struggled => 'Struggled',
    };
    final prefixedText = '$emoji $label — $journalText';

    final entry = JournalEntry(
      id: 'j_${DateTime.now().millisecondsSinceEpoch}',
      hobbyId: hobbyId,
      text: prefixedText,
      createdAt: DateTime.now(),
    );

    // Optimistic add via the journal notifier (also calls API)
    ref.read(journalProvider.notifier).addEntry(entry);
    debugPrint('[Session] Journal entry saved for hobby $hobbyId');
  }

  void _exitSession() {
    final session = ref.read(sessionProvider);
    // Mark step complete in user state if session finished successfully
    if (session != null && session.isComplete) {
      ref
          .read(userHobbiesProvider.notifier)
          .toggleStep(session.hobbyId, session.stepId);
    }
    ref.read(sessionProvider.notifier).completeSession();
    if (mounted) Navigator.of(context).maybePop();
  }

  // ═══════════════════════════════════════════════════════
  //  BREATHING RING HELPERS
  // ═══════════════════════════════════════════════════════

  /// Breathing cycle duration adapts to session state (D-10, D-11, D-12).
  Duration _breathCycleDuration(SessionState session) {
    if (session.isPaused) return const Duration(milliseconds: 8000); // D-11
    final remaining = session.selectedMinutes * 60 - session.elapsedSeconds;
    if (session.phase == SessionPhase.timer &&
        remaining > 0 &&
        remaining < 60) {
      return const Duration(milliseconds: 3000); // D-12
    }
    return const Duration(milliseconds: 4000); // D-10
  }

  /// Ring opacity per phase:
  /// - prepare: barely visible (0.12) — subtle preview behind content
  /// - timer: full (1.0), dimmed when paused (0.4)
  /// - completing/reflect/complete: hidden (0.0)
  double _ringOpacity(SessionState session) {
    switch (session.phase) {
      case SessionPhase.prepare:
        return 0.0;
      case SessionPhase.timer:
        return session.isPaused ? 0.4 : 1.0;
      case SessionPhase.completing:
      case SessionPhase.reflect:
      case SessionPhase.complete:
        return 0.0;
    }
  }

  /// Glow intensity increases during last minute (D-24).
  double _glowIntensity(SessionState session) {
    final remaining = session.selectedMinutes * 60 - session.elapsedSeconds;
    if (session.phase == SessionPhase.timer &&
        remaining > 0 &&
        remaining < 60) {
      return 0.25; // D-24: intensified glow in last minute
    }
    return 0.15; // Default
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

    // Milestone pulse: trigger at 50% progress (D-23)
    final progress = _computeProgress(session);
    if (progress >= 0.5 &&
        !_halfwayPulseFired &&
        session.phase == SessionPhase.timer) {
      _halfwayPulseFired = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _ringKey.currentState?.triggerMilestonePulse();
      });
    }
    // Reset flag when returning to prepare
    if (session.phase == SessionPhase.prepare) _halfwayPulseFired = false;

    final breathDuration = _breathCycleDuration(session);

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
            // Layer 1: Breathing background (D-09)
            // Subtle pulse between #0A0A0F and #0F0F14 synced with ring
            Positioned.fill(
              child: _BreathingBackground(
                cycleDuration: breathDuration,
                active: session.phase != SessionPhase.prepare,
              ),
            ),

            // Layer 2: Ambient gradient spotlight (D-07)
            // Soft radial gradient centered on ring, coral at 4% opacity
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0, -0.16), // ~42% from top
                      radius: 0.5,
                      colors: [
                        AppColors.accent.withValues(alpha: 0.04),
                        AppColors.accent.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Layer 3: Film grain overlay REMOVED (Issue 2)

            // Layer 4: Breathing ring (D-01 through D-05)
            // Only visible during prepare, timer, and completing phases (Issue 5)
            // Positioned at ~42% from top (D-03), centered horizontally
            Positioned(
              top: MediaQuery.of(context).size.height * 0.42 - 135,
              left: 0,
              right: 0,
              child: Center(
                child: IgnorePointer(
                  child: AnimatedOpacity(
                    opacity: _ringOpacity(session),
                    duration: const Duration(milliseconds: 400),
                    child: BreathingRing(
                      key: _ringKey,
                      progress: progress,
                      breathCycleDuration: breathDuration,
                      glowIntensity: _glowIntensity(session),
                      ringOpacity: 1.0, // AnimatedOpacity handles dimming
                      ringSize: 270, // D-03: ~260-280dp
                    ),
                  ),
                ),
              ),
            ),

            // Layer 5: Phase content (same AnimatedSwitcher as before)
            Positioned.fill(
              child: SafeArea(
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
          onDevComplete: notifier.devForceComplete,
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

            // Save journal entry via API (fire and forget)
            if (journalText != null && journalText.trim().isNotEmpty) {
              _saveSessionJournal(
                hobbyId: session.hobbyId,
                choice: choice,
                journalText: journalText.trim(),
              );
            }

            _exitSession();
          },
          onSkip: () {
            notifier.skipReflection();
            _exitSession();
          },
        );

      case SessionPhase.complete:
        // After reflect, go straight home — completion was already shown
        // during the "completing" phase in the timer.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _exitSession();
        });
        return const SizedBox.shrink();
    }
  }
}

// ═══════════════════════════════════════════════════════
//  BREATHING BACKGROUND — subtle pulse synced with ring (D-09)
// ═══════════════════════════════════════════════════════

/// Continuously oscillates between #0A0A0F and #0F0F14 using
/// [TweenAnimationBuilder] with onEnd to toggle direction.
class _BreathingBackground extends StatefulWidget {
  final Duration cycleDuration;
  final bool active;

  const _BreathingBackground({
    required this.cycleDuration,
    required this.active,
  });

  @override
  State<_BreathingBackground> createState() => _BreathingBackgroundState();
}

class _BreathingBackgroundState extends State<_BreathingBackground> {
  bool _brightPhase = false;

  @override
  Widget build(BuildContext context) {
    final target = widget.active ? (_brightPhase ? 1.0 : 0.0) : 0.0;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: target),
      duration: widget.cycleDuration,
      curve: Curves.easeInOut,
      onEnd: () {
        if (widget.active) {
          setState(() => _brightPhase = !_brightPhase);
        }
      },
      builder: (context, value, _) {
        return Container(
          color: Color.lerp(
            const Color(0xFF0A0A0F),
            const Color(0xFF0F0F14),
            value,
          ),
        );
      },
    );
  }
}
