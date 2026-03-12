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
import 'package:trysomething/screens/feed/discover_feed_screen.dart';

// ── Minimal stubs ──────────────────────────────────────────────────────────

class _StubHobbyRepository implements HobbyRepository {
  final List<Hobby> _hobbies;

  _StubHobbyRepository({List<Hobby>? hobbies}) : _hobbies = hobbies ?? [];

  @override
  Future<List<Hobby>> getHobbies() async => _hobbies;

  @override
  Future<Hobby?> getHobbyById(String id) async =>
      _hobbies.where((h) => h.id == id).firstOrNull;

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

// ── Helpers ────────────────────────────────────────────────────────────────

Future<List<Override>> _baseOverrides({List<Hobby>? hobbies}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();

  return [
    sharedPreferencesProvider.overrideWithValue(prefs),
    hobbyRepositoryProvider.overrideWithValue(
      _StubHobbyRepository(hobbies: hobbies),
    ),
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
          GoRoute(path: '/hobby/:id', builder: (_, __) => const Scaffold()),
          GoRoute(path: '/search', builder: (_, __) => const Scaffold()),
          GoRoute(
            path: '/rail-feed/:id',
            builder: (_, __) => const Scaffold(),
          ),
        ],
      ),
    ),
  );
}

// ── Tests ──────────────────────────────────────────────────────────────────

void main() {
  group('DiscoverFeedScreen', () {
    testWidgets('renders without throwing (smoke test)', (tester) async {
      final overrides = await _baseOverrides();
      await tester.pumpWidget(_wrapScreen(const DiscoverFeedScreen(), overrides));
      await tester.pump();
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('has a Scaffold in the widget tree', (tester) async {
      final overrides = await _baseOverrides();
      await tester.pumpWidget(_wrapScreen(const DiscoverFeedScreen(), overrides));
      await tester.pump();
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('shows a loading indicator while hobbies are loading', (tester) async {
      final overrides = await _baseOverrides();
      await tester.pumpWidget(_wrapScreen(const DiscoverFeedScreen(), overrides));
      // Before pump() completes async futures, the FutureProvider is loading.
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('search bar placeholder text is visible', (tester) async {
      final overrides = await _baseOverrides();
      await tester.pumpWidget(_wrapScreen(const DiscoverFeedScreen(), overrides));
      await tester.pump();
      // The search bar shows placeholder hint text when not active.
      expect(
        find.textContaining('"cheap creative hobby"'),
        findsOneWidget,
      );
    });

    testWidgets('tapping search bar activates search mode', (tester) async {
      final overrides = await _baseOverrides();
      await tester.pumpWidget(_wrapScreen(const DiscoverFeedScreen(), overrides));
      await tester.pump();
      // Tap the placeholder text to activate search.
      await tester.tap(find.textContaining('"cheap creative hobby"'));
      await tester.pump();
      // Cancel button appears when search is active.
      expect(find.text('Cancel'), findsOneWidget);
    });
  });
}
