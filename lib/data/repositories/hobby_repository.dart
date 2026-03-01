import '../../models/hobby.dart';

/// Abstract hobby data source. Implementations can delegate to
/// SeedData (current), API, or cached Hive storage.
abstract class HobbyRepository {
  Future<List<Hobby>> getHobbies();
  Future<Hobby?> getHobbyById(String id);
  Future<List<HobbyCategory>> getCategories();
  Future<List<Hobby>> getRelatedHobbies(String hobbyId, {int limit = 3});
  Future<List<Hobby>> searchHobbies(String query);
}
