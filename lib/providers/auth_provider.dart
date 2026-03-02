import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../core/auth/token_storage.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/auth_repository_api.dart';
import '../models/auth.dart';

// ═══════════════════════════════════════════════════
//  AUTH STATE
// ═══════════════════════════════════════════════════

enum AuthStatus { unknown, unauthenticated, loading, authenticated }

enum AuthMethod { none, email, google }

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

// Shared GoogleSignIn instance — must be reused across sign-in/sign-out.
final _googleSignIn = GoogleSignIn(
  scopes: ['email', 'profile'],
  // On Android, serverClientId makes the plugin request an idToken
  // your server can verify. Empty string means "not set".
  serverClientId: const String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID') != ''
      ? const String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID')
      : null,
);

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;

  AuthNotifier(this._repo) : super(const AuthState());

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
      // Sign out first to clear cached session and force account picker.
      await _googleSignIn.signOut().catchError((_) => null);
      final account = await _googleSignIn.signIn();
      if (account == null) {
        // User cancelled
        state = const AuthState(status: AuthStatus.unauthenticated);
        return false;
      }
      final googleAuth = await account.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null && accessToken == null) {
        state = const AuthState(
          status: AuthStatus.unauthenticated,
          error: 'Failed to get Google credentials',
        );
        return false;
      }

      // Prefer idToken (Android/iOS), fall back to accessToken (Windows/web).
      final response = await _repo.loginWithGoogle(
        idToken: idToken,
        accessToken: accessToken,
      );
      await TokenStorage.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );
      state = AuthState(status: AuthStatus.authenticated, user: response.user);
      return true;
    } catch (e) {
      debugPrint('Google sign-in error: $e');
      state = AuthState(
        status: AuthStatus.unauthenticated,
        error: _extractError(e),
      );
      return false;
    }
  }

  Future<void> logout() async {
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

  Future<void> updateProfile({String? displayName, String? avatarUrl}) async {
    try {
      final updated = await _repo.updateProfile(
        displayName: displayName,
        avatarUrl: avatarUrl,
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
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

/// Convenience: whether the user is authenticated.
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).status == AuthStatus.authenticated;
});
