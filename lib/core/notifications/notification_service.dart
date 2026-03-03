import 'package:flutter/foundation.dart';

/// Push notification service stub. Currently logs to console.
///
/// To activate FCM:
/// 1. Create a Firebase project at https://console.firebase.google.com
/// 2. Run `flutterfire configure` to generate config files
/// 3. Add `firebase_core` and `firebase_messaging` to pubspec.yaml
/// 4. Initialize Firebase in main.dart before this service
/// 5. Replace this stub with real FCM calls
class NotificationService {
  bool _initialized = false;

  /// Whether the service has been initialized.
  bool get isInitialized => _initialized;

  /// Initialize the notification service.
  /// No-ops until Firebase is configured.
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    if (kDebugMode) {
      debugPrint('[Notifications] Service initialized (stub — FCM not configured)');
    }
  }

  /// Request notification permission from the user.
  /// Returns true if granted (stub always returns false).
  Future<bool> requestPermission() async {
    if (kDebugMode) {
      debugPrint('[Notifications] requestPermission (stub)');
    }
    return false;
  }

  /// Get the FCM device token. Returns null until Firebase is configured.
  Future<String?> getToken() async {
    if (kDebugMode) {
      debugPrint('[Notifications] getToken (stub — no Firebase)');
    }
    return null;
  }

  /// Register a callback for foreground messages.
  void onMessage(void Function(Map<String, dynamic> data) handler) {
    if (kDebugMode) {
      debugPrint('[Notifications] onMessage registered (stub)');
    }
  }
}
