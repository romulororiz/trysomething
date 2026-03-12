import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:trysomething/components/app_background.dart';
import '../golden_test_helpers.dart';

void main() {
  setUpAll(() async => await loadFonts());

  testGoldens('AppBackground — default (both tints on)', (tester) async {
    await tester.pumpWidgetBuilder(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: AppBackground(child: const SizedBox.expand()),
        ),
      ),
      surfaceSize: const Size(375, 200),
    );
    await tester.pumpAndSettle();
    await screenMatchesGolden(tester, 'app_background_default');
  });

  testGoldens('AppBackground — no top-left tint', (tester) async {
    await tester.pumpWidgetBuilder(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: AppBackground(
            tintTopLeft: false,
            child: const SizedBox.expand(),
          ),
        ),
      ),
      surfaceSize: const Size(375, 200),
    );
    await tester.pumpAndSettle();
    await screenMatchesGolden(tester, 'app_background_no_top_tint');
  });

  testGoldens('AppBackground — no bottom-right tint', (tester) async {
    await tester.pumpWidgetBuilder(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: AppBackground(
            tintBottomRight: false,
            child: const SizedBox.expand(),
          ),
        ),
      ),
      surfaceSize: const Size(375, 200),
    );
    await tester.pumpAndSettle();
    await screenMatchesGolden(tester, 'app_background_no_bottom_tint');
  });

  testGoldens('AppBackground — no tints', (tester) async {
    await tester.pumpWidgetBuilder(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: AppBackground(
            tintTopLeft: false,
            tintBottomRight: false,
            child: const SizedBox.expand(),
          ),
        ),
      ),
      surfaceSize: const Size(375, 200),
    );
    await tester.pumpAndSettle();
    await screenMatchesGolden(tester, 'app_background_no_tints');
  });
}
