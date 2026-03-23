import '../../models/hobby.dart';

/// Abstract interface for user hobby progress operations.
abstract class UserProgressRepository {
  /// Fetch all user hobbies with completed step IDs.
  Future<List<UserHobby>> getHobbies();

  /// Save a hobby (status: saved).
  Future<UserHobby> saveHobby(String hobbyId);

  /// Remove a saved hobby.
  Future<void> unsaveHobby(String hobbyId);

  /// Update hobby status (trying, active, done).
  Future<UserHobby> updateStatus(
    String hobbyId,
    HobbyStatus status, {
    DateTime? startedAt,
    DateTime? completedAt,
  });

  /// Toggle a roadmap step completion.
  /// Returns a record of (updated UserHobby, hobbyCompleted flag).
  Future<(UserHobby, bool)> toggleStep(String hobbyId, String stepId);

  /// Bulk sync local hobbies to server (first-login migration).
  Future<List<UserHobby>> syncHobbies(List<UserHobby> hobbies);

  /// Fetch activity log for heatmap.
  Future<List<Map<String, dynamic>>> getActivityLog({int days = 365});
}
