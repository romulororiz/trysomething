import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:trysomething/components/shimmer_skeleton.dart';
import '../golden_test_helpers.dart';

void main() {
  setUpAll(() async => await loadFonts());

  testGoldens('ShimmerBone — default (full width, height 20)', (tester) async {
    await tester.pumpWidgetBuilder(
      wrap(const ShimmerBone(height: 20)),
      surfaceSize: const Size(300, 60),
    );
    await tester.pumpAndSettle();
    await screenMatchesGolden(tester, 'shimmer_bone_default');
  });

  testGoldens('ShimmerBone — short (width: 100, height: 14, borderRadius: 4)', (tester) async {
    await tester.pumpWidgetBuilder(
      wrap(const ShimmerBone(width: 100, height: 14, borderRadius: 4)),
      surfaceSize: const Size(300, 60),
    );
    await tester.pumpAndSettle();
    await screenMatchesGolden(tester, 'shimmer_bone_short');
  });

  testGoldens('ShimmerBone — pill (width: 60, height: 26, borderRadius: 13)', (tester) async {
    await tester.pumpWidgetBuilder(
      wrap(const ShimmerBone(width: 60, height: 26, borderRadius: 13)),
      surfaceSize: const Size(300, 60),
    );
    await tester.pumpAndSettle();
    await screenMatchesGolden(tester, 'shimmer_bone_pill');
  });
}
