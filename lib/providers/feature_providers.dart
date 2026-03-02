import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/personal_tools_repository.dart';
import '../models/activity_log.dart';
import '../models/features.dart';
import '../models/social.dart';
import '../models/feature_seed_data.dart';
import 'repository_providers.dart';
import 'user_provider.dart';

// ═══════════════════════════════════════════════════════
//  FEATURE DATA PROVIDERS (via FeatureRepository)
// ═══════════════════════════════════════════════════════

final faqProvider = FutureProvider.family<List<FaqItem>, String>((ref, hobbyId) {
  return ref.watch(featureRepositoryProvider).getFaqForHobby(hobbyId);
});

final costBreakdownProvider = FutureProvider.family<CostBreakdown?, String>((ref, hobbyId) {
  return ref.watch(featureRepositoryProvider).getCostBreakdown(hobbyId);
});

final budgetAlternativesProvider = FutureProvider.family<List<BudgetAlternative>, String>((ref, hobbyId) {
  return ref.watch(featureRepositoryProvider).getBudgetAlternatives(hobbyId);
});

final seasonalHobbiesProvider = FutureProvider<Map<String, List<String>>>((ref) {
  return ref.watch(featureRepositoryProvider).getSeasonalHobbies();
});

final moodTagsProvider = FutureProvider<Map<String, List<String>>>((ref) {
  return ref.watch(featureRepositoryProvider).getMoodTags();
});

// ═══════════════════════════════════════════════════════
//  USER PROFILE
// ═══════════════════════════════════════════════════════

class ProfileNotifier extends StateNotifier<UserProfile> {
  ProfileNotifier() : super(const UserProfile());

  void updateUsername(String name) => state = state.copyWith(username: name);
  void updateBio(String bio) => state = state.copyWith(bio: bio);
  void updateAvatar(String? url) => state = state.copyWith(avatarUrl: url);
}

final profileProvider = StateNotifierProvider<ProfileNotifier, UserProfile>(
  (ref) => ProfileNotifier(),
);

// ═══════════════════════════════════════════════════════
//  JOURNAL
// ═══════════════════════════════════════════════════════

class JournalNotifier extends StateNotifier<List<JournalEntry>> {
  final PersonalToolsRepository _repo;
  JournalNotifier(this._repo) : super([]);

  void _apiCall(
    List<JournalEntry> snapshot,
    Future<void> Function() call,
  ) {
    call().catchError((e) {
      debugPrint('[Journal] API call failed, rolling back: $e');
      state = snapshot;
    });
  }

  Future<void> loadFromServer() async {
    try {
      state = await _repo.getJournalEntries();
    } catch (e) {
      debugPrint('[Journal] Failed to load from server: $e');
    }
  }

  void addEntry(JournalEntry entry) {
    final snapshot = List<JournalEntry>.from(state);
    state = [entry, ...state];
    _apiCall(snapshot, () async {
      final created = await _repo.createJournalEntry(
        hobbyId: entry.hobbyId,
        text: entry.text,
        photoUrl: entry.photoUrl,
      );
      // Replace temp entry with server response (has real ID)
      state = [created, ...state.where((e) => e.id != entry.id).toList()];
    });
  }

  void removeEntry(String id) {
    final snapshot = List<JournalEntry>.from(state);
    state = state.where((e) => e.id != id).toList();
    _apiCall(snapshot, () => _repo.deleteJournalEntry(id));
  }

  List<JournalEntry> entriesForHobby(String hobbyId) {
    return state.where((e) => e.hobbyId == hobbyId).toList();
  }
}

final journalProvider = StateNotifierProvider<JournalNotifier, List<JournalEntry>>(
  (ref) => JournalNotifier(ref.watch(personalToolsRepositoryProvider)),
);

// ═══════════════════════════════════════════════════════
//  CHALLENGES
// ═══════════════════════════════════════════════════════

final challengeProvider = Provider<List<Challenge>>((ref) {
  return FeatureSeedData.challenges;
});

final currentChallengeProvider = Provider<Challenge?>((ref) {
  final challenges = ref.watch(challengeProvider);
  try {
    return challenges.firstWhere((c) => !c.isCompleted);
  } catch (_) {
    return null;
  }
});

// ═══════════════════════════════════════════════════════
//  SCHEDULE
// ═══════════════════════════════════════════════════════

class ScheduleNotifier extends StateNotifier<List<ScheduleEvent>> {
  final PersonalToolsRepository _repo;
  ScheduleNotifier(this._repo) : super([]);

  void _apiCall(
    List<ScheduleEvent> snapshot,
    Future<void> Function() call,
  ) {
    call().catchError((e) {
      debugPrint('[Schedule] API call failed, rolling back: $e');
      state = snapshot;
    });
  }

  Future<void> loadFromServer() async {
    try {
      state = await _repo.getScheduleEvents();
    } catch (e) {
      debugPrint('[Schedule] Failed to load from server: $e');
    }
  }

  void addEvent(ScheduleEvent event) {
    final snapshot = List<ScheduleEvent>.from(state);
    state = [...state, event];
    _apiCall(snapshot, () async {
      final created = await _repo.createScheduleEvent(
        hobbyId: event.hobbyId,
        dayOfWeek: event.dayOfWeek,
        startTime: event.startTime,
        durationMinutes: event.durationMinutes,
      );
      // Replace temp event with server response (has real ID)
      state = [...state.where((e) => e.id != event.id), created];
    });
  }

  void removeEvent(String id) {
    final snapshot = List<ScheduleEvent>.from(state);
    state = state.where((e) => e.id != id).toList();
    _apiCall(snapshot, () => _repo.deleteScheduleEvent(id));
  }
}

final scheduleProvider = StateNotifierProvider<ScheduleNotifier, List<ScheduleEvent>>(
  (ref) => ScheduleNotifier(ref.watch(personalToolsRepositoryProvider)),
);

// ═══════════════════════════════════════════════════════
//  SHOPPING LIST
// ═══════════════════════════════════════════════════════

class ShoppingListNotifier extends StateNotifier<Set<String>> {
  final PersonalToolsRepository _repo;
  ShoppingListNotifier(this._repo) : super({});

  void _apiCall(
    Set<String> snapshot,
    Future<void> Function() call,
  ) {
    call().catchError((e) {
      debugPrint('[Shopping] API call failed, rolling back: $e');
      state = snapshot;
    });
  }

  Future<void> loadForHobby(String hobbyId) async {
    try {
      final items = await _repo.getCheckedItems(hobbyId);
      state = {...state, ...items};
    } catch (e) {
      debugPrint('[Shopping] Failed to load for hobby $hobbyId: $e');
    }
  }

  void toggle(String hobbyId, String itemName, bool checked) {
    final key = '${hobbyId}_$itemName';
    final snapshot = Set<String>.from(state);
    if (checked) {
      state = {...state, key};
    } else {
      state = Set.from(state)..remove(key);
    }
    _apiCall(snapshot, () => _repo.toggleShoppingItem(
      hobbyId: hobbyId,
      itemName: itemName,
      checked: checked,
    ));
  }
}

final shoppingListCheckedProvider =
    StateNotifierProvider<ShoppingListNotifier, Set<String>>(
  (ref) => ShoppingListNotifier(ref.watch(personalToolsRepositoryProvider)),
);

// ═══════════════════════════════════════════════════════
//  PERSONAL NOTES (stepId → note text)
// ═══════════════════════════════════════════════════════

class NotesNotifier extends StateNotifier<Map<String, String>> {
  final PersonalToolsRepository _repo;
  NotesNotifier(this._repo) : super({});

  void _apiCall(
    Map<String, String> snapshot,
    Future<void> Function() call,
  ) {
    call().catchError((e) {
      debugPrint('[Notes] API call failed, rolling back: $e');
      state = snapshot;
    });
  }

  Future<void> loadForHobby(String hobbyId) async {
    try {
      final notes = await _repo.getNotesForHobby(hobbyId);
      state = {...state, ...notes};
    } catch (e) {
      debugPrint('[Notes] Failed to load for hobby $hobbyId: $e');
    }
  }

  void saveNote(String hobbyId, String stepId, String text) {
    final snapshot = Map<String, String>.from(state);
    state = {...state, stepId: text};
    _apiCall(snapshot, () => _repo.saveNote(
      hobbyId: hobbyId,
      stepId: stepId,
      text: text,
    ));
  }

  void deleteNote(String hobbyId, String stepId) {
    final snapshot = Map<String, String>.from(state);
    state = Map.from(state)..remove(stepId);
    _apiCall(snapshot, () => _repo.deleteNote(
      hobbyId: hobbyId,
      stepId: stepId,
    ));
  }
}

final notesProvider = StateNotifierProvider<NotesNotifier, Map<String, String>>(
  (ref) => NotesNotifier(ref.watch(personalToolsRepositoryProvider)),
);

// ═══════════════════════════════════════════════════════
//  COMPARE MODE (selected hobby IDs)
// ═══════════════════════════════════════════════════════

final selectedCompareProvider = StateProvider<List<String>>((ref) => []);

// ═══════════════════════════════════════════════════════
//  BUDDY MODE
// ═══════════════════════════════════════════════════════

final buddyProfilesProvider = Provider<List<BuddyProfile>>((ref) {
  return FeatureSeedData.buddyProfiles;
});

final buddyActivitiesProvider = Provider<List<BuddyActivity>>((ref) {
  return FeatureSeedData.buddyActivities;
});

// ═══════════════════════════════════════════════════════
//  COMMUNITY STORIES
// ═══════════════════════════════════════════════════════

final storiesProvider = Provider<List<CommunityStory>>((ref) {
  return FeatureSeedData.stories;
});

// ═══════════════════════════════════════════════════════
//  NEARBY USERS
// ═══════════════════════════════════════════════════════

final nearbyUsersProvider = Provider<List<NearbyUser>>((ref) {
  return FeatureSeedData.nearbyUsers;
});

// ═══════════════════════════════════════════════════════
//  HOBBY COMBOS
// ═══════════════════════════════════════════════════════

final combosProvider = FutureProvider<List<HobbyCombo>>((ref) {
  return ref.watch(featureRepositoryProvider).getCombos();
});

// ═══════════════════════════════════════════════════════
//  ACTIVITY LOG (for profile heatmap)
// ═══════════════════════════════════════════════════════

/// Fetches activity log entries from the server (last 112 days for heatmap).
final activityLogProvider = FutureProvider<List<ActivityLogEntry>>((ref) async {
  final repo = ref.watch(userProgressRepositoryProvider);
  final raw = await repo.getActivityLog(days: 112);
  return raw.map((e) => ActivityLogEntry.fromJson(e)).toList();
});

/// Converts activity log entries into heatmap data: Map<DateTime, int>
/// where value is activity level (0=none, 1=light, 2=medium, 3=heavy).
final activityHeatmapProvider = Provider<Map<DateTime, int>>((ref) {
  final logAsync = ref.watch(activityLogProvider);
  return logAsync.when(
    data: (entries) {
      final counts = <DateTime, int>{};
      for (final entry in entries) {
        final day = DateTime(
          entry.createdAt.year,
          entry.createdAt.month,
          entry.createdAt.day,
        );
        counts[day] = (counts[day] ?? 0) + 1;
      }
      // Convert raw counts to levels: 0=none, 1=1 action, 2=2-3, 3=4+
      final result = <DateTime, int>{};
      for (final entry in counts.entries) {
        final count = entry.value;
        if (count == 0) {
          result[entry.key] = 0;
        } else if (count == 1) {
          result[entry.key] = 1;
        } else if (count <= 3) {
          result[entry.key] = 2;
        } else {
          result[entry.key] = 3;
        }
      }
      return result;
    },
    loading: () => <DateTime, int>{},
    error: (_, __) => <DateTime, int>{},
  );
});
