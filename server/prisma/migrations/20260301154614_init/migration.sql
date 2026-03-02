-- CreateTable
CREATE TABLE "Category" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "imageUrl" TEXT NOT NULL,
    "sortOrder" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "Category_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Hobby" (
    "id" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "hook" TEXT NOT NULL,
    "categoryId" TEXT NOT NULL,
    "imageUrl" TEXT NOT NULL,
    "tags" TEXT[],
    "costText" TEXT NOT NULL,
    "timeText" TEXT NOT NULL,
    "difficultyText" TEXT NOT NULL,
    "whyLove" TEXT NOT NULL,
    "difficultyExplain" TEXT NOT NULL,
    "pitfalls" TEXT[],
    "sortOrder" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "Hobby_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "KitItem" (
    "id" TEXT NOT NULL,
    "hobbyId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "cost" INTEGER NOT NULL,
    "isOptional" BOOLEAN NOT NULL DEFAULT false,
    "sortOrder" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "KitItem_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "RoadmapStep" (
    "id" TEXT NOT NULL,
    "hobbyId" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "estimatedMinutes" INTEGER NOT NULL,
    "milestone" TEXT,
    "sortOrder" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "RoadmapStep_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "FaqItem" (
    "id" TEXT NOT NULL,
    "hobbyId" TEXT NOT NULL,
    "question" TEXT NOT NULL,
    "answer" TEXT NOT NULL,
    "upvotes" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "FaqItem_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "CostBreakdown" (
    "id" TEXT NOT NULL,
    "hobbyId" TEXT NOT NULL,
    "starter" INTEGER NOT NULL,
    "threeMonth" INTEGER NOT NULL,
    "oneYear" INTEGER NOT NULL,
    "tips" TEXT[],

    CONSTRAINT "CostBreakdown_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "BudgetAlternative" (
    "id" TEXT NOT NULL,
    "hobbyId" TEXT NOT NULL,
    "itemName" TEXT NOT NULL,
    "diyOption" TEXT NOT NULL,
    "diyCost" INTEGER NOT NULL,
    "budgetOption" TEXT NOT NULL,
    "budgetCost" INTEGER NOT NULL,
    "premiumOption" TEXT NOT NULL,
    "premiumCost" INTEGER NOT NULL,
    "sortOrder" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "BudgetAlternative_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "HobbyCombo" (
    "id" TEXT NOT NULL,
    "hobbyId1" TEXT NOT NULL,
    "hobbyId2" TEXT NOT NULL,
    "reason" TEXT NOT NULL,
    "sharedTags" TEXT[],

    CONSTRAINT "HobbyCombo_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SeasonalPick" (
    "id" TEXT NOT NULL,
    "hobbyId" TEXT NOT NULL,
    "season" TEXT NOT NULL,

    CONSTRAINT "SeasonalPick_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "MoodTag" (
    "id" TEXT NOT NULL,
    "hobbyId" TEXT NOT NULL,
    "mood" TEXT NOT NULL,

    CONSTRAINT "MoodTag_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "CostBreakdown_hobbyId_key" ON "CostBreakdown"("hobbyId");

-- CreateIndex
CREATE UNIQUE INDEX "HobbyCombo_hobbyId1_hobbyId2_key" ON "HobbyCombo"("hobbyId1", "hobbyId2");

-- CreateIndex
CREATE UNIQUE INDEX "SeasonalPick_hobbyId_season_key" ON "SeasonalPick"("hobbyId", "season");

-- CreateIndex
CREATE UNIQUE INDEX "MoodTag_hobbyId_mood_key" ON "MoodTag"("hobbyId", "mood");

-- AddForeignKey
ALTER TABLE "Hobby" ADD CONSTRAINT "Hobby_categoryId_fkey" FOREIGN KEY ("categoryId") REFERENCES "Category"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "KitItem" ADD CONSTRAINT "KitItem_hobbyId_fkey" FOREIGN KEY ("hobbyId") REFERENCES "Hobby"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RoadmapStep" ADD CONSTRAINT "RoadmapStep_hobbyId_fkey" FOREIGN KEY ("hobbyId") REFERENCES "Hobby"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "FaqItem" ADD CONSTRAINT "FaqItem_hobbyId_fkey" FOREIGN KEY ("hobbyId") REFERENCES "Hobby"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CostBreakdown" ADD CONSTRAINT "CostBreakdown_hobbyId_fkey" FOREIGN KEY ("hobbyId") REFERENCES "Hobby"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "BudgetAlternative" ADD CONSTRAINT "BudgetAlternative_hobbyId_fkey" FOREIGN KEY ("hobbyId") REFERENCES "Hobby"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "HobbyCombo" ADD CONSTRAINT "HobbyCombo_hobbyId1_fkey" FOREIGN KEY ("hobbyId1") REFERENCES "Hobby"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "HobbyCombo" ADD CONSTRAINT "HobbyCombo_hobbyId2_fkey" FOREIGN KEY ("hobbyId2") REFERENCES "Hobby"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SeasonalPick" ADD CONSTRAINT "SeasonalPick_hobbyId_fkey" FOREIGN KEY ("hobbyId") REFERENCES "Hobby"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MoodTag" ADD CONSTRAINT "MoodTag_hobbyId_fkey" FOREIGN KEY ("hobbyId") REFERENCES "Hobby"("id") ON DELETE CASCADE ON UPDATE CASCADE;
