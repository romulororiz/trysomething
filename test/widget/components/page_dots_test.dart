import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trysomething/components/page_dots.dart';

void main() {
  group('PageDots', () {
    testWidgets('renders correct number of dots (count=3 → 3 AnimatedContainers)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PageDots(count: 3, current: 0),
          ),
        ),
      );
      expect(find.byType(AnimatedContainer), findsNWidgets(3));
    });

    testWidgets('active dot (current=0) has width 20', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PageDots(count: 3, current: 0),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final renderBox = tester.renderObject<RenderBox>(
        find.byType(AnimatedContainer).at(0),
      );
      // RenderBox includes 3px horizontal margin on each side → 20 + 6 = 26.
      expect(renderBox.size.width, 26.0);
    });

    testWidgets('inactive dot has width 6', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PageDots(count: 3, current: 0),
          ),
        ),
      );
      await tester.pumpAndSettle();
      // Dot at index 1 is inactive when current=0.
      final renderBox = tester.renderObject<RenderBox>(
        find.byType(AnimatedContainer).at(1),
      );
      // RenderBox includes 3px horizontal margin on each side → 6 + 6 = 12.
      expect(renderBox.size.width, 12.0);
    });

    testWidgets('count=1 renders 1 dot', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PageDots(count: 1, current: 0),
          ),
        ),
      );
      expect(find.byType(AnimatedContainer), findsOneWidget);
    });

    testWidgets('current=2 with count=3 makes the last dot active (width 20)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PageDots(count: 3, current: 2),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final activeRenderBox = tester.renderObject<RenderBox>(
        find.byType(AnimatedContainer).at(2),
      );
      // Active: 20 + 6 (margins) = 26.
      expect(activeRenderBox.size.width, 26.0);

      // First two dots should be inactive: 6 + 6 (margins) = 12.
      final firstRenderBox = tester.renderObject<RenderBox>(
        find.byType(AnimatedContainer).at(0),
      );
      expect(firstRenderBox.size.width, 12.0);
    });
  });
}
