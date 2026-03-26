# Roadmap: TrySomething

## Milestones

- ✅ **v1.0 Launch Readiness** — Phases 1-10 (shipped 2026-03-23)
- ✅ **v1.1 Hobby Lifecycle & Monetization** — Phases 11-14 (shipped 2026-03-23)
- 🚧 **v1.2 Separation of Concerns Refactor** — Phases 15-20 (in progress)

---

## Phases

<details>
<summary>✅ v1.0 Launch Readiness (Phases 1-10) -- SHIPPED 2026-03-23</summary>

- [x] **Phase 1: Server Security Hardening** — Close the live webhook vulnerability and replace bypassable client-side rate limit with server-side enforcement (completed 2026-03-21)
- [x] **Phase 2: Apple OAuth Routing Fix** — One-line vercel.json fix that unblocks Apple Sign-In testing on iOS (completed 2026-03-21)
- [x] **Phase 3: Legal Documents -- Host and Link** — Publish Terms and Privacy Policy to the Next.js site and wire up Settings links (completed 2026-03-21)
- [x] **Phase 4: Account Deletion + Data Export -- Backend** — Build DELETE and export endpoints with atomic cascade and FADP-compliant field allowlist (completed 2026-03-21)
- [x] **Phase 5: Account Deletion -- Flutter UX** — Settings flow with confirmation dialog, subscription warning, and full client-side storage wipe (completed 2026-03-21)
- [x] **Phase 6: Restore Purchases** — Add RevenueCat restore flow to paywall and Settings per Apple guideline 3.1.1 (completed 2026-03-21)
- [x] **Phase 7: Dead Code Cleanup** — Remove 7 hidden feature screens (~7,000 lines) safely via impact analysis (completed 2026-03-21)
- [x] **Phase 8: Sonnet AI Upgrade** — Deploy prepared Sonnet files; fix stale detection and add JSON extraction guard (completed 2026-03-22)
- [x] **Phase 9: App Store Assets and Admin** — Screenshots, privacy manifests, privacy labels, data safety form, metadata (completed 2026-03-22)
- [x] **Phase 9.1: Session Screen Redesign -- The Breathing Ring** (INSERTED) — Replace particle field with premium Apple Watch-style breathing ring (completed 2026-03-22)
- [x] **Phase 10: Pre-Commit Hooks** — Install Lefthook for Flutter analyze + TypeScript lint on every commit (completed 2026-03-22)

### Phase Details (v1.0 -- archived)

**Phase 1:** Requirements SEC-01, SEC-02 | 2/2 plans complete
**Phase 2:** Requirements SEC-03 | 1/1 plans complete
**Phase 3:** Requirements COMP-09, COMP-10, COMP-11 | 2/2 plans complete
**Phase 4:** Requirements COMP-01, COMP-02, COMP-03, COMP-06, COMP-07, COMP-08 | 2/2 plans complete
**Phase 5:** Requirements COMP-04, COMP-05 | 2/2 plans complete
**Phase 6:** Requirements SUB-01 | 1/1 plans complete
**Phase 7:** Requirements CLEAN-01 | 1/1 plans complete
**Phase 8:** Requirements AI-01, AI-02, AI-03 | 1/1 plans complete
**Phase 9:** Requirements COMP-12, COMP-13, COMP-14 | 2/2 plans complete
**Phase 9.1:** No requirements (inserted visual redesign) | 3/3 plans complete
**Phase 10:** Requirements DX-01 | 1/1 plans complete

</details>

<details>
<summary>✅ v1.1 Hobby Lifecycle & Monetization (Phases 11-14) -- SHIPPED 2026-03-23</summary>

- [x] **Phase 11: Lifecycle Schema Migration** — Add `paused` enum value and pause tracking fields to Prisma schema and Dart model (completed 2026-03-23)
- [x] **Phase 12: Hobby Completion Flow + Stop** — Server-side completion detection, celebration overlay, Home completed state, and free stop/abandon action (completed 2026-03-23)
- [x] **Phase 13: Detail Page Content Gating** — Free vs Pro content sections with `ProGateSection` widget and server-side endpoint guards (completed 2026-03-23)
- [x] **Phase 14: Pause/Resume Lifecycle** — Pro-gated pause action, paused state display, resume, Pro-lapse auto-resume, and streak-safe pause duration tracking (completed 2026-03-23)

### Phase Details (v1.1 -- archived)

**Phase 11:** Requirements SCHM-01, SCHM-02, SCHM-03 | 2/2 plans complete
**Phase 12:** Requirements COMP-01, COMP-02, COMP-03, COMP-04, LIFE-01 | 2/2 plans complete
**Phase 13:** Requirements GATE-01, GATE-02, GATE-03, GATE-04, GATE-05, GATE-06 | 2/2 plans complete
**Phase 14:** Requirements LIFE-02, LIFE-03, LIFE-04, LIFE-05, LIFE-06, LIFE-07 | 2/2 plans complete

</details>

---

### v1.2 Separation of Concerns Refactor (In Progress)

**Milestone Goal:** Reduce every oversized screen file to under 500 lines by extracting stateful widgets, providers, and reusable components into their own files. Pure refactor -- zero UI/UX changes. The app must look and behave identically after every phase.

- [x] **Phase 15: Home Screen Refactor** — Extract page variants, journal tiles, and roadmap widgets from home_screen.dart (2,375 -> ~400 lines) (completed 2026-03-26)
- [x] **Phase 16: Settings Screen Refactor** — Extract edit profile sheet, photo picker, and section builders from settings_screen.dart (2,082 -> ~300 lines) (completed 2026-03-26)
- [ ] **Phase 17: You Screen Refactor** — Extract tab contents and hobby card variants from you_screen.dart (1,654 -> ~300 lines)
- [ ] **Phase 18: Coach Screen Refactor** — Extract CoachNotifier, message bubbles, composer, and mode selector from hobby_coach_screen.dart (1,741 -> ~400 lines)
- [ ] **Phase 19: Onboarding Screen Refactor** — Extract each onboarding step into standalone widget files from onboarding_screen.dart (1,456 -> ~200 lines)
- [ ] **Phase 20: Remaining Screens Refactor** — Extract sub-widgets from journal, search, detail, and discover screens; unify photo picker into one shared component

---

## Phase Details

### Phase 15: Home Screen Refactor
**Goal:** home_screen.dart is a thin shell that composes extracted widgets, with every page variant, journal tile, and roadmap component living in its own file
**Depends on:** Nothing (first phase of v1.2)
**Requirements:** HOME-01, HOME-02, HOME-03, HOME-04, HOME-05
**Success Criteria** (what must be TRUE):
  1. `home_screen.dart` is under 500 lines and contains only the top-level scaffold, tab/page switching logic, and widget composition -- no inline widget build methods over 50 lines
  2. The paused hobby page is a standalone file in `lib/screens/home/` that renders identically to the current inline version -- same dimmed card, "Paused" chip, "Resume" CTA, and days counter
  3. The active hobby page content (greeting, hobby card, next step, weekly plan, coach entry, progress) is a standalone file that renders identically to the current inline version
  4. Journal entry tiles and their empty states are standalone widget files that produce pixel-identical output in both Home and any other screen that uses them
  5. `dart analyze lib/screens/home/` passes with 0 errors, 0 warnings; the Home tab navigates and behaves identically to before the refactor
**Plans:** 2/2 plans complete
Plans:
- [ ] 15-01-PLAN.md -- Extract PausedHobbyPage and RoadmapJourney into standalone files
- [ ] 15-02-PLAN.md -- Extract JournalEntryTile and ActiveHobbyPage, finalize under 500 lines

### Phase 16: Settings Screen Refactor
**Goal:** settings_screen.dart is a lean scrollable list that delegates every sheet, picker, and section group to extracted files
**Depends on:** Nothing (independent of Phase 15)
**Requirements:** SETT-01, SETT-02, SETT-03, SETT-04
**Success Criteria** (what must be TRUE):
  1. `settings_screen.dart` is under 500 lines and contains only the scaffold, section list layout, and navigation handlers -- no inline bottom sheet or overlay definitions
  2. The edit profile bottom sheet is a standalone widget file that opens, validates, and saves profile changes identically to the current inline implementation
  3. The photo picker overlay is a standalone reusable component in `lib/components/` (not screen-specific) that can be imported by any screen needing image selection
  4. `dart analyze lib/screens/settings/` passes with 0 errors, 0 warnings; every Settings interaction (edit profile, toggle, link tap, delete account) behaves identically to before
**Plans:** 2/2 plans complete
Plans:
- [ ] 16-01-PLAN.md -- Extract EditProfileSheet and PhotoPickerOverlay into standalone files
- [ ] 16-02-PLAN.md -- Extract settings section builder widgets, finalize under 500 lines

### Phase 17: You Screen Refactor
**Goal:** you_screen.dart is a tab controller shell that delegates each tab's content and card rendering to extracted files
**Depends on:** Nothing (independent of Phases 15-16)
**Requirements:** YOU-01, YOU-02, YOU-03, YOU-04
**Success Criteria** (what must be TRUE):
  1. `you_screen.dart` is under 500 lines and contains only the scaffold, tab bar, and tab switching -- no inline card builders or list construction
  2. Each tab content (Active, Paused, Saved, Tried) is a standalone file in `lib/screens/you/` that renders its list and empty state identically to the current inline version
  3. Hobby card variants (collector card, paused card, saved card, tried card) are standalone widget files that produce identical visual output to the current inline builders
  4. `dart analyze lib/screens/you/` passes with 0 errors, 0 warnings; all four tab filters, card taps, and empty states behave identically to before
**Plans:** 1/2 plans executed
Plans:
- [ ] 17-01-PLAN.md -- Extract hobby card variants and tab content widgets into standalone files
- [ ] 17-02-PLAN.md -- Extract helper/stats widgets, finalize you_screen.dart under 500 lines

### Phase 18: Coach Screen Refactor
**Goal:** hobby_coach_screen.dart is a slim conversation UI that composes extracted provider, bubble, composer, and mode widgets
**Depends on:** Nothing (independent of Phases 15-17)
**Requirements:** COACH-01, COACH-02, COACH-03, COACH-04, COACH-05
**Success Criteria** (what must be TRUE):
  1. `hobby_coach_screen.dart` is under 500 lines and contains only the scaffold, message list, and widget composition -- no business logic, no model classes, no inline complex widgets
  2. `CoachNotifier` and `ChatMessage` model live in a dedicated `coach_provider.dart` file with all chat state management, API calls, and message history logic
  3. The message bubble widget is a standalone `coach_bubble.dart` file that renders user and assistant bubbles identically to the current inline version -- same glass styling, same text layout
  4. The composer widget (text input, mic button, attach button, voice recording overlay) is a standalone file that handles input, recording state, and submission identically to the current inline version
  5. `dart analyze lib/screens/coach/` passes with 0 errors, 0 warnings; sending messages, switching modes, voice input, and photo attach all behave identically to before
**Plans:** TBD

### Phase 19: Onboarding Screen Refactor
**Goal:** onboarding_screen.dart is a PageView coordinator that delegates each step's content to standalone widget files
**Depends on:** Nothing (independent of Phases 15-18)
**Requirements:** ONBD-01, ONBD-02
**Success Criteria** (what must be TRUE):
  1. `onboarding_screen.dart` is under 300 lines and contains only the PageView controller, navigation logic, and step composition -- no inline step content
  2. Each onboarding step/page (welcome, time preference, budget, social preference, vibe selection, results) is a standalone widget file in `lib/screens/onboarding/` that renders identically to the current inline version
  3. `dart analyze lib/screens/onboarding/` passes with 0 errors, 0 warnings; the complete onboarding flow (forward, back, skip, submit) behaves identically to before
**Plans:** TBD

### Phase 20: Remaining Screens Refactor
**Goal:** Journal, search, detail, and discover screens are each under 500 lines, and all photo picker overlays across the app use one shared component
**Depends on:** Phase 16 (shared photo picker component created in SETT-03)
**Requirements:** MISC-01, MISC-02, MISC-03, MISC-04, MISC-05
**Success Criteria** (what must be TRUE):
  1. `hobby_journal_screen.dart` is under 500 lines with the add-entry sheet and journal cards extracted to standalone files -- journal creation, editing, and photo attachment behave identically
  2. `search_screen.dart` is under 500 lines with result cards and suggestion widgets extracted -- search input, results display, and hobby navigation behave identically
  3. `hobby_detail_screen.dart` is under 500 lines with kit section, roadmap section, FAQ section, and cost/budget sections extracted -- all detail page interactions (scroll, expand, gate, start hobby) behave identically
  4. `discover_screen.dart` is under 500 lines with feed card, list card, and hero card extracted -- discovery browsing, category filtering, and hobby selection behave identically
  5. All photo picker usages (journal, settings, coach) import the single shared component from `lib/components/` created in Phase 16 -- no duplicate picker implementations remain in screen files
**Plans:** TBD

---

## Progress

**Execution Order:** 15 -> 16 -> 17 -> 18 -> 19 -> 20 (sequential; Phase 20 depends on Phase 16's shared photo picker)

| Phase | Milestone | Plans Complete | Status | Completed |
|-------|-----------|----------------|--------|-----------|
| 1. Server Security Hardening | v1.0 | 2/2 | Complete | 2026-03-21 |
| 2. Apple OAuth Routing Fix | v1.0 | 1/1 | Complete | 2026-03-21 |
| 3. Legal Documents | v1.0 | 2/2 | Complete | 2026-03-21 |
| 4. Account Deletion -- Backend | v1.0 | 2/2 | Complete | 2026-03-21 |
| 5. Account Deletion -- Flutter UX | v1.0 | 2/2 | Complete | 2026-03-21 |
| 6. Restore Purchases | v1.0 | 1/1 | Complete | 2026-03-21 |
| 7. Dead Code Cleanup | v1.0 | 1/1 | Complete | 2026-03-21 |
| 8. Sonnet AI Upgrade | v1.0 | 1/1 | Complete | 2026-03-22 |
| 9. App Store Assets | v1.0 | 2/2 | Complete | 2026-03-22 |
| 9.1. Session Screen Redesign | v1.0 | 3/3 | Complete | 2026-03-22 |
| 10. Pre-Commit Hooks | v1.0 | 1/1 | Complete | 2026-03-22 |
| 11. Lifecycle Schema Migration | v1.1 | 2/2 | Complete | 2026-03-23 |
| 12. Hobby Completion Flow + Stop | v1.1 | 2/2 | Complete | 2026-03-23 |
| 13. Detail Page Content Gating | v1.1 | 2/2 | Complete | 2026-03-23 |
| 14. Pause/Resume Lifecycle | v1.1 | 2/2 | Complete | 2026-03-23 |
| 15. Home Screen Refactor | 2/2 | Complete   | 2026-03-26 | - |
| 16. Settings Screen Refactor | 2/2 | Complete   | 2026-03-26 | - |
| 17. You Screen Refactor | 1/2 | In Progress|  | - |
| 18. Coach Screen Refactor | v1.2 | 0/TBD | Not started | - |
| 19. Onboarding Screen Refactor | v1.2 | 0/TBD | Not started | - |
| 20. Remaining Screens Refactor | v1.2 | 0/TBD | Not started | - |

---

## Coverage Map (v1.2)

| Requirement | Phase | Description |
|-------------|-------|-------------|
| HOME-01 | Phase 15 | home_screen.dart under 500 lines with all page variants extracted |
| HOME-02 | Phase 15 | Paused hobby page is a standalone widget file |
| HOME-03 | Phase 15 | Active hobby page content is a standalone widget file |
| HOME-04 | Phase 15 | Journal entry tiles and empty states are standalone widget files |
| HOME-05 | Phase 15 | Roadmap step tile is a standalone widget file |
| SETT-01 | Phase 16 | settings_screen.dart under 500 lines |
| SETT-02 | Phase 16 | Edit profile sheet is a standalone widget file |
| SETT-03 | Phase 16 | Photo picker overlay is a shared reusable component |
| SETT-04 | Phase 16 | Settings section builders extracted into helper widgets |
| YOU-01 | Phase 17 | you_screen.dart under 500 lines |
| YOU-02 | Phase 17 | Each tab content (Active/Paused/Saved/Tried) is a standalone file |
| YOU-03 | Phase 17 | Hobby card variants are standalone files |
| YOU-04 | Phase 17 | Stats widgets and helper widgets extracted |
| COACH-01 | Phase 18 | hobby_coach_screen.dart under 500 lines |
| COACH-02 | Phase 18 | CoachNotifier + ChatMessage extracted to coach_provider.dart |
| COACH-03 | Phase 18 | Message bubble widget extracted to coach_bubble.dart |
| COACH-04 | Phase 18 | Composer widget (input + mic + attach + voice overlay) extracted |
| COACH-05 | Phase 18 | Mode selector and quick actions strip extracted |
| ONBD-01 | Phase 19 | onboarding_screen.dart under 300 lines |
| ONBD-02 | Phase 19 | Each onboarding step/page is a standalone widget file |
| MISC-01 | Phase 20 | hobby_journal_screen.dart under 500 lines |
| MISC-02 | Phase 20 | search_screen.dart under 500 lines |
| MISC-03 | Phase 20 | hobby_detail_screen.dart under 500 lines |
| MISC-04 | Phase 20 | discover_screen.dart under 500 lines |
| MISC-05 | Phase 20 | Photo picker overlays unified into one shared component |

**Total mapped: 25/25**

---

## Dependency Graph (v1.2)

```
Phase 15 (Home Screen)        -+
Phase 16 (Settings Screen)     +-- all independent except Phase 20
Phase 17 (You Screen)          |
Phase 18 (Coach Screen)        |
Phase 19 (Onboarding Screen)  -+
                                |
Phase 20 (Remaining Screens) ---- depends on Phase 16 (shared photo picker from SETT-03)
```

---

*Roadmap created: 2026-03-21 (v1.0)*
*v1.1 phases added: 2026-03-23*
*v1.2 phases added: 2026-03-26*
*Last updated: 2026-03-26 after Phase 17 planning*
