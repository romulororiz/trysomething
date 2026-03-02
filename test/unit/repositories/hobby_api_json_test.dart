import 'package:flutter_test/flutter_test.dart';
import 'package:trysomething/models/hobby.dart';
import 'package:trysomething/models/features.dart';

/// Tests that Flutter Freezed models can parse API-shaped JSON correctly.
/// Uses the exact field names the server mapper produces.
void main() {
  group('Hobby.fromJson with API response shape', () {
    test('parses hobby with category (not categoryId) and starterKit (not kitItems)', () {
      final json = {
        'id': 'pottery',
        'title': 'Pottery',
        'hook': 'Get your hands dirty.',
        'category': 'creative',
        'imageUrl': 'https://example.com/img.jpg',
        'tags': ['creative', 'relaxing'],
        'costText': 'CHF 40–120',
        'timeText': '2h/week',
        'difficultyText': 'Moderate',
        'whyLove': 'Satisfying.',
        'difficultyExplain': 'Takes practice.',
        'starterKit': [
          {
            'name': 'Clay',
            'description': 'Air-dry clay',
            'cost': 10,
            'isOptional': false,
          },
        ],
        'pitfalls': ['Impatience'],
        'roadmapSteps': [
          {
            'id': 'step1',
            'title': 'First pot',
            'description': 'Make a pinch pot',
            'estimatedMinutes': 60,
            'milestone': 'First piece',
          },
        ],
      };

      final hobby = Hobby.fromJson(json);
      expect(hobby.id, 'pottery');
      expect(hobby.category, 'creative');
      expect(hobby.starterKit.length, 1);
      expect(hobby.starterKit.first.name, 'Clay');
      expect(hobby.roadmapSteps.length, 1);
      expect(hobby.roadmapSteps.first.milestone, 'First piece');
    });

    test('parses hobby with null milestone in roadmap step', () {
      final json = {
        'id': 'chess',
        'title': 'Chess',
        'hook': 'Think ahead.',
        'category': 'mind',
        'imageUrl': 'https://example.com/chess.jpg',
        'tags': ['strategic', 'competitive'],
        'costText': 'CHF 0–30',
        'timeText': '2h/week',
        'difficultyText': 'Easy',
        'whyLove': 'Infinite depth.',
        'difficultyExplain': 'Easy to learn.',
        'starterKit': <Map<String, dynamic>>[],
        'pitfalls': <String>[],
        'roadmapSteps': [
          {
            'id': 'step1',
            'title': 'Learn the rules',
            'description': 'Basic piece movement',
            'estimatedMinutes': 30,
            'milestone': null,
          },
        ],
      };

      final hobby = Hobby.fromJson(json);
      expect(hobby.roadmapSteps.first.milestone, isNull);
    });
  });

  group('HobbyCategory.fromJson with API response shape', () {
    test('parses category with count field', () {
      final json = {
        'id': 'creative',
        'name': 'Creative',
        'count': 5,
        'imageUrl': 'https://example.com/img.jpg',
      };

      final cat = HobbyCategory.fromJson(json);
      expect(cat.id, 'creative');
      expect(cat.count, 5);
    });
  });

  group('FaqItem.fromJson with API response shape', () {
    test('parses FAQ without id or hobbyId', () {
      final json = {
        'question': 'Do I need a kiln?',
        'answer': 'No, use air-dry clay.',
        'upvotes': 47,
      };

      final faq = FaqItem.fromJson(json);
      expect(faq.question, 'Do I need a kiln?');
      expect(faq.upvotes, 47);
    });
  });

  group('CostBreakdown.fromJson with API response shape', () {
    test('parses cost breakdown without id or hobbyId', () {
      final json = {
        'starter': 35,
        'threeMonth': 125,
        'oneYear': 380,
        'tips': ['Air-dry clay is cheaper'],
      };

      final cost = CostBreakdown.fromJson(json);
      expect(cost.starter, 35);
      expect(cost.tips.first, 'Air-dry clay is cheaper');
    });
  });

  group('BudgetAlternative.fromJson with API response shape', () {
    test('parses budget alt without id, hobbyId, sortOrder', () {
      final json = {
        'itemName': 'Clay',
        'diyOption': 'Flour dough',
        'diyCost': 2,
        'budgetOption': 'DAS clay',
        'budgetCost': 8,
        'premiumOption': 'Amaco',
        'premiumCost': 25,
      };

      final alt = BudgetAlternative.fromJson(json);
      expect(alt.itemName, 'Clay');
      expect(alt.diyCost, 2);
    });
  });

  group('HobbyCombo.fromJson with API response shape', () {
    test('parses combo without id', () {
      final json = {
        'hobbyId1': 'pottery',
        'hobbyId2': 'calligraphy',
        'reason': 'Both creative',
        'sharedTags': ['creative'],
      };

      final combo = HobbyCombo.fromJson(json);
      expect(combo.hobbyId1, 'pottery');
      expect(combo.sharedTags, ['creative']);
    });
  });
}
