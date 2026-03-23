-- AlterTable
ALTER TABLE "UserHobby" ADD COLUMN     "pausedAt" TIMESTAMP(3),
ADD COLUMN     "pausedDurationDays" INTEGER NOT NULL DEFAULT 0;
