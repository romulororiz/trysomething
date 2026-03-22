/**
 * Batch generate FAQs for all hobbies that don't have them yet.
 * Run: cd server && node scripts/batch-generate-faqs.mjs
 */

import { PrismaClient } from "@prisma/client";
import Anthropic from "@anthropic-ai/sdk";
import { config } from "dotenv";

config(); // Load .env

const prisma = new PrismaClient();
const anthropic = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY });

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

async function generateFaqs(title, category) {
  const response = await anthropic.messages.create({
    model: "claude-sonnet-4-6",
    max_tokens: 1500,
    temperature: 0.3,
    messages: [
      {
        role: "user",
        content: `Generate 5 beginner FAQ items for the hobby "${title}" (category: ${category}).`,
      },
    ],
    system: FAQ_SYSTEM,
  });

  const text = response.content[0].type === "text" ? response.content[0].text : "";
  const cleaned = text.replace(/^```(?:json)?\s*/m, "").replace(/\s*```\s*$/m, "").trim();
  return JSON.parse(cleaned);
}

async function main() {
  const allHobbies = await prisma.hobby.findMany({
    select: { id: true, title: true, categoryId: true },
    orderBy: { title: "asc" },
  });

  const hobbiesWithFaqs = await prisma.faqItem.findMany({
    select: { hobbyId: true },
    distinct: ["hobbyId"],
  });
  const faqHobbyIds = new Set(hobbiesWithFaqs.map((f) => f.hobbyId));
  const missing = allHobbies.filter((h) => !faqHobbyIds.has(h.id));

  console.log(`Found ${missing.length} hobbies without FAQs\n`);

  let success = 0;
  let failed = 0;

  for (const hobby of missing) {
    try {
      const faqData = await generateFaqs(hobby.title, hobby.categoryId);

      await Promise.all(
        faqData.map((item) =>
          prisma.faqItem.create({
            data: { hobbyId: hobby.id, question: item.question, answer: item.answer },
          })
        )
      );

      success++;
      console.log(`✓ [${success}/${missing.length}] ${hobby.title} — ${faqData.length} FAQs`);
      await new Promise((r) => setTimeout(r, 500));
    } catch (err) {
      failed++;
      console.error(`✗ ${hobby.title}:`, err.message || err);
    }
  }

  console.log(`\nDone: ${success} succeeded, ${failed} failed out of ${missing.length}`);
  await prisma.$disconnect();
}

main().catch((err) => {
  console.error("Fatal:", err);
  process.exit(1);
});
