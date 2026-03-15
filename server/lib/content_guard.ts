// ═══════════════════════════════════════════════════
//  Content Safety — Input/Output validation
//  Layer 1 (input) + Layer 3 (output) of 4-layer defense
// ═══════════════════════════════════════════════════

type ValidationResult = { ok: true } | { ok: false; reason: string };

// ── Blocklist ────────────────────────────────────

const BLOCKLIST: string[] = [
  // Weapons / violence
  "gun", "rifle", "firearm", "bomb", "explosive", "weapon", "knife fighting",
  "sword fighting", "martial weapon", "assassination", "killing", "murder",
  // Drugs / substances
  "drug", "cocaine", "heroin", "meth", "marijuana growing", "weed growing",
  "lsd", "mushroom growing psychedelic",
  // Illegal activity
  "hacking", "lockpicking", "theft", "stealing", "fraud", "counterfeit",
  "piracy", "smuggling", "gambling illegal",
  // NSFW / adult
  "porn", "pornography", "sex", "sexual", "nude", "erotic", "fetish",
  "escort", "stripper", "adult entertainment",
  // Self-harm
  "suicide", "self-harm", "cutting self", "anorexia", "bulimia",
  // Hate / extremism
  "supremacy", "extremism", "terrorism", "radicalization",
];

function containsBlockedTerm(text: string): string | null {
  const lower = text.toLowerCase();
  for (const term of BLOCKLIST) {
    // Match whole words/phrases (not partial — "knitting" shouldn't match "kni")
    const regex = new RegExp(`\\b${term.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")}\\b`, "i");
    if (regex.test(lower)) {
      return term;
    }
  }
  return null;
}

// ── Valid categories ────────────────────────────

const VALID_CATEGORIES = [
  "creative", "outdoors", "fitness", "maker",
  "music", "food", "collecting", "mind", "social",
];

// ── Input validation (Layer 1) ──────────────────

export function validateInput(query: string): ValidationResult {
  if (!query || typeof query !== "string") {
    return { ok: false, reason: "Query is required" };
  }

  const trimmed = query.trim();

  if (trimmed.length < 2) {
    return { ok: false, reason: "Query too short (min 2 characters)" };
  }

  if (trimmed.length > 60) {
    return { ok: false, reason: "Query too long (max 60 characters)" };
  }

  // Allow letters, numbers, spaces, hyphens, apostrophes, ampersands, commas, dots, slashes, parens
  if (!/^[a-zA-Z0-9\s\-'&,./()]+$/.test(trimmed)) {
    return { ok: false, reason: "Query contains invalid characters" };
  }

  const blocked = containsBlockedTerm(trimmed);
  if (blocked) {
    return { ok: false, reason: `Query contains prohibited content` };
  }

  return { ok: true };
}

// ── Output validation (Layer 3) ─────────────────

export function validateOutput(hobby: Record<string, unknown>): ValidationResult {
  // Required string fields
  const requiredStrings = [
    "title", "hook", "categoryId", "costText", "timeText",
    "difficultyText", "whyLove", "difficultyExplain",
  ];

  for (const field of requiredStrings) {
    if (typeof hobby[field] !== "string" || !(hobby[field] as string).trim()) {
      return { ok: false, reason: `Missing or empty field: ${field}` };
    }
  }

  // Title length
  if ((hobby.title as string).length > 80) {
    return { ok: false, reason: "Title too long (max 80 chars)" };
  }

  // Hook length
  if ((hobby.hook as string).length > 150) {
    return { ok: false, reason: "Hook too long (max 150 chars)" };
  }

  // Category must be valid
  if (!VALID_CATEGORIES.includes(hobby.categoryId as string)) {
    return { ok: false, reason: `Invalid category: ${hobby.categoryId}` };
  }

  // Tags array
  if (!Array.isArray(hobby.tags) || hobby.tags.length === 0) {
    return { ok: false, reason: "Tags must be a non-empty array" };
  }

  // Pitfalls array
  if (!Array.isArray(hobby.pitfalls) || hobby.pitfalls.length < 2 || hobby.pitfalls.length > 5) {
    return { ok: false, reason: "Pitfalls must have 2-5 items" };
  }

  // Kit items
  if (!Array.isArray(hobby.kitItems) || hobby.kitItems.length < 2 || hobby.kitItems.length > 6) {
    return { ok: false, reason: "Kit items must have 2-6 items" };
  }
  for (const item of hobby.kitItems as Record<string, unknown>[]) {
    if (typeof item.name !== "string" || typeof item.description !== "string") {
      return { ok: false, reason: "Kit item missing name or description" };
    }
    if (typeof item.cost !== "number" || item.cost < 0) {
      return { ok: false, reason: "Kit item cost must be non-negative" };
    }
  }

  // Roadmap steps
  if (!Array.isArray(hobby.roadmapSteps) || hobby.roadmapSteps.length < 3 || hobby.roadmapSteps.length > 7) {
    return { ok: false, reason: "Roadmap steps must have 3-7 items" };
  }
  for (const step of hobby.roadmapSteps as Record<string, unknown>[]) {
    if (typeof step.title !== "string" || typeof step.description !== "string") {
      return { ok: false, reason: "Roadmap step missing title or description" };
    }
    if (typeof step.estimatedMinutes !== "number" || step.estimatedMinutes < 15 || step.estimatedMinutes > 240) {
      return { ok: false, reason: "Step estimatedMinutes must be 15-240" };
    }
  }

  // Full-text re-scan of all generated text against blocklist
  const allText = [
    hobby.title, hobby.hook, hobby.whyLove, hobby.difficultyExplain,
    ...(hobby.pitfalls as string[]),
    ...(hobby.tags as string[]),
    ...(hobby.kitItems as Record<string, unknown>[]).map((k) => `${k.name} ${k.description}`),
    ...(hobby.roadmapSteps as Record<string, unknown>[]).map(
      (s) => `${s.title} ${s.description} ${s.coachTip ?? ''} ${s.completionMessage ?? ''}`
    ),
  ].join(" ");

  const blocked = containsBlockedTerm(allText);
  if (blocked) {
    return { ok: false, reason: "Generated content contains prohibited terms" };
  }

  return { ok: true };
}
