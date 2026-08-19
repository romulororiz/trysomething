import { describe, it, expect } from "vitest";
import {
  parseCostRange,
  parseWeeklyHours,
  budgetThreshold,
  computeMatchScore,
  computeMatchReasons,
  selectCandidates,
  sanitizeJuryPicks,
  type HobbyLite,
  type MatchProfile,
} from "../lib/match_heuristic";

// Fixtures mirror real catalog shapes. Expected values are hand-computed
// against lib/core/hobby_match.dart — if a number here changes, the Dart
// and TS heuristics have drifted apart.

const pottery: HobbyLite = {
  id: "pottery",
  title: "Pottery",
  hook: "Get your hands dirty",
  tags: ["creative", "relaxing", "hands-on"],
  costText: "CHF 40–120",
  timeText: "2h/week",
  difficultyText: "Easy",
  categoryId: "creative",
};

const hikingFree: HobbyLite = {
  id: "hiking",
  title: "Hiking",
  hook: "Walk it off",
  tags: ["outdoors", "walking"],
  costText: "Free",
  timeText: "3h/week",
  difficultyText: "Easy",
  categoryId: "outdoors",
};

const meditation: HobbyLite = {
  id: "meditation",
  title: "Meditation",
  hook: "Sit with it",
  tags: ["meditative", "mindful", "solo"],
  costText: "CHF 0–30",
  timeText: "30 min/day",
  difficultyText: "Easy",
  categoryId: "mind",
};

const vibeHeavy: HobbyLite = {
  id: "dance",
  title: "Dance",
  hook: "Move",
  tags: ["creative", "social", "physical"],
  costText: "CHF 10–40",
  timeText: "1h/week",
  difficultyText: "Medium",
  categoryId: "fitness",
};

const expensive: HobbyLite = {
  id: "band",
  title: "Band",
  hook: "Loud",
  tags: ["performance"],
  costText: "CHF 300–800",
  timeText: "6h/week",
  difficultyText: "Hard",
  categoryId: "music",
};

const profileA: MatchProfile = {
  vibes: ["creative", "relaxing"],
  hoursPerWeek: 3,
  budgetLevel: 1,
  preferSocial: false,
};

describe("parseCostRange (Dart parity)", () => {
  it("parses en-dash ranges", () => {
    expect(parseCostRange("CHF 40–120")).toEqual([40, 120]);
  });

  it("parses hyphen ranges with spaces", () => {
    expect(parseCostRange("CHF 40 - 120")).toEqual([40, 120]);
  });

  it("parses single numbers", () => {
    expect(parseCostRange("$30")).toEqual([30, 30]);
  });

  it('quirk parity: "Free" falls back to [0, 9999] (no budget points)', () => {
    // Same as the Dart original — free hobbies do NOT pass the budget check.
    expect(parseCostRange("Free")).toEqual([0, 9999]);
  });
});

describe("parseWeeklyHours (Dart parity)", () => {
  it("parses h/week", () => {
    expect(parseWeeklyHours("2h/week")).toBe(2);
  });

  it("parses decimal hours", () => {
    expect(parseWeeklyHours("1.5h/week")).toBe(1.5);
  });

  it('quirk parity: "30 min/day" is unparseable and falls back to 99', () => {
    expect(parseWeeklyHours("30 min/day")).toBe(99);
  });
});

describe("budgetThreshold (Dart parity)", () => {
  it("maps levels like the Dart original", () => {
    expect(budgetThreshold(0)).toBe(50);
    expect(budgetThreshold(1)).toBe(150);
    expect(budgetThreshold(2)).toBe(999999);
    expect(budgetThreshold(3)).toBe(999999);
  });
});

describe("computeMatchScore (Dart parity)", () => {
  it("pottery vs creative+relaxing profile scores 14", () => {
    // vibes: creative +5, relaxing +5; budget 120<=150 +2; time 2<=3 +2; solo no.
    expect(computeMatchScore(pottery, profileA)).toBe(14);
  });

  it('free hobby loses the budget points ("Free" → costMax 9999)', () => {
    const profile: MatchProfile = {
      vibes: ["outdoors"],
      hoursPerWeek: 4,
      budgetLevel: 0,
      preferSocial: true,
    };
    // outdoors +5; budget 0 (quirk); time 3<=4 +2; social tag missing 0.
    expect(computeMatchScore(hikingFree, profile)).toBe(7);
  });

  it("min/day time string scores no time points", () => {
    const profile: MatchProfile = {
      vibes: ["meditative"],
      hoursPerWeek: 2,
      budgetLevel: 0,
      preferSocial: false,
    };
    // meditative +5; budget 30<=50 +2; time 99 (quirk) 0; solo +1.
    expect(computeMatchScore(meditation, profile)).toBe(8);
  });

  it("duplicated vibes count once (Set semantics like Dart)", () => {
    const dup: MatchProfile = { ...profileA, vibes: ["creative", "creative"] };
    const single: MatchProfile = { ...profileA, vibes: ["creative"] };
    expect(computeMatchScore(pottery, dup)).toBe(computeMatchScore(pottery, single));
  });

  it("vibe matches via category mapping, not just tags", () => {
    const profile: MatchProfile = {
      vibes: ["physical"],
      hoursPerWeek: 1,
      budgetLevel: 1,
      preferSocial: true,
    };
    // physical maps to fitness category +5; budget 40<=150 +2; time 1<=1 +2; social tag +1.
    expect(computeMatchScore(vibeHeavy, profile)).toBe(10);
  });
});

describe("computeMatchReasons (Dart parity)", () => {
  it("pottery reasons match the Dart texts and order", () => {
    expect(computeMatchReasons(pottery, profileA)).toEqual([
      "Starter cost: CHF 40–120",
      "Fits in 2h/week",
      "Matches your creative vibe",
    ]);
  });

  it("cheap hobby gets the free/under-30 phrasing and solo reason", () => {
    const profile: MatchProfile = {
      vibes: ["meditative"],
      hoursPerWeek: 2,
      budgetLevel: 0,
      preferSocial: false,
    };
    expect(computeMatchReasons(meditation, profile)).toEqual([
      "Starts free or under CHF 30",
      "Perfect for solo time",
      "Matches your meditative vibe",
    ]);
  });
});

describe("selectCandidates", () => {
  const all = [pottery, hikingFree, meditation, vibeHeavy, expensive];

  it("returns top n by score desc with deterministic id tie-break", () => {
    const result = selectCandidates(all, profileA, 3);
    expect(result).toHaveLength(3);
    expect(result[0].hobby.id).toBe("pottery"); // 14
    expect(result[0].score).toBe(14);
    for (let i = 1; i < result.length; i++) {
      expect(result[i].score).toBeLessThanOrEqual(result[i - 1].score);
    }
  });

  it("pads with zero-score budget-passing hobbies up to n", () => {
    const nobodyProfile: MatchProfile = {
      vibes: [],
      hoursPerWeek: 0,
      budgetLevel: 0,
      preferSocial: true,
    };
    // No vibe points anywhere; scores are tiny but some are 0.
    const result = selectCandidates(all, nobodyProfile, 5);
    expect(result).toHaveLength(5);
    const ids = result.map((e) => e.hobby.id);
    expect(new Set(ids).size).toBe(5); // no duplicates from padding
  });

  it("returns empty for an empty catalog", () => {
    expect(selectCandidates([], profileA, 30)).toEqual([]);
  });
});

describe("sanitizeJuryPicks (jury judges, never creates)", () => {
  const candidateIds = new Set(["pottery", "hiking", "meditation"]);

  it("discards invented hobbyIds", () => {
    const picks = [
      { hobbyId: "pottery", reason: "Fits your budget" },
      { hobbyId: "underwater-basket-weaving", reason: "Sounds fun" },
    ];
    const valid = sanitizeJuryPicks(picks, candidateIds);
    expect(valid).toHaveLength(1);
    expect(valid[0].hobbyId).toBe("pottery");
  });

  it("dedupes repeated ids and drops empty reasons", () => {
    const picks = [
      { hobbyId: "pottery", reason: "First" },
      { hobbyId: "pottery", reason: "Second" },
      { hobbyId: "hiking", reason: "   " },
    ];
    const valid = sanitizeJuryPicks(picks, candidateIds);
    expect(valid).toHaveLength(1);
    expect(valid[0].reason).toBe("First");
  });

  it("trims reasons to 140 chars", () => {
    const picks = [{ hobbyId: "hiking", reason: "x".repeat(200) }];
    const valid = sanitizeJuryPicks(picks, candidateIds);
    expect(valid[0].reason).toHaveLength(140);
  });

  it("returns empty for non-array and malformed picks", () => {
    expect(sanitizeJuryPicks(null, candidateIds)).toEqual([]);
    expect(sanitizeJuryPicks({ picks: [] }, candidateIds)).toEqual([]);
    expect(sanitizeJuryPicks([{ hobbyId: 42, reason: "x" }, "junk"], candidateIds)).toEqual([]);
  });
});
