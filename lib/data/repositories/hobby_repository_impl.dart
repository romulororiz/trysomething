import 'package:dio/dio.dart';
import '../../models/curated_pack.dart';
import '../../models/hobby.dart';
import '../../models/seed_data.dart';
import 'hobby_repository.dart';

/// Local seed-data implementation of [HobbyRepository].
/// Will be replaced with API + Hive cache in Phase 3.
class HobbyRepositoryImpl implements HobbyRepository {
  @override
  Future<List<Hobby>> getHobbies() async {
    return SeedData.hobbies;
  }

  @override
  Future<Hobby?> getHobbyById(String id) async {
    return SeedData.getHobby(id);
  }

  @override
  Future<List<HobbyCategory>> getCategories() async {
    return SeedData.categories;
  }

  @override
  Future<List<Hobby>> getRelatedHobbies(String hobbyId, {int limit = 3}) async {
    return SeedData.getRelated(hobbyId, limit: limit);
  }

  @override
  Future<List<Hobby>> searchHobbies(String query) async {
    if (query.isEmpty) return [];
    final q = query.toLowerCase();
    return SeedData.hobbies.where((h) =>
      h.title.toLowerCase().contains(q) ||
      h.category.toLowerCase().contains(q) ||
      h.tags.any((t) => t.toLowerCase().contains(q)) ||
      h.hook.toLowerCase().contains(q)
    ).toList();
  }

  @override
  Future<List<CuratedPack>> getCuratedPacks() async {
    return []; // No seed data for curated packs
  }

  @override
  Future<Hobby> generateHobby(String query, {CancelToken? cancelToken}) {
    throw UnsupportedError('Generation requires API');
  }
}
