// ═══════════════════════════════════════════════════
//  AI Hobby Generator — Claude API integration
//  Tier 1: Core hobby content (on-demand, ~3-5s)
//  Tier 2: FAQ, cost, budget (lazy generation)
//
//  Model: claude-sonnet-4-20250514
//  All prompts hardened for zero-tolerance JSON output.
// ═══════════════════════════════════════════════════

import Anthropic from "@anthropic-ai/sdk";

let _client: Anthropic | null = null;
function getClient(): Anthropic {
  if (!_client) {
    _client = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY });
  }
  return _client;
}

const MODEL = "claude-sonnet-4-20250514";

// ═══════════════════════════════════════════════════
//  VALID CATEGORIES — single source of truth
// ═══════════════════════════════════════════════════

const VALID_CATEGORIES = [
  "creative",
  "outdoors",
  "fitness",
  "maker",
  "music",
  "food",
  "collecting",
  "mind",
  "social",
] as const;

// ═══════════════════════════════════════════════════
//  Tier 1: Core hobby content
// ═══════════════════════════════════════════════════

const TIER1_SYSTEM = `You are a structured data generator for the hobby discovery app "TrySomething".

# TASK
Given a hobby query, return a SINGLE JSON object describing that hobby.

# HARD RULES — VIOLATING ANY RULE MAKES YOUR OUTPUT INVALID
1. Return ONLY raw JSON. No markdown fences. No backticks. No explanation. No preamble. No trailing text.
2. Every string field must be non-empty after trimming.
3. The hobby MUST be a real, legal, safe, non-violent activity that an adult beginner in Switzerland could start.
4. If the query is nonsensical, too vague to identify a single hobby, or describes something dangerous/illegal/sexual/violent, return exactly: {"error":"invalid"}
5. All monetary values use Swiss Francs (CHF).
6. Tone: warm, encouraging, practical. Write as if helping a friend who is nervous about trying something new.

# EXACT JSON SCHEMA — every field is required, types are strict
{
  "title": "<string, 2-80 chars, proper English title case, the canonical hobby name — NOT the user's raw query>",
  "hook": "<string, max 150 chars, punchy one-liner that makes someone want to try it>",
  "categoryId": "<string, EXACTLY one of: creative | outdoors | fitness | maker | music | food | collecting | mind | social>",
  "tags": ["<2-5 lowercase single-word descriptive tags, e.g. relaxing, social, creative, technical, solo, physical, meditative, competitive>"],
  "costText": "<string, format 'CHF X–Y' or 'Free', realistic for Switzerland>",
  "timeText": "<string, format 'Xh/week', e.g. '2h/week'>",
  "difficultyText": "<string, EXACTLY one of: Easy | Medium | Hard>",
  "whyLove": "<string, 2-3 sentences, emotional appeal — why people fall in love with this hobby>",
  "difficultyExplain": "<string, 1-2 sentences, honest difficulty assessment with encouragement for beginners>",
  "pitfalls": ["<array of 2-4 strings, each a practical beginner mistake to avoid, phrased as actionable warnings>"],
  "kitItems": [
    {
      "name": "<string, item name>",
      "description": "<string, 1 sentence why you need it>",
      "cost": <integer, CHF, 0 or positive>,
      "isOptional": <boolean>
    }
  ],
  "roadmapSteps": [
    {
      "title": "<string, step title, imperative verb form, e.g. 'Make your first pinch pot'>",
      "description": "<string, 1-2 sentences, what to do and why>",
      "estimatedMinutes": <integer, range 15-240>,
      "milestone": "<string or null, achievement name if this step is a milestone, null otherwise>"
    }
  ]
}

# ARRAY CONSTRAINTS
- kitItems: minimum 2, maximum 6. At least 1 must have isOptional=false. Mix essential and optional.
- roadmapSteps: minimum 3, maximum 7. Progressive difficulty from day-1 to competent. First step must be achievable in a single session.
- pitfalls: minimum 2, maximum 4.
- tags: minimum 2, maximum 5.

# COST RULES
- Kit item costs must be realistic retail prices in Switzerland (generally 20-40% higher than Germany/US).
- costText summarizes the total starter cost range (essentials only, not optionals).
- A "Free" hobby must have all essential kit items at cost 0.

# CATEGORY SELECTION RULES
- creative: visual arts, crafts, design, writing
- outdoors: activities primarily done outside in nature
- fitness: physical exercise, sports, body movement
- maker: building, engineering, fabrication, repair
- music: playing instruments, production, theory
- food: cooking, baking, brewing, fermentation
- collecting: acquiring, curating, and organizing objects
- mind: intellectual pursuits, puzzles, learning, meditation
- social: group activities where the social element is the primary draw`;

const TIER1_USER = (query: string) =>
  `Generate a complete hobby profile for: "${query}"`;

export async function generateHobbyContent(
  query: string
): Promise<Record<string, unknown>> {
  const client = getClient();

  const response = await client.messages.create({
    model: MODEL,
    max_tokens: 2500,
    temperature: 0.3, // Low temperature for consistent structured output
    messages: [
      {
        role: "user",
        content: TIER1_USER(query),
      },
    ],
    system: TIER1_SYSTEM,
  });

  const text =
    response.content[0].type === "text" ? response.content[0].text : "";

  // Strip markdown code fences if model adds them despite instructions
  const cleaned = text
    .replace(/^```(?:json)?\s*/m, "")
    .replace(/\s*```\s*$/m, "")
    .trim();

  const parsed = JSON.parse(cleaned);

  // Check for explicit error response
  if (parsed.error === "invalid") {
    throw new Error("Model determined query is invalid or unsafe");
  }

  // ── Runtime validation: catch anything the model gets wrong ──
  validateHobbyOutput(parsed);

  return parsed;
}

// ═══════════════════════════════════════════════════
//  Runtime validation — zero trust on model output
// ═══════════════════════════════════════════════════

function validateHobbyOutput(data: Record<string, unknown>): void {
  const errors: string[] = [];

  // Required string fields
  const stringFields = [
    "title",
    "hook",
    "categoryId",
    "costText",
    "timeText",
    "difficultyText",
    "whyLove",
    "difficultyExplain",
  ];
  for (const field of stringFields) {
    if (typeof data[field] !== "string" || (data[field] as string).trim() === "") {
      errors.push(`Missing or empty string: ${field}`);
    }
  }

  // Category must be valid
  if (!VALID_CATEGORIES.includes(data.categoryId as typeof VALID_CATEGORIES[number])) {
    errors.push(`Invalid categoryId: "${data.categoryId}". Must be one of: ${VALID_CATEGORIES.join(", ")}`);
  }

  // Difficulty must be exact
  if (!["Easy", "Medium", "Hard"].includes(data.difficultyText as string)) {
    errors.push(`Invalid difficultyText: "${data.difficultyText}". Must be Easy, Medium, or Hard.`);
  }

  // Title length
  if (typeof data.title === "string" && (data.title.length < 2 || data.title.length > 80)) {
    errors.push(`Title length ${data.title.length} out of range [2, 80]`);
  }

  // Hook length
  if (typeof data.hook === "string" && data.hook.length > 150) {
    errors.push(`Hook length ${data.hook.length} exceeds 150 chars`);
  }

  // Tags
  const tags = data.tags;
  if (!Array.isArray(tags) || tags.length < 2 || tags.length > 5) {
    errors.push(`tags must be array of 2-5 items, got ${Array.isArray(tags) ? tags.length : typeof tags}`);
  }

  // Kit items
  const kit = data.kitItems;
  if (!Array.isArray(kit) || kit.length < 2 || kit.length > 6) {
    errors.push(`kitItems must be array of 2-6 items, got ${Array.isArray(kit) ? kit.length : typeof kit}`);
  } else {
    const hasRequired = kit.some((k: any) => k.isOptional === false);
    if (!hasRequired) {
      errors.push("kitItems must have at least 1 non-optional item");
    }
    for (let i = 0; i < kit.length; i++) {
      const item = kit[i] as any;
      if (typeof item.name !== "string" || !item.name.trim()) errors.push(`kitItems[${i}].name missing`);
      if (typeof item.description !== "string" || !item.description.trim()) errors.push(`kitItems[${i}].description missing`);
      if (typeof item.cost !== "number" || item.cost < 0 || !Number.isInteger(item.cost)) errors.push(`kitItems[${i}].cost must be non-negative integer`);
      if (typeof item.isOptional !== "boolean") errors.push(`kitItems[${i}].isOptional must be boolean`);
    }
  }

  // Roadmap steps
  const steps = data.roadmapSteps;
  if (!Array.isArray(steps) || steps.length < 3 || steps.length > 7) {
    errors.push(`roadmapSteps must be array of 3-7 items, got ${Array.isArray(steps) ? steps.length : typeof steps}`);
  } else {
    for (let i = 0; i < steps.length; i++) {
      const step = steps[i] as any;
      if (typeof step.title !== "string" || !step.title.trim()) errors.push(`roadmapSteps[${i}].title missing`);
      if (typeof step.description !== "string" || !step.description.trim()) errors.push(`roadmapSteps[${i}].description missing`);
      if (typeof step.estimatedMinutes !== "number" || step.estimatedMinutes < 15 || step.estimatedMinutes > 240) {
        errors.push(`roadmapSteps[${i}].estimatedMinutes must be 15-240, got ${step.estimatedMinutes}`);
      }
      if (step.milestone !== null && (typeof step.milestone !== "string" || !step.milestone.trim())) {
        errors.push(`roadmapSteps[${i}].milestone must be non-empty string or null`);
      }
    }
  }

  // Pitfalls
  const pitfalls = data.pitfalls;
  if (!Array.isArray(pitfalls) || pitfalls.length < 2 || pitfalls.length > 4) {
    errors.push(`pitfalls must be array of 2-4 items, got ${Array.isArray(pitfalls) ? pitfalls.length : typeof pitfalls}`);
  }

  if (errors.length > 0) {
    throw new Error(`Hobby validation failed:\n${errors.join("\n")}`);
  }
}

// ═══════════════════════════════════════════════════
//  Tier 2: FAQ
// ═══════════════════════════════════════════════════

const FAQ_SYSTEM = `You generate beginner FAQ items for hobbies.

# RULES
1. Return ONLY a raw JSON array. No markdown fences. No backticks. No explanation.
2. Exactly 5 items.
3. Questions must be what a total beginner would actually ask before starting.
4. Answers must be practical, concise (2-4 sentences), and encouraging.
5. Do not repeat information across answers.

# SCHEMA
[
  { "question": "<string>", "answer": "<string>" }
]`;

export async function generateFaqContent(
  hobbyTitle: string,
  category: string
): Promise<{ question: string; answer: string }[]> {
  const client = getClient();

  const response = await client.messages.create({
    model: MODEL,
    max_tokens: 1500,
    temperature: 0.3,
    messages: [
      {
        role: "user",
        content: `Generate 5 beginner FAQ items for the hobby "${hobbyTitle}" (category: ${category}).`,
      },
    ],
    system: FAQ_SYSTEM,
  });

  const text =
    response.content[0].type === "text" ? response.content[0].text : "";
  const cleaned = text
    .replace(/^```(?:json)?\s*/m, "")
    .replace(/\s*```\s*$/m, "")
    .trim();

  return JSON.parse(cleaned);
}

// ═══════════════════════════════════════════════════
//  Tier 2: Cost breakdown
// ═══════════════════════════════════════════════════

const COST_SYSTEM = `You generate cost projections for hobbies in Switzerland.

# RULES
1. Return ONLY a raw JSON object. No markdown fences. No backticks. No explanation.
2. All costs in CHF (Swiss Francs), integers only.
3. "starter" = total cost to begin (essentials only, first purchase).
4. "threeMonth" = cumulative total after 3 months of regular practice.
5. "oneYear" = cumulative total after 1 year.
6. Tips must be actionable money-saving advice specific to this hobby.
7. starter <= threeMonth <= oneYear.

# SCHEMA
{
  "starter": <integer>,
  "threeMonth": <integer>,
  "oneYear": <integer>,
  "tips": ["<2-4 strings, each a specific money-saving tip>"]
}`;

export async function generateCostContent(
  hobbyTitle: string,
  kitItems: { name: string; cost: number }[]
): Promise<{
  starter: number;
  threeMonth: number;
  oneYear: number;
  tips: string[];
}> {
  const client = getClient();

  const kitSummary = kitItems
    .map((k) => `${k.name}: CHF ${k.cost}`)
    .join(", ");

  const response = await client.messages.create({
    model: MODEL,
    max_tokens: 800,
    temperature: 0.2,
    messages: [
      {
        role: "user",
        content: `Generate cost projection for "${hobbyTitle}" in Switzerland. Known starter kit: ${kitSummary}`,
      },
    ],
    system: COST_SYSTEM,
  });

  const text =
    response.content[0].type === "text" ? response.content[0].text : "";
  const cleaned = text
    .replace(/^```(?:json)?\s*/m, "")
    .replace(/\s*```\s*$/m, "")
    .trim();

  return JSON.parse(cleaned);
}

// ═══════════════════════════════════════════════════
//  Tier 2: Budget alternatives
// ═══════════════════════════════════════════════════

const BUDGET_SYSTEM = `You generate budget alternatives for hobby starter kit items in Switzerland.

# RULES
1. Return ONLY a raw JSON array. No markdown fences. No backticks. No explanation.
2. One entry per kit item provided.
3. All costs in CHF (Swiss Francs), integers only.
4. diyCost <= budgetCost <= premiumCost for each item.
5. DIY option should be the cheapest possible alternative (including free/homemade).
6. Budget option should be a real affordable product.
7. Premium option should be the high-quality choice an enthusiast would buy.

# SCHEMA
[
  {
    "itemName": "<string, matches the provided kit item name>",
    "diyOption": "<string, cheapest/free alternative>",
    "diyCost": <integer>,
    "budgetOption": "<string, affordable real product>",
    "budgetCost": <integer>,
    "premiumOption": "<string, high-quality choice>",
    "premiumCost": <integer>
  }
]`;

export async function generateBudgetContent(
  hobbyTitle: string,
  kitItems: { name: string; cost: number }[]
): Promise<
  {
    itemName: string;
    diyOption: string;
    diyCost: number;
    budgetOption: string;
    budgetCost: number;
    premiumOption: string;
    premiumCost: number;
  }[]
> {
  const client = getClient();

  const kitSummary = kitItems
    .map((k) => `${k.name}: CHF ${k.cost}`)
    .join(", ");

  const response = await client.messages.create({
    model: MODEL,
    max_tokens: 1500,
    temperature: 0.2,
    messages: [
      {
        role: "user",
        content: `Generate budget alternatives for "${hobbyTitle}" kit items: ${kitSummary}`,
      },
    ],
    system: BUDGET_SYSTEM,
  });

  const text =
    response.content[0].type === "text" ? response.content[0].text : "";
  const cleaned = text
    .replace(/^```(?:json)?\s*/m, "")
    .replace(/\s*```\s*$/m, "")
    .trim();

  return JSON.parse(cleaned);
}
