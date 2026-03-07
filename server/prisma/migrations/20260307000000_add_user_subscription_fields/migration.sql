-- AlterTable
ALTER TABLE "User" ADD COLUMN     "proExpiresAt" TIMESTAMP(3),
ADD COLUMN     "proSince" TIMESTAMP(3),
ADD COLUMN     "revenuecatId" TEXT,
ADD COLUMN     "subscriptionTier" TEXT NOT NULL DEFAULT 'free';

-- CreateIndex
CREATE UNIQUE INDEX "User_revenuecatId_key" ON "User"("revenuecatId");
