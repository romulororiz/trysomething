import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/analytics/analytics_provider.dart';
import '../core/analytics/analytics_service.dart';
import '../data/repositories/user_progress_repository.dart';
import 'subscription_provider.dart';
import '../data/repositories/user_progress_repository_api.dart';
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
      return UserPreferences.fromJson(
        jsonDecode(json) as Map<String, dynamic>,
      );
    } catch (_) {
      return const UserPreferences();
    }
  }

  void _save() {
    _prefs.setString(_key, jsonEncode(state.toJson()));
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

final userProgressRepositoryProvider = Provider<UserProgressRepository>((ref) {
  return UserProgressRepositoryApi();
});

final userHobbiesProvider = StateNotifierProvider<UserHobbiesNotifier, Map<String, UserHobby>>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final repo = ref.watch(userProgressRepositoryProvider);
  final analytics = ref.watch(analyticsProvider);
  return UserHobbiesNotifier(prefs, repo, analytics);
});

class UserHobbiesNotifier extends StateNotifier<Map<String, UserHobby>> {
  final SharedPreferences _prefs;
  final UserProgressRepository _repo;
  final AnalyticsService _analytics;
  static const _key = 'user_hobbies';

  UserHobbiesNotifier(this._prefs, this._repo, this._analytics) : super(_load(_prefs));

  static Map<String, UserHobby> _load(SharedPreferences prefs) {
    final json = prefs.getString(_key);
    if (json == null) return {};
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return map.map((key, value) => MapEntry(
        key,
        UserHobby.fromJson(value as Map<String, dynamic>),
      ));
    } catch (_) {
      return {};
    }
  }

  void _save() {
    final map = state.map((key, value) => MapEntry(key, value.toJson()));
    _prefs.setString(_key, jsonEncode(map));
  }

  /// Fire-and-forget API call with rollback on failure.
  void _apiCall(
    Map<String, UserHobby> snapshot,
    Future<void> Function() call,
  ) {
    call().catchError((e) {
      debugPrint('[UserHobbies] API call failed, rolling back: $e');
      state = snapshot;
      _save();
    });
  }

  /// Sync local state with server. Called after login/session restore.
  /// If server has data, it replaces local. If server is empty but local
  /// has data, pushes local to server (first-login migration).
  Future<void> syncFromServer() async {
    try {
      final serverHobbies = await _repo.getHobbies();
      if (serverHobbies.isNotEmpty) {
        // Server is source of truth — replace local state
        state = {for (final h in serverHobbies) h.hobbyId: h};
        _save();
      } else if (state.isNotEmpty) {
        // First login with existing local data — push to server
        await _repo.syncHobbies(state.values.toList());
      }
    } catch (e) {
      debugPrint('[UserHobbies] syncFromServer failed: $e');
    }
  }

  void saveHobby(String hobbyId) {
    if (state.containsKey(hobbyId)) return;
    final snapshot = Map<String, UserHobby>.from(state);
    state = {
      ...state,
      hobbyId: UserHobby(hobbyId: hobbyId, status: HobbyStatus.saved),
    };
    _save();
    _analytics.trackEvent('hobby_saved', {'hobby_id': hobbyId});
    _apiCall(snapshot, () async => _repo.saveHobby(hobbyId));
  }

  void unsaveHobby(String hobbyId) {
    final hobby = state[hobbyId];
    if (hobby == null || hobby.status != HobbyStatus.saved) return;
    final snapshot = Map<String, UserHobby>.from(state);
    state = Map.from(state)..remove(hobbyId);
    _save();
    _apiCall(snapshot, () => _repo.unsaveHobby(hobbyId));
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
    // Track hobby_switched if user already has a different active/trying hobby
    final currentActive = state.entries
        .where((e) => e.value.status == HobbyStatus.trying || e.value.status == HobbyStatus.active)
        .map((e) => e.key)
        .toList();
    if (currentActive.isNotEmpty && !currentActive.contains(hobbyId)) {
      _analytics.trackEvent('hobby_switched', {
        'from_hobby_id': currentActive.first,
        'to_hobby_id': hobbyId,
      });
    }

    final snapshot = Map<String, UserHobby>.from(state);
    final existing = state[hobbyId];
    final now = DateTime.now();
    state = {
      ...state,
      hobbyId: UserHobby(
        hobbyId: hobbyId,
        status: HobbyStatus.trying,
        completedStepIds: existing?.completedStepIds ?? {},
        startedAt: now,
      ),
    };
    _save();
    _analytics.trackEvent('hobby_started', {'hobby_id': hobbyId});
    _apiCall(snapshot, () async =>
      _repo.updateStatus(hobbyId, HobbyStatus.trying, startedAt: now));
  }

  void setActive(String hobbyId) {
    final existing = state[hobbyId];
    if (existing == null) return;
    final snapshot = Map<String, UserHobby>.from(state);
    state = {
      ...state,
      hobbyId: existing.copyWith(status: HobbyStatus.active),
    };
    _save();
    _apiCall(snapshot, () async =>
      _repo.updateStatus(hobbyId, HobbyStatus.active));
  }

  void setDone(String hobbyId) {
    final existing = state[hobbyId];
    if (existing == null) return;
    final snapshot = Map<String, UserHobby>.from(state);
    state = {
      ...state,
      hobbyId: existing.copyWith(status: HobbyStatus.done),
    };
    _save();
    _apiCall(snapshot, () async =>
      _repo.updateStatus(hobbyId, HobbyStatus.done, completedAt: DateTime.now()));
  }

  void toggleStep(String hobbyId, String stepId) {
    final existing = state[hobbyId] ?? UserHobby(hobbyId: hobbyId, status: HobbyStatus.trying);
    final steps = Set<String>.from(existing.completedStepIds);
    final wasCompleted = steps.contains(stepId);
    if (wasCompleted) {
      steps.remove(stepId);
    } else {
      steps.add(stepId);
      // First step ever completed for this hobby = first session
      if (existing.completedStepIds.isEmpty) {
        _analytics.trackEvent('first_session_completed', {
          'hobby_id': hobbyId,
          'step_id': stepId,
        });
      }
    }
    state = {
      ...state,
      hobbyId: existing.copyWith(completedStepIds: steps),
    };
    _save();
    // Targeted rollback: only undo THIS specific step toggle on failure,
    // so concurrent toggles don't cascade-wipe each other's changes.
    _repo.toggleStep(hobbyId, stepId).then((_) {}).catchError((e) {
      debugPrint('[UserHobbies] toggleStep failed, reverting step $stepId: $e');
      final current = state[hobbyId];
      if (current != null) {
        final revertedSteps = Set<String>.from(current.completedStepIds);
        if (wasCompleted) {
          revertedSteps.add(stepId);
        } else {
          revertedSteps.remove(stepId);
        }
        state = {
          ...state,
          hobbyId: current.copyWith(completedStepIds: revertedSteps),
        };
        _save();
      }
    });
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

/// Whether the user can start a new hobby (Pro = unlimited, Free = 1 active).
/// Returns true if the hobbyId is already active OR if no other hobby is active.
final canStartHobbyProvider = Provider.family<bool, String>((ref, hobbyId) {
  final isPro = ref.watch(isProProvider);
  if (isPro) return true;

  final hobbies = ref.watch(userHobbiesProvider);
  final activeEntries = hobbies.entries.where(
    (e) => e.value.status == HobbyStatus.trying ||
           e.value.status == HobbyStatus.active ||
           e.value.status == HobbyStatus.paused,
  );

  // Allow if this hobby is already the active one
  if (activeEntries.any((e) => e.key == hobbyId)) return true;

  // Allow if no other hobby is active
  return activeEntries.isEmpty;
});
