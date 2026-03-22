import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:trysomething/providers/session_provider.dart';
import 'package:trysomething/models/session.dart';

// ---------------------------------------------------------------------------
// Helper — builds a minimal valid SessionState for direct state inspection.
// ---------------------------------------------------------------------------
SessionState _baseState({
  String hobbyId = 'h1',
  String hobbyTitle = 'Watercolor',
  String hobbyCategory = 'art',
  String stepId = 's1',
  String stepTitle = 'First brushstroke',
  String stepDescription = 'desc',
  String stepInstructions = 'instructions',
  String whatYouNeed = 'brushes',
  int recommendedMinutes = 30,
  CompletionMode completionMode = CompletionMode.timer,
}) =>
    SessionState(
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
    );

// ---------------------------------------------------------------------------
// Thin helper that calls startSession with the same defaults as _baseState.
// ---------------------------------------------------------------------------
void _startSession(
  SessionNotifier notifier, {
  int recommendedMinutes = 30,
  CompletionMode completionMode = CompletionMode.timer,
  String? nextStepTitle,
  String? completionMessage,
  String? coachTip,
}) {
  notifier.startSession(
    hobbyId: 'h1',
    hobbyTitle: 'Watercolor',
    hobbyCategory: 'art',
    stepId: 's1',
    stepTitle: 'First brushstroke',
    stepDescription: 'desc',
    stepInstructions: 'instructions',
    whatYouNeed: 'brushes',
    recommendedMinutes: recommendedMinutes,
    completionMode: completionMode,
    nextStepTitle: nextStepTitle,
    completionMessage: completionMessage,
    coachTip: coachTip,
  );
}

void main() {
  // Initialize binding so platform channel calls don't throw.
  TestWidgetsFlutterBinding.ensureInitialized();

  // Stub WakelockPlus pigeon channel so enable/disable are no-ops in tests.
  // Must be set directly in main() (not setUp) so it is present before any
  // test runs and outlives individual tearDowns.
  // Pigeon StandardMessageCodec success response: list([null]) = [0x0c, 1, 0].
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler(
    'dev.flutter.pigeon.wakelock_plus_platform_interface.WakelockPlusApi.toggle',
    (_) async => ByteData.sublistView(Uint8List.fromList([0x0c, 1, 0])),
  );

  late SessionNotifier notifier;

  setUp(() => notifier = SessionNotifier());

  // ─────────────────────────────────────────────────────────────────────────
  // Initial state
  // ─────────────────────────────────────────────────────────────────────────

  group('initial state', () {
    test('is null before any session is started', () {
      expect(notifier.state, isNull);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // startSession
  // ─────────────────────────────────────────────────────────────────────────

  group('startSession', () {
    test('sets state with phase=prepare and correct fields', () {
      _startSession(notifier, recommendedMinutes: 30, nextStepTitle: 'Second stroke');

      final s = notifier.state;
      expect(s, isNotNull);
      expect(s!.hobbyId, 'h1');
      expect(s.hobbyTitle, 'Watercolor');
      expect(s.hobbyCategory, 'art');
      expect(s.stepId, 's1');
      expect(s.stepTitle, 'First brushstroke');
      expect(s.stepDescription, 'desc');
      expect(s.stepInstructions, 'instructions');
      expect(s.whatYouNeed, 'brushes');
      expect(s.recommendedMinutes, 30);
      expect(s.completionMode, CompletionMode.timer);
      expect(s.nextStepTitle, 'Second stroke');
      expect(s.phase, SessionPhase.prepare);
    });

    test('sets selectedMinutes equal to recommendedMinutes', () {
      _startSession(notifier, recommendedMinutes: 45);
      expect(notifier.state!.selectedMinutes, 45);
    });

    test('initialises elapsed, isPaused, and isComplete to defaults', () {
      _startSession(notifier);
      final s = notifier.state!;
      expect(s.elapsedSeconds, 0);
      expect(s.isPaused, false);
      expect(s.isComplete, false);
      expect(s.reflection, isNull);
      expect(s.journalText, isNull);
      expect(s.photoPath, isNull);
    });

    test('replaces previous state when called a second time', () {
      _startSession(notifier, recommendedMinutes: 20);
      expect(notifier.state!.recommendedMinutes, 20);

      _startSession(notifier, recommendedMinutes: 60);
      expect(notifier.state!.recommendedMinutes, 60);
      expect(notifier.state!.selectedMinutes, 60);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // selectDuration
  // ─────────────────────────────────────────────────────────────────────────

  group('selectDuration', () {
    test('updates selectedMinutes when state is not null', () {
      _startSession(notifier, recommendedMinutes: 30);
      notifier.selectDuration(15);
      expect(notifier.state!.selectedMinutes, 15);
    });

    test('is a no-op when state is null', () {
      notifier.selectDuration(20);
      expect(notifier.state, isNull);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // pauseTimer / resumeTimer
  // ─────────────────────────────────────────────────────────────────────────

  group('pauseTimer', () {
    test('sets isPaused=true when state is non-null and not already paused', () {
      _startSession(notifier);
      expect(notifier.state!.isPaused, false);

      notifier.pauseTimer();

      expect(notifier.state!.isPaused, true);
    });

    test('is a no-op when state is null', () {
      // Should not throw.
      notifier.pauseTimer();
      expect(notifier.state, isNull);
    });

    test('is a no-op when already paused', () {
      _startSession(notifier);
      notifier.pauseTimer(); // first pause
      notifier.pauseTimer(); // second call — should be ignored
      expect(notifier.state!.isPaused, true);
    });
  });

  group('resumeTimer', () {
    test('sets isPaused=false after pauseTimer was called', () {
      _startSession(notifier);
      notifier.pauseTimer();
      expect(notifier.state!.isPaused, true);

      notifier.resumeTimer();
      expect(notifier.state!.isPaused, false);
    });

    test('is a no-op when state is null', () {
      notifier.resumeTimer();
      expect(notifier.state, isNull);
    });

    test('is a no-op when not paused', () {
      _startSession(notifier);
      expect(notifier.state!.isPaused, false);
      // Calling resume when not paused should not throw or change state.
      notifier.resumeTimer();
      expect(notifier.state!.isPaused, false);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // endTimerEarly
  // ─────────────────────────────────────────────────────────────────────────

  group('endTimerEarly', () {
    test('sets state to null', () {
      _startSession(notifier);
      expect(notifier.state, isNotNull);

      notifier.endTimerEarly();

      expect(notifier.state, isNull);
    });

    test('can be called when state is already null without error', () {
      expect(() => notifier.endTimerEarly(), returnsNormally);
      expect(notifier.state, isNull);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // submitReflection
  // ─────────────────────────────────────────────────────────────────────────

  group('submitReflection', () {
    test('sets phase=complete, isComplete=true, and stores reflection data', () {
      _startSession(notifier);
      notifier.submitReflection(
        ReflectionChoice.lovedIt,
        journalText: 'Great session!',
        photoPath: '/path/to/photo.jpg',
      );

      final s = notifier.state;
      expect(s, isNotNull);
      expect(s!.phase, SessionPhase.complete);
      expect(s.isComplete, true);
      expect(s.reflection, ReflectionChoice.lovedIt);
      expect(s.journalText, 'Great session!');
      expect(s.photoPath, '/path/to/photo.jpg');
    });

    test('works without optional journalText and photoPath', () {
      _startSession(notifier);
      notifier.submitReflection(ReflectionChoice.okay);

      final s = notifier.state!;
      expect(s.phase, SessionPhase.complete);
      expect(s.isComplete, true);
      expect(s.reflection, ReflectionChoice.okay);
      expect(s.journalText, isNull);
      expect(s.photoPath, isNull);
    });

    test('is a no-op when state is null', () {
      notifier.submitReflection(ReflectionChoice.struggled);
      expect(notifier.state, isNull);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // skipReflection
  // ─────────────────────────────────────────────────────────────────────────

  group('skipReflection', () {
    test('sets phase=complete and isComplete=true with no reflection data', () {
      _startSession(notifier);
      notifier.skipReflection();

      final s = notifier.state;
      expect(s, isNotNull);
      expect(s!.phase, SessionPhase.complete);
      expect(s.isComplete, true);
      expect(s.reflection, isNull);
      expect(s.journalText, isNull);
      expect(s.photoPath, isNull);
    });

    test('is a no-op when state is null', () {
      notifier.skipReflection();
      expect(notifier.state, isNull);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // completeSession
  // ─────────────────────────────────────────────────────────────────────────

  group('completeSession', () {
    test('sets state to null', () {
      _startSession(notifier);
      notifier.skipReflection(); // advance to complete phase
      expect(notifier.state, isNotNull);

      notifier.completeSession();

      expect(notifier.state, isNull);
    });

    test('can be called when state is already null without error', () {
      expect(() => notifier.completeSession(), returnsNormally);
      expect(notifier.state, isNull);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // SessionState model
  // ─────────────────────────────────────────────────────────────────────────

  group('SessionState', () {
    test('copyWith preserves unmodified fields', () {
      final original = _baseState(recommendedMinutes: 20);
      final copy = original.copyWith(selectedMinutes: 10);

      expect(copy.selectedMinutes, 10);
      expect(copy.recommendedMinutes, 20);
      expect(copy.hobbyId, original.hobbyId);
      expect(copy.phase, original.phase);
    });

    test('default values are applied when not specified', () {
      final s = _baseState();
      expect(s.phase, SessionPhase.prepare);
      expect(s.elapsedSeconds, 0);
      expect(s.isPaused, false);
      expect(s.isComplete, false);
      expect(s.selectedMinutes, 15); // Freezed @Default(15)
      expect(s.reflection, isNull);
    });
  });
}
