import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trysomething/components/glass_card.dart';

void main() {
  group('GlassCard', () {
    testWidgets('child widget is rendered', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassCard(
              child: Text('tap me'),
            ),
          ),
        ),
      );
      expect(find.text('tap me'), findsOneWidget);
    });

    testWidgets('onTap callback fires when tapped', (tester) async {
      int tapCount = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassCard(
              onTap: () => tapCount++,
              child: const Text('tap me'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('tap me'));
      await tester.pump();
      expect(tapCount, 1);
    });

    testWidgets('blur=true adds BackdropFilter to widget tree', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassCard(
              blur: true,
              child: Text('blurred'),
            ),
          ),
        ),
      );
      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('blur=false (default) has no BackdropFilter', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassCard(
              child: Text('no blur'),
            ),
          ),
        ),
      );
      expect(find.byType(BackdropFilter), findsNothing);
    });

    testWidgets('GestureDetector present only when onTap is provided', (tester) async {
      // Without onTap — no GestureDetector
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassCard(
              child: Text('no tap'),
            ),
          ),
        ),
      );
      expect(find.byType(GestureDetector), findsNothing);

      // With onTap — GestureDetector present
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassCard(
              onTap: () {},
              child: const Text('with tap'),
            ),
          ),
        ),
      );
      expect(find.byType(GestureDetector), findsOneWidget);
    });
  });
}
