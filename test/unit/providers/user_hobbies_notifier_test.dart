import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trysomething/core/analytics/analytics_service.dart';
import 'package:trysomething/data/repositories/user_progress_repository.dart';
import 'package:trysomething/models/hobby.dart';
import 'package:trysomething/providers/user_provider.dart';

/// Mock repository that tracks calls and can be configured to fail.
class MockUserProgressRepository implements UserProgressRepository {
  bool shouldFail = false;
  final List<String> calls = [];

  @override
  Future<List<UserHobby>> getHobbies() async {
    calls.add('getHobbies');
    if (shouldFail) throw Exception('mock failure');
    return [];
  }

  @override
  Future<UserHobby> saveHobby(String hobbyId) async {
    calls.add('saveHobby:$hobbyId');
    if (shouldFail) throw Exception('mock failure');
    return UserHobby(hobbyId: hobbyId, status: HobbyStatus.saved);
  }

  @override
  Future<void> unsaveHobby(String hobbyId) async {
    calls.add('unsaveHobby:$hobbyId');
    if (shouldFail) throw Exception('mock failure');
  }

  @override
  Future<UserHobby> updateStatus(
    String hobbyId,
    HobbyStatus status, {
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? pausedAt,
    int? pausedDurationDays,
    DateTime? lastActivityAt,
  }) async {
    calls.add('updateStatus:$hobbyId:${status.name}');
    if (shouldFail) throw Exception('mock failure');
    return UserHobby(hobbyId: hobbyId, status: status);
  }

  @override
  Future<(UserHobby, bool)> toggleStep(String hobbyId, String stepId) async {
    calls.add('toggleStep:$hobbyId:$stepId');
    if (shouldFail) throw Exception('mock failure');
    return (UserHobby(hobbyId: hobbyId, status: HobbyStatus.trying), false);
  }

  @override
  Future<List<UserHobby>> syncHobbies(List<UserHobby> hobbies) async {
    calls.add('syncHobbies:${hobbies.length}');
    if (shouldFail) throw Exception('mock failure');
    return hobbies;
  }

  @override
  Future<List<Map<String, dynamic>>> getActivityLog({int days = 365}) async {
    calls.add('getActivityLog:$days');
    if (shouldFail) throw Exception('mock failure');
    return [];
  }
}

void main() {
  late SharedPreferences prefs;
  late MockUserProgressRepository mockRepo;
  late UserHobbiesNotifier notifier;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    mockRepo = MockUserProgressRepository();
    notifier = UserHobbiesNotifier(prefs, mockRepo, AnalyticsService());
  });

  group('UserHobbiesNotifier', () {
    test('starts with empty state', () {
      expect(notifier.state, isEmpty);
    });

    test('saveHobby adds hobby to state', () {
      notifier.saveHobby('pottery');
      expect(notifier.state.containsKey('pottery'), isTrue);
      expect(notifier.state['pottery']!.status, HobbyStatus.saved);
    });

    test('saveHobby fires API call', () async {
      notifier.saveHobby('pottery');
      // Wait for async API call
      await Future.delayed(Duration.zero);
      expect(mockRepo.calls, contains('saveHobby:pottery'));
    });

    test('saveHobby is idempotent', () {
      notifier.saveHobby('pottery');
      notifier.saveHobby('pottery');
      expect(notifier.state.length, 1);
    });

    test('unsaveHobby removes saved hobby', () {
      notifier.saveHobby('pottery');
      notifier.unsaveHobby('pottery');
      expect(notifier.state.containsKey('pottery'), isFalse);
    });

    test('unsaveHobby does not remove non-saved hobby', () {
      notifier.saveHobby('pottery');
      notifier.startTrying('pottery');
      notifier.unsaveHobby('pottery');
      // Should still be there because status is trying, not saved
      expect(notifier.state.containsKey('pottery'), isTrue);
    });

    test('toggleSave adds then removes', () {
      notifier.toggleSave('pottery');
      expect(notifier.state.containsKey('pottery'), isTrue);
      notifier.toggleSave('pottery');
      expect(notifier.state.containsKey('pottery'), isFalse);
    });

    test('startTrying changes status to trying', () {
      notifier.saveHobby('pottery');
      notifier.startTrying('pottery');
      expect(notifier.state['pottery']!.status, HobbyStatus.trying);
      expect(notifier.state['pottery']!.startedAt, isNotNull);
    });

    test('setActive changes status to active', () {
      notifier.saveHobby('pottery');
      notifier.startTrying('pottery');
      notifier.setActive('pottery');
      expect(notifier.state['pottery']!.status, HobbyStatus.active);
    });

    test('setDone changes status to done', () {
      notifier.saveHobby('pottery');
      notifier.startTrying('pottery');
      notifier.setDone('pottery');
      expect(notifier.state['pottery']!.status, HobbyStatus.done);
    });

    test('toggleStep adds step to completedStepIds', () {
      notifier.saveHobby('pottery');
      notifier.startTrying('pottery');
      notifier.toggleStep('pottery', 'step-1');
      expect(
        notifier.state['pottery']!.completedStepIds.contains('step-1'),
        isTrue,
      );
    });

    test('toggleStep removes step when toggled again', () {
      notifier.saveHobby('pottery');
      notifier.startTrying('pottery');
      notifier.toggleStep('pottery', 'step-1');
      notifier.toggleStep('pottery', 'step-1');
      expect(
        notifier.state['pottery']!.completedStepIds.contains('step-1'),
        isFalse,
      );
    });

    test('isStepCompleted returns correct value', () {
      notifier.saveHobby('pottery');
      notifier.toggleStep('pottery', 'step-1');
      expect(notifier.isStepCompleted('pottery', 'step-1'), isTrue);
      expect(notifier.isStepCompleted('pottery', 'step-2'), isFalse);
    });

    test('getByStatus filters correctly', () {
      notifier.saveHobby('pottery');
      notifier.saveHobby('bouldering');
      notifier.startTrying('pottery');

      final saved = notifier.getByStatus(HobbyStatus.saved);
      final trying = notifier.getByStatus(HobbyStatus.trying);
      expect(saved.length, 1);
      expect(saved.first.hobbyId, 'bouldering');
      expect(trying.length, 1);
      expect(trying.first.hobbyId, 'pottery');
    });

    test('persists state to SharedPreferences', () {
      notifier.saveHobby('pottery');
      final stored = prefs.getString('user_hobbies');
      expect(stored, isNotNull);
      expect(stored!, contains('pottery'));
    });

    group('optimistic rollback', () {
      test('saveHobby rolls back on API failure', () async {
        mockRepo.shouldFail = true;
        notifier.saveHobby('pottery');
        expect(notifier.state.containsKey('pottery'), isTrue);

        // Wait for async failure + rollback
        await Future.delayed(const Duration(milliseconds: 50));
        expect(notifier.state.containsKey('pottery'), isFalse);
      });

      test('unsaveHobby rolls back on API failure', () async {
        notifier.saveHobby('pottery');
        await Future.delayed(Duration.zero);

        mockRepo.shouldFail = true;
        notifier.unsaveHobby('pottery');
        expect(notifier.state.containsKey('pottery'), isFalse);

        await Future.delayed(const Duration(milliseconds: 50));
        expect(notifier.state.containsKey('pottery'), isTrue);
      });
    });

    group('syncFromServer', () {
      test('replaces local state with server data', () async {
        notifier.saveHobby('local-hobby');
        mockRepo.shouldFail = false;

        // Override getHobbies to return server data
        final serverRepo = _ServerDataRepo([
          const UserHobby(hobbyId: 'server-hobby', status: HobbyStatus.active),
        ]);
        final syncNotifier = UserHobbiesNotifier(prefs, serverRepo, AnalyticsService());
        syncNotifier.saveHobby('local-hobby');

        await syncNotifier.syncFromServer();
        expect(syncNotifier.state.containsKey('server-hobby'), isTrue);
        expect(syncNotifier.state.containsKey('local-hobby'), isFalse);
      });

      test('pushes local to server when server is empty', () async {
        notifier.saveHobby('local-hobby');
        await notifier.syncFromServer();

        expect(mockRepo.calls, contains('getHobbies'));
        expect(mockRepo.calls, contains('syncHobbies:1'));
      });
    });
  });
}

/// Helper repo that returns preset server data from getHobbies.
class _ServerDataRepo implements UserProgressRepository {
  final List<UserHobby> _serverHobbies;
  _ServerDataRepo(this._serverHobbies);

  @override
  Future<List<UserHobby>> getHobbies() async => _serverHobbies;
  @override
  Future<UserHobby> saveHobby(String hobbyId) async =>
      UserHobby(hobbyId: hobbyId, status: HobbyStatus.saved);
  @override
  Future<void> unsaveHobby(String hobbyId) async {}
  @override
  Future<UserHobby> updateStatus(String hobbyId, HobbyStatus status,
          {DateTime? startedAt, DateTime? completedAt, DateTime? pausedAt,
           int? pausedDurationDays, DateTime? lastActivityAt}) async =>
      UserHobby(hobbyId: hobbyId, status: status);
  @override
  Future<(UserHobby, bool)> toggleStep(String hobbyId, String stepId) async =>
      (UserHobby(hobbyId: hobbyId, status: HobbyStatus.trying), false);
  @override
  Future<List<UserHobby>> syncHobbies(List<UserHobby> hobbies) async => hobbies;
  @override
  Future<List<Map<String, dynamic>>> getActivityLog({int days = 365}) async =>
      [];
}
