import type { VercelRequest, VercelResponse } from "@vercel/node";
import { handleCors, methodNotAllowed, errorResponse } from "../../../lib/middleware";
import { prisma } from "../../../lib/db";
import { mapBudgetAlternative } from "../../../lib/mappers";

export default async function handler(
  req: VercelRequest,
  res: VercelResponse
): Promise<void> {
  if (handleCors(req, res)) return;
  if (methodNotAllowed(req, res, ["GET"])) return;

  try {
    const { id } = req.query;
    if (!id || typeof id !== "string") {
      errorResponse(res, 400, "Missing hobby ID");
      return;
    }

    const alternatives = await prisma.budgetAlternative.findMany({
      where: { hobbyId: id },
      orderBy: { sortOrder: "asc" },
    });

    res.status(200).json(alternatives.map(mapBudgetAlternative));
  } catch (err) {
    console.error("GET /api/hobbies/[id]/budget error:", err);
    errorResponse(res, 500, "Failed to fetch budget alternatives");
  }
}
