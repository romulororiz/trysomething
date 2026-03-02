// ═══════════════════════════════════════════════════
//  Batch Hobby Generator
//  Pre-generates ~150 hobbies across 9 categories
//  Run: cd server && npx ts-node scripts/batch-generate.ts
// ═══════════════════════════════════════════════════

import { PrismaClient } from "@prisma/client";
import Anthropic from "@anthropic-ai/sdk";
import { validateOutput } from "../lib/content_guard";
import { fetchHobbyImage } from "../lib/unsplash";

const prisma = new PrismaClient();
const anthropic = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY });

const MODEL = "claude-haiku-4-5-20251001";
const DELAY_MS = 1500; // Rate limit courtesy

const CATEGORIES = [
  "creative", "outdoors", "fitness", "maker",
  "music", "food", "collecting", "mind", "social",
];

// ── Step 1: Get hobby titles per category ────────

async function getHobbyTitles(category: string): Promise<string[]> {
  const response = await anthropic.messages.create({
    model: MODEL,
    max_tokens: 1000,
    system: `You are a hobby expert. Return ONLY a JSON array of hobby title strings. No markdown, no explanation.`,
    messages: [
      {
        role: "user",
        content: `List 17 real, popular hobbies in the "${category}" category that a beginner could start. Include a mix of well-known and interesting niche hobbies. Return as a JSON array of strings.`,
      },
    ],
  });

  const text = response.content[0].type === "text" ? response.content[0].text : "";
  const cleaned = text.replace(/^```(?:json)?\s*/m, "").replace(/\s*```\s*$/m, "").trim();
  return JSON.parse(cleaned);
}

// ── Step 2: Generate full hobby content ──────────

async function generateHobby(title: string, category: string): Promise<Record<string, unknown> | null> {
  const PROMPT = `You are a hobby expert for the app "TrySomething". Generate structured JSON for a hobby.

RULES:
- The hobby must be a real, legal, safe activity that anyone could reasonably start
- Use Swiss Francs (CHF) for costs
- Be practical and encouraging
- Respond with ONLY valid JSON, no markdown fences

The category for this hobby is: ${category}

JSON SCHEMA:
{
  "title": "string (2-80 chars)",
  "hook": "string (max 150 chars, punchy tagline)",
  "categoryId": "${category}",
  "tags": ["2-5 descriptive tags"],
  "costText": "string (e.g. 'CHF 20–80')",
  "timeText": "string (e.g. '2h/week')",
  "difficultyText": "Easy | Moderate | Hard",
  "whyLove": "string (2-3 sentences: why people love this)",
  "difficultyExplain": "string (1-2 sentences: honest difficulty + encouragement)",
  "pitfalls": ["2-4 practical beginner mistakes"],
  "kitItems": [
    { "name": "string", "description": "string (1 sentence)", "cost": number, "isOptional": boolean }
  ],
  "roadmapSteps": [
    { "title": "string", "description": "string (1-2 sentences)", "estimatedMinutes": number (15-240), "milestone": "string or null" }
  ]
}

REQUIREMENTS: 2-6 kit items, 3-7 roadmap steps, realistic Swiss prices.`;

  try {
    const response = await anthropic.messages.create({
      model: MODEL,
      max_tokens: 2000,
      system: PROMPT,
      messages: [
        { role: "user", content: `Generate a complete hobby profile for: "${title}"` },
      ],
    });

    const text = response.content[0].type === "text" ? response.content[0].text : "";
    const cleaned = text.replace(/^```(?:json)?\s*/m, "").replace(/\s*```\s*$/m, "").trim();
    return JSON.parse(cleaned);
  } catch (err) {
    console.error(`  ✗ Failed to generate content for "${title}":`, err);
    return null;
  }
}

// ── Step 3: Generate tier-2 content ─────────────

async function generateFaq(title: string, category: string): Promise<{ question: string; answer: string }[]> {
  try {
    const response = await anthropic.messages.create({
      model: MODEL,
      max_tokens: 1500,
      system: `Generate 5 beginner FAQ items. Respond with ONLY a JSON array: [{"question":"...","answer":"..."}]`,
      messages: [
        { role: "user", content: `FAQ for "${title}" (${category})` },
      ],
    });
    const text = response.content[0].type === "text" ? response.content[0].text : "";
    return JSON.parse(text.replace(/^```(?:json)?\s*/m, "").replace(/\s*```\s*$/m, "").trim());
  } catch {
    return [];
  }
}

async function generateCost(title: string, kitItems: { name: string; cost: number }[]): Promise<{ starter: number; threeMonth: number; oneYear: number; tips: string[] } | null> {
  try {
    const kitSummary = kitItems.map((k) => `${k.name}: CHF ${k.cost}`).join(", ");
    const response = await anthropic.messages.create({
      model: MODEL,
      max_tokens: 800,
      system: `Generate cost projection for Switzerland. Respond with ONLY JSON: {"starter":num,"threeMonth":num,"oneYear":num,"tips":["..."]}`,
      messages: [
        { role: "user", content: `Cost for "${title}". Kit: ${kitSummary}` },
      ],
    });
    const text = response.content[0].type === "text" ? response.content[0].text : "";
    return JSON.parse(text.replace(/^```(?:json)?\s*/m, "").replace(/\s*```\s*$/m, "").trim());
  } catch {
    return null;
  }
}

async function generateBudget(title: string, kitItems: { name: string; cost: number }[]): Promise<{ itemName: string; diyOption: string; diyCost: number; budgetOption: string; budgetCost: number; premiumOption: string; premiumCost: number }[]> {
  try {
    const kitSummary = kitItems.map((k) => `${k.name}: CHF ${k.cost}`).join(", ");
    const response = await anthropic.messages.create({
      model: MODEL,
      max_tokens: 1500,
      system: `Generate budget alternatives. Respond with ONLY a JSON array: [{"itemName":"...","diyOption":"...","diyCost":num,"budgetOption":"...","budgetCost":num,"premiumOption":"...","premiumCost":num}]`,
      messages: [
        { role: "user", content: `Budget alternatives for "${title}" kit: ${kitSummary}` },
      ],
    });
    const text = response.content[0].type === "text" ? response.content[0].text : "";
    return JSON.parse(text.replace(/^```(?:json)?\s*/m, "").replace(/\s*```\s*$/m, "").trim());
  } catch {
    return [];
  }
}

// ── Step 4: Generate mood tags + seasonal picks ──

async function generateMoodAndSeasonal(title: string, category: string): Promise<{ moods: string[]; seasons: string[] }> {
  try {
    const response = await anthropic.messages.create({
      model: MODEL,
      max_tokens: 300,
      system: `Respond with ONLY JSON: {"moods":["1-3 mood tags from: energetic,chill,creative,focused,social,solo,meditative,adventurous"],"seasons":["1-4 seasons from: spring,summer,fall,winter"]}`,
      messages: [
        { role: "user", content: `Mood tags and best seasons for "${title}" (${category})` },
      ],
    });
    const text = response.content[0].type === "text" ? response.content[0].text : "";
    return JSON.parse(text.replace(/^```(?:json)?\s*/m, "").replace(/\s*```\s*$/m, "").trim());
  } catch {
    return { moods: [], seasons: [] };
  }
}

// ── Main ────────────────────────────────────────

async function main() {
  console.log("🏁 Batch hobby generation starting...\n");

  let totalCreated = 0;
  let totalSkipped = 0;
  let totalFailed = 0;
  let sortOrder = 100; // Start after seed hobbies

  for (const category of CATEGORIES) {
    console.log(`\n📁 Category: ${category}`);
    console.log("─".repeat(40));

    // Get hobby titles for this category
    const titles = await getHobbyTitles(category);
    console.log(`  Got ${titles.length} titles`);
    await delay(DELAY_MS);

    for (const title of titles) {
      // Skip if already exists
      const existing = await prisma.hobby.findFirst({
        where: { title: { equals: title, mode: "insensitive" } },
      });
      if (existing) {
        console.log(`  ⏭ "${title}" — already exists`);
        totalSkipped++;
        continue;
      }

      // Generate content
      console.log(`  ⚡ Generating "${title}"...`);
      const content = await generateHobby(title, category);
      if (!content) {
        totalFailed++;
        await delay(DELAY_MS);
        continue;
      }

      // Validate output
      const check = validateOutput(content);
      if (!check.ok) {
        console.error(`  ✗ Validation failed for "${title}": ${check.reason}`);
        totalFailed++;
        await delay(DELAY_MS);
        continue;
      }

      // Fetch image
      const imageUrl = await fetchHobbyImage(title, category);

      // Generate slug
      const slug = (content.title as string)
        .toLowerCase()
        .replace(/[^a-z0-9]+/g, "-")
        .replace(/^-|-$/g, "");
      const slugExists = await prisma.hobby.findUnique({ where: { id: slug } });
      const hobbyId = slugExists ? `${slug}-${Date.now().toString(36)}` : slug;

      try {
        // Create hobby with nested relations
        const hobby = await prisma.hobby.create({
          data: {
            id: hobbyId,
            title: content.title as string,
            hook: content.hook as string,
            categoryId: content.categoryId as string,
            imageUrl,
            tags: content.tags as string[],
            costText: content.costText as string,
            timeText: content.timeText as string,
            difficultyText: content.difficultyText as string,
            whyLove: content.whyLove as string,
            difficultyExplain: content.difficultyExplain as string,
            pitfalls: content.pitfalls as string[],
            isAiGenerated: true,
            generatedBy: null,
            sortOrder: sortOrder++,
            kitItems: {
              create: (content.kitItems as Record<string, unknown>[]).map((item, i) => ({
                name: item.name as string,
                description: item.description as string,
                cost: item.cost as number,
                isOptional: (item.isOptional as boolean) ?? false,
                sortOrder: i,
              })),
            },
            roadmapSteps: {
              create: (content.roadmapSteps as Record<string, unknown>[]).map((step, i) => ({
                id: `${hobbyId}-step-${i + 1}`,
                title: step.title as string,
                description: step.description as string,
                estimatedMinutes: step.estimatedMinutes as number,
                milestone: (step.milestone as string) ?? null,
                sortOrder: i,
              })),
            },
          },
          include: { kitItems: true },
        });

        console.log(`  ✓ Created "${hobby.title}" (${hobbyId})`);
        totalCreated++;

        // Tier 2: FAQ, cost, budget (non-blocking failures)
        await delay(DELAY_MS);
        const kitForCost = hobby.kitItems.map((k) => ({ name: k.name, cost: k.cost }));

        const [faqData, costData, budgetData, moodSeasonal] = await Promise.all([
          generateFaq(hobby.title, category),
          generateCost(hobby.title, kitForCost),
          generateBudget(hobby.title, kitForCost),
          generateMoodAndSeasonal(hobby.title, category),
        ]);

        // Save FAQ
        if (faqData.length > 0) {
          await Promise.all(
            faqData.map((item) =>
              prisma.faqItem.create({
                data: { hobbyId, question: item.question, answer: item.answer },
              })
            )
          );
          console.log(`    + ${faqData.length} FAQ items`);
        }

        // Save cost breakdown
        if (costData) {
          await prisma.costBreakdown.create({
            data: {
              hobbyId,
              starter: costData.starter,
              threeMonth: costData.threeMonth,
              oneYear: costData.oneYear,
              tips: costData.tips,
            },
          });
          console.log(`    + Cost breakdown`);
        }

        // Save budget alternatives
        if (budgetData.length > 0) {
          await Promise.all(
            budgetData.map((item, i) =>
              prisma.budgetAlternative.create({
                data: {
                  hobbyId,
                  itemName: item.itemName,
                  diyOption: item.diyOption,
                  diyCost: item.diyCost,
                  budgetOption: item.budgetOption,
                  budgetCost: item.budgetCost,
                  premiumOption: item.premiumOption,
                  premiumCost: item.premiumCost,
                  sortOrder: i,
                },
              })
            )
          );
          console.log(`    + ${budgetData.length} budget alternatives`);
        }

        // Save mood tags
        if (moodSeasonal.moods.length > 0) {
          await Promise.all(
            moodSeasonal.moods.map((mood) =>
              prisma.moodTag.upsert({
                where: { hobbyId_mood: { hobbyId, mood } },
                update: {},
                create: { hobbyId, mood },
              })
            )
          );
          console.log(`    + ${moodSeasonal.moods.length} mood tags`);
        }

        // Save seasonal picks
        if (moodSeasonal.seasons.length > 0) {
          await Promise.all(
            moodSeasonal.seasons.map((season) =>
              prisma.seasonalPick.upsert({
                where: { hobbyId_season: { hobbyId, season } },
                update: {},
                create: { hobbyId, season },
              })
            )
          );
          console.log(`    + ${moodSeasonal.seasons.length} seasonal picks`);
        }
      } catch (err) {
        console.error(`  ✗ DB error for "${title}":`, err);
        totalFailed++;
      }

      await delay(DELAY_MS);
    }
  }

  // Summary
  const totalHobbies = await prisma.hobby.count();
  console.log("\n" + "═".repeat(50));
  console.log(`✅ Batch complete!`);
  console.log(`   Created: ${totalCreated}`);
  console.log(`   Skipped: ${totalSkipped} (already existed)`);
  console.log(`   Failed:  ${totalFailed}`);
  console.log(`   Total hobbies in DB: ${totalHobbies}`);
  console.log("═".repeat(50));

  await prisma.$disconnect();
}

function delay(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

main().catch((err) => {
  console.error("Fatal error:", err);
  process.exit(1);
});
