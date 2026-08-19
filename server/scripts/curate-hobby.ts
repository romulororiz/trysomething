// ═══════════════════════════════════════════════════
//  Curation CLI — maintainer-only hobby generation
//
//  Generation is no longer an API surface. This tool is the ONLY
//  path that creates AI-generated catalog content, run locally by
//  the maintainer with ANTHROPIC_API_KEY + DATABASE_URL set.
//
//  Modes:
//    --new "<Title>" --category <categoryId>   Generate + insert ONE hobby
//                                              (tier 1 + tier 2, admission-tested)
//    --backfill-tier2                          Fill missing FAQ/cost/budget for
//                                              every hobby in the DB
//  Flags:
//    --dry-run                                 Print the plan, write nothing,
//                                              call no LLM
//    --hobby <id>                              Restrict --backfill-tier2 to one hobby
//
//  Run: cd server && npx ts-node scripts/curate-hobby.ts --backfill-tier2 --dry-run
// ═══════════════════════════════════════════════════

import "dotenv/config";
import { PrismaClient } from "@prisma/client";
import { validateOutput } from "../lib/content_guard";
import { fetchHobbyImage } from "../lib/unsplash";
import {
  generateHobbyContent,
  generateFaqContent,
  generateCostContent,
  generateBudgetContent,
} from "../lib/ai_generator";

const prisma = new PrismaClient();

const DELAY_MS = 1500; // Rate limit courtesy between LLM calls

// ── CLI args ────────────────────────────────────

interface CliArgs {
  newTitle: string | null;
  category: string | null;
  backfillTier2: boolean;
  dryRun: boolean;
  hobbyId: string | null;
}

function parseArgs(argv: string[]): CliArgs {
  const args: CliArgs = {
    newTitle: null,
    category: null,
    backfillTier2: false,
    dryRun: false,
    hobbyId: null,
  };

  for (let i = 0; i < argv.length; i++) {
    switch (argv[i]) {
      case "--new":
        args.newTitle = argv[++i] ?? null;
        break;
      case "--category":
        args.category = argv[++i] ?? null;
        break;
      case "--backfill-tier2":
        args.backfillTier2 = true;
        break;
      case "--dry-run":
        args.dryRun = true;
        break;
      case "--hobby":
        args.hobbyId = argv[++i] ?? null;
        break;
      default:
        console.error(`Unknown argument: ${argv[i]}`);
        printUsage();
        process.exit(1);
    }
  }
  return args;
}

function printUsage(): void {
  console.log(`Usage:
  npx ts-node scripts/curate-hobby.ts --new "<Title>" --category <categoryId> [--dry-run]
  npx ts-node scripts/curate-hobby.ts --backfill-tier2 [--dry-run] [--hobby <id>]`);
}

function delay(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

// ── Mode A: generate + insert one hobby ─────────

async function runNew(title: string, category: string, dryRun: boolean): Promise<void> {
  console.log(`🆕 Curating "${title}" (category: ${category})${dryRun ? " [dry run]" : ""}`);

  // Duplicate check on the requested title — abort before spending an LLM call
  const existing = await prisma.hobby.findFirst({
    where: { title: { equals: title, mode: "insensitive" } },
  });
  if (existing) {
    console.error(`✗ Aborted: "${existing.title}" already exists (${existing.id})`);
    process.exit(1);
  }

  if (dryRun) {
    console.log(`  Would generate tier-1 content, fetch a cover image, insert the hobby`);
    console.log(`  (isAiGenerated: true, generatedBy: "curation"), then backfill FAQ/cost/budget.`);
    console.log(`  Nothing written.`);
    return;
  }

  // Tier 1 content — validateHobbyOutput inside ai_generator already throws on
  // schema violations; validateOutput below is the blocklist re-scan (admission test)
  console.log(`  ⚡ Generating tier-1 content...`);
  const content = await generateHobbyContent(title);

  const check = validateOutput(content);
  if (!check.ok) {
    console.error(`✗ Admission test failed: ${check.reason}`);
    process.exit(1);
  }

  // The model canonicalizes titles — re-check the generated title for duplicates
  const generatedTitle = content.title as string;
  const postGenDupe = await prisma.hobby.findFirst({
    where: { title: { equals: generatedTitle, mode: "insensitive" } },
  });
  if (postGenDupe) {
    console.error(
      `✗ Aborted: generated title "${generatedTitle}" already exists (${postGenDupe.id})`
    );
    process.exit(1);
  }

  const imageUrl = await fetchHobbyImage(generatedTitle, content.categoryId as string);

  const slug = generatedTitle
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-|-$/g, "");
  const slugExists = await prisma.hobby.findUnique({ where: { id: slug } });
  const hobbyId = slugExists ? `${slug}-${Date.now().toString(36)}` : slug;

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
      generatedBy: "curation",
      sortOrder: 999,
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
          coachTip: (step.coachTip as string) ?? null,
          completionMessage: (step.completionMessage as string) ?? null,
          sortOrder: i,
        })),
      },
    },
    include: { kitItems: { select: { name: true, cost: true } } },
  });

  console.log(`  ✓ Created "${hobby.title}" (${hobbyId})`);

  // Tier 2 for the new hobby
  await delay(DELAY_MS);
  await backfillHobby(
    { id: hobby.id, title: hobby.title, categoryId: content.categoryId as string, kitItems: hobby.kitItems },
    false,
    "  "
  );
}

// ── Mode B: backfill tier-2 content ─────────────

interface BackfillTarget {
  id: string;
  title: string;
  categoryId: string;
  kitItems: { name: string; cost: number }[];
}

/** Fills missing FAQ/cost/budget for one hobby. Returns a status segment per piece. */
async function backfillHobby(
  hobby: BackfillTarget,
  dryRun: boolean,
  indent = ""
): Promise<string[]> {
  const segments: string[] = [];

  const [faqCount, costRow, budgetCount] = await Promise.all([
    prisma.faqItem.count({ where: { hobbyId: hobby.id } }),
    prisma.costBreakdown.findUnique({ where: { hobbyId: hobby.id }, select: { id: true } }),
    prisma.budgetAlternative.count({ where: { hobbyId: hobby.id } }),
  ]);

  // FAQ
  if (faqCount > 0) {
    segments.push("faq skip(exists)");
  } else if (dryRun) {
    segments.push("faq would-gen");
  } else {
    try {
      const faqData = await generateFaqContent(hobby.title, hobby.categoryId);
      await Promise.all(
        faqData.map((item) =>
          prisma.faqItem.create({
            data: { hobbyId: hobby.id, question: item.question, answer: item.answer },
          })
        )
      );
      segments.push("faq ✓");
    } catch (err) {
      segments.push("faq ✗");
      console.error(`${indent}✗ FAQ generation failed for "${hobby.title}":`, err);
    }
    await delay(DELAY_MS);
  }

  // Cost breakdown
  if (costRow) {
    segments.push("cost skip(exists)");
  } else if (dryRun) {
    segments.push("cost would-gen");
  } else {
    try {
      const costData = await generateCostContent(hobby.title, hobby.kitItems);
      await prisma.costBreakdown.create({
        data: {
          hobbyId: hobby.id,
          starter: costData.starter,
          threeMonth: costData.threeMonth,
          oneYear: costData.oneYear,
          tips: costData.tips,
        },
      });
      segments.push("cost ✓");
    } catch (err) {
      segments.push("cost ✗");
      console.error(`${indent}✗ Cost generation failed for "${hobby.title}":`, err);
    }
    await delay(DELAY_MS);
  }

  // Budget alternatives — pointless without kit items to price
  if (budgetCount > 0) {
    segments.push("budget skip(exists)");
  } else if (hobby.kitItems.length === 0) {
    segments.push("budget skip(no kit)");
  } else if (dryRun) {
    segments.push("budget would-gen");
  } else {
    try {
      const budgetData = await generateBudgetContent(hobby.title, hobby.kitItems);
      await Promise.all(
        budgetData.map((item, i) =>
          prisma.budgetAlternative.create({
            data: {
              hobbyId: hobby.id,
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
      segments.push("budget ✓");
    } catch (err) {
      segments.push("budget ✗");
      console.error(`${indent}✗ Budget generation failed for "${hobby.title}":`, err);
    }
    await delay(DELAY_MS);
  }

  return segments;
}

async function runBackfill(dryRun: boolean, onlyHobbyId: string | null): Promise<void> {
  const hobbies = await prisma.hobby.findMany({
    where: onlyHobbyId ? { id: onlyHobbyId } : undefined,
    orderBy: { title: "asc" },
    include: { kitItems: { select: { name: true, cost: true } } },
  });

  if (hobbies.length === 0) {
    console.error(onlyHobbyId ? `✗ Hobby not found: ${onlyHobbyId}` : "✗ No hobbies in DB");
    process.exit(1);
  }

  console.log(
    `🏁 Tier-2 backfill over ${hobbies.length} hobbies${dryRun ? " [dry run — nothing will be written]" : ""}\n`
  );

  const totals = { generated: 0, skipped: 0, failed: 0, wouldGen: 0 };

  for (let i = 0; i < hobbies.length; i++) {
    const h = hobbies[i];
    const segments = await backfillHobby(
      { id: h.id, title: h.title, categoryId: h.categoryId, kitItems: h.kitItems },
      dryRun
    );
    for (const s of segments) {
      if (s.endsWith("✓")) totals.generated++;
      else if (s.includes("skip")) totals.skipped++;
      else if (s.endsWith("✗")) totals.failed++;
      else if (s.includes("would-gen")) totals.wouldGen++;
    }
    console.log(`[${i + 1}/${hobbies.length}] ${h.title} — ${segments.join(" ")}`);
  }

  console.log("\n" + "═".repeat(50));
  if (dryRun) {
    console.log(`✅ Dry run complete — would generate ${totals.wouldGen} pieces, ${totals.skipped} already exist. Nothing written.`);
  } else {
    console.log(`✅ Backfill complete — generated: ${totals.generated}, skipped: ${totals.skipped}, failed: ${totals.failed}`);
  }
  console.log("═".repeat(50));
}

// ── Main ────────────────────────────────────────

async function main() {
  const args = parseArgs(process.argv.slice(2));

  if (!process.env.DATABASE_URL) {
    console.error("✗ DATABASE_URL is not set");
    process.exit(1);
  }
  if (!args.dryRun && !process.env.ANTHROPIC_API_KEY) {
    console.error("✗ ANTHROPIC_API_KEY is not set (required unless --dry-run)");
    process.exit(1);
  }

  if (args.newTitle) {
    if (!args.category) {
      console.error("✗ --new requires --category <categoryId>");
      printUsage();
      process.exit(1);
    }
    await runNew(args.newTitle, args.category, args.dryRun);
  } else if (args.backfillTier2) {
    await runBackfill(args.dryRun, args.hobbyId);
  } else {
    printUsage();
    process.exit(1);
  }

  await prisma.$disconnect();
}

main().catch(async (err) => {
  console.error("Fatal error:", err);
  await prisma.$disconnect().catch(() => {});
  process.exit(1);
});
