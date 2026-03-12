import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trysomething/components/spec_badge.dart';

void main() {
  group('SpecBadge', () {
    testWidgets('renders text content', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SpecBadge(
              type: SpecBadgeType.cost,
              text: 'CHF 40',
            ),
          ),
        ),
      );
      expect(find.text('CHF 40'), findsOneWidget);
    });

    testWidgets('small=true uses 11px font size', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SpecBadge(
              type: SpecBadgeType.time,
              text: '2h/week',
              small: true,
            ),
          ),
        ),
      );
      final textWidget = tester.widget<Text>(find.text('2h/week'));
      expect(textWidget.style?.fontSize, 11);
    });

    testWidgets('small=false uses 13px font size', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SpecBadge(
              type: SpecBadgeType.difficulty,
              text: 'Easy',
              small: false,
            ),
          ),
        ),
      );
      final textWidget = tester.widget<Text>(find.text('Easy'));
      expect(textWidget.style?.fontSize, 13);
    });
  });

  group('SpecBar', () {
    testWidgets('renders joined "cost · time · difficulty" string', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SpecBar(
              cost: 'CHF 40-120',
              time: '2h/week',
              difficulty: 'Easy',
            ),
          ),
        ),
      );
      expect(find.text('CHF 40-120 · 2h/week · Easy'), findsOneWidget);
    });

    testWidgets('small=true uses 11px font size', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SpecBar(
              cost: 'CHF 40',
              time: '1h/week',
              difficulty: 'Easy',
              small: true,
            ),
          ),
        ),
      );
      final textWidget = tester.widget<Text>(
        find.text('CHF 40 · 1h/week · Easy'),
      );
      expect(textWidget.style?.fontSize, 11);
    });

    testWidgets('withContainer=true wraps in Padding', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SpecBar(
              cost: 'CHF 40',
              time: '1h/week',
              difficulty: 'Easy',
              withContainer: true,
            ),
          ),
        ),
      );
      expect(find.byType(Padding), findsWidgets);
      // Verify Padding is the outermost widget of SpecBar (ancestor of the Text)
      final textFinder = find.text('CHF 40 · 1h/week · Easy');
      expect(
        find.ancestor(of: textFinder, matching: find.byType(Padding)),
        findsWidgets,
      );
    });
  });
}
