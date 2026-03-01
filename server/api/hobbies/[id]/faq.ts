import type { VercelRequest, VercelResponse } from "@vercel/node";
import { handleCors, methodNotAllowed, errorResponse } from "../../../lib/middleware";
import { prisma } from "../../../lib/db";
import { mapFaqItem } from "../../../lib/mappers";

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

    const items = await prisma.faqItem.findMany({
      where: { hobbyId: id },
      orderBy: { upvotes: "desc" },
    });

    res.status(200).json(items.map(mapFaqItem));
  } catch (err) {
    console.error("GET /api/hobbies/[id]/faq error:", err);
    errorResponse(res, 500, "Failed to fetch FAQ");
  }
}
