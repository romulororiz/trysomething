import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  /// Picks the single hobby worth reminding about, or null when none
  /// qualifies. Precedence: active > trying > saved (matches the product's
  /// one-hobby focus); ties broken by most recent activity. Scheduling one
  /// reminder total — instead of one per hobby — prevents accounts with
  /// several stalled hobbies from receiving a burst of identical
  /// notifications at the same instant.
  @visibleForTesting
  static MapEntry<String, UserHobby>? selectReminderHobby(
    Map<String, UserHobby> hobbies,
  ) {
    const rank = {
      HobbyStatus.active: 0,
      HobbyStatus.trying: 1,
      HobbyStatus.saved: 2,
    };

    MapEntry<String, UserHobby>? best;
    for (final entry in hobbies.entries) {
      final r = rank[entry.value.status];
      if (r == null) continue; // done/paused: no reminders

      if (best == null) {
        best = entry;
        continue;
      }
      final bestRank = rank[best.value.status]!;
      if (r < bestRank) {
        best = entry;
      } else if (r == bestRank) {
        final a = entry.value.lastActivityAt ?? entry.value.startedAt;
        final b = best.value.lastActivityAt ?? best.value.startedAt;
        if (b == null || (a != null && a.isAfter(b))) best = entry;
      }
    }
    return best;
  }

  /// Schedule the re-engagement notification based on current hobby state.
  /// Call this whenever hobby state changes (save, start, toggle step, etc.).
  Future<void> reschedule({
    required Map<String, UserHobby> hobbies,
    required String Function(String hobbyId) hobbyTitle,
  }) async {
    if (!_initialized) return;

    // Respect the notifications toggle in Settings
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool('notifications_enabled') ?? true)) {
      await _plugin.cancelAll();
      return;
    }

    // Cancel all existing re-engagement notifications first
    await _plugin.cancelAll();

    final pick = selectReminderHobby(hobbies);
    if (pick == null) return;

    final now = DateTime.now();
    final hobbyId = pick.key;
    final hobby = pick.value;
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
          // Already stalled — schedule for tomorrow evening
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
      case HobbyStatus.paused:
        break;
    }
  }

  /// Immediate notification when user completes a step.
  Future<void> notifyStepCompleted({
    required String hobbyId,
    required String stepTitle,
    required String hobbyTitle,
  }) async {
    if (!_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool('notifications_enabled') ?? true)) return;

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
    final now = tz.TZDateTime.now(tz.local);
    await _scheduleSilentReminderAt(
      hobbyId,
      title,
      DateTime(now.year, now.month, now.day + 1),
    );
  }

  Future<void> _scheduleSilentReminderAt(
    String hobbyId,
    String title,
    DateTime scheduledDate,
  ) async {
    // Deliver at 19:00 local on the target day — the copy says "tonight",
    // so a morning delivery reads wrong.
    final when = tz.TZDateTime(
      tz.local,
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
      19,
    );
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
