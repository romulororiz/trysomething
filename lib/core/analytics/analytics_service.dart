import 'package:flutter/foundation.dart';

/// Lightweight analytics service. Logs to console in debug mode.
/// Swap the provider override in main.dart to connect Firebase Analytics,
/// Mixpanel, Amplitude, or any other backend.
class AnalyticsService {
  String? _userId;

  /// Set the authenticated user ID for attribution.
  void setUserId(String? userId) {
    _userId = userId;
    if (kDebugMode) {
      debugPrint('[Analytics] userId=${userId ?? 'null'}');
    }
  }

  /// Track a screen view.
  void trackScreen(String screenName) {
    if (kDebugMode) {
      debugPrint('[Analytics] screen: $screenName');
    }
  }

  /// Track a custom event with optional parameters.
  void trackEvent(String name, [Map<String, dynamic>? params]) {
    if (kDebugMode) {
      final extra = params != null ? ' $params' : '';
      debugPrint('[Analytics] event: $name$extra');
    }
  }

  /// Current user ID (if set).
  String? get userId => _userId;
}
