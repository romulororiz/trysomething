import 'package:flutter_test/flutter_test.dart';
import 'package:trysomething/models/curated_pack.dart';
import 'package:trysomething/models/hobby.dart';
import 'package:trysomething/data/repositories/hobby_repository.dart';
import 'package:trysomething/providers/hobby_provider.dart';

/// Mock hobby repository that supports configurable generation.
class MockHobbyRepository implements HobbyRepository {
  bool shouldFail = false;
  Hobby? generatedHobby;
  String? lastGenerateQuery;

  @override
  Future<Hobby> generateHobby(String query) async {
    lastGenerateQuery = query;
    if (shouldFail) throw Exception('generation failed');
    if (generatedHobby != null) return generatedHobby!;
    return Hobby(
      id: query.toLowerCase().replaceAll(' ', '-'),
      title: query,
      hook: 'A test hook',
      category: 'creative',
      imageUrl: 'https://example.com/img.jpg',
      tags: const ['test'],
      costText: 'CHF 10–30',
      timeText: '1h/week',
      difficultyText: 'Easy',
      whyLove: 'Test love',
      difficultyExplain: 'Test difficulty',
      starterKit: const [],
      pitfalls: const ['Test pitfall 1', 'Test pitfall 2'],
      roadmapSteps: const [],
    );
  }

  // ── Unused stubs ──
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
  @override
  Future<List<CuratedPack>> getCuratedPacks() async => [];
}

void main() {
  // ═══════════════════════════════════════════════════════
  //  GENERATION STATE
  // ═══════════════════════════════════════════════════════

  group('GenerationState', () {
    test('default state is idle with no hobby or error', () {
      const state = GenerationState();

      expect(state.status, GenerationStatus.idle);
      expect(state.hobby, isNull);
      expect(state.error, isNull);
    });

    test('copyWith updates only specified fields', () {
      const state = GenerationState();
      final updated = state.copyWith(
        status: GenerationStatus.generating,
      );

      expect(updated.status, GenerationStatus.generating);
      expect(updated.hobby, isNull);
      expect(updated.error, isNull);
    });

    test('copyWith preserves existing values', () {
      final state = GenerationState(
        status: GenerationStatus.error,
        error: 'some error',
      );
      final updated = state.copyWith(
        status: GenerationStatus.idle,
      );

      expect(updated.status, GenerationStatus.idle);
      // error field is preserved (not cleared) by copyWith
      expect(updated.error, 'some error');
    });
  });

  // ═══════════════════════════════════════════════════════
  //  GENERATION STATUS ENUM
  // ═══════════════════════════════════════════════════════

  group('GenerationStatus', () {
    test('has expected values', () {
      expect(GenerationStatus.values, hasLength(4));
      expect(GenerationStatus.values, containsAll([
        GenerationStatus.idle,
        GenerationStatus.generating,
        GenerationStatus.success,
        GenerationStatus.error,
      ]));
    });
  });

  // ═══════════════════════════════════════════════════════
  //  MOCK REPOSITORY GENERATION
  // ═══════════════════════════════════════════════════════

  group('MockHobbyRepository.generateHobby', () {
    late MockHobbyRepository repo;

    setUp(() {
      repo = MockHobbyRepository();
    });

    test('returns hobby with query-based ID on success', () async {
      final hobby = await repo.generateHobby('Pottery');

      expect(hobby.id, 'pottery');
      expect(hobby.title, 'Pottery');
      expect(hobby.category, 'creative');
      expect(repo.lastGenerateQuery, 'Pottery');
    });

    test('returns custom hobby when configured', () async {
      repo.generatedHobby = const Hobby(
        id: 'custom-hobby',
        title: 'Custom Hobby',
        hook: 'Custom hook',
        category: 'fitness',
        imageUrl: 'https://example.com/custom.jpg',
        tags: ['custom'],
        costText: 'Free',
        timeText: '30min/week',
        difficultyText: 'Easy',
        whyLove: 'Custom love',
        difficultyExplain: 'Custom difficulty',
        starterKit: [],
        pitfalls: ['Pitfall 1', 'Pitfall 2'],
        roadmapSteps: [],
      );

      final hobby = await repo.generateHobby('anything');

      expect(hobby.id, 'custom-hobby');
      expect(hobby.title, 'Custom Hobby');
    });

    test('throws on failure', () async {
      repo.shouldFail = true;

      expect(
        () => repo.generateHobby('Pottery'),
        throwsException,
      );
    });

    test('handles multi-word queries', () async {
      final hobby = await repo.generateHobby('Rock Climbing');

      expect(hobby.id, 'rock-climbing');
      expect(hobby.title, 'Rock Climbing');
    });
  });
}
