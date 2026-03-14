import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../core/auth/token_storage.dart';
import '../core/analytics/analytics_provider.dart';
import '../core/analytics/analytics_service.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/auth_repository_api.dart';
import '../models/auth.dart';
import '../core/subscription/subscription_service.dart';
import 'subscription_provider.dart';

// ═══════════════════════════════════════════════════
//  AUTH STATE
// ═══════════════════════════════════════════════════

enum AuthStatus { unknown, unauthenticated, loading, authenticated }

enum AuthMethod { none, email, google, apple }

class AuthState {
  final AuthStatus status;
  final AuthUser? user;
  final String? error;
  final AuthMethod loadingMethod;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.error,
    this.loadingMethod = AuthMethod.none,
  });

  AuthState copyWith({
    AuthStatus? status,
    AuthUser? user,
    String? error,
    AuthMethod? loadingMethod,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
      loadingMethod: loadingMethod ?? this.loadingMethod,
    );
  }
}

// ═══════════════════════════════════════════════════
//  AUTH NOTIFIER
// ═══════════════════════════════════════════════════

// Primary GoogleSignIn — with serverClientId to request idToken (Android/iOS).
final _googleSignIn = GoogleSignIn(
  scopes: ['email', 'profile'],
  serverClientId: const String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID') != ''
      ? const String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID')
      : null,
);

// Fallback GoogleSignIn — without serverClientId. Used when idToken flow
// fails (ApiException 10 = SHA-1 mismatch or propagation delay). Gets an
// accessToken instead, which the server verifies via Google userinfo endpoint.
final _googleSignInFallback = GoogleSignIn(
  scopes: ['email', 'profile'],
);

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;
  final AnalyticsService? _analytics;
  final SubscriptionService? _subscriptions;

  AuthNotifier(this._repo, [this._analytics, this._subscriptions])
      : super(const AuthState());

  /// Check for stored token on app startup.
  Future<void> tryRestoreSession() async {
    final hasToken = await TokenStorage.hasTokens();
    if (!hasToken) {
      state = const AuthState(status: AuthStatus.unauthenticated);
      return;
    }

    try {
      final user = await _repo.getMe();
      state = AuthState(status: AuthStatus.authenticated, user: user);
      _analytics?.setUserId(user.id);
      _subscriptions?.setUserId(user.id);
    } catch (_) {
      await TokenStorage.clearTokens();
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, error: null, loadingMethod: AuthMethod.email);
    try {
      final response = await _repo.register(
        email: email,
        password: password,
        displayName: displayName,
      );
      await TokenStorage.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );
      state = AuthState(status: AuthStatus.authenticated, user: response.user);
      _analytics?.setUserId(response.user.id);
      _subscriptions?.setUserId(response.user.id);
      _analytics?.trackEvent('register');
      return true;
    } catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        error: _extractError(e),
      );
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, error: null, loadingMethod: AuthMethod.email);
    try {
      final response = await _repo.login(email: email, password: password);
      await TokenStorage.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );
      state = AuthState(status: AuthStatus.authenticated, user: response.user);
      _analytics?.setUserId(response.user.id);
      _subscriptions?.setUserId(response.user.id);
      _analytics?.trackEvent('login');
      return true;
    } catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        error: _extractError(e),
      );
      return false;
    }
  }

  Future<bool> loginWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading, error: null, loadingMethod: AuthMethod.google);
    try {
      // Try primary flow (idToken via serverClientId).
      await _googleSignIn.signOut().catchError((_) => null);
      debugPrint('[GoogleAuth] Attempting sign-in with serverClientId...');
      GoogleSignInAccount? account;
      try {
        account = await _googleSignIn.signIn();
      } catch (e) {
        // ApiException 10 = DEVELOPER_ERROR (SHA-1 mismatch or propagation).
        // Fall back to accessToken-only flow.
        debugPrint('[GoogleAuth] Primary failed: $e');
        debugPrint('[GoogleAuth] Falling back to accessToken-only flow...');
        await _googleSignInFallback.signOut().catchError((_) => null);
        account = await _googleSignInFallback.signIn();
      }

      if (account == null) {
        debugPrint('[GoogleAuth] User cancelled');
        state = const AuthState(status: AuthStatus.unauthenticated);
        return false;
      }
      debugPrint('[GoogleAuth] Got account: ${account.email}');

      final googleAuth = await account.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;
      debugPrint('[GoogleAuth] idToken: ${idToken != null ? "present" : "NULL"}');
      debugPrint('[GoogleAuth] accessToken: ${accessToken != null ? "present" : "NULL"}');

      if (idToken == null && accessToken == null) {
        state = const AuthState(
          status: AuthStatus.unauthenticated,
          error: 'Failed to get Google credentials',
        );
        return false;
      }

      debugPrint('[GoogleAuth] Calling server...');
      final response = await _repo.loginWithGoogle(
        idToken: idToken,
        accessToken: accessToken,
      );
      await TokenStorage.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );
      debugPrint('[GoogleAuth] Success!');
      state = AuthState(status: AuthStatus.authenticated, user: response.user);
      _analytics?.setUserId(response.user.id);
      _subscriptions?.setUserId(response.user.id);
      _analytics?.trackEvent('login_google');
      return true;
    } catch (e, stackTrace) {
      debugPrint('══════════════════════════════════════════');
      debugPrint('Google sign-in FAILED');
      debugPrint('Type: ${e.runtimeType}');
      debugPrint('Error: $e');
      debugPrint('Stack: $stackTrace');
      debugPrint('══════════════════════════════════════════');
      state = AuthState(
        status: AuthStatus.unauthenticated,
        error: _extractError(e),
      );
      return false;
    }
  }

  /// Generate a random nonce for Apple Sign In.
  String _generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  /// SHA256 hash of the nonce for Apple Sign In.
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<bool> loginWithApple() async {
    state = state.copyWith(status: AuthStatus.loading, error: null, loadingMethod: AuthMethod.apple);
    try {
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
        webAuthenticationOptions: WebAuthenticationOptions(
          clientId: const String.fromEnvironment(
            'APPLE_SERVICE_ID',
            defaultValue: 'com.romulororiz.trysomething.service',
          ),
          redirectUri: Uri.parse(
            'https://server-psi-seven-49.vercel.app/api/auth/apple-callback',
          ),
        ),
      );

      if (credential.authorizationCode.isEmpty) {
        state = const AuthState(
          status: AuthStatus.unauthenticated,
          error: 'Apple sign-in was cancelled',
        );
        return false;
      }

      debugPrint('[AppleAuth] Got credential, calling server...');

      final response = await _repo.loginWithApple(
        authorizationCode: credential.authorizationCode,
        identityToken: credential.identityToken,
        fullName: {
          'givenName': credential.givenName,
          'familyName': credential.familyName,
        },
      );

      await TokenStorage.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );
      debugPrint('[AppleAuth] Success!');
      state = AuthState(status: AuthStatus.authenticated, user: response.user);
      _analytics?.setUserId(response.user.id);
      _subscriptions?.setUserId(response.user.id);
      _analytics?.trackEvent('login_apple');
      return true;
    } catch (e, stackTrace) {
      debugPrint('══════════════════════════════════════════');
      debugPrint('Apple sign-in FAILED');
      debugPrint('Type: ${e.runtimeType}');
      debugPrint('Error: $e');
      debugPrint('Stack: $stackTrace');
      debugPrint('══════════════════════════════════════════');

      // User cancelled — don't show error
      if (e is SignInWithAppleAuthorizationException &&
          e.code == AuthorizationErrorCode.canceled) {
        state = const AuthState(status: AuthStatus.unauthenticated);
        return false;
      }

      state = AuthState(
        status: AuthStatus.unauthenticated,
        error: _extractError(e),
      );
      return false;
    }
  }

  Future<void> logout() async {
    _analytics?.trackEvent('logout');
    _analytics?.setUserId(null);
    _subscriptions?.clearUser();
    await TokenStorage.clearTokens();
    // Fire-and-forget — signOut hangs on unsupported platforms (Windows/Linux).
    _googleSignIn.signOut().catchError((_) => null);
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  void clearError() {
    if (state.error != null) {
      state = state.copyWith(error: null);
    }
  }

  Future<void> updateProfile({String? displayName, String? bio, String? avatarUrl, String? fcmToken}) async {
    try {
      final updated = await _repo.updateProfile(
        displayName: displayName,
        bio: bio,
        avatarUrl: avatarUrl,
        fcmToken: fcmToken,
      );
      state = state.copyWith(user: updated);
    } catch (_) {}
  }

  String _extractError(dynamic e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && data.containsKey('error')) {
        return data['error'] as String;
      }
      if (e.response?.statusCode == 409) return 'Email already registered';
      if (e.response?.statusCode == 401) return 'Invalid email or password';
    }
    // Surface Google Sign-In plugin errors
    final msg = e.toString();
    if (msg.contains('sign_in_failed')) {
      return 'Google sign-in failed. Check your Google account configuration.';
    }
    if (msg.contains('network_error')) {
      return 'Network error. Please check your connection.';
    }
    return 'Something went wrong. Please try again.';
  }
}

// ═══════════════════════════════════════════════════
//  PROVIDERS
// ═══════════════════════════════════════════════════

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryApi();
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final analytics = ref.watch(analyticsProvider);
  final subscriptions = ref.watch(subscriptionProvider);
  return AuthNotifier(ref.watch(authRepositoryProvider), analytics, subscriptions);
});

/// Convenience: whether the user is authenticated.
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).status == AuthStatus.authenticated;
});
