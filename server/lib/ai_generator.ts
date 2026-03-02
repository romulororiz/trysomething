// ═══════════════════════════════════════════════════
//  AI Hobby Generator — Claude API integration
//  Tier 1: Core hobby content (on-demand, ~3-5s)
//  Tier 2: FAQ, cost, budget (lazy generation)
// ═══════════════════════════════════════════════════

import Anthropic from "@anthropic-ai/sdk";

let _client: Anthropic | null = null;
function getClient(): Anthropic {
  if (!_client) {
    _client = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY });
  }
  return _client;
}

const MODEL = "claude-haiku-4-5-20251001";

// ── Tier 1: Core hobby content ──────────────────

const TIER1_PROMPT = `You are a hobby expert for the app "TrySomething". Generate structured JSON for a hobby.

RULES:
- The hobby must be a real, legal, safe activity that anyone could reasonably start
- Use Swiss Francs (CHF) for costs
- Be practical and encouraging — this app helps beginners actually start
- Respond with ONLY valid JSON, no markdown fences, no extra text

CATEGORIES (pick the best fit):
creative, outdoors, fitness, maker, music, food, collecting, mind, social

JSON SCHEMA:
{
  "title": "string (2-80 chars, proper capitalized name)",
  "hook": "string (max 150 chars, punchy tagline that makes someone want to try it)",
  "categoryId": "string (one of the 9 categories above)",
  "tags": ["string array, 2-5 descriptive tags like 'relaxing', 'social', 'creative'"],
  "costText": "string (e.g. 'CHF 20–80')",
  "timeText": "string (e.g. '2h/week')",
  "difficultyText": "string (Easy, Moderate, or Hard)",
  "whyLove": "string (2-3 sentences: why people love this hobby, emotional appeal)",
  "difficultyExplain": "string (1-2 sentences: honest difficulty assessment with encouragement)",
  "pitfalls": ["2-4 practical beginner mistakes to avoid"],
  "kitItems": [
    {
      "name": "string (item name)",
      "description": "string (why you need it, 1 sentence)",
      "cost": number (CHF, integer, 0 or positive),
      "isOptional": boolean
    }
  ],
  "roadmapSteps": [
    {
      "title": "string (step title)",
      "description": "string (what to do, 1-2 sentences)",
      "estimatedMinutes": number (15-240),
      "milestone": "string or null (achievement name if this is a milestone)"
    }
  ]
}

REQUIREMENTS:
- 2-6 kit items (mix of essential and optional)
- 3-7 roadmap steps (progressive, from day-1 to competent)
- Costs should be realistic for Switzerland
- Write in a warm, encouraging tone`;

export async function generateHobbyContent(
  query: string
): Promise<Record<string, unknown>> {
  const client = getClient();

  const response = await client.messages.create({
    model: MODEL,
    max_tokens: 2000,
    messages: [
      {
        role: "user",
        content: `Generate a complete hobby profile for: "${query}"`,
      },
    ],
    system: TIER1_PROMPT,
  });

  const text =
    response.content[0].type === "text" ? response.content[0].text : "";

  // Strip markdown code fences if present
  const cleaned = text
    .replace(/^```(?:json)?\s*/m, "")
    .replace(/\s*```\s*$/m, "")
    .trim();

  return JSON.parse(cleaned);
}

// ── Tier 2: FAQ ─────────────────────────────────

const FAQ_PROMPT = `You are a hobby expert. Generate FAQ items for beginners.

RULES:
- Questions should be what a total beginner would actually ask
- Answers should be practical, concise, and encouraging
- Respond with ONLY a JSON array, no markdown fences

JSON SCHEMA:
[
  { "question": "string", "answer": "string" }
]

Generate exactly 5 FAQ items.`;

export async function generateFaqContent(
  hobbyTitle: string,
  category: string
): Promise<{ question: string; answer: string }[]> {
  const client = getClient();

  const response = await client.messages.create({
    model: MODEL,
    max_tokens: 1500,
    messages: [
      {
        role: "user",
        content: `Generate beginner FAQ for the hobby "${hobbyTitle}" (category: ${category})`,
      },
    ],
    system: FAQ_PROMPT,
  });

  const text =
    response.content[0].type === "text" ? response.content[0].text : "";
  const cleaned = text
    .replace(/^```(?:json)?\s*/m, "")
    .replace(/\s*```\s*$/m, "")
    .trim();

  return JSON.parse(cleaned);
}

// ── Tier 2: Cost breakdown ──────────────────────

const COST_PROMPT = `You are a hobby cost advisor for Switzerland. Generate a cost projection.

RULES:
- Use Swiss Francs (CHF), realistic prices
- Respond with ONLY valid JSON, no markdown fences

JSON SCHEMA:
{
  "starter": number (CHF to get started, integer),
  "threeMonth": number (CHF total after 3 months),
  "oneYear": number (CHF total after 1 year),
  "tips": ["2-4 money-saving tips"]
}`;

export async function generateCostContent(
  hobbyTitle: string,
  kitItems: { name: string; cost: number }[]
): Promise<{ starter: number; threeMonth: number; oneYear: number; tips: string[] }> {
  const client = getClient();

  const kitSummary = kitItems
    .map((k) => `${k.name}: CHF ${k.cost}`)
    .join(", ");

  const response = await client.messages.create({
    model: MODEL,
    max_tokens: 800,
    messages: [
      {
        role: "user",
        content: `Generate cost projection for "${hobbyTitle}". Known starter kit: ${kitSummary}`,
      },
    ],
    system: COST_PROMPT,
  });

  const text =
    response.content[0].type === "text" ? response.content[0].text : "";
  const cleaned = text
    .replace(/^```(?:json)?\s*/m, "")
    .replace(/\s*```\s*$/m, "")
    .trim();

  return JSON.parse(cleaned);
}

// ── Tier 2: Budget alternatives ─────────────────

const BUDGET_PROMPT = `You are a hobby budget advisor for Switzerland. Generate budget alternatives.

RULES:
- For each starter kit item, suggest DIY/budget/premium options with CHF costs
- Respond with ONLY a JSON array, no markdown fences

JSON SCHEMA:
[
  {
    "itemName": "string (kit item name)",
    "diyOption": "string (cheapest DIY option)",
    "diyCost": number (CHF integer),
    "budgetOption": "string (budget-friendly option)",
    "budgetCost": number (CHF integer),
    "premiumOption": "string (premium option)",
    "premiumCost": number (CHF integer)
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
    messages: [
      {
        role: "user",
        content: `Generate budget alternatives for "${hobbyTitle}" kit items: ${kitSummary}`,
      },
    ],
    system: BUDGET_PROMPT,
  });

  const text =
    response.content[0].type === "text" ? response.content[0].text : "";
  const cleaned = text
    .replace(/^```(?:json)?\s*/m, "")
    .replace(/\s*```\s*$/m, "")
    .trim();

  return JSON.parse(cleaned);
}
