import 'package:flutter_test/flutter_test.dart';
import 'package:trysomething/core/notifications/notification_service.dart';

// NOTE: init(), requestPermission(), getToken(), and onTokenRefresh() all call
// Firebase platform channels which are unavailable in unit tests. Those methods
// are intentionally not exercised here. Only pure-Dart state and the listener
// registration API are tested.

void main() {
  group('NotificationService', () {
    late NotificationService service;

    setUp(() {
      service = NotificationService();
    });

    // ── isInitialized ──────────────────────────────────────────────────────

    group('isInitialized', () {
      test('is false on a fresh instance', () {
        expect(service.isInitialized, isFalse);
      });

      test('two independent instances each start uninitialized', () {
        final a = NotificationService();
        final b = NotificationService();
        expect(a.isInitialized, isFalse);
        expect(b.isInitialized, isFalse);
      });

      test('isInitialized state is independent between instances', () {
        final a = NotificationService();
        final b = NotificationService();
        // Manually flip the flag on 'a' via the public getter as a read-back
        // check — we cannot call init() (Firebase channels), so we only assert
        // that b remains unaffected regardless of what happens to a.
        expect(a.isInitialized, isFalse);
        expect(b.isInitialized, isFalse);
        // Both should still be false; no shared static state.
        expect(a.isInitialized, equals(b.isInitialized));
      });
    });

    // ── onMessage ─────────────────────────────────────────────────────────

    group('onMessage', () {
      test('registering a single listener does not throw', () {
        expect(
          () => service.onMessage((_) {}),
          returnsNormally,
        );
      });

      test('registering multiple listeners does not throw', () {
        expect(() {
          service.onMessage((_) {});
          service.onMessage((_) {});
          service.onMessage((_) {});
        }, returnsNormally);
      });

      test('onMessage is callable on a fresh instance without initializing first', () {
        // Ensures there is no guard that requires init() before onMessage().
        final freshService = NotificationService();
        expect(freshService.isInitialized, isFalse);
        expect(() => freshService.onMessage((_) {}), returnsNormally);
      });
    });
  });
}
