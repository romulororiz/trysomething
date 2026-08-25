import 'package:flutter/foundation.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

/// Analytics service backed by PostHog.
/// Falls back to console logging in debug mode.
class AnalyticsService {
  String? _userId;

  bool _initialized = false;

  // PostHog *project* API key (phc_ prefix) — a write-only ingestion key that
  // is meant to ship inside client binaries. Baked as the default so CI builds
  // without --dart-define still report. Never put a phx_ personal key here:
  // those are account-wide secrets and PostHog rejects their ingestion.
  static const _apiKey = String.fromEnvironment(
    'POSTHOG_API_KEY',
    defaultValue: 'phc_2JdQmgssLVNdwU4FJjBteajM9dXkztG5by6xF0A4U8z',
  );

  /// Initialize PostHog SDK.
  /// Skips initialization if POSTHOG_API_KEY is not set (empty).
  Future<void> init() async {
    if (_apiKey.isEmpty) {
      debugPrint('[Analytics] POSTHOG_API_KEY not set — skipping PostHog init');
      return;
    }

    try {
      const host = String.fromEnvironment(
        'POSTHOG_HOST',
        defaultValue: 'https://us.i.posthog.com',
      );

      final config = PostHogConfig(_apiKey);
      config.host = host;
      config.captureApplicationLifecycleEvents = true;
      config.debug = kDebugMode;

      await Posthog().setup(config);
      _initialized = true;
    } catch (e) {
      debugPrint('[Analytics] PostHog init failed: $e');
    }
  }

  /// Set the authenticated user ID for attribution.
  void setUserId(String? userId) {
    _userId = userId;
    if (_initialized) {
      if (userId != null) {
        Posthog().identify(userId: userId);
      } else {
        Posthog().reset();
      }
    }
    if (kDebugMode) {
      debugPrint('[Analytics] userId=${userId ?? 'null'}');
    }
  }

  /// Track a screen view.
  void trackScreen(String screenName) {
    if (_initialized) Posthog().screen(screenName: screenName);
    if (kDebugMode) {
      debugPrint('[Analytics] screen: $screenName');
    }
  }

  /// Track a custom event with optional parameters.
  void trackEvent(String name, [Map<String, dynamic>? params]) {
    if (_initialized) Posthog().capture(eventName: name, properties: params?.cast<String, Object>());
    if (kDebugMode) {
      final extra = params != null ? ' $params' : '';
      debugPrint('[Analytics] event: $name$extra');
    }
  }

  /// Current user ID (if set).
  String? get userId => _userId;
}
