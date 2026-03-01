import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/hobby_repository.dart';
import '../data/repositories/hobby_repository_impl.dart';
import '../data/repositories/feature_repository.dart';
import '../data/repositories/feature_repository_impl.dart';

/// Hobby data repository — swap implementation for API in Phase 3.
final hobbyRepositoryProvider = Provider<HobbyRepository>((ref) {
  return HobbyRepositoryImpl();
});

/// Feature data repository — swap implementation for API in Phase 3.
final featureRepositoryProvider = Provider<FeatureRepository>((ref) {
  return FeatureRepositoryImpl();
});
