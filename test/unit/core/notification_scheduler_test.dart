import 'package:flutter_test/flutter_test.dart';
import 'package:trysomething/core/notifications/notification_scheduler.dart';
import 'package:trysomething/models/hobby.dart';

void main() {
  group('NotificationScheduler.selectReminderHobby', () {
    UserHobby hobby(HobbyStatus status, {DateTime? lastActivityAt}) =>
        UserHobby(
          hobbyId: 'x',
          status: status,
          lastActivityAt: lastActivityAt,
        );

    test('returns null when there is nothing to remind about', () {
      expect(NotificationScheduler.selectReminderHobby({}), isNull);
      expect(
        NotificationScheduler.selectReminderHobby({
          'a': hobby(HobbyStatus.done),
          'b': hobby(HobbyStatus.paused),
        }),
        isNull,
      );
    });

    test('picks exactly one hobby even when several are stalled', () {
      // The bug this guards against: 4 trying hobbies used to produce 4
      // identical notifications delivered at the same instant.
      final pick = NotificationScheduler.selectReminderHobby({
        'a': hobby(HobbyStatus.trying),
        'b': hobby(HobbyStatus.trying),
        'c': hobby(HobbyStatus.trying),
        'd': hobby(HobbyStatus.trying),
      });
      expect(pick, isNotNull);
    });

    test('active beats trying beats saved', () {
      final pick = NotificationScheduler.selectReminderHobby({
        'saved': hobby(HobbyStatus.saved),
        'trying': hobby(HobbyStatus.trying),
        'active': hobby(HobbyStatus.active),
      });
      expect(pick!.key, 'active');

      final pick2 = NotificationScheduler.selectReminderHobby({
        'saved': hobby(HobbyStatus.saved),
        'trying': hobby(HobbyStatus.trying),
      });
      expect(pick2!.key, 'trying');
    });

    test('ties broken by most recent activity', () {
      final pick = NotificationScheduler.selectReminderHobby({
        'old': hobby(
          HobbyStatus.trying,
          lastActivityAt: DateTime(2026, 8, 1),
        ),
        'recent': hobby(
          HobbyStatus.trying,
          lastActivityAt: DateTime(2026, 8, 18),
        ),
        'undated': hobby(HobbyStatus.trying),
      });
      expect(pick!.key, 'recent');
    });
  });
}
