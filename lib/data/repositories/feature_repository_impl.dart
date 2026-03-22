import '../../models/features.dart';
import '../../models/feature_seed_data.dart';
import 'feature_repository.dart';

/// Local seed-data implementation of [FeatureRepository].
/// Will be replaced with API + Hive cache in Phase 3.
class FeatureRepositoryImpl implements FeatureRepository {
  @override
  Future<List<FaqItem>> getFaqForHobby(String hobbyId) async {
    return FeatureSeedData.faqByHobby[hobbyId] ?? [];
  }

  @override
  Future<FaqItem> voteFaq(String hobbyId, String faqId, String vote) async {
    // Seed fallback — no server, return a dummy item
    throw UnimplementedError('voteFaq not available in seed fallback');
  }

  @override
  Future<CostBreakdown?> getCostBreakdown(String hobbyId) async {
    return FeatureSeedData.costByHobby[hobbyId];
  }

  @override
  Future<List<BudgetAlternative>> getBudgetAlternatives(String hobbyId) async {
    return FeatureSeedData.budgetAlternatives[hobbyId] ?? [];
  }

  @override
  Future<Map<String, List<String>>> getSeasonalHobbies() async {
    return FeatureSeedData.seasonalHobbies;
  }

  @override
  Future<Map<String, List<String>>> getMoodTags() async {
    return FeatureSeedData.moodToTags;
  }

  @override
  Future<List<HobbyCombo>> getCombos() async {
    return FeatureSeedData.combos;
  }
}
