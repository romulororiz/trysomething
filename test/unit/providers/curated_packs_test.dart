import 'package:flutter_test/flutter_test.dart';
import 'package:trysomething/models/curated_pack.dart';
import 'package:trysomething/models/hobby.dart';
import 'package:trysomething/data/repositories/hobby_repository.dart';
import 'package:trysomething/data/repositories/hobby_repository_impl.dart';

/// Mock hobby repository that returns configurable curated packs.
class MockHobbyRepository implements HobbyRepository {
  bool shouldFail = false;
  List<CuratedPack> serverPacks = [];

  @override
  Future<List<CuratedPack>> getCuratedPacks() async {
    if (shouldFail) throw Exception('mock failure');
    return serverPacks;
  }

  @override
  Future<List<Hobby>> getHobbies() async => [];
  @override
  Future<Hobby?> getHobbyById(String id) async => null;
  @override
  Future<List<HobbyCategory>> getCategories() async => [];
  @override
  Future<List<Hobby>> getRelatedHobbies(String hobbyId, {int limit = 3}) async => [];
  @override
  Future<List<Hobby>> searchHobbies(String query) async => [];
}

void main() {
  // ═══════════════════════════════════════════════════════
  //  CURATED PACK MODEL
  // ═══════════════════════════════════════════════════════

  group('CuratedPack serialization', () {
    test('fromJson round-trips correctly', () {
      final json = {
        'id': 'introverts',
        'title': '10 Hobbies for Introverts',
        'icon': 'introvert',
        'hobbies': <Map<String, dynamic>>[],
      };

      final pack = CuratedPack.fromJson(json);

      expect(pack.id, 'introverts');
      expect(pack.title, '10 Hobbies for Introverts');
      expect(pack.icon, 'introvert');
      expect(pack.hobbies, isEmpty);
    });

    test('toJson produces correct structure', () {
      const pack = CuratedPack(
        id: 'budget',
        title: 'Weekend Hobbies Under CHF 50',
        icon: 'budget',
        hobbies: [],
      );

      final json = pack.toJson();

      expect(json['id'], 'budget');
      expect(json['title'], 'Weekend Hobbies Under CHF 50');
      expect(json['icon'], 'budget');
      expect(json['hobbies'], isList);
    });

    test('copyWith creates modified copy', () {
      const pack = CuratedPack(
        id: 'community',
        title: 'Hobbies That Build Community',
        icon: 'community',
        hobbies: [],
      );

      final modified = pack.copyWith(title: 'New Title');

      expect(modified.title, 'New Title');
      expect(modified.id, 'community'); // unchanged
    });
  });

  // ═══════════════════════════════════════════════════════
  //  MOCK REPOSITORY
  // ═══════════════════════════════════════════════════════

  group('CuratedPacks repository', () {
    late MockHobbyRepository repo;

    setUp(() {
      repo = MockHobbyRepository();
    });

    test('returns server packs on success', () async {
      repo.serverPacks = [
        const CuratedPack(
          id: 'introverts',
          title: '10 Hobbies for Introverts',
          icon: 'introvert',
          hobbies: [],
        ),
        const CuratedPack(
          id: 'budget',
          title: 'Weekend Hobbies Under CHF 50',
          icon: 'budget',
          hobbies: [],
        ),
      ];

      final result = await repo.getCuratedPacks();

      expect(result, hasLength(2));
      expect(result.first.id, 'introverts');
      expect(result.last.id, 'budget');
    });

    test('throws on failure', () async {
      repo.shouldFail = true;

      expect(
        () => repo.getCuratedPacks(),
        throwsException,
      );
    });
  });

  // ═══════════════════════════════════════════════════════
  //  SEED FALLBACK
  // ═══════════════════════════════════════════════════════

  group('HobbyRepositoryImpl (seed fallback)', () {
    test('getCuratedPacks returns empty list', () async {
      final repo = HobbyRepositoryImpl();
      final packs = await repo.getCuratedPacks();
      expect(packs, isEmpty);
    });
  });
}
