import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'notification_service.dart';
import 'notification_scheduler.dart';

/// Global notification service singleton (FCM push).
/// Override this provider in main.dart once Firebase is configured.
final notificationProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Local notification scheduler for re-engagement reminders.
/// Override this provider in main.dart after initialization.
final notificationSchedulerProvider = Provider<NotificationScheduler>((ref) {
  return NotificationScheduler();
});
