# Deferred Items - Phase 08

- **Pre-existing test failure:** `test/cron-purge.test.ts` (5 tests) fails because `api/cron/purge-deleted-users.ts` does not exist. This file belongs to the account deletion phase (Phase 04) and is not related to AI upgrade work.
