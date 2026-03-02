import '../../models/features.dart';
import '../../models/gamification.dart';

/// Repository interface for gamification: challenges and achievements.
abstract class GamificationRepository {
  Future<List<Challenge>> getChallenges();
  Future<List<Achievement>> getAchievements();
}
