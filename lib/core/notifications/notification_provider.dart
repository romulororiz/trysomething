import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'notification_service.dart';

/// Global notification service singleton.
/// Override this provider in main.dart once Firebase is configured.
final notificationProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});
