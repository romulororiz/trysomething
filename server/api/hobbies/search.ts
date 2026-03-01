import type { VercelRequest, VercelResponse } from "@vercel/node";
import { handleCors, methodNotAllowed, errorResponse } from "../../lib/middleware";
import { prisma } from "../../lib/db";
import { mapHobby } from "../../lib/mappers";

export default async function handler(
  req: VercelRequest,
  res: VercelResponse
): Promise<void> {
  if (handleCors(req, res)) return;
  if (methodNotAllowed(req, res, ["GET"])) return;

  try {
    const q = (req.query.q as string || "").trim();
    if (!q) {
      res.status(200).json([]);
      return;
    }

    const hobbies = await prisma.hobby.findMany({
      where: {
        OR: [
          { title: { contains: q, mode: "insensitive" } },
          { hook: { contains: q, mode: "insensitive" } },
          { tags: { hasSome: [q.toLowerCase()] } },
          { category: { name: { contains: q, mode: "insensitive" } } },
        ],
      },
      orderBy: { sortOrder: "asc" },
      include: {
        kitItems: { orderBy: { sortOrder: "asc" as const } },
        roadmapSteps: { orderBy: { sortOrder: "asc" as const } },
      },
    });

    res.status(200).json(hobbies.map(mapHobby));
  } catch (err) {
    console.error("GET /api/hobbies/search error:", err);
    errorResponse(res, 500, "Search failed");
  }
}
