-- CreateTable
CREATE TABLE "MatchCache" (
    "id" TEXT NOT NULL,
    "profileHash" TEXT NOT NULL,
    "resultJson" JSONB NOT NULL,
    "source" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "expiresAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "MatchCache_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "MatchCache_profileHash_key" ON "MatchCache"("profileHash");

-- CreateIndex
CREATE INDEX "MatchCache_expiresAt_idx" ON "MatchCache"("expiresAt");

