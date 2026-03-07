# Design: Fix Onboarding Matching + Feed Category Flash

**Date:** 2026-03-07
**Tasks:** A.1 (matching logic), A.4 / Bug 1 (feed flash)

---

## A.1 — Fix Onboarding Matching Logic

### Problem
`_computeMatchedHobbies()` in `onboarding_screen.dart` only scores on vibe tags and solo/social. Budget and time inputs are collected but ignored, destroying user trust.

### Solution

**New file: `lib/core/hobby_match.dart`** — pure scoring logic, no UI.

#### 1. Parsing Helpers

- `parseCostRange(String costText) → (int min, int max)` — regex on "CHF 40–120" format
- `parseWeeklyHours(String timeText) → double` — regex on "2h/week" format
- Graceful fallback: returns high defaults if parsing fails (so unparseable hobbies aren't falsely excluded)

#### 2. Budget Mapping

User's budget level (0/1/2) maps to a max starter cost threshold:
- `0` (Low): max CHF 50
- `1` (Medium): max CHF 150
- `2` (High): unlimited (no filter)

#### 3. Composite Scoring

| Signal | Logic | Points |
|--------|-------|--------|
| Budget fit | Parsed cost max ≤ threshold → +3; over by <50% → +1; way over → 0 | 0–3 |
| Time fit | Parsed hours ≤ user's hours → +3; over by ≤2h → +1; way over → 0 | 0–3 |
| Solo/Social | Matching tag present → +2 | 0–2 |
| Vibe match | Each matching vibe tag → +1 | 0–N |

#### 4. Result Assembly

- Sort all hobbies by composite score descending
- Return top 3 (1 best + 2 alternatives)
- If fewer than 3 score > 0, pad with budget-passing hobbies sorted randomly

#### 5. Integration

Replace `_computeMatchedHobbies()` body in `onboarding_screen.dart` with call to the new scoring function, passing `_hours`, `_budget`, `_social`, `_vibes`.

---

## Bug 1 — Feed Category Black Flash

### Problem
Switching categories causes a black flash. Root cause: `_pageController.dispose()` + recreation inside `ref.listen` destroys the controller while the widget tree still references it.

### Solution

1. Stop disposing/recreating `PageController` in the listener — use `_pageController.jumpToPage(0)` instead
2. Keep `AnimatedSwitcher` with `FadeTransition` + `ValueKey(selectedCategory)` for visual cross-fade

---

## Files Changed

- `lib/core/hobby_match.dart` (NEW) — parsing + scoring
- `lib/screens/onboarding/onboarding_screen.dart` — use new matching
- `lib/screens/feed/discover_feed_screen.dart` — fix flash
