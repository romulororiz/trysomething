import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trysomething/components/app_background.dart';

void main() {
  group('AppBackground', () {
    testWidgets('child widget is rendered', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppBackground(
              child: Text('hello'),
            ),
          ),
        ),
      );
      expect(find.text('hello'), findsOneWidget);
    });

    testWidgets(
      'default (both tints true) renders Stack with 4 children: base + teal + burgundy + child',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: AppBackground(
                child: SizedBox.shrink(),
              ),
            ),
          ),
        );
        // The direct Stack inside AppBackground — find it as an ancestor of the child
        final stackFinder = find.byType(Stack).first;
        final Stack stack = tester.widget<Stack>(stackFinder);
        // base gradient (Positioned.fill) + teal (Positioned.fill) + burgundy (Positioned.fill) + child
        expect(stack.children.length, 4);
      },
    );

    testWidgets(
      'tintTopLeft=false renders Stack with 3 children: base + burgundy + child',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: AppBackground(
                tintTopLeft: false,
                child: SizedBox.shrink(),
              ),
            ),
          ),
        );
        final Stack stack = tester.widget<Stack>(find.byType(Stack).first);
        expect(stack.children.length, 3);
      },
    );

    testWidgets(
      'tintBottomRight=false renders Stack with 3 children: base + teal + child',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: AppBackground(
                tintBottomRight: false,
                child: SizedBox.shrink(),
              ),
            ),
          ),
        );
        final Stack stack = tester.widget<Stack>(find.byType(Stack).first);
        expect(stack.children.length, 3);
      },
    );
  });
}
