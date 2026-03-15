import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_constants.dart';
import '../../core/storage/cache_manager.dart';
import '../../models/curated_pack.dart';
import '../../models/hobby.dart';
import '../../models/seed_data.dart';
import 'hobby_repository.dart';
import 'hobby_repository_impl.dart';

/// API-backed hobby repository with Hive cache and SeedData fallback.
class HobbyRepositoryApi implements HobbyRepository {
  final Dio _dio = ApiClient.instance;
  final HobbyRepositoryImpl _seedFallback = HobbyRepositoryImpl();

  @override
  Future<List<Hobby>> getHobbies() async {
    const key = 'hobbies';
    try {
      // Check cache first
      final cached = CacheManager.get(key);
      if (cached != null) {
        return _parseHobbyList(cached);
      }

      // Fetch from API
      final response = await _dio.get(ApiConstants.hobbies);
      final jsonString = json.encode(response.data);
      await CacheManager.put(key, jsonString);
      return _parseHobbyList(jsonString);
    } catch (e) {
      // Try stale cache
      final stale = CacheManager.getStale(key);
      if (stale != null) return _parseHobbyList(stale);
      // Fall back to seed data
      return _seedFallback.getHobbies();
    }
  }

  @override
  Future<Hobby?> getHobbyById(String id) async {
    final key = 'hobby_$id';
    try {
      final cached = CacheManager.get(key);
      if (cached != null) {
        final hobby = _enrichFromSeed(
            Hobby.fromJson(json.decode(cached) as Map<String, dynamic>));
        // Re-fetch if cached data is missing new fields (coachTip)
        final hasNewFields = hobby.roadmapSteps.isEmpty ||
            hobby.roadmapSteps.first.coachTip != null;
        if (hasNewFields) return hobby;
        // Otherwise fall through to fresh fetch
        await CacheManager.invalidate(key);
      }

      final response = await _dio.get(ApiConstants.hobby(id));
      final jsonString = json.encode(response.data);
      await CacheManager.put(key, jsonString);
      return _enrichFromSeed(
          Hobby.fromJson(response.data as Map<String, dynamic>));
    } catch (e) {
      final stale = CacheManager.getStale(key);
      if (stale != null) {
        return _enrichFromSeed(
            Hobby.fromJson(json.decode(stale) as Map<String, dynamic>));
      }
      return _seedFallback.getHobbyById(id);
    }
  }

  @override
  Future<List<HobbyCategory>> getCategories() async {
    const key = 'categories';
    try {
      final cached = CacheManager.get(key);
      if (cached != null) {
        return _parseCategoryList(cached);
      }

      final response = await _dio.get(ApiConstants.categories);
      final jsonString = json.encode(response.data);
      await CacheManager.put(key, jsonString);
      return _parseCategoryList(jsonString);
    } catch (e) {
      final stale = CacheManager.getStale(key);
      if (stale != null) return _parseCategoryList(stale);
      return _seedFallback.getCategories();
    }
  }

  @override
  Future<List<Hobby>> getRelatedHobbies(String hobbyId, {int limit = 3}) async {
    // Use the full hobby list to find related hobbies by category
    try {
      final allHobbies = await getHobbies();
      final hobby = allHobbies.where((h) => h.id == hobbyId).firstOrNull;
      if (hobby == null) return [];
      return allHobbies
          .where((h) => h.category == hobby.category && h.id != hobbyId)
          .take(limit)
          .toList();
    } catch (e) {
      return _seedFallback.getRelatedHobbies(hobbyId, limit: limit);
    }
  }

  @override
  Future<List<Hobby>> searchHobbies(String query) async {
    if (query.trim().isEmpty) return [];
    try {
      final response = await _dio.get(
        ApiConstants.search,
        queryParameters: {'q': query},
      );
      return (response.data as List)
          .map((e) => Hobby.fromJson(e as Map<String, dynamic>))
          .map(_enrichFromSeed)
          .toList();
    } catch (e) {
      return _seedFallback.searchHobbies(query);
    }
  }

  @override
  Future<List<CuratedPack>> getCuratedPacks() async {
    try {
      final response = await _dio.get(ApiConstants.hobbyPacks);
      return (response.data as List)
          .map((e) => CuratedPack.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return _seedFallback.getCuratedPacks();
    }
  }

  @override
  Future<Hobby> generateHobby(String query) async {
    debugPrint('[GenerateHobby] POST ${ApiConstants.generateHobby} query="$query"');
    try {
      final response = await _dio.post(
        ApiConstants.generateHobby,
        data: {'query': query},
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          validateStatus: (status) => status != null && status < 500 && status != 401,
        ),
      );
      debugPrint('[GenerateHobby] Response status: ${response.statusCode}');

      if (response.statusCode == 429) {
        throw Exception('Generation limit reached (5 per day). Try again tomorrow.');
      }
      if (response.statusCode != null && response.statusCode! >= 400) {
        final msg = response.data is Map
            ? (response.data['error'] ?? 'Request failed')
            : 'Request failed';
        throw Exception(msg.toString());
      }

      final data = response.data as Map<String, dynamic>;
      final hobby = Hobby.fromJson(data['hobby'] as Map<String, dynamic>);
      debugPrint('[GenerateHobby] Parsed hobby: ${hobby.title}');

      // Invalidate hobbies cache so the new hobby appears in the feed
      await CacheManager.invalidate('hobbies');
      // Cache the new hobby individually
      await CacheManager.put('hobby_${hobby.id}', json.encode(data['hobby']));

      return hobby;
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        throw Exception('Generation limit reached (5 per day). Try again tomorrow.');
      }
      rethrow;
    }
  }

  // ── Helpers ──────────────────────────────────────

  /// Merge client-only fields (quittingReasons) from seed data into
  /// API-loaded hobbies. These fields aren't in the server DB yet.
  Hobby _enrichFromSeed(Hobby hobby) {
    if (hobby.quittingReasons.isNotEmpty) return hobby;
    final titleLower = hobby.title.toLowerCase();
    final seed = SeedData.hobbies
        .where((s) => s.id == hobby.id || s.title.toLowerCase() == titleLower)
        .firstOrNull;
    if (seed == null || seed.quittingReasons.isEmpty) return hobby;
    return hobby.copyWith(quittingReasons: seed.quittingReasons);
  }

  List<Hobby> _parseHobbyList(String jsonString) {
    final list = json.decode(jsonString) as List;
    return list
        .map((e) => Hobby.fromJson(e as Map<String, dynamic>))
        .map(_enrichFromSeed)
        .toList();
  }

  List<HobbyCategory> _parseCategoryList(String jsonString) {
    final list = json.decode(jsonString) as List;
    return list
        .map((e) => HobbyCategory.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
