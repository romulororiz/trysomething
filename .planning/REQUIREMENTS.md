# Requirements: TrySomething

**Defined:** 2026-03-26
**Core Value:** A user can discover a hobby that fits them, start it with clear first steps, and stick with it for 30 days.

## v1.2 Requirements

Requirements for the Separation of Concerns Refactor. Each maps to one phase.

### Home Screen

- [x] **HOME-01**: home_screen.dart is under 500 lines with all page variants extracted
- [x] **HOME-02**: Paused hobby page is a standalone widget file
- [x] **HOME-03**: Active hobby page content is a standalone widget file
- [x] **HOME-04**: Journal entry tiles and empty states are standalone widget files
- [x] **HOME-05**: Roadmap step tile is a standalone widget file

### Settings Screen

- [x] **SETT-01**: settings_screen.dart is under 500 lines
- [x] **SETT-02**: Edit profile sheet is a standalone widget file
- [x] **SETT-03**: Photo picker overlay is a shared reusable component
- [x] **SETT-04**: Settings section builders are extracted into helper widgets

### You Screen

- [ ] **YOU-01**: you_screen.dart is under 500 lines
- [ ] **YOU-02**: Each tab content (Active/Paused/Saved/Tried) is a standalone file
- [ ] **YOU-03**: Hobby card variants (collector, paused, saved, tried) are standalone files
- [ ] **YOU-04**: Stats widgets and helper widgets are extracted

### Coach Screen

- [ ] **COACH-01**: hobby_coach_screen.dart is under 500 lines
- [ ] **COACH-02**: CoachNotifier + ChatMessage model extracted to coach_provider.dart
- [ ] **COACH-03**: Message bubble widget extracted to coach_bubble.dart
- [ ] **COACH-04**: Composer widget (input + mic + attach + voice overlay) extracted
- [ ] **COACH-05**: Mode selector and quick actions strip extracted

### Onboarding Screen

- [ ] **ONBD-01**: onboarding_screen.dart is under 300 lines
- [ ] **ONBD-02**: Each onboarding step/page is a standalone widget file

### Remaining Screens

- [ ] **MISC-01**: hobby_journal_screen.dart under 500 lines — add entry sheet, cards extracted
- [ ] **MISC-02**: search_screen.dart under 500 lines — results, suggestions extracted
- [ ] **MISC-03**: hobby_detail_screen.dart under 500 lines — kit, roadmap, FAQ sections extracted
- [ ] **MISC-04**: discover_screen.dart under 500 lines — feed card, list card, hero card extracted
- [ ] **MISC-05**: Photo picker overlays unified into one shared component (journal + settings + coach)

## Out of Scope

| Feature | Reason |
|---------|--------|
| New features | v1.2 is pure refactor — no behavioral changes |
| Server refactor | Server files are already well-structured |
| Model refactor | Freezed models are auto-generated, no action needed |
| Test refactor | Tests can be updated after screens are split |
| Provider restructuring (except CoachNotifier) | Providers are already in separate files |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| HOME-01 | Phase 15 | Complete |
| HOME-02 | Phase 15 | Complete |
| HOME-03 | Phase 15 | Complete |
| HOME-04 | Phase 15 | Complete |
| HOME-05 | Phase 15 | Complete |
| SETT-01 | Phase 16 | Complete |
| SETT-02 | Phase 16 | Complete |
| SETT-03 | Phase 16 | Complete |
| SETT-04 | Phase 16 | Complete |
| YOU-01 | Phase 17 | Pending |
| YOU-02 | Phase 17 | Pending |
| YOU-03 | Phase 17 | Pending |
| YOU-04 | Phase 17 | Pending |
| COACH-01 | Phase 18 | Pending |
| COACH-02 | Phase 18 | Pending |
| COACH-03 | Phase 18 | Pending |
| COACH-04 | Phase 18 | Pending |
| COACH-05 | Phase 18 | Pending |
| ONBD-01 | Phase 19 | Pending |
| ONBD-02 | Phase 19 | Pending |
| MISC-01 | Phase 20 | Pending |
| MISC-02 | Phase 20 | Pending |
| MISC-03 | Phase 20 | Pending |
| MISC-04 | Phase 20 | Pending |
| MISC-05 | Phase 20 | Pending |

**Coverage:**
- v1.2 requirements: 25 total
- Mapped to phases: 25
- Unmapped: 0 ✓

---
*Requirements defined: 2026-03-26*
*Last updated: 2026-03-26 after initial definition*
