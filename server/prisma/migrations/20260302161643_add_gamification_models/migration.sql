-- CreateTable
CREATE TABLE "CommunityStory" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "quote" TEXT NOT NULL,
    "hobbyId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "CommunityStory_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "StoryReaction" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "storyId" TEXT NOT NULL,
    "type" TEXT NOT NULL,

    CONSTRAINT "StoryReaction_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "BuddyPair" (
    "id" TEXT NOT NULL,
    "requesterId" TEXT NOT NULL,
    "accepterId" TEXT NOT NULL,
    "hobbyId" TEXT,
    "status" TEXT NOT NULL DEFAULT 'pending',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "BuddyPair_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "UserChallenge" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "challengeType" TEXT NOT NULL,
    "currentCount" INTEGER NOT NULL DEFAULT 0,
    "targetCount" INTEGER NOT NULL,
    "isCompleted" BOOLEAN NOT NULL DEFAULT false,
    "weekStart" TIMESTAMP(3) NOT NULL,
    "completedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "UserChallenge_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "UserAchievement" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "achievementId" TEXT NOT NULL,
    "unlockedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "UserAchievement_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "CommunityStory_createdAt_idx" ON "CommunityStory"("createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "StoryReaction_userId_storyId_type_key" ON "StoryReaction"("userId", "storyId", "type");

-- CreateIndex
CREATE INDEX "BuddyPair_requesterId_idx" ON "BuddyPair"("requesterId");

-- CreateIndex
CREATE INDEX "BuddyPair_accepterId_idx" ON "BuddyPair"("accepterId");

-- CreateIndex
CREATE UNIQUE INDEX "BuddyPair_requesterId_accepterId_key" ON "BuddyPair"("requesterId", "accepterId");

-- CreateIndex
CREATE INDEX "UserChallenge_userId_weekStart_idx" ON "UserChallenge"("userId", "weekStart");

-- CreateIndex
CREATE UNIQUE INDEX "UserChallenge_userId_challengeType_weekStart_key" ON "UserChallenge"("userId", "challengeType", "weekStart");

-- CreateIndex
CREATE UNIQUE INDEX "UserAchievement_userId_achievementId_key" ON "UserAchievement"("userId", "achievementId");

-- AddForeignKey
ALTER TABLE "CommunityStory" ADD CONSTRAINT "CommunityStory_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "StoryReaction" ADD CONSTRAINT "StoryReaction_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "StoryReaction" ADD CONSTRAINT "StoryReaction_storyId_fkey" FOREIGN KEY ("storyId") REFERENCES "CommunityStory"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "BuddyPair" ADD CONSTRAINT "BuddyPair_requesterId_fkey" FOREIGN KEY ("requesterId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "BuddyPair" ADD CONSTRAINT "BuddyPair_accepterId_fkey" FOREIGN KEY ("accepterId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "UserChallenge" ADD CONSTRAINT "UserChallenge_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "UserAchievement" ADD CONSTRAINT "UserAchievement_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
