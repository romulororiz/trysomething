# TrySomething

## What This Is

A mobile app for overwhelmed adults who want to pick up a hobby but don't know where to start. TrySomething matches users to one hobby based on their preferences, provides a structured 30-day guided start with step-by-step roadmaps, and offers AI coaching (Claude Sonnet) to keep them going. Built with Flutter (frontend) and Node.js/TypeScript on Vercel (backend), backed by Neon PostgreSQL. Session screen features a premium Apple Watch-style breathing ring.

## Core Value

A user can discover a hobby that fits them, start it with clear first steps, and stick with it for 30 days through guided support and coaching.

## Current Milestone: v1.2 Separation of Concerns Refactor

**Goal:** Reduce every screen file to <500 lines by extracting stateful widgets, providers, and reusable components into their own files. Pure code quality — no new features.

**Target files:**
- `home_screen.dart` (2,375 → ~400) — extract page variants, journal tiles, roadmap
- `settings_screen.dart` (2,082 → ~300) — extract edit profile sheet, photo picker
- `you_screen.dart` (1,654 → ~300) — extract 4 tab contents + card types
- `hobby_coach_screen.dart` (1,613 → ~400) — extract CoachNotifier, bubbles, composer
- `onboarding_screen.dart` (1,456 → ~200) — extract each onboarding step
- Remaining: journal, search, detail, discover screens

**Previous:** v1.1 shipped 2026-03-25 — Hobby lifecycle, monetization, AI image moderation, coach photo/voice input.

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
- ✓ 150+ seed hobbies with AI generation for new ones — Sprint A
- ✓ JWT auth with Google OAuth — Sprint A
- ✓ PostHog analytics + Sentry error reporting — Sprint A
- ✓ Firebase push notifications — Sprint B
- ✓ Landing page (Next.js) — Sprint F
- ✓ RevenueCat webhook fail-closed with timingSafeEqual — v1.0 Phase 1
- ✓ Server-side coach rate limiting via GenerationLog — v1.0 Phase 1
- ✓ Apple OAuth routing fixed — v1.0 Phase 2
- ✓ Terms of Service hosted on Next.js site — v1.0 Phase 3
- ✓ Privacy Policy hosted on Next.js site — v1.0 Phase 3
- ✓ Settings links to hosted Terms and Privacy Policy — v1.0 Phase 3
- ✓ Account deletion with cascading soft-delete + 30-day purge — v1.0 Phase 4
- ✓ Data export endpoint with field allowlist — v1.0 Phase 4
- ✓ Account deletion Flutter UI with email/OAuth flows — v1.0 Phase 5
- ✓ Subscription cancellation warning in deletion flow — v1.0 Phase 5
- ✓ Client-side storage wipe on account deletion — v1.0 Phase 5
- ✓ Restore Purchases button in Settings — v1.0 Phase 6
- ✓ Dead code cleanup: 7 hidden screens removed (~7,000 lines) — v1.0 Phase 7
- ✓ AI upgraded to Claude Sonnet with extractJson() guard — v1.0 Phase 8
- ✓ Coach stale detection uses lastActivityAt — v1.0 Phase 8
- ✓ Apple Privacy Manifest (CA92.1) — v1.0 Phase 9
- ✓ App Privacy Labels in App Store Connect — v1.0 Phase 9
- ✓ Data Safety Form in Google Play Console — v1.0 Phase 9
- ✓ Session screen breathing ring redesign — v1.0 Phase 9.1
- ✓ Pre-commit hooks via Lefthook — v1.0 Phase 10

### Active

- [ ] Hobby auto-completes to `done` when all roadmap steps are finished
- [ ] Celebration screen when completing final step (distinct from regular step completion)
- [ ] Home shows completed state with "pick your next hobby" CTA
- [ ] Completed hobbies appear in You tab "Tried" section
- [ ] Stop/abandon hobby action (free) — moves to Tried with no progress preserved
- [ ] Pause hobby action (Pro) — preserves progress, shows in paused state
- [ ] Resume paused hobby (Pro)
- [ ] Detail page: free users see hero + spec + Stage 1 only
- [ ] Detail page: Pro users see full FAQ, cost breakdown, budget alternatives

### Out of Scope

- Mapper function co-location — architectural cleanup, not user-facing
- Golden triangle tests for shared middleware — improves confidence but not user-facing
- Oversized screen refactoring — cosmetic tech debt, no user impact
- Buddy mode, community stories, local discovery — features deleted in v1.0
- Real-time chat — not core to hobby guidance
- Multi-language support — English-only for now

## Context

**Shipped v1.0** with 50,138 LOC Dart + 18,312 LOC TypeScript.
**Tech stack:** Flutter 3.6.0 + Riverpod + GoRouter, Node.js/TypeScript on Vercel, Prisma ORM with 25 models on Neon PostgreSQL, Claude Sonnet AI, RevenueCat subscriptions.
**Test device:** Nothing Phone 3a (Android).
**Landing page:** Next.js at trysomething.io with hosted Terms and Privacy Policy.

## Constraints

- **Budget:** Solo developer, cost-conscious — Vercel free tier, Neon free tier
- **Tech stack:** Flutter + Node.js/Vercel — no stack changes planned
- **AI model:** Claude Sonnet deployed, same API key architecture
- **RevenueCat:** Entitlement ID is `pro`, webhook verified

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Include all HIGH items in launch milestone | Security gaps exploitable in production | ✓ Good — all resolved |
| Dead code cleanup with impact analysis | 7,000+ lines safely removed | ✓ Good — zero breakage |
| Defer mapper/screen refactoring to v1.1 | Internal quality, no user impact | ✓ Good — shipped faster |
| Haiku → Sonnet as in-place upgrade | Drop-in, same API key | ✓ Good — seamless |
| Soft-delete over hard-delete | JWT tokens remain valid up to 30 days | ✓ Good — safe approach |
| Lefthook over Husky for pre-commit | No package.json at repo root | ✓ Good — language-agnostic |
| Single CustomPainter for breathing ring | More efficient than stacked widgets | ✓ Good — smooth animation |
| Film grain as static PNG overlay | Zero GPU cost vs dynamic noise | ✓ Good — indistinguishable |

## Evolution

This document evolves at phase transitions and milestone boundaries.

---
*Last updated: 2026-03-23 after v1.1 milestone start*
