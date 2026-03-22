import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../models/session.dart';

/// Manages the full lifecycle of an active hobby session.
///
/// Handles timer ticking (DateTime-based for background survival),
/// wakelock, haptic feedback at milestones, and phase transitions.
///
/// Auto-disposes when no widget is listening (session screen popped).
class SessionNotifier extends StateNotifier<SessionState?> {
  SessionNotifier() : super(null);

  Timer? _timer;
  Timer? _completionDelayTimer;
  DateTime? _timerStartTime;
  Duration _totalPauseDuration = Duration.zero;
  DateTime? _pauseStartTime;
  bool _halfwayHapticFired = false;
  bool _oneMinuteHapticFired = false;

  // ───────────────────────────────────────────────
  //  Session lifecycle
  // ───────────────────────────────────────────────

  /// Initialise a new session. Call from the session screen's initState.
  void startSession({
    required String hobbyId,
    required String hobbyTitle,
    required String hobbyCategory,
    required String stepId,
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
    state = SessionState(
      hobbyId: hobbyId,
      hobbyTitle: hobbyTitle,
      hobbyCategory: hobbyCategory,
      stepId: stepId,
      stepTitle: stepTitle,
      stepDescription: stepDescription,
      stepInstructions: stepInstructions,
      whatYouNeed: whatYouNeed,
      recommendedMinutes: recommendedMinutes,
      completionMode: completionMode,
      selectedMinutes: recommendedMinutes,
      nextStepTitle: nextStepTitle,
      completionMessage: completionMessage,
      coachTip: coachTip,
    );
    debugPrint('[Session] Started for "$hobbyTitle" — step "$stepTitle"');
  }

  /// Update the user's chosen session duration (from prepare phase).
  void selectDuration(int minutes) {
    state = state?.copyWith(selectedMinutes: minutes);
  }

  // ───────────────────────────────────────────────
  //  Timer
  // ───────────────────────────────────────────────

  /// Begin the countdown timer. Transitions to [SessionPhase.timer].
  void beginTimer() {
    if (state == null) return;

    _timerStartTime = DateTime.now();
    _totalPauseDuration = Duration.zero;
    _pauseStartTime = null;
    _halfwayHapticFired = false;
    _oneMinuteHapticFired = false;

    state = state!.copyWith(
      phase: SessionPhase.timer,
      isPaused: false,
      elapsedSeconds: 0,
    );

    WakelockPlus.enable();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());

    debugPrint('[Session] Timer started — ${state!.selectedMinutes} min');
  }

  void _tick() {
    if (state == null || state!.isPaused) return;

    final now = DateTime.now();
    final rawElapsed = now.difference(_timerStartTime!);
    final elapsed = rawElapsed - _totalPauseDuration;
    final elapsedSec = elapsed.inSeconds;
    final totalSec = state!.selectedMinutes * 60;

    if (elapsedSec >= totalSec) {
      _completeTimer();
      return;
    }

    state = state!.copyWith(elapsedSeconds: elapsedSec);

    // Milestone haptics
    if (!_halfwayHapticFired && elapsedSec >= totalSec ~/ 2) {
      _halfwayHapticFired = true;
      HapticFeedback.lightImpact();
    }
    if (!_oneMinuteHapticFired && elapsedSec >= totalSec - 60) {
      _oneMinuteHapticFired = true;
      HapticFeedback.lightImpact();
    }
  }

  void pauseTimer() {
    if (state == null || state!.isPaused) return;
    _pauseStartTime = DateTime.now();
    state = state!.copyWith(isPaused: true);
    debugPrint('[Session] Paused');
  }

  void resumeTimer() {
    if (state == null || !state!.isPaused) return;
    if (_pauseStartTime != null) {
      _totalPauseDuration += DateTime.now().difference(_pauseStartTime!);
      _pauseStartTime = null;
    }
    state = state!.copyWith(isPaused: false);
    debugPrint('[Session] Resumed');
  }

  /// End session early from the pause menu. Step is NOT completed.
  void endTimerEarly() {
    debugPrint('[Session] Ended early');
    _cleanup();
    state = null;
  }

  void _completeTimer() {
    _timer?.cancel();
    _timer = null;
    final totalSec = state!.selectedMinutes * 60;

    state = state!.copyWith(
      elapsedSeconds: totalSec,
      phase: SessionPhase.completing,
    );
    // Enhanced haptic alarm pattern
    HapticFeedback.mediumImpact();
    Future.delayed(
        const Duration(milliseconds: 200), () => HapticFeedback.lightImpact());
    Future.delayed(
        const Duration(milliseconds: 400), () => HapticFeedback.lightImpact());
    Future.delayed(
        const Duration(milliseconds: 600), () => HapticFeedback.mediumImpact());
    debugPrint('[Session] Timer complete — entering completion moment');

    // Hold on the completion moment for 2 seconds, then advance.
    _completionDelayTimer = Timer(const Duration(seconds: 5), () {
      if (state != null && state!.phase == SessionPhase.completing) {
        state = state!.copyWith(phase: SessionPhase.reflect);
        debugPrint('[Session] → Reflect phase');
      }
    });
  }

  /// DEV ONLY: Force-complete the timer to test the completion flow.
  void devForceComplete() {
    if (state == null) return;
    _completeTimer();
  }

  // ───────────────────────────────────────────────
  //  Reflection & completion
  // ───────────────────────────────────────────────

  /// Save the user's reflection and advance to the final complete phase.
  void submitReflection(
    ReflectionChoice choice, {
    String? journalText,
    String? photoPath,
  }) {
    state = state?.copyWith(
      reflection: choice,
      journalText: journalText,
      photoPath: photoPath,
      phase: SessionPhase.complete,
      isComplete: true,
    );
    debugPrint('[Session] Reflection submitted: ${choice.name}');

    // TODO(integration): Save journal entry via API
    // TODO(integration): POST step completion
    // TODO(integration): Update streak
    // TODO(integration): Fire analytics events
  }

  /// Skip reflection — still mark complete, just no journal data.
  void skipReflection() {
    state = state?.copyWith(
      phase: SessionPhase.complete,
      isComplete: true,
    );
    debugPrint('[Session] Reflection skipped');
  }

  /// Called when the complete-phase auto-exit finishes.
  void completeSession() {
    debugPrint('[Session] Session fully complete');
    _cleanup();
    state = null;
  }

  // ───────────────────────────────────────────────
  //  Cleanup
  // ───────────────────────────────────────────────

  void _cleanup() {
    _timer?.cancel();
    _timer = null;
    _completionDelayTimer?.cancel();
    _completionDelayTimer = null;
    WakelockPlus.disable();
  }

  @override
  void dispose() {
    _cleanup();
    super.dispose();
  }
}

/// Provider for the active session.
///
/// Returns `null` when no session is active. Auto-disposes when the
/// session screen is removed from the widget tree.
final sessionProvider =
    StateNotifierProvider.autoDispose<SessionNotifier, SessionState?>((ref) {
  final notifier = SessionNotifier();
  ref.onDispose(notifier.dispose);
  return notifier;
});
