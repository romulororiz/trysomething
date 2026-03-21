import type { VercelRequest, VercelResponse } from "@vercel/node";
import { prisma } from "../../lib/db";

/**
 * Daily cron handler: hard-deletes users whose deletedAt is older than 30 days.
 * Vercel Cron sends GET requests. Requires CRON_SECRET for authorization.
 *
 * GenerationLog has no FK relation to User, so it must be deleted explicitly.
 * All other user-related tables have onDelete: Cascade and are auto-removed.
 */
export default async function handler(
  req: VercelRequest,
  res: VercelResponse
): Promise<void> {
  // Vercel Cron sends GET requests
  if (req.method !== "GET") {
    res.status(405).json({ error: "Method not allowed" });
    return;
  }

  // Verify CRON_SECRET
  const authHeader = req.headers.authorization;
  if (
    !process.env.CRON_SECRET ||
    authHeader !== `Bearer ${process.env.CRON_SECRET}`
  ) {
    res.status(401).json({ error: "Unauthorized" });
    return;
  }

  try {
    // 30-day cutoff
    const cutoff = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);

    const usersToDelete = await prisma.user.findMany({
      where: { deletedAt: { lte: cutoff } },
      select: { id: true },
    });

    if (usersToDelete.length === 0) {
      res.status(200).json({ purged: 0 });
      return;
    }

    const userIds = usersToDelete.map((u) => u.id);

    // Hard delete: GenerationLog first (no FK cascade), then User (cascades the rest)
    await prisma.$transaction([
      prisma.generationLog.deleteMany({ where: { userId: { in: userIds } } }),
      prisma.user.deleteMany({ where: { id: { in: userIds } } }),
    ]);

    res.status(200).json({ purged: userIds.length });
  } catch (err) {
    console.error("Cron purge-deleted-users error:", err);
    res.status(500).json({ error: "Purge failed" });
  }
}
