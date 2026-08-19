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
