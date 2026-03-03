import 'package:flutter_test/flutter_test.dart';
import 'package:trysomething/core/analytics/analytics_service.dart';

void main() {
  group('AnalyticsService', () {
    late AnalyticsService analytics;

    setUp(() {
      analytics = AnalyticsService();
    });

    test('starts with null userId', () {
      expect(analytics.userId, isNull);
    });

    test('setUserId stores userId', () {
      analytics.setUserId('user_123');
      expect(analytics.userId, 'user_123');
    });

    test('setUserId with null clears userId', () {
      analytics.setUserId('user_123');
      analytics.setUserId(null);
      expect(analytics.userId, isNull);
    });

    test('trackScreen does not throw', () {
      expect(() => analytics.trackScreen('/feed'), returnsNormally);
    });

    test('trackEvent does not throw', () {
      expect(() => analytics.trackEvent('test_event'), returnsNormally);
    });

    test('trackEvent with params does not throw', () {
      expect(
        () => analytics.trackEvent('test_event', {'key': 'value'}),
        returnsNormally,
      );
    });
  });
}
