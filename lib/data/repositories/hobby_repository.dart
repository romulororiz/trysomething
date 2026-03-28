import 'package:dio/dio.dart';
import '../../models/curated_pack.dart';
import '../../models/hobby.dart';

/// Abstract hobby data source. Implementations can delegate to
/// SeedData (current), API, or cached Hive storage.
abstract class HobbyRepository {
  Future<List<Hobby>> getHobbies();
  Future<Hobby?> getHobbyById(String id);
  Future<List<HobbyCategory>> getCategories();
  Future<List<Hobby>> getRelatedHobbies(String hobbyId, {int limit = 3});
  Future<List<Hobby>> searchHobbies(String query);
  Future<List<CuratedPack>> getCuratedPacks();
  Future<Hobby> generateHobby(String query, {CancelToken? cancelToken});
}
