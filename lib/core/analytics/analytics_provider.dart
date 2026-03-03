import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'analytics_service.dart';

/// Global analytics service singleton.
final analyticsProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});

/// GoRouter NavigatorObserver that auto-tracks screen views.
class AnalyticsObserver extends NavigatorObserver {
  final AnalyticsService _analytics;

  AnalyticsObserver(this._analytics);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _trackRoute(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) _trackRoute(newRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute != null) _trackRoute(previousRoute);
  }

  void _trackRoute(Route<dynamic> route) {
    final name = route.settings.name;
    if (name != null && name.isNotEmpty) {
      _analytics.trackScreen(name);
    }
  }
}
