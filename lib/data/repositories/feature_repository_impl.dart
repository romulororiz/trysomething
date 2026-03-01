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
