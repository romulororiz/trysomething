// ═══════════════════════════════════════════════════
//  Audit CLI — review user-generated hobbies
//
//  Read-only report over every hobby with isAiGenerated=true and
//  generatedBy != "curation" (legacy user-facing generation output),
//  plus two action modes to promote or unpublish audited hobbies.
//  Runs LOCALLY only, never in API routes. No LLM calls.
//
//  Modes:
//    (no args)                 Report: run all checks, print a summary
//                              table, write scripts/audit-report-<date>.md
//    --approve <id> [<id>...]  Set generatedBy: "curation" on each hobby
//    --archive <id> [<id>...]  Set isPublished: false on each hobby
//
//  Checks (report mode):
//    steps        3-7 roadmap steps
//    coach        every step has non-empty coachTip + completionMessage
//    kit          >= 2 kit items
//    tier2        >= 1 FAQ item, cost breakdown exists, >= 1 budget alternative
//    image        imageUrl non-empty and starts with https://
//    image-match  scripts/image-audit-cache.json verdict for the CURRENT
//                 imageUrl (informational when absent — "NOT AUDITED")
//    currency     no swept text field contains "CHF"
//    duplicate    normalized title not equal to / contained in / within
//                 Levenshtein distance 2 of any other catalog title
//
//  Verdict: all pass → APPROVE? · duplicate fails → ARCHIVE? · else → REVIEW
//
//  Run: cd server && npx ts-node scripts/audit-generated.ts
// ═══════════════════════════════════════════════════

import "dotenv/config";
import * as fs from "fs";
import * as path from "path";
import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

// ── Types ───────────────────────────────────────

type Mode = "report" | "approve" | "archive";

interface CliArgs {
  mode: Mode;
  ids: string[];
}

type CheckStatus = "PASS" | "FAIL" | "NOT AUDITED";

interface CheckResult {
  name: string;
  status: CheckStatus;
  detail: string;
}

type Verdict = "APPROVE?" | "ARCHIVE?" | "REVIEW";

interface AuditResult {
  id: string;
  title: string;
  categoryName: string;
  createdAt: Date;
  generatedBy: string | null;
  checks: CheckResult[];
  failedChecks: string[];
  verdict: Verdict;
}

/** Shape of the hobby rows the report needs (structural subset of the Prisma include). */
interface AuditHobby {
  id: string;
  title: string;
  imageUrl: string;
  costText: string;
  timeText: string;
  difficultyText: string;
  whyLove: string;
  difficultyExplain: string;
  pitfalls: string[];
  generatedBy: string | null;
  createdAt: Date;
  category: { name: string };
  roadmapSteps: {
    title: string;
    description: string;
    milestone: string | null;
    coachTip: string | null;
    completionMessage: string | null;
  }[];
  kitItems: { name: string; description: string }[];
  faqItems: { question: string; answer: string }[];
  costBreakdown: { tips: string[] } | null;
  budgetAlts: {
    itemName: string;
    diyOption: string;
    budgetOption: string;
    premiumOption: string;
  }[];
}

interface CatalogEntry {
  id: string;
  title: string;
}

/** One entry of scripts/image-audit-cache.json — fields treated as untrusted. */
interface ImageAuditEntry {
  imageUrl?: unknown;
  match?: unknown;
  confidence?: unknown;
  reason?: unknown;
}

type ImageAuditCache = Record<string, ImageAuditEntry>;

// ── CLI args ────────────────────────────────────

function parseArgs(argv: string[]): CliArgs {
  const args: CliArgs = { mode: "report", ids: [] };

  for (let i = 0; i < argv.length; i++) {
    switch (argv[i]) {
      case "--approve":
      case "--archive": {
        if (args.mode !== "report") {
          console.error("✗ Use only one of --approve / --archive per run");
          printUsage();
          process.exit(1);
        }
        args.mode = argv[i] === "--approve" ? "approve" : "archive";
        break;
      }
      default: {
        if (argv[i].startsWith("--")) {
          console.error(`Unknown argument: ${argv[i]}`);
          printUsage();
          process.exit(1);
        }
        if (args.mode === "report") {
          console.error(`✗ Unexpected id "${argv[i]}" — ids only follow --approve or --archive`);
          printUsage();
          process.exit(1);
        }
        args.ids.push(argv[i]);
      }
    }
  }

  if (args.mode !== "report" && args.ids.length === 0) {
    console.error(`✗ --${args.mode} requires at least one hobby id`);
    printUsage();
    process.exit(1);
  }
  return args;
}

function printUsage(): void {
  console.log(`Usage:
  npx ts-node scripts/audit-generated.ts                        # report (read-only)
  npx ts-node scripts/audit-generated.ts --approve <id> [<id>...]
  npx ts-node scripts/audit-generated.ts --archive <id> [<id>...]`);
}

// ── String helpers ──────────────────────────────

/**
 * Normalizes a title for duplicate comparison: lowercase, strip accents
 * (NFD + remove combining diacritics), strip punctuation, collapse spaces.
 */
function normalizeTitle(title: string): string {
  return title
    .toLowerCase()
    .normalize("NFD")
    .replace(/[̀-ͯ]/g, "")
    .replace(/[^a-z0-9\s]/g, " ")
    .replace(/\s+/g, " ")
    .trim();
}

/** Levenshtein edit distance (iterative two-row DP) — inputs are short titles. */
function levenshtein(a: string, b: string): number {
  if (a === b) return 0;
  if (a.length === 0) return b.length;
  if (b.length === 0) return a.length;

  let prev: number[] = Array.from({ length: b.length + 1 }, (_, i) => i);
  let curr: number[] = new Array(b.length + 1).fill(0);

  for (let i = 1; i <= a.length; i++) {
    curr[0] = i;
    for (let j = 1; j <= b.length; j++) {
      const cost = a[i - 1] === b[j - 1] ? 0 : 1;
      curr[j] = Math.min(prev[j] + 1, curr[j - 1] + 1, prev[j - 1] + cost);
    }
    [prev, curr] = [curr, prev];
  }
  return prev[b.length];
}

/** Truncates text to max chars, appending an ellipsis when cut. */
function truncate(text: string, max: number): string {
  return text.length <= max ? text : `${text.slice(0, max - 1)}…`;
}

/** Escapes pipes/newlines so free text is safe inside a markdown table cell. */
function mdCell(text: string): string {
  return text.replace(/\|/g, "\\|").replace(/\r?\n/g, " ");
}

// ── Image-audit cache ───────────────────────────

const IMAGE_CACHE_PATH = path.join(__dirname, "image-audit-cache.json");

/** Loads scripts/image-audit-cache.json; missing or malformed file → empty cache. */
function loadImageAuditCache(): ImageAuditCache {
  try {
    const raw = fs.readFileSync(IMAGE_CACHE_PATH, "utf8");
    const parsed: unknown = JSON.parse(raw);
    if (parsed && typeof parsed === "object" && !Array.isArray(parsed)) {
      return parsed as ImageAuditCache;
    }
    console.warn("⚠ image-audit-cache.json is not an object — image-match reported as NOT AUDITED");
  } catch {
    console.log("ℹ No readable image-audit-cache.json — image-match reported as NOT AUDITED");
  }
  return {};
}

// ── Checks ──────────────────────────────────────

/** Returns labels of swept text fields that contain "CHF". */
function findCurrencyHits(hobby: AuditHobby): string[] {
  const hits: string[] = [];
  const sweep = (label: string, value: string | null | undefined): void => {
    if (value && /CHF/.test(value)) hits.push(label);
  };

  sweep("costText", hobby.costText);
  sweep("whyLove", hobby.whyLove);
  sweep("difficultyExplain", hobby.difficultyExplain);
  hobby.pitfalls.forEach((p, i) => sweep(`pitfalls[${i}]`, p));
  hobby.roadmapSteps.forEach((s, i) => {
    sweep(`step[${i}].title`, s.title);
    sweep(`step[${i}].description`, s.description);
    sweep(`step[${i}].milestone`, s.milestone);
    sweep(`step[${i}].coachTip`, s.coachTip);
    sweep(`step[${i}].completionMessage`, s.completionMessage);
  });
  hobby.kitItems.forEach((k, i) => {
    sweep(`kit[${i}].name`, k.name);
    sweep(`kit[${i}].description`, k.description);
  });
  hobby.faqItems.forEach((f, i) => {
    sweep(`faq[${i}].question`, f.question);
    sweep(`faq[${i}].answer`, f.answer);
  });
  hobby.costBreakdown?.tips.forEach((t, i) => sweep(`costBreakdown.tips[${i}]`, t));
  hobby.budgetAlts.forEach((b, i) => {
    sweep(`budget[${i}].itemName`, b.itemName);
    sweep(`budget[${i}].diyOption`, b.diyOption);
    sweep(`budget[${i}].budgetOption`, b.budgetOption);
    sweep(`budget[${i}].premiumOption`, b.premiumOption);
  });

  return hits;
}

/**
 * Finds the first other catalog hobby whose normalized title is equal to,
 * contains / is contained in, or is within Levenshtein distance 2 of this
 * hobby's normalized title. Returns a description of the match, or null.
 */
function findDuplicate(hobby: AuditHobby, catalog: CatalogEntry[]): string | null {
  const norm = normalizeTitle(hobby.title);
  if (norm.length === 0) return null; // degenerate title — steps/other checks flag it

  for (const other of catalog) {
    if (other.id === hobby.id) continue;
    const otherNorm = normalizeTitle(other.title);
    if (otherNorm.length === 0) continue;

    if (norm === otherNorm) {
      return `identical to "${other.title}" (${other.id})`;
    }
    if (norm.includes(otherNorm) || otherNorm.includes(norm)) {
      return `contains / contained in "${other.title}" (${other.id})`;
    }
    if (Math.abs(norm.length - otherNorm.length) <= 2 && levenshtein(norm, otherNorm) <= 2) {
      return `within edit distance 2 of "${other.title}" (${other.id})`;
    }
  }
  return null;
}

/** Runs all audit checks for one hobby against the full catalog + image cache. */
function runChecks(
  hobby: AuditHobby,
  catalog: CatalogEntry[],
  imageCache: ImageAuditCache
): CheckResult[] {
  const checks: CheckResult[] = [];

  // steps: 3-7 roadmap steps
  const stepCount = hobby.roadmapSteps.length;
  checks.push({
    name: "steps",
    status: stepCount >= 3 && stepCount <= 7 ? "PASS" : "FAIL",
    detail: `${stepCount} roadmap steps (expected 3-7)`,
  });

  // coach: every step has non-empty coachTip AND completionMessage
  const missingCoach = hobby.roadmapSteps.filter(
    (s) => !s.coachTip?.trim() || !s.completionMessage?.trim()
  );
  if (stepCount === 0) {
    checks.push({ name: "coach", status: "FAIL", detail: "no roadmap steps to check" });
  } else if (missingCoach.length === 0) {
    checks.push({
      name: "coach",
      status: "PASS",
      detail: "all steps have coachTip + completionMessage",
    });
  } else {
    checks.push({
      name: "coach",
      status: "FAIL",
      detail: `${missingCoach.length} step(s) missing coachTip/completionMessage: ${missingCoach
        .map((s) => `"${s.title}"`)
        .join(", ")}`,
    });
  }

  // kit: >= 2 kit items
  checks.push({
    name: "kit",
    status: hobby.kitItems.length >= 2 ? "PASS" : "FAIL",
    detail: `${hobby.kitItems.length} kit items (expected >= 2)`,
  });

  // tier2: faq >= 1 AND costBreakdown exists AND budgetAlts >= 1
  const tier2Missing: string[] = [];
  if (hobby.faqItems.length < 1) tier2Missing.push("faq");
  if (!hobby.costBreakdown) tier2Missing.push("costBreakdown");
  if (hobby.budgetAlts.length < 1) tier2Missing.push("budgetAlternatives");
  checks.push({
    name: "tier2",
    status: tier2Missing.length === 0 ? "PASS" : "FAIL",
    detail:
      tier2Missing.length === 0
        ? `faq: ${hobby.faqItems.length}, cost: yes, budget: ${hobby.budgetAlts.length}`
        : `missing: ${tier2Missing.join(", ")}`,
  });

  // image: non-empty https:// URL
  const imageOk = hobby.imageUrl.trim().length > 0 && hobby.imageUrl.startsWith("https://");
  checks.push({
    name: "image",
    status: imageOk ? "PASS" : "FAIL",
    detail: imageOk ? "https:// imageUrl present" : `bad imageUrl: "${hobby.imageUrl || "(empty)"}"`,
  });

  // image-match: cache verdict for the CURRENT imageUrl (informational when absent)
  const entry = imageCache[hobby.id];
  if (!entry || typeof entry.imageUrl !== "string" || entry.imageUrl !== hobby.imageUrl) {
    checks.push({
      name: "image-match",
      status: "NOT AUDITED",
      detail: entry ? "cache entry is for a different imageUrl" : "no cache entry",
    });
  } else if (entry.match === true) {
    checks.push({
      name: "image-match",
      status: "PASS",
      detail: `image matches hobby (confidence: ${String(entry.confidence ?? "n/a")})`,
    });
  } else {
    checks.push({
      name: "image-match",
      status: "FAIL",
      detail: `image does not match hobby: ${String(entry.reason ?? "no reason given")}`,
    });
  }

  // currency: no swept text field contains "CHF"
  const currencyHits = findCurrencyHits(hobby);
  checks.push({
    name: "currency",
    status: currencyHits.length === 0 ? "PASS" : "FAIL",
    detail:
      currencyHits.length === 0 ? "no CHF references" : `CHF found in: ${currencyHits.join(", ")}`,
  });

  // duplicate: normalized-title collision against the ENTIRE catalog
  const dupe = findDuplicate(hobby, catalog);
  checks.push({
    name: "duplicate",
    status: dupe === null ? "PASS" : "FAIL",
    detail: dupe ?? "no similar title in catalog",
  });

  return checks;
}

/** Derives the suggested verdict — NOT AUDITED results are informational only. */
function deriveVerdict(checks: CheckResult[]): { verdict: Verdict; failedChecks: string[] } {
  const failedChecks = checks.filter((c) => c.status === "FAIL").map((c) => c.name);
  if (failedChecks.length === 0) return { verdict: "APPROVE?", failedChecks };
  if (failedChecks.includes("duplicate")) return { verdict: "ARCHIVE?", failedChecks };
  return { verdict: "REVIEW", failedChecks };
}

// ── Report mode ─────────────────────────────────

/** Renders the per-hobby markdown report body. */
function buildMarkdownReport(results: AuditResult[], dateStr: string): string {
  const counts = { "APPROVE?": 0, "ARCHIVE?": 0, REVIEW: 0 };
  for (const r of results) counts[r.verdict]++;

  const lines: string[] = [
    `# Generated Hobby Audit — ${dateStr}`,
    "",
    "> Read-only report produced by `scripts/audit-generated.ts`.",
    '> Scope: hobbies with `isAiGenerated = true` and `generatedBy != "curation"`.',
    "",
    `**${results.length} hobbies audited — APPROVE?: ${counts["APPROVE?"]} · ARCHIVE?: ${counts["ARCHIVE?"]} · REVIEW: ${counts.REVIEW}**`,
    "",
  ];

  for (const r of results) {
    lines.push(`## ${r.title} (\`${r.id}\`)`);
    lines.push("");
    lines.push(`- **Category:** ${r.categoryName}`);
    lines.push(`- **Created:** ${r.createdAt.toISOString()}`);
    lines.push(`- **Generated by:** ${r.generatedBy ?? "null"}`);
    lines.push(`- **Suggested verdict:** ${r.verdict}`);
    lines.push("");
    lines.push("| Check | Result | Detail |");
    lines.push("|-------|--------|--------|");
    for (const c of r.checks) {
      lines.push(`| ${c.name} | ${c.status} | ${mdCell(c.detail)} |`);
    }
    lines.push("");
  }

  return lines.join("\n");
}

/** Report mode: audit every non-curated generated hobby, print + write the report. */
async function runReport(): Promise<void> {
  const hobbies = await prisma.hobby.findMany({
    where: {
      isAiGenerated: true,
      OR: [{ generatedBy: null }, { generatedBy: { not: "curation" } }],
    },
    orderBy: { createdAt: "asc" },
    include: {
      category: { select: { name: true } },
      roadmapSteps: { orderBy: { sortOrder: "asc" } },
      kitItems: true,
      faqItems: true,
      costBreakdown: true,
      budgetAlts: true,
    },
  });

  if (hobbies.length === 0) {
    console.log("✅ No user-generated hobbies to audit (isAiGenerated + generatedBy != 'curation'). No report written.");
    return;
  }

  // Duplicate detection compares against the ENTIRE catalog, not just generated
  const catalog: CatalogEntry[] = await prisma.hobby.findMany({
    select: { id: true, title: true },
  });
  const imageCache = loadImageAuditCache();

  console.log(`🏁 Auditing ${hobbies.length} user-generated hobbies (catalog size: ${catalog.length})\n`);

  const results: AuditResult[] = hobbies.map((h) => {
    const checks = runChecks(h, catalog, imageCache);
    const { verdict, failedChecks } = deriveVerdict(checks);
    return {
      id: h.id,
      title: h.title,
      categoryName: h.category.name,
      createdAt: h.createdAt,
      generatedBy: h.generatedBy,
      checks,
      failedChecks,
      verdict,
    };
  });

  // Summary table
  const idW = 30;
  const titleW = 32;
  const verdictW = 9;
  console.log(
    `${"ID".padEnd(idW)}  ${"TITLE".padEnd(titleW)}  ${"VERDICT".padEnd(verdictW)}  FAILED CHECKS`
  );
  console.log("─".repeat(idW + titleW + verdictW + 20));
  for (const r of results) {
    console.log(
      `${truncate(r.id, idW).padEnd(idW)}  ${truncate(r.title, titleW).padEnd(titleW)}  ` +
        `${r.verdict.padEnd(verdictW)}  ${r.failedChecks.join(", ") || "—"}`
    );
  }

  const counts = { "APPROVE?": 0, "ARCHIVE?": 0, REVIEW: 0 };
  for (const r of results) counts[r.verdict]++;
  console.log("\n" + "═".repeat(50));
  console.log(
    `✅ ${results.length} audited — APPROVE?: ${counts["APPROVE?"]}, ARCHIVE?: ${counts["ARCHIVE?"]}, REVIEW: ${counts.REVIEW}`
  );
  console.log("═".repeat(50));

  // Markdown report
  const dateStr = new Date().toISOString().slice(0, 10);
  const reportPath = path.join(__dirname, `audit-report-${dateStr}.md`);
  fs.writeFileSync(reportPath, buildMarkdownReport(results, dateStr), "utf8");
  console.log(`\n📄 Report written: ${reportPath}`);
  console.log(`   Next: --approve <id> to promote, --archive <id> to unpublish.`);
}

// ── Action modes ────────────────────────────────

/**
 * Validates that every requested id exists. On any unknown id: prints a clear
 * error and exits 1 WITHOUT changing anything. Returns the found rows.
 */
async function requireAllIds(
  ids: string[]
): Promise<{ id: string; title: string; generatedBy: string | null }[]> {
  const found = await prisma.hobby.findMany({
    where: { id: { in: ids } },
    select: { id: true, title: true, generatedBy: true },
  });
  const foundIds = new Set(found.map((h) => h.id));
  const missing = ids.filter((id) => !foundIds.has(id));
  if (missing.length > 0) {
    console.error(`✗ Unknown hobby id(s): ${missing.join(", ")}`);
    console.error("  Nothing was changed. Fix the id list and re-run.");
    process.exit(1);
  }
  // Preserve the order the ids were passed in
  const byId = new Map(found.map((h) => [h.id, h]));
  return ids.map((id) => byId.get(id)!);
}

/** --approve: mark hobbies as curated (generatedBy: "curation"). */
async function runApprove(ids: string[]): Promise<void> {
  const hobbies = await requireAllIds(ids);
  console.log(`🏁 Approving ${hobbies.length} hobby(ies)\n`);

  for (const h of hobbies) {
    await prisma.hobby.update({
      where: { id: h.id },
      data: { generatedBy: "curation" },
    });
    console.log(`✓ Approved "${h.title}" (${h.id}) — generatedBy: ${h.generatedBy ?? "null"} → "curation"`);
  }
  console.log(`\n✅ Done — ${hobbies.length} hobby(ies) promoted to curation.`);
}

/** --archive: unpublish hobbies (isPublished: false) without deleting anything. */
async function runArchive(ids: string[]): Promise<void> {
  const hobbies = await requireAllIds(ids);
  console.log(`🏁 Archiving ${hobbies.length} hobby(ies)\n`);

  for (const h of hobbies) {
    await prisma.hobby.update({
      where: { id: h.id },
      data: { isPublished: false },
    });
    console.log(`✓ Archived "${h.title}" (${h.id}) — isPublished → false`);
  }
  console.log(`\n✅ Done — ${hobbies.length} hobby(ies) unpublished. No rows deleted.`);
}

// ── Main ────────────────────────────────────────

async function main() {
  const args = parseArgs(process.argv.slice(2));

  if (!process.env.DATABASE_URL) {
    console.error("✗ DATABASE_URL is not set");
    process.exit(1);
  }

  const uniqueIds = [...new Set(args.ids)];

  if (args.mode === "approve") {
    await runApprove(uniqueIds);
  } else if (args.mode === "archive") {
    await runArchive(uniqueIds);
  } else {
    await runReport();
  }

  await prisma.$disconnect();
}

main().catch(async (err) => {
  console.error("Fatal error:", err);
  await prisma.$disconnect().catch(() => {});
  process.exit(1);
});
