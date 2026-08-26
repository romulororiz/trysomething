# Runbook — Database backups & restore

> Neon free tier keeps only **6 hours** of point-in-time history. This nightly
> dump is the real safety net: RPO ≤ 24h, kept 14 days.

## How it works

`.github/workflows/db-backup.yml` runs nightly at 02:30 UTC (and on demand via
**Actions → DB Backup → Run workflow**):

1. Installs `postgresql-client-17` from PGDG — Neon runs PG 17 and the
   runner's default client 16 refuses newer servers.
2. `pg_dump --format=custom --compress=9` against the **direct** endpoint
   (the workflow strips any `-pooler` suffix — pg_dump must not go through
   PgBouncer).
3. Fails loudly if the dump is under 1 MB (empty/truncated dump guard).
4. Uploads as a workflow artifact, 14-day retention (~5–10 MB each; well
   inside the 500 MB private-repo quota).

**Requires** the repo secret `DATABASE_URL` (Settings → Secrets and variables
→ Actions): the production Neon connection string, same value as Vercel's.
Either form works — the workflow strips `-pooler` itself.

## Restore drill (run quarterly, and once right after merging this)

Never restore into production in place. Always into a branch.

### Part 1 — Neon PITR branch (~10 min, tests the built-in 6h window)

1. Neon console → project `quiet-paper-13757687` → Branches → New branch →
   parent `production` @ a timestamp ~1h ago → name `restore-drill`.
2. Connect (psql or Neon SQL editor) and verify:
   ```sql
   SELECT count(*) FROM "User";
   SELECT count(*), max("createdAt") FROM "JournalEntry";
   ```
3. Compare counts against production. Delete the branch.

### Part 2 — pg_restore of an actual dump (~20 min, validates this pipeline)

1. Download the latest artifact from the Actions run.
2. Create a throwaway Neon branch `restore-test` from `production`.
3. Restore into it (PG 17 client):
   ```bash
   pg_restore --no-owner --no-privileges \
     --dbname="postgresql://<user>:<pass>@<restore-test-host>/neondb?sslmode=require" \
     trysomething-<date>.dump
   ```
4. Verify: **26 tables** (25 Prisma models + `_prisma_migrations`), row counts
   match Part 1.
5. Delete the branch.

### Drill log

| Date | Part | Result | Notes |
|------|------|--------|-------|
| _(fill on first drill)_ | | | |

## Privacy note (FADP)

Dumps contain PII (emails, bcrypt hashes, journal entries). The 14-day
artifact retention bounds how long deleted-account data persists in backups,
consistent with the 30-day account purge. Artifacts are only accessible to
repo collaborators. If the repo ever gains collaborators, encrypt dumps
(`age -p`) before upload.
