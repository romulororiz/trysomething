import 'package:freezed_annotation/freezed_annotation.dart';

part 'features.freezed.dart';
part 'features.g.dart';

// ═══════════════════════════════════════════════════════
//  FEATURE MODELS (Gamification, Utility, Content)
// ═══════════════════════════════════════════════════════

@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    @Default('Your Name') String username,
    @Default('') String bio,
    String? avatarUrl,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}

@freezed
class Challenge with _$Challenge {
  const Challenge._();

  const factory Challenge({
    required String id,
    required String title,
    required String description,
    required int targetCount,
    @Default(0) int currentCount,
    required DateTime startDate,
    required DateTime endDate,
    @Default(false) bool isCompleted,
  }) = _Challenge;

  int get daysLeft => endDate.difference(DateTime.now()).inDays.clamp(0, 999);

  factory Challenge.fromJson(Map<String, dynamic> json) =>
      _$ChallengeFromJson(json);
}

@freezed
class ScheduleEvent with _$ScheduleEvent {
  const factory ScheduleEvent({
    required String id,
    required String hobbyId,
    required int dayOfWeek, // 1=Mon, 7=Sun
    required String startTime, // "19:00"
    required int durationMinutes,
  }) = _ScheduleEvent;

  factory ScheduleEvent.fromJson(Map<String, dynamic> json) =>
      _$ScheduleEventFromJson(json);
}

@freezed
class HobbyCombo with _$HobbyCombo {
  const factory HobbyCombo({
    required String hobbyId1,
    required String hobbyId2,
    required String reason,
    required List<String> sharedTags,
  }) = _HobbyCombo;

  factory HobbyCombo.fromJson(Map<String, dynamic> json) =>
      _$HobbyComboFromJson(json);
}

@freezed
class FaqItem with _$FaqItem {
  const factory FaqItem({
    @Default('') String id,
    required String question,
    required String answer,
    @Default(0) int upvotes,
    @Default(0) int helpfulCount,
  }) = _FaqItem;

  factory FaqItem.fromJson(Map<String, dynamic> json) =>
      _$FaqItemFromJson(json);
}

@freezed
class CostBreakdown with _$CostBreakdown {
  const factory CostBreakdown({
    required int starter,
    required int threeMonth,
    required int oneYear,
    @Default([]) List<String> tips,
  }) = _CostBreakdown;

  factory CostBreakdown.fromJson(Map<String, dynamic> json) =>
      _$CostBreakdownFromJson(json);
}

@freezed
class BudgetAlternative with _$BudgetAlternative {
  const factory BudgetAlternative({
    required String itemName,
    required String diyOption,
    required int diyCost,
    required String budgetOption,
    required int budgetCost,
    required String premiumOption,
    required int premiumCost,
  }) = _BudgetAlternative;

  factory BudgetAlternative.fromJson(Map<String, dynamic> json) =>
      _$BudgetAlternativeFromJson(json);
}
