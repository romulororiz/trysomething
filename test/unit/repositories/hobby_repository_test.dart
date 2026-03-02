import 'package:flutter_test/flutter_test.dart';
import 'package:trysomething/data/repositories/hobby_repository_impl.dart';

void main() {
  late HobbyRepositoryImpl repository;

  setUp(() {
    repository = HobbyRepositoryImpl();
  });

  group('HobbyRepositoryImpl', () {
    test('getHobbies returns non-empty list', () async {
      final hobbies = await repository.getHobbies();
      expect(hobbies, isNotEmpty);
    });

    test('getHobbyById returns correct hobby', () async {
      final hobbies = await repository.getHobbies();
      final firstId = hobbies.first.id;

      final hobby = await repository.getHobbyById(firstId);
      expect(hobby, isNotNull);
      expect(hobby!.id, firstId);
    });

    test('getHobbyById returns null for unknown id', () async {
      final hobby = await repository.getHobbyById('nonexistent_id');
      expect(hobby, isNull);
    });

    test('getCategories returns non-empty list', () async {
      final categories = await repository.getCategories();
      expect(categories, isNotEmpty);
      expect(categories.first.name, isNotEmpty);
    });

    test('getRelatedHobbies returns hobbies of same category', () async {
      final hobbies = await repository.getHobbies();
      final firstHobby = hobbies.first;

      final related = await repository.getRelatedHobbies(firstHobby.id);
      expect(related.length, lessThanOrEqualTo(3));
      // Related hobbies should not include the original hobby
      for (final h in related) {
        expect(h.id, isNot(firstHobby.id));
      }
    });

    test('searchHobbies returns matching results', () async {
      final hobbies = await repository.getHobbies();
      final title = hobbies.first.title;
      // Search by first word of the title
      final query = title.split(' ').first;

      final results = await repository.searchHobbies(query);
      expect(results, isNotEmpty);
      expect(
        results.any((h) => h.title.toLowerCase().contains(query.toLowerCase())),
        isTrue,
      );
    });

    test('searchHobbies returns empty for gibberish', () async {
      final results = await repository.searchHobbies('xyzzyplugh');
      expect(results, isEmpty);
    });
  });
}
