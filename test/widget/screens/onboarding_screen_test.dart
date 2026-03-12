import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trysomething/models/hobby.dart';
import 'package:trysomething/providers/user_provider.dart';
import 'package:trysomething/providers/repository_providers.dart';
import 'package:trysomething/data/repositories/hobby_repository.dart';
import 'package:trysomething/data/repositories/personal_tools_repository.dart';
import 'package:trysomething/data/repositories/user_progress_repository.dart';
import 'package:trysomething/data/repositories/auth_repository.dart';
import 'package:trysomething/providers/auth_provider.dart';
import 'package:trysomething/models/curated_pack.dart';
import 'package:trysomething/models/features.dart';
import 'package:trysomething/models/social.dart';
import 'package:trysomething/models/auth.dart' as auth_models;
import 'package:trysomething/models/hobby.dart' as hobby_models;
import 'package:trysomething/screens/onboarding/onboarding_screen.dart';

// ── Minimal stubs ──────────────────────────────────────────────────────────

class _StubHobbyRepository implements HobbyRepository {
  @override
  Future<List<Hobby>> getHobbies() async => [];

  @override
  Future<Hobby?> getHobbyById(String id) async => null;

  @override
  Future<List<HobbyCategory>> getCategories() async => [];

  @override
  Future<List<Hobby>> getRelatedHobbies(String hobbyId, {int limit = 3}) async => [];

  @override
  Future<List<Hobby>> searchHobbies(String query) async => [];

  @override
  Future<List<CuratedPack>> getCuratedPacks() async => [];

  @override
  Future<Hobby> generateHobby(String query) async =>
      throw UnimplementedError('generateHobby not needed in test');
}

class _StubPersonalToolsRepository implements PersonalToolsRepository {
  @override
  Future<List<JournalEntry>> getJournalEntries() async => [];

  @override
  Future<JournalEntry> createJournalEntry({
    String? hobbyId,
    required String text,
    String? photoUrl,
  }) async =>
      throw UnimplementedError();

  @override
  Future<void> deleteJournalEntry(String entryId) async {}

  @override
  Future<Map<String, String>> getNotesForHobby(String hobbyId) async => {};

  @override
  Future<void> saveNote({
    required String hobbyId,
    required String stepId,
    required String text,
  }) async {}

  @override
  Future<void> deleteNote({required String hobbyId, required String stepId}) async {}

  @override
  Future<List<ScheduleEvent>> getScheduleEvents() async => [];

  @override
  Future<ScheduleEvent> createScheduleEvent({
    required String hobbyId,
    required int dayOfWeek,
    required String startTime,
    required int durationMinutes,
  }) async =>
      throw UnimplementedError();

  @override
  Future<void> deleteScheduleEvent(String eventId) async {}

  @override
  Future<Set<String>> getCheckedItems(String hobbyId) async => {};

  @override
  Future<void> toggleShoppingItem({
    required String hobbyId,
    required String itemName,
    required bool checked,
  }) async {}
}

class _StubUserProgressRepository implements UserProgressRepository {
  final UserHobby _stub = const UserHobby(
    hobbyId: 'stub',
    status: HobbyStatus.saved,
  );

  @override
  Future<List<UserHobby>> getHobbies() async => [];

  @override
  Future<UserHobby> saveHobby(String hobbyId) async => _stub;

  @override
  Future<void> unsaveHobby(String hobbyId) async {}

  @override
  Future<UserHobby> updateStatus(
    String hobbyId,
    HobbyStatus status, {
    DateTime? startedAt,
    DateTime? completedAt,
  }) async =>
      _stub;

  @override
  Future<UserHobby> toggleStep(String hobbyId, String stepId) async => _stub;

  @override
  Future<List<UserHobby>> syncHobbies(List<UserHobby> hobbies) async => hobbies;

  @override
  Future<List<Map<String, dynamic>>> getActivityLog({int days = 365}) async => [];
}

class _StubAuthRepository implements AuthRepository {
  @override
  Future<auth_models.AuthResponse> register({
    required String email,
    required String password,
    required String displayName,
  }) async =>
      throw UnimplementedError();

  @override
  Future<auth_models.AuthResponse> login({
    required String email,
    required String password,
  }) async =>
      throw UnimplementedError();

  @override
  Future<auth_models.AuthResponse> loginWithGoogle({
    String? idToken,
    String? accessToken,
  }) async =>
      throw UnimplementedError();

  @override
  Future<Map<String, dynamic>> refreshToken({
    required String refreshToken,
  }) async =>
      throw UnimplementedError();

  @override
  Future<auth_models.AuthUser> getMe() async => throw UnimplementedError();

  @override
  Future<auth_models.AuthUser> updateProfile({
    String? displayName,
    String? bio,
    String? avatarUrl,
    String? fcmToken,
  }) async =>
      throw UnimplementedError();

  @override
  Future<hobby_models.UserPreferences> updatePreferences({
    int? hoursPerWeek,
    int? budgetLevel,
    bool? preferSocial,
    Set<String>? vibes,
  }) async =>
      const hobby_models.UserPreferences();
}

// ── Helpers ────────────────────────────────────────────────────────────────

Future<List<Override>> _baseOverrides() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();

  return [
    sharedPreferencesProvider.overrideWithValue(prefs),
    hobbyRepositoryProvider.overrideWithValue(_StubHobbyRepository()),
    personalToolsRepositoryProvider.overrideWithValue(_StubPersonalToolsRepository()),
    userProgressRepositoryProvider.overrideWithValue(_StubUserProgressRepository()),
    authRepositoryProvider.overrideWithValue(_StubAuthRepository()),
  ];
}

Widget _wrapScreen(Widget screen, List<Override> overrides) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp.router(
      routerConfig: GoRouter(
        routes: [
          GoRoute(path: '/', builder: (_, __) => screen),
          GoRoute(path: '/home', builder: (_, __) => const Scaffold()),
          GoRoute(path: '/hobby/:id', builder: (_, __) => const Scaffold()),
        ],
      ),
    ),
  );
}

// ── Tests ──────────────────────────────────────────────────────────────────

void main() {
  group('OnboardingScreen', () {
    testWidgets('renders without throwing (smoke test)', (tester) async {
      final overrides = await _baseOverrides();
      await tester.pumpWidget(_wrapScreen(const OnboardingScreen(), overrides));
      await tester.pump();
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('has a Scaffold in the widget tree', (tester) async {
      final overrides = await _baseOverrides();
      await tester.pumpWidget(_wrapScreen(const OnboardingScreen(), overrides));
      await tester.pump();
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Continue button is present on first page', (tester) async {
      final overrides = await _baseOverrides();
      await tester.pumpWidget(_wrapScreen(const OnboardingScreen(), overrides));
      await tester.pump();
      // _buildBottomCta shows "Continue  →" on pages 0 and 1.
      expect(find.textContaining('Continue'), findsOneWidget);
    });

    testWidgets('tapping Continue button does not throw', (tester) async {
      final overrides = await _baseOverrides();
      await tester.pumpWidget(_wrapScreen(const OnboardingScreen(), overrides));
      await tester.pump();
      final continueBtn = find.textContaining('Continue');
      expect(continueBtn, findsOneWidget);
      await tester.tap(continueBtn);
      // Let the page animation begin — use pump(duration) to avoid
      // waiting for an infinite animation loop.
      await tester.pump(const Duration(milliseconds: 50));
      // Still no exception = pass.
      expect(find.byType(Scaffold), findsWidgets);
    });
  });
}
