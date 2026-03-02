import 'package:flutter_test/flutter_test.dart';
import 'package:trysomething/models/hobby.dart';

void main() {
  group('Hobby serialization', () {
    test('round-trips through JSON', () {
      final hobby = Hobby(
        id: 'pottery',
        title: 'Pottery',
        hook: 'Shape clay into art',
        category: 'Creative',
        imageUrl: 'https://example.com/pottery.jpg',
        tags: ['relaxing', 'creative', 'hands-on'],
        costText: 'CHF 50',
        timeText: '3h/week',
        difficultyText: 'Beginner',
        whyLove: 'Mindful and meditative',
        difficultyExplain: 'Easy to start',
        starterKit: [
          KitItem(name: 'Clay', description: '2kg air-dry', cost: 15),
          KitItem(name: 'Tools', description: 'Basic set', cost: 25, isOptional: true),
        ],
        pitfalls: ['Drying too fast', 'Uneven thickness'],
        roadmapSteps: [
          RoadmapStep(
            id: 'step1',
            title: 'Pinch pot',
            description: 'Make your first pinch pot',
            estimatedMinutes: 30,
            milestone: 'First pot!',
          ),
          RoadmapStep(
            id: 'step2',
            title: 'Coil building',
            description: 'Learn coil technique',
            estimatedMinutes: 45,
          ),
        ],
      );

      final json = hobby.toJson();
      final restored = Hobby.fromJson(json);

      expect(restored.id, hobby.id);
      expect(restored.title, hobby.title);
      expect(restored.tags, hobby.tags);
      expect(restored.starterKit.length, 2);
      expect(restored.starterKit[1].isOptional, true);
      expect(restored.roadmapSteps.length, 2);
      expect(restored.roadmapSteps[0].milestone, 'First pot!');
      expect(restored.roadmapSteps[1].milestone, isNull);
    });
  });

  group('KitItem serialization', () {
    test('round-trips with defaults', () {
      final item = KitItem(name: 'Brush', description: 'Wide', cost: 10);
      final json = item.toJson();
      final restored = KitItem.fromJson(json);

      expect(restored.name, 'Brush');
      expect(restored.isOptional, false);
    });
  });

  group('RoadmapStep serialization', () {
    test('round-trips with nullable milestone', () {
      final step = RoadmapStep(
        id: 's1',
        title: 'Step 1',
        description: 'Do it',
        estimatedMinutes: 20,
      );
      final json = step.toJson();
      final restored = RoadmapStep.fromJson(json);

      expect(restored.id, 's1');
      expect(restored.milestone, isNull);
    });
  });

  group('HobbyCategory serialization', () {
    test('round-trips through JSON', () {
      final cat = HobbyCategory(
        id: 'creative',
        name: 'Creative',
        count: 5,
        imageUrl: 'https://example.com/creative.jpg',
      );
      final json = cat.toJson();
      final restored = HobbyCategory.fromJson(json);

      expect(restored.id, 'creative');
      expect(restored.count, 5);
    });
  });

  group('UserHobby serialization', () {
    test('round-trips with Set<String> completedStepIds', () {
      final uh = UserHobby(
        hobbyId: 'pottery',
        status: HobbyStatus.trying,
        completedStepIds: {'step1', 'step2'},
        startedAt: DateTime(2026, 1, 15),
        lastActivityAt: DateTime(2026, 2, 20),
        streakDays: 7,
      );
      final json = uh.toJson();
      final restored = UserHobby.fromJson(json);

      expect(restored.hobbyId, 'pottery');
      expect(restored.status, HobbyStatus.trying);
      expect(restored.completedStepIds, {'step1', 'step2'});
      expect(restored.streakDays, 7);
    });

    test('progressPercent calculates correctly', () {
      final uh = UserHobby(
        hobbyId: 'test',
        status: HobbyStatus.active,
        completedStepIds: {'a', 'b'},
      );
      expect(uh.progressPercent(4), 0.5);
      expect(uh.progressPercent(0), 0.0);
    });
  });

  group('UserPreferences serialization', () {
    test('round-trips with Set<String> vibes', () {
      final prefs = UserPreferences(
        hoursPerWeek: 5,
        budgetLevel: 2,
        preferSocial: true,
        vibes: {'relaxing', 'creative'},
      );
      final json = prefs.toJson();
      final restored = UserPreferences.fromJson(json);

      expect(restored.hoursPerWeek, 5);
      expect(restored.budgetLevel, 2);
      expect(restored.preferSocial, true);
      expect(restored.vibes, {'relaxing', 'creative'});
    });

    test('defaults are correct', () {
      final prefs = UserPreferences();
      expect(prefs.hoursPerWeek, 3);
      expect(prefs.budgetLevel, 1);
      expect(prefs.preferSocial, false);
      expect(prefs.vibes, isEmpty);
    });
  });
}
