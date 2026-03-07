import 'package:flutter_test/flutter_test.dart';
import 'package:trysomething/data/repositories/auth_repository.dart';
import 'package:trysomething/models/auth.dart';
import 'package:trysomething/models/hobby.dart';
import 'package:trysomething/providers/auth_provider.dart';

/// Mock AuthRepository for testing AuthNotifier in isolation.
class MockAuthRepository implements AuthRepository {
  bool shouldFail = false;
  String failMessage = 'mock failure';
  final List<String> calls = [];

  AuthUser mockUser = const AuthUser(
    id: 'user_1',
    email: 'test@example.com',
    displayName: 'Test User',
  );

  @override
  Future<AuthResponse> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    calls.add('register:$email');
    if (shouldFail) throw Exception(failMessage);
    return AuthResponse(
      user: mockUser.copyWith(email: email, displayName: displayName),
      accessToken: 'access_token',
      refreshToken: 'refresh_token',
    );
  }

  @override
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    calls.add('login:$email');
    if (shouldFail) throw Exception(failMessage);
    return AuthResponse(
      user: mockUser.copyWith(email: email),
      accessToken: 'access_token',
      refreshToken: 'refresh_token',
    );
  }

  @override
  Future<AuthResponse> loginWithGoogle({String? idToken, String? accessToken}) async {
    calls.add('loginWithGoogle');
    if (shouldFail) throw Exception(failMessage);
    return AuthResponse(
      user: mockUser,
      accessToken: 'access_token',
      refreshToken: 'refresh_token',
    );
  }

  @override
  Future<Map<String, dynamic>> refreshToken({required String refreshToken}) async {
    calls.add('refreshToken');
    if (shouldFail) throw Exception(failMessage);
    return {'accessToken': 'new_access', 'refreshToken': 'new_refresh'};
  }

  @override
  Future<AuthUser> getMe() async {
    calls.add('getMe');
    if (shouldFail) throw Exception(failMessage);
    return mockUser;
  }

  @override
  Future<AuthUser> updateProfile({String? displayName, String? bio, String? avatarUrl, String? fcmToken}) async {
    calls.add('updateProfile');
    if (shouldFail) throw Exception(failMessage);
    return mockUser.copyWith(
      displayName: displayName ?? mockUser.displayName,
      bio: bio ?? mockUser.bio,
      avatarUrl: avatarUrl ?? mockUser.avatarUrl,
    );
  }

  @override
  Future<UserPreferences> updatePreferences({
    int? hoursPerWeek,
    int? budgetLevel,
    bool? preferSocial,
    Set<String>? vibes,
  }) async {
    calls.add('updatePreferences');
    if (shouldFail) throw Exception(failMessage);
    return UserPreferences(
      hoursPerWeek: hoursPerWeek ?? 5,
      budgetLevel: budgetLevel ?? 2,
      preferSocial: preferSocial ?? false,
      vibes: vibes ?? {},
    );
  }
}

void main() {
  late MockAuthRepository mockRepo;
  late AuthNotifier notifier;

  setUp(() {
    mockRepo = MockAuthRepository();
    notifier = AuthNotifier(mockRepo);
  });

  // Note: register/login/logout full-flow tests that call TokenStorage.saveTokens
  // are skipped because flutter_secure_storage requires a platform channel
  // not available in unit tests. Those flows are covered by integration tests.

  group('AuthNotifier initial state', () {
    test('starts with unknown status', () {
      expect(notifier.state.status, AuthStatus.unknown);
      expect(notifier.state.user, isNull);
      expect(notifier.state.error, isNull);
      expect(notifier.state.loadingMethod, AuthMethod.none);
    });
  });

  group('register', () {
    test('calls repo with correct params', () async {
      // Will fail due to TokenStorage, but repo should be called
      await notifier.register(
        email: 'a@b.com',
        password: '123456',
        displayName: 'Alice',
      );
      expect(mockRepo.calls, contains('register:a@b.com'));
    });

    test('sets error on repo failure', () async {
      mockRepo.shouldFail = true;
      final result = await notifier.register(
        email: 'a@b.com',
        password: '123456',
        displayName: 'Alice',
      );
      expect(result, isFalse);
      expect(notifier.state.status, AuthStatus.unauthenticated);
      expect(notifier.state.error, isNotNull);
    });
  });

  group('login', () {
    test('calls repo with correct params', () async {
      await notifier.login(email: 'a@b.com', password: '123456');
      expect(mockRepo.calls, contains('login:a@b.com'));
    });

    test('sets error on repo failure', () async {
      mockRepo.shouldFail = true;
      final result = await notifier.login(
        email: 'a@b.com',
        password: 'wrong',
      );
      expect(result, isFalse);
      expect(notifier.state.status, AuthStatus.unauthenticated);
      expect(notifier.state.error, isNotNull);
    });
  });

  group('clearError', () {
    test('clears error from state', () async {
      mockRepo.shouldFail = true;
      await notifier.login(email: 'a@b.com', password: 'wrong');
      expect(notifier.state.error, isNotNull);

      notifier.clearError();
      expect(notifier.state.error, isNull);
    });

    test('no-ops when no error', () {
      notifier.clearError();
      expect(notifier.state.error, isNull);
    });
  });

  // tryRestoreSession and logout are not unit-testable because they call
  // TokenStorage (flutter_secure_storage) which requires native platform
  // channels unavailable in unit tests.

  group('AuthState', () {
    test('copyWith preserves fields', () {
      const state = AuthState(
        status: AuthStatus.authenticated,
        error: 'some error',
        loadingMethod: AuthMethod.email,
      );
      final copied = state.copyWith(status: AuthStatus.loading);
      expect(copied.status, AuthStatus.loading);
      expect(copied.loadingMethod, AuthMethod.email);
    });

    test('default state has expected values', () {
      const state = AuthState();
      expect(state.status, AuthStatus.unknown);
      expect(state.user, isNull);
      expect(state.error, isNull);
      expect(state.loadingMethod, AuthMethod.none);
    });
  });
}
