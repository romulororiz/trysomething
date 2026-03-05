-- CreateEnum
CREATE TYPE "HobbyStatus" AS ENUM ('saved', 'trying', 'active', 'done');

-- CreateTable
CREATE TABLE "UserHobby" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "hobbyId" TEXT NOT NULL,
    "status" "HobbyStatus" NOT NULL DEFAULT 'saved',
    "startedAt" TIMESTAMP(3),
    "completedAt" TIMESTAMP(3),
    "lastActivityAt" TIMESTAMP(3),
    "streakDays" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "UserHobby_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "UserCompletedStep" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "hobbyId" TEXT NOT NULL,
    "stepId" TEXT NOT NULL,
    "completedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "UserCompletedStep_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "UserActivityLog" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "hobbyId" TEXT,
    "action" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "UserActivityLog_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "UserHobby_userId_hobbyId_key" ON "UserHobby"("userId", "hobbyId");

-- CreateIndex
CREATE UNIQUE INDEX "UserCompletedStep_userId_hobbyId_stepId_key" ON "UserCompletedStep"("userId", "hobbyId", "stepId");

-- CreateIndex
CREATE INDEX "UserActivityLog_userId_createdAt_idx" ON "UserActivityLog"("userId", "createdAt");

-- AddForeignKey
ALTER TABLE "UserHobby" ADD CONSTRAINT "UserHobby_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "UserCompletedStep" ADD CONSTRAINT "UserCompletedStep_userId_hobbyId_fkey" FOREIGN KEY ("userId", "hobbyId") REFERENCES "UserHobby"("userId", "hobbyId") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "UserActivityLog" ADD CONSTRAINT "UserActivityLog_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
