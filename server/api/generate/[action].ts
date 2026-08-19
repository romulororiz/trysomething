// ═══════════════════════════════════════════════════
//  AI endpoints — Consolidated handler
//  POST /api/generate/coach          → AI hobby coach (Sonnet)
//  POST /api/generate/moderate-image → Journal image safety gate (Haiku vision)
//
//  Hobby/FAQ/cost/budget generation moved to scripts/curate-hobby.ts (curation-only)
// ═══════════════════════════════════════════════════

import type { VercelRequest, VercelResponse } from "@vercel/node";
import Anthropic from "@anthropic-ai/sdk";
import { prisma } from "../../lib/db";
import { requireAuth } from "../../lib/auth";
import { handleCors, methodNotAllowed, errorResponse } from "../../lib/middleware";
import { checkCoachRateLimit } from "../../lib/rate_limit";

// ── Shared Anthropic client (coach uses this directly) ──
const COACH_MODEL = "claude-sonnet-4-6";
const COACH_MAX_TOKENS = 512;

let _anthropic: Anthropic | null = null;
function getAnthropicClient(): Anthropic {
  if (!_anthropic) {
    _anthropic = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY });
  }
  return _anthropic;
}

// Vercel function config — coach + vision moderation need more time than default 10s
export const config = { maxDuration: 60 };

export default async function handler(req: VercelRequest, res: VercelResponse) {
  if (handleCors(req, res)) return;
  if (methodNotAllowed(req, res, ["POST"])) return;

  const action = req.query.action as string;

  switch (action) {
    case "coach":
      return handleCoachChat(req, res);
    case "moderate-image":
      return handleModerateImage(req, res);
    default:
      return errorResponse(res, 404, `Unknown action: ${action}`);
  }
}

// ═══════════════════════════════════════════════════
//  AI Hobby Coach — Sonnet, hardened prompt
// ═══════════════════════════════════════════════════

type CoachMode = "START" | "MOMENTUM" | "RESCUE";

interface CoachChatMessage {
  role: "user" | "assistant";
  content: string | Array<{ type: "text"; text: string } | { type: "image"; source: { type: "url"; url: string } }>;
}

async function handleCoachChat(req: VercelRequest, res: VercelResponse) {
  const userId = await requireAuth(req, res);
  if (!userId) return;

  // Server-side rate limit check (SEC-02, per D-04/D-05/D-06)
  const user = await prisma.user.findUnique({
    where: { id: userId },
    select: { subscriptionTier: true },
  });
  if (!user) {
    return errorResponse(res, 401, 'User not found');
  }

  const rateCheck = await checkCoachRateLimit(userId, user.subscriptionTier);
  if (!rateCheck.allowed) {
    // D-06: Simple error message only, client handles UX
    return errorResponse(res, 429, 'Rate limit exceeded');
  }

  const { hobbyId, message, conversationHistory, modeOverride, focusEntryId, imageUrl } = req.body ?? {};

  if (!hobbyId || typeof hobbyId !== "string") {
    return errorResponse(res, 400, "hobbyId is required");
  }
  if (!message || typeof message !== "string") {
    return errorResponse(res, 400, "message is required");
  }

  try {
    const hobby = await prisma.hobby.findUnique({
      where: { id: hobbyId },
      include: {
        kitItems: { orderBy: { sortOrder: "asc" } },
        roadmapSteps: { orderBy: { sortOrder: "asc" } },
      },
    });

    if (!hobby) {
      return errorResponse(res, 404, "Hobby not found");
    }

    const userHobby = await prisma.userHobby.findUnique({
      where: { userId_hobbyId: { userId, hobbyId } },
    });

    const recentJournal = await prisma.journalEntry.findMany({
      where: { userId, hobbyId },
      orderBy: { createdAt: "desc" },
      take: 5,
    });

// ── Derive user state + coach mode ──

    let userState: "BROWSING" | "SAVED" | "ACTIVE" = "BROWSING";
    let currentStep = -1;
    let daysSinceLastSession: number | null = null;

    if (userHobby) {
      if (userHobby.status === "trying" || userHobby.status === "active") {
        userState = "ACTIVE";

        // Count completed steps via the join table
        const completedCount = await prisma.userCompletedStep.count({
          where: { userId, hobbyId },
        });
        const totalSteps = hobby.roadmapSteps?.length ?? 0;
        currentStep = Math.min(completedCount, Math.max(totalSteps - 1, 0));

        // Days since last activity
        const lastActivity = userHobby.lastActivityAt ?? userHobby.startedAt;
        daysSinceLastSession = lastActivity
          ? Math.floor((Date.now() - new Date(lastActivity).getTime()) / 86400000)
          : null;
      } else if (userHobby.status === "saved") {
        userState = "SAVED";
      }
    }

    const validOverrides: CoachMode[] = ["START", "MOMENTUM", "RESCUE"];
    const mode: CoachMode =
      typeof modeOverride === "string" && validOverrides.includes(modeOverride as CoachMode)
        ? (modeOverride as CoachMode)
        : detectCoachMode(userState, daysSinceLastSession);

    // Find the focused entry's photoUrl (if any) for vision
    let focusedPhotoUrl: string | null = null;

    const journalEntries = recentJournal.map(
      (j: any) => {
        const dateStr = new Date(j.createdAt).toLocaleDateString();
        const text = (j.text ?? "").slice(0, 150);
        const hasPhoto = !!j.photoUrl;
        const isFocused = focusEntryId && j.id === focusEntryId;
        if (isFocused && hasPhoto) focusedPhotoUrl = j.photoUrl;
        const photoTag = hasPhoto ? " [Photo attached]" : "";
        return isFocused
          ? `>>> [${dateStr}] ${text}${photoTag} <<< (THE USER IS ASKING ABOUT THIS ENTRY — reference it naturally without quoting it back verbatim${hasPhoto ? ". THE PHOTO IS INCLUDED BELOW — describe what you see and give specific feedback on it." : ""})`
          : `[${dateStr}] ${text}${photoTag}`;
      }
    );

    const systemPrompt = buildCoachSystemPrompt(
      {
        title: hobby.title,
        categoryId: hobby.categoryId,
        difficultyText: hobby.difficultyText ?? "Unknown",
        costText: hobby.costText ?? "Unknown",
        timeText: hobby.timeText ?? "Unknown",
        kitItems: (hobby.kitItems ?? []).map((k: any) => ({
          name: k.name,
          description: k.description ?? "",
          cost: k.cost,
          isOptional: k.isOptional ?? false,
        })),
        roadmapSteps: (hobby.roadmapSteps ?? []).map((s: any) => ({
          title: s.title,
          description: s.description ?? "",
          estimatedMinutes: s.estimatedMinutes,
          milestone: s.milestone ?? null,
        })),
      },
      { userState, currentStep, daysSinceLastSession, journalEntries },
      mode
    );

    // ── Build messages array ──

    const messages: CoachChatMessage[] = [];
    if (Array.isArray(conversationHistory)) {
      for (const msg of conversationHistory.slice(-15)) {
        if (msg.role === "user" || msg.role === "assistant") {
          messages.push({ role: msg.role, content: msg.content });
        }
      }
    }

    // Include image as a vision content block if provided:
    // - focusedPhotoUrl: from a journal entry with photo
    // - imageUrl: directly attached by the user in chat
    const photoUrl = focusedPhotoUrl || (typeof imageUrl === "string" ? imageUrl : null);
    console.log(`[Coach] photoUrl=${photoUrl ? photoUrl.slice(0, 60) + '...' : 'none'}, focusedPhotoUrl=${!!focusedPhotoUrl}, imageUrl=${typeof imageUrl === 'string' ? 'present' : 'absent'}`);
    if (photoUrl) {
      messages.push({
        role: "user",
        content: [
          { type: "image", source: { type: "url", url: photoUrl } },
          { type: "text", text: message },
        ],
      });
    } else {
      messages.push({ role: "user", content: message });
    }

    // ── Call Sonnet ──

    const client = getAnthropicClient();
    const response = await client.messages.create({
      model: COACH_MODEL,
      max_tokens: COACH_MAX_TOKENS,
      temperature: 0.5,
      system: systemPrompt,
      messages,
    });

    const text =
      response.content[0]?.type === "text" ? response.content[0].text : "";

    // Log successful coach message to GenerationLog (AFTER AI response, per Pitfall 2).
    // Critical: a silent log failure here would let the rate-limit counter stall
    // forever (since checkCoachRateLimit reads from this table). Surface failures
    // loudly so we can fix the underlying issue rather than masking a bypass.
    try {
      await logGeneration(userId, 'coach', 'success', null);
    } catch (logErr) {
      console.error(
        '[Coach] CRITICAL: GenerationLog write failed — rate limit will not increment for this user!',
        logErr
      );
    }

    return res.status(200).json({ response: text.trim() });
  } catch (err: unknown) {
    console.error("[Coach] Error:", err);
    const msg = err instanceof Error ? err.message : "Unknown error";
    return errorResponse(res, 500, `Coach error: ${msg}`);
  }
}

// ═══════════════════════════════════════════════════
//  Coach internals — mode detection + prompt builder
// ═══════════════════════════════════════════════════

function detectCoachMode(
  userState: "BROWSING" | "SAVED" | "ACTIVE",
  daysSinceLastSession: number | null
): CoachMode {
  if (userState === "BROWSING" || userState === "SAVED") return "START";
  if (daysSinceLastSession !== null && daysSinceLastSession >= 7) return "RESCUE";
  return "MOMENTUM";
}

interface CoachHobbyContext {
  title: string;
  categoryId: string;
  difficultyText: string;
  costText: string;
  timeText: string;
  kitItems: { name: string; description: string; cost: number; isOptional: boolean }[];
  roadmapSteps: { title: string; description: string; estimatedMinutes: number; milestone: string | null }[];
}

interface CoachUserContext {
  userState: "BROWSING" | "SAVED" | "ACTIVE";
  currentStep: number;
  daysSinceLastSession: number | null;
  journalEntries: string[];
}

function buildCoachSystemPrompt(
  hobby: CoachHobbyContext,
  user: CoachUserContext,
  mode: CoachMode
): string {
  // ── Hobby facts ──
  const kitList = hobby.kitItems
    .map((k) => `- ${k.name} (CHF ${k.cost}${k.isOptional ? ", optional" : ""})`)
    .join("\n");

  const roadmapList = hobby.roadmapSteps
    .map((s, i) => {
      const marker =
        i === user.currentStep
          ? " ← CURRENT"
          : i < user.currentStep
            ? " ✓"
            : "";
      return `${i + 1}. ${s.title} (~${s.estimatedMinutes} min)${s.milestone ? ` [Milestone: ${s.milestone}]` : ""}${marker}`;
    })
    .join("\n");

  // ── Journal context ──
  const journalBlock =
    user.journalEntries.length > 0
      ? `\n# USER'S RECENT JOURNAL ENTRIES\n${user.journalEntries.map((e, i) => `${i + 1}. "${e}"`).join("\n")}`
      : "";

  // ── Mode-specific instructions (model only sees ONE mode) ──
  const modeInstructions: Record<CoachMode, string> = {
    START: `# YOUR MODE: START (user is considering this hobby)
The user has NOT committed yet. Your job:
- Share what makes ${hobby.title} genuinely rewarding (not generic hype).
- Address the specific hesitations a beginner would have (cost, time, difficulty, fear of being bad).
- Give ONE concrete first action they can do today — the smallest possible step.
- If they ask what to buy: recommend only the cheapest essential items first. Never push the full kit upfront.
- If they seem uncertain: validate that uncertainty is normal. Don't oversell.`,

    MOMENTUM: `# YOUR MODE: MOMENTUM (user is actively practicing)
The user is on step ${user.currentStep + 1} of ${hobby.roadmapSteps.length}: "${hobby.roadmapSteps[user.currentStep]?.title || "unknown"}".
Your job:
- Give specific guidance for their CURRENT step — what to focus on, common mistakes at this stage, what "good enough" looks like.
- If they're struggling: simplify. Suggest a shorter session (15 min) or an easier variation.
- If they completed a step: celebrate briefly (1 sentence), then preview the next step to build anticipation.
- Keep it practical — tell them exactly what to do in their next session.
- Reference their journal entries if relevant (shows you're paying attention).`,

    RESCUE: `# YOUR MODE: RESCUE (user hasn't practiced in ${user.daysSinceLastSession}+ days)
The user has gone quiet. Your job:
- Be warm, NEVER guilt-trip. No "I noticed you've been away" energy. No passive-aggression.
- Acknowledge that life gets in the way — normalize the gap.
- Suggest the EASIEST possible re-entry: a tiny 10-minute session, or even just laying out their materials.
- If they express doubt about continuing: validate it. Switching hobbies is fine. Ask what's blocking them — is it the hobby itself or just life?
- If they want to quit: respect it. Suggest they save it for later. Never pressure.`,
  };

  return `You are the hobby coach inside the app "TrySomething". You help one person with one hobby: ${hobby.title}.

# PERSONALITY
- Warm, practical, concise. Like a supportive friend who actually does this hobby.
- You speak from experience with ${hobby.title} specifically — not generic motivation.
- You are NOT a therapist, life coach, or motivational speaker. You are a hobby guide.

# HOBBY FACTS (use these, don't invent others)
- Title: ${hobby.title}
- Category: ${hobby.categoryId}
- Difficulty: ${hobby.difficultyText}
- Typical cost: ${hobby.costText}
- Time commitment: ${hobby.timeText}

## Starter Kit
${kitList}

## Roadmap
${roadmapList}

${modeInstructions[mode]}
${journalBlock}

# HARD RULES — NEVER BREAK THESE
1. ONLY discuss ${hobby.title} and directly related topics (materials, techniques, mindset for this hobby). If the user asks about something unrelated, say: "I'm your ${hobby.title} coach — I can only help with that! But I'm all yours for ${hobby.title} questions."
2. For REGULAR conversation: maximum 2-3 short paragraphs. No bullet lists. No headers. Write like a text message from a knowledgeable friend.
3. For GUIDED FLOWS (see below): use **bold section headers** and bullet points starting with "- " so the app can render them as action cards.
4. NEVER invent facts about ${hobby.title}. If you're unsure about a specific technique or product, say so.
5. NEVER recommend specific brand names or stores unless they are in the kit items above.
6. All costs in CHF. This user is in Switzerland.
7. If the user shares a journal entry or photo, acknowledge what they specifically did — don't give generic praise. If an image is included, describe what you see and give concrete, specific feedback about their work.
8. Do NOT repeat the roadmap or kit list back to the user unless they explicitly ask.
9. Do NOT start responses with "Great question!" or similar filler. Get straight to the useful content.
10. If the user asks about Pro features, say they can check their subscription in the You tab. Don't upsell.

# GUIDED FLOWS — USE STRUCTURED FORMAT
When the user's message matches one of these intents, respond with **bold section headers** and "- " bullet items. Keep each section to 2-4 bullets max. Be specific to ${hobby.title}, not generic.

**Intent: "help me start tonight" / "start tonight" / first session**
Use these sections:
**Tonight's Plan**
- What to do (one simple activity, 15-20 min)
- What mindset to bring
**What You Need**
- Only the bare essentials from the kit list
**What to Skip**
- Things beginners overthink that don't matter yet

**Intent: "make this cheaper" / "cheaper way" / budget / cost**
Use these sections:
**Buy Now** (cheapest essentials only)
- item — approximate CHF cost
**Skip For Now**
- Items that can wait until week 3+
**Cheaper Alternatives**
- DIY or budget substitutes for expensive items

**Intent: "what should I do next" / "next step"**
Use these sections:
**Your Next Step**
- The specific next action based on their current roadmap position
**How to Do It**
- 2-3 concrete tips for this step
**What Good Looks Like**
- What "done enough" means for this step (lower the bar)

**Intent: "maybe this hobby isn't for me" / "switch" / "not sure" / "quit"**
Use these sections:
**What's Not Working**
- Ask 1-2 clarifying questions about what specifically feels off
**Simpler Version**
- A dramatically easier way to do ${hobby.title} (less time, less gear, lower expectations)
**If You Want to Switch**
- Validate that switching is fine, suggest saving this hobby for later

**Intent: "I skipped a few days" / "restart" / "been away" / "fell off"**
Use these sections:
**Easy Restart**
- One tiny action (under 10 min) to break the gap
**Just Do This**
- The single simplest thing they can do right now
**Why It's OK**
- Normalize the gap, no guilt

For ALL other messages, use the regular text-message style (no headers, no bullets).`;
}

// ═══════════════════════════════════════════════════
//  Image Moderation — Pre-upload safety gate
// ═══════════════════════════════════════════════════

const MODERATION_MODEL = "claude-haiku-4-5-20251001";

const MODERATION_PROMPT = `You are an image content safety classifier for a hobby discovery app (TrySomething). Your ONLY job is to determine if an uploaded image is safe for a general-audience mobile app.

REJECT (unsafe = true) if the image contains ANY of the following:
- Nudity or partial nudity (including lingerie, suggestive poses)
- Sexual or sexually suggestive content of any kind
- Pornographic content
- Violence, gore, blood, wounds, or graphic injury
- Weapons (guns, knives used threateningly, explosives)
- Drug use, drug paraphernalia, or substance abuse
- Self-harm or suicide imagery
- Hate symbols, extremist imagery, or discriminatory content
- Graphic medical/surgical imagery
- Child exploitation or endangerment of any kind
- Illegal activity being depicted
- Disturbing, grotesque, or shock content
- Text overlays containing hate speech, slurs, or threats

ALLOW (unsafe = false) for:
- Hobby activities (painting, cooking, gardening, crafts, sports, music, etc.)
- Nature, landscapes, animals, pets
- Food, recipes, ingredients
- Tools, materials, equipment for hobbies
- Selfies and portraits (clothed, appropriate)
- Progress photos of creative work
- Indoor/outdoor scenes
- Screenshots of hobby-related content

You MUST err on the side of caution. If you are even slightly uncertain, REJECT.

Respond with EXACTLY this JSON format, nothing else:
{"unsafe": false}
or
{"unsafe": true, "reason": "brief explanation"}`;

async function handleModerateImage(req: VercelRequest, res: VercelResponse) {
  const userId = await requireAuth(req, res);
  if (!userId) return;

  try {
    const { image, mediaType } = req.body ?? {};

    if (!image || typeof image !== "string") {
      return errorResponse(res, 400, "Missing image (base64 string)");
    }

    // 2MB max (base64 string ~1.37× raw bytes)
    if (image.length > 2 * 1024 * 1024 * 1.4) {
      return errorResponse(res, 413, "Image too large (max 2MB)");
    }

    const validTypes = ["image/jpeg", "image/png", "image/webp", "image/gif"];
    const resolvedType = validTypes.includes(mediaType) ? mediaType : "image/jpeg";

    const client = getAnthropicClient();
    const response = await client.messages.create({
      model: MODERATION_MODEL,
      max_tokens: 100,
      temperature: 0,
      system: MODERATION_PROMPT,
      messages: [
        {
          role: "user",
          content: [
            {
              type: "image",
              source: {
                type: "base64",
                media_type: resolvedType,
                data: image,
              },
            },
            { type: "text", text: "Classify this image. Respond with JSON only." },
          ],
        },
      ],
    });

    const text =
      response.content[0]?.type === "text" ? response.content[0].text : "";

    let result: { unsafe: boolean; reason?: string };
    try {
      const jsonMatch = text.match(/\{[^}]+\}/);
      result = jsonMatch
        ? JSON.parse(jsonMatch[0])
        : { unsafe: true, reason: "Failed to parse moderation response" };
    } catch {
      // Fail closed
      result = { unsafe: true, reason: "Moderation check inconclusive — rejected for safety" };
    }

    if (typeof result.unsafe !== "boolean") {
      result = { unsafe: true, reason: "Invalid moderation response" };
    }

    return res.status(200).json({
      safe: !result.unsafe,
      reason: result.unsafe ? (result.reason || "Content policy violation") : undefined,
    });
  } catch (err: unknown) {
    console.error("[Moderate] Error:", err);
    // Fail closed — reject if moderation itself errors
    return res.status(200).json({
      safe: false,
      reason: "Moderation service unavailable — please try again",
    });
  }
}

// ═══════════════════════════════════════════════════
//  Audit log helper
// ═══════════════════════════════════════════════════

async function logGeneration(
  userId: string,
  query: string,
  status: string,
  reason: string | null,
  hobbyId?: string
) {
  await prisma.generationLog.create({
    data: { userId, query, hobbyId, status, reason },
  });
}