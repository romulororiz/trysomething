import 'package:flutter_test/flutter_test.dart';
import 'package:trysomething/core/hobby_match.dart';
import 'package:trysomething/models/hobby.dart';

Hobby _hobby({
  String id = 'h1',
  String costText = 'CHF 40–120',
  String timeText = '2h/week',
  List<String> tags = const [],
}) =>
    Hobby(
      id: id,
      title: 'Test Hobby',
      hook: 'hook',
      category: 'creative',
      imageUrl: '',
      tags: tags,
      costText: costText,
      timeText: timeText,
      difficultyText: 'Easy',
      whyLove: '',
      difficultyExplain: '',
      starterKit: const [],
      pitfalls: const [],
      roadmapSteps: const [],
    );

void main() {
  // ═══════════════════════════════════════════════════════
  //  parseCostRange
  // ═══════════════════════════════════════════════════════

  group('parseCostRange', () {
    test('parses range with en-dash', () {
      expect(parseCostRange('CHF 40–120'), (40, 120));
    });

    test('parses range with hyphen', () {
      expect(parseCostRange('CHF 0-30'), (0, 30));
    });

    test('parses range with spaces around dash', () {
      expect(parseCostRange('CHF 40 – 120'), (40, 120));
    });

    test('parses single number', () {
      expect(parseCostRange('CHF 50'), (50, 50));
    });

    test('falls back to (0, 9999) when no number present', () {
      expect(parseCostRange('Free'), (0, 9999));
    });

    test('falls back to (0, 9999) for empty string', () {
      expect(parseCostRange(''), (0, 9999));
    });
  });

  // ═══════════════════════════════════════════════════════
  //  parseWeeklyHours
  // ═══════════════════════════════════════════════════════

  group('parseWeeklyHours', () {
    test('parses integer hours', () {
      expect(parseWeeklyHours('2h/week'), 2.0);
    });

    test('parses decimal hours', () {
      expect(parseWeeklyHours('1.5h/week'), 1.5);
    });

    test('parses hours without /week suffix', () {
      expect(parseWeeklyHours('4h'), 4.0);
    });

    test('falls back to 99 when no match', () {
      expect(parseWeeklyHours('varies'), 99.0);
    });

    test('falls back to 99 for empty string', () {
      expect(parseWeeklyHours(''), 99.0);
    });
  });

  // ═══════════════════════════════════════════════════════
  //  budgetThreshold
  // ═══════════════════════════════════════════════════════

  group('budgetThreshold', () {
    test('level 0 returns 50', () {
      expect(budgetThreshold(0), 50);
    });

    test('level 1 returns 150', () {
      expect(budgetThreshold(1), 150);
    });

    test('level 2 returns 999999', () {
      expect(budgetThreshold(2), 999999);
    });

    test('unknown level returns 999999', () {
      expect(budgetThreshold(99), 999999);
    });
  });

  // ═══════════════════════════════════════════════════════
  //  computeMatchScore
  // ═══════════════════════════════════════════════════════

  group('computeMatchScore', () {
    test('perfect fit scores budget + time + social + vibe points', () {
      final hobby = _hobby(
        costText: 'CHF 20–40',
        timeText: '1h/week',
        tags: const ['social', 'creative'],
      );
      final score = computeMatchScore(
        hobby: hobby,
        userHours: 2.0,
        userBudgetLevel: 1,
        userPrefersSocial: true,
        userVibes: const {'creative'},
      );
      // budget fit: costMax=40 <= 150 → +3
      // time fit: hobbyHours=1 <= userHours=2 → +3
      // social match: userPrefersSocial=true, tag 'social' → +2
      // vibe match: 'creative' → +1
      expect(score, 9);
    });

    test('over budget hobby earns no budget points', () {
      final hobby = _hobby(costText: 'CHF 200–400', timeText: '1h/week');
      final score = computeMatchScore(
        hobby: hobby,
        userHours: 2.0,
        userBudgetLevel: 0, // threshold = 50
        userPrefersSocial: false,
        userVibes: const {},
      );
      // costMax=400 > 50 and 400 > 50*1.5=75 → +0 budget
      // time fit → +3
      expect(score, 3);
    });

    test('slightly over budget earns 1 budget point', () {
      final hobby = _hobby(costText: 'CHF 60–70', timeText: '1h/week');
      final score = computeMatchScore(
        hobby: hobby,
        userHours: 2.0,
        userBudgetLevel: 0, // threshold = 50; 50*1.5 = 75
        userPrefersSocial: false,
        userVibes: const {},
      );
      // costMax=70 > 50 but 70 <= 75 → +1 budget
      // time fit → +3
      expect(score, 4);
    });

    test('over hours hobby earns no time points', () {
      final hobby = _hobby(costText: 'CHF 20–40', timeText: '5h/week');
      final score = computeMatchScore(
        hobby: hobby,
        userHours: 2.0,
        userBudgetLevel: 1,
        userPrefersSocial: false,
        userVibes: const {},
      );
      // hobbyHours=5, userHours=2, 5 > 2+2=4 → +0 time
      // budget fit → +3
      expect(score, 3);
    });

    test('hobby slightly over hours earns 1 time point', () {
      final hobby = _hobby(costText: 'CHF 20–40', timeText: '3h/week');
      final score = computeMatchScore(
        hobby: hobby,
        userHours: 2.0,
        userBudgetLevel: 1,
        userPrefersSocial: false,
        userVibes: const {},
      );
      // hobbyHours=3, userHours=2, 3 <= 2+2=4 → +1 time
      // budget fit → +3
      expect(score, 4);
    });

    test('social mismatch earns no social points', () {
      final hobby = _hobby(tags: const ['social']);
      final score = computeMatchScore(
        hobby: hobby,
        userHours: 10.0,
        userBudgetLevel: 2,
        userPrefersSocial: false, // user prefers solo but hobby is social
        userVibes: const {},
      );
      // social mismatch → +0 social
      expect(score, greaterThanOrEqualTo(0));
      // The 2 social points should NOT be included
      final scoreWithSocial = computeMatchScore(
        hobby: hobby,
        userHours: 10.0,
        userBudgetLevel: 2,
        userPrefersSocial: true,
        userVibes: const {},
      );
      expect(scoreWithSocial, score + 2);
    });

    test('vibe matches add one point each', () {
      final hobby = _hobby(tags: const ['creative', 'relaxing', 'physical']);
      final baseScore = computeMatchScore(
        hobby: hobby,
        userHours: 10.0,
        userBudgetLevel: 2,
        userPrefersSocial: false,
        userVibes: const {},
      );
      final vibeScore = computeMatchScore(
        hobby: hobby,
        userHours: 10.0,
        userBudgetLevel: 2,
        userPrefersSocial: false,
        userVibes: const {'creative', 'relaxing'},
      );
      expect(vibeScore, baseScore + 2);
    });

    test('score is never negative', () {
      final hobby = _hobby(
        costText: 'CHF 500–1000',
        timeText: '20h/week',
        tags: const [],
      );
      final score = computeMatchScore(
        hobby: hobby,
        userHours: 1.0,
        userBudgetLevel: 0,
        userPrefersSocial: false,
        userVibes: const {},
      );
      expect(score, greaterThanOrEqualTo(0));
    });
  });

  // ═══════════════════════════════════════════════════════
  //  computeMatchReasons
  // ═══════════════════════════════════════════════════════

  group('computeMatchReasons', () {
    test('returns at most 3 items', () {
      final hobby = _hobby(
        costText: 'CHF 20–40',
        timeText: '1h/week',
        tags: const ['solo', 'creative', 'outdoors', 'relaxing'],
      );
      final reasons = computeMatchReasons(
        hobby: hobby,
        userHours: 2.0,
        userBudgetLevel: 0,
        userPrefersSocial: false,
        userVibes: const {'creative', 'relaxing'},
      );
      expect(reasons.length, lessThanOrEqualTo(3));
    });

    test('budget reason shown when within budget and budgetLevel < 2', () {
      final hobby = _hobby(costText: 'CHF 40–120', timeText: '2h/week');
      final reasons = computeMatchReasons(
        hobby: hobby,
        userHours: 3.0,
        userBudgetLevel: 1, // threshold=150, costMax=120 fits
        userPrefersSocial: false,
        userVibes: const {},
      );
      expect(
        reasons.any((r) => r.contains('CHF 40–120') || r.contains('CHF 0') || r.contains('free')),
        isTrue,
      );
    });

    test('budget reason NOT shown when budgetLevel is 2', () {
      final hobby = _hobby(costText: 'CHF 40–120', timeText: '2h/week');
      final reasons = computeMatchReasons(
        hobby: hobby,
        userHours: 3.0,
        userBudgetLevel: 2, // no budget limit — reason should be suppressed
        userPrefersSocial: false,
        userVibes: const {},
      );
      final hasBudgetReason = reasons.any(
        (r) => r.contains('CHF') || r.contains('free') || r.contains('cost'),
      );
      expect(hasBudgetReason, isFalse);
    });

    test('budget reason shows "free or under CHF 30" for near-free hobbies', () {
      final hobby = _hobby(costText: 'CHF 0-20', timeText: '2h/week');
      final reasons = computeMatchReasons(
        hobby: hobby,
        userHours: 3.0,
        userBudgetLevel: 0, // threshold=50, fits
        userPrefersSocial: false,
        userVibes: const {},
      );
      expect(reasons, contains('Starts free or under CHF 30'));
    });

    test('time reason shown when hobby fits user hours', () {
      final hobby = _hobby(costText: 'CHF 200', timeText: '2h/week');
      final reasons = computeMatchReasons(
        hobby: hobby,
        userHours: 3.0,
        userBudgetLevel: 2,
        userPrefersSocial: false,
        userVibes: const {},
      );
      expect(reasons.any((r) => r.contains('2h/week') || r.contains('2h')), isTrue);
    });

    test('solo reason shown when user prefers solo and hobby has solo tag', () {
      final hobby = _hobby(
        costText: 'CHF 200',
        timeText: '2h/week',
        tags: const ['solo'],
      );
      final reasons = computeMatchReasons(
        hobby: hobby,
        userHours: 3.0,
        userBudgetLevel: 2,
        userPrefersSocial: false,
        userVibes: const {},
      );
      expect(reasons, contains('Perfect for solo time'));
    });
  });

  // ═══════════════════════════════════════════════════════
  //  computeMatchedHobbies
  // ═══════════════════════════════════════════════════════

  group('computeMatchedHobbies', () {
    test('returns empty list when allHobbies is empty', () {
      final result = computeMatchedHobbies(
        allHobbies: const [],
        userHours: 2.0,
        userBudgetLevel: 1,
        userPrefersSocial: false,
        userVibes: const {},
      );
      expect(result, isEmpty);
    });

    test('returns top 4 hobbies when enough high-scoring hobbies exist', () {
      final hobbies = List.generate(
        6,
        (i) => _hobby(
          id: 'h$i',
          costText: 'CHF 20–40',
          timeText: '1h/week',
          tags: const ['solo'],
        ),
      );
      final result = computeMatchedHobbies(
        allHobbies: hobbies,
        userHours: 2.0,
        userBudgetLevel: 1,
        userPrefersSocial: false,
        userVibes: const {},
      );
      expect(result.length, 4);
    });

    test('pads to 4 when fewer than 4 hobbies score > 0', () {
      // 1 hobby scores well, rest score 0 but pass budget
      final goodHobby = _hobby(
        id: 'good',
        costText: 'CHF 20–40',
        timeText: '1h/week',
        tags: const ['solo', 'creative'],
      );
      final cheapHobbies = List.generate(
        5,
        (i) => _hobby(
          id: 'cheap$i',
          costText: 'CHF 20–30',
          timeText: '20h/week', // way over hours → score 0 for time
          tags: const [],
        ),
      );
      final result = computeMatchedHobbies(
        allHobbies: [goodHobby, ...cheapHobbies],
        userHours: 1.0,
        userBudgetLevel: 1,
        userPrefersSocial: false,
        userVibes: const {'creative'},
      );
      expect(result.length, 4);
    });

    test('result contains no duplicate hobby ids', () {
      final hobbies = List.generate(
        8,
        (i) => _hobby(
          id: 'h$i',
          costText: 'CHF 20–40',
          timeText: '2h/week',
        ),
      );
      final result = computeMatchedHobbies(
        allHobbies: hobbies,
        userHours: 3.0,
        userBudgetLevel: 1,
        userPrefersSocial: false,
        userVibes: const {},
      );
      final ids = result.map((h) => h.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('returns fewer than 4 when total hobbies is less than 4', () {
      final hobbies = [
        _hobby(id: 'a', costText: 'CHF 10', timeText: '1h/week'),
        _hobby(id: 'b', costText: 'CHF 20', timeText: '1h/week'),
      ];
      final result = computeMatchedHobbies(
        allHobbies: hobbies,
        userHours: 2.0,
        userBudgetLevel: 1,
        userPrefersSocial: false,
        userVibes: const {},
      );
      expect(result.length, 2);
    });
  });
}
