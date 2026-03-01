import '../../models/features.dart';

/// Abstract feature data source for FAQ, cost, budget, seasonal, mood data.
abstract class FeatureRepository {
  Future<List<FaqItem>> getFaqForHobby(String hobbyId);
  Future<CostBreakdown?> getCostBreakdown(String hobbyId);
  Future<List<BudgetAlternative>> getBudgetAlternatives(String hobbyId);
  Future<Map<String, List<String>>> getSeasonalHobbies();
  Future<Map<String, List<String>>> getMoodTags();
}
