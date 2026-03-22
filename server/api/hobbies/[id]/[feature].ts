import type { VercelRequest, VercelResponse } from "@vercel/node";
import {
  handleCors,
  methodNotAllowed,
  errorResponse,
} from "../../../lib/middleware";
import { prisma } from "../../../lib/db";
import {
  mapFaqItem,
  mapCostBreakdown,
  mapBudgetAlternative,
} from "../../../lib/mappers";

export default async function handler(
  req: VercelRequest,
  res: VercelResponse
): Promise<void> {
  if (handleCors(req, res)) return;
  if (methodNotAllowed(req, res, ["GET", "PATCH"])) return;

  const { id, feature, faqId } = req.query;
  if (!id || typeof id !== "string") {
    errorResponse(res, 400, "Missing hobby ID");
    return;
  }

  try {
    // ── PATCH /api/hobbies/:id/faq/:faqId/vote ──────────
    if (req.method === "PATCH" && feature === "faq" && faqId) {
      const { vote } = req.body ?? {};
      if (vote !== "up" && vote !== "down") {
        errorResponse(res, 400, 'Invalid vote — must be "up" or "down"');
        return;
      }

      const faq = await prisma.faqItem.findFirst({
        where: { id: faqId as string, hobbyId: id },
      });
      if (!faq) {
        errorResponse(res, 404, `FAQ item '${faqId}' not found`);
        return;
      }

      const updated = await prisma.faqItem.update({
        where: { id: faqId as string },
        data: {
          helpfulCount: {
            increment: vote === "up" ? 1 : -1,
          },
        },
      });
      res.status(200).json(mapFaqItem(updated));
      return;
    }

    // ── GET handlers ─────────────────────────────────────
    if (req.method !== "GET") {
      errorResponse(res, 405, `PATCH only supported for faq vote`);
      return;
    }

    switch (feature) {
      case "faq": {
        const items = await prisma.faqItem.findMany({
          where: { hobbyId: id },
          orderBy: { helpfulCount: "desc" },
        });
        res.status(200).json(items.map(mapFaqItem));
        return;
      }

      case "cost": {
        const breakdown = await prisma.costBreakdown.findUnique({
          where: { hobbyId: id },
        });
        if (!breakdown) {
          errorResponse(res, 404, `No cost data for hobby '${id}'`);
          return;
        }
        res.status(200).json(mapCostBreakdown(breakdown));
        return;
      }

      case "budget": {
        const alternatives = await prisma.budgetAlternative.findMany({
          where: { hobbyId: id },
          orderBy: { sortOrder: "asc" },
        });
        res.status(200).json(alternatives.map(mapBudgetAlternative));
        return;
      }

      default:
        errorResponse(res, 404, `Unknown feature '${feature}'`);
    }
  } catch (err) {
    console.error(`${req.method} /api/hobbies/${id}/${feature} error:`, err);
    errorResponse(res, 500, `Failed to process ${feature}`);
  }
}
