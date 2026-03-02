import 'dart:convert';
import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_constants.dart';
import '../../core/storage/cache_manager.dart';
import '../../models/features.dart';
import 'feature_repository.dart';
import 'feature_repository_impl.dart';

/// API-backed feature repository with Hive cache and SeedData fallback.
class FeatureRepositoryApi implements FeatureRepository {
  final Dio _dio = ApiClient.instance;
  final FeatureRepositoryImpl _seedFallback = FeatureRepositoryImpl();

  @override
  Future<List<FaqItem>> getFaqForHobby(String hobbyId) async {
    final key = 'faq_$hobbyId';
    try {
      final cached = CacheManager.get(key);
      if (cached != null) return _parseFaqList(cached);

      final response = await _dio.get(ApiConstants.faq(hobbyId));
      final jsonString = json.encode(response.data);
      await CacheManager.put(key, jsonString);
      return _parseFaqList(jsonString);
    } catch (e) {
      final stale = CacheManager.getStale(key);
      if (stale != null) return _parseFaqList(stale);
      return _seedFallback.getFaqForHobby(hobbyId);
    }
  }

  @override
  Future<CostBreakdown?> getCostBreakdown(String hobbyId) async {
    final key = 'cost_$hobbyId';
    try {
      final cached = CacheManager.get(key);
      if (cached != null) {
        return CostBreakdown.fromJson(
            json.decode(cached) as Map<String, dynamic>);
      }

      final response = await _dio.get(ApiConstants.cost(hobbyId));
      final jsonString = json.encode(response.data);
      await CacheManager.put(key, jsonString);
      return CostBreakdown.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      // 404 means no cost data — that's valid, return null
      if (e is DioException && e.response?.statusCode == 404) return null;
      final stale = CacheManager.getStale(key);
      if (stale != null) {
        return CostBreakdown.fromJson(
            json.decode(stale) as Map<String, dynamic>);
      }
      return _seedFallback.getCostBreakdown(hobbyId);
    }
  }

  @override
  Future<List<BudgetAlternative>> getBudgetAlternatives(String hobbyId) async {
    final key = 'budget_$hobbyId';
    try {
      final cached = CacheManager.get(key);
      if (cached != null) return _parseBudgetList(cached);

      final response = await _dio.get(ApiConstants.budget(hobbyId));
      final jsonString = json.encode(response.data);
      await CacheManager.put(key, jsonString);
      return _parseBudgetList(jsonString);
    } catch (e) {
      final stale = CacheManager.getStale(key);
      if (stale != null) return _parseBudgetList(stale);
      return _seedFallback.getBudgetAlternatives(hobbyId);
    }
  }

  @override
  Future<Map<String, List<String>>> getSeasonalHobbies() async {
    const key = 'seasonal';
    try {
      final cached = CacheManager.get(key);
      if (cached != null) return _parseStringListMap(cached);

      final response = await _dio.get(ApiConstants.seasonal);
      final jsonString = json.encode(response.data);
      await CacheManager.put(key, jsonString);
      return _parseStringListMap(jsonString);
    } catch (e) {
      final stale = CacheManager.getStale(key);
      if (stale != null) return _parseStringListMap(stale);
      return _seedFallback.getSeasonalHobbies();
    }
  }

  @override
  Future<Map<String, List<String>>> getMoodTags() async {
    const key = 'mood';
    try {
      final cached = CacheManager.get(key);
      if (cached != null) return _parseStringListMap(cached);

      final response = await _dio.get(ApiConstants.mood);
      final jsonString = json.encode(response.data);
      await CacheManager.put(key, jsonString);
      return _parseStringListMap(jsonString);
    } catch (e) {
      final stale = CacheManager.getStale(key);
      if (stale != null) return _parseStringListMap(stale);
      return _seedFallback.getMoodTags();
    }
  }

  @override
  Future<List<HobbyCombo>> getCombos() async {
    const key = 'combos';
    try {
      final cached = CacheManager.get(key);
      if (cached != null) return _parseComboList(cached);

      final response = await _dio.get(ApiConstants.combos);
      final jsonString = json.encode(response.data);
      await CacheManager.put(key, jsonString);
      return _parseComboList(jsonString);
    } catch (e) {
      final stale = CacheManager.getStale(key);
      if (stale != null) return _parseComboList(stale);
      return _seedFallback.getCombos();
    }
  }

  // ── Helpers ──────────────────────────────────────

  List<FaqItem> _parseFaqList(String jsonString) {
    final list = json.decode(jsonString) as List;
    return list
        .map((e) => FaqItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  List<BudgetAlternative> _parseBudgetList(String jsonString) {
    final list = json.decode(jsonString) as List;
    return list
        .map((e) => BudgetAlternative.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  List<HobbyCombo> _parseComboList(String jsonString) {
    final list = json.decode(jsonString) as List;
    return list
        .map((e) => HobbyCombo.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Map<String, List<String>> _parseStringListMap(String jsonString) {
    final map = json.decode(jsonString) as Map<String, dynamic>;
    return map.map((k, v) =>
        MapEntry(k, (v as List).map((e) => e as String).toList()));
  }
}
