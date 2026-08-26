import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../core/auth/token_storage.dart';
import '../core/storage/cache_manager.dart';
import '../core/analytics/analytics_provider.dart';
import '../core/analytics/analytics_service.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/auth_repository_api.dart';
import '../models/auth.dart';
import 'user_provider.dart';
import 'feature_providers.dart';
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

// Google OAuth *web* client ID — a public identifier, baked as the default so
// CI builds without --dart-define still request an idToken (whose audience the
// server accepts). Single source of truth: the sign-in config below and the
// idToken gate in loginWithGoogle must never disagree.
const _googleServerClientId = String.fromEnvironment(
  'GOOGLE_SERVER_CLIENT_ID',
  defaultValue:
      '941963960338-3583dc8tj80i8bi95le7in6c1jr1u96f.apps.googleusercontent.com',
);

// Primary GoogleSignIn — with serverClientId to request idToken (Android/iOS).
final _googleSignIn = GoogleSignIn(
  scopes: ['email', 'profile'],
  serverClientId: _googleServerClientId.isEmpty ? null : _googleServerClientId,
);


class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;
  final AnalyticsService? _analytics;
  final SubscriptionService? _subscriptions;
  final OnboardingNotifier? _onboarding;
  final Ref? _ref;

  AuthNotifier(this._repo,
      [this._analytics, this._subscriptions, this._onboarding, this._ref])
      : super(const AuthState());

  /// Sync user identity to Sentry for crash attribution.
  void _setSentryUser(String? userId) {
    Sentry.configureScope((scope) {
      scope.setUser(userId != null ? SentryUser(id: userId) : null);
    });
  }

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
      _setSentryUser(user.id);
      _onboarding?.complete();
      // RevenueCat setUserId is handled in main.dart (awaited) — not here
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
      _setSentryUser(response.user.id);
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
      _setSentryUser(response.user.id);
      _subscriptions?.setUserId(response.user.id);
      _onboarding?.complete();
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
      // Single sign-in flow — uses serverClientId if available (for idToken),
      // falls back gracefully to accessToken if not.
      await _googleSignIn.signOut().catchError((_) => null);
      debugPrint('[GoogleAuth] Attempting sign-in...');
      final account = await _googleSignIn.signIn();

      if (account == null) {
        debugPrint('[GoogleAuth] User cancelled');
        state = const AuthState(status: AuthStatus.unauthenticated);
        return false;
      }
      debugPrint('[GoogleAuth] Got account: ${account.email}');

      final googleAuth = await account.authentication;
      // Only trust idToken if serverClientId was set — otherwise the token's
      // audience is the Android client ID which the server won't accept.
      const hasServerClientId = _googleServerClientId != '';
      final idToken = hasServerClientId ? googleAuth.idToken : null;
      final accessToken = googleAuth.accessToken;
      debugPrint('[GoogleAuth] idToken: ${idToken != null ? "present" : "NULL"} (serverClientId: $hasServerClientId)');
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
      _setSentryUser(response.user.id);
      _subscriptions?.setUserId(response.user.id);
      _onboarding?.complete();
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
            'https://api.trysomething.io/api/auth/apple-callback',
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
      _setSentryUser(response.user.id);
      _subscriptions?.setUserId(response.user.id);
      _onboarding?.complete();
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

  /// Wipe every trace of the current user from the device.
  ///
  /// Owned by the notifier rather than the calling screen so no logout path
  /// can forget a step — the previous split let a bare logout() leave cached
  /// API responses and in-memory provider state behind, which the next
  /// account would briefly see.
  ///
  /// Order matters: SharedPreferences must be cleared BEFORE providers are
  /// invalidated, because notifiers reload from prefs when recreated.
  Future<void> _clearUserData() async {
    await TokenStorage.clearTokens();
    await CacheManager.clearAll();

    // Coach history lives in its own boxes, outside CacheManager.
    for (final box in ['coach_conversations', 'coach_limits']) {
      try {
        await (await Hive.openBox(box)).clear();
      } catch (e) {
        debugPrint('[Logout] Could not clear $box: $e');
      }
    }

    final ref = _ref;
    if (ref == null) return;

    await ref.read(sharedPreferencesProvider).clear();
    ref.read(userHobbiesProvider.notifier).clear();

    // Every provider seeded on login (see main.dart) plus the user-scoped
    // ones loaded lazily afterwards. Invalidation recreates them empty.
    ref.invalidate(profileProvider);
    ref.invalidate(proStatusProvider);
    ref.invalidate(journalProvider);
    ref.invalidate(scheduleProvider);
    ref.invalidate(storiesProvider);
    ref.invalidate(buddyProvider);
    ref.invalidate(challengeProvider);
    ref.invalidate(achievementsProvider);
    ref.invalidate(notesProvider);
    ref.invalidate(shoppingListCheckedProvider);
    ref.invalidate(activityLogProvider);
    ref.invalidate(userPreferencesProvider);
  }

  Future<void> logout() async {
    _analytics?.trackEvent('logout');
    _analytics?.setUserId(null);
    _setSentryUser(null);
    _subscriptions?.clearUser();
    await _clearUserData();
    // Fire-and-forget — signOut hangs on unsupported platforms (Windows/Linux).
    _googleSignIn.signOut().catchError((_) => null);
    state = const AuthState(status: AuthStatus.unauthenticated);
    // After the state flip: an authenticated-but-not-onboarded user would be
    // routed to /onboarding instead of /login.
    _onboarding?.reset();
  }

  /// Delete the user's account. Returns true on success.
  Future<bool> deleteAccount({String? password}) async {
    try {
      await _repo.deleteAccount(password: password);
      // Cleanup AFTER successful API call only
      _analytics?.trackEvent('account_deleted');
      _analytics?.setUserId(null);
      _setSentryUser(null);
      _subscriptions?.clearUser();
      await _clearUserData();
      _googleSignIn.signOut().catchError((_) => null);
      state = const AuthState(status: AuthStatus.unauthenticated);
      _onboarding?.reset();
      return true;
    } catch (e) {
      debugPrint('[DeleteAccount] Failed: $e');
      return false;
    }
  }

  void clearError() {
    if (state.error != null) {
      state = state.copyWith(error: null);
    }
  }

  /// Verify email with 6-digit code. Returns null on success, error string on failure.
  Future<String?> verifyEmail(String code) async {
    try {
      final verified = await _repo.verifyEmail(code: code);
      if (verified && state.user != null) {
        state = state.copyWith(user: state.user!.copyWith(emailVerified: true));
      }
      return null;
    } catch (e) {
      return _extractError(e);
    }
  }

  /// Resend verification email. Returns null on success, error string on failure.
  Future<String?> resendVerification() async {
    try {
      await _repo.resendVerification();
      return null;
    } catch (e) {
      return _extractError(e);
    }
  }

  /// Change password for email users. Returns null on success, error string on failure.
  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _repo.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return null;
    } catch (e) {
      return _extractError(e);
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
    debugPrint('[Auth] Error: $e');
    if (e is DioException) {
      debugPrint('[Auth] DioException: type=${e.type}, status=${e.response?.statusCode}, data=${e.response?.data}, message=${e.message}');
      final data = e.response?.data;
      if (data is Map && data.containsKey('error')) {
        return data['error'] as String;
      }
      if (e.response?.statusCode == 409) return 'Email already registered';
      if (e.response?.statusCode == 401) return 'Invalid email or password';
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        return 'Cannot reach server. Check your connection.';
      }
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
  final onboarding = ref.watch(onboardingCompleteProvider.notifier);
  return AuthNotifier(
      ref.watch(authRepositoryProvider), analytics, subscriptions, onboarding, ref);
});

/// Convenience: whether the user is authenticated.
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).status == AuthStatus.authenticated;
});

/// Convenience: whether the user has verified their email.
final emailVerifiedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).user?.emailVerified ?? false;
});
