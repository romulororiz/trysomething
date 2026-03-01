import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/features.dart';
import '../models/social.dart';
import '../models/feature_seed_data.dart';
import 'repository_providers.dart';

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
  JournalNotifier() : super(FeatureSeedData.journalEntries);

  void addEntry(JournalEntry entry) {
    state = [entry, ...state];
  }

  void removeEntry(String id) {
    state = state.where((e) => e.id != id).toList();
  }

  List<JournalEntry> entriesForHobby(String hobbyId) {
    return state.where((e) => e.hobbyId == hobbyId).toList();
  }
}

final journalProvider = StateNotifierProvider<JournalNotifier, List<JournalEntry>>(
  (ref) => JournalNotifier(),
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
  ScheduleNotifier() : super(FeatureSeedData.scheduleEvents);

  void addEvent(ScheduleEvent event) {
    state = [...state, event];
  }

  void removeEvent(String id) {
    state = state.where((e) => e.id != id).toList();
  }
}

final scheduleProvider = StateNotifierProvider<ScheduleNotifier, List<ScheduleEvent>>(
  (ref) => ScheduleNotifier(),
);

// ═══════════════════════════════════════════════════════
//  SHOPPING LIST
// ═══════════════════════════════════════════════════════

final shoppingListCheckedProvider = StateProvider<Set<String>>((ref) => {});

// ═══════════════════════════════════════════════════════
//  PERSONAL NOTES (stepId → note text)
// ═══════════════════════════════════════════════════════

class NotesNotifier extends StateNotifier<Map<String, String>> {
  NotesNotifier() : super({});

  void saveNote(String stepId, String text) {
    state = {...state, stepId: text};
  }

  void deleteNote(String stepId) {
    state = Map.from(state)..remove(stepId);
  }
}

final notesProvider = StateNotifierProvider<NotesNotifier, Map<String, String>>(
  (ref) => NotesNotifier(),
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
