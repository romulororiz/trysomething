// ═══════════════════════════════════════════════════
//  AI Hobby Generation — Consolidated handler
//  POST /api/generate/hobby  → Generate new hobby
//  POST /api/generate/faq    → Generate FAQ (tier 2)
//  POST /api/generate/cost   → Generate cost breakdown (tier 2)
//  POST /api/generate/budget → Generate budget alternatives (tier 2)
// ═══════════════════════════════════════════════════

import type { VercelRequest, VercelResponse } from "@vercel/node";
import { PrismaClient } from "@prisma/client";
import Anthropic from "@anthropic-ai/sdk";
import { requireAuth } from "../../lib/auth";
import { handleCors, methodNotAllowed, errorResponse } from "../../lib/middleware";
import { validateInput, validateOutput } from "../../lib/content_guard";
import { fetchHobbyImage } from "../../lib/unsplash";
import {
  generateHobbyContent,
  generateFaqContent,
  generateCostContent,
  generateBudgetContent,
} from "../../lib/ai_generator";
import {
  mapHobby,
  mapFaqItem,
  mapCostBreakdown,
  mapBudgetAlternative,
} from "../../lib/mappers";

const prisma = new PrismaClient();

// Coach: lazy Anthropic client
const COACH_MODEL = "claude-haiku-4-5-20251001";
let _anthropic: Anthropic | null = null;
function getAnthropicClient(): Anthropic {
  if (!_anthropic) {
    _anthropic = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY });
  }
  return _anthropic;
}

// Rate limit: 20 generations per user per 24 hours
const RATE_LIMIT = 20;

export default async function handler(req: VercelRequest, res: VercelResponse) {
  if (handleCors(req, res)) return;
  if (methodNotAllowed(req, res, ["POST"])) return;

  const action = req.query.action as string;

  switch (action) {
    case "hobby":
      return handleGenerateHobby(req, res);
    case "faq":
      return handleGenerateFaq(req, res);
    case "cost":
      return handleGenerateCost(req, res);
    case "budget":
      return handleGenerateBudget(req, res);
    case "coach":
      return handleCoachChat(req, res);
    default:
      return errorResponse(res, 404, `Unknown action: ${action}`);
  }
}

// ── Generate hobby (Tier 1) ─────────────────────

async function handleGenerateHobby(req: VercelRequest, res: VercelResponse) {
  const userId = requireAuth(req, res);
  if (!userId) return;

  const { query } = req.body ?? {};
  if (!query || typeof query !== "string") {
    return errorResponse(res, 400, "Query is required");
  }

  const trimmed = query.trim();

  // Layer 1: Input validation
  const inputCheck = validateInput(trimmed);
  if (!inputCheck.ok) {
    await logGeneration(userId, trimmed, "rejected", inputCheck.reason);
    return errorResponse(res, 400, inputCheck.reason);
  }

  // Rate limit check
  const recentCount = await prisma.generationLog.count({
    where: {
      userId,
      createdAt: { gte: new Date(Date.now() - 24 * 60 * 60 * 1000) },
      status: "success",
    },
  });

  if (recentCount >= RATE_LIMIT) {
    await logGeneration(userId, trimmed, "rejected", "Rate limit exceeded");
    return errorResponse(res, 429, "Generation limit reached (5 per day). Try again tomorrow.");
  }

  // Duplicate check — case-insensitive title match
  const existing = await prisma.hobby.findFirst({
    where: { title: { equals: trimmed, mode: "insensitive" } },
    include: {
      kitItems: { orderBy: { sortOrder: "asc" } },
      roadmapSteps: { orderBy: { sortOrder: "asc" } },
    },
  });

  if (existing) {
    return res.status(200).json({ hobby: mapHobby(existing), existed: true });
  }

  try {
    // Parallel: Claude + Unsplash (image uses query as hint, category resolved after)
    const [content, defaultImage] = await Promise.all([
      generateHobbyContent(trimmed),
      fetchHobbyImage(trimmed),
    ]);
    const imageUrl = defaultImage;

    // Layer 3: Output validation
    const outputCheck = validateOutput(content);
    if (!outputCheck.ok) {
      await logGeneration(userId, trimmed, "rejected", `Output: ${outputCheck.reason}`);
      return errorResponse(res, 500, "Generated content failed validation. Please try a different query.");
    }

    // Generate slug ID from title
    const slug = (content.title as string)
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, "-")
      .replace(/^-|-$/g, "");

    // Check slug doesn't already exist
    const slugExists = await prisma.hobby.findUnique({ where: { id: slug } });
    const hobbyId = slugExists ? `${slug}-${Date.now().toString(36)}` : slug;

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
        generatedBy: userId,
        sortOrder: 999,
        kitItems: {
          create: (content.kitItems as Record<string, unknown>[]).map(
            (item, i) => ({
              name: item.name as string,
              description: item.description as string,
              cost: item.cost as number,
              isOptional: (item.isOptional as boolean) ?? false,
              sortOrder: i,
            })
          ),
        },
        roadmapSteps: {
          create: (content.roadmapSteps as Record<string, unknown>[]).map(
            (step, i) => ({
              id: `${hobbyId}-step-${i + 1}`,
              title: step.title as string,
              description: step.description as string,
              estimatedMinutes: step.estimatedMinutes as number,
              milestone: (step.milestone as string) ?? null,
              sortOrder: i,
            })
          ),
        },
      },
      include: {
        kitItems: { orderBy: { sortOrder: "asc" } },
        roadmapSteps: { orderBy: { sortOrder: "asc" } },
      },
    });

    await logGeneration(userId, trimmed, "success", null, hobbyId);

    return res.status(201).json({ hobby: mapHobby(hobby), existed: false });
  } catch (err) {
    const message = err instanceof Error ? err.message : "Unknown error";
    await logGeneration(userId, trimmed, "error", message).catch(() => {});
    console.error("Generation error:", message);
    return errorResponse(res, 500, "Failed to generate hobby. Please try again.");
  }
}

// ── Generate FAQ (Tier 2) ───────────────────────

async function handleGenerateFaq(req: VercelRequest, res: VercelResponse) {
  const userId = requireAuth(req, res);
  if (!userId) return;

  const { hobbyId } = req.body ?? {};
  if (!hobbyId || typeof hobbyId !== "string") {
    return errorResponse(res, 400, "hobbyId is required");
  }

  // Check if FAQ already exists
  const existing = await prisma.faqItem.findMany({ where: { hobbyId } });
  if (existing.length > 0) {
    return res.status(200).json(existing.map(mapFaqItem));
  }

  const hobby = await prisma.hobby.findUnique({
    where: { id: hobbyId },
    select: { title: true, categoryId: true },
  });

  if (!hobby) {
    return errorResponse(res, 404, "Hobby not found");
  }

  try {
    const faqData = await generateFaqContent(hobby.title, hobby.categoryId);

    const created = await Promise.all(
      faqData.map((item) =>
        prisma.faqItem.create({
          data: { hobbyId, question: item.question, answer: item.answer },
        })
      )
    );

    return res.status(201).json(created.map(mapFaqItem));
  } catch (err) {
    console.error("FAQ generation error:", err);
    return errorResponse(res, 500, "Failed to generate FAQ");
  }
}

// ── Generate cost breakdown (Tier 2) ────────────

async function handleGenerateCost(req: VercelRequest, res: VercelResponse) {
  const userId = requireAuth(req, res);
  if (!userId) return;

  const { hobbyId } = req.body ?? {};
  if (!hobbyId || typeof hobbyId !== "string") {
    return errorResponse(res, 400, "hobbyId is required");
  }

  // Check if cost breakdown already exists
  const existing = await prisma.costBreakdown.findUnique({ where: { hobbyId } });
  if (existing) {
    return res.status(200).json(mapCostBreakdown(existing));
  }

  const hobby = await prisma.hobby.findUnique({
    where: { id: hobbyId },
    include: { kitItems: { select: { name: true, cost: true } } },
  });

  if (!hobby) {
    return errorResponse(res, 404, "Hobby not found");
  }

  try {
    const costData = await generateCostContent(hobby.title, hobby.kitItems);

    const created = await prisma.costBreakdown.create({
      data: {
        hobbyId,
        starter: costData.starter,
        threeMonth: costData.threeMonth,
        oneYear: costData.oneYear,
        tips: costData.tips,
      },
    });

    return res.status(201).json(mapCostBreakdown(created));
  } catch (err) {
    console.error("Cost generation error:", err);
    return errorResponse(res, 500, "Failed to generate cost breakdown");
  }
}

// ── Generate budget alternatives (Tier 2) ───────

async function handleGenerateBudget(req: VercelRequest, res: VercelResponse) {
  const userId = requireAuth(req, res);
  if (!userId) return;

  const { hobbyId } = req.body ?? {};
  if (!hobbyId || typeof hobbyId !== "string") {
    return errorResponse(res, 400, "hobbyId is required");
  }

  // Check if budget alternatives already exist
  const existing = await prisma.budgetAlternative.findMany({ where: { hobbyId } });
  if (existing.length > 0) {
    return res.status(200).json(existing.map(mapBudgetAlternative));
  }

  const hobby = await prisma.hobby.findUnique({
    where: { id: hobbyId },
    include: { kitItems: { select: { name: true, cost: true } } },
  });

  if (!hobby) {
    return errorResponse(res, 404, "Hobby not found");
  }

  try {
    const budgetData = await generateBudgetContent(hobby.title, hobby.kitItems);

    const created = await Promise.all(
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

    return res.status(201).json(created.map(mapBudgetAlternative));
  } catch (err) {
    console.error("Budget generation error:", err);
    return errorResponse(res, 500, "Failed to generate budget alternatives");
  }
}

// ── AI Hobby Coach ──────────────────────────────

interface ChatMessage {
  role: "user" | "assistant";
  content: string;
}

async function handleCoachChat(req: VercelRequest, res: VercelResponse) {
  const userId = requireAuth(req, res);
  if (!userId) return;

  const { hobbyId, message, conversationHistory } = req.body ?? {};

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
        kitItems: true,
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

    const systemPrompt = buildCoachSystemPrompt(hobby, userHobby, recentJournal);

    const messages: ChatMessage[] = [];
    if (Array.isArray(conversationHistory)) {
      for (const msg of conversationHistory.slice(-15)) {
        if (msg.role === "user" || msg.role === "assistant") {
          messages.push({ role: msg.role, content: msg.content });
        }
      }
    }
    messages.push({ role: "user", content: message });

    const client = getAnthropicClient();
    const response = await client.messages.create({
      model: COACH_MODEL,
      max_tokens: 512,
      system: systemPrompt,
      messages,
    });

    const text =
      response.content[0]?.type === "text" ? response.content[0].text : "";

    return res.status(200).json({ response: text });
  } catch (err: unknown) {
    console.error("[Coach] Error:", err);
    const msg = err instanceof Error ? err.message : "Unknown error";
    return errorResponse(res, 500, `Coach error: ${msg}`);
  }
}

function buildCoachSystemPrompt(
  hobby: any,
  userHobby: any | null,
  recentJournal: any[]
): string {
  const kitList = hobby.kitItems
    ?.map((k: any) => `- ${k.name}: ${k.description}`)
    .join("\n") ?? "None";

  const roadmapList = hobby.roadmapSteps
    ?.map((s: any, i: number) => `${i + 1}. ${s.title} (${s.estimatedMinutes}min)`)
    .join("\n") ?? "None";

  const journalSummary =
    recentJournal.length > 0
      ? recentJournal
          .map(
            (j: any) =>
              `[${new Date(j.createdAt).toLocaleDateString()}] ${j.text.slice(0, 100)}`
          )
          .join("\n")
      : "No journal entries yet.";

  let userState = "BROWSING";
  let progressInfo = "Not started yet.";
  if (userHobby) {
    if (userHobby.status === "trying" || userHobby.status === "active") {
      userState = "ACTIVE";
      const completedSteps = userHobby.completedSteps ?? 0;
      const totalSteps = hobby.roadmapSteps?.length ?? 0;
      progressInfo = `Status: ${userHobby.status}. Completed ${completedSteps}/${totalSteps} roadmap steps. Started: ${userHobby.startedAt ? new Date(userHobby.startedAt).toLocaleDateString() : "unknown"}.`;
    } else if (userHobby.status === "saved") {
      userState = "SAVED";
      progressInfo = "Saved but not started yet.";
    }
  }

  return `You are a friendly, encouraging coach for ${hobby.title}.
You ONLY discuss ${hobby.title} and directly related topics.

User state: ${userState}
${progressInfo}

Recent journal entries:
${journalSummary}

Hobby context:
- Category: ${hobby.categoryId}
- Difficulty: ${hobby.difficultyText ?? "Unknown"}
- Cost: ${hobby.costText ?? "Unknown"}
- Time: ${hobby.timeText ?? "Unknown"}

Starter kit:
${kitList}

Roadmap:
${roadmapList}

Rules:
- If asked about anything unrelated to ${hobby.title}, politely redirect and suggest they check other hobbies in the app.
- Keep responses concise (2-3 paragraphs max).
- Be encouraging but honest.
- Reference their specific progress when relevant.
- If they're BROWSING, share what makes this hobby special and encourage them to save it.
- If they're SAVED, address hesitation and help them take the first step.
- If they're ACTIVE, give specific guidance based on their current roadmap step.`;
}

// ── Audit log helper ────────────────────────────

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
