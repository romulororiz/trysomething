import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:trysomething/components/surprise_me_pill.dart';

void main() {
  group('SurpriseMePill', () {
    testWidgets('fires onSurprise once on tap', (tester) async {
      var calls = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SurpriseMePill(onSurprise: () => calls++),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(SurpriseMePill));
      await tester.pump(); // start press animation
      expect(calls, 1);

      // Pump until the debounce window closes.
      await tester.pump(const Duration(milliseconds: 450));
    });

    testWidgets('does nothing when disabled', (tester) async {
      var calls = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SurpriseMePill(
                enabled: false,
                onSurprise: () => calls++,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(SurpriseMePill));
      await tester.pump();

      expect(calls, 0);
    });

    testWidgets('debounces a fast double tap', (tester) async {
      var calls = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SurpriseMePill(onSurprise: () => calls++),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(SurpriseMePill));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.byType(SurpriseMePill));
      await tester.pump(const Duration(milliseconds: 50));

      expect(calls, 1);

      // Drain remaining timers.
      await tester.pump(const Duration(milliseconds: 500));
    });

    testWidgets('exposes a Semantics button label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SurpriseMePill(onSurprise: () {}),
            ),
          ),
        ),
      );

      // Assert against the widget tree rather than the rendered semantics
      // tree — descendants (Text, Icon) merge into the same semantics node,
      // so find.bySemanticsLabel doesn't reliably surface the outer label.
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Semantics &&
              w.properties.label == 'Surprise me with a random hobby',
        ),
        findsOneWidget,
      );

      await tester.pump(const Duration(milliseconds: 500));
    });
  });
}
