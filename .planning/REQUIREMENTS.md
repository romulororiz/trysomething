# Requirements: TrySomething

**Defined:** 2026-03-21
**Core Value:** A user can discover a hobby that fits them, start it with clear first steps, and stick with it for 30 days.

## v1.0 Requirements

Requirements for App Store and Play Store submission readiness.

### Compliance

- [ ] **COMP-01**: User can delete their account via confirmation dialog in Settings screen
- [ ] **COMP-02**: Account deletion uses soft-delete (`deletedAt` field) with 30-day deferred purge
- [ ] **COMP-03**: Account deletion cascades across all 14 user-related tables + GenerationLog
- [ ] **COMP-04**: Account deletion clears all client-side storage (Hive, SharedPreferences, secure storage, RevenueCat logout)
- [ ] **COMP-05**: Account deletion UI warns user to cancel subscription manually before proceeding
- [ ] **COMP-06**: Auth middleware rejects tokens for soft-deleted users (`deletedAt` check)
- [ ] **COMP-07**: User can export all personal data as JSON via `GET /api/users/me/export`
- [ ] **COMP-08**: Data export uses explicit field allowlist (excludes `passwordHash`, `revenuecatId`, `GenerationLog` internals)
- [ ] **COMP-09**: Terms of Service hosted as public HTML page on Next.js website
- [ ] **COMP-10**: Privacy Policy hosted as public HTML page on Next.js website
- [ ] **COMP-11**: Settings screen links to hosted Terms and Privacy Policy
- [ ] **COMP-12**: iOS app includes Apple Privacy Manifests for Firebase, RevenueCat, and PostHog SDKs
- [ ] **COMP-13**: App Privacy Labels completed in App Store Connect (requires hosted privacy policy)
- [ ] **COMP-14**: Data Safety Form completed in Google Play Console (requires hosted privacy policy)

### Security

- [x] **SEC-01**: RevenueCat webhook verifies Authorization header and fails closed (rejects when env var unset)
- [x] **SEC-02**: Coach rate limiting enforced server-side via GenerationLog count query (replaces client-side Hive check)
- [ ] **SEC-03**: Apple OAuth routing fixed in `vercel.json` (add `|apple` to auth action regex)

### AI

- [ ] **AI-01**: AI generation upgraded from Haiku to Sonnet (deploy `outputs/ai_generator.ts` and `outputs/action.ts`)
- [ ] **AI-02**: Coach stale detection uses `lastActivityAt` instead of `startedAt` for days-inactive calculation
- [ ] **AI-03**: AI response parsing includes `extractJson()` guard for Sonnet output format safety

### Subscription

- [ ] **SUB-01**: Restore Purchases button available on paywall screen and/or Settings (Apple guideline 3.1.1)

### Cleanup

- [ ] **CLEAN-01**: Remove 7 hidden feature screens (~7,000 lines) with GitNexus impact analysis per file before deletion

### Developer Experience

- [ ] **DX-01**: Pre-commit hooks via Lefthook enforcing TypeScript lint (`server/`) + Flutter analyze (`lib/`)

## v2 Requirements

Deferred to v1.1 milestone. Tracked but not in current roadmap.

### Code Quality

- **QUAL-01**: Co-locate mapper functions with their consumers (currently centralized in `mappers.ts`)
- **QUAL-02**: Add golden triangle tests for shared middleware (`errorResponse`, `methodNotAllowed`, `requireAuth`)
- **QUAL-03**: Refactor oversized screens (profile 2,021 lines, home 1,977, discover 1,813, settings 1,564, you 1,346)
- **QUAL-04**: Clean dead mapper functions (`mapChallengeResponse`, `mapActivityLog`, etc.)

## Out of Scope

| Feature | Reason |
|---------|--------|
| Buddy mode / Community stories / Local discovery | Routes already removed; screens deleted in CLEAN-01 |
| Real-time chat | Not core to hobby guidance; high complexity |
| Multi-language / i18n | English-only for v1.0 launch |
| Custom push notification scheduling | FCM already works; advanced scheduling is v2 |
| OAuth providers beyond Google + Apple | Two providers sufficient for v1.0 |
| Redis/Upstash rate limiting | GenerationLog + Postgres is sufficient at current scale |
| Hard account deletion | Soft-delete chosen for JWT/webhook safety; purge after 30 days |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| COMP-01 | Phase 4 | Pending |
| COMP-02 | Phase 4 | Pending |
| COMP-03 | Phase 4 | Pending |
| COMP-04 | Phase 5 | Pending |
| COMP-05 | Phase 5 | Pending |
| COMP-06 | Phase 4 | Pending |
| COMP-07 | Phase 4 | Pending |
| COMP-08 | Phase 4 | Pending |
| COMP-09 | Phase 3 | Pending |
| COMP-10 | Phase 3 | Pending |
| COMP-11 | Phase 3 | Pending |
| COMP-12 | Phase 9 | Pending |
| COMP-13 | Phase 9 | Pending |
| COMP-14 | Phase 9 | Pending |
| SEC-01 | Phase 1 | Complete |
| SEC-02 | Phase 1 | Complete |
| SEC-03 | Phase 2 | Pending |
| AI-01 | Phase 8 | Pending |
| AI-02 | Phase 8 | Pending |
| AI-03 | Phase 8 | Pending |
| SUB-01 | Phase 6 | Pending |
| CLEAN-01 | Phase 7 | Pending |
| DX-01 | Phase 10 | Pending |

**Coverage:**
- v1.0 requirements: 23 total
- Mapped to phases: 23
- Unmapped: 0

---
*Requirements defined: 2026-03-21*
*Last updated: 2026-03-21 — Traceability populated after roadmap creation*
