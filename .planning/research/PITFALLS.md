# Domain Pitfalls

**Domain:** Flutter mobile app — app store launch readiness (account deletion, data privacy, security hardening)
**Researched:** 2026-03-21
**Project:** TrySomething v1.0

---

## Critical Pitfalls

Mistakes that cause app store rejection, data breaches, or require rewrites.

---

### Pitfall 1: RevenueCat Deletion Does Not Cancel the Subscription

**What goes wrong:** Developer calls RevenueCat's delete user API during account deletion, assumes the subscription is cancelled, marks the deletion complete. The user's App Store or Play Store subscription continues billing them. If they reinstall and create a new account, RevenueCat may create a duplicate customer record. The subscription receipt is still valid at the platform level even though the RevenueCat record is gone.

**Why it happens:** RevenueCat's customer deletion is a record-keeping operation — it removes the customer from RevenueCat's dashboard and metrics. It does NOT touch Apple's billing system or Google Play billing. Apple subscriptions cannot be cancelled programmatically by any third party, including developers. Google Play subscriptions CAN be cancelled via the Google Play Developer API but RevenueCat does not do this automatically.

**Consequences:**
- User continues to be billed after deleting their account — a serious consumer protection issue
- If user complains to Apple/Google, it reflects on the app's review standing
- App store submissions can be flagged if deletion flow is misleading

**Prevention:**
1. On the deletion confirmation screen, show explicit text: "Your subscription will continue until [date] — cancel it in Settings > Apple ID > Subscriptions before deleting your account"
2. Do NOT call RevenueCat's delete API as part of account deletion — the customer record is useful for refund/dispute resolution
3. Soft-delete the user row in your database (set `deletedAt`, anonymize PII) rather than hard-deleting, so RevenueCat's `revenuecatId` foreign key still resolves for any lingering webhook events
4. For Google Play, call the Google Play Developer API `purchases.subscriptions.cancel` before deleting the user record

**Detection:** Test on sandbox accounts: delete account, check App Store subscriptions settings — subscription should still show as active.

**Phase:** Account Deletion (Phase 1 of milestone)

---

### Pitfall 2: JWT Tokens Remain Valid After Account Deletion

**What goes wrong:** The `DELETE /api/users/me` endpoint deletes the user record from PostgreSQL. The user's access token (15-min TTL) and refresh token (30-day TTL) continue to work until they naturally expire. An attacker who stole a refresh token can continue using the API for up to 30 days after the account is deleted.

**Why it happens:** JWTs are stateless by design. The server does not check "does this user still exist" on every request — it only verifies the signature and expiry. Deleting the database row does not invalidate outstanding tokens.

**Consequences:**
- Deleted user's refresh token can be used to generate new access tokens for 30 days
- If a user deletes their account expecting all access to stop immediately, it does not
- Potential GDPR violation: processing requests from a deleted user's credentials

**Prevention:**
1. Implement a token version counter on the User model: `tokenVersion Int @default(0)`
2. Increment `tokenVersion` on account deletion (or embed it in the JWT at issue time and check on every request)
3. Simpler approach: maintain a Redis or in-memory blacklist for the user's `jti` claims or `userId` — check it on every authenticated request, with TTL matching the longest-lived token (30 days)
4. Most pragmatic for this stack (no Redis): add a `deletedAt` nullable field to the User model. Add a middleware check: `if (user.deletedAt) return 401`. This is one DB lookup per request but is simple and correct.
5. Purge all rows in a `RefreshToken` table (if one exists) or add such a table if denylist approach is used

**Detection:** Delete an account, immediately try to call `GET /api/users/me` with the old access token — it should return 401, not 200.

**Phase:** Account Deletion (Phase 1)

---

### Pitfall 3: Account Deletion Leaves Orphaned Data in Tables Without Cascade

**What goes wrong:** The delete endpoint correctly calls `prisma.user.delete()`, which triggers cascade deletes on all relations marked `onDelete: Cascade`. But the schema has some relations where cascade is not set (or set to `Restrict`/`SetNull`). The delete fails with a foreign key constraint violation, or worse, it succeeds but leaves orphaned rows in tables that were set to `SetNull`.

**Specific risk in this schema (25 models):** The schema has `GenerationLog` (userId FK — audit trail), `CommunityStory` (authorId), `StoryReaction` (userId), `BuddyPair` (userId + buddyId — two FKs on same table). If any of these are `onDelete: Restrict` or have no action defined, the delete will fail. If any are `onDelete: SetNull`, the row survives with a null userId — orphaned content that is unlinkable and uncleanable.

**Why it happens:** Prisma's default `onDelete` is `SetNull` for optional relations and `Restrict` for required relations. Developers often add models incrementally without auditing cascade behavior end-to-end.

**Consequences:**
- Delete endpoint throws 500 in production
- User cannot delete their account (app store violation)
- Orphaned `CommunityStory` rows with `authorId: null` show up in public feeds

**Prevention:**
1. Before writing the delete endpoint, run: `grep -n "onDelete" server/prisma/schema.prisma` and audit every relation for User-linked models
2. Write the delete as an explicit `prisma.$transaction([...])` that manually deletes in dependency order (children before parents) rather than relying on cascades alone
3. Test in a staging environment with a seeded user who has data in every table
4. Add a schema review step: for every model with a `userId` field, the PR for `DELETE /api/users/me` must include the cascade behavior decision in a comment

**Recommended delete order (dependency-safe):**
```
GenerationLog → UserActivityLog → UserAchievement → UserChallenge →
ShoppingCheck → ScheduleEvent → PersonalNote → JournalEntry →
UserCompletedStep → UserHobby → StoryReaction → CommunityStory →
BuddyPair → UserPreference → User
```

**Detection:** Seed a test user with rows in every table, run DELETE, verify zero rows remain across all tables, verify no 500 errors.

**Phase:** Account Deletion (Phase 1)

---

### Pitfall 4: Data Export Leaks Hashed Passwords and Internal Audit Data

**What goes wrong:** The `GET /api/users/me/export` endpoint fetches the user record and serializes it to JSON. The User model includes `passwordHash` (bcrypt hash). The developer thinks "it's just a hash, not the real password" — but the export goes to the user, who can now share it, and anyone with the hash can run offline attacks. Separately, `GenerationLog` includes every AI query the user sent — useful for fraud audits, but its `reason` field and `status` field are internal signals that should not be disclosed.

**Why it happens:** Developers serialize the entire Prisma model without an explicit allowlist. "Select all, exclude nothing" is the path of least resistance.

**Consequences:**
- Password hash in the export = offline brute force attack vector (even bcrypt is attackable given enough time)
- Internal audit fields leak implementation details — `GenerationLog.reason` reveals content safety decisions ("blocked: weapons keyword")
- RevenueCat IDs, Sentry user IDs, internal database IDs provide correlation vectors for attackers

**Prevention:**
1. Build the export endpoint with an explicit allowlist, never a blocklist:
   ```typescript
   // GOOD — only include what user owns and can read
   const exportData = {
     profile: { email, name, createdAt, updatedAt },
     preferences: { hoursPerWeek, budgetLevel, preferSocial, vibes },
     hobbies: userHobbies.map(h => ({ hobbyTitle, status, startedAt, streakDays })),
     journal: journalEntries.map(e => ({ content, createdAt, photoUrl })),
     // ...
   }
   // NOT: return user (includes passwordHash, revenuecatId, etc.)
   ```
2. Fields to explicitly EXCLUDE: `passwordHash`, `revenuecatId`, `generationLog` (entire table), `id` (internal integer PK — use `createdAt` for audit purposes instead)
3. Fields borderline — decide before implementation: `googleId`, `appleId` (OAuth provider IDs — include or exclude), FCM token (exclude — operational, not personal data)

**Detection:** Call the export endpoint on a test account, manually inspect every field in the JSON response, confirm no `passwordHash` key exists anywhere.

**Phase:** Data Export (Phase 2 of milestone)

---

### Pitfall 5: Apple Privacy Manifest Missing for Required Third-Party SDKs

**What goes wrong:** App is submitted to App Store Connect. The upload succeeds. Review team rejects with `ITMS-91061: Missing privacy manifest`. The app uses Firebase (FCM), RevenueCat, and PostHog — all of which are on Apple's list of "commonly used third-party SDKs" that require a `PrivacyInfo.xcprivacy` manifest file as of February 12, 2025.

**Why it happens:** This requirement is enforced at submission time by Apple's tooling. Flutter developers often work in Dart and forget that the iOS build layer links native SDKs. The Flutter package for Firebase, purchases_flutter, and posthog_flutter all link their respective iOS native SDKs. If any linked SDK on Apple's required list lacks a privacy manifest, the build is rejected.

**Consequences:**
- Hard rejection at App Store Connect upload — not even a review team rejection, an automated toolchain rejection
- Firebase 10.22.0+ (March 2024) added privacy manifest support — must verify the version in `ios/Podfile.lock`
- RevenueCat's `purchases-ios` SDK added privacy manifest support — verify via `Add Apple privacy manifest · Issue #1064 · RevenueCat/purchases-flutter`

**Prevention:**
1. Before submission, run `xcodebuild -showBuildSettings` and inspect all linked pods for `PrivacyInfo.xcprivacy` files
2. Verify Firebase iOS SDK version is 10.22.0 or higher in `ios/Podfile.lock`
3. Verify `purchases_flutter` is at a version that includes the privacy manifest (check the CHANGELOG)
4. For PostHog: check `posthog-ios` CHANGELOG for privacy manifest addition; if not present, file a support issue and add a manual `PrivacyInfo.xcprivacy` for the app target covering the APIs PostHog accesses
5. Add a custom `ios/PrivacyInfo.xcprivacy` for any app-level APIs accessed (UserDefaults, file timestamps, disk space) — this is in addition to SDK-level manifests

**Detection:** Test submission to App Store Connect TestFlight (not just `flutter build ipa`) — the upload process runs validation that catches `ITMS-91061` before a human reviewer sees it.

**Phase:** App Store Prep (Phase 5 of milestone)

---

## Moderate Pitfalls

Mistakes that cause delays, security gaps, or poor user experience.

---

### Pitfall 6: RevenueCat Webhook Authorization Header vs. HMAC Signature

**What goes wrong:** Developer reads "webhook signature verification" in the task description and implements HMAC-SHA256 verification (like Stripe). RevenueCat does NOT support HMAC payload signing. Its security model is an Authorization header with a static secret set in the RevenueCat dashboard. Implementing HMAC verification means every legitimate webhook from RevenueCat fails to authenticate — all subscription events are silently dropped.

**Why it happens:** RevenueCat's webhook security model is simpler than Stripe/GitHub. The community documentation calls this out clearly, but the terminology "signature verification" implies HMAC to most developers who have worked with other webhook providers.

**Consequences:**
- All subscription events (purchases, cancellations, renewals, refunds) fail to update the database
- Users who cancel subscriptions stay as "Pro" forever
- Users who subscribe stay as "Free" until they next open the app (which triggers a client-side entitlement check)

**Prevention:**
1. Use header-based auth only: in the webhook handler, verify `req.headers['authorization'] === process.env.REVENUECAT_WEBHOOK_SECRET`
2. Additionally, call RevenueCat's `GET /subscribers/{app_user_id}` REST API to verify the subscription state reported in the webhook matches RevenueCat's own records before updating the database — this is the recommended secondary verification
3. Add replay protection: store a 30-day rolling window of processed webhook `event.id` values (in the database or Hive) and reject duplicates. RevenueCat retries up to 5 times on 60s timeout — idempotent processing is required.

**Detection:** Send a test webhook from RevenueCat dashboard → server logs should show the event processed, not 401.

**Phase:** RevenueCat Webhook (Phase 4 of milestone)

---

### Pitfall 7: AI Model Upgrade Changes Output Schema Silently

**What goes wrong:** `outputs/ai_generator.ts` upgrades the model from `claude-haiku-4-5-20251001` to `claude-sonnet-4-6`. Sonnet is more capable but also more verbose and more likely to add explanatory text around JSON. The parsing code does `JSON.parse(response.content[0].text)` — if Sonnet adds a markdown code block wrapper (` ```json ... ``` `) or a preamble sentence, this throws a SyntaxError. The generation endpoint returns 500. Users cannot generate new hobbies or get coach responses.

**Why it happens:** Haiku was tuned to be more direct and structured. Sonnet, despite the same system prompt, may exhibit different formatting tendencies, especially when the prompt is ambiguous about output format. The upgraded prompts in `outputs/ai_generator.ts` use temperature 0.2-0.3 which helps, but JSON extraction robustness is still required.

**Consequences:**
- Hobby generation fails silently — user gets "Something went wrong" toast
- Coach conversations break on first message if the coach prompt similarly fails
- Difficult to diagnose in production without structured logging

**Prevention:**
1. Add robust JSON extraction before `JSON.parse`:
   ```typescript
   function extractJson(text: string): string {
     // Strip markdown code blocks
     const match = text.match(/```(?:json)?\s*([\s\S]*?)```/);
     if (match) return match[1].trim();
     // Strip any leading text before first {
     const start = text.indexOf('{');
     const end = text.lastIndexOf('}');
     if (start !== -1 && end !== -1) return text.slice(start, end + 1);
     return text;
   }
   ```
2. Run the upgraded prompts against 20+ test queries in staging before deploying, comparing output schemas field-by-field against what the Flutter app expects
3. Log the raw AI response (before JSON parse) in `GenerationLog` during the first week post-deploy — this catches formatting issues immediately
4. The upgrade files already include `validateHobbyOutput()` — ensure that function is called and failures return the `{"error":"invalid"}` sentinel, not a 500

**Detection:** In staging, call `POST /api/generate/hobby` with 10 diverse queries. All should return valid JSON matching the Hobby schema.

**Phase:** Sonnet AI Upgrade (Phase 3 of milestone)

---

### Pitfall 8: Dead Code Removal Breaks Shared Components Still Used by Active Screens

**What goes wrong:** `buddy_mode_screen.dart` is deleted along with its imports. The developer removes the corresponding provider `social_repository_api.dart` because it was only referenced by the deleted screen. But `you_screen.dart` also imports `social_repository` to display `CommunityStory` thumbnails in the "Tried" section. `dart analyze` passes because the import was removed from the deleted file — but the active screen now has a broken import. The error surfaces only at build time.

**Why it happens:** Screens being deleted have hidden shared dependencies with active screens. The dead code is identifiable, but its shared dependencies are not always identifiable by file-based inspection alone. Riverpod providers may have no `@riverpod` annotation consumers that are visible in the removed file — they may be consumed deeper in shared components.

**Consequences:**
- Build failure after "straightforward" dead code removal
- If the developer also removes model classes (e.g., `social.dart` — `CommunityStory`, `BuddyPair`), those are used in active providers and will cause type errors
- Provider tree can break at runtime if a provider that was keeping another alive is removed

**Prevention:**
1. **Before deleting any file**, run `gitnexus_impact({target: "ClassName", direction: "upstream"})` for every exported symbol in that file — this is mandatory per the CLAUDE.md GitNexus protocol
2. Use `dart analyze` after EACH file deletion, not at the end of all deletions — isolates breakage immediately
3. Do not delete model files (e.g., `social.dart`) just because the screen was deleted — models may be referenced in repositories that serve active screens
4. Safe order: (1) delete route from `router.dart`, (2) run analyze, (3) delete screen file, (4) run analyze, (5) delete providers ONLY if analyze confirms zero references
5. Check `providers/repository_providers.dart` — it registers all repositories at the DI layer. Removing a repository registration there breaks any provider that `ref.watch()`s it, even if the screen is gone.

**Detection:** After each file deletion, run `flutter analyze lib/` and verify zero errors before deleting the next file.

**Phase:** Dead Code Cleanup (Phase 6 of milestone)

---

### Pitfall 9: Apple App Store Screenshot Submission Uses Wrong Device Size

**What goes wrong:** Developer screenshots the app on a Nothing Phone 3a (Android 6.3-inch display). Submits those screenshots for iOS. App Store Connect rejects with "Screenshots do not match required device dimensions." Or worse: the developer submits correct-size screenshots (1290 x 2796 for 6.9-inch iPhone) but they were captured with the Flutter debug banner still visible. Apple rejects on review.

**Why it happens:** As of 2025, Apple requires 6.9-inch iPhone screenshots (1290 x 2796px) as mandatory for all submissions — the 6.5-inch screenshots that were mandatory previously are still accepted but the 6.9-inch is now the primary. Developers working Android-first often use Android device screenshots. The Flutter debug banner appears in debug builds and must be explicitly suppressed.

**Consequences:**
- App Store Connect validation error on upload (device size mismatch)
- App review rejection (debug banner, content not matching actual app)
- 13-inch iPad screenshots now required if the app supports iPad (even if not optimized)

**Prevention:**
1. Capture iOS screenshots using Xcode Simulator with iPhone 16 Pro Max (6.9-inch) — not from physical Android device
2. Always build in release mode for screenshot capture: `flutter build ipa --release` then screenshot via Simulator
3. Verify `debugShowCheckedModeBanner: false` in `MaterialApp` widget in `main.dart` (already likely set, but confirm)
4. Required sizes for submission: 6.9-inch iPhone (1290x2796) is mandatory; 6.5-inch (1242x2688) no longer required but accepted
5. If the app is iPad-capable, also provide 13-inch iPad (2064x2752) screenshots
6. For Google Play: use the AAB format (`flutter build appbundle`) — APK submissions are no longer accepted. Target SDK must be Android 14 (API 34) minimum, Android 15 (API 35) required for new apps as of August 31, 2025.

**Detection:** Run app through App Store Connect "Prepare for Submission" flow and look at screenshot validation errors before the app goes to review.

**Phase:** App Store Prep (Phase 5 of milestone)

---

### Pitfall 10: Google Play Data Safety Form Inaccurate for AI and Analytics SDKs

**What goes wrong:** Developer fills out Google Play's Data Safety form quickly, marking "No data collected." But the app uses PostHog (analytics), Firebase (FCM + crash reporting via Sentry), RevenueCat (purchase history), and the AI coach (sends hobby context and user messages to Anthropic's API). All of these involve data collection. Google Play can reject the app or suspend it if the Data Safety form materially misrepresents data practices.

**Why it happens:** The Data Safety form is long and the data types are granular. Developers underestimate what "data collection" means — it includes data sent to third-party SDKs even if the developer never directly sees it.

**Consequences:**
- App rejection with reason "Data Safety form inaccurate"
- If approved with inaccurate form and later flagged, app can be suspended
- User trust damage if privacy label says "no data collected" but PostHog is pinging

**Required declarations for this stack:**
- **Personal info (email address):** Collected, not optional, for core functionality
- **User IDs:** Collected (JWT sub, RevenueCat ID)
- **Purchase history:** Shared with RevenueCat (third party)
- **App activity:** Collected (PostHog session events, screen views)
- **App diagnostics:** Shared (Sentry crash reports)
- **Device or other IDs:** Collected (FCM registration token)
- **User-generated content:** Collected (journal entries, coach messages)

**Prevention:**
1. Before filling the form, list every SDK and what data it sends: PostHog (device info, session data, events), Firebase FCM (device token), Sentry (stack traces, device info), RevenueCat (purchase receipts, user ID), Anthropic (coach message text in API calls)
2. Check RevenueCat's published Data Safety guidance in their community forum — they provide suggested answers for the Data Safety form
3. Mark "Account deletion supported" — the deletion endpoint built in Phase 1 qualifies

**Phase:** App Store Prep (Phase 5 of milestone)

---

## Minor Pitfalls

---

### Pitfall 11: Coach Rate Limit Reset Exploitable via App Reinstall (Hive-Only)

**What goes wrong:** The current `_CoachLimitTracker` stores usage counts in Hive cache keyed by `year_month`. Uninstalling and reinstalling the app clears Hive. A free user can send unlimited coach messages by uninstalling between sessions. With the server-side rate limiting migration (using `GenerationLog`), this is fixed — but if the Hive client check is removed BEFORE the server-side check is confirmed working, there is a window with no limits at all.

**Prevention:** When migrating rate limiting from Hive to `GenerationLog`, implement and verify the server-side check BEFORE removing the Hive client check. Run both in parallel for one release cycle. The server-side check should return HTTP 429 which the client handles by showing the upgrade prompt.

**Phase:** Coach Rate Limiting (Phase 3 of milestone)

---

### Pitfall 12: Terms & Privacy Policy URLs Hardcoded to Non-HTTPS Links

**What goes wrong:** Privacy Policy is hosted on a static page. The URL is added to settings screen as `http://trysomething.ch/privacy`. Apple App Store and Google Play both require privacy policy URLs to be accessible via HTTPS, served at a stable URL that doesn't redirect. If the URL 404s or redirects at review time, the submission is rejected.

**Prevention:**
1. Host at a stable HTTPS URL before submission
2. Test the URL from an iOS device (not your development machine) to verify it loads
3. Apple also checks that the privacy policy URL in App Store Connect metadata matches or is consistent with what's shown in-app

**Phase:** Terms & Privacy (Phase 5 of milestone)

---

### Pitfall 13: Prisma Migration Not Committed to Git

**What goes wrong:** The `DELETE /api/users/me` endpoint requires schema changes (adding `deletedAt` nullable field, possibly a token version counter). Developer runs `prisma migrate dev` locally. The migration exists only in Neon (production) and local environment. Another developer (or a future redeploy) runs `prisma migrate deploy` and gets migration conflicts. Rollback is impossible because there is no migration history in the repo.

**Prevention:**
1. All `prisma migrate dev` runs must be committed: commit the generated file in `server/prisma/migrations/`
2. Never use `prisma db push` in production (it bypasses migration history)
3. Document the schema versioning in the PR that adds `deletedAt`

**Phase:** Account Deletion (Phase 1)

---

### Pitfall 14: Vercel Serverless Cold Start Causes Webhook Timeout

**What goes wrong:** RevenueCat sends a webhook event (subscription renewed). The Vercel serverless function is cold (no recent traffic). Cold start takes 2-4 seconds. RevenueCat has a 60-second timeout for webhooks, so the event is eventually processed — but during a traffic spike (many users renewing at the same time), Prisma connection pool exhaustion on Neon free tier (100 connections) causes timeout. RevenueCat retries the failed events. Without idempotency protection, the subscription update runs multiple times.

**Prevention:**
1. Webhook handler must be idempotent: check if the event's `event.id` was already processed before updating the database
2. Use Prisma's `upsert` or check `existing = await prisma.userHobby.findFirst({where: {userId, processed: true}})` pattern
3. The 100-connection Neon limit is a real concern — webhook handlers should use minimal Prisma queries (one read, one write max)

**Phase:** RevenueCat Webhook (Phase 4)

---

## Phase-Specific Warnings

| Phase Topic | Likely Pitfall | Mitigation |
|-------------|---------------|------------|
| Account Deletion | RevenueCat subscription still active after DB delete | Show explicit "cancel subscription first" warning in UI; document that deletion does not cancel billing |
| Account Deletion | JWT tokens valid 30 days after user row deleted | Add `deletedAt` check in auth middleware; return 401 for deleted users |
| Account Deletion | Cascade delete fails on unsupported FK relations | Audit every FK in schema.prisma before writing the endpoint; use explicit transaction order |
| Data Export | `passwordHash` included in serialized User | Use explicit allowlist in export, never full model serialize |
| Data Export | `GenerationLog` leaks content safety decision reasons | Exclude entire `GenerationLog` table from export — it is an audit tool, not user data |
| Sonnet Upgrade | JSON parsing fails if Sonnet adds markdown wrappers | Add `extractJson()` helper before `JSON.parse()`; validate output schema with `validateHobbyOutput()` |
| RevenueCat Webhook | HMAC-based verification blocks all legitimate webhooks | RevenueCat uses header auth only, not payload signing — use `Authorization` header check |
| RevenueCat Webhook | Duplicate event processing on retry | Store processed `event.id` values; use idempotent DB upsert patterns |
| Dead Code Cleanup | Shared models/providers deleted with screens | Run `gitnexus_impact` on every exported symbol before deleting; run `dart analyze` after each file deletion |
| App Store Prep | Privacy manifest missing for Firebase/RevenueCat/PostHog | Verify each SDK version includes `PrivacyInfo.xcprivacy`; add app-level manifest for system API access |
| App Store Prep | Screenshots from Android device rejected for iOS | Capture iOS screenshots on Xcode Simulator, iPhone 16 Pro Max dimensions |
| App Store Prep | Google Play Data Safety form underreports SDK data collection | Enumerate all SDKs and their data; PostHog/RevenueCat/Sentry all require disclosure |
| Coach Rate Limiting | Window with no limits if Hive check removed before server check verified | Migrate server-side first, run in parallel, then remove Hive check |

---

## Sources

- [Apple: Offering account deletion in your app](https://developer.apple.com/support/offering-account-deletion-in-your-app/) — HIGH confidence (official Apple documentation)
- [Apple TN3194: Handling account deletions and revoking tokens for Sign in with Apple](https://developer.apple.com/documentation/technotes/tn3194-handling-account-deletions-and-revoking-tokens-for-sign-in-with-apple) — HIGH confidence (official Apple technote)
- [RevenueCat: Account deletion rules on the App Store](https://www.revenuecat.com/blog/engineering/app-store-account-deletion/) — MEDIUM confidence (official RevenueCat engineering blog)
- [RevenueCat: How to handle subscription when deleting a user](https://community.revenuecat.com/general-questions-7/how-to-handle-subscription-when-deleting-a-user-4339) — MEDIUM confidence (official RevenueCat community)
- [RevenueCat: Best practices on handling webhooks](https://community.revenuecat.com/general-questions-7/best-practices-on-handling-webhooks-5054) — MEDIUM confidence (official RevenueCat community)
- [RevenueCat: Webhook message verification](https://community.revenuecat.com/sdks-51/webhook-message-verification-7165) — MEDIUM confidence (confirms no HMAC signing, header-only)
- [Apple: Privacy updates for App Store submissions (Feb 2025 manifest requirement)](https://developer.apple.com/news/?id=3d8a9yyh) — HIGH confidence (official Apple developer news)
- [RevenueCat purchases-flutter: Add Apple privacy manifest Issue #1064](https://github.com/RevenueCat/purchases-flutter/issues/1064) — MEDIUM confidence (official repo issue)
- [Google Play: Understanding app account deletion requirements](https://support.google.com/googleplay/android-developer/answer/13327111) — HIGH confidence (official Google Play policy)
- [Webhook security: Preventing replay attacks](https://dohost.us/index.php/2026/02/15/preventing-replay-attacks-implementing-timestamps-and-nonces-in-webhook-handlers/) — MEDIUM confidence (community guide, February 2026)
- [JWT invalidation after account deletion](https://www.descope.com/blog/post/jwt-logout-risks-mitigations) — MEDIUM confidence (security vendor documentation)
- [Promptfoo: Model upgrades break agent safety](https://www.promptfoo.dev/blog/model-upgrades-break-agent-safety/) — MEDIUM confidence (verified with Anthropic knowledge of Sonnet behavior)
- [App Store screenshot requirements 2025-2026](https://www.mobileaction.co/guide/app-screenshot-sizes-and-guidelines-for-the-app-store/) — MEDIUM confidence (multiple sources agree on 6.9-inch requirement)
- Project CONCERNS.md — HIGH confidence (direct codebase analysis, 2026-03-21)
