-- Additive, row-safe: archived hobbies are hidden from discovery, never deleted.
ALTER TABLE "Hobby" ADD COLUMN IF NOT EXISTS "isPublished" BOOLEAN NOT NULL DEFAULT true;
