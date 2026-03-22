/**
 * Batch generate FAQs for all hobbies that don't have them yet.
 * Run: cd server && npx ts-node scripts/batch-generate-faqs.ts
 */

import { PrismaClient } from "@prisma/client";
import { generateFaqContent } from "../lib/ai_generator";

const prisma = new PrismaClient();

async function main() {
  // Find hobbies without FAQs
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
      const faqData = await generateFaqContent(hobby.title, hobby.categoryId);

      await Promise.all(
        faqData.map((item) =>
          prisma.faqItem.create({
            data: {
              hobbyId: hobby.id,
              question: item.question,
              answer: item.answer,
            },
          })
        )
      );

      success++;
      console.log(`✓ [${success}/${missing.length}] ${hobby.title} — ${faqData.length} FAQs`);

      // Rate limit: small delay between API calls
      await new Promise((r) => setTimeout(r, 500));
    } catch (err) {
      failed++;
      console.error(`✗ ${hobby.title}:`, err instanceof Error ? err.message : err);
    }
  }

  console.log(`\nDone: ${success} succeeded, ${failed} failed out of ${missing.length}`);
  await prisma.$disconnect();
}

main().catch((err) => {
  console.error("Fatal:", err);
  process.exit(1);
});
