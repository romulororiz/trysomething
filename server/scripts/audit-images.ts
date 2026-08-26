// ═══════════════════════════════════════════════════
//  Image Audit CLI — vision audit of hobby cover images
//
//  Verifies every hobby cover with Claude vision (does the image
//  actually depict the hobby?) and regenerates flagged covers with
//  GPT Image, uploading replacements to Vercel Blob. Runs LOCALLY
//  only by the maintainer — never wired into API routes.
//
//  Modes:
//    (default)                    Verify ALL hobby covers, write
//                                 scripts/image-audit-cache.json +
//                                 scripts/image-audit-report-<date>.md
//    --fix <id> [<id>...]         Regenerate covers for specific hobbies
//    --fix-flagged                Regenerate covers for every FLAGGED
//                                 hobby recorded in the cache
//  Flags:
//    --dry-run                    Verify: print verdicts, write no files.
//                                 Fix: print the prompts that WOULD be
//                                 sent, generate nothing.
//
//  Env:
//    DATABASE_URL                 always
//    ANTHROPIC_API_KEY            verify + fix (vision checks)
//    OPENAI_API_KEY               fix only (GPT Image generation)
//    BLOB_READ_WRITE_TOKEN        fix only (@vercel/blob put() reads it
//                                 from env automatically)
//
//  Run: cd server && npx ts-node scripts/audit-images.ts
// ═══════════════════════════════════════════════════

import "dotenv/config";
import * as fs from "fs";
import * as path from "path";
import { PrismaClient } from "@prisma/client";
import Anthropic from "@anthropic-ai/sdk";
import OpenAI from "openai";
import { put } from "@vercel/blob";

const prisma = new PrismaClient();

const VISION_MODEL = "claude-haiku-4-5-20251001";
const IMAGE_MODEL = "gpt-image-1";
const VISION_DELAY_MS = 1200; // Rate limit courtesy between vision calls
const FETCH_TIMEOUT_MS = 20_000;
const CACHE_PATH = path.join(__dirname, "image-audit-cache.json");

// ── Lazy API clients ────────────────────────────

let _anthropic: Anthropic | null = null;
function getAnthropic(): Anthropic {
  if (!_anthropic) {
    _anthropic = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY });
  }
  return _anthropic;
}

let _openai: OpenAI | null = null;
function getOpenAI(): OpenAI {
  if (!_openai) {
    _openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });
  }
  return _openai;
}

// ── Types ───────────────────────────────────────

type Confidence = "high" | "medium" | "low";
type Verdict = "OK" | "BORDERLINE" | "FLAGGED";
type ImageMediaType = "image/jpeg" | "image/png" | "image/gif" | "image/webp";

interface VisionResult {
  match: boolean;
  confidence: Confidence;
  reason: string;
}

interface CacheEntry extends VisionResult {
  imageUrl: string;
  checkedAt: string;
}

type AuditCache = Record<string, CacheEntry>;

interface HobbyRow {
  id: string;
  title: string;
  hook: string;
  categoryId: string;
  imageUrl: string;
}

interface DownloadedImage {
  data: string; // base64
  mediaType: ImageMediaType;
}

interface AuditRow {
  hobby: HobbyRow;
  verdict: Verdict;
  result: VisionResult;
  cached: boolean;
}

// ── CLI args ────────────────────────────────────

interface CliArgs {
  fixIds: string[];
  fixFlagged: boolean;
  dryRun: boolean;
}

function parseArgs(argv: string[]): CliArgs {
  const args: CliArgs = { fixIds: [], fixFlagged: false, dryRun: false };

  for (let i = 0; i < argv.length; i++) {
    switch (argv[i]) {
      case "--fix": {
        while (i + 1 < argv.length && !argv[i + 1].startsWith("--")) {
          args.fixIds.push(argv[++i]);
        }
        if (args.fixIds.length === 0) {
          console.error("✗ --fix requires at least one hobby id");
          printUsage();
          process.exit(1);
        }
        break;
      }
      case "--fix-flagged":
        args.fixFlagged = true;
        break;
      case "--dry-run":
        args.dryRun = true;
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
  npx ts-node scripts/audit-images.ts [--dry-run]
  npx ts-node scripts/audit-images.ts --fix <id> [<id>...] [--dry-run]
  npx ts-node scripts/audit-images.ts --fix-flagged [--dry-run]`);
}

function delay(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

/** Formats an unknown error into a one-line message. */
function errMsg(err: unknown): string {
  return err instanceof Error ? err.message : String(err);
}

// ── JSON extraction ─────────────────────────────

/**
 * Extracts and parses the JSON object in an AI response by slicing from
 * the first "{" to the last "}". Throws a descriptive error on failure.
 */
function extractJson<T = unknown>(text: string): T {
  const start = text.indexOf("{");
  const end = text.lastIndexOf("}");
  if (start === -1 || end <= start) {
    const preview = text.length > 200 ? text.slice(0, 200) + "..." : text;
    throw new Error(`extractJson: no JSON object in response. Preview: ${preview}`);
  }
  const sliced = text.slice(start, end + 1);
  try {
    return JSON.parse(sliced) as T;
  } catch (_err) {
    const preview = sliced.length > 200 ? sliced.slice(0, 200) + "..." : sliced;
    throw new Error(`extractJson: failed to parse AI response as JSON. Preview: ${preview}`);
  }
}

// ── Cache ───────────────────────────────────────

/** Loads the audit cache. Missing or corrupt file returns an empty cache. */
function loadCache(): AuditCache {
  try {
    const raw = fs.readFileSync(CACHE_PATH, "utf8");
    const parsed = JSON.parse(raw);
    if (parsed && typeof parsed === "object" && !Array.isArray(parsed)) {
      return parsed as AuditCache;
    }
  } catch (_err) {
    // Missing or corrupt cache — start fresh
  }
  return {};
}

/** Writes the cache to disk. Called after every verdict so an interrupt keeps progress. */
function saveCache(cache: AuditCache): void {
  fs.writeFileSync(CACHE_PATH, JSON.stringify(cache, null, 2));
}

// ── Image download ──────────────────────────────

/** Narrows a Content-Type header to an Anthropic-supported image media type. */
function normalizeMediaType(contentType: string | null): ImageMediaType {
  const base = (contentType ?? "").split(";")[0].trim().toLowerCase();
  if (base === "image/png" || base === "image/gif" || base === "image/webp" || base === "image/jpeg") {
    return base;
  }
  return "image/jpeg";
}

/**
 * Downloads an image with a 20s timeout and returns base64 bytes + media type.
 * Unsplash URLs get a size/quality hint appended to keep payloads small.
 */
async function downloadImage(url: string): Promise<DownloadedImage> {
  let fetchUrl = url;
  if (fetchUrl.includes("unsplash")) {
    fetchUrl += (fetchUrl.includes("?") ? "&" : "?") + "w=600&q=70";
  }

  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), FETCH_TIMEOUT_MS);
  try {
    const res = await fetch(fetchUrl, { signal: controller.signal });
    if (!res.ok) {
      throw new Error(`HTTP ${res.status} fetching ${fetchUrl}`);
    }
    const bytes = Buffer.from(await res.arrayBuffer());
    return {
      data: bytes.toString("base64"),
      mediaType: normalizeMediaType(res.headers.get("content-type")),
    };
  } finally {
    clearTimeout(timer);
  }
}

// ── Vision check ────────────────────────────────

/** Builds the vision prompt asking whether the image depicts the hobby. */
function buildVisionPrompt(hobby: Pick<HobbyRow, "title" | "hook" | "categoryId">): string {
  return (
    `This image is the cover for a hobby app entry.\n` +
    `Hobby: "${hobby.title}" — ${hobby.hook}. Category: ${hobby.categoryId}.\n` +
    `Does the image clearly and primarily depict this hobby, its unmistakable equipment, ` +
    `or its natural setting? A related-mood-only or generic image is NOT a match. ` +
    `Output ONLY raw JSON:\n` +
    `{"match": true|false, "confidence": "high"|"medium"|"low", "reason": "<one sentence>"}`
  );
}

/**
 * Runs the Claude vision check on one image and returns the parsed verdict.
 * Throws on API failure or unparseable output — callers decide how to react.
 */
async function visionCheck(
  hobby: Pick<HobbyRow, "title" | "hook" | "categoryId">,
  imageData: string,
  mediaType: ImageMediaType
): Promise<VisionResult> {
  const response = await getAnthropic().messages.create({
    model: VISION_MODEL,
    max_tokens: 150,
    messages: [
      {
        role: "user",
        content: [
          {
            type: "image",
            source: { type: "base64", media_type: mediaType, data: imageData },
          },
          { type: "text", text: buildVisionPrompt(hobby) },
        ],
      },
    ],
  });

  const text = response.content[0].type === "text" ? response.content[0].text : "";
  const parsed = extractJson<Partial<VisionResult>>(text);

  if (typeof parsed.match !== "boolean" || typeof parsed.reason !== "string") {
    throw new Error(`Vision response missing fields: ${JSON.stringify(parsed)}`);
  }
  const confidence: Confidence =
    parsed.confidence === "high" || parsed.confidence === "medium" || parsed.confidence === "low"
      ? parsed.confidence
      : "low";

  return { match: parsed.match, confidence, reason: parsed.reason };
}

/** Maps a vision result to an audit verdict. */
function verdictFor(result: VisionResult): Verdict {
  if (!result.match) return "FLAGGED";
  if (result.confidence === "low") return "BORDERLINE";
  return "OK";
}

// ── Mode A: verify all covers ───────────────────

/** Writes the markdown report and returns its path. */
function writeReport(rows: AuditRow[], visionErrors: number): string {
  const date = new Date().toISOString().slice(0, 10);
  const reportPath = path.join(__dirname, `image-audit-report-${date}.md`);

  const totals: Record<Verdict, number> = { OK: 0, BORDERLINE: 0, FLAGGED: 0 };
  let cachedCount = 0;
  for (const r of rows) {
    totals[r.verdict]++;
    if (r.cached) cachedCount++;
  }
  const flaggedIds = rows.filter((r) => r.verdict === "FLAGGED").map((r) => r.hobby.id);

  const lines: string[] = [
    `# Image Audit Report — ${date}`,
    ``,
    `- Audited: ${rows.length} hobbies (${cachedCount} from cache)`,
    `- OK: ${totals.OK}`,
    `- BORDERLINE: ${totals.BORDERLINE}`,
    `- FLAGGED: ${totals.FLAGGED}`,
    `- Vision errors (skipped, not cached): ${visionErrors}`,
    ``,
    `## Verdicts`,
    ``,
    `| Hobby | Verdict | Reason |`,
    `|---|---|---|`,
  ];

  for (const r of rows) {
    const reason = r.result.reason.replace(/\|/g, "\\|");
    const cachedTag = r.cached ? " (cached)" : "";
    lines.push(`| ${r.hobby.title} (\`${r.hobby.id}\`) | ${r.verdict}${cachedTag} | ${reason} |`);
  }

  if (flaggedIds.length > 0) {
    lines.push(
      ``,
      `## Fix command`,
      ``,
      `Regenerate all FLAGGED covers with:`,
      ``,
      "```",
      `npx ts-node scripts/audit-images.ts --fix ${flaggedIds.join(" ")}`,
      "```"
    );
  }

  fs.writeFileSync(reportPath, lines.join("\n") + "\n");
  return reportPath;
}

/** Audits every hobby cover, refreshing the cache incrementally. */
async function runVerify(dryRun: boolean): Promise<void> {
  const hobbies: HobbyRow[] = await prisma.hobby.findMany({
    select: { id: true, title: true, hook: true, categoryId: true, imageUrl: true },
    orderBy: { title: "asc" },
  });

  if (hobbies.length === 0) {
    console.error("✗ No hobbies in DB");
    process.exit(1);
  }

  const cache = loadCache();
  console.log(
    `🔍 Auditing ${hobbies.length} hobby covers${dryRun ? " [dry run — nothing will be written]" : ""}\n`
  );

  const rows: AuditRow[] = [];
  let visionErrors = 0;

  for (let i = 0; i < hobbies.length; i++) {
    const h = hobbies[i];
    const progress = `[${i + 1}/${hobbies.length}]`;

    // Skip when the cached verdict is for the exact same image URL
    const entry = cache[h.id];
    if (entry && entry.imageUrl === h.imageUrl) {
      const result: VisionResult = {
        match: entry.match,
        confidence: entry.confidence,
        reason: entry.reason,
      };
      const verdict = verdictFor(result);
      rows.push({ hobby: h, verdict, result, cached: true });
      console.log(`${progress} ${h.title} — ${verdict} (cached)`);
      continue;
    }

    // Download — failure means the cover itself is broken: FLAG it
    let image: DownloadedImage | null = null;
    try {
      image = await downloadImage(h.imageUrl);
    } catch (err) {
      console.error(`  ✗ Download failed for "${h.title}": ${errMsg(err)}`);
    }

    let result: VisionResult;
    if (!image) {
      result = { match: false, confidence: "high", reason: "unreachable" };
    } else {
      // Vision API failure is NOT a verdict — skip without caching so the
      // hobby is re-checked on the next run
      try {
        result = await visionCheck(h, image.data, image.mediaType);
      } catch (err) {
        visionErrors++;
        console.error(`  ✗ Vision check failed for "${h.title}": ${errMsg(err)}`);
        console.log(`${progress} ${h.title} — SKIPPED (vision error)`);
        await delay(VISION_DELAY_MS);
        continue;
      }
      await delay(VISION_DELAY_MS);
    }

    const verdict = verdictFor(result);
    rows.push({ hobby: h, verdict, result, cached: false });
    console.log(`${progress} ${h.title} — ${verdict}: ${result.reason}`);

    if (!dryRun) {
      cache[h.id] = { imageUrl: h.imageUrl, ...result, checkedAt: new Date().toISOString() };
      saveCache(cache);
    }
  }

  const totals: Record<Verdict, number> = { OK: 0, BORDERLINE: 0, FLAGGED: 0 };
  for (const r of rows) totals[r.verdict]++;
  const flaggedIds = rows.filter((r) => r.verdict === "FLAGGED").map((r) => r.hobby.id);

  console.log("\n" + "═".repeat(50));
  console.log(
    `✅ Audit complete — OK: ${totals.OK}, BORDERLINE: ${totals.BORDERLINE}, ` +
      `FLAGGED: ${totals.FLAGGED}${visionErrors > 0 ? `, vision errors: ${visionErrors}` : ""}`
  );
  if (dryRun) {
    console.log("Dry run — cache and report not written.");
  } else {
    const reportPath = writeReport(rows, visionErrors);
    console.log(`📄 Report: ${reportPath}`);
  }
  if (flaggedIds.length > 0) {
    console.log(`\nFix flagged covers with:`);
    console.log(`  npx ts-node scripts/audit-images.ts --fix ${flaggedIds.join(" ")}`);
  }
  console.log("═".repeat(50));
}

// ── Mode B: regenerate flagged covers ───────────

/** GPT Image prompt template for a hobby cover. */
export const buildImagePrompt = (title: string, categoryId: string, hook: string): string =>
  `Editorial cover photograph for the hobby "${title}" (${categoryId}). ${hook}. ` +
  `Photorealistic, warm cinematic lighting, moody and premium, shallow depth of field, ` +
  `the hobby's equipment or activity as the clear subject. No text, no watermarks, ` +
  `no logos, no readable faces.`;

/** Generates one cover with GPT Image and returns the PNG bytes. */
async function generateCover(prompt: string): Promise<Buffer> {
  const response = await getOpenAI().images.generate({
    model: IMAGE_MODEL,
    prompt,
    size: "1536x1024",
    quality: "medium",
  });

  const b64 = response.data?.[0]?.b64_json;
  if (!b64) {
    throw new Error(`${IMAGE_MODEL} returned no b64_json image data`);
  }
  return Buffer.from(b64, "base64");
}

/**
 * Regenerates one hobby cover: generate → vision-verify the buffer → upload
 * to Vercel Blob → update DB + cache. A failed vision check retries generation
 * ONCE; a second failure leaves the hobby untouched. Returns true on success.
 */
async function fixHobby(hobby: HobbyRow, cache: AuditCache, dryRun: boolean): Promise<boolean> {
  const prompt = buildImagePrompt(hobby.title, hobby.categoryId, hobby.hook);

  if (dryRun) {
    console.log(`  [dry run] Would send prompt:\n    ${prompt}`);
    return true;
  }

  for (let attempt = 1; attempt <= 2; attempt++) {
    console.log(`  ⚡ Generating cover (attempt ${attempt}/2)...`);
    const buffer = await generateCover(prompt);

    // Re-verify with the same Mode-A vision check — buffer directly, no download
    const result = await visionCheck(hobby, buffer.toString("base64"), "image/png");
    await delay(VISION_DELAY_MS);

    if (!result.match) {
      console.warn(`  ✗ Generated image failed vision check: ${result.reason}`);
      continue;
    }

    const blob = await put(`hobby-covers/${hobby.id}.png`, buffer, {
      access: "public",
      contentType: "image/png",
      addRandomSuffix: true,
    });

    await prisma.hobby.update({
      where: { id: hobby.id },
      data: { imageUrl: blob.url },
    });

    cache[hobby.id] = {
      imageUrl: blob.url,
      match: result.match,
      confidence: result.confidence,
      reason: result.reason,
      checkedAt: new Date().toISOString(),
    };
    saveCache(cache);

    console.log(`  ✓ ${hobby.id}: ${hobby.imageUrl} -> ${blob.url}`);
    return true;
  }

  console.error(`  ✗ ${hobby.id}: both generations failed the vision check — left untouched`);
  return false;
}

/** Fixes the requested hobbies (explicit ids or FLAGGED-from-cache). */
async function runFix(ids: string[], fromFlagged: boolean, dryRun: boolean): Promise<void> {
  const cache = loadCache();

  let targetIds = ids;
  if (fromFlagged) {
    targetIds = Object.entries(cache)
      .filter(([, entry]) => entry.match === false)
      .map(([id]) => id);
    if (targetIds.length === 0) {
      console.log("✅ No FLAGGED hobbies in cache — nothing to fix");
      return;
    }
  }

  const hobbies: HobbyRow[] = await prisma.hobby.findMany({
    where: { id: { in: targetIds } },
    select: { id: true, title: true, hook: true, categoryId: true, imageUrl: true },
    orderBy: { title: "asc" },
  });

  const found = new Set(hobbies.map((h) => h.id));
  for (const id of targetIds) {
    if (!found.has(id)) {
      console.warn(`⚠ Hobby not found in DB, skipping: ${id}`);
    }
  }
  if (hobbies.length === 0) {
    console.error("✗ None of the requested hobbies exist in the DB");
    process.exit(1);
  }

  console.log(
    `🛠 Fixing ${hobbies.length} covers${dryRun ? " [dry run — nothing will be generated]" : ""}`
  );

  const totals = { fixed: 0, failed: 0 };
  for (const h of hobbies) {
    console.log(`\n▶ ${h.title} (${h.id})`);
    try {
      const ok = await fixHobby(h, cache, dryRun);
      if (ok) totals.fixed++;
      else totals.failed++;
    } catch (err) {
      totals.failed++;
      console.error(`  ✗ Fix failed for "${h.title}":`, err);
    }
  }

  console.log("\n" + "═".repeat(50));
  if (dryRun) {
    console.log(`✅ Dry run complete — printed ${hobbies.length} prompts. Nothing generated.`);
  } else {
    console.log(`✅ Fix complete — fixed: ${totals.fixed}, failed: ${totals.failed}`);
  }
  console.log("═".repeat(50));
}

// ── Main ────────────────────────────────────────

async function main() {
  const args = parseArgs(process.argv.slice(2));

  if (args.fixIds.length > 0 && args.fixFlagged) {
    console.error("✗ Use either --fix <ids> or --fix-flagged, not both");
    process.exit(1);
  }

  if (!process.env.DATABASE_URL) {
    console.error("✗ DATABASE_URL is not set");
    process.exit(1);
  }

  const fixMode = args.fixIds.length > 0 || args.fixFlagged;

  if (fixMode) {
    // Fix dry-run only reads the DB and prints prompts — no keys needed
    if (!args.dryRun) {
      if (!process.env.OPENAI_API_KEY) {
        console.error("✗ OPENAI_API_KEY is not set (required for fix mode image generation)");
        process.exit(1);
      }
      if (!process.env.BLOB_READ_WRITE_TOKEN) {
        console.error(
          "✗ BLOB_READ_WRITE_TOKEN is not set (required for fix mode — @vercel/blob reads it from env)"
        );
        process.exit(1);
      }
      if (!process.env.ANTHROPIC_API_KEY) {
        console.error("✗ ANTHROPIC_API_KEY is not set (required to re-verify generated images)");
        process.exit(1);
      }
    }
    await runFix(args.fixIds, args.fixFlagged, args.dryRun);
  } else {
    // Verify mode always calls vision — even --dry-run produces real verdicts
    if (!process.env.ANTHROPIC_API_KEY) {
      console.error("✗ ANTHROPIC_API_KEY is not set (required for vision verification)");
      process.exit(1);
    }
    await runVerify(args.dryRun);
  }

  await prisma.$disconnect();
}

main().catch(async (err) => {
  console.error("Fatal error:", err);
  await prisma.$disconnect().catch(() => {});
  process.exit(1);
});
