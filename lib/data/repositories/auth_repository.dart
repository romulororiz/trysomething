import '../../models/auth.dart';
import '../../models/hobby.dart';

/// Abstract auth repository interface.
abstract class AuthRepository {
  Future<AuthResponse> register({
    required String email,
    required String password,
    required String displayName,
  });

  Future<AuthResponse> login({
    required String email,
    required String password,
  });

  Future<AuthResponse> loginWithGoogle({String? idToken, String? accessToken});

  Future<AuthResponse> loginWithApple({
    String? authorizationCode,
    String? identityToken,
    Map<String, String?>? fullName,
  });

  Future<Map<String, dynamic>> refreshToken({required String refreshToken});

  Future<AuthUser> getMe();

  Future<AuthUser> updateProfile({String? displayName, String? bio, String? avatarUrl, String? fcmToken});

  Future<UserPreferences> updatePreferences({
    int? hoursPerWeek,
    int? budgetLevel,
    bool? preferSocial,
    Set<String>? vibes,
  });
}
