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
  if (methodNotAllowed(req, res, ["GET"])) return;

  const { id, feature } = req.query;
  if (!id || typeof id !== "string") {
    errorResponse(res, 400, "Missing hobby ID");
    return;
  }

  try {
    switch (feature) {
      case "faq": {
        const items = await prisma.faqItem.findMany({
          where: { hobbyId: id },
          orderBy: { upvotes: "desc" },
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
    console.error(`GET /api/hobbies/${id}/${feature} error:`, err);
    errorResponse(res, 500, `Failed to fetch ${feature}`);
  }
}
