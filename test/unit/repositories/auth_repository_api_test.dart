import 'package:flutter_test/flutter_test.dart';
import 'package:trysomething/models/auth.dart';
import 'package:trysomething/models/hobby.dart';

// AuthRepositoryApi cannot be tested directly because it uses ApiClient.instance
// (a global Dio singleton) with no injection point, making it impossible to
// intercept HTTP calls in unit tests.
//
// These tests instead cover the JSON serialization of every model that
// AuthRepositoryApi consumes and returns: AuthUser, AuthResponse, and
// UserPreferences (defined in hobby.dart).

void main() {
  // ─────────────────────────────────────────────────────────────
  // AuthUser
  // ─────────────────────────────────────────────────────────────
  group('AuthUser.fromJson', () {
    test('parses all fields including optionals', () {
      final json = {
        'id': 'user_42',
        'email': 'alice@example.com',
        'displayName': 'Alice',
        'bio': 'loves sketching',
        'avatarUrl': 'https://cdn.example.com/avatar.jpg',
        'createdAt': '2025-01-15T10:00:00.000Z',
      };

      final user = AuthUser.fromJson(json);

      expect(user.id, 'user_42');
      expect(user.email, 'alice@example.com');
      expect(user.displayName, 'Alice');
      expect(user.bio, 'loves sketching');
      expect(user.avatarUrl, 'https://cdn.example.com/avatar.jpg');
      expect(user.createdAt, '2025-01-15T10:00:00.000Z');
    });

    test('uses defaults when optional fields are absent', () {
      final json = {
        'id': 'user_1',
        'email': 'bob@example.com',
        'displayName': 'Bob',
      };

      final user = AuthUser.fromJson(json);

      expect(user.id, 'user_1');
      expect(user.email, 'bob@example.com');
      expect(user.displayName, 'Bob');
      // bio defaults to '' per @Default('')
      expect(user.bio, '');
      // avatarUrl and createdAt are nullable with no default
      expect(user.avatarUrl, isNull);
      expect(user.createdAt, isNull);
    });

    test('handles null optional fields explicitly', () {
      final json = {
        'id': 'user_2',
        'email': 'carol@example.com',
        'displayName': 'Carol',
        'bio': null,
        'avatarUrl': null,
        'createdAt': null,
      };

      final user = AuthUser.fromJson(json);

      // bio falls back to default '' when null comes from JSON
      expect(user.bio, '');
      expect(user.avatarUrl, isNull);
      expect(user.createdAt, isNull);
    });
  });

  group('AuthUser.copyWith', () {
    test('updates displayName and preserves all other fields', () {
      const original = AuthUser(
        id: 'user_10',
        email: 'dan@example.com',
        displayName: 'Dan',
        bio: 'painter',
        avatarUrl: 'https://example.com/dan.jpg',
        createdAt: '2025-06-01T00:00:00.000Z',
      );

      final updated = original.copyWith(displayName: 'Daniel');

      expect(updated.displayName, 'Daniel');
      expect(updated.id, original.id);
      expect(updated.email, original.email);
      expect(updated.bio, original.bio);
      expect(updated.avatarUrl, original.avatarUrl);
      expect(updated.createdAt, original.createdAt);
    });

    test('can clear avatarUrl by setting it to null', () {
      const original = AuthUser(
        id: 'user_11',
        email: 'eve@example.com',
        displayName: 'Eve',
        avatarUrl: 'https://example.com/eve.jpg',
      );

      final updated = original.copyWith(avatarUrl: null);

      expect(updated.avatarUrl, isNull);
      expect(updated.id, original.id);
      expect(updated.email, original.email);
    });
  });

  group('AuthUser round-trip', () {
    test('toJson then fromJson produces equivalent object', () {
      const user = AuthUser(
        id: 'user_99',
        email: 'roundtrip@example.com',
        displayName: 'Round Trip',
        bio: 'testing toJson',
        avatarUrl: 'https://example.com/rt.png',
        createdAt: '2025-12-31T23:59:59.000Z',
      );

      final restored = AuthUser.fromJson(user.toJson());

      expect(restored, user);
    });

    test('toJson then fromJson with minimal fields', () {
      const user = AuthUser(
        id: 'min_user',
        email: 'min@example.com',
        displayName: 'Minimal',
      );

      final restored = AuthUser.fromJson(user.toJson());

      expect(restored, user);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // AuthResponse
  // ─────────────────────────────────────────────────────────────
  group('AuthResponse.fromJson', () {
    test('parses user, accessToken and refreshToken correctly', () {
      final json = {
        'user': {
          'id': 'user_5',
          'email': 'frank@example.com',
          'displayName': 'Frank',
        },
        'accessToken': 'eyJhbGciOi.access',
        'refreshToken': 'eyJhbGciOi.refresh',
      };

      final response = AuthResponse.fromJson(json);

      expect(response.accessToken, 'eyJhbGciOi.access');
      expect(response.refreshToken, 'eyJhbGciOi.refresh');
      expect(response.user.id, 'user_5');
      expect(response.user.email, 'frank@example.com');
      expect(response.user.displayName, 'Frank');
    });
  });

  group('AuthResponse round-trip', () {
    test('toJson then fromJson produces equivalent object', () {
      const user = AuthUser(
        id: 'user_rt',
        email: 'rt@example.com',
        displayName: 'RT User',
        bio: 'round tripper',
        avatarUrl: 'https://example.com/rt_user.jpg',
      );
      const response = AuthResponse(
        user: user,
        accessToken: 'access_abc',
        refreshToken: 'refresh_xyz',
      );

      final restored = AuthResponse.fromJson(response.toJson());

      expect(restored, response);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // UserPreferences (defined in hobby.dart)
  // ─────────────────────────────────────────────────────────────
  group('UserPreferences.fromJson', () {
    test('parses hoursPerWeek, budgetLevel, preferSocial, and vibes', () {
      final json = {
        'hoursPerWeek': 5,
        'budgetLevel': 2,
        'preferSocial': true,
        'vibes': ['relaxing', 'creative'],
      };

      final prefs = UserPreferences.fromJson(json);

      expect(prefs.hoursPerWeek, 5);
      expect(prefs.budgetLevel, 2);
      expect(prefs.preferSocial, isTrue);
      expect(prefs.vibes, containsAll(['relaxing', 'creative']));
      expect(prefs.vibes.length, 2);
    });

    test('uses default values when all fields are absent', () {
      final prefs = UserPreferences.fromJson({});

      // Defaults declared in the model:
      // hoursPerWeek: 3, budgetLevel: 1, preferSocial: false, vibes: {}
      expect(prefs.hoursPerWeek, 3);
      expect(prefs.budgetLevel, 1);
      expect(prefs.preferSocial, isFalse);
      expect(prefs.vibes, isEmpty);
    });

    test('vibes is a Set — duplicates are deduplicated', () {
      final json = {
        'hoursPerWeek': 2,
        'budgetLevel': 1,
        'preferSocial': false,
        'vibes': ['active', 'active', 'outdoors'],
      };

      final prefs = UserPreferences.fromJson(json);

      expect(prefs.vibes, {'active', 'outdoors'});
      expect(prefs.vibes.length, 2);
    });
  });

  group('UserPreferences round-trip', () {
    test('toJson then fromJson produces equivalent object', () {
      final prefs = UserPreferences.fromJson({
        'hoursPerWeek': 4,
        'budgetLevel': 3,
        'preferSocial': true,
        'vibes': ['mindful', 'solo'],
      });

      final restored = UserPreferences.fromJson(prefs.toJson());

      expect(restored, prefs);
    });
  });
}
