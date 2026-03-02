import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_constants.dart';
import '../../models/hobby.dart';
import 'user_progress_repository.dart';

/// API-backed user progress repository.
class UserProgressRepositoryApi implements UserProgressRepository {
  final Dio _dio = ApiClient.instance;

  @override
  Future<List<UserHobby>> getHobbies() async {
    final response = await _dio.get(ApiConstants.usersHobbies);
    final list = response.data as List<dynamic>;
    return list
        .map((e) => UserHobby.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<UserHobby> saveHobby(String hobbyId) async {
    final response = await _dio.post(
      ApiConstants.usersHobbies,
      data: {'hobbyId': hobbyId},
    );
    return UserHobby.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> unsaveHobby(String hobbyId) async {
    await _dio.delete(ApiConstants.userHobby(hobbyId));
  }

  @override
  Future<UserHobby> updateStatus(
    String hobbyId,
    HobbyStatus status, {
    DateTime? startedAt,
    DateTime? completedAt,
  }) async {
    final response = await _dio.put(
      ApiConstants.userHobby(hobbyId),
      data: {
        'status': status.name,
        if (startedAt != null) 'startedAt': startedAt.toIso8601String(),
        if (completedAt != null) 'completedAt': completedAt.toIso8601String(),
      },
    );
    return UserHobby.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<UserHobby> toggleStep(String hobbyId, String stepId) async {
    final response = await _dio.post(
      ApiConstants.userHobbyStep(hobbyId, stepId),
    );
    return UserHobby.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<UserHobby>> syncHobbies(List<UserHobby> hobbies) async {
    final hobbyJsonList = hobbies.map((h) => h.toJson()).toList();
    final response = await _dio.post(
      ApiConstants.usersHobbiesSync,
      data: {'hobbies': hobbyJsonList},
    );
    final list = response.data as List<dynamic>;
    return list
        .map((e) => UserHobby.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getActivityLog({int days = 365}) async {
    final response = await _dio.get(
      ApiConstants.usersActivity,
      queryParameters: {'days': days},
    );
    final list = response.data as List<dynamic>;
    return list.cast<Map<String, dynamic>>();
  }
}
