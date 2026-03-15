import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/hobby.dart';
import '../core/hobby_match.dart';
import 'hobby_provider.dart';
import 'user_provider.dart';

/// Single match result with score and human-readable reasons.
class MatchResult {
  final Hobby hobby;
  final int score;
  final List<String> reasons;
  const MatchResult({
    required this.hobby,
    required this.score,
    required this.reasons,
  });
}

/// Reactive provider: recalculates when preferences or hobby list changes.
/// Consumed by Match Results Screen (onboarding) and Updated Matches Sheet (settings).
final matchedHobbiesProvider = Provider<List<MatchResult>>((ref) {
  final allHobbies = ref.watch(hobbyListProvider).valueOrNull ?? [];
  final prefs = ref.watch(userPreferencesProvider);

  if (allHobbies.isEmpty) return [];

  final matched = computeMatchedHobbies(
    allHobbies: allHobbies,
    userHours: prefs.hoursPerWeek.toDouble(),
    userBudgetLevel: prefs.budgetLevel,
    userPrefersSocial: prefs.preferSocial,
    userVibes: prefs.vibes,
  );

  return matched.map((hobby) {
    final score = computeMatchScore(
      hobby: hobby,
      userHours: prefs.hoursPerWeek.toDouble(),
      userBudgetLevel: prefs.budgetLevel,
      userPrefersSocial: prefs.preferSocial,
      userVibes: prefs.vibes,
    );
    final reasons = computeMatchReasons(
      hobby: hobby,
      userHours: prefs.hoursPerWeek.toDouble(),
      userBudgetLevel: prefs.budgetLevel,
      userPrefersSocial: prefs.preferSocial,
      userVibes: prefs.vibes,
    );
    return MatchResult(hobby: hobby, score: score, reasons: reasons);
  }).toList();
});
