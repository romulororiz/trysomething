import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_constants.dart';
import '../../models/auth.dart';
import '../../models/hobby.dart';
import 'auth_repository.dart';

/// API-backed auth repository.
class AuthRepositoryApi implements AuthRepository {
  final Dio _dio = ApiClient.instance;

  @override
  Future<AuthResponse> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final response = await _dio.post(ApiConstants.authRegister, data: {
      'email': email,
      'password': password,
      'displayName': displayName,
    });
    return AuthResponse.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(ApiConstants.authLogin, data: {
      'email': email,
      'password': password,
    });
    return AuthResponse.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<AuthResponse> loginWithGoogle({
    String? idToken,
    String? accessToken,
  }) async {
    final response = await _dio.post(ApiConstants.authGoogle, data: {
      if (idToken != null) 'idToken': idToken,
      if (accessToken != null) 'accessToken': accessToken,
    });
    return AuthResponse.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<Map<String, dynamic>> refreshToken({
    required String refreshToken,
  }) async {
    final response = await _dio.post(ApiConstants.authRefresh, data: {
      'refreshToken': refreshToken,
    });
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<AuthUser> getMe() async {
    final response = await _dio.get(ApiConstants.usersMe);
    return AuthUser.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<AuthUser> updateProfile({
    String? displayName,
    String? bio,
    String? avatarUrl,
  }) async {
    final response = await _dio.put(ApiConstants.usersMe, data: {
      if (displayName != null) 'displayName': displayName,
      if (bio != null) 'bio': bio,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
    });
    return AuthUser.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<UserPreferences> updatePreferences({
    int? hoursPerWeek,
    int? budgetLevel,
    bool? preferSocial,
    Set<String>? vibes,
  }) async {
    final response = await _dio.put(ApiConstants.usersPreferences, data: {
      if (hoursPerWeek != null) 'hoursPerWeek': hoursPerWeek,
      if (budgetLevel != null) 'budgetLevel': budgetLevel,
      if (preferSocial != null) 'preferSocial': preferSocial,
      if (vibes != null) 'vibes': vibes.toList(),
    });
    return UserPreferences.fromJson(response.data as Map<String, dynamic>);
  }
}
