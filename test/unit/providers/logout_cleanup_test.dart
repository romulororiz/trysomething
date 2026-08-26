import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trysomething/core/storage/cache_manager.dart';
import 'package:trysomething/data/repositories/auth_repository.dart';
import 'package:trysomething/providers/auth_provider.dart';
import 'package:trysomething/providers/user_provider.dart';

/// logout() never reaches the repository, so every call is a test failure.
class _UnusedAuthRepo implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw StateError('logout() must not call the auth repository');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('logout_test');
    Hive.init(tempDir.path);
    await CacheManager.init();

    // flutter_secure_storage has no test implementation; back it with a map.
    final secureStore = <String, String>{'access_token': 'a', 'refresh_token': 'r'};
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (call) async {
        switch (call.method) {
          case 'read':
            return secureStore[call.arguments['key'] as String];
          case 'write':
            secureStore[call.arguments['key'] as String] =
                call.arguments['value'] as String;
            return null;
          case 'delete':
            secureStore.remove(call.arguments['key'] as String);
            return null;
          case 'deleteAll':
            secureStore.clear();
            return null;
          case 'readAll':
            return Map<String, String>.from(secureStore);
          case 'containsKey':
            return secureStore.containsKey(call.arguments['key'] as String);
          default:
            return null;
        }
      },
    );
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  // One test only: CacheManager keeps static init state that cannot be reset
  // between tests in the same file.
  test('logout wipes cached API data and user-keyed prefs', () async {
    // Seed the device as if user A had been using the app.
    await CacheManager.put('hobby_detail_h1', '{"private":"user-a-data"}');
    SharedPreferences.setMockInitialValues({
      'user_hobbies': '{"h1":{"hobbyId":"h1","status":"trying"}}',
      'some_other_user_pref': 'leaky',
    });
    final prefs = await SharedPreferences.getInstance();

    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    // Build the notifier with a real Ref so provider cleanup runs.
    final harness = Provider(
      (ref) => AuthNotifier(_UnusedAuthRepo(), null, null, null, ref),
    );

    expect(CacheManager.getStale('hobby_detail_h1'), isNotNull,
        reason: 'precondition: cache is seeded');
    expect(container.read(userHobbiesProvider), isNotEmpty,
        reason: 'precondition: hobbies loaded from prefs');

    await container.read(harness).logout();

    // getStale bypasses TTL — proves the box is empty, not merely expired.
    expect(CacheManager.getStale('hobby_detail_h1'), isNull,
        reason: 'cached API responses must not survive logout');
    expect(container.read(userHobbiesProvider), isEmpty);
    expect(prefs.getString('user_hobbies'), isNull);
    expect(prefs.getString('some_other_user_pref'), isNull);
  });
}
