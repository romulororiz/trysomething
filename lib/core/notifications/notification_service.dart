import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Handle background messages (must be a top-level function).
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    debugPrint('[Notifications] Background message: ${message.messageId}');
  }
}

/// Push notification service powered by Firebase Cloud Messaging.
class NotificationService {
  bool _initialized = false;
  FirebaseMessaging? _messagingInstance;
  FirebaseMessaging get _messaging => _messagingInstance ??= FirebaseMessaging.instance;
  final List<void Function(RemoteMessage)> _foregroundListeners = [];

  bool get isInitialized => _initialized;

  /// Initialize FCM, request permission, and listen for foreground messages.
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    // Register background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Request permission (iOS requires explicit prompt, Android auto-grants)
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (kDebugMode) {
      debugPrint(
        '[Notifications] Permission: ${settings.authorizationStatus}',
      );
    }

    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        debugPrint(
          '[Notifications] Foreground message: ${message.notification?.title}',
        );
      }
      for (final listener in _foregroundListeners) {
        listener(message);
      }
    });

    // Handle notification taps when app is in background/terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        debugPrint(
          '[Notifications] Opened from notification: ${message.data}',
        );
      }
    });

    if (kDebugMode) {
      final token = await _messaging.getToken();
      debugPrint('[Notifications] FCM token: $token');
    }
  }

  /// Request notification permission. Returns true if granted.
  Future<bool> requestPermission() async {
    final settings = await _messaging.requestPermission();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  /// Get the FCM device token for server registration.
  Future<String?> getToken() async {
    return _messaging.getToken();
  }

  /// Listen for token refreshes (e.g. after app reinstall).
  void onTokenRefresh(void Function(String token) handler) {
    _messaging.onTokenRefresh.listen(handler);
  }

  /// Register a callback for foreground messages.
  void onMessage(void Function(RemoteMessage message) handler) {
    _foregroundListeners.add(handler);
  }
}
