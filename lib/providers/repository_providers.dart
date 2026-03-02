import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/hobby_repository.dart';
import '../data/repositories/hobby_repository_api.dart';
import '../data/repositories/feature_repository.dart';
import '../data/repositories/feature_repository_api.dart';
import '../data/repositories/personal_tools_repository.dart';
import '../data/repositories/personal_tools_repository_api.dart';

/// Hobby data repository — API-backed with Hive cache + SeedData fallback.
final hobbyRepositoryProvider = Provider<HobbyRepository>((ref) {
  return HobbyRepositoryApi();
});

/// Feature data repository — API-backed with Hive cache + SeedData fallback.
final featureRepositoryProvider = Provider<FeatureRepository>((ref) {
  return FeatureRepositoryApi();
});

/// Personal tools repository — journal, notes, schedule, shopping.
final personalToolsRepositoryProvider = Provider<PersonalToolsRepository>((ref) {
  return PersonalToolsRepositoryApi();
});
