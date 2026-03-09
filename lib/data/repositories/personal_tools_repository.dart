import '../../models/features.dart';
import '../../models/social.dart';

/// Abstract interface for personal tools operations.
abstract class PersonalToolsRepository {
  // ── Journal ──
  Future<List<JournalEntry>> getJournalEntries();
  Future<JournalEntry> createJournalEntry({
    String? hobbyId,
    required String text,
    String? photoUrl,
  });
  Future<void> deleteJournalEntry(String entryId);

  // ── Notes ──
  Future<Map<String, String>> getNotesForHobby(String hobbyId);
  Future<void> saveNote({
    required String hobbyId,
    required String stepId,
    required String text,
  });
  Future<void> deleteNote({
    required String hobbyId,
    required String stepId,
  });

  // ── Schedule ──
  Future<List<ScheduleEvent>> getScheduleEvents();
  Future<ScheduleEvent> createScheduleEvent({
    required String hobbyId,
    required int dayOfWeek,
    required String startTime,
    required int durationMinutes,
  });
  Future<void> deleteScheduleEvent(String eventId);

  // ── Shopping ──
  Future<Set<String>> getCheckedItems(String hobbyId);
  Future<void> toggleShoppingItem({
    required String hobbyId,
    required String itemName,
    required bool checked,
  });
}
