# Premium Discover + Feed + Session Overhaul — Design Spec

**Date:** 2026-03-13
**Scope:** 6 issues across Discover, TikTok Feed, and Session screens

---

## 1. Discover Scroll Clipping Fix

**Problem:** Search bar in fixed Column above CustomScrollView clips content hard.
**Solution:** Convert to NestedScrollView with SliverAppBar (floating, snap) for the search bar. Content scrolls seamlessly underneath. Hero image gets parallax (0.7x speed).

**Files:** `lib/screens/feed/discover_feed_screen.dart`

## 2. Search Input Black Background + Pill Centering

**Problem:** TextField injects default dark fill. SearchChip vertical text centering is off.
**Solution:** Add `filled: true, fillColor: Colors.transparent` to InputDecoration. For chips: fixed `height: 32`, `alignment: Alignment.center` on container.

**Files:** `lib/screens/feed/discover_feed_screen.dart`

## 3. NLP Pills Centering + Search Logic Fix

**Problem:** Wrap not centered. NLP matching too loose (substring matching creates false positives).
**Solution:** Center Wrap with `alignment: WrapAlignment.center`. Fix NLP to use exact word matching. Weight budget/time more heavily. Add whyLove field matching.

**Files:** `lib/screens/feed/discover_feed_screen.dart`

## 4. Premium Rails Redesign

**Problem:** Static horizontal ListView with no motion.
**Solution:**
- Staggered fade-up reveal on first scroll into view (100ms stagger)
- Parallax on card images (0.5x horizontal shift)
- Rail headers get coral gradient glow line (1px, fading edges)
- Cards get 3D tilt on press (2-3 degree perspective transform)
- New "NEED A DIFFERENT VIBE?" rail with larger editorial cards

**Files:** `lib/screens/feed/discover_feed_screen.dart`

## 5. TikTok Feed Identity

**Problem:** Bare PageView on black — no app identity.
**Solution:**
- Category-colored ambient glow at bottom (3-5% opacity)
- Smooth parallax on image during page transitions
- "Typing" effect for hobby hook text as card enters view
- NO noise grain, NO page indicator, NO CTA breathing animation

**Files:** `lib/screens/feed/rail_feed_screen.dart`, `lib/components/hobby_card.dart`

## 6. Session Particle Cosmos

**Problem:** BrushstrokeTimerPainter is a simple S-curve — not mesmerizing.
**Solution:** Replace with category-themed particle field via CustomPainter:

| Category | Theme | Color |
|----------|-------|-------|
| Creative | Paint splatter / orbiting dots | Warm coral mist |
| Outdoors | Floating leaves / wind particles | Sage green mist |
| Fitness | Energy pulse / expanding rings | Amber glow |
| Music | Sound wave ripples | Indigo waves |
| Food | Gentle steam / rising bubbles | Warm golden mist |
| Maker | Geometric fragments / crystal shards | Cool steel glow |
| Mind | Breathing circles / zen ripples | Soft lavender mist |
| Collecting | Scattered dots converging | Warm cream constellation |
| Social | Interconnecting nodes | Peach warm glow |

Features:
- 40-80 particles in circular field (200-260px radius)
- Slow orbit + subtle drift
- Progress fills by particles activating (dim → bright)
- Completion: burst outward then converge to center
- Ambient breathing scale on particle cloud

### Session Alarm
- Haptic pattern: medium → light → light → medium
- Visual: particle burst + "Session complete" text
- Settings: Sound toggle, Vibration toggle, Sound selection (Gentle chime / Soft bell / Silent)
- Uses `audioplayers` package

**Files:**
- `lib/components/particle_timer_painter.dart` (NEW)
- `lib/screens/session/session_timer_phase.dart`
- `lib/providers/session_provider.dart`
- `lib/screens/settings/settings_screen.dart`
