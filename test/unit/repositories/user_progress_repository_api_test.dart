import 'package:flutter_test/flutter_test.dart';
import 'package:trysomething/models/hobby.dart';

// NOTE: UserProgressRepositoryApi is not tested directly because it uses
// ApiClient.instance (a global Dio singleton) and makes real HTTP calls.
// These tests exercise the UserHobby model serialization layer instead,
// which is the data contract consumed and produced by that repository.

void main() {
  group('HobbyStatus enum', () {
    test('has exactly the expected values', () {
      expect(HobbyStatus.values, hasLength(4));
      expect(HobbyStatus.values, containsAll([
        HobbyStatus.saved,
        HobbyStatus.trying,
        HobbyStatus.active,
        HobbyStatus.done,
      ]));
    });
  });

  group('UserHobby.fromJson', () {
    test('basic round-trip with all required fields', () {
      final json = <String, dynamic>{
        'hobbyId': 'hobby_42',
        'status': 'active',
        'completedStepIds': ['step_1', 'step_2'],
        'startedAt': '2026-01-15T10:00:00.000Z',
        'lastActivityAt': '2026-02-20T18:30:00.000Z',
        'streakDays': 7,
      };

      final userHobby = UserHobby.fromJson(json);

      expect(userHobby.hobbyId, 'hobby_42');
      expect(userHobby.status, HobbyStatus.active);
      expect(userHobby.completedStepIds, {'step_1', 'step_2'});
      expect(userHobby.startedAt, DateTime.parse('2026-01-15T10:00:00.000Z'));
      expect(userHobby.lastActivityAt, DateTime.parse('2026-02-20T18:30:00.000Z'));
      expect(userHobby.streakDays, 7);
    });

    test('completedStepIds as JSON list is converted to a Set', () {
      final json = <String, dynamic>{
        'hobbyId': 'hobby_1',
        'status': 'trying',
        'completedStepIds': ['a', 'b', 'c'],
      };

      final userHobby = UserHobby.fromJson(json);

      expect(userHobby.completedStepIds, isA<Set<String>>());
      expect(userHobby.completedStepIds, {'a', 'b', 'c'});
    });

    test('null dates are deserialized as null', () {
      final json = <String, dynamic>{
        'hobbyId': 'hobby_x',
        'status': 'saved',
        'completedStepIds': null,
        'startedAt': null,
        'lastActivityAt': null,
      };

      final userHobby = UserHobby.fromJson(json);

      expect(userHobby.startedAt, isNull);
      expect(userHobby.lastActivityAt, isNull);
      expect(userHobby.completedStepIds, isEmpty);
    });

    test('missing optional fields use defaults', () {
      final json = <String, dynamic>{
        'hobbyId': 'hobby_min',
        'status': 'saved',
      };

      final userHobby = UserHobby.fromJson(json);

      expect(userHobby.completedStepIds, isEmpty);
      expect(userHobby.streakDays, 0);
      expect(userHobby.startedAt, isNull);
      expect(userHobby.lastActivityAt, isNull);
    });
  });

  group('UserHobby.toJson', () {
    test('completedStepIds Set is serialized as a List in JSON', () {
      final userHobby = UserHobby(
        hobbyId: 'hobby_99',
        status: HobbyStatus.active,
        completedStepIds: {'step_a', 'step_b'},
        startedAt: DateTime.parse('2026-03-01T09:00:00.000'),
        streakDays: 3,
      );

      final json = userHobby.toJson();

      expect(json['hobbyId'], 'hobby_99');
      expect(json['status'], 'active');
      expect(json['completedStepIds'], isA<List>());
      expect((json['completedStepIds'] as List).toSet(), {'step_a', 'step_b'});
      expect(json['streakDays'], 3);
    });
  });

  group('UserHobby round-trip', () {
    test('toJson then fromJson preserves completedStepIds and all fields', () {
      final original = UserHobby(
        hobbyId: 'hobby_round',
        status: HobbyStatus.trying,
        completedStepIds: {'s1', 's2', 's3'},
        startedAt: DateTime.parse('2026-02-01T08:00:00.000'),
        lastActivityAt: DateTime.parse('2026-02-10T20:00:00.000'),
        streakDays: 5,
      );

      final restored = UserHobby.fromJson(original.toJson());

      expect(restored.hobbyId, original.hobbyId);
      expect(restored.status, original.status);
      expect(restored.completedStepIds, original.completedStepIds);
      expect(restored.startedAt, original.startedAt);
      expect(restored.lastActivityAt, original.lastActivityAt);
      expect(restored.streakDays, original.streakDays);
    });
  });

  group('UserHobby.copyWith', () {
    test('updates status while preserving all other fields', () {
      final original = UserHobby(
        hobbyId: 'hobby_copy',
        status: HobbyStatus.saved,
        completedStepIds: {'x', 'y'},
        startedAt: DateTime.parse('2026-01-01T00:00:00.000'),
        streakDays: 2,
      );

      final updated = original.copyWith(status: HobbyStatus.done);

      expect(updated.status, HobbyStatus.done);
      expect(updated.hobbyId, original.hobbyId);
      expect(updated.completedStepIds, original.completedStepIds);
      expect(updated.startedAt, original.startedAt);
      expect(updated.streakDays, original.streakDays);
    });
  });

  group('UserHobby with populated completedStepIds', () {
    test('fromJson correctly contains expected step IDs', () {
      final json = <String, dynamic>{
        'hobbyId': 'hobby_steps',
        'status': 'active',
        'completedStepIds': ['week1_buy_kit', 'week1_first_session', 'week2_repeat'],
        'streakDays': 10,
      };

      final userHobby = UserHobby.fromJson(json);

      expect(userHobby.completedStepIds, contains('week1_buy_kit'));
      expect(userHobby.completedStepIds, contains('week1_first_session'));
      expect(userHobby.completedStepIds, contains('week2_repeat'));
      expect(userHobby.completedStepIds.length, 3);
    });
  });
}
