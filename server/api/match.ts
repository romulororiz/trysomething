// ═══════════════════════════════════════════════════
//  POST /api/match — two-stage AI jury matching
//
//  Stage 1: deterministic heuristic (lib/match_heuristic) filters the
//  catalog to MATCH_CANDIDATES. Stage 2: Claude Haiku ranks the top
//  MATCH_RESULTS and writes one personal reason per pick. The jury only
//  JUDGES catalog hobbies — invented ids are discarded.
//
//  Every failure path (rate ceilings, timeout, LLM error, bad output)
//  degrades to the pure heuristic with HTTP 200. The only non-200
//  responses are 400/401/405 (+500 if the DB itself is down, where the
//  client falls back to its local heuristic).
// ═══════════════════════════════════════════════════

import type { VercelRequest, VercelResponse } from "@vercel/node";
import { createHash } from "crypto";
import Anthropic from "@anthropic-ai/sdk";
import { prisma } from "../lib/db";
import { requireAuth } from "../lib/auth";
import { handleCors, methodNotAllowed, errorResponse } from "../lib/middleware";
import { extractJson } from "../lib/ai_generator";
import {
  selectCandidates,
  computeMatchReasons,
  sanitizeJuryPicks,
  type MatchProfile,
  type ScoredHobby,
} from "../lib/match_heuristic";
import {
  MATCH_CANDIDATES,
  MATCH_RESULTS,
  MATCH_USER_DAILY_LIMIT,
  MATCH_GLOBAL_DAILY_LIMIT,
  MATCH_CACHE_TTL_DAYS,
} from "../lib/entitlement_constants";

const MATCH_MODEL = "claude-haiku-4-5-20251001";
const MATCH_MAX_TOKENS = 600;
const MATCH_TEMPERATURE = 0.4;
const JURY_TIMEOUT_MS = 10_000;
const HEURISTIC_CACHE_TTL_DAYS = 1;

let _anthropic: Anthropic | null = null;
function getAnthropicClient(): Anthropic {
  if (!_anthropic) {
    _anthropic = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY });
  }
  return _anthropic;
}

export const config = { maxDuration: 30 };

interface MatchResponseItem {
  hobbyId: string;
  rank: number;
  score: number;
  reason: string;
}

interface MatchResponse {
  source: "ai" | "heuristic";
  matches: MatchResponseItem[];
}

export default async function handler(req: VercelRequest, res: VercelResponse) {
  if (handleCors(req, res)) return;
  if (methodNotAllowed(req, res, ["POST"])) return;

  const userId = await requireAuth(req, res);
  if (!userId) return;

  try {
    // ── Profile: body, or stored UserPreference on empty body ──
    const profile = await resolveProfile(req.body, userId);
    if (profile === "invalid") {
      return errorResponse(res, 400, "Invalid match profile");
    }
    if (profile === null) {
      return errorResponse(res, 400, "No preferences found — complete onboarding first");
    }

    // ── profileHash: canonical JSON, global across users ──
    const profileHash = createHash("sha256")
      .update(
        JSON.stringify({
          v: [...profile.vibes].sort(),
          h: profile.hoursPerWeek,
          b: profile.budgetLevel,
          s: profile.preferSocial,
        })
      )
      .digest("hex");

    // ── Cache lookup ──
    const cached = await prisma.matchCache.findUnique({ where: { profileHash } });
    if (cached) {
      if (cached.expiresAt > new Date()) {
        return res.status(200).json(cached.resultJson);
      }
      await prisma.matchCache.delete({ where: { profileHash } }).catch(() => {});
    }

    // ── Load catalog (light select) + stage 1 ──
    const hobbies = await prisma.hobby.findMany({
      select: {
        id: true,
        title: true,
        hook: true,
        tags: true,
        costText: true,
        timeText: true,
        difficultyText: true,
        categoryId: true,
      },
    });

    const candidates = selectCandidates(hobbies, profile, MATCH_CANDIDATES);
    if (candidates.length === 0) {
      return res.status(200).json({ source: "heuristic", matches: [] });
    }

    // ── Heuristic fallback, used by every failure path below ──
    const fallback = buildHeuristicResponse(candidates, profile);

    const respondFallback = async (why: string) => {
      console.error(`[Match] Falling back to heuristic: ${why}`);
      await persistCache(profileHash, fallback, HEURISTIC_CACHE_TTL_DAYS);
      return res.status(200).json(fallback);
    };

    // ── Guard rails: per-user + global daily LLM ceilings ──
    const since = new Date(Date.now() - 24 * 60 * 60 * 1000);
    const [userCount, globalCount] = await Promise.all([
      prisma.generationLog.count({
        where: { userId, query: "match", status: "success", createdAt: { gte: since } },
      }),
      prisma.generationLog.count({
        where: { query: "match", status: "success", createdAt: { gte: since } },
      }),
    ]);

    if (userCount >= MATCH_USER_DAILY_LIMIT) {
      return respondFallback(`user daily limit (${userCount})`);
    }
    if (globalCount >= MATCH_GLOBAL_DAILY_LIMIT) {
      return respondFallback(`global daily ceiling (${globalCount})`);
    }

    // ── Stage 2: the jury ──
    try {
      const juryText = await callJury(profile, candidates);

      // The LLM call itself succeeded — count it against the ceilings
      // regardless of whether its output survives validation below.
      let logReason: string | null = null;

      const parsed = extractJson<Record<string, unknown>>(juryText);
      const candidateIds = new Set(candidates.map((c) => c.hobby.id));
      const valid = sanitizeJuryPicks(parsed.picks, candidateIds);

      if (valid.length < 4) {
        logReason = `jury output rejected (${valid.length} valid picks)`;
        await logMatch(userId, "success", logReason);
        return respondFallback(logReason);
      }

      await logMatch(userId, "success", null);

      const scoreById = new Map(candidates.map((c) => [c.hobby.id, c.score]));
      const response: MatchResponse = {
        source: "ai",
        matches: valid.slice(0, MATCH_RESULTS).map((pick, i) => ({
          hobbyId: pick.hobbyId,
          rank: i + 1,
          score: scoreById.get(pick.hobbyId) ?? 0,
          reason: pick.reason,
        })),
      };

      await persistCache(profileHash, response, MATCH_CACHE_TTL_DAYS);
      return res.status(200).json(response);
    } catch (err) {
      const message = err instanceof Error ? err.message : "Unknown jury error";
      logMatch(userId, "error", message).catch(() => {});
      return respondFallback(`jury error: ${message}`);
    }
  } catch (err) {
    // DB-level failure before a fallback could even be built — the client
    // has its own local heuristic for this case.
    console.error("[Match] Error:", err);
    return errorResponse(res, 500, "Matching temporarily unavailable");
  }
}

// ═══════════════════════════════════════════════════
//  Profile resolution + validation
// ═══════════════════════════════════════════════════

/** Returns the validated profile, null when no body and no stored
 *  preferences, or "invalid" when a provided body fails validation. */
async function resolveProfile(
  body: unknown,
  userId: string
): Promise<MatchProfile | null | "invalid"> {
  const isEmpty =
    body == null || (typeof body === "object" && Object.keys(body as object).length === 0);

  if (isEmpty) {
    const stored = await prisma.userPreference.findUnique({ where: { userId } });
    if (!stored) return null;
    return {
      vibes: stored.vibes,
      hoursPerWeek: stored.hoursPerWeek,
      budgetLevel: stored.budgetLevel,
      preferSocial: stored.preferSocial,
    };
  }

  const b = body as Record<string, unknown>;
  const { vibes, hoursPerWeek, budgetLevel, preferSocial } = b;

  if (
    !Array.isArray(vibes) ||
    vibes.length > 10 ||
    vibes.some((v) => typeof v !== "string" || v.length === 0 || v.length > 30)
  ) {
    return "invalid";
  }
  if (typeof hoursPerWeek !== "number" || hoursPerWeek < 0 || hoursPerWeek > 40) {
    return "invalid";
  }
  if (typeof budgetLevel !== "number" || !Number.isInteger(budgetLevel) || budgetLevel < 0 || budgetLevel > 3) {
    return "invalid";
  }
  if (typeof preferSocial !== "boolean") {
    return "invalid";
  }

  return { vibes: vibes as string[], hoursPerWeek, budgetLevel, preferSocial };
}

// ═══════════════════════════════════════════════════
//  Heuristic fallback response
// ═══════════════════════════════════════════════════

function buildHeuristicResponse(
  candidates: ScoredHobby[],
  profile: MatchProfile
): MatchResponse {
  return {
    source: "heuristic",
    matches: candidates.slice(0, MATCH_RESULTS).map((c, i) => {
      const reasons = computeMatchReasons(c.hobby, profile);
      // Zero-signal padding hobbies can produce no reasons — the hobby's
      // own hook is the honest one-liner in that case.
      const reason = reasons.length > 0 ? reasons.join(" · ") : c.hobby.hook;
      return { hobbyId: c.hobby.id, rank: i + 1, score: c.score, reason };
    }),
  };
}

// ═══════════════════════════════════════════════════
//  Jury call (Claude Haiku, 10s timeout)
// ═══════════════════════════════════════════════════

const JURY_SYSTEM = `You are the matching jury for a hobby app. You are given a user profile and a
numbered list of candidate hobbies from our catalog. Your job is to pick the
${MATCH_RESULTS} best hobbies FOR THIS SPECIFIC USER and explain each pick in one
personal, concrete sentence.

Rules:
- You may ONLY pick hobbyIds that appear in the candidate list. Never invent ids.
- Return EXACTLY ${MATCH_RESULTS} picks, best first.
- Each reason: max 140 characters, second person ("you"), concrete — reference
  their time, budget, vibes, or the hobby's nature. No generic praise, no emoji.
- Prefer variety across categories when scores are close.
- Output ONLY raw JSON, no markdown fences:
  {"picks":[{"hobbyId":"...","reason":"..."}]}`;

function budgetDescription(level: number): string {
  switch (level) {
    case 0:
      return "tight budget (under CHF 50 to start)";
    case 1:
      return "moderate budget (up to CHF 150 to start)";
    default:
      return "flexible budget (cost is not a concern)";
  }
}

async function callJury(profile: MatchProfile, candidates: ScoredHobby[]): Promise<string> {
  const profileLines = [
    `Vibes they picked: ${profile.vibes.length > 0 ? profile.vibes.join(", ") : "none"}`,
    `Time available: ${profile.hoursPerWeek}h/week`,
    `Budget: ${budgetDescription(profile.budgetLevel)}`,
    `Prefers: ${profile.preferSocial ? "social activities with others" : "solo activities"}`,
  ].join("\n");

  const candidateLines = candidates
    .map(
      (c) =>
        `${c.hobby.id} | ${c.hobby.title} | ${c.hobby.hook} | tags: ${c.hobby.tags.join(",")} | ${c.hobby.costText} | ${c.hobby.timeText} | ${c.hobby.difficultyText}`
    )
    .join("\n");

  const client = getAnthropicClient();

  const call = client.messages.create({
    model: MATCH_MODEL,
    max_tokens: MATCH_MAX_TOKENS,
    temperature: MATCH_TEMPERATURE,
    system: JURY_SYSTEM,
    messages: [
      {
        role: "user",
        content: `USER PROFILE\n${profileLines}\n\nCANDIDATES\n${candidateLines}`,
      },
    ],
  });

  const timeout = new Promise<never>((_, reject) =>
    setTimeout(() => reject(new Error(`Jury timed out after ${JURY_TIMEOUT_MS}ms`)), JURY_TIMEOUT_MS)
  );

  const response = await Promise.race([call, timeout]);
  return response.content[0]?.type === "text" ? response.content[0].text : "";
}

// ═══════════════════════════════════════════════════
//  Persistence helpers
// ═══════════════════════════════════════════════════

async function persistCache(profileHash: string, result: MatchResponse, ttlDays: number) {
  const expiresAt = new Date(Date.now() + ttlDays * 24 * 60 * 60 * 1000);
  try {
    await prisma.matchCache.upsert({
      where: { profileHash },
      update: { resultJson: result as object, source: result.source, expiresAt, createdAt: new Date() },
      create: { profileHash, resultJson: result as object, source: result.source, expiresAt },
    });
  } catch (err) {
    // Cache write failure must never break the response.
    console.error("[Match] Cache write failed:", err);
  }
}

async function logMatch(userId: string, status: string, reason: string | null) {
  await prisma.generationLog.create({
    data: { userId, query: "match", status, reason },
  });
}
