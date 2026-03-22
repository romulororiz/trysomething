// ignore_for_file: invalid_use_of_protected_member

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trysomething/models/session.dart';
import 'package:trysomething/providers/session_provider.dart';
import 'package:trysomething/providers/user_provider.dart';
import 'package:trysomething/screens/session/session_screen.dart';

// ─────────────────────────────────────────────────────────
//  Shared test parameters
// ─────────────────────────────────────────────────────────

const _kHobbyId = 'hobby-1';
const _kStepId = 'step-1';
const _kHobbyTitle = 'Pottery';
const _kHobbyCategory = 'creative';
const _kStepTitle = 'First clay touch';
const _kStepDescription = 'Get a feel for the clay.';
const _kStepInstructions = 'Knead the clay gently for a few minutes.';
const _kWhatYouNeed = 'Clay, table, hands';
const _kRecommendedMinutes = 15;

// ─────────────────────────────────────────────────────────
//  Test doubles
// ─────────────────────────────────────────────────────────

/// A [SessionNotifier] whose [startSession] is a no-op, keeping state null.
/// Used to exercise the null-state guard branch of [SessionScreen].
class _NullSessionNotifier extends SessionNotifier {
  @override
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
    // Intentionally does nothing — keeps state == null.
  }
}

// ─────────────────────────────────────────────────────────
//  Helpers
// ─────────────────────────────────────────────────────────

/// Creates a SharedPreferences override with empty mock values.
Future<Override> _prefsOverride() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  return sharedPreferencesProvider.overrideWithValue(prefs);
}

/// Returns a [sessionProvider.overrideWith] factory that creates a plain
/// [SessionNotifier] WITHOUT the `ref.onDispose(notifier.dispose)` call
/// that the production provider registration adds. This avoids the double-
/// dispose error that would otherwise surface in test teardown.
Override _sessionOverride({_NullSessionNotifier? nullNotifier}) {
  return sessionProvider.overrideWith(
    (ref) => nullNotifier ?? SessionNotifier(),
  );
}

/// Pumps [SessionScreen] inside a [ProviderScope] that stubs the prefs
/// provider and overrides the session provider (to avoid double-dispose).
/// An extra 700 ms pump drains flutter_animate stagger timers.
Future<void> _pumpScreen(
  WidgetTester tester, {
  String? nextStepTitle,
  Override? sessionOv,
}) async {
  final prefsOv = await _prefsOverride();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        prefsOv,
        sessionOv ?? _sessionOverride(),
      ],
      child: MaterialApp(
        home: SessionScreen(
          hobbyId: _kHobbyId,
          stepId: _kStepId,
          hobbyTitle: _kHobbyTitle,
          hobbyCategory: _kHobbyCategory,
          stepTitle: _kStepTitle,
          stepDescription: _kStepDescription,
          stepInstructions: _kStepInstructions,
          whatYouNeed: _kWhatYouNeed,
          recommendedMinutes: _kRecommendedMinutes,
          completionMode: CompletionMode.timer,
          nextStepTitle: nextStepTitle,
        ),
      ),
    ),
  );

  // Tick 1: addPostFrameCallback fires → startSession → state = prepare.
  await tester.pump();

  // Tick 2: drain flutter_animate stagger timers.
  // Longest stagger in prepare phase: 600 ms.
  await tester.pump(const Duration(milliseconds: 700));
}

/// Reads the [SessionNotifier] from the live [ProviderScope] in the tree.
SessionNotifier _notifier(WidgetTester tester) {
  final element = tester.element(find.byType(SessionScreen));
  return ProviderScope.containerOf(element).read(sessionProvider.notifier);
}

/// Reads the current [SessionState?] from the live [ProviderScope] in the tree.
SessionState? _sessionState(WidgetTester tester) {
  final element = tester.element(find.byType(SessionScreen));
  return ProviderScope.containerOf(element).read(sessionProvider);
}

// ─────────────────────────────────────────────────────────
//  Test suite
// ─────────────────────────────────────────────────────────

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock the WakelockPlus Pigeon channel so WakelockPlus.enable() and
  // WakelockPlus.disable() inside SessionNotifier don't throw
  // MissingPluginException. The bytes encode a Pigeon null-success envelope.
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler(
    'dev.flutter.pigeon.wakelock_plus_platform_interface.WakelockPlusApi.toggle',
    (_) async => ByteData.sublistView(Uint8List.fromList([0x0c, 1, 0])),
  );

  // ── 1 & 2. Prepare phase ────────────────────────────────
  group('Prepare phase', () {
    testWidgets("renders hobby/step context and the \"I'm ready\" CTA",
        (tester) async {
      await _pumpScreen(tester);

      expect(find.text(_kHobbyTitle), findsOneWidget);
      expect(find.text(_kStepTitle), findsOneWidget);
      expect(find.text("I'm ready"), findsOneWidget);
      expect(find.text('Not now'), findsOneWidget);
    });

    testWidgets('duration selector shows three pill options for 15-min default',
        (tester) async {
      await _pumpScreen(tester);

      // _computeOptions for recommended == 15 → [10, 15, 30]
      expect(find.text('10 min'), findsOneWidget);
      expect(find.text('15 min'), findsOneWidget);
      expect(find.text('30 min'), findsOneWidget);
    });
  });

  // ── 3-6. Timer phase ────────────────────────────────────
  group('Timer phase', () {
    /// Enters the timer phase. Callers MUST call `notifier.endTimerEarly()`
    /// before the test ends; otherwise the 1-second periodic timer causes a
    /// "pending timers" failure in teardown.
    Future<SessionNotifier> enterTimerPhase(WidgetTester tester) async {
      await _pumpScreen(tester);

      final notifier = _notifier(tester);
      notifier.beginTimer();

      // Repaint with timer phase UI.
      await tester.pump();
      // Drain any remaining flutter_animate timers inside timer phase.
      await tester.pump(const Duration(milliseconds: 200));

      return notifier;
    }

    testWidgets('shows MM:SS countdown and step instructions', (tester) async {
      final notifier = await enterTimerPhase(tester);

      // Countdown is in MM:SS format.
      expect(find.textContaining(':'), findsOneWidget);
      // Step instructions appear during the active timer.
      expect(find.text(_kStepInstructions), findsOneWidget);

      // Cancel the periodic timer before teardown.
      notifier.endTimerEarly();
      await tester.pump();
    });

    testWidgets('pause/play GestureDetector is present in timer phase',
        (tester) async {
      final notifier = await enterTimerPhase(tester);

      expect(find.byType(GestureDetector), findsWidgets);

      notifier.endTimerEarly();
      await tester.pump();
    });

    testWidgets(
        '"Paused" label appears and "End session early" link visible after pause',
        (tester) async {
      final notifier = await enterTimerPhase(tester);

      notifier.pauseTimer();
      await tester.pump();

      // AnimatedOpacity sets opacity to 1.0 when paused — text is in tree.
      expect(find.text('Paused'), findsOneWidget);
      // IgnorePointer renders "End session early" even when not yet interactive.
      expect(find.text('End session early'), findsOneWidget);

      notifier.endTimerEarly();
      await tester.pump();
    });

    testWidgets('resumeTimer() restores running state (not paused)', (tester) async {
      final notifier = await enterTimerPhase(tester);

      notifier.pauseTimer();
      notifier.resumeTimer();
      await tester.pump();

      final state = _sessionState(tester);
      expect(state, isNotNull);
      expect(state!.phase, SessionPhase.timer);
      expect(state.isPaused, isFalse);

      // Provider state confirms timer is running and not paused (source of truth).
      // Note: AnimatedSwitcher crossfade (400 ms) may overlap prepare/timer
      // widgets visually, so we rely on state rather than widget presence.
      expect(find.text('STEP COMPLETE'), findsNothing);

      notifier.endTimerEarly();
      await tester.pump();
    });
  });

  // ── 7-10. Reflect phase ─────────────────────────────────
  group('Reflect phase', () {
    /// Reaches reflect phase by directly patching the notifier state —
    /// no periodic timer is started, so no cleanup required.
    Future<void> pumpInReflect(WidgetTester tester) async {
      await _pumpScreen(tester);

      final notifier = _notifier(tester);
      final current = _sessionState(tester)!;

      // Bypass the private _completeTimer by writing state directly.
      notifier.state = current.copyWith(phase: SessionPhase.reflect);

      await tester.pump();
      // Drain reflect-phase fade-in timers (longest delay: 300 ms).
      await tester.pump(const Duration(milliseconds: 400));
    }

    testWidgets('renders "How was that?" headline', (tester) async {
      await pumpInReflect(tester);
      expect(find.text('How was that?'), findsOneWidget);
    });

    testWidgets('shows all three reflection choice labels', (tester) async {
      await pumpInReflect(tester);

      expect(find.text('Loved it'), findsOneWidget);
      expect(find.text('It was okay'), findsOneWidget);
      expect(find.text('Struggled'), findsOneWidget);
    });

    testWidgets('"Skip" link is visible', (tester) async {
      await pumpInReflect(tester);
      expect(find.text('Skip'), findsOneWidget);
    });

    testWidgets('tapping a choice reveals journal prompt and "Save & finish"',
        (tester) async {
      await pumpInReflect(tester);

      await tester.tap(find.text('Loved it'));
      await tester.pump();
      // Drain the reveal-animation timers (~300 ms delay + 300 ms duration).
      await tester.pump(const Duration(milliseconds: 700));

      expect(find.text('Want to remember anything?'), findsOneWidget);
      expect(find.text('Save & finish'), findsOneWidget);
    });
  });

  // ── 11-13. Complete phase ───────────────────────────────
  group('Complete phase', () {
    Future<void> pumpInComplete(WidgetTester tester,
        {String? nextStepTitle}) async {
      await _pumpScreen(tester, nextStepTitle: nextStepTitle);

      final notifier = _notifier(tester);
      final current = _sessionState(tester)!;

      // Jump to reflect without starting the periodic timer.
      notifier.state = current.copyWith(phase: SessionPhase.reflect);
      await tester.pump();

      // Skip reflection → phase = complete, isComplete = true.
      notifier.skipReflection();
      await tester.pump();

      // Drain complete-phase animation timers (longest delay: 900 ms).
      await tester.pump(const Duration(milliseconds: 1100));
    }

    testWidgets('renders "STEP COMPLETE" overline', (tester) async {
      await pumpInComplete(tester);
      expect(find.text('STEP COMPLETE'), findsOneWidget);

      // Pump past the 3-second auto-exit timer to let it fire cleanly.
      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets('renders step title and check icon', (tester) async {
      await pumpInComplete(tester);
      expect(find.text(_kStepTitle), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline_rounded), findsOneWidget);

      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets('renders next step preview when nextStepTitle is provided',
        (tester) async {
      await pumpInComplete(tester, nextStepTitle: 'Shape your first bowl');
      expect(find.text('Next: Shape your first bowl'), findsOneWidget);

      await tester.pump(const Duration(seconds: 4));
    });
  });

  // ── 14. endTimerEarly sets session state to null ────────
  group('endTimerEarly()', () {
    testWidgets('nullifies provider state after beginTimer', (tester) async {
      await _pumpScreen(tester);

      final notifier = _notifier(tester);
      notifier.beginTimer();

      expect(_sessionState(tester), isNotNull);

      // endTimerEarly cancels the periodic timer and sets state = null.
      notifier.endTimerEarly();
      await tester.pump();

      expect(_sessionState(tester), isNull);
    });
  });

  // ── 15. Null session state ──────────────────────────────
  group('Null session state', () {
    testWidgets('SessionScreen shows plain Scaffold with no phase content',
        (tester) async {
      await _pumpScreen(
        tester,
        sessionOv: _sessionOverride(nullNotifier: _NullSessionNotifier()),
      );

      // No phase-specific widgets should appear.
      expect(find.text("I'm ready"), findsNothing);
      expect(find.text('How was that?'), findsNothing);
      expect(find.text('STEP COMPLETE'), findsNothing);

      // The null-guard branch in SessionScreen returns a plain Scaffold.
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
