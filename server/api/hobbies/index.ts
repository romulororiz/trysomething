import type { VercelRequest, VercelResponse } from "@vercel/node";
import { handleCors, methodNotAllowed, errorResponse } from "../../lib/middleware";
import { prisma } from "../../lib/db";
import { mapHobby } from "../../lib/mappers";

const hobbyIncludes = {
  kitItems: { orderBy: { sortOrder: "asc" as const } },
  roadmapSteps: { orderBy: { sortOrder: "asc" as const } },
};

export default async function handler(
  req: VercelRequest,
  res: VercelResponse
): Promise<void> {
  if (handleCors(req, res)) return;
  if (methodNotAllowed(req, res, ["GET"])) return;

  try {
    // Curated packs mode
    if (req.query.packs === "true") {
      const CURATED_PACKS = [
        {
          id: "introverts",
          title: "10 Hobbies for Introverts",
          icon: "introvert",
          filter: { tags: { hasSome: ["solo", "relaxing", "indoor"] } },
          limit: 10,
        },
        {
          id: "budget",
          title: "Weekend Hobbies Under CHF 50",
          icon: "budget",
          filter: {
            costText: { in: ["Free", "CHF 0–20", "CHF 20–50"] },
          },
          limit: 10,
        },
        {
          id: "community",
          title: "Hobbies That Build Community",
          icon: "community",
          filter: { tags: { hasSome: ["social", "community", "group"] } },
          limit: 10,
        },
      ];

      const packs = await Promise.all(
        CURATED_PACKS.map(async (pack) => {
          const hobbies = await prisma.hobby.findMany({
            where: pack.filter as any,
            take: pack.limit,
            orderBy: { sortOrder: "asc" },
            include: hobbyIncludes,
          });
          return {
            id: pack.id,
            title: pack.title,
            icon: pack.icon,
            hobbies: hobbies.map(mapHobby),
          };
        })
      );

      res.status(200).json(packs);
      return;
    }

    // Default: return all hobbies
    const hobbies = await prisma.hobby.findMany({
      orderBy: { sortOrder: "asc" },
      include: hobbyIncludes,
    });

    res.status(200).json(hobbies.map(mapHobby));
  } catch (err) {
    console.error("GET /api/hobbies error:", err);
    errorResponse(res, 500, "Failed to fetch hobbies");
  }
}
