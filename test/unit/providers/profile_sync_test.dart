import 'package:flutter_test/flutter_test.dart';
import 'package:trysomething/data/repositories/auth_repository.dart';
import 'package:trysomething/models/auth.dart';
import 'package:trysomething/models/hobby.dart';
import 'package:trysomething/providers/feature_providers.dart';

/// Mock auth repository that tracks calls and returns predictable results.
class MockAuthRepository implements AuthRepository {
  bool shouldFail = false;
  final List<String> calls = [];
  String? lastDisplayName;
  String? lastBio;
  String? lastAvatarUrl;

  @override
  Future<AuthUser> updateProfile({
    String? displayName,
    String? bio,
    String? avatarUrl,
    String? fcmToken,
  }) async {
    calls.add('updateProfile');
    lastDisplayName = displayName;
    lastBio = bio;
    lastAvatarUrl = avatarUrl;
    if (shouldFail) throw Exception('mock failure');
    return AuthUser(
      id: 'u1',
      email: 'test@test.com',
      displayName: displayName ?? 'Test',
      bio: bio ?? '',
      avatarUrl: avatarUrl,
    );
  }

  // ── Unused stubs ──

  @override
  Future<AuthResponse> register({
    required String email,
    required String password,
    required String displayName,
  }) async =>
      throw UnimplementedError();

  @override
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async =>
      throw UnimplementedError();

  @override
  Future<AuthResponse> loginWithGoogle({
    String? idToken,
    String? accessToken,
  }) async =>
      throw UnimplementedError();

  @override
  Future<AuthResponse> loginWithApple({
    String? authorizationCode,
    String? identityToken,
    Map<String, String?>? fullName,
  }) async =>
      throw UnimplementedError();

  @override
  Future<void> deleteAccount({String? password}) async =>
      throw UnimplementedError();

  @override
  Future<Map<String, dynamic>> refreshToken({
    required String refreshToken,
  }) async =>
      throw UnimplementedError();

  @override
  Future<AuthUser> getMe() async => throw UnimplementedError();

  @override
  Future<UserPreferences> updatePreferences({
    int? hoursPerWeek,
    int? budgetLevel,
    bool? preferSocial,
    Set<String>? vibes,
  }) async =>
      throw UnimplementedError();
}

void main() {
  // ═══════════════════════════════════════════════════════
  //  PROFILE NOTIFIER
  // ═══════════════════════════════════════════════════════

  group('ProfileNotifier', () {
    late MockAuthRepository repo;
    late ProfileNotifier notifier;

    setUp(() {
      repo = MockAuthRepository();
      notifier = ProfileNotifier(repo);
    });

    test('initFromAuth populates state from AuthUser', () {
      const user = AuthUser(
        id: 'u1',
        email: 'alice@test.com',
        displayName: 'Alice',
        bio: 'Hello world',
        avatarUrl: 'https://img.example.com/alice.jpg',
      );

      notifier.initFromAuth(user);

      expect(notifier.state.username, 'Alice');
      expect(notifier.state.bio, 'Hello world');
      expect(notifier.state.avatarUrl, 'https://img.example.com/alice.jpg');
    });

    test('initFromAuth handles empty bio and null avatar', () {
      const user = AuthUser(
        id: 'u2',
        email: 'bob@test.com',
        displayName: 'Bob',
      );

      notifier.initFromAuth(user);

      expect(notifier.state.username, 'Bob');
      expect(notifier.state.bio, '');
      expect(notifier.state.avatarUrl, isNull);
    });

    test('updateBio updates state and calls repo', () async {
      notifier.updateBio('New bio');

      expect(notifier.state.bio, 'New bio');
      // Give fire-and-forget future time to complete
      await Future<void>.delayed(Duration.zero);
      expect(repo.calls, contains('updateProfile'));
      expect(repo.lastBio, 'New bio');
    });

    test('updateAvatar updates state and calls repo', () async {
      notifier.updateAvatar('https://img.example.com/new.jpg');

      expect(notifier.state.avatarUrl, 'https://img.example.com/new.jpg');
      await Future<void>.delayed(Duration.zero);
      expect(repo.calls, contains('updateProfile'));
      expect(repo.lastAvatarUrl, 'https://img.example.com/new.jpg');
    });

    test('updateAvatar with null skips server sync', () async {
      notifier.updateAvatar(null);

      expect(notifier.state.avatarUrl, isNull);
      await Future<void>.delayed(Duration.zero);
      expect(repo.calls, isEmpty);
    });

    test('updateUsername updates state and calls repo', () async {
      notifier.updateUsername('NewName');

      expect(notifier.state.username, 'NewName');
      await Future<void>.delayed(Duration.zero);
      expect(repo.calls, contains('updateProfile'));
      expect(repo.lastDisplayName, 'NewName');
    });

    test('server failure does not revert state (optimistic)', () async {
      repo.shouldFail = true;
      notifier.updateBio('Optimistic bio');

      expect(notifier.state.bio, 'Optimistic bio');
      // Give the catchError time to fire
      await Future<void>.delayed(const Duration(milliseconds: 50));
      // State should still reflect the optimistic update
      expect(notifier.state.bio, 'Optimistic bio');
    });
  });
}
