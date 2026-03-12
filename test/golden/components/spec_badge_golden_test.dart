import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:trysomething/components/spec_badge.dart';
import '../golden_test_helpers.dart';

// SpecBadge / SpecBar use AppTypography.data → GoogleFonts.ibmPlexMono().
// IBMPlexMono-Medium.ttf is bundled under assets/fonts/ so google_fonts
// loads it from the asset bundle (runtime fetching is disabled in loadFonts()).

void main() {
  setUpAll(() async => await loadFonts());

  testGoldens('SpecBadge — default', (tester) async {
    await tester.pumpWidgetBuilder(
      wrap(const SpecBadge(type: SpecBadgeType.cost, text: 'CHF 20-50')),
      surfaceSize: const Size(300, 60),
    );
    await tester.pumpAndSettle();
    await screenMatchesGolden(tester, 'spec_badge_default');
  });

  testGoldens('SpecBadge — small: true', (tester) async {
    await tester.pumpWidgetBuilder(
      wrap(const SpecBadge(
        type: SpecBadgeType.cost,
        text: 'CHF 20-50',
        small: true,
      )),
      surfaceSize: const Size(300, 60),
    );
    await tester.pumpAndSettle();
    await screenMatchesGolden(tester, 'spec_badge_small');
  });

  testGoldens('SpecBadge — onDark: true', (tester) async {
    await tester.pumpWidgetBuilder(
      wrap(const SpecBadge(
        type: SpecBadgeType.time,
        text: '2h/week',
        onDark: true,
      )),
      surfaceSize: const Size(300, 60),
    );
    await tester.pumpAndSettle();
    await screenMatchesGolden(tester, 'spec_badge_on_dark');
  });

  testGoldens('SpecBar — default', (tester) async {
    await tester.pumpWidgetBuilder(
      wrap(const SpecBar(
        cost: 'CHF 40-120',
        time: '2h/week',
        difficulty: 'Easy',
      )),
      surfaceSize: const Size(300, 60),
    );
    await tester.pumpAndSettle();
    await screenMatchesGolden(tester, 'spec_bar_default');
  });

  testGoldens('SpecBar — small: true', (tester) async {
    await tester.pumpWidgetBuilder(
      wrap(const SpecBar(
        cost: 'Free',
        time: '1h/week',
        difficulty: 'Easy',
        small: true,
      )),
      surfaceSize: const Size(300, 60),
    );
    await tester.pumpAndSettle();
    await screenMatchesGolden(tester, 'spec_bar_small');
  });
}
