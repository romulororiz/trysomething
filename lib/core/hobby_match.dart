import '../models/hobby.dart';

// ═══════════════════════════════════════════════════════
//  PARSING HELPERS
// ═══════════════════════════════════════════════════════

/// Extracts numeric cost range from strings like "CHF 40–120" or "CHF 0–30".
/// Returns (min, max). Falls back to (0, 9999) if unparseable.
(int, int) parseCostRange(String costText) {
  // Match patterns like "40–120", "0-30", "40 – 120"
  final match = RegExp(r'(\d+)\s*[–\-]\s*(\d+)').firstMatch(costText);
  if (match != null) {
    return (int.parse(match.group(1)!), int.parse(match.group(2)!));
  }
  // Single number like "CHF 50"
  final single = RegExp(r'(\d+)').firstMatch(costText);
  if (single != null) {
    final v = int.parse(single.group(1)!);
    return (v, v);
  }
  return (0, 9999);
}

/// Extracts weekly hours from strings like "2h/week" or "4h/week".
/// Returns the number. Falls back to 99 if unparseable.
double parseWeeklyHours(String timeText) {
  final match = RegExp(r'(\d+(?:\.\d+)?)\s*h').firstMatch(timeText);
  if (match != null) {
    return double.parse(match.group(1)!);
  }
  return 99;
}

// ═══════════════════════════════════════════════════════
//  BUDGET THRESHOLDS
// ═══════════════════════════════════════════════════════

/// Maps budget level (0=low, 1=medium, 2=high) to max starter cost in CHF.
int budgetThreshold(int budgetLevel) {
  switch (budgetLevel) {
    case 0:
      return 50;
    case 1:
      return 150;
    default:
      return 999999; // no limit
  }
}

// ═══════════════════════════════════════════════════════
//  SCORING
// ═══════════════════════════════════════════════════════

/// Computes a composite match score for a hobby against user preferences.
int computeMatchScore({
  required Hobby hobby,
  required double userHours,
  required int userBudgetLevel,
  required bool userPrefersSocial,
  required Set<String> userVibes,
}) {
  int score = 0;

  // Budget fit (0–3 points)
  final (_, costMax) = parseCostRange(hobby.costText);
  final maxBudget = budgetThreshold(userBudgetLevel);
  if (costMax <= maxBudget) {
    score += 3;
  } else if (costMax <= maxBudget * 1.5) {
    score += 1;
  }

  // Time fit (0–3 points)
  final hobbyHours = parseWeeklyHours(hobby.timeText);
  if (hobbyHours <= userHours) {
    score += 3;
  } else if (hobbyHours <= userHours + 2) {
    score += 1;
  }

  // Solo/social (0–2 points)
  if (userPrefersSocial && hobby.tags.contains('social')) {
    score += 2;
  } else if (!userPrefersSocial && hobby.tags.contains('solo')) {
    score += 2;
  }

  // Vibe match (+1 per matching tag)
  for (final vibe in userVibes) {
    if (hobby.tags.contains(vibe)) {
      score += 1;
    }
  }

  return score;
}

// ═══════════════════════════════════════════════════════
//  MATCH REASONS
// ═══════════════════════════════════════════════════════

/// Vibe key → display label mapping.
const _vibeLabels = {
  'creative': 'creative',
  'relaxing': 'relaxing',
  'social': 'social',
  'physical': 'active',
  'intellectual': 'intellectual',
  'outdoors': 'outdoor',
  'technical': 'technical',
  'culinary': 'culinary',
  'meditative': 'meditative',
  'competitive': 'competitive',
};

/// Returns 2-3 specific reasons why a hobby matches the user's preferences.
/// Reasons are derived from the actual scoring signals, not generic text.
/// Each reason references concrete hobby data to differentiate between cards.
List<String> computeMatchReasons({
  required Hobby hobby,
  required double userHours,
  required int userBudgetLevel,
  required bool userPrefersSocial,
  required Set<String> userVibes,
}) {
  final reasons = <String>[];

  // Budget reason — show actual hobby cost, not just "fits budget"
  final (costMin, costMax) = parseCostRange(hobby.costText);
  final maxBudget = budgetThreshold(userBudgetLevel);
  if (costMax <= maxBudget && userBudgetLevel < 2) {
    if (costMin == 0 && costMax <= 30) {
      reasons.add('Starts free or under CHF 30');
    } else {
      reasons.add('Starter cost: ${hobby.costText}');
    }
  }

  // Time reason — show actual hobby hours
  final hobbyHours = parseWeeklyHours(hobby.timeText);
  if (hobbyHours <= userHours) {
    if (hobbyHours <= 1) {
      reasons.add('Just ${hobbyHours.round()}h/week to start');
    } else {
      reasons.add('Fits in ${hobbyHours.round()}h/week');
    }
  }

  // Solo/social reason
  if (userPrefersSocial && hobby.tags.contains('social')) {
    reasons.add('Great for group activities');
  } else if (!userPrefersSocial && hobby.tags.contains('solo')) {
    reasons.add('Perfect for solo time');
  }

  // Indoor/outdoor context
  if (hobby.tags.contains('outdoors')) {
    reasons.add('Gets you outdoors');
  } else if (hobby.tags.contains('indoor') || hobby.tags.contains('at-home')) {
    reasons.add('Easy to do at home');
  }

  // Vibe reason (first matching vibe)
  for (final vibe in userVibes) {
    if (hobby.tags.contains(vibe)) {
      final label = _vibeLabels[vibe] ?? vibe;
      reasons.add('Matches your $label vibe');
      break;
    }
  }

  return reasons.take(3).toList();
}

// ═══════════════════════════════════════════════════════
//  TOP MATCHES
// ═══════════════════════════════════════════════════════

/// Returns the top matched hobbies from [allHobbies] based on user preferences.
/// Always returns at least 4 hobbies (padded with budget-passing hobbies if needed).
List<Hobby> computeMatchedHobbies({
  required List<Hobby> allHobbies,
  required double userHours,
  required int userBudgetLevel,
  required bool userPrefersSocial,
  required Set<String> userVibes,
}) {
  if (allHobbies.isEmpty) return [];

  final scored = allHobbies.map((h) {
    final score = computeMatchScore(
      hobby: h,
      userHours: userHours,
      userBudgetLevel: userBudgetLevel,
      userPrefersSocial: userPrefersSocial,
      userVibes: userVibes,
    );
    return (hobby: h, score: score);
  }).toList();

  scored.sort((a, b) => b.score.compareTo(a.score));

  final top = scored.where((e) => e.score > 0).toList();

  if (top.length >= 4) {
    return top.take(4).map((e) => e.hobby).toList();
  }

  // Pad with budget-passing hobbies not already in top
  final maxBudget = budgetThreshold(userBudgetLevel);
  final topIds = top.map((e) => e.hobby.id).toSet();
  final padding = allHobbies.where((h) {
    if (topIds.contains(h.id)) return false;
    final (_, costMax) = parseCostRange(h.costText);
    return costMax <= maxBudget;
  }).toList()
    ..shuffle();

  final result = top.map((e) => e.hobby).toList();
  for (final h in padding) {
    if (result.length >= 4) break;
    result.add(h);
  }

  // If still under 4, add any remaining hobbies
  if (result.length < 4) {
    final resultIds = result.map((h) => h.id).toSet();
    for (final h in allHobbies) {
      if (result.length >= 4) break;
      if (!resultIds.contains(h.id)) result.add(h);
    }
  }

  return result;
}
