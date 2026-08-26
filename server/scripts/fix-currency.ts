/**
 * fix-currency.ts — one-time sweep: CHF → $ across all catalog content.
 *
 * The catalog was authored for the Swiss market; this neutralizes it for a
 * global launch. Values stay 1:1 (Swiss estimates read slightly conservative
 * globally, which is honest for "cost to start" guidance).
 *
 * Usage:
 *   npx ts-node scripts/fix-currency.ts --dry-run    # diff table, writes nothing
 *   npx ts-node scripts/fix-currency.ts --execute    # apply to the database
 */
import "dotenv/config";
import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

/** CHF followed by a number → $number; standalone CHF → USD. */
export function neutralize(text: string): string {
  return text.replace(/CHF\s*(\d)/g, "$$$1").replace(/CHF/g, "USD");
}

const hasChf = (v: string | string[] | null | undefined): boolean => {
  if (v == null) return false;
  return Array.isArray(v) ? v.some((s) => /CHF/.test(s)) : /CHF/.test(v);
};

interface Change {
  table: string;
  id: string;
  field: string;
  before: string;
  after: string;
}

const changes: Change[] = [];

function sweepField(
  table: string,
  id: string,
  field: string,
  value: string | null | undefined,
): string | undefined {
  if (value == null || !/CHF/.test(value)) return undefined;
  const after = neutralize(value);
  changes.push({ table, id, field, before: value, after });
  return after;
}

function sweepArray(
  table: string,
  id: string,
  field: string,
  values: string[],
): string[] | undefined {
  if (!values.some((v) => /CHF/.test(v))) return undefined;
  const after = values.map(neutralize);
  changes.push({
    table,
    id,
    field,
    before: values.filter((v) => /CHF/.test(v)).join(" | "),
    after: after.filter((_, i) => /CHF/.test(values[i])).join(" | "),
  });
  return after;
}

async function main() {
  const execute = process.argv.includes("--execute");
  if (!execute && !process.argv.includes("--dry-run")) {
    console.log("No mode flag given — defaulting to --dry-run.\n");
  }

  const totals: Record<string, number> = {};
  const bump = (table: string) => {
    totals[table] = (totals[table] ?? 0) + 1;
  };

  // ── Hobby: costText, whyLove, difficultyExplain, pitfalls[] ──
  for (const h of await prisma.hobby.findMany()) {
    const data: Record<string, unknown> = {};
    const f1 = sweepField("Hobby", h.id, "costText", h.costText);
    const f2 = sweepField("Hobby", h.id, "whyLove", h.whyLove);
    const f3 = sweepField("Hobby", h.id, "difficultyExplain", h.difficultyExplain);
    const f4 = sweepArray("Hobby", h.id, "pitfalls", h.pitfalls);
    if (f1) data.costText = f1;
    if (f2) data.whyLove = f2;
    if (f3) data.difficultyExplain = f3;
    if (f4) data.pitfalls = f4;
    if (Object.keys(data).length) {
      bump("Hobby");
      if (execute) await prisma.hobby.update({ where: { id: h.id }, data });
    }
  }

  // ── RoadmapStep: description, coachTip, completionMessage ──
  for (const s of await prisma.roadmapStep.findMany()) {
    const data: Record<string, unknown> = {};
    const f1 = sweepField("RoadmapStep", s.id, "description", s.description);
    const f2 = sweepField("RoadmapStep", s.id, "coachTip", s.coachTip);
    const f3 = sweepField("RoadmapStep", s.id, "completionMessage", s.completionMessage);
    if (f1) data.description = f1;
    if (f2) data.coachTip = f2;
    if (f3) data.completionMessage = f3;
    if (Object.keys(data).length) {
      bump("RoadmapStep");
      if (execute) await prisma.roadmapStep.update({ where: { id: s.id }, data });
    }
  }

  // ── KitItem: description ──
  for (const k of await prisma.kitItem.findMany()) {
    const f1 = sweepField("KitItem", k.id, "description", k.description);
    if (f1) {
      bump("KitItem");
      if (execute) {
        await prisma.kitItem.update({ where: { id: k.id }, data: { description: f1 } });
      }
    }
  }

  // ── CostBreakdown: tips[] ──
  for (const c of await prisma.costBreakdown.findMany()) {
    const f1 = sweepArray("CostBreakdown", c.id, "tips", c.tips);
    if (f1) {
      bump("CostBreakdown");
      if (execute) {
        await prisma.costBreakdown.update({ where: { id: c.id }, data: { tips: f1 } });
      }
    }
  }

  // ── BudgetAlternative: diyOption, budgetOption, premiumOption, itemName ──
  for (const b of await prisma.budgetAlternative.findMany()) {
    const data: Record<string, unknown> = {};
    const f1 = sweepField("BudgetAlternative", b.id, "diyOption", b.diyOption);
    const f2 = sweepField("BudgetAlternative", b.id, "budgetOption", b.budgetOption);
    const f3 = sweepField("BudgetAlternative", b.id, "premiumOption", b.premiumOption);
    const f4 = sweepField("BudgetAlternative", b.id, "itemName", b.itemName);
    if (f1) data.diyOption = f1;
    if (f2) data.budgetOption = f2;
    if (f3) data.premiumOption = f3;
    if (f4) data.itemName = f4;
    if (Object.keys(data).length) {
      bump("BudgetAlternative");
      if (execute) await prisma.budgetAlternative.update({ where: { id: b.id }, data });
    }
  }

  // ── FaqItem: question, answer ──
  for (const f of await prisma.faqItem.findMany()) {
    const data: Record<string, unknown> = {};
    const f1 = sweepField("FaqItem", f.id, "question", f.question);
    const f2 = sweepField("FaqItem", f.id, "answer", f.answer);
    if (f1) data.question = f1;
    if (f2) data.answer = f2;
    if (Object.keys(data).length) {
      bump("FaqItem");
      if (execute) await prisma.faqItem.update({ where: { id: f.id }, data });
    }
  }

  // ── Report ──
  for (const c of changes) {
    console.log(`${c.table}[${c.id}].${c.field}:`);
    console.log(`  - ${c.before.slice(0, 120)}`);
    console.log(`  + ${c.after.slice(0, 120)}`);
  }
  console.log(`\n${execute ? "UPDATED" : "WOULD UPDATE"} rows per table:`);
  for (const [table, n] of Object.entries(totals)) console.log(`  ${table}: ${n}`);
  if (!Object.keys(totals).length) console.log("  (nothing to change — catalog is clean)");
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
