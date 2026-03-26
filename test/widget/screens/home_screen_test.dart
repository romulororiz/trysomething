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
import 'package:trysomething/models/curated_pack.dart';
import 'package:trysomething/models/features.dart';
import 'package:trysomething/models/social.dart';
import 'package:trysomething/screens/home/home_screen.dart';

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
    DateTime? pausedAt,
    int? pausedDurationDays,
    DateTime? lastActivityAt,
  }) async =>
      _stub;

  @override
  Future<(UserHobby, bool)> toggleStep(String hobbyId, String stepId) async => (_stub, false);

  @override
  Future<List<UserHobby>> syncHobbies(List<UserHobby> hobbies) async => hobbies;

  @override
  Future<List<Map<String, dynamic>>> getActivityLog({int days = 365}) async => [];
}

// ── Helpers ────────────────────────────────────────────────────────────────

Future<List<Override>> _baseOverrides({String? hobbiesJson}) async {
  SharedPreferences.setMockInitialValues(
    hobbiesJson != null ? {'user_hobbies': hobbiesJson} : {},
  );
  final prefs = await SharedPreferences.getInstance();

  return [
    sharedPreferencesProvider.overrideWithValue(prefs),
    hobbyRepositoryProvider.overrideWithValue(_StubHobbyRepository()),
    personalToolsRepositoryProvider.overrideWithValue(_StubPersonalToolsRepository()),
    userProgressRepositoryProvider.overrideWithValue(_StubUserProgressRepository()),
  ];
}

Widget _wrapScreen(Widget screen, List<Override> overrides) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp.router(
      routerConfig: GoRouter(
        routes: [
          GoRoute(path: '/', builder: (_, __) => screen),
          GoRoute(path: '/discover', builder: (_, __) => const Scaffold()),
          GoRoute(path: '/hobby/:id', builder: (_, __) => const Scaffold()),
          GoRoute(path: '/journal', builder: (_, __) => const Scaffold()),
          GoRoute(path: '/coach/:id', builder: (_, __) => const Scaffold()),
          GoRoute(
            path: '/session/:hobbyId/:stepId',
            builder: (_, __) => const Scaffold(),
          ),
        ],
      ),
    ),
  );
}

// ── Tests ──────────────────────────────────────────────────────────────────

void main() {
  group('HomeScreen', () {
    testWidgets('renders without throwing (smoke test)', (tester) async {
      final overrides = await _baseOverrides();
      await tester.pumpWidget(_wrapScreen(const HomeScreen(), overrides));
      await tester.pump();
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('has a Scaffold in the widget tree', (tester) async {
      final overrides = await _baseOverrides();
      await tester.pumpWidget(_wrapScreen(const HomeScreen(), overrides));
      await tester.pump();
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('empty state — shows Discover hobbies button', (tester) async {
      final overrides = await _baseOverrides();
      await tester.pumpWidget(_wrapScreen(const HomeScreen(), overrides));
      await tester.pump();
      // _EmptyHomeState renders this CTA when no active hobby exists.
      expect(find.text('Discover hobbies'), findsOneWidget);
    });

    testWidgets('empty state — Discover hobbies button is tappable without error',
        (tester) async {
      final overrides = await _baseOverrides();
      await tester.pumpWidget(_wrapScreen(const HomeScreen(), overrides));
      await tester.pump();
      await tester.tap(find.text('Discover hobbies'));
      await tester.pump();
      // No exception after tap = pass.
    });

    testWidgets('with an active hobby entry — renders without throwing', (tester) async {
      // Stub returns null for getHobbyById, so the screen will show a loading
      // or "Hobby not found" path — both are valid, no crash expected.
      const hobbiesJson =
          '{"knitting":{"hobbyId":"knitting","status":"trying","completedStepIds":[]}}';
      final overrides = await _baseOverrides(hobbiesJson: hobbiesJson);
      await tester.pumpWidget(_wrapScreen(const HomeScreen(), overrides));
      await tester.pump();
      expect(find.byType(Scaffold), findsWidgets);
      // Drain any pending async timers triggered by the active-hobby load path.
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('HomeScreen(initialHobbyId: null) does not throw', (tester) async {
      final overrides = await _baseOverrides();
      await tester.pumpWidget(
        _wrapScreen(const HomeScreen(initialHobbyId: null), overrides),
      );
      await tester.pump();
      expect(find.byType(Scaffold), findsWidgets);
    });
  });
}
