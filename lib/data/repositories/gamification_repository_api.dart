import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_constants.dart';
import '../../models/features.dart';
import '../../models/gamification.dart';
import 'gamification_repository.dart';

/// API-backed gamification repository.
class GamificationRepositoryApi implements GamificationRepository {
  final Dio _dio = ApiClient.instance;

  @override
  Future<List<Challenge>> getChallenges() async {
    final response = await _dio.get(ApiConstants.usersChallenges);
    final list = response.data as List<dynamic>;
    return list
        .map((e) => Challenge.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Achievement>> getAchievements() async {
    final response = await _dio.get(ApiConstants.usersAchievements);
    final list = response.data as List<dynamic>;
    return list
        .map((e) => Achievement.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
