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
///
/// Owns three FCM stream subscriptions (foreground messages, opened-app
/// taps, token refresh). All subscriptions are cancellable via [dispose]
/// so callers can be re-created without leaking listeners.
class NotificationService {
  bool _initialized = false;
  FirebaseMessaging? _messagingInstance;
  FirebaseMessaging get _messaging => _messagingInstance ??= FirebaseMessaging.instance;

  final List<void Function(RemoteMessage)> _foregroundListeners = [];
  final List<void Function(String)> _tokenRefreshListeners = [];

  StreamSubscription<RemoteMessage>? _onMessageSub;
  StreamSubscription<RemoteMessage>? _onMessageOpenedAppSub;
  StreamSubscription<String>? _onTokenRefreshSub;

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

    // Listen for foreground messages — fan out to registered listeners.
    _onMessageSub = FirebaseMessaging.onMessage.listen((RemoteMessage message) {
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
    _onMessageOpenedAppSub = FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage message) {
        if (kDebugMode) {
          debugPrint(
            '[Notifications] Opened from notification: ${message.data}',
          );
        }
      },
    );

    // Single token-refresh subscription that fans out to registered listeners.
    _onTokenRefreshSub = _messaging.onTokenRefresh.listen((String token) {
      for (final listener in _tokenRefreshListeners) {
        listener(token);
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

  /// Register a callback for FCM token refreshes (e.g. after app reinstall).
  /// Multiple handlers may be registered; all fire on each refresh.
  void onTokenRefresh(void Function(String token) handler) {
    _tokenRefreshListeners.add(handler);
  }

  /// Register a callback for foreground messages.
  void onMessage(void Function(RemoteMessage message) handler) {
    _foregroundListeners.add(handler);
  }

  /// Cancel all FCM stream subscriptions and clear registered listeners.
  /// Safe to call multiple times.
  Future<void> dispose() async {
    await _onMessageSub?.cancel();
    await _onMessageOpenedAppSub?.cancel();
    await _onTokenRefreshSub?.cancel();
    _onMessageSub = null;
    _onMessageOpenedAppSub = null;
    _onTokenRefreshSub = null;
    _foregroundListeners.clear();
    _tokenRefreshListeners.clear();
    _initialized = false;
  }
}
