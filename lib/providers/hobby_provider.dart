import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/hobby_match.dart';
import '../models/curated_pack.dart';
import '../models/hobby.dart';
import 'repository_providers.dart';
import 'user_provider.dart';

// ═══════════════════════════════════════════════════════
//  SHELL LOADING STATE
// ═══════════════════════════════════════════════════════

/// When true, the main shell hides the navbar (e.g. while home screen loads).
final shellLoadingProvider = StateProvider<bool>((ref) => true);

// ═══════════════════════════════════════════════════════
//  HOBBY PROVIDERS
// ═══════════════════════════════════════════════════════

/// All hobbies
final hobbyListProvider = FutureProvider<List<Hobby>>((ref) {
  return ref.watch(hobbyRepositoryProvider).getHobbies();
});

/// Single hobby by ID
final hobbyByIdProvider = FutureProvider.family<Hobby?, String>((ref, id) {
  return ref.watch(hobbyRepositoryProvider).getHobbyById(id);
});

/// All categories
final categoriesProvider = FutureProvider<List<HobbyCategory>>((ref) {
  return ref.watch(hobbyRepositoryProvider).getCategories();
});

/// Related hobbies for a given hobby ID
final relatedHobbiesProvider =
    FutureProvider.family<List<Hobby>, String>((ref, hobbyId) {
  return ref.watch(hobbyRepositoryProvider).getRelatedHobbies(hobbyId);
});

/// Curated packs from server
final curatedPacksProvider = FutureProvider<List<CuratedPack>>((ref) {
  return ref.watch(hobbyRepositoryProvider).getCuratedPacks();
});

// ═══════════════════════════════════════════════════════
//  AI GENERATION
// ═══════════════════════════════════════════════════════

enum GenerationStatus { idle, generating, success, error }

class GenerationState {
  final GenerationStatus status;
  final Hobby? hobby;
  final String? error;

  const GenerationState({
    this.status = GenerationStatus.idle,
    this.hobby,
    this.error,
  });

  GenerationState copyWith({
    GenerationStatus? status,
    Hobby? hobby,
    String? error,
  }) =>
      GenerationState(
        status: status ?? this.status,
        hobby: hobby ?? this.hobby,
        error: error ?? this.error,
      );
}

class GenerationNotifier extends StateNotifier<GenerationState> {
  GenerationNotifier(this._ref) : super(const GenerationState());

  final Ref _ref;
  CancelToken? _cancelToken;

  Future<void> generate(String query) async {
    // Guard against double-taps / concurrent calls
    if (state.status == GenerationStatus.generating) return;
    debugPrint('[Generation] Starting generation for: "$query"');
    _cancelToken = CancelToken();
    state = const GenerationState(status: GenerationStatus.generating);
    try {
      final hobby = await _ref
          .read(hobbyRepositoryProvider)
          .generateHobby(query, cancelToken: _cancelToken);
      debugPrint('[Generation] Success! Hobby: ${hobby.title} (${hobby.id})');
      // Invalidate hobby list so feed picks up the new hobby
      _ref.invalidate(hobbyListProvider);
      state = GenerationState(
        status: GenerationStatus.success,
        hobby: hobby,
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        debugPrint('[Generation] Cancelled by user');
        state = const GenerationState();
        return;
      }
      debugPrint('[Generation] Error: $e');
      state = GenerationState(
        status: GenerationStatus.error,
        error: _friendlyError(e),
      );
    } catch (e) {
      debugPrint('[Generation] Error: $e');
      state = GenerationState(
        status: GenerationStatus.error,
        error: _friendlyError(e),
      );
    } finally {
      _cancelToken = null;
    }
  }

  void cancel() {
    _cancelToken?.cancel();
    _cancelToken = null;
    state = const GenerationState();
  }

  void reset() {
    state = const GenerationState();
  }

  /// Debug only: fake generating state for UI testing. Remove before release.
  void debugFakeGenerating() {
    assert(() {
      state = const GenerationState(status: GenerationStatus.generating);
      return true;
    }());
  }

  String _friendlyError(dynamic e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && data.containsKey('error')) {
        return data['error'] as String;
      }
      if (e.response?.statusCode == 403) return 'Pro subscription required';
      if (e.response?.statusCode == 429) return 'Generation limit reached. Try again tomorrow.';
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        return 'No internet connection. Check your network.';
      }
    }
    if (e is Exception) {
      final msg = e.toString();
      // Strip "Exception: " prefix
      if (msg.startsWith('Exception: ')) return msg.substring(11);
    }
    return 'Something went wrong. Try again.';
  }
}

final generationProvider =
    StateNotifierProvider<GenerationNotifier, GenerationState>((ref) {
  return GenerationNotifier(ref);
});

// ═══════════════════════════════════════════════════════
//  FEED PROVIDERS
// ═══════════════════════════════════════════════════════

/// Currently selected category filter (null = "For you" / all)
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

/// Filtered hobbies for the feed.
/// When "For you" is selected (category == null), hobbies are ranked by
/// match score using the user's onboarding preferences.
final filteredHobbiesProvider = FutureProvider<List<Hobby>>((ref) async {
  final category = ref.watch(selectedCategoryProvider);
  final allHobbies = await ref.watch(hobbyListProvider.future);

  if (category != null) {
    return allHobbies
        .where((h) => h.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  // "For you" — rank by match score using onboarding preferences
  final prefs = ref.watch(userPreferencesProvider);
  final scored = allHobbies.map((h) {
    final score = computeMatchScore(
      hobby: h,
      userHours: prefs.hoursPerWeek.toDouble(),
      userBudgetLevel: prefs.budgetLevel,
      userPrefersSocial: prefs.preferSocial,
      userVibes: prefs.vibes,
    );
    return (hobby: h, score: score);
  }).toList();

  scored.sort((a, b) => b.score.compareTo(a.score));
  return scored.map((e) => e.hobby).toList();
});
