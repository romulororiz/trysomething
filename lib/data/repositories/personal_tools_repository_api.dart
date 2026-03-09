import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_constants.dart';
import '../../models/features.dart';
import '../../models/social.dart';
import 'personal_tools_repository.dart';

/// API-backed personal tools repository.
class PersonalToolsRepositoryApi implements PersonalToolsRepository {
  final Dio _dio = ApiClient.instance;

  // ── Journal ──────────────────────────────────

  @override
  Future<List<JournalEntry>> getJournalEntries() async {
    final response = await _dio.get(ApiConstants.usersJournal);
    final list = response.data as List<dynamic>;
    return list
        .map((e) => JournalEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<JournalEntry> createJournalEntry({
    String? hobbyId,
    required String text,
    String? photoUrl,
  }) async {
    final response = await _dio.post(
      ApiConstants.usersJournal,
      data: {
        if (hobbyId != null) 'hobbyId': hobbyId,
        'text': text,
        if (photoUrl != null) 'photoUrl': photoUrl,
      },
    );
    return JournalEntry.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteJournalEntry(String entryId) async {
    await _dio.delete(ApiConstants.usersJournalEntry(entryId));
  }

  // ── Notes ────────────────────────────────────

  @override
  Future<Map<String, String>> getNotesForHobby(String hobbyId) async {
    final response = await _dio.get(ApiConstants.usersNotes(hobbyId));
    final list = response.data as List<dynamic>;
    final result = <String, String>{};
    for (final item in list) {
      final map = item as Map<String, dynamic>;
      result[map['stepId'] as String] = map['text'] as String;
    }
    return result;
  }

  @override
  Future<void> saveNote({
    required String hobbyId,
    required String stepId,
    required String text,
  }) async {
    await _dio.put(
      ApiConstants.usersNotes(hobbyId),
      data: {'stepId': stepId, 'text': text},
    );
  }

  @override
  Future<void> deleteNote({
    required String hobbyId,
    required String stepId,
  }) async {
    await _dio.delete(ApiConstants.usersNoteStep(hobbyId, stepId));
  }

  // ── Schedule ─────────────────────────────────

  @override
  Future<List<ScheduleEvent>> getScheduleEvents() async {
    final response = await _dio.get(ApiConstants.usersSchedule);
    final list = response.data as List<dynamic>;
    return list
        .map((e) => ScheduleEvent.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ScheduleEvent> createScheduleEvent({
    required String hobbyId,
    required int dayOfWeek,
    required String startTime,
    required int durationMinutes,
  }) async {
    final response = await _dio.post(
      ApiConstants.usersSchedule,
      data: {
        'hobbyId': hobbyId,
        'dayOfWeek': dayOfWeek,
        'startTime': startTime,
        'durationMinutes': durationMinutes,
      },
    );
    return ScheduleEvent.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteScheduleEvent(String eventId) async {
    await _dio.delete(ApiConstants.usersScheduleEvent(eventId));
  }

  // ── Shopping ─────────────────────────────────

  @override
  Future<Set<String>> getCheckedItems(String hobbyId) async {
    final response = await _dio.get(ApiConstants.usersShopping(hobbyId));
    final list = response.data as List<dynamic>;
    final result = <String>{};
    for (final item in list) {
      final map = item as Map<String, dynamic>;
      if (map['checked'] == true) {
        result.add('${hobbyId}_${map['itemName']}');
      }
    }
    return result;
  }

  @override
  Future<void> toggleShoppingItem({
    required String hobbyId,
    required String itemName,
    required bool checked,
  }) async {
    await _dio.put(
      ApiConstants.usersShopping(hobbyId),
      data: {'itemName': itemName, 'checked': checked},
    );
  }
}
