import 'package:freezed_annotation/freezed_annotation.dart';

part 'session.freezed.dart';

/// How a roadmap step is completed during a session.
enum CompletionMode { timer, photoProof, checkIn }

/// User's reflection after completing a timed session.
enum ReflectionChoice { lovedIt, okay, struggled }

/// Which phase of the session flow the user is in.
enum SessionPhase { prepare, timer, completing, reflect, complete }

/// Immutable state for an active hobby session.
///
/// Managed by [SessionNotifier]. The session screen reads this to
/// determine which phase widget to render and what data to display.
@freezed
class SessionState with _$SessionState {
  const factory SessionState({
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
    @Default(SessionPhase.prepare) SessionPhase phase,
    @Default(15) int selectedMinutes,
    @Default(0) int elapsedSeconds,
    @Default(false) bool isPaused,
    @Default(false) bool isComplete,
    ReflectionChoice? reflection,
    String? journalText,
    String? photoPath,
    String? nextStepTitle,
  }) = _SessionState;
}
