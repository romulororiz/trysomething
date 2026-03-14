# TrySomething — Task List v5.0 (Premium Finalization + Feed Discover)

> **Strategy:** Finish the redesign with discipline. Make the app feel iconic, premium, and fully coherent.
> **Core loop:** Choose 1 hobby → Start it → Do step 1 → Come back tomorrow
> **Product direction:** Guided-start app, not hobby super app
> **Visual direction:** Premium Cinematic Discovery — teal/burgundy atmosphere + warm premium UI + calm tactile motion

## Rules
- Read `CLAUDE.md` before every session
- Read `PRODUCT_GUARDRAILS.md` before every session
- `dart analyze` on changed files after each task (NOT full flutter analyze)
- Full `flutter analyze` + `dart test` after each sprint
- One sprint per branch
- Do not introduce new major features unless explicitly listed here
- Keep the teal + burgundy atmospheric background
- Do not introduce 3.js or web-based UI rendering for app screens
- Ask user beforehand and stage and commit changes after every spring using /commit-master
- Use /ui-ux-pro-max and /flutter-expert and /frontend-design, and any other skills you deem necessary for the job.

---

## Status Summary

Sprints A–F established:
- the new 3-tab architecture
- onboarding and recommendation improvements
- Home / Discover / You direction
- detail conversion improvements
- coach groundwork
- warm premium direction
- core redesign momentum

This file covers the remaining work needed to make the app feel fully premium, cohesive, and launch-ready.

---

## Sprint G: Replace Discover with Premium Feed Discover

The current Discover is better than before, but still carries rail-based browse DNA. Replace it with a premium swipeable recommendation deck using the existing TikTok-style feed component.

- [x] **G.1 — Retire current Discover page from the primary UX**
  - Remove the current rail-based Discover page as the default primary Discover surface
  - Rewire Discover to use the existing full-screen feed component as the default
  - The old Discover implementation may remain temporarily in code if needed, but must no longer be the primary experience
  - **Test:** opening Discover lands directly on the feed experience

- [x] **G.2 — Rewire existing feed component to become Discover**
  - Reuse the existing TikTok-style feed component already built for “See all”
  - Adapt it to become the main Discover surface
  - Ensure the feed uses premium UI styling, not social-feed styling
  - Remove any leftover “secondary feed” assumptions in naming/logic if possible
  - **Test:** feed works as the main Discover route without regression

- [x] **G.3 — Add top pill tabs that control feed datasets**
  - Add premium pill tabs at the top of Discover:
    - For You
    - Start Cheap
    - Start This Week
    - Different Vibe
  - Tapping a pill should re-render the feed with the correct hobby dataset and ranking
  - Tabs should feel calm and premium — not loud category chips
  - **Test:** each pill updates the feed correctly

- [x] **G.4 — Implement real filter/ranking logic for Discover feed tabs**
  - `For You` → highest-ranked personalized matches
  - `Start Cheap` → hobbies sorted/filtered by lowest realistic starter cost
  - `Start This Week` → hobbies with low friction and fast time-to-first-session
  - `Different Vibe` → intentionally varied alternatives outside the user’s top cluster
  - Ensure these are real logic paths, not cosmetic labels
  - **Test:** hobby feed contents clearly differ by tab

- [x] **G.5 — Build premium Discover top chrome**
  - Keep the teal + burgundy atmospheric background
  - Top chrome should include:
    - pill tabs
    - search magnifier only
    - subtle view-mode toggle
  - Chrome should be floating, glassy, and minimal
  - Avoid clutter or utility-heavy toolbar feel
  - **Test:** top chrome feels premium and remains readable across cards

- [x] **G.6 — Search as separate screen with premium transition**
  - Replace integrated Discover search bar with magnifier-only entry
  - On tap:
    - fade/slightly slide Discover feed out
    - fade Search screen in
  - Search becomes its own premium surface
  - Search must feel like an intelligent hobby query space, not a standard utility page
  - **Test:** transition feels smooth and premium, back behavior works

- [x] **G.7 — Add Discover view toggle: Feed vs List**
  - Default mode = Feed
  - Secondary mode = premium vertical list
  - The toggle should be subtle, not dominant
  - The app should remember the last selected mode if feasible
  - List mode should still feel premium, not like old Discover
  - **Test:** toggle switches between both modes without breaking filters/search state

- [x] **G.8 — Redesign feed cards for decision-making, not passive browsing**
  - Each feed card should answer:
    - what the hobby is
    - why it fits the user
    - cost to start
    - time per week
    - friction/effort level
    - can I start this tonight?
  - Card structure should include:
    - strong image
    - hobby title
    - one-line emotional hook
    - quiet metadata line or small restrained pills
    - why-it-fits line
    - one primary CTA
  - Avoid social-feed affordances like right-side action stacks or noisy overlays
  - **Test:** cards feel like premium recommendations, not content posters

- [x] **G.9 — List mode design**
  - Build list mode as vertically stacked premium cards
  - Maintain the same card language as feed mode
  - List mode should optimize scanning while staying visually rich
  - No regression to old rail/card-grid feel
  - **Test:** list mode works well for scanning and retains the premium identity

- [x] **G.10 — Discover screen performance and gesture QA**
  - Ensure vertical snap/swipe behavior feels smooth
  - Ensure pill switching is fast and does not flash ugly states
  - Ensure transitions between feed/list/search feel polished
  - **Test:** no jank on physical device, no black flashes, no content jumps

- [ ] **G.11 — Redesign cost breakdown screen as premium interactive surface**
  - Current cost calculator screen looks amateurish and non-functional
  - Rebuild as a premium interactive cost breakdown:
    - Visual cost breakdown chart (stacked bar, donut, or segmented visual)
    - Dynamic: user can toggle essential vs optional items, see total update live
    - Tier comparison: minimum / best value / premium side by side
    - Show per-item costs with expandable detail
    - Add "total starter cost" summary that updates as user selects/deselects items
    - Premium glass card styling consistent with the rest of the app
  - Must feel like a professional budgeting tool, not a static list
  - Use the teal + burgundy atmospheric background
  - **Test:** cost screen feels like a premium planning tool, interactive and informative

---

## Sprint H: Typography Reset

Typography is still not fully resolved. The app needs a calmer, more coherent voice.

- [ ] **H.1 — Simplify the type system**
  - Replace the current multi-voice feel with a more disciplined hierarchy
  - Recommended direction:
    - Primary UI/body/headings: `Manrope`
    - Editorial hero moments only: `Instrument Serif`
    - Remove or nearly remove `IBM Plex Mono` from brand expression
  - If serif is retained, use it sparingly and intentionally
  - **Test:** all core screens render correctly with the new type hierarchy

- [ ] **H.2 — Apply new type hierarchy rules**
  - Serif only for:
    - welcome headline
    - occasional hero statement
    - maybe paywall headline
    - maybe one detail-page hobby title
  - Sans for:
    - navigation
    - cards
    - buttons
    - body
    - metadata
    - section structure
  - Mono only if strictly functional (for example, session timer)
  - **Test:** typography feels more coherent across screens

- [ ] **H.3 — Reduce over-designed typography moments**
  - Audit screens for overly stylized or competing type moments
  - Reduce decorative hierarchy where it weakens clarity
  - Improve spacing, line-height, and contrast between hero vs utility text
  - **Test:** typography feels premium and calm, not self-conscious

- [ ] **H.4 — Screen-by-screen typography QA**
  - Check:
    - Welcome
    - Onboarding
    - Discover feed
    - Search
    - Detail
    - Home
    - Roadmap
    - Coach
    - Journal
    - You
    - Settings
    - Paywall
  - **Test:** type scale and font choices feel consistent everywhere

---

## Sprint I: Overlay System Rebuild (Popups, Sheets, Dialogs, Snackbars)

Current overlays are inconsistent and break the premium feel.

- [ ] **I.1 — Create one shared overlay system**
  - Build reusable overlay families:
    - `AppSheet`
    - `AppConfirmDialog`
    - `AppSnackbar`
    - `AppFullscreenModal` if needed
  - These must replace mixed stock/legacy dialogs and ad hoc bottom sheets
  - **Test:** the app has one coherent overlay language

- [ ] **I.2 — Build premium AppSheet**
  - Use for:
    - edit profile
    - hobby actions
    - quickstart options
    - chooser flows
    - premium nudges
    - schedule/action sheets
  - Shared design:
    - same radius
    - same handle
    - same padding
    - same typography
    - same CTA hierarchy
    - same glass/surface language
  - **Test:** all sheets feel consistent and premium

- [ ] **I.3 — Build AppConfirmDialog**
  - Use for:
    - logout
    - destructive actions
    - reset choices
    - data clearing
  - Remove stock-feeling `AlertDialog` usage where possible
  - **Test:** confirmation dialogs no longer break the visual identity

- [ ] **I.4 — Standardize snackbars and transient messages**
  - Create one premium snackbar/toast style
  - Use for:
    - success
    - info
    - non-blocking errors
  - **Test:** transient messages feel like part of the product

- [ ] **I.5 — Replace legacy overlays screen by screen**
  - Audit and replace legacy popups/dialogs in:
    - Settings
    - Profile edit
    - Home
    - Detail
    - Quickstart flow
    - Paywall triggers
    - Journal
  - **Test:** overlay behavior is visually consistent across the app

---

## Sprint J: Screen-by-Screen Premium Cleanup

The main architecture is right. Now each major surface must feel fully designed.

### J.1 — Welcome / Entry
- [ ] Reduce explanatory clutter
- [ ] Strengthen one hero statement
- [ ] Improve CTA confidence
- [ ] Make first impression feel more iconic and less generic
- [ ] **Test:** welcome feels premium and decisive

### J.2 — Onboarding
- [ ] Simplify each question screen
- [ ] Reduce decorative complexity
- [ ] Improve selected states and spacing
- [ ] Make progress feel premium, not utility-like
- [ ] **Test:** onboarding feels calm, focused, and confident

### J.3 — Match Results
- [ ] Make best match more dominant
- [ ] Make alternatives clearly secondary
- [ ] Strengthen “why this fits” scanability
- [ ] Improve CTA singularity
- [ ] **Test:** results feel decisive, not list-like

### J.4 — Search
- [ ] Make search feel like a premium intelligence surface
- [ ] Improve query suggestions
- [ ] Improve result grouping
- [ ] Make results feel closer to recommendation logic than catalog logic
- [ ] **Test:** search feels helpful, not utility-heavy

### J.5 — Hobby Detail
- [ ] Push quick-start content higher if needed
- [ ] Simplify visual density in upper half
- [ ] Make easiest-start content even more obvious
- [ ] Improve CTA stack clarity
- [ ] **Test:** detail page strongly converts to “start now”

### J.6 — Start Now / Week 1 Setup
- [ ] Make setup feel lighter and less configurational
- [ ] Reduce the number of visible decisions at once
- [ ] Improve transitions between setup steps
- [ ] Improve generated Week 1 success state
- [ ] **Test:** setup feels easy and inevitable

### J.7 — Home
- [ ] Reduce dashboard feeling
- [ ] Make active hobby more singular and emotionally central
- [ ] Clarify next-step hierarchy
- [ ] Remove any leftover browse noise
- [ ] **Test:** Home feels like an operating center, not a dashboard

### J.8 — Roadmap / Progress
- [ ] Emphasize current stage over future stages
- [ ] Make roadmap feel like a narrative ladder, not task UI
- [ ] Improve “stuck?” integration
- [ ] Reduce status clutter
- [ ] **Test:** roadmap feels humane and calm

### J.9 — Coach
- [ ] Make chips the dominant entry
- [ ] Reduce generic chat feel
- [ ] Improve visual scanability of replies
- [ ] Strengthen Start / Momentum / Rescue clarity
- [ ] **Test:** coach feels like support UI, not chatbot UI

### J.10 — Journal
- [ ] Make journal more reflective and less form-like
- [ ] Emphasize “What should be simpler next time?”
- [ ] Improve visual softness and calm
- [ ] **Test:** journal feels emotionally useful, not bolted on

### J.11 — You
- [ ] Reduce accent overload
- [ ] Improve distinction between Active / Saved / Tried
- [ ] Reduce account-area feel
- [ ] Make Active the clear emotional center
- [ ] **Test:** You feels like “my hobby life,” not settings-plus

### J.12 — Settings
- [ ] Improve row spacing and visual hierarchy
- [ ] Rebuild settings confirmations with new overlay system
- [ ] Reduce stock Material feel
- [ ] **Test:** settings no longer break the premium illusion

### J.13 — Paywall / Pro
- [ ] Tighten hero composition
- [ ] Improve whitespace confidence
- [ ] Improve plan selector styling
- [ ] Make premium feel like continuity support, not monetization UI
- [ ] **Test:** paywall feels premium and emotionally coherent

---

## Sprint K: Coach Logic + Monetization Correction

The biggest remaining product logic issue is still the coach gating.

- [ ] **K.1 — Fix current coach usage logic**
  - Current pattern is strategically wrong if unsaved hobbies get more generous access than active ones
  - Refactor so the coach’s value appears strongest when the user is actively trying to continue
  - **Test:** coach access logic aligns with product strategy

- [ ] **K.2 — Reframe free vs Pro around continuity**
  - Free should help users:
    - start
    - ask one or two meaningful starter questions
    - get one recovery assist
  - Pro should help users:
    - continue
    - recover
    - get ongoing support through friction
  - **Test:** free/Pro boundary feels intuitive and fair

- [ ] **K.3 — Improve upgrade timing**
  - Trigger premium moments after:
    - useful coach value
    - recovery moments
    - real progression moments
  - Avoid upgrade pressure before value is felt
  - **Test:** paywall timing feels more natural

- [ ] **K.4 — Align upgrade language with coach value**
  - Emphasize:
    - know the next step
    - get unstuck
    - keep the hobby alive after week 1
  - Avoid feature-list-first framing
  - **Test:** coach-related upgrade moments feel emotionally coherent

---

## Sprint L: Full Visual Consistency Pass

Keep the teal + burgundy atmosphere, but make the rest of the app harmonize with it.

- [ ] **L.1 — Keep teal/burgundy background intentionally**
  - Retain the atmospheric teal + burgundy background treatment
  - Do not replace it with a different visual base
  - Instead, harmonize all surfaces, type, and accents with it
  - **Test:** background feels like atmosphere, not visual competition

- [ ] **L.2 — Reduce accent overuse**
  - Audit screens for coral overuse
  - Keep one clear primary coral CTA per screen where possible
  - Demote competing accents to quiet neutrals
  - **Test:** screens feel calmer and more expensive

- [ ] **L.3 — Audit card/material hierarchy**
  - Ensure all screens use a coherent material family:
    - grounded surfaces
    - floating surfaces
    - focal surfaces
  - Remove mixed old/new card language where it still exists
  - **Test:** screens feel built from the same system

- [ ] **L.4 — Metadata consistency pass**
  - Ensure metadata treatment is consistent across:
    - feed cards
    - list cards
    - detail
    - You
    - search results
    - roadmap
  - **Test:** metadata styling is quiet, premium, and consistent

- [ ] **L.5 — CTA hierarchy consistency pass**
  - Audit every major screen for:
    - one primary action
    - quieter secondary actions
    - no cluttered CTA stacks
  - **Test:** CTA hierarchy feels obvious everywhere

---

## Sprint M: Refactor for Maintainability

The redesign has landed, but the screen files are still too large.

- [ ] **M.1 — Refactor Discover into sections/components**
  - Break out:
    - top chrome
    - feed wrapper
    - card renderer
    - list renderer
    - filter logic
    - empty states
  - **Test:** Discover becomes easier to reason about and maintain

- [ ] **M.2 — Refactor You into smaller sections**
  - Break out:
    - header
    - Active section
    - Saved section
    - Tried section
    - utility rows
  - **Test:** You screen is easier to evolve cleanly

- [ ] **M.3 — Refactor Search**
  - Break out search chrome, suggestions, result groups, and cards
  - **Test:** Search becomes cleaner and easier to polish

- [ ] **M.4 — Refactor Detail**
  - Extract upper hero, quick-start section, why-fits section, roadmap block, coach teaser, CTA area
  - **Test:** detail page becomes easier to tune

- [ ] **M.5 — Refactor Home**
  - Extract active hobby hero, next-step block, week plan, coach module, restart prompt
  - **Test:** Home becomes easier to polish without regressions

- [ ] **M.6 — Remove or isolate legacy product mass**
  - Audit older secondary screens still living in the repo
  - Hide, isolate, or clearly mark legacy/secondary surfaces that should not influence the main product direction
  - **Test:** legacy features stop exerting structural pressure on the main app

---

## Sprint N: Final Premium Polish + QA

This is the last stretch from “very improved” to “finished premium beta.”

- [ ] **N.1 — Motion consistency pass**
  - Standardize tap, screen, and card transitions
  - Ensure motion is calm, tactile, and not busy
  - **Test:** app interactions feel expensive and coherent

- [ ] **N.2 — Haptic pass**
  - Add or refine haptics for:
    - save
    - tab switch
    - complete step
    - primary CTA
    - coach chip
    - confirmation flows
  - **Test:** haptics feel supportive, not noisy

- [ ] **N.3 — Empty states + loading states QA**
  - Ensure all empty/loading/error states follow the premium system
  - No ugly defaults or low-effort placeholders
  - **Test:** all states feel designed

- [ ] **N.4 — Device visual QA**
  - Test on physical device:
    - Discover feed and list
    - Search transition
    - Home
    - Detail
    - You
    - Sheets/dialogs
    - Paywall
  - Check:
    - safe areas
    - spacing
    - gesture comfort
    - no visual clipping
    - no awkward overlays
  - **Test:** no major visual inconsistencies remain

- [ ] **N.5 — End-to-end premium QA**
  - Run through:
    - onboarding → match → start → week 1 → coach → return
    - free → hit meaningful limitation → upgrade
    - save hobby → return later
    - switch to list mode → search → detail → start
  - **Test:** the app feels coherent all the way through

---

## Definition of Done for v5

This redesign is done when:

- Discover is fully replaced by the premium feed/list Discover
- Search is a separate premium transition surface
- Typography feels coherent and premium
- Popups/sheets/dialogs no longer look stock or ugly
- Coach gating matches product strategy
- Home / Discover / You all feel like one brand
- The teal + burgundy atmosphere feels intentional and fully integrated
- The app no longer feels like a redesign in progress
- The product feels like a premium guided-start app from start to finish
