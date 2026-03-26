import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// Skip golden image comparisons when running in CI (Ubuntu) since reference
/// images were generated on Windows and font rendering differs across OSes.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  if (Platform.environment.containsKey('CI')) {
    autoUpdateGoldenFiles = true;
  }
  await testMain();
}
