import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../../models/hobby.dart';

/// Notification IDs — stable per hobby to avoid duplicates.
/// Uses hobbyId hashCode modulo 100000 + offset per type.
int _notifId(String hobbyId, int offset) =>
    (hobbyId.hashCode.abs() % 100000) + offset;

const _kSavedOffset = 0;
const _kSilentOffset = 100000;
const _kStepOffset = 200000;

/// Schedules local re-engagement notifications based on user hobby state.
class NotificationScheduler {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Initialize the local notifications plugin + timezone data.
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false, // already requested via FCM
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(settings);

    // Create Android notification channel
    if (!kIsWeb && Platform.isAndroid) {
      final androidPlugin =
          _plugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          'reengagement',
          'Re-engagement',
          description: 'Gentle reminders to keep your hobby going',
          importance: Importance.defaultImportance,
        ),
      );
    }
  }

  /// Schedule all re-engagement notifications based on current hobby state.
  /// Call this whenever hobby state changes (save, start, toggle step, etc.).
  Future<void> reschedule({
    required Map<String, UserHobby> hobbies,
    required String Function(String hobbyId) hobbyTitle,
  }) async {
    if (!_initialized) return;

    // Cancel all existing re-engagement notifications first
    await _plugin.cancelAll();

    final now = DateTime.now();

    for (final entry in hobbies.entries) {
      final hobbyId = entry.key;
      final hobby = entry.value;
      final title = hobbyTitle(hobbyId);

      switch (hobby.status) {
        case HobbyStatus.saved:
          // Saved but never started → remind after 24h from now
          await _scheduleSavedReminder(hobbyId, title);
          break;

        case HobbyStatus.trying:
        case HobbyStatus.active:
          // Check if stalled (3+ days since last activity or start)
          final lastActive = hobby.lastActivityAt ?? hobby.startedAt ?? now;
          final daysSilent = now.difference(lastActive).inDays;
          if (daysSilent >= 2) {
            // Already stalled — schedule for tomorrow morning
            await _scheduleSilentReminder(hobbyId, title);
          } else {
            // Not stalled yet — schedule for 3 days from last activity
            await _scheduleSilentReminderAt(
              hobbyId,
              title,
              lastActive.add(const Duration(days: 3)),
            );
          }
          break;

        case HobbyStatus.done:
        case HobbyStatus.paused: // No reminders while paused
          break;
      }
    }
  }

  /// Immediate notification when user completes a step.
  Future<void> notifyStepCompleted({
    required String hobbyId,
    required String stepTitle,
    required String hobbyTitle,
  }) async {
    if (!_initialized) return;

    await _plugin.show(
      _notifId(hobbyId, _kStepOffset),
      '$stepTitle done!',
      'Nice progress on $hobbyTitle. Here\'s what comes next.',
      _details,
    );
  }

  // ── Private scheduling helpers ──────────────────────────

  Future<void> _scheduleSavedReminder(String hobbyId, String title) async {
    final when = tz.TZDateTime.now(tz.local).add(const Duration(hours: 24));
    await _plugin.zonedSchedule(
      _notifId(hobbyId, _kSavedOffset),
      'Ready to try $title?',
      'Your first session is just 15-20 minutes. Start small tonight.',
      when,
      _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: null,
    );
  }

  Future<void> _scheduleSilentReminder(String hobbyId, String title) async {
    // Schedule for 9am tomorrow
    final now = tz.TZDateTime.now(tz.local);
    var when = tz.TZDateTime(tz.local, now.year, now.month, now.day + 1, 9);
    if (when.isBefore(now)) {
      when = when.add(const Duration(days: 1));
    }
    await _scheduleSilentReminderAt(hobbyId, title, when);
  }

  Future<void> _scheduleSilentReminderAt(
    String hobbyId,
    String title,
    DateTime scheduledDate,
  ) async {
    final when = tz.TZDateTime.from(scheduledDate, tz.local);
    if (when.isBefore(tz.TZDateTime.now(tz.local))) return;

    await _plugin.zonedSchedule(
      _notifId(hobbyId, _kSilentOffset),
      'Still interested in $title?',
      'Try a quick 10-minute session tonight. Small steps count.',
      when,
      _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: null,
    );
  }

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'reengagement',
      'Re-engagement',
      channelDescription: 'Gentle reminders to keep your hobby going',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    ),
    iOS: DarwinNotificationDetails(),
  );
}
