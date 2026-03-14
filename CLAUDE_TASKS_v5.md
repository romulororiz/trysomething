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

- [x] **G.11 — Redesign cost breakdown screen as premium interactive surface**
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

- [x] **H.1 — Simplify the type system**
  - Replace the current multi-voice feel with a more disciplined hierarchy
  - Recommended direction:
    - Primary UI/body/headings: `Manrope`
    - Editorial hero moments only: `Instrument Serif`
    - Remove or nearly remove `IBM Plex Mono` from brand expression
  - If serif is retained, use it sparingly and intentionally
  - **Test:** all core screens render correctly with the new type hierarchy

- [x] **H.2 — Apply new type hierarchy rules**
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

- [x] **H.3 — Reduce over-designed typography moments**
  - Audit screens for overly stylized or competing type moments
  - Reduce decorative hierarchy where it weakens clarity
  - Improve spacing, line-height, and contrast between hero vs utility text
  - **Test:** typography feels premium and calm, not self-conscious

- [x] **H.4 — Screen-by-screen typography QA**
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

- [x] **I.1 — Create one shared overlay system**
  - Build reusable overlay families:
    - `AppSheet`
    - `AppConfirmDialog`
    - `AppSnackbar`
    - `AppFullscreenModal` if needed
  - These must replace mixed stock/legacy dialogs and ad hoc bottom sheets
  - **Test:** the app has one coherent overlay language

- [x] **I.2 — Build premium AppSheet**
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

- [x] **I.3 — Build AppConfirmDialog**
  - Use for:
    - logout
    - destructive actions
    - reset choices
    - data clearing
  - Remove stock-feeling `AlertDialog` usage where possible
  - **Test:** confirmation dialogs no longer break the visual identity

- [x] **I.4 — Standardize snackbars and transient messages**
  - Create one premium snackbar/toast style
  - Use for:
    - success
    - info
    - non-blocking errors
  - **Test:** transient messages feel like part of the product

- [x] **I.5 — Replace legacy overlays screen by screen**
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
- [x] Reduce explanatory clutter
- [x] Strengthen one hero statement
- [x] Improve CTA confidence
- [x] Make first impression feel more iconic and less generic
- [x] **Test:** welcome feels premium and decisive

### J.2 — Onboarding
- [x] Simplify each question screen
- [x] Reduce decorative complexity
- [x] Improve selected states and spacing
- [x] Make progress feel premium, not utility-like
- [x] **Test:** onboarding feels calm, focused, and confident

### J.3 — Match Results
- [x] Make best match more dominant
- [x] Make alternatives clearly secondary
- [x] Strengthen “why this fits” scanability
- [x] Improve CTA singularity
- [x] **Test:** results feel decisive, not list-like

### J.4 — Search
- [x] Make search feel like a premium intelligence surface
- [x] Improve query suggestions
- [x] Improve result grouping
- [x] Make results feel closer to recommendation logic than catalog logic
- [x] **Test:** search feels helpful, not utility-heavy

### J.5 — Hobby Detail
- [x] Push quick-start content higher if needed
- [x] Simplify visual density in upper half
- [x] Make easiest-start content even more obvious
- [x] Improve CTA stack clarity
- [x] **Test:** detail page strongly converts to “start now”

### J.6 — Start Now / Week 1 Setup
- [x] Make setup feel lighter and less configurational
- [x] Reduce the number of visible decisions at once
- [x] Improve transitions between setup steps
- [x] Improve generated Week 1 success state
- [x] **Test:** setup feels easy and inevitable

### J.7 — Home
- [x] Reduce dashboard feeling
- [x] Make active hobby more singular and emotionally central
- [x] Clarify next-step hierarchy
- [x] Remove any leftover browse noise
- [x] **Test:** Home feels like an operating center, not a dashboard

### J.8 — Roadmap / Progress
- [x] Emphasize current stage over future stages
- [x] Make roadmap feel like a narrative ladder, not task UI
- [x] Improve “stuck?” integration
- [x] Reduce status clutter
- [x] **Test:** roadmap feels humane and calm

### J.9 — Coach
- [x] Make chips the dominant entry
- [x] Reduce generic chat feel
- [x] Improve visual scanability of replies
- [x] Strengthen Start / Momentum / Rescue clarity
- [x] **Test:** coach feels like support UI, not chatbot UI

### J.10 — Journal
- [x] Make journal more reflective and less form-like
- [x] Emphasize “What should be simpler next time?”
- [x] Improve visual softness and calm
- [x] **Test:** journal feels emotionally useful, not bolted on

### J.11 — You
- [x] Reduce accent overload
- [x] Improve distinction between Active / Saved / Tried
- [x] Reduce account-area feel
- [x] Make Active the clear emotional center
- [x] **Test:** You feels like “my hobby life,” not settings-plus

### J.12 — Settings
- [x] Improve row spacing and visual hierarchy
- [x] Rebuild settings confirmations with new overlay system
- [x] Reduce stock Material feel
- [x] **Test:** settings no longer break the premium illusion

### J.13 — Paywall / Pro
- [x] Tighten hero composition
- [x] Improve whitespace confidence
- [x] Improve plan selector styling
- [x] Make premium feel like continuity support, not monetization UI
- [x] **Test:** paywall feels premium and emotionally coherent

---

## Sprint K: Coach Logic + Monetization Correction

The biggest remaining product logic issue is still the coach gating.

- [x] **K.1 — Fix current coach usage logic**
  - Current pattern is strategically wrong if unsaved hobbies get more generous access than active ones
  - Refactor so the coach’s value appears strongest when the user is actively trying to continue
  - **Test:** coach access logic aligns with product strategy

- [x] **K.2 — Reframe free vs Pro around continuity**
  - Free should help users:
    - start
    - ask one or two meaningful starter questions
    - get one recovery assist
  - Pro should help users:
    - continue
    - recover
    - get ongoing support through friction
  - **Test:** free/Pro boundary feels intuitive and fair

- [x] **K.3 — Improve upgrade timing**
  - Trigger premium moments after:
    - useful coach value
    - recovery moments
    - real progression moments
  - Avoid upgrade pressure before value is felt
  - **Test:** paywall timing feels more natural

- [x] **K.4 — Align upgrade language with coach value**
  - Emphasize:
    - know the next step
    - get unstuck
    - keep the hobby alive after week 1
  - Avoid feature-list-first framing
  - **Test:** coach-related upgrade moments feel emotionally coherent

---

## Sprint L: Full Visual Consistency Pass

Keep the teal + burgundy atmosphere, but make the rest of the app harmonize with it.

- [x] **L.1 — Keep teal/burgundy background intentionally**
  - Retain the atmospheric teal + burgundy background treatment
  - Do not replace it with a different visual base
  - Instead, harmonize all surfaces, type, and accents with it
  - **Test:** background feels like atmosphere, not visual competition

- [x] **L.2 — Reduce accent overuse**
  - Audit screens for coral overuse
  - Keep one clear primary coral CTA per screen where possible
  - Demote competing accents to quiet neutrals
  - **Test:** screens feel calmer and more expensive

- [x] **L.3 — Audit card/material hierarchy**
  - Ensure all screens use a coherent material family:
    - grounded surfaces
    - floating surfaces
    - focal surfaces
  - Remove mixed old/new card language where it still exists
  - **Test:** screens feel built from the same system

- [x] **L.4 — Metadata consistency pass**
  - Ensure metadata treatment is consistent across:
    - feed cards
    - list cards
    - detail
    - You
    - search results
    - roadmap
  - **Test:** metadata styling is quiet, premium, and consistent

- [x] **L.5 — CTA hierarchy consistency pass**
  - Audit every major screen for:
    - one primary action
    - quieter secondary actions
    - no cluttered CTA stacks
  - **Test:** CTA hierarchy feels obvious everywhere

---

## Sprint M: Refactor for Maintainability

The redesign has landed, but the screen files are still too large.

- [x] **M.1 — Refactor Discover into sections/components**
  - Break out:
    - top chrome
    - feed wrapper
    - card renderer
    - list renderer
    - filter logic
    - empty states
  - **Test:** Discover becomes easier to reason about and maintain

- [x] **M.2 — Refactor You into smaller sections**
  - Break out:
    - header
    - Active section
    - Saved section
    - Tried section
    - utility rows
  - **Test:** You screen is easier to evolve cleanly

- [x] **M.3 — Refactor Search**
  - Break out search chrome, suggestions, result groups, and cards
  - **Test:** Search becomes cleaner and easier to polish

- [x] **M.4 — Refactor Detail**
  - Extract upper hero, quick-start section, why-fits section, roadmap block, coach teaser, CTA area
  - **Test:** detail page becomes easier to tune

- [x] **M.5 — Refactor Home**
  - Extract active hobby hero, next-step block, week plan, coach module, restart prompt
  - **Test:** Home becomes easier to polish without regressions

- [x] **M.6 — Remove or isolate legacy product mass**
  - Audit older secondary screens still living in the repo
  - Hide, isolate, or clearly mark legacy/secondary surfaces that should not influence the main product direction
  - **Test:** legacy features stop exerting structural pressure on the main app

---

## Sprint N: Final Premium Polish + QA

This is the last stretch from “very improved” to “finished premium beta.”

- [x] **N.1 — Motion consistency pass**
  - Standardize tap, screen, and card transitions
  - Ensure motion is calm, tactile, and not busy
  - **Test:** app interactions feel expensive and coherent

- [x] **N.2 — Haptic pass**
  - Add or refine haptics for:
    - save
    - tab switch
    - complete step
    - primary CTA
    - coach chip
    - confirmation flows
  - **Test:** haptics feel supportive, not noisy

- [x] **N.3 — Empty states + loading states QA**
  - Ensure all empty/loading/error states follow the premium system
  - No ugly defaults or low-effort placeholders
  - **Test:** all states feel designed

- [x] **N.4 — Device visual QA**
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

- [x] **N.5 — End-to-end premium QA**
  - Run through:
    - onboarding → match → start → week 1 → coach → return
    - free → hit meaningful limitation → upgrade
    - save hobby → return later
    - switch to list mode → search → detail → start
  - **Test:** the app feels coherent all the way through

  ## Definition of Done for Sprints G to N:

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


---

- **Sprints O to T (Premium Coach Rebuild)**

This covers the next major opportunity:
**make the AI Coach screen, flows, and premium value feel truly productized and worth paying for.**

> **Strategy:** Turn the AI Coach from a generic chat surface into a premium guidance workspace worth paying for.
> **Core loop:** Choose 1 hobby → Start it → Do step 1 → Come back tomorrow
> **Coach goal:** Make the coach the strongest premium feature in the app
> **Coach promise:** Know the next step. Get unstuck fast. Keep the hobby alive after week 1.

---

## Sprint O: Rebuild the Coach Screen Architecture

The current coach logic is improved, but the screen still feels like a generic AI chat wrapper. Rebuild it into a premium guidance workspace.

- [ ] **O.1 — Redefine the coach screen as a guidance workspace**
  - Stop treating the coach primarily as a chat screen
  - The screen should visually communicate:
    - the current hobby
    - the current stage
    - what the coach can help with right now
    - the user’s next step
  - Remove the “generic AI chat” feel as the dominant identity
  - **Test:** coach screen feels productized before the user sends a message

- [ ] **O.2 — Add a premium context hero at the top**
  - Build a top context card showing:
    - hobby title
    - current mode
    - current stage/week
    - next step
    - recent activity context (for example, last active 2 days ago)
  - This must be visually richer than the current thin header
  - It should feel like a premium support space, not a page title bar
  - **Test:** top of coach gives useful context even before interaction

- [ ] **O.3 — Replace the thin header with a stronger premium header system**
  - Remove or de-emphasize the current minimal “AI Coach” style header
  - Replace with:
    - hobby identity
    - guidance context
    - calmer top controls
  - Refresh behavior, if kept, should be quieter and less utilitarian
  - **Test:** top chrome feels premium and intentional

- [ ] **O.4 — Add explicit coach mode selector**
  - Add a segmented premium mode switch:
    - Start
    - Momentum
    - Rescue
  - This should live near the top and visually define the screen state
  - Switching mode should change the quick actions and prompt framing
  - **Test:** mode changes are obvious, useful, and visually smooth

- [ ] **O.5 — Rebuild the empty state**
  - Replace the current icon/title/chips empty state with a richer premium onboarding state for the coach
  - Empty state should communicate:
    - what this coach does
    - what it can help with right now
    - why it is different from generic chat
  - Keep it calm, premium, and action-first
  - **Test:** first-time coach entry feels valuable before typing

- [ ] **O.6 — Reduce the dominance of the raw text composer**
  - The text input should remain available, but it should not dominate the screen
  - The first interaction should feel guided, not blank-page conversational
  - Rebalance the layout so guided actions matter more than typing from scratch
  - **Test:** coach can be meaningfully used without typing first

---

## Sprint P: Structured Coach Responses + Action Cards

The biggest missing premium layer is that coach responses are too flat. Replace plain assistant bubbles with structured, actionable response blocks.

- [ ] **P.1 — Add structured response rendering system**
  - Support multiple assistant response types instead of only plain chat bubbles
  - At minimum, add rendering support for:
    - quick plan cards
    - cost reducer cards
    - recovery cards
    - reflection cards
    - week-plan adjustment cards
  - Keep a plain text fallback if needed, but premium cards should become the preferred experience
  - **Test:** assistant can render at least two non-bubble structured response types

- [ ] **P.2 — Build “Tonight’s easiest plan” card**
  - Card should include:
    - session length
    - what to use
    - what to do
    - what to ignore
  - Add CTA buttons like:
    - Start this session
    - Adjust it
  - **Test:** card renders correctly and actions work

- [ ] **P.3 — Build “Cheaper way to start” card**
  - Card should include:
    - what to buy now
    - what to skip
    - cheaper substitutes if relevant
  - Add CTA buttons like:
    - Use this version
    - Show starter kit
  - **Test:** card makes budget coaching feel premium and useful

- [ ] **P.4 — Build “Restart gently” recovery card**
  - Card should appear for inactivity or rescue mode
  - Include:
    - one tiny restart action
    - low-pressure framing
    - continue/switch options
  - Add CTA buttons like:
    - Restart now
    - Maybe switch hobbies
  - **Test:** recovery card feels supportive and practical

- [ ] **P.5 — Build reflection prompt card**
  - Card should support post-session reflection and route to the Journal where useful
  - Include:
    - one or two reflective prompts
    - clear next action
  - Add CTA buttons like:
    - Open reflection
    - Skip for now
  - **Test:** reflection card integrates cleanly with journal flow

- [ ] **P.6 — Build week-plan adjustment card**
  - Card should allow the coach to revise the user’s current week plan
  - Include:
    - what changed
    - why it changed
    - lighter version if needed
  - Add CTA buttons like:
    - Apply update
    - Keep original
  - **Test:** coach can propose and apply plan changes

- [ ] **P.7 — Improve assistant message styling**
  - Even plain assistant messages should feel more premium:
    - more breathing room
    - better hierarchy
    - less generic bubble styling
  - Distinguish:
    - coach guidance
    - coach actions
    - user messages
  - **Test:** coach timeline feels richer and more intentional

---

## Sprint Q: Quick Actions, Modes, and Guided Flows

The coach should make it obvious what help is available before users type anything.

- [ ] **Q.1 — Replace simple chips with premium quick-action cards**
  - Upgrade the current lightweight chips into more substantial quick-action surfaces
  - At minimum, support:
    - Help me start tonight
    - Make this cheaper
    - What should I do next?
    - I skipped a few days
    - I’m losing motivation
    - Maybe this hobby isn’t for me
  - **Test:** quick actions feel premium and useful, not like placeholder chips

- [ ] **Q.2 — Make quick actions mode-aware**
  - Start mode should emphasize:
    - first session
    - starter kit
    - low-cost entry
    - fear reduction
  - Momentum mode should emphasize:
    - next step
    - plan simplification
    - consistency
  - Rescue mode should emphasize:
    - restart
    - friction reduction
    - switch decision support
  - **Test:** each mode surfaces clearly different guidance

- [ ] **Q.3 — Add “continue or switch?” support**
  - Build a dedicated coach flow for:
    - “Maybe this hobby isn’t for me”
  - Flow should help user decide whether to:
    - continue with a simpler version
    - change pacing
    - switch to a better adjacent hobby
  - **Test:** flow feels supportive, not judgmental

- [ ] **Q.4 — Add “what should I do next?” guidance flow**
  - When triggered, the coach should respond with a practical, stage-aware suggestion
  - Prefer structured response cards over plain text
  - **Test:** next-step guidance feels tied to real progress context

- [ ] **Q.5 — Add “make this cheaper” guidance flow**
  - Connect to hobby starter-kit logic and budget framing
  - The result should feel like real budget coaching, not generic text
  - **Test:** cheaper-flow responses are specific and useful

- [ ] **Q.6 — Add “start tonight” guidance flow**
  - This should be one of the strongest default premium-feeling actions
  - Coach should provide:
    - tiny session plan
    - low-pressure framing
    - direct launch path into session or plan
  - **Test:** user can go from coach to action in one or two taps

---

## Sprint R: Coach Integration with Home, Detail, Roadmap, and Journal

The coach should not feel isolated. It should feel embedded in the product.

- [ ] **R.1 — Strengthen coach entry from Home**
  - Make Home → Coach entry context-rich
  - Pass:
    - current stage
    - next step
    - inactivity signal if relevant
  - **Test:** coach opens already knowing why the user came

- [ ] **R.2 — Strengthen coach entry from Hobby Detail**
  - Coach should understand:
    - this hobby is not yet active
    - user may be exploring
    - user may need cheapest/easiest start
  - **Test:** detail-page coach feels tailored to pre-commitment state

- [ ] **R.3 — Strengthen coach entry from Roadmap**
  - “Stuck?” should route to coach with stage-aware context
  - Coach should answer in terms of the specific current stage
  - **Test:** roadmap-to-coach flow feels coherent and useful

- [ ] **R.4 — Connect reflection prompts to Journal**
  - Coach reflection cards should route smoothly into journal flows where appropriate
  - Coach should be able to reference recent journal insights in later guidance
  - **Test:** Journal and Coach feel connected, not separate features

- [ ] **R.5 — Connect week-plan adjustments back into Home**
  - If the coach simplifies or changes the week plan, Home should reflect the new plan
  - **Test:** coach changes visibly update the main product flow

---

## Sprint S: Premium Value and Monetization Clarity for Coach

The coach should visually and functionally feel like a reason to pay.

- [ ] **S.1 — Reframe coach premium promise in UI copy**
  - Change coach-adjacent copy from generic AI framing to premium support framing
  - Emphasize:
    - know the next step
    - get unstuck fast
    - restart without overthinking
    - keep the hobby alive after week 1
  - **Test:** coach language sounds like a premium guidance product

- [ ] **S.2 — Improve free coach experience so value is obvious**
  - Free users should still experience:
    - one or two genuinely useful starter interactions
    - one meaningful recovery/support moment
  - Do not make the free experience feel too crippled to understand the value
  - **Test:** free users can understand why the coach matters

- [ ] **S.3 — Make Pro feel like continuity ownership**
  - Pro coach value should center on:
    - ongoing guidance
    - rescue support
    - adaptive weekly help
    - reflection-aware planning
  - Avoid making premium feel like only “more messages”
  - **Test:** Pro feels like deeper support, not just usage volume

- [ ] **S.4 — Improve coach-related paywall triggers**
  - Coach-related upgrade prompts should appear after meaningful value moments
  - Good trigger examples:
    - after a useful quick plan
    - after a rescue flow
    - after plan adjustment
  - Avoid pushing upgrade before the user sees the difference
  - **Test:** upgrade moments feel natural and contextually justified

- [ ] **S.5 — Add premium coach feature cues inside the screen**
  - Make the coach screen itself visually suggest premium depth:
    - adaptive plans
    - rescue help
    - week adjustments
    - reflection memory
  - Do this without cluttering the UI
  - **Test:** even before paying, users can understand why the coach is premium

---

## Sprint T: Coach Visual Polish, Motion, and QA

Once the coach architecture and response system are rebuilt, finish the premium quality pass.

- [ ] **T.1 — Motion pass for coach**
  - Add calm, tactile animations for:
    - mode switching
    - quick-action expansion
    - structured response card entry
    - composer focus transitions
  - Motion must feel premium, not noisy
  - **Test:** coach interactions feel alive and expensive

- [ ] **T.2 — Haptic pass for coach**
  - Add haptics for:
    - quick-action tap
    - mode switch
    - apply-plan action
    - restart-now action
    - successful coach action completion
  - **Test:** haptics feel subtle and useful

- [ ] **T.3 — Empty/loading/error state QA**
  - Ensure:
    - empty state
    - loading replies
    - failed responses
    - no remaining-message state
  - all feel designed and premium
  - **Test:** no ugly generic state remains in coach

- [ ] **T.4 — Device QA**
  - Test on physical device:
    - top hero spacing
    - keyboard behavior
    - input bar placement
    - card scrolling
    - mode switch comfort
    - no clipping or awkward overlays
  - **Test:** coach screen feels polished on-device

- [ ] **T.5 — End-to-end coach QA**
  - Run through:
    - new user starting first hobby
    - active user asking what’s next
    - stalled user using rescue
    - user asking for cheaper version
    - user deciding whether to switch
    - free user hitting meaningful coach limitation
    - Pro user continuing smoothly
  - **Test:** the coach feels premium all the way through

---

## Definition of Done for v6

This coach rebuild is done when:

- The coach no longer feels like a generic AI chat screen
- The top of the screen gives useful context before the user types
- Start / Momentum / Rescue are visually and functionally real modes
- Assistant replies can render structured, actionable premium cards
- The coach integrates cleanly with Home, Detail, Roadmap, and Journal
- The coach feels like one of the strongest reasons to pay for Pro
- Free users can understand its value, and Pro users can feel its depth
- The coach screen visually matches the rest of the premium app

