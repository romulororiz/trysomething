import { prisma } from './db';

const COACH_FREE_LIMIT = 3;
const COACH_WINDOW_MS = 30 * 24 * 60 * 60 * 1000; // 30 days rolling

export async function checkCoachRateLimit(
  userId: string,
  subscriptionTier: string
): Promise<{ allowed: boolean; count: number }> {
  // D-05: Pro/lifetime users are unlimited
  if (subscriptionTier !== 'free') {
    return { allowed: true, count: 0 };
  }

  // D-04: Rolling 30-day window count from GenerationLog
  const windowStart = new Date(Date.now() - COACH_WINDOW_MS);
  const count = await prisma.generationLog.count({
    where: {
      userId,
      query: 'coach',
      status: 'success',
      createdAt: { gte: windowStart },
    },
  });

  return { allowed: count < COACH_FREE_LIMIT, count };
}
