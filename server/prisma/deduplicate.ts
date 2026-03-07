/**
 * Deduplicate hobbies in the database.
 *
 * Phase 1: Near-duplicate cleanup (semantically same hobbies with different titles)
 * Phase 2: Exact title duplicates (case-insensitive)
 *
 * For each group:
 *  - Keep the oldest one (earliest createdAt, or first in near-dupe list)
 *  - Re-point all UserHobby, JournalEntry, PersonalNote, ScheduleEvent,
 *    ShoppingCheck, GenerationLog records from duplicate IDs to the kept ID
 *  - Delete the duplicate hobbies (cascades KitItem, RoadmapStep, FaqItem, etc.)
 *
 * Run once: npx tsx prisma/deduplicate.ts
 */

import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

// Near-duplicate groups: keep the first ID, delete the rest.
const NEAR_DUPLICATE_GROUPS: string[][] = [
  ["martial-arts", "mixed-martial-arts", "mixed-martial-arts-mma", "mixed-martial-arts-training"],
  ["acting", "amateur-acting"],
];

/** Re-point all user-facing records from dupeId to keepId. */
async function repointRecords(keepId: string, dupeId: string): Promise<number> {
  let count = 0;

  // UserHobby: has @@unique([userId, hobbyId])
  const dupeUserHobbies = await prisma.userHobby.findMany({ where: { hobbyId: dupeId } });
  for (const uh of dupeUserHobbies) {
    const existing = await prisma.userHobby.findUnique({
      where: { userId_hobbyId: { userId: uh.userId, hobbyId: keepId } },
    });
    if (existing) {
      await prisma.userHobby.delete({ where: { id: uh.id } });
    } else {
      await prisma.userHobby.update({ where: { id: uh.id }, data: { hobbyId: keepId } });
    }
    count++;
  }

  // JournalEntry
  const journal = await prisma.journalEntry.updateMany({ where: { hobbyId: dupeId }, data: { hobbyId: keepId } });
  count += journal.count;

  // PersonalNote: has @@unique([userId, hobbyId, stepId])
  const dupeNotes = await prisma.personalNote.findMany({ where: { hobbyId: dupeId } });
  for (const note of dupeNotes) {
    const existing = await prisma.personalNote.findFirst({
      where: { userId: note.userId, hobbyId: keepId, stepId: note.stepId },
    });
    if (existing) {
      await prisma.personalNote.delete({ where: { id: note.id } });
    } else {
      await prisma.personalNote.update({ where: { id: note.id }, data: { hobbyId: keepId } });
    }
    count++;
  }

  // ScheduleEvent
  const schedule = await prisma.scheduleEvent.updateMany({ where: { hobbyId: dupeId }, data: { hobbyId: keepId } });
  count += schedule.count;

  // ShoppingCheck: has @@unique([userId, hobbyId, itemName])
  const dupeChecks = await prisma.shoppingCheck.findMany({ where: { hobbyId: dupeId } });
  for (const check of dupeChecks) {
    const existing = await prisma.shoppingCheck.findFirst({
      where: { userId: check.userId, hobbyId: keepId, itemName: check.itemName },
    });
    if (existing) {
      await prisma.shoppingCheck.delete({ where: { id: check.id } });
    } else {
      await prisma.shoppingCheck.update({ where: { id: check.id }, data: { hobbyId: keepId } });
    }
    count++;
  }

  // GenerationLog
  await prisma.generationLog.updateMany({ where: { hobbyId: dupeId }, data: { hobbyId: keepId } });

  return count;
}

async function main() {
  console.log("Scanning for duplicate hobbies (case-insensitive + near-duplicates)...\n");

  let totalDeleted = 0;
  let totalRepointed = 0;

  // ── Phase 1: Near-duplicate cleanup ──
  for (const group of NEAR_DUPLICATE_GROUPS) {
    const existing = await prisma.hobby.findMany({
      where: { id: { in: group } },
      select: { id: true, title: true },
      orderBy: { createdAt: "asc" },
    });

    if (existing.length <= 1) continue;

    const keep = existing[0];
    const dupeIds = existing.slice(1).map((h) => h.id);
    console.log(`  Near-dupe: keeping "${keep.title}" (${keep.id}), removing: ${dupeIds.join(", ")}`);

    for (const dupeId of dupeIds) {
      totalRepointed += await repointRecords(keep.id, dupeId);
    }
    await prisma.hobby.deleteMany({ where: { id: { in: dupeIds } } });
    totalDeleted += dupeIds.length;
  }

  // ── Phase 2: Exact title duplicates ──
  const allHobbies = await prisma.hobby.findMany({
    select: { id: true, title: true, createdAt: true },
    orderBy: { createdAt: "asc" },
  });

  const groups = new Map<string, { id: string; title: string; createdAt: Date }[]>();
  for (const h of allHobbies) {
    const key = h.title.toLowerCase().trim();
    const list = groups.get(key) ?? [];
    list.push(h);
    groups.set(key, list);
  }

  const dupeGroups = Array.from(groups.entries()).filter(([, list]) => list.length > 1);

  if (dupeGroups.length > 0) {
    console.log(`\n  Found ${dupeGroups.length} exact-title duplicate group(s):\n`);

    for (const [, hobbies] of dupeGroups) {
      const keep = hobbies[0];
      const dupes = hobbies.slice(1);
      const dupeIds = dupes.map((d) => d.id);

      console.log(`  "${keep.title}" — keeping "${keep.id}", removing ${dupeIds.length} duplicate(s): ${dupeIds.join(", ")}`);

      for (const dupeId of dupeIds) {
        totalRepointed += await repointRecords(keep.id, dupeId);
      }
      await prisma.hobby.deleteMany({ where: { id: { in: dupeIds } } });
      totalDeleted += dupeIds.length;
    }
  }

  if (totalDeleted === 0) {
    console.log("No duplicates found. Database is clean.");
  } else {
    console.log(`\nDone! Deleted ${totalDeleted} duplicate hobby(ies), re-pointed ${totalRepointed} user record(s).`);
  }
}

main()
  .catch((e) => {
    console.error("Deduplication failed:", e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
