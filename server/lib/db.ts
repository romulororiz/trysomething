import { PrismaClient } from "@prisma/client";

// Singleton Prisma client.
// In serverless (Vercel), reuse the client across warm invocations
// to avoid exhausting the connection pool.

const globalForPrisma = globalThis as unknown as { prisma: PrismaClient };

export const prisma =
  globalForPrisma.prisma ??
  new PrismaClient({
    log: process.env.NODE_ENV === "development" ? ["query", "error", "warn"] : ["error"],
  });

if (process.env.NODE_ENV !== "production") {
  globalForPrisma.prisma = prisma;
}
