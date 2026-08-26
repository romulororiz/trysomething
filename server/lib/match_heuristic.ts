// ═══════════════════════════════════════════════════
//  Match heuristic — stage-1 filter for /api/match
//
//  1:1 TypeScript port of lib/core/hobby_match.dart (client keeps the
//  Dart original as its offline fallback — behavior must stay identical,
//  including quirks: "Free" parses to (0, 9999) and "min/day" time
//  strings parse to 99h. See match_heuristic.test.ts for the parity
//  fixtures that pin this down.
// ═══════════════════════════════════════════════════

export interface MatchProfile {
  vibes: string[];
  hoursPerWeek: number;
  budgetLevel: number;
  preferSocial: boolean;
}

export interface HobbyLite {
  id: string;
  title: string;
  hook: string;
  tags: string[];
  costText: string;
  timeText: string;
  difficultyText: string;
  categoryId: string;
}

export interface ScoredHobby {
  hobby: HobbyLite;
  score: number;
}

// ── Parsing helpers ─────────────────────────────

/** Extracts numeric cost range from strings like "$40–120" or "$0–30".
 *  Returns [min, max]. Falls back to [0, 9999] if unparseable ("Free" included). */
export function parseCostRange(costText: string): [number, number] {
  const range = costText.match(/(\d+)\s*[–-]\s*(\d+)/);
  if (range) {
    return [parseInt(range[1], 10), parseInt(range[2], 10)];
  }
  const single = costText.match(/(\d+)/);
  if (single) {
    const v = parseInt(single[1], 10);
    return [v, v];
  }
  return [0, 9999];
}

/** Extracts weekly hours from strings like "2h/week" or "1.5h/week".
 *  Falls back to 99 if unparseable (e.g. "30 min/day"). */
export function parseWeeklyHours(timeText: string): number {
  const match = timeText.match(/(\d+(?:\.\d+)?)\s*h/);
  if (match) {
    return parseFloat(match[1]);
  }
  return 99;
}

// ── Budget thresholds ───────────────────────────

/** Maps budget level (0=low, 1=medium, 2+=high) to max starter cost in USD. */
export function budgetThreshold(budgetLevel: number): number {
  switch (budgetLevel) {
    case 0:
      return 50;
    case 1:
      return 150;
    default:
      return 999999; // no limit
  }
}

// ── Vibe → category + tag mapping ───────────────

const VIBE_CATEGORIES: Record<string, Set<string>> = {
  creative: new Set(["creative", "maker"]),
  relaxing: new Set(["collecting"]),
  social: new Set(["social"]),
  physical: new Set(["fitness", "outdoors"]),
  intellectual: new Set(["mind"]),
  outdoors: new Set(["outdoors"]),
  technical: new Set(["maker"]),
  culinary: new Set(["food"]),
};

const VIBE_EXPANDED_TAGS: Record<string, Set<string>> = {
  creative: new Set(["creative", "artistic", "expressive", "craft", "paper-craft", "textile", "hands-on"]),
  relaxing: new Set(["relaxing", "therapeutic", "stress-relief", "self-care", "wellness", "mindful", "slow"]),
  social: new Set(["social", "family", "band-essential", "performance"]),
  physical: new Set(["physical", "cardio", "full-body", "energizing", "high-energy", "adrenaline", "thrilling"]),
  intellectual: new Set(["intellectual", "analytical", "logical", "problem-solving", "literary", "introspective", "science"]),
  outdoors: new Set(["outdoors", "outdoor", "walking", "water sports", "water-based", "aerial", "aerial-views", "urban exploration", "seasonal"]),
  technical: new Set(["technical", "tech", "digital", "electronic", "electronics", "arduino", "stem", "prototyping", "mechanical", "precision", "fpv"]),
  culinary: new Set(["fermented", "italian", "japanese", "spicy", "flavourful", "comforting", "aromatic", "home-based", "morning-routine", "daily-ritual", "indulgent", "hands-on", "cultural"]),
  meditative: new Set(["meditative", "mindful", "therapeutic", "introspective", "patience", "slow"]),
  competitive: new Set(["competitive", "skill-building", "challenging", "adrenaline"]),
};

/** Vibe key → display label mapping (used by the fallback reasons). */
const VIBE_LABELS: Record<string, string> = {
  creative: "creative",
  relaxing: "relaxing",
  social: "social",
  physical: "active",
  intellectual: "intellectual",
  outdoors: "outdoor",
  technical: "technical",
  culinary: "culinary",
  meditative: "meditative",
  competitive: "competitive",
};

/** A hobby matches a vibe via direct tag, category mapping, or expanded tags. */
function hobbyMatchesVibe(hobby: HobbyLite, vibe: string): boolean {
  if (hobby.tags.includes(vibe)) return true;

  const matchingCategories = VIBE_CATEGORIES[vibe];
  if (matchingCategories && matchingCategories.has(hobby.categoryId.toLowerCase())) {
    return true;
  }

  const expandedTags = VIBE_EXPANDED_TAGS[vibe];
  if (expandedTags) {
    for (const tag of hobby.tags) {
      if (expandedTags.has(tag)) return true;
    }
  }

  return false;
}

// ── Scoring ─────────────────────────────────────

/** Composite match score. Weights identical to the Dart original:
 *  +5 per vibe match, budget 0–2, time 0–2, solo/social 0–1. */
export function computeMatchScore(hobby: HobbyLite, profile: MatchProfile): number {
  let score = 0;

  // Vibe match — dominant signal (+5 per matching vibe; Set semantics like Dart)
  for (const vibe of new Set(profile.vibes)) {
    if (hobbyMatchesVibe(hobby, vibe)) {
      score += 5;
    }
  }

  // Budget fit (0–2 points)
  const [, costMax] = parseCostRange(hobby.costText);
  const maxBudget = budgetThreshold(profile.budgetLevel);
  if (costMax <= maxBudget) {
    score += 2;
  } else if (costMax <= maxBudget * 1.5) {
    score += 1;
  }

  // Time fit (0–2 points)
  const hobbyHours = parseWeeklyHours(hobby.timeText);
  if (hobbyHours <= profile.hoursPerWeek) {
    score += 2;
  } else if (hobbyHours <= profile.hoursPerWeek + 2) {
    score += 1;
  }

  // Solo/social (0–1 point)
  if (profile.preferSocial && hobby.tags.includes("social")) {
    score += 1;
  } else if (!profile.preferSocial && hobby.tags.includes("solo")) {
    score += 1;
  }

  return score;
}

// ── Match reasons (fallback path) ───────────────

/** 2-3 concrete reasons, derived from the same signals as the score.
 *  Same texts and priority order as the Dart original. */
export function computeMatchReasons(hobby: HobbyLite, profile: MatchProfile): string[] {
  const reasons: string[] = [];

  const [costMin, costMax] = parseCostRange(hobby.costText);
  const maxBudget = budgetThreshold(profile.budgetLevel);
  if (costMax <= maxBudget && profile.budgetLevel < 2) {
    if (costMin === 0 && costMax <= 30) {
      reasons.push("Starts free or under $30");
    } else {
      reasons.push(`Starter cost: ${hobby.costText}`);
    }
  }

  const hobbyHours = parseWeeklyHours(hobby.timeText);
  if (hobbyHours <= profile.hoursPerWeek) {
    if (hobbyHours <= 1) {
      reasons.push(`Just ${Math.round(hobbyHours)}h/week to start`);
    } else {
      reasons.push(`Fits in ${Math.round(hobbyHours)}h/week`);
    }
  }

  if (profile.preferSocial && hobby.tags.includes("social")) {
    reasons.push("Great for group activities");
  } else if (!profile.preferSocial && hobby.tags.includes("solo")) {
    reasons.push("Perfect for solo time");
  }

  if (hobby.tags.includes("outdoors")) {
    reasons.push("Gets you outdoors");
  } else if (hobby.tags.includes("indoor") || hobby.tags.includes("at-home")) {
    reasons.push("Easy to do at home");
  }

  for (const vibe of new Set(profile.vibes)) {
    if (hobbyMatchesVibe(hobby, vibe)) {
      const label = VIBE_LABELS[vibe] ?? vibe;
      reasons.push(`Matches your ${label} vibe`);
      break;
    }
  }

  return reasons.slice(0, 3);
}

// ── Candidate selection (stage 1) ───────────────

/** Scores every hobby and returns the top `n` with score > 0, sorted by
 *  score desc (id asc as a deterministic tie-break — results feed a
 *  profile-keyed cache). If fewer than `n` score above zero, pads with
 *  budget-passing hobbies, then anything left, mirroring the Dart
 *  padding idea but deterministic (no shuffle) and padding to `n`. */
export function selectCandidates(
  hobbies: HobbyLite[],
  profile: MatchProfile,
  n = 30
): ScoredHobby[] {
  if (hobbies.length === 0) return [];

  const scored: ScoredHobby[] = hobbies.map((hobby) => ({
    hobby,
    score: computeMatchScore(hobby, profile),
  }));

  scored.sort((a, b) => b.score - a.score || a.hobby.id.localeCompare(b.hobby.id));

  const top = scored.filter((e) => e.score > 0).slice(0, n);
  if (top.length >= n) return top;

  const maxBudget = budgetThreshold(profile.budgetLevel);
  const topIds = new Set(top.map((e) => e.hobby.id));

  const budgetPadding = scored.filter((e) => {
    if (topIds.has(e.hobby.id) || e.score > 0) return false;
    const [, costMax] = parseCostRange(e.hobby.costText);
    return costMax <= maxBudget;
  });

  const result = [...top];
  for (const e of budgetPadding) {
    if (result.length >= n) break;
    result.push(e);
    topIds.add(e.hobby.id);
  }

  if (result.length < n) {
    for (const e of scored) {
      if (result.length >= n) break;
      if (!topIds.has(e.hobby.id)) result.push(e);
    }
  }

  return result;
}

// ── Jury output gate ────────────────────────────

export interface JuryPick {
  hobbyId: string;
  reason: string;
}

/** The "jury judges, never creates" gate: keeps only picks whose hobbyId
 *  exists in the candidate set, dedupes by id, trims reasons to 140 chars
 *  and drops picks with an empty reason. The caller decides whether the
 *  survivors are enough (≥4) to trust the jury. */
export function sanitizeJuryPicks(
  picks: unknown,
  candidateIds: Set<string>
): JuryPick[] {
  if (!Array.isArray(picks)) return [];

  const seen = new Set<string>();
  const valid: JuryPick[] = [];

  for (const pick of picks) {
    if (typeof pick !== "object" || pick === null) continue;
    const hobbyId = (pick as Record<string, unknown>).hobbyId;
    const reason = (pick as Record<string, unknown>).reason;
    if (typeof hobbyId !== "string" || typeof reason !== "string") continue;
    if (!candidateIds.has(hobbyId) || seen.has(hobbyId)) continue;

    const trimmed = reason.trim().slice(0, 140);
    if (trimmed.length === 0) continue;

    seen.add(hobbyId);
    valid.push({ hobbyId, reason: trimmed });
  }

  return valid;
}
