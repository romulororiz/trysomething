# TrySomething

## What This Is

A mobile app for overwhelmed adults who want to pick up a hobby but don't know where to start. TrySomething matches users to one hobby based on their preferences, provides a structured 30-day guided start with step-by-step roadmaps, and offers AI coaching to keep them going. Built with Flutter (frontend) and Node.js/TypeScript on Vercel (backend), backed by Neon PostgreSQL and Claude AI.

## Core Value

A user can discover a hobby that fits them, start it with clear first steps, and stick with it for 30 days through guided support and coaching.

## Current Milestone: v1.0 Launch Readiness

**Goal:** Prepare the app for App Store and Play Store submission by resolving all compliance blockers, security gaps, and production readiness issues.

**Target scope:**
- Account deletion + data export (app store compliance)
- Apple OAuth fix (broken routing)
- Terms & Privacy hosting + in-app linking
- AI coach fixes (stale detection, rate limiting)
- Sonnet AI model upgrade
- RevenueCat webhook security
- Pre-commit hooks (DX quality gate)
- Dead code cleanup (7,000+ lines of removed features)

## Requirements

### Validated

- ✓ Onboarding quiz matches users to 3 hobby recommendations — Sprint A
- ✓ "Why this fits you" personalized explanations — Sprint A
- ✓ 3-tab navigation: Home, Discover, You — Sprint B
- ✓ Home dashboard with active hobby, next step, coach entry — Sprint B
- ✓ Discover feed with hero card, personalized rails, category browse — Sprint B
- ✓ You tab with saved/active/tried hobbies, journal, profile, settings — Sprint B
- ✓ Warm cinematic visual system (glass cards, floating dock, coral CTAs) — Sprint C
- ✓ Hobby detail page with commitment flow, 4-stage roadmap, quit reasons — Sprint D
- ✓ AI hobby coach with 3 modes (START/MOMENTUM/RESCUE) — Sprint E
- ✓ RevenueCat Pro subscription (CHF 4.99/mo, 7-day trial) — Sprint E
- ✓ Paywall and Pro feature locks — Sprint E
- ✓ Session screen with 4 phases (prepare/timer/reflect/complete) — Sprint D
- ✓ Particle formation timer with category shapes — Sprint D
- ✓ 150+ seed hobbies with AI generation for new ones — Sprint A
- ✓ JWT auth with Google OAuth — Sprint A
- ✓ PostHog analytics + Sentry error reporting — Sprint A
- ✓ Firebase push notifications — Sprint B
- ✓ Landing page (Next.js) — Sprint F

### Active

- [ ] Account deletion endpoint with cascading deletes + client cleanup
- [ ] Data export endpoint (FADP/GDPR portability)
- [ ] Apple OAuth routing fix
- [ ] Terms of Service & Privacy Policy hosting + in-app linking
- [ ] Coach stale detection fix (use lastActivityAt)
- [ ] Sonnet AI model upgrade (deploy prepared files)
- [ ] Server-side rate limiting for coach (move from Hive to GenerationLog)
- [ ] RevenueCat webhook signature verification
- [ ] Pre-commit hooks (Husky: TypeScript lint + Flutter analyze)
- [ ] Dead code cleanup (7 hidden feature screens, ~7,000 lines)

### Out of Scope

- Mapper function co-location (#12) — architectural cleanup, not user-facing, defer to v1.1
- Golden triangle tests for shared middleware (#13) — improves confidence but doesn't block launch
- Oversized screen refactoring (#14) — cosmetic tech debt, no user impact
- Dead mapper function cleanup (#11) — minor dead code, low priority vs screen cleanup
- Buddy mode, community stories, local discovery features — routes already removed, screens deleted in this milestone
- Real-time chat — not core to hobby guidance
- Multi-language support — English-only for v1.0

## Context

**Codebase state:** 6 sprints completed (A through F.3). Flutter 3.6.0 + Riverpod + GoRouter frontend, Node.js/TypeScript Vercel serverless backend, Prisma ORM with 25 models on Neon PostgreSQL. AI generation via Claude Haiku (upgrade to Sonnet prepared but not deployed).

**Codebase maps:** Full analysis in `.planning/codebase/` (STACK.md, ARCHITECTURE.md, STRUCTURE.md, CONVENTIONS.md, TESTING.md, INTEGRATIONS.md, CONCERNS.md) — produced 2026-03-21.

**Known issues from CONCERNS.md:** 5 critical, 10 high-priority items identified. This milestone addresses all critical and high items. Medium items deferred to v1.1.

**Test device:** Nothing Phone 3a (Android). iOS testing needed for Apple OAuth and App Store submission.

**Prepared but not deployed:**
- `outputs/ai_generator.ts` — Sonnet-ready generation prompts
- `outputs/action.ts` — Sonnet coach with single-mode injection

## Constraints

- **App Store compliance:** Apple requires account deletion (mandatory since 2022). Google Play requires it for apps with accounts.
- **FADP (Swiss data protection):** Art. 28 requires data portability — users must be able to export their data.
- **RevenueCat:** Entitlement ID is `pro`. Webhook verification needed before production traffic.
- **AI model:** Sonnet upgrade files ready — same API key, drop-in replacement for Haiku.
- **Budget:** Solo developer, cost-conscious — Vercel free tier, Neon free tier.
- **Tech stack:** Flutter + Node.js/Vercel — no stack changes in this milestone.

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Include all HIGH items in launch milestone | Security gaps (rate limiting, webhook verification) are exploitable in production | — Pending |
| Dead code cleanup with GitNexus safety net | 7,000+ lines removed with impact analysis to prevent breakage | — Pending |
| Defer mapper/screen refactoring to v1.1 | Internal quality, no user impact, doesn't block submission | — Pending |
| Keep Haiku → Sonnet as in-place upgrade | Prepared files are drop-in, same API key, no architecture change | — Pending |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd:transition`):
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `/gsd:complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-03-21 after initialization*
