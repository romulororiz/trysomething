/**
 * Backfill coachTip + completionMessage for all existing roadmap steps.
 *
 * Usage:
 *   npx ts-node scripts/backfill-step-fields.ts --dry-run    # preview
 *   npx ts-node scripts/backfill-step-fields.ts               # write to DB
 *   npx ts-node scripts/backfill-step-fields.ts --hobby=ID    # single hobby
 *   npx ts-node scripts/backfill-step-fields.ts --force       # overwrite existing
 *
 * Requires: ANTHROPIC_API_KEY and DATABASE_URL in .env or environment.
 */

import * as fs from "fs";
import * as path from "path";
import { fileURLToPath } from "url";
import pg from "pg";
import Anthropic from "@anthropic-ai/sdk";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// ── Load .env ──
const envCandidates = [
  path.join(__dirname, "..", ".env"),
  path.join(process.cwd(), ".env"),
];
for (const envPath of envCandidates) {
  if (fs.existsSync(envPath)) {
    for (const rawLine of fs.readFileSync(envPath, "utf8").split("\n")) {
      const line = rawLine.trim();
      const match = line.match(/^(\w+)=["']?(.+?)["']?$/);
      if (match && !process.env[match[1]]) {
        process.env[match[1]] = match[2];
      }
    }
    break;
  }
}

// ── Parse flags ──
const args = process.argv.slice(2);
const DRY_RUN = args.includes("--dry-run");
const FORCE = args.includes("--force");
const hobbyFlag = args.find((a) => a.startsWith("--hobby="));
const HOBBY_ID = hobbyFlag?.split("=")[1] ?? null;

// ── Clients ──
const DATABASE_URL = process.env.DATABASE_URL;
if (!DATABASE_URL) {
  console.error("Missing DATABASE_URL");
  process.exit(1);
}

const ANTHROPIC_KEY = process.env.ANTHROPIC_API_KEY;
if (!ANTHROPIC_KEY) {
  console.error("Missing ANTHROPIC_API_KEY");
  process.exit(1);
}

const pool = new pg.Pool({ connectionString: DATABASE_URL, ssl: { rejectUnauthorized: false } });
const anthropic = new Anthropic({ apiKey: ANTHROPIC_KEY });
const MODEL = "claude-haiku-4-5-20251001"; // cheap + fast for backfill

const SYSTEM = `You generate a coach tip AND a completion message for each roadmap step of a hobby.

# RULES
1. Return ONLY a raw JSON array. No markdown. No backticks.
2. One entry per step, in the EXACT order provided.
3. Array length MUST equal the number of steps.

Per step:
- "coachTip": 1-2 sentences. Specific technique, common mistake, or insider trick for THIS step. Must differ from the step description. No generic motivation.
- "completionMessage": 1-2 sentences. Warm, specific reaction to completing THIS step. Reference what they did. Not "Great job!" or generic praise. Like a friend who does this hobby.

# SCHEMA
[
  { "coachTip": "<string>", "completionMessage": "<string>" }
]`;

type StepRow = {
  id: string;
  title: string;
  description: string;
  hobby_id: string;
  coach_tip: string | null;
  completion_message: string | null;
};

type HobbyGroup = {
  hobbyId: string;
  hobbyTitle: string;
  steps: StepRow[];
};

async function main() {
  console.log(`\n🔧 Backfill step fields${DRY_RUN ? " (DRY RUN)" : ""}${FORCE ? " (FORCE)" : ""}\n`);

  // Fetch hobbies + steps
  let query = `
    SELECT rs.id, rs.title, rs.description, rs."hobbyId" as hobby_id,
           rs."coachTip" as coach_tip, rs."completionMessage" as completion_message,
           h.title as hobby_title
    FROM "RoadmapStep" rs
    JOIN "Hobby" h ON h.id = rs."hobbyId"
  `;
  const params: string[] = [];
  if (HOBBY_ID) {
    query += ` WHERE rs."hobbyId" = $1`;
    params.push(HOBBY_ID);
  }
  query += ` ORDER BY rs."hobbyId", rs."sortOrder"`;

  const { rows } = await pool.query(query, params);
  console.log(`Found ${rows.length} total steps`);

  // Group by hobby
  const groups = new Map<string, HobbyGroup>();
  for (const row of rows) {
    if (!groups.has(row.hobby_id)) {
      groups.set(row.hobby_id, {
        hobbyId: row.hobby_id,
        hobbyTitle: row.hobby_title,
        steps: [],
      });
    }
    groups.get(row.hobby_id)!.steps.push(row);
  }

  // Filter: skip hobbies where ALL steps already have both fields (unless --force)
  const toProcess: HobbyGroup[] = [];
  for (const group of groups.values()) {
    const needsFill = FORCE || group.steps.some((s) => !s.coach_tip || !s.completion_message);
    if (needsFill) toProcess.push(group);
  }

  console.log(`${toProcess.length} hobbies need backfill (of ${groups.size} total)\n`);

  let processed = 0;
  let stepsUpdated = 0;
  let errors = 0;

  for (const group of toProcess) {
    processed++;
    const label = `[${processed}/${toProcess.length}] ${group.hobbyTitle} (${group.steps.length} steps)`;

    try {
      const userPrompt = [
        `Hobby: "${group.hobbyTitle}"`,
        `Steps:`,
        ...group.steps.map(
          (s, i) => `${i + 1}. "${s.title}" — ${s.description}`
        ),
      ].join("\n");

      const response = await anthropic.messages.create({
        model: MODEL,
        max_tokens: 1500,
        temperature: 0.3,
        system: SYSTEM,
        messages: [{ role: "user", content: userPrompt }],
      });

      const text =
        response.content[0].type === "text" ? response.content[0].text : "";
      const cleaned = text
        .replace(/^```(?:json)?\s*/m, "")
        .replace(/\s*```\s*$/m, "")
        .trim();

      const results: { coachTip: string; completionMessage: string }[] =
        JSON.parse(cleaned);

      if (results.length !== group.steps.length) {
        console.error(`  ❌ ${label} — expected ${group.steps.length} results, got ${results.length}`);
        errors++;
        continue;
      }

      if (DRY_RUN) {
        console.log(`  ✅ ${label}`);
        for (let i = 0; i < results.length; i++) {
          console.log(`     Step ${i + 1}: "${group.steps[i].title}"`);
          console.log(`       tip: ${results[i].coachTip}`);
          console.log(`       msg: ${results[i].completionMessage}`);
        }
      } else {
        // Write to DB
        for (let i = 0; i < results.length; i++) {
          const step = group.steps[i];
          const r = results[i];
          await pool.query(
            `UPDATE "RoadmapStep" SET "coachTip" = $1, "completionMessage" = $2 WHERE id = $3`,
            [r.coachTip, r.completionMessage, step.id]
          );
          stepsUpdated++;
        }
        console.log(`  ✅ ${label}`);
      }
    } catch (err: any) {
      console.error(`  ❌ ${label} — ${err.message}`);
      errors++;

      // Rate limit: wait and retry once
      if (err.status === 429) {
        console.log("     ⏳ Rate limited, waiting 30s...");
        await new Promise((r) => setTimeout(r, 30_000));
        processed--; // retry this hobby
        toProcess.splice(toProcess.indexOf(group), 0, group);
      }
    }

    // Small delay to avoid rate limits
    if (!DRY_RUN && processed < toProcess.length) {
      await new Promise((r) => setTimeout(r, 500));
    }
  }

  console.log(`\n✨ Done!`);
  console.log(`   Processed: ${processed} hobbies`);
  if (!DRY_RUN) console.log(`   Updated: ${stepsUpdated} steps`);
  if (errors > 0) console.log(`   Errors: ${errors}`);

  await pool.end();
}

main().catch((err) => {
  console.error("Fatal:", err);
  process.exit(1);
});
