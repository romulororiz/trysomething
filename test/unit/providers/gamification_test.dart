import 'package:flutter_test/flutter_test.dart';
import 'package:trysomething/data/repositories/gamification_repository.dart';
import 'package:trysomething/models/features.dart';
import 'package:trysomething/models/gamification.dart';
import 'package:trysomething/providers/feature_providers.dart';

/// Mock repository that tracks calls and can be configured to fail.
class MockGamificationRepository implements GamificationRepository {
  bool shouldFail = false;
  final List<String> calls = [];

  List<Challenge> serverChallenges = [];
  List<Achievement> serverAchievements = [];

  @override
  Future<List<Challenge>> getChallenges() async {
    calls.add('getChallenges');
    if (shouldFail) throw Exception('mock failure');
    return serverChallenges;
  }

  @override
  Future<List<Achievement>> getAchievements() async {
    calls.add('getAchievements');
    if (shouldFail) throw Exception('mock failure');
    return serverAchievements;
  }
}

void main() {
  // ═══════════════════════════════════════════════════════
  //  CHALLENGES
  // ═══════════════════════════════════════════════════════

  group('ChallengeNotifier', () {
    late MockGamificationRepository repo;
    late ChallengeNotifier notifier;

    setUp(() {
      repo = MockGamificationRepository();
      notifier = ChallengeNotifier(repo);
    });

    test('loadFromServer populates state', () async {
      repo.serverChallenges = [
        Challenge(
          id: 'ch1',
          title: 'Try Something New',
          description: 'Save a new hobby this week',
          targetCount: 1,
          currentCount: 0,
          startDate: DateTime(2026, 3, 2),
          endDate: DateTime(2026, 3, 9),
        ),
        Challenge(
          id: 'ch2',
          title: 'Complete Steps',
          description: 'Complete 3 roadmap steps',
          targetCount: 3,
          currentCount: 3,
          startDate: DateTime(2026, 2, 23),
          endDate: DateTime(2026, 3, 2),
          isCompleted: true,
        ),
      ];

      await notifier.loadFromServer();

      expect(notifier.state, hasLength(2));
      expect(notifier.state.first.title, 'Try Something New');
      expect(notifier.state.last.isCompleted, isTrue);
      expect(repo.calls, ['getChallenges']);
    });

    test('loadFromServer handles failure gracefully', () async {
      repo.shouldFail = true;
      await notifier.loadFromServer();
      expect(notifier.state, isEmpty);
    });

    test('state starts empty', () {
      expect(notifier.state, isEmpty);
    });
  });

  // ═══════════════════════════════════════════════════════
  //  ACHIEVEMENTS
  // ═══════════════════════════════════════════════════════

  group('AchievementsNotifier', () {
    late MockGamificationRepository repo;
    late AchievementsNotifier notifier;

    setUp(() {
      repo = MockGamificationRepository();
      notifier = AchievementsNotifier(repo);
    });

    test('loadFromServer populates state', () async {
      repo.serverAchievements = [
        Achievement(
          id: 'first_save',
          title: 'First Steps',
          description: 'Saved your first hobby',
          icon: '🌱',
          unlockedAt: DateTime(2026, 2, 15),
        ),
        const Achievement(
          id: 'explorer',
          title: 'Explorer',
          description: 'Tried 3 different hobbies',
          icon: '🧭',
        ),
      ];

      await notifier.loadFromServer();

      expect(notifier.state, hasLength(2));
      expect(notifier.state.first.title, 'First Steps');
      expect(notifier.state.first.unlockedAt, isNotNull);
      expect(notifier.state.last.unlockedAt, isNull);
      expect(repo.calls, ['getAchievements']);
    });

    test('loadFromServer handles failure gracefully', () async {
      repo.shouldFail = true;
      await notifier.loadFromServer();
      expect(notifier.state, isEmpty);
    });

    test('unlocked achievements have non-null unlockedAt', () async {
      repo.serverAchievements = [
        Achievement(
          id: 'first_save',
          title: 'First Steps',
          description: 'Saved your first hobby',
          icon: '🌱',
          unlockedAt: DateTime(2026, 2, 15),
        ),
        Achievement(
          id: 'first_step',
          title: 'Getting Started',
          description: 'Completed your first step',
          icon: '👣',
          unlockedAt: DateTime(2026, 2, 20),
        ),
        const Achievement(
          id: 'dedicated',
          title: 'Dedicated',
          description: 'Completed 10 roadmap steps',
          icon: '💪',
        ),
      ];

      await notifier.loadFromServer();

      final unlocked =
          notifier.state.where((a) => a.unlockedAt != null).toList();
      final locked =
          notifier.state.where((a) => a.unlockedAt == null).toList();

      expect(unlocked, hasLength(2));
      expect(locked, hasLength(1));
      expect(locked.first.id, 'dedicated');
    });

    test('state starts empty', () {
      expect(notifier.state, isEmpty);
    });
  });
}
