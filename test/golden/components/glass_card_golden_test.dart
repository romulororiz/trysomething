import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:trysomething/components/glass_card.dart';
import '../golden_test_helpers.dart';

void main() {
  setUpAll(() async => await loadFonts());

  testGoldens('GlassCard — default (no blur)', (tester) async {
    await tester.pumpWidgetBuilder(
      wrap(const GlassCard(
        child: Text('Hello', style: TextStyle(color: Colors.white)),
      )),
      surfaceSize: const Size(300, 120),
    );
    await tester.pumpAndSettle();
    await screenMatchesGolden(tester, 'glass_card_default');
  });

  testGoldens('GlassCard — blur: true', (tester) async {
    await tester.pumpWidgetBuilder(
      wrap(const GlassCard(
        blur: true,
        child: Text('Hello', style: TextStyle(color: Colors.white)),
      )),
      surfaceSize: const Size(300, 120),
    );
    await tester.pumpAndSettle();
    await screenMatchesGolden(tester, 'glass_card_blur');
  });

  testGoldens('GlassCard — with onTap', (tester) async {
    await tester.pumpWidgetBuilder(
      wrap(GlassCard(
        onTap: () {},
        child: const Text('Tap me', style: TextStyle(color: Colors.white)),
      )),
      surfaceSize: const Size(300, 120),
    );
    await tester.pumpAndSettle();
    await screenMatchesGolden(tester, 'glass_card_with_tap');
  });

  testGoldens('GlassCard — custom borderRadius 8', (tester) async {
    await tester.pumpWidgetBuilder(
      wrap(const GlassCard(
        borderRadius: 8,
        child: SizedBox(width: 100, height: 40),
      )),
      surfaceSize: const Size(300, 120),
    );
    await tester.pumpAndSettle();
    await screenMatchesGolden(tester, 'glass_card_custom_radius');
  });
}
