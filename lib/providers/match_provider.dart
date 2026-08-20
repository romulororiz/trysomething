import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/analytics/analytics_provider.dart';
import '../core/hobby_match.dart';
import '../models/hobby.dart';
import 'hobby_provider.dart';
import 'repository_providers.dart';
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

/// Matches come from POST /api/match (heuristic pre-filter + AI jury with
/// personalized reasons). Any failure — offline, server error, or a result
/// too small to resolve locally — falls back to the on-device heuristic in
/// lib/core/hobby_match.dart, so the user always gets matches.
///
/// Recomputes when preferences or the hobby list change.
/// Consumed by Match Results Screen (onboarding) and Updated Matches Sheet (settings).
final matchedHobbiesProvider = FutureProvider<List<MatchResult>>((ref) async {
  final allHobbies = await ref.watch(hobbyListProvider.future);
  final prefs = ref.watch(userPreferencesProvider);

  if (allHobbies.isEmpty) return [];
  final byId = {for (final h in allHobbies) h.id: h};

  try {
    final server = await ref.read(hobbyRepositoryProvider).getMatches(prefs);
    final results = [
      for (final m in server)
        if (byId[m.hobbyId] != null)
          MatchResult(
            hobby: byId[m.hobbyId]!,
            score: m.score,
            reasons: [m.reason],
          ),
    ];
    if (results.length >= 3) {
      ref.read(analyticsProvider).trackEvent('match_served', {
        'source': 'server',
        'count': results.length,
      });
      return results;
    }
    // Server returned too little we can resolve locally → local fallback.
  } catch (_) {
    // Network/server error → local fallback.
  }

  final local = _localHeuristicMatches(allHobbies, prefs);
  ref.read(analyticsProvider).trackEvent('match_served', {
    'source': 'local',
    'count': local.length,
  });
  return local;
});

/// The pre-Phase-2 on-device matching, kept whole as the offline fallback.
List<MatchResult> _localHeuristicMatches(
  List<Hobby> allHobbies,
  UserPreferences prefs,
) {
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
}
