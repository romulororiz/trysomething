import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/hobby.dart';
import '../models/seed_data.dart';

// ═══════════════════════════════════════════════════════
//  HOBBY PROVIDERS
// ═══════════════════════════════════════════════════════

/// All hobbies
final hobbyListProvider = Provider<List<Hobby>>((ref) {
  return SeedData.hobbies;
});

/// Single hobby by ID
final hobbyByIdProvider = Provider.family<Hobby?, String>((ref, id) {
  return SeedData.getHobby(id);
});

/// All categories
final categoriesProvider = Provider<List<HobbyCategory>>((ref) {
  return SeedData.categories;
});

/// Related hobbies for a given hobby ID
final relatedHobbiesProvider = Provider.family<List<Hobby>, String>((ref, hobbyId) {
  return SeedData.getRelated(hobbyId);
});

// ═══════════════════════════════════════════════════════
//  FEED PROVIDERS
// ═══════════════════════════════════════════════════════

/// Currently selected category filter (null = "For you" / all)
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

/// Filtered hobbies for the feed
final filteredHobbiesProvider = Provider<List<Hobby>>((ref) {
  final category = ref.watch(selectedCategoryProvider);
  final allHobbies = ref.watch(hobbyListProvider);
  
  if (category == null) return allHobbies;
  return allHobbies.where((h) => h.category.toLowerCase() == category.toLowerCase()).toList();
});
