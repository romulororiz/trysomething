import 'package:freezed_annotation/freezed_annotation.dart';

part 'hobby.freezed.dart';
part 'hobby.g.dart';

// ═══════════════════════════════════════════════════════
//  JSON CONVERTERS
// ═══════════════════════════════════════════════════════

/// Converts Set<String> ↔ List<dynamic> for JSON serialization.
class SetStringConverter implements JsonConverter<Set<String>, List<dynamic>> {
  const SetStringConverter();

  @override
  Set<String> fromJson(List<dynamic> json) => json.cast<String>().toSet();

  @override
  List<String> toJson(Set<String> object) => object.toList();
}

// ═══════════════════════════════════════════════════════
//  HOBBY MODEL
// ═══════════════════════════════════════════════════════

@freezed
class Hobby with _$Hobby {
  const factory Hobby({
    required String id,
    required String title,
    required String hook,
    required String category,
    required String imageUrl,
    required List<String> tags,
    required String costText,
    required String timeText,
    required String difficultyText,
    required String whyLove,
    required String difficultyExplain,
    required List<KitItem> starterKit,
    required List<String> pitfalls,
    @Default([]) List<String> quittingReasons,
    required List<RoadmapStep> roadmapSteps,
  }) = _Hobby;

  factory Hobby.fromJson(Map<String, dynamic> json) => _$HobbyFromJson(json);
}

// ═══════════════════════════════════════════════════════
//  KIT ITEM MODEL
// ═══════════════════════════════════════════════════════

@freezed
class KitItem with _$KitItem {
  const factory KitItem({
    required String name,
    required String description,
    required int cost,
    @Default(false) bool isOptional,
    String? imageUrl,
    String? affiliateUrl,
    String? affiliateSource,
  }) = _KitItem;

  factory KitItem.fromJson(Map<String, dynamic> json) => _$KitItemFromJson(json);
}

// ═══════════════════════════════════════════════════════
//  COMPLETION MODE
// ═══════════════════════════════════════════════════════

/// How a roadmap step is completed during a session.
enum CompletionMode { timer, photoProof, checkIn }

// ═══════════════════════════════════════════════════════
//  ROADMAP STEP MODEL
// ═══════════════════════════════════════════════════════

@freezed
class RoadmapStep with _$RoadmapStep {
  const RoadmapStep._();

  const factory RoadmapStep({
    required String id,
    required String title,
    required String description,
    required int estimatedMinutes,
    String? milestone,
    CompletionMode? completionMode,
  }) = _RoadmapStep;

  /// Infers completion mode from step title when not explicitly set.
  ///
  /// Steps about buying/visiting/finding → checkIn (quick confirm).
  /// Everything else → timer (timed practice session).
  CompletionMode get effectiveMode {
    if (completionMode != null) return completionMode!;
    final lower = title.toLowerCase();
    if (lower.startsWith('buy') ||
        lower.startsWith('get ') ||
        lower.startsWith('visit') ||
        lower.startsWith('try a local') ||
        lower.startsWith('set up') ||
        lower.startsWith('find ')) {
      return CompletionMode.checkIn;
    }
    return CompletionMode.timer;
  }

  factory RoadmapStep.fromJson(Map<String, dynamic> json) =>
      _$RoadmapStepFromJson(json);
}

// ═══════════════════════════════════════════════════════
//  HOBBY CATEGORY MODEL
// ═══════════════════════════════════════════════════════

@freezed
class HobbyCategory with _$HobbyCategory {
  const factory HobbyCategory({
    required String id,
    required String name,
    required int count,
    required String imageUrl,
  }) = _HobbyCategory;

  factory HobbyCategory.fromJson(Map<String, dynamic> json) =>
      _$HobbyCategoryFromJson(json);
}

// ═══════════════════════════════════════════════════════
//  USER STATE MODELS
// ═══════════════════════════════════════════════════════

enum HobbyStatus { saved, trying, active, done }

@freezed
class UserHobby with _$UserHobby {
  const UserHobby._();

  const factory UserHobby({
    required String hobbyId,
    required HobbyStatus status,
    @SetStringConverter() @Default(<String>{}) Set<String> completedStepIds,
    DateTime? startedAt,
    DateTime? lastActivityAt,
    @Default(0) int streakDays,
  }) = _UserHobby;

  double progressPercent(int totalSteps) {
    if (totalSteps == 0) return 0;
    return completedStepIds.length / totalSteps;
  }

  factory UserHobby.fromJson(Map<String, dynamic> json) =>
      _$UserHobbyFromJson(json);
}

@freezed
class UserPreferences with _$UserPreferences {
  const factory UserPreferences({
    @Default(3) int hoursPerWeek,
    @Default(1) int budgetLevel,
    @Default(false) bool preferSocial,
    @SetStringConverter() @Default(<String>{}) Set<String> vibes,
  }) = _UserPreferences;

  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesFromJson(json);
}
