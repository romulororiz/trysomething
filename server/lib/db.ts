import { PrismaClient } from "@prisma/client";

// Singleton Prisma client.
// In serverless (Vercel), reuse the client across warm invocations
// to avoid exhausting the connection pool.

const globalForPrisma = globalThis as unknown as { prisma: PrismaClient };

const basePrisma =
  globalForPrisma.prisma ??
  new PrismaClient({
    log: process.env.NODE_ENV === "development" ? ["query", "error", "warn"] : ["error"],
  });

if (process.env.NODE_ENV !== "production") {
  globalForPrisma.prisma = basePrisma;
}

// Resilience: a Vercel function instance can hold a Prisma connection across
// invocations (Fluid Compute), but if Neon recycles TCP connections during
// its maintenance window, the cached socket goes stale. The next query
// throws PrismaClientInitializationError ("Can't reach database server")
// even though the DB is healthy. The fix is to force-disconnect and let
// Prisma lazily re-open the pool on retry.
function isStaleConnectionError(err: unknown): boolean {
  if (!err || typeof err !== "object") return false;
  const e = err as { name?: string; message?: string };
  if (e.name === "PrismaClientInitializationError") return true;
  const msg = e.message ?? "";
  return (
    msg.includes("Can't reach database server") ||
    msg.includes("Connection refused") ||
    msg.includes("Connection terminated") ||
    msg.includes("connection closed")
  );
}

export const prisma = basePrisma.$extends({
  query: {
    $allModels: {
      async $allOperations({ args, query, operation, model }) {
        try {
          return await query(args);
        } catch (err) {
          if (!isStaleConnectionError(err)) throw err;
          console.warn(
            `[db] stale connection on ${model}.${operation}, reconnecting...`
          );
          try {
            await basePrisma.$disconnect();
          } catch {
            // ignore disconnect failures — we are about to reconnect anyway
          }
          // Retry once. Prisma lazily reopens the pool on the next query.
          return await query(args);
        }
      },
    },
  },
});
