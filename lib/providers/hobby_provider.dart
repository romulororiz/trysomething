import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/curated_pack.dart';
import '../models/hobby.dart';
import 'repository_providers.dart';

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

/// Filtered hobbies for the feed
final filteredHobbiesProvider = FutureProvider<List<Hobby>>((ref) async {
  final category = ref.watch(selectedCategoryProvider);
  final allHobbies = await ref.watch(hobbyListProvider.future);

  if (category == null) return allHobbies;
  return allHobbies
      .where((h) => h.category.toLowerCase() == category.toLowerCase())
      .toList();
});
