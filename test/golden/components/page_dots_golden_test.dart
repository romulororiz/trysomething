import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:trysomething/components/page_dots.dart';
import '../golden_test_helpers.dart';

void main() {
  setUpAll(() async => await loadFonts());

  testGoldens('PageDots — first (count: 3, current: 0)', (tester) async {
    await tester.pumpWidgetBuilder(
      wrap(const PageDots(count: 3, current: 0)),
      surfaceSize: const Size(200, 40),
    );
    await tester.pumpAndSettle();
    await screenMatchesGolden(tester, 'page_dots_first');
  });

  testGoldens('PageDots — middle (count: 3, current: 1)', (tester) async {
    await tester.pumpWidgetBuilder(
      wrap(const PageDots(count: 3, current: 1)),
      surfaceSize: const Size(200, 40),
    );
    await tester.pumpAndSettle();
    await screenMatchesGolden(tester, 'page_dots_middle');
  });

  testGoldens('PageDots — last (count: 5, current: 4)', (tester) async {
    await tester.pumpWidgetBuilder(
      wrap(const PageDots(count: 5, current: 4)),
      surfaceSize: const Size(200, 40),
    );
    await tester.pumpAndSettle();
    await screenMatchesGolden(tester, 'page_dots_last');
  });
}
