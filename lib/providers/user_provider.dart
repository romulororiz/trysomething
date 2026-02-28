import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/hobby.dart';

// ═══════════════════════════════════════════════════════
//  SHARED PREFERENCES PROVIDER
// ═══════════════════════════════════════════════════════

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Must be overridden in main.dart');
});

// ═══════════════════════════════════════════════════════
//  ONBOARDING STATE
// ═══════════════════════════════════════════════════════

final onboardingCompleteProvider = StateNotifierProvider<OnboardingNotifier, bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return OnboardingNotifier(prefs);
});

class OnboardingNotifier extends StateNotifier<bool> {
  final SharedPreferences _prefs;
  static const _key = 'onboarding_complete';

  OnboardingNotifier(this._prefs) : super(_prefs.getBool(_key) ?? false);

  void complete() {
    state = true;
    _prefs.setBool(_key, true);
  }

  void reset() {
    state = false;
    _prefs.setBool(_key, false);
  }
}

// ═══════════════════════════════════════════════════════
//  USER PREFERENCES
// ═══════════════════════════════════════════════════════

final userPreferencesProvider = StateNotifierProvider<UserPreferencesNotifier, UserPreferences>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return UserPreferencesNotifier(prefs);
});

class UserPreferencesNotifier extends StateNotifier<UserPreferences> {
  final SharedPreferences _prefs;
  static const _key = 'user_preferences';

  UserPreferencesNotifier(this._prefs) : super(_load(_prefs));

  static UserPreferences _load(SharedPreferences prefs) {
    final json = prefs.getString(_key);
    if (json == null) return const UserPreferences();
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return UserPreferences(
        hoursPerWeek: map['hoursPerWeek'] as int? ?? 3,
        budgetLevel: map['budgetLevel'] as int? ?? 1,
        preferSocial: map['preferSocial'] as bool? ?? false,
        vibes: (map['vibes'] as List<dynamic>?)?.map((e) => e as String).toSet() ?? {},
      );
    } catch (_) {
      return const UserPreferences();
    }
  }

  void _save() {
    _prefs.setString(_key, jsonEncode({
      'hoursPerWeek': state.hoursPerWeek,
      'budgetLevel': state.budgetLevel,
      'preferSocial': state.preferSocial,
      'vibes': state.vibes.toList(),
    }));
  }

  void setHoursPerWeek(int hours) {
    state = state.copyWith(hoursPerWeek: hours);
    _save();
  }

  void setBudgetLevel(int level) {
    state = state.copyWith(budgetLevel: level);
    _save();
  }

  void setPreferSocial(bool value) {
    state = state.copyWith(preferSocial: value);
    _save();
  }

  void toggleVibe(String vibe) {
    final vibes = Set<String>.from(state.vibes);
    if (vibes.contains(vibe)) {
      vibes.remove(vibe);
    } else {
      vibes.add(vibe);
    }
    state = state.copyWith(vibes: vibes);
    _save();
  }
}

// ═══════════════════════════════════════════════════════
//  USER HOBBIES (Saved / Trying / Active / Done)
// ═══════════════════════════════════════════════════════

final userHobbiesProvider = StateNotifierProvider<UserHobbiesNotifier, Map<String, UserHobby>>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return UserHobbiesNotifier(prefs);
});

class UserHobbiesNotifier extends StateNotifier<Map<String, UserHobby>> {
  final SharedPreferences _prefs;
  static const _key = 'user_hobbies';
  static const _stepsKey = 'completed_steps';

  UserHobbiesNotifier(this._prefs) : super(_load(_prefs));

  static Map<String, UserHobby> _load(SharedPreferences prefs) {
    final json = prefs.getString(_key);
    if (json == null) return {};
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      final stepsJson = prefs.getString(_stepsKey);
      final stepsMap = stepsJson != null ? jsonDecode(stepsJson) as Map<String, dynamic> : <String, dynamic>{};

      return map.map((key, value) {
        final statusIndex = value as int;
        final stepsList = (stepsMap[key] as List<dynamic>?)?.map((e) => e as String).toSet() ?? {};
        return MapEntry(key, UserHobby(
          hobbyId: key,
          status: HobbyStatus.values[statusIndex],
          completedStepIds: stepsList,
        ));
      });
    } catch (_) {
      return {};
    }
  }

  void _save() {
    final statusMap = state.map((key, value) => MapEntry(key, value.status.index));
    final stepsMap = state.map((key, value) => MapEntry(key, value.completedStepIds.toList()));
    _prefs.setString(_key, jsonEncode(statusMap));
    _prefs.setString(_stepsKey, jsonEncode(stepsMap));
  }

  void saveHobby(String hobbyId) {
    if (state.containsKey(hobbyId)) return;
    state = {
      ...state,
      hobbyId: UserHobby(hobbyId: hobbyId, status: HobbyStatus.saved),
    };
    _save();
  }

  void unsaveHobby(String hobbyId) {
    final hobby = state[hobbyId];
    if (hobby == null || hobby.status != HobbyStatus.saved) return;
    state = Map.from(state)..remove(hobbyId);
    _save();
  }

  void toggleSave(String hobbyId) {
    if (state.containsKey(hobbyId) && state[hobbyId]!.status == HobbyStatus.saved) {
      unsaveHobby(hobbyId);
    } else if (!state.containsKey(hobbyId)) {
      saveHobby(hobbyId);
    }
  }

  bool isSaved(String hobbyId) {
    return state.containsKey(hobbyId);
  }

  void startTrying(String hobbyId) {
    final existing = state[hobbyId];
    state = {
      ...state,
      hobbyId: UserHobby(
        hobbyId: hobbyId,
        status: HobbyStatus.trying,
        completedStepIds: existing?.completedStepIds ?? {},
        startedAt: DateTime.now(),
      ),
    };
    _save();
  }

  void setActive(String hobbyId) {
    final existing = state[hobbyId];
    if (existing == null) return;
    state = {
      ...state,
      hobbyId: existing.copyWith(status: HobbyStatus.active),
    };
    _save();
  }

  void setDone(String hobbyId) {
    final existing = state[hobbyId];
    if (existing == null) return;
    state = {
      ...state,
      hobbyId: existing.copyWith(status: HobbyStatus.done),
    };
    _save();
  }

  void toggleStep(String hobbyId, String stepId) {
    final existing = state[hobbyId] ?? UserHobby(hobbyId: hobbyId, status: HobbyStatus.trying);
    final steps = Set<String>.from(existing.completedStepIds);
    if (steps.contains(stepId)) {
      steps.remove(stepId);
    } else {
      steps.add(stepId);
    }
    state = {
      ...state,
      hobbyId: existing.copyWith(completedStepIds: steps),
    };
    _save();
  }

  bool isStepCompleted(String hobbyId, String stepId) {
    return state[hobbyId]?.completedStepIds.contains(stepId) ?? false;
  }

  List<UserHobby> getByStatus(HobbyStatus status) {
    return state.values.where((h) => h.status == status).toList();
  }
}

// ═══════════════════════════════════════════════════════
//  DERIVED PROVIDERS
// ═══════════════════════════════════════════════════════

/// Count of hobbies per status
final hobbyCountByStatusProvider = Provider.family<int, HobbyStatus>((ref, status) {
  return ref.watch(userHobbiesProvider).values.where((h) => h.status == status).length;
});

/// Whether a specific hobby is saved/bookmarked
final isHobbySavedProvider = Provider.family<bool, String>((ref, hobbyId) {
  return ref.watch(userHobbiesProvider).containsKey(hobbyId);
});
