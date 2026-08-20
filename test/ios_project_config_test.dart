import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('GoogleService-Info.plist is bundled in the iOS Runner target', () {
    final pbxproj = File('ios/Runner.xcodeproj/project.pbxproj')
        .readAsStringSync();

    // Without these entries the plist exists on disk but never ships in the
    // .ipa — Firebase has no default app on iOS and startup throws
    // [core/no-app] before the first frame (white screen on launch).
    expect(
      pbxproj,
      contains('GoogleService-Info.plist */ = {isa = PBXFileReference'),
      reason: 'GoogleService-Info.plist needs a PBXFileReference entry',
    );
    expect(
      pbxproj,
      contains('GoogleService-Info.plist in Resources'),
      reason:
          'GoogleService-Info.plist must be in the Resources build phase',
    );
  });
}
