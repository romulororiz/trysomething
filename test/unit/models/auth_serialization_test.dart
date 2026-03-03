import 'package:flutter_test/flutter_test.dart';
import 'package:trysomething/models/auth.dart';

void main() {
  group('AuthUser serialization', () {
    test('fromJson with all fields', () {
      final json = {
        'id': 'u1',
        'email': 'test@example.com',
        'displayName': 'Test User',
        'bio': 'Hello world',
        'avatarUrl': 'https://example.com/avatar.jpg',
        'createdAt': '2026-01-01T00:00:00.000Z',
      };
      final user = AuthUser.fromJson(json);
      expect(user.id, 'u1');
      expect(user.email, 'test@example.com');
      expect(user.displayName, 'Test User');
      expect(user.bio, 'Hello world');
      expect(user.avatarUrl, 'https://example.com/avatar.jpg');
      expect(user.createdAt, '2026-01-01T00:00:00.000Z');
    });

    test('fromJson with minimal fields', () {
      final json = {
        'id': 'u2',
        'email': 'min@test.com',
        'displayName': 'Min',
      };
      final user = AuthUser.fromJson(json);
      expect(user.id, 'u2');
      expect(user.bio, ''); // default
      expect(user.avatarUrl, isNull);
      expect(user.createdAt, isNull);
    });

    test('toJson round-trip', () {
      const user = AuthUser(
        id: 'u1',
        email: 'test@example.com',
        displayName: 'Test',
        bio: 'Bio text',
      );
      final json = user.toJson();
      final restored = AuthUser.fromJson(json);
      expect(restored.id, user.id);
      expect(restored.email, user.email);
      expect(restored.displayName, user.displayName);
      expect(restored.bio, user.bio);
    });

    test('copyWith creates modified copy', () {
      const user = AuthUser(
        id: 'u1',
        email: 'a@b.com',
        displayName: 'Original',
      );
      final modified = user.copyWith(displayName: 'Modified');
      expect(modified.displayName, 'Modified');
      expect(modified.id, 'u1'); // unchanged
      expect(modified.email, 'a@b.com'); // unchanged
    });
  });

  group('AuthResponse serialization', () {
    test('fromJson with all fields', () {
      final json = {
        'user': {
          'id': 'u1',
          'email': 'test@example.com',
          'displayName': 'Test',
        },
        'accessToken': 'access_123',
        'refreshToken': 'refresh_456',
      };
      final response = AuthResponse.fromJson(json);
      expect(response.user.id, 'u1');
      expect(response.accessToken, 'access_123');
      expect(response.refreshToken, 'refresh_456');
    });

    test('toJson round-trip', () {
      const response = AuthResponse(
        user: AuthUser(id: 'u1', email: 'a@b.com', displayName: 'Test'),
        accessToken: 'at',
        refreshToken: 'rt',
      );
      final json = response.toJson();
      final restored = AuthResponse.fromJson(json);
      expect(restored.user.id, response.user.id);
      expect(restored.accessToken, response.accessToken);
      expect(restored.refreshToken, response.refreshToken);
    });
  });
}
