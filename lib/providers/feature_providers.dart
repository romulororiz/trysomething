import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/gamification_repository.dart';
import '../data/repositories/personal_tools_repository.dart';
import '../data/repositories/social_repository.dart';
import '../models/activity_log.dart';
import '../models/auth.dart';
import '../models/features.dart';
import '../models/gamification.dart';
import '../models/social.dart';
import 'auth_provider.dart';
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

// ═══════════════════════════════════════════════════════
//  USER PROFILE
// ═══════════════════════════════════════════════════════

class ProfileNotifier extends StateNotifier<UserProfile> {
  final AuthRepository _repo;
  ProfileNotifier(this._repo) : super(const UserProfile());

  void initFromAuth(AuthUser user) {
    state = UserProfile(
      username: user.displayName,
      bio: user.bio,
      avatarUrl: user.avatarUrl,
    );
  }

  void updateUsername(String name) {
    state = state.copyWith(username: name);
    _syncToServer(displayName: name);
  }

  void updateBio(String bio) {
    state = state.copyWith(bio: bio);
    _syncToServer(bio: bio);
  }

  void updateAvatar(String? url) {
    state = state.copyWith(avatarUrl: url);
    if (url != null) _syncToServer(avatarUrl: url);
  }

  void _syncToServer({String? displayName, String? bio, String? avatarUrl}) {
    _repo
        .updateProfile(
            displayName: displayName, bio: bio, avatarUrl: avatarUrl)
        .then((_) {})
        .catchError((e) {
      debugPrint('[Profile] Failed to sync: $e');
    });
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, UserProfile>(
  (ref) => ProfileNotifier(ref.watch(authRepositoryProvider)),
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

class ChallengeNotifier extends StateNotifier<List<Challenge>> {
  final GamificationRepository _repo;
  ChallengeNotifier(this._repo) : super([]);

  Future<void> loadFromServer() async {
    try {
      state = await _repo.getChallenges();
    } catch (e) {
      debugPrint('[Challenges] Failed to load from server: $e');
    }
  }
}

final challengeProvider =
    StateNotifierProvider<ChallengeNotifier, List<Challenge>>(
  (ref) => ChallengeNotifier(ref.watch(gamificationRepositoryProvider)),
);

final currentChallengeProvider = Provider<Challenge?>((ref) {
  final challenges = ref.watch(challengeProvider);
  try {
    return challenges.firstWhere((c) => !c.isCompleted);
  } catch (_) {
    return null;
  }
});

// ═══════════════════════════════════════════════════════
//  ACHIEVEMENTS
// ═══════════════════════════════════════════════════════

class AchievementsNotifier extends StateNotifier<List<Achievement>> {
  final GamificationRepository _repo;
  AchievementsNotifier(this._repo) : super([]);

  Future<void> loadFromServer() async {
    try {
      state = await _repo.getAchievements();
    } catch (e) {
      debugPrint('[Achievements] Failed to load from server: $e');
    }
  }
}

final achievementsProvider =
    StateNotifierProvider<AchievementsNotifier, List<Achievement>>(
  (ref) => AchievementsNotifier(ref.watch(gamificationRepositoryProvider)),
);

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

class BuddyState {
  final List<BuddyProfile> profiles;
  final List<BuddyActivity> activities;
  final List<BuddyRequest> pendingRequests;
  const BuddyState({
    this.profiles = const [],
    this.activities = const [],
    this.pendingRequests = const [],
  });
  BuddyState copyWith({
    List<BuddyProfile>? profiles,
    List<BuddyActivity>? activities,
    List<BuddyRequest>? pendingRequests,
  }) =>
      BuddyState(
        profiles: profiles ?? this.profiles,
        activities: activities ?? this.activities,
        pendingRequests: pendingRequests ?? this.pendingRequests,
      );
}

class BuddyNotifier extends StateNotifier<BuddyState> {
  final SocialRepository _repo;
  BuddyNotifier(this._repo) : super(const BuddyState());

  Future<void> loadFromServer() async {
    try {
      final data = await _repo.getBuddiesWithActivity();
      final profiles = (data['profiles'] as List<dynamic>)
          .map((e) => BuddyProfile.fromJson(e as Map<String, dynamic>))
          .toList();
      final activities = (data['activities'] as List<dynamic>)
          .map((e) => BuddyActivity.fromJson(e as Map<String, dynamic>))
          .toList();
      final requests = await _repo.getBuddyRequests();
      state = BuddyState(
        profiles: profiles,
        activities: activities,
        pendingRequests: requests,
      );
    } catch (e) {
      debugPrint('[Buddy] Failed to load from server: $e');
    }
  }

  Future<void> sendRequest(String targetUserId, {String? hobbyId}) async {
    try {
      final request = await _repo.sendBuddyRequest(
        targetUserId: targetUserId,
        hobbyId: hobbyId,
      );
      state = state.copyWith(
        pendingRequests: [...state.pendingRequests, request],
      );
    } catch (e) {
      debugPrint('[Buddy] Failed to send request: $e');
    }
  }

  Future<void> acceptRequest(String requestId) async {
    try {
      await _repo.respondToRequest(requestId: requestId, status: 'active');
      await loadFromServer();
    } catch (e) {
      debugPrint('[Buddy] Failed to accept request: $e');
    }
  }

  void rejectRequest(String requestId) {
    final snapshot = state;
    state = state.copyWith(
      pendingRequests:
          state.pendingRequests.where((r) => r.id != requestId).toList(),
    );
    _repo
        .respondToRequest(requestId: requestId, status: 'rejected')
        .catchError((e) {
      debugPrint('[Buddy] Reject failed, rolling back: $e');
      state = snapshot;
    });
  }

  void cancelRequest(String requestId) {
    final snapshot = state;
    state = state.copyWith(
      pendingRequests:
          state.pendingRequests.where((r) => r.id != requestId).toList(),
    );
    _repo.cancelRequest(requestId).catchError((e) {
      debugPrint('[Buddy] Cancel failed, rolling back: $e');
      state = snapshot;
    });
  }

  bool hasRequestFor(String userId) {
    return state.pendingRequests.any((r) => r.userId == userId);
  }
}

final buddyProvider = StateNotifierProvider<BuddyNotifier, BuddyState>(
  (ref) => BuddyNotifier(ref.watch(socialRepositoryProvider)),
);

// ═══════════════════════════════════════════════════════
//  COMMUNITY STORIES
// ═══════════════════════════════════════════════════════

class StoriesNotifier extends StateNotifier<List<CommunityStory>> {
  final SocialRepository _repo;
  StoriesNotifier(this._repo) : super([]);

  void _apiCall(
    List<CommunityStory> snapshot,
    Future<void> Function() call,
  ) {
    call().catchError((e) {
      debugPrint('[Stories] API call failed, rolling back: $e');
      state = snapshot;
    });
  }

  Future<void> loadFromServer() async {
    try {
      state = await _repo.getStories();
    } catch (e) {
      debugPrint('[Stories] Failed to load from server: $e');
    }
  }

  void createStory(String quote, String hobbyId) {
    final snapshot = List<CommunityStory>.from(state);
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final temp = CommunityStory(
      id: tempId,
      authorName: '',
      authorInitial: '',
      quote: quote,
      hobbyId: hobbyId,
    );
    state = [temp, ...state];
    _apiCall(snapshot, () async {
      final created = await _repo.createStory(quote: quote, hobbyId: hobbyId);
      state = [created, ...state.where((s) => s.id != tempId).toList()];
    });
  }

  void deleteStory(String storyId) {
    final snapshot = List<CommunityStory>.from(state);
    state = state.where((s) => s.id != storyId).toList();
    _apiCall(snapshot, () => _repo.deleteStory(storyId));
  }

  void toggleReaction(String storyId, String type) {
    final snapshot = List<CommunityStory>.from(state);
    final idx = state.indexWhere((s) => s.id == storyId);
    if (idx == -1) return;

    final story = state[idx];
    final hasReacted = story.userReactions.contains(type);
    final newReactions = Map<String, int>.from(story.reactions);
    final newUserReactions = List<String>.from(story.userReactions);

    if (hasReacted) {
      newUserReactions.remove(type);
      newReactions[type] = (newReactions[type] ?? 1) - 1;
    } else {
      newUserReactions.add(type);
      newReactions[type] = (newReactions[type] ?? 0) + 1;
    }

    final updated = story.copyWith(
      reactions: newReactions,
      userReactions: newUserReactions,
    );
    state = [...state.sublist(0, idx), updated, ...state.sublist(idx + 1)];

    _apiCall(snapshot, () async {
      if (hasReacted) {
        await _repo.removeReaction(storyId: storyId, type: type);
      } else {
        await _repo.addReaction(storyId: storyId, type: type);
      }
    });
  }
}

final storiesProvider =
    StateNotifierProvider<StoriesNotifier, List<CommunityStory>>(
  (ref) => StoriesNotifier(ref.watch(socialRepositoryProvider)),
);

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
