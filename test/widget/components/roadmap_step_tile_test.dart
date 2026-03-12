import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trysomething/components/roadmap_step_tile.dart';
import 'package:trysomething/models/hobby.dart';

// ---------------------------------------------------------------------------
// Helper — construct a minimal RoadmapStep for testing.
// The actual model only exposes: id, title, description, estimatedMinutes,
// milestone, completionMode.  The task spec's extra fields don't exist.
// ---------------------------------------------------------------------------
RoadmapStep _step({
  String id = 's1',
  String title = 'First session',
  String description = 'Do the thing',
  int estimatedMinutes = 20,
  String? milestone,
  CompletionMode? completionMode,
}) =>
    RoadmapStep(
      id: id,
      title: title,
      description: description,
      estimatedMinutes: estimatedMinutes,
      milestone: milestone,
      completionMode: completionMode,
    );

// ---------------------------------------------------------------------------
// Convenience pump helper — wraps the tile in MaterialApp + Scaffold so that
// timelines_plus / Material context is satisfied.
// ---------------------------------------------------------------------------
Future<void> _pump(
  WidgetTester tester,
  RoadmapStepTile tile,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(child: tile),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('RoadmapStepTile', () {
    // ── 1. isCompleted=true — title has strikethrough decoration ──────────
    testWidgets('isCompleted=true — title text has lineThrough decoration',
        (tester) async {
      await _pump(
        tester,
        RoadmapStepTile(
          step: _step(title: 'First session'),
          stepNumber: 1,
          isCompleted: true,
        ),
      );

      // Find all Text widgets that contain the title string.
      final titleFinder = find.text('First session');
      expect(titleFinder, findsOneWidget);

      final textWidget = tester.widget<Text>(titleFinder);
      expect(
        textWidget.style?.decoration,
        equals(TextDecoration.lineThrough),
        reason: 'Completed step title should be struck through',
      );
    });

    // ── 2. isCompleted=true — check icon is present ───────────────────────
    testWidgets('isCompleted=true — contains a check icon', (tester) async {
      await _pump(
        tester,
        RoadmapStepTile(
          step: _step(),
          stepNumber: 1,
          isCompleted: true,
        ),
      );

      expect(
        find.byIcon(Icons.check),
        findsOneWidget,
        reason: 'Completed step node should show Icons.check',
      );
    });

    // ── 3. isCurrent=true — title is visible ──────────────────────────────
    testWidgets('isCurrent=true — title text is visible', (tester) async {
      await _pump(
        tester,
        RoadmapStepTile(
          step: _step(title: 'Paint something'),
          stepNumber: 2,
          isCurrent: true,
        ),
      );

      expect(find.text('Paint something'), findsOneWidget);
    });

    // ── 4. isCurrent=true with milestone — milestone text is visible ──────
    testWidgets('isCurrent=true with milestone — milestone text visible',
        (tester) async {
      await _pump(
        tester,
        RoadmapStepTile(
          step: _step(milestone: 'First brushstroke!'),
          stepNumber: 1,
          isCurrent: true,
        ),
      );

      expect(
        find.text('First brushstroke!'),
        findsOneWidget,
        reason: 'Milestone badge should appear for the current step',
      );
    });

    // ── 5. isCurrent=true — description is visible ────────────────────────
    testWidgets('isCurrent=true — description text is visible',
        (tester) async {
      await _pump(
        tester,
        RoadmapStepTile(
          step: _step(description: 'Mix the colours gently'),
          stepNumber: 1,
          isCurrent: true,
        ),
      );

      expect(find.text('Mix the colours gently'), findsOneWidget);
    });

    // ── 6. future state — description NOT shown ───────────────────────────
    testWidgets(
        'future state (not completed, not current) — description not shown',
        (tester) async {
      await _pump(
        tester,
        RoadmapStepTile(
          step: _step(description: 'Secret future description'),
          stepNumber: 3,
          isCompleted: false,
          isCurrent: false,
        ),
      );

      expect(
        find.text('Secret future description'),
        findsNothing,
        reason: 'Future steps should not expand to show description',
      );
    });

    // ── 7. future state — no check icon ──────────────────────────────────
    testWidgets('future state — no check icon present', (tester) async {
      await _pump(
        tester,
        RoadmapStepTile(
          step: _step(),
          stepNumber: 4,
          isCompleted: false,
          isCurrent: false,
        ),
      );

      expect(
        find.byIcon(Icons.check),
        findsNothing,
        reason: 'Future step node should not show a check icon',
      );
    });

    // ── 8. onToggle fires when tile is tapped ─────────────────────────────
    testWidgets('tapping the tile invokes the onToggle callback',
        (tester) async {
      int callCount = 0;

      await _pump(
        tester,
        RoadmapStepTile(
          step: _step(title: 'Tappable step'),
          stepNumber: 1,
          isCurrent: true,
          onToggle: () => callCount++,
        ),
      );

      // Tap the card content area (the title text is a reliable target).
      await tester.tap(find.text('Tappable step'));
      await tester.pumpAndSettle();

      expect(callCount, greaterThan(0),
          reason: 'onToggle should be called on tap');
    });

    // ── 9. onToggle=null — tapping doesn't throw ─────────────────────────
    testWidgets('onToggle=null — tapping does not throw', (tester) async {
      await _pump(
        tester,
        RoadmapStepTile(
          step: _step(title: 'No callback step'),
          stepNumber: 1,
          isCurrent: true,
          // onToggle intentionally omitted
        ),
      );

      // Tapping with no onToggle should not throw.
      await tester.tap(find.text('No callback step'), warnIfMissed: false);
      await tester.pumpAndSettle();
    });

    // ── 10. stepNumber shown — appears as text somewhere in the tile ──────
    testWidgets('stepNumber is rendered as text in the tile node',
        (tester) async {
      await _pump(
        tester,
        RoadmapStepTile(
          step: _step(),
          stepNumber: 7,
          isCurrent: false,
          isCompleted: false,
        ),
      );

      // The node always renders the step number as text for current / future.
      expect(
        find.text('7'),
        findsOneWidget,
        reason: 'Step number should appear as text in the timeline node',
      );
    });

    // ── 11. isCurrent=true with estimatedMinutes — time text shown ────────
    testWidgets('isCurrent=true — estimatedMinutes shown as "<n>min"',
        (tester) async {
      await _pump(
        tester,
        RoadmapStepTile(
          step: _step(estimatedMinutes: 45),
          stepNumber: 1,
          isCurrent: true,
        ),
      );

      expect(
        find.text('45min'),
        findsOneWidget,
        reason:
            'Current step card should display estimatedMinutes as "<n>min"',
      );
    });

    // ── 12. isCompleted=true with milestone — milestone NOT shown ─────────
    testWidgets('isCompleted=true with milestone — milestone not shown',
        (tester) async {
      await _pump(
        tester,
        RoadmapStepTile(
          step: _step(milestone: 'Hidden milestone'),
          stepNumber: 1,
          isCompleted: true,
        ),
      );

      expect(
        find.text('Hidden milestone'),
        findsNothing,
        reason: 'Milestone badge should only appear for the current step, '
            'not for completed steps',
      );
    });
  });
}
