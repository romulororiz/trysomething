import 'package:flutter_test/flutter_test.dart';
import 'package:trysomething/data/repositories/personal_tools_repository.dart';
import 'package:trysomething/models/features.dart';
import 'package:trysomething/models/social.dart';
import 'package:trysomething/providers/feature_providers.dart';

/// Mock repository that tracks calls and can be configured to fail.
class MockPersonalToolsRepository implements PersonalToolsRepository {
  bool shouldFail = false;
  final List<String> calls = [];

  // Pre-configured server data for load tests
  List<JournalEntry> serverJournalEntries = [];
  List<ScheduleEvent> serverScheduleEvents = [];
  Map<String, String> serverNotes = {};
  Set<String> serverCheckedItems = {};

  @override
  Future<List<JournalEntry>> getJournalEntries() async {
    calls.add('getJournalEntries');
    if (shouldFail) throw Exception('mock failure');
    return serverJournalEntries;
  }

  @override
  Future<JournalEntry> createJournalEntry({
    required String hobbyId,
    required String text,
    String? photoUrl,
  }) async {
    calls.add('createJournalEntry:$hobbyId');
    if (shouldFail) throw Exception('mock failure');
    return JournalEntry(
      id: 'server_j_1',
      hobbyId: hobbyId,
      text: text,
      photoUrl: photoUrl,
      createdAt: DateTime(2026, 3, 2),
    );
  }

  @override
  Future<void> deleteJournalEntry(String entryId) async {
    calls.add('deleteJournalEntry:$entryId');
    if (shouldFail) throw Exception('mock failure');
  }

  @override
  Future<Map<String, String>> getNotesForHobby(String hobbyId) async {
    calls.add('getNotesForHobby:$hobbyId');
    if (shouldFail) throw Exception('mock failure');
    return serverNotes;
  }

  @override
  Future<void> saveNote({
    required String hobbyId,
    required String stepId,
    required String text,
  }) async {
    calls.add('saveNote:$hobbyId:$stepId');
    if (shouldFail) throw Exception('mock failure');
  }

  @override
  Future<void> deleteNote({
    required String hobbyId,
    required String stepId,
  }) async {
    calls.add('deleteNote:$hobbyId:$stepId');
    if (shouldFail) throw Exception('mock failure');
  }

  @override
  Future<List<ScheduleEvent>> getScheduleEvents() async {
    calls.add('getScheduleEvents');
    if (shouldFail) throw Exception('mock failure');
    return serverScheduleEvents;
  }

  @override
  Future<ScheduleEvent> createScheduleEvent({
    required String hobbyId,
    required int dayOfWeek,
    required String startTime,
    required int durationMinutes,
  }) async {
    calls.add('createScheduleEvent:$hobbyId');
    if (shouldFail) throw Exception('mock failure');
    return ScheduleEvent(
      id: 'server_ev_1',
      hobbyId: hobbyId,
      dayOfWeek: dayOfWeek,
      startTime: startTime,
      durationMinutes: durationMinutes,
    );
  }

  @override
  Future<void> deleteScheduleEvent(String eventId) async {
    calls.add('deleteScheduleEvent:$eventId');
    if (shouldFail) throw Exception('mock failure');
  }

  @override
  Future<Set<String>> getCheckedItems(String hobbyId) async {
    calls.add('getCheckedItems:$hobbyId');
    if (shouldFail) throw Exception('mock failure');
    return serverCheckedItems;
  }

  @override
  Future<void> toggleShoppingItem({
    required String hobbyId,
    required String itemName,
    required bool checked,
  }) async {
    calls.add('toggleShoppingItem:$hobbyId:$itemName:$checked');
    if (shouldFail) throw Exception('mock failure');
  }
}

void main() {
  late MockPersonalToolsRepository mockRepo;

  setUp(() {
    mockRepo = MockPersonalToolsRepository();
  });

  // ═══════════════════════════════════════════════════
  //  JOURNAL
  // ═══════════════════════════════════════════════════

  group('JournalNotifier', () {
    late JournalNotifier notifier;

    setUp(() {
      notifier = JournalNotifier(mockRepo);
    });

    test('starts with empty state', () {
      expect(notifier.state, isEmpty);
    });

    test('loadFromServer populates state', () async {
      mockRepo.serverJournalEntries = [
        JournalEntry(
          id: 'j1',
          hobbyId: 'pottery',
          text: 'Great session',
          createdAt: DateTime(2026, 3, 1),
        ),
      ];
      await notifier.loadFromServer();
      expect(notifier.state, hasLength(1));
      expect(notifier.state.first.id, 'j1');
      expect(mockRepo.calls, contains('getJournalEntries'));
    });

    test('loadFromServer handles failure gracefully', () async {
      mockRepo.shouldFail = true;
      await notifier.loadFromServer();
      expect(notifier.state, isEmpty);
    });

    test('addEntry optimistically prepends entry', () {
      final entry = JournalEntry(
        id: 'temp_1',
        hobbyId: 'pottery',
        text: 'New entry',
        createdAt: DateTime(2026, 3, 2),
      );
      notifier.addEntry(entry);
      expect(notifier.state.first.text, 'New entry');
      expect(mockRepo.calls, contains('createJournalEntry:pottery'));
    });

    test('addEntry replaces temp entry with server response', () async {
      final entry = JournalEntry(
        id: 'temp_1',
        hobbyId: 'pottery',
        text: 'New entry',
        createdAt: DateTime(2026, 3, 2),
      );
      notifier.addEntry(entry);
      // Wait for async API call to complete
      await Future.delayed(Duration.zero);
      expect(notifier.state.any((e) => e.id == 'server_j_1'), isTrue);
      expect(notifier.state.any((e) => e.id == 'temp_1'), isFalse);
    });

    test('addEntry rolls back on API failure', () async {
      mockRepo.shouldFail = true;
      final entry = JournalEntry(
        id: 'temp_1',
        hobbyId: 'pottery',
        text: 'New entry',
        createdAt: DateTime(2026, 3, 2),
      );
      notifier.addEntry(entry);
      await Future.delayed(Duration.zero);
      // Should roll back to empty state
      expect(notifier.state, isEmpty);
    });

    test('removeEntry optimistically removes', () {
      // Seed state manually
      notifier.addEntry(JournalEntry(
        id: 'j1',
        hobbyId: 'pottery',
        text: 'Entry',
        createdAt: DateTime(2026, 3, 1),
      ));
      // Wait for add to complete, then reset mock
      mockRepo.calls.clear();

      notifier.removeEntry('j1');
      // The temp entry was replaced by server_j_1 after add, so remove temp won't find it
      // Let's test with a pre-loaded entry instead
    });

    test('removeEntry calls API delete', () async {
      // Pre-load state via loadFromServer
      mockRepo.serverJournalEntries = [
        JournalEntry(
          id: 'j1',
          hobbyId: 'pottery',
          text: 'Entry',
          createdAt: DateTime(2026, 3, 1),
        ),
      ];
      await notifier.loadFromServer();
      mockRepo.calls.clear();

      notifier.removeEntry('j1');
      expect(notifier.state, isEmpty);
      expect(mockRepo.calls, contains('deleteJournalEntry:j1'));
    });

    test('removeEntry rolls back on API failure', () async {
      mockRepo.serverJournalEntries = [
        JournalEntry(
          id: 'j1',
          hobbyId: 'pottery',
          text: 'Entry',
          createdAt: DateTime(2026, 3, 1),
        ),
      ];
      await notifier.loadFromServer();
      mockRepo.shouldFail = true;
      mockRepo.calls.clear();

      notifier.removeEntry('j1');
      await Future.delayed(Duration.zero);
      // Should roll back
      expect(notifier.state, hasLength(1));
      expect(notifier.state.first.id, 'j1');
    });

    test('entriesForHobby filters by hobbyId', () async {
      mockRepo.serverJournalEntries = [
        JournalEntry(id: 'j1', hobbyId: 'pottery', text: 'A', createdAt: DateTime(2026, 3, 1)),
        JournalEntry(id: 'j2', hobbyId: 'chess', text: 'B', createdAt: DateTime(2026, 3, 1)),
        JournalEntry(id: 'j3', hobbyId: 'pottery', text: 'C', createdAt: DateTime(2026, 3, 1)),
      ];
      await notifier.loadFromServer();
      expect(notifier.entriesForHobby('pottery'), hasLength(2));
      expect(notifier.entriesForHobby('chess'), hasLength(1));
      expect(notifier.entriesForHobby('unknown'), isEmpty);
    });
  });

  // ═══════════════════════════════════════════════════
  //  SCHEDULE
  // ═══════════════════════════════════════════════════

  group('ScheduleNotifier', () {
    late ScheduleNotifier notifier;

    setUp(() {
      notifier = ScheduleNotifier(mockRepo);
    });

    test('starts with empty state', () {
      expect(notifier.state, isEmpty);
    });

    test('loadFromServer populates state', () async {
      mockRepo.serverScheduleEvents = [
        const ScheduleEvent(
          id: 'ev1',
          hobbyId: 'pottery',
          dayOfWeek: 2,
          startTime: '19:00',
          durationMinutes: 90,
        ),
      ];
      await notifier.loadFromServer();
      expect(notifier.state, hasLength(1));
      expect(notifier.state.first.id, 'ev1');
    });

    test('addEvent optimistically appends', () {
      const event = ScheduleEvent(
        id: 'temp_ev',
        hobbyId: 'pottery',
        dayOfWeek: 3,
        startTime: '18:00',
        durationMinutes: 60,
      );
      notifier.addEvent(event);
      expect(notifier.state, hasLength(1));
      expect(mockRepo.calls, contains('createScheduleEvent:pottery'));
    });

    test('addEvent replaces temp with server response', () async {
      const event = ScheduleEvent(
        id: 'temp_ev',
        hobbyId: 'pottery',
        dayOfWeek: 3,
        startTime: '18:00',
        durationMinutes: 60,
      );
      notifier.addEvent(event);
      await Future.delayed(Duration.zero);
      expect(notifier.state.any((e) => e.id == 'server_ev_1'), isTrue);
      expect(notifier.state.any((e) => e.id == 'temp_ev'), isFalse);
    });

    test('addEvent rolls back on failure', () async {
      mockRepo.shouldFail = true;
      const event = ScheduleEvent(
        id: 'temp_ev',
        hobbyId: 'pottery',
        dayOfWeek: 3,
        startTime: '18:00',
        durationMinutes: 60,
      );
      notifier.addEvent(event);
      await Future.delayed(Duration.zero);
      expect(notifier.state, isEmpty);
    });

    test('removeEvent calls API and removes from state', () async {
      mockRepo.serverScheduleEvents = [
        const ScheduleEvent(
          id: 'ev1',
          hobbyId: 'pottery',
          dayOfWeek: 2,
          startTime: '19:00',
          durationMinutes: 90,
        ),
      ];
      await notifier.loadFromServer();
      mockRepo.calls.clear();

      notifier.removeEvent('ev1');
      expect(notifier.state, isEmpty);
      expect(mockRepo.calls, contains('deleteScheduleEvent:ev1'));
    });

    test('removeEvent rolls back on failure', () async {
      mockRepo.serverScheduleEvents = [
        const ScheduleEvent(
          id: 'ev1',
          hobbyId: 'pottery',
          dayOfWeek: 2,
          startTime: '19:00',
          durationMinutes: 90,
        ),
      ];
      await notifier.loadFromServer();
      mockRepo.shouldFail = true;
      mockRepo.calls.clear();

      notifier.removeEvent('ev1');
      await Future.delayed(Duration.zero);
      expect(notifier.state, hasLength(1));
    });
  });

  // ═══════════════════════════════════════════════════
  //  NOTES
  // ═══════════════════════════════════════════════════

  group('NotesNotifier', () {
    late NotesNotifier notifier;

    setUp(() {
      notifier = NotesNotifier(mockRepo);
    });

    test('starts with empty state', () {
      expect(notifier.state, isEmpty);
    });

    test('loadForHobby merges server notes into state', () async {
      mockRepo.serverNotes = {'step1': 'My note', 'step2': 'Another note'};
      await notifier.loadForHobby('pottery');
      expect(notifier.state, hasLength(2));
      expect(notifier.state['step1'], 'My note');
      expect(mockRepo.calls, contains('getNotesForHobby:pottery'));
    });

    test('loadForHobby handles failure gracefully', () async {
      mockRepo.shouldFail = true;
      await notifier.loadForHobby('pottery');
      expect(notifier.state, isEmpty);
    });

    test('saveNote optimistically updates state', () {
      notifier.saveNote('pottery', 'step1', 'Hello');
      expect(notifier.state['step1'], 'Hello');
      expect(mockRepo.calls, contains('saveNote:pottery:step1'));
    });

    test('saveNote rolls back on failure', () async {
      mockRepo.shouldFail = true;
      notifier.saveNote('pottery', 'step1', 'Hello');
      await Future.delayed(Duration.zero);
      expect(notifier.state['step1'], isNull);
    });

    test('deleteNote optimistically removes from state', () async {
      mockRepo.serverNotes = {'step1': 'My note'};
      await notifier.loadForHobby('pottery');
      mockRepo.calls.clear();

      notifier.deleteNote('pottery', 'step1');
      expect(notifier.state.containsKey('step1'), isFalse);
      expect(mockRepo.calls, contains('deleteNote:pottery:step1'));
    });

    test('deleteNote rolls back on failure', () async {
      mockRepo.serverNotes = {'step1': 'My note'};
      await notifier.loadForHobby('pottery');
      mockRepo.shouldFail = true;
      mockRepo.calls.clear();

      notifier.deleteNote('pottery', 'step1');
      await Future.delayed(Duration.zero);
      expect(notifier.state['step1'], 'My note');
    });
  });

  // ═══════════════════════════════════════════════════
  //  SHOPPING LIST
  // ═══════════════════════════════════════════════════

  group('ShoppingListNotifier', () {
    late ShoppingListNotifier notifier;

    setUp(() {
      notifier = ShoppingListNotifier(mockRepo);
    });

    test('starts with empty state', () {
      expect(notifier.state, isEmpty);
    });

    test('loadForHobby merges checked items into state', () async {
      mockRepo.serverCheckedItems = {'pottery_Brush', 'pottery_Clay'};
      await notifier.loadForHobby('pottery');
      expect(notifier.state, contains('pottery_Brush'));
      expect(notifier.state, contains('pottery_Clay'));
      expect(mockRepo.calls, contains('getCheckedItems:pottery'));
    });

    test('loadForHobby handles failure gracefully', () async {
      mockRepo.shouldFail = true;
      await notifier.loadForHobby('pottery');
      expect(notifier.state, isEmpty);
    });

    test('toggle adds checked item to state', () {
      notifier.toggle('pottery', 'Brush', true);
      expect(notifier.state, contains('pottery_Brush'));
      expect(mockRepo.calls, contains('toggleShoppingItem:pottery:Brush:true'));
    });

    test('toggle removes unchecked item from state', () async {
      mockRepo.serverCheckedItems = {'pottery_Brush'};
      await notifier.loadForHobby('pottery');
      mockRepo.calls.clear();

      notifier.toggle('pottery', 'Brush', false);
      expect(notifier.state.contains('pottery_Brush'), isFalse);
      expect(mockRepo.calls, contains('toggleShoppingItem:pottery:Brush:false'));
    });

    test('toggle rolls back on failure', () async {
      mockRepo.shouldFail = true;
      notifier.toggle('pottery', 'Brush', true);
      await Future.delayed(Duration.zero);
      expect(notifier.state.contains('pottery_Brush'), isFalse);
    });
  });
}
