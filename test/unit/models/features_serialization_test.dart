import 'package:flutter_test/flutter_test.dart';
import 'package:trysomething/models/features.dart';

void main() {
  group('UserProfile serialization', () {
    test('round-trips with defaults', () {
      final profile = UserProfile();
      final json = profile.toJson();
      final restored = UserProfile.fromJson(json);

      expect(restored.username, 'Your Name');
      expect(restored.bio, '');
      expect(restored.avatarUrl, isNull);
    });

    test('round-trips with values', () {
      final profile = UserProfile(
        username: 'Alice',
        bio: 'Hobby explorer',
        avatarUrl: 'https://example.com/avatar.jpg',
      );
      final json = profile.toJson();
      final restored = UserProfile.fromJson(json);

      expect(restored.username, 'Alice');
      expect(restored.avatarUrl, 'https://example.com/avatar.jpg');
    });
  });

  group('Challenge serialization', () {
    test('round-trips through JSON', () {
      final challenge = Challenge(
        id: 'c1',
        title: 'Try 3 Hobbies',
        description: 'Explore something new',
        targetCount: 3,
        currentCount: 1,
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 31),
      );
      final json = challenge.toJson();
      final restored = Challenge.fromJson(json);

      expect(restored.id, 'c1');
      expect(restored.targetCount, 3);
      expect(restored.currentCount, 1);
      expect(restored.isCompleted, false);
    });
  });

  group('ScheduleEvent serialization', () {
    test('round-trips through JSON', () {
      final event = ScheduleEvent(
        id: 'ev1',
        hobbyId: 'pottery',
        dayOfWeek: 3,
        startTime: '19:00',
        durationMinutes: 60,
      );
      final json = event.toJson();
      final restored = ScheduleEvent.fromJson(json);

      expect(restored.dayOfWeek, 3);
      expect(restored.startTime, '19:00');
      expect(restored.durationMinutes, 60);
    });
  });

  group('HobbyCombo serialization', () {
    test('round-trips through JSON', () {
      final combo = HobbyCombo(
        hobbyId1: 'pottery',
        hobbyId2: 'calligraphy',
        reason: 'Both are meditative',
        sharedTags: ['creative', 'relaxing'],
      );
      final json = combo.toJson();
      final restored = HobbyCombo.fromJson(json);

      expect(restored.hobbyId1, 'pottery');
      expect(restored.sharedTags, ['creative', 'relaxing']);
    });
  });

  group('FaqItem serialization', () {
    test('round-trips through JSON', () {
      final faq = FaqItem(
        question: 'How to start?',
        answer: 'Just begin!',
        upvotes: 42,
      );
      final json = faq.toJson();
      final restored = FaqItem.fromJson(json);

      expect(restored.question, 'How to start?');
      expect(restored.upvotes, 42);
    });
  });

  group('CostBreakdown serialization', () {
    test('round-trips through JSON', () {
      final cost = CostBreakdown(
        starter: 50,
        threeMonth: 150,
        oneYear: 400,
        tips: ['Buy used', 'Start small'],
      );
      final json = cost.toJson();
      final restored = CostBreakdown.fromJson(json);

      expect(restored.starter, 50);
      expect(restored.tips.length, 2);
    });
  });

  group('BudgetAlternative serialization', () {
    test('round-trips through JSON', () {
      final alt = BudgetAlternative(
        itemName: 'Clay',
        diyOption: 'Homemade',
        diyCost: 0,
        budgetOption: 'Air-dry clay',
        budgetCost: 10,
        premiumOption: 'Kiln clay',
        premiumCost: 30,
      );
      final json = alt.toJson();
      final restored = BudgetAlternative.fromJson(json);

      expect(restored.itemName, 'Clay');
      expect(restored.diyCost, 0);
      expect(restored.premiumCost, 30);
    });
  });
}
