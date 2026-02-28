# TrySomething — Motion & Animation Spec

## Philosophy
Motion communicates hierarchy, not decoration.
Every animation serves a purpose: guide attention, confirm action, or show spatial relationship.

---

## Timing Tokens

| Token    | Duration | Curve                  | Use Case                        |
|----------|----------|------------------------|---------------------------------|
| `fast`   | 150ms    | `easeInOut`            | Micro-interactions, toggles     |
| `normal` | 250ms    | `easeOutCubic`         | Standard transitions, fades     |
| `slow`   | 350ms    | `easeInOutCubic`       | Page transitions, reveals       |
| `hero`   | 500ms    | `easeOutCubic`         | Shared element transitions      |
| `spring` | 400ms    | `elasticOut`           | Checkbox, button press          |

---

## 1. Card Swipe Physics (Discovery Feed)

```
Axis:           Vertical (PageView)
ViewportFraction: 0.92 (peek next card edges)
Spring:         damping 0.8, stiffness 300
Snap:           Snap to full card on release
Velocity threshold: 300px/s for page commit
```

### Parallax on Scroll
- Card background image moves at 0.5x scroll velocity
- Creates depth without disorientation
- Implementation: `Transform.translate(offset: Offset(0, scrollOffset * 0.5))`

### Card Press Effect
- Scale: 1.0 → 0.975 on tap down (150ms, easeInOut)
- Release: 0.975 → 1.0 (150ms, easeOut)
- Shadow deepens slightly on press

---

## 2. Shared Element Transitions (Feed → Detail)

### Image Expansion
```
Duration:  500ms
Curve:     easeOutCubic
Behavior:  Card image expands to fill hero area
           Clip radius: 20 → 0
           Position: card position → top of screen
```

### Spec Badge Slide
```
Duration:  400ms (starts at 100ms delay)
Curve:     easeOutCubic  
Behavior:  Badges slide from card position into spec bar
           Opacity: 0 → 1 (first 200ms)
```

### Title Reveal
```
Duration:  350ms (starts at 150ms delay)
Curve:     easeOutCubic
Behavior:  Title slides up 20px and fades in
```

### Implementation Notes
- Use Flutter's `Hero` widget with custom `flightShuttleBuilder`
- Tag: `hobby_image_${hobby.id}`, `hobby_title_${hobby.id}`
- Custom `RectTween` for non-linear position interpolation

---

## 3. Try Today Button

### Idle State — Breathing Glow
```
Duration:  1800ms (repeat, reverse)
Property:  boxShadow blur 12→16, opacity 0.3→0.7
Color:     electricCyan (alpha oscillates)
Purpose:   Draws eye without being aggressive
```

### Press State
```
Duration:  120ms
Scale:     1.0 → 0.97
Shadow:    Blur increases to 20, spreadRadius: 2
Color:     Glow opacity jumps to 0.6
```

### Release
```
Duration:  200ms  
Curve:     easeOutCubic
Scale:     0.97 → 1.0
Shadow:    Returns to breathing animation
```

---

## 4. Checkbox Animation (Roadmap Steps)

### Check ON
```
Duration:  400ms
Phase 1:   Circle fill (0–200ms) — color transparent → electricCyan
Phase 2:   Checkmark scale (0–240ms) — scale 0 → 1, elasticOut
Phase 3:   Checkmark opacity (0–120ms) — opacity 0 → 1, easeIn
```

### Check OFF  
```
Duration:  250ms
Behavior:  Reverse of check ON but with easeInOut (no elastic)
```

### Step Tile State Change
```
Duration:  250ms
Curve:     easeOutCubic
Properties:
  - Background color shifts
  - Border color/width changes  
  - Text color dims + strikethrough appears
  - Time badge dims
```

---

## 5. Page Transitions

### Forward Navigation (push)
```
Duration:  350ms
Curve:     easeInOutCubic
New page:  Slides in from right (offset 1.0 → 0.0)
Old page:  Slides left slightly (offset 0.0 → -0.3) + dims to 95% opacity
```

### Back Navigation (pop)
```
Duration:  300ms  
Curve:     easeOutCubic
Current:   Slides out to right
Previous:  Slides back from -0.3 → 0.0 + opacity 0.95 → 1.0
```

### Bottom Sheet (detail overlays)
```
Duration:  350ms
Curve:     easeOutCubic
Behavior:  Slides up from bottom with backdrop blur fade-in
Backdrop:  Color(0x60000000) with 8px blur
```

---

## 6. Onboarding Transitions

### Page Swipe
```
Controller: PageView with NeverScrollableScrollPhysics (button-driven)
Duration:   400ms
Curve:      easeOutCubic
Content:    Cross-fade + slight horizontal slide
```

### Progress Bar
```
Duration:  300ms
Curve:     easeOutCubic
Behavior:  Bar segments fill with color as pages advance
```

### Vibe Icon Cluster (Welcome page)
```
Entry:     Staggered fade-in + scale (each icon 150ms apart)
Idle:      Subtle float animation (translateY ±4px, 3000ms loop)
```

---

## 7. Micro-interactions

### Save Button
```
Tap:       Scale 1.0 → 1.2 → 1.0 (300ms, elasticOut)
Icon:      bookmark_border → bookmark (cross-fade 150ms)
Color:     white → electricCyan (200ms)
```

### Category Tile Press
```
Duration:  200ms  
Icon:      Scale 1.0 → 1.12 (easeOutCubic)
Release:   Scale 1.12 → 1.0
```

### Tab Switch
```
Indicator: Slide to new position (250ms, easeOutCubic)
Icon:      AnimatedSwitcher with fade (200ms)
```

### Filter Toggle
```
Duration:  200ms
Panel:     AnimatedContainer height 0 → content height
           Combined with opacity fade
```

---

## 8. Scroll Behaviors

### Feed Parallax
```
Image offset:  scrollPosition * 0.5 (clamped 0–80px)
Direction:     Image moves up slower than content
```

### Detail Page
```
Hero parallax:  scrollPosition * 0.5
AppBar fade-in: Opacity increases as hero scrolls out of view
Spec bar:       Becomes sticky at scroll threshold
```

### Overscroll
```
Behavior:  BouncingScrollPhysics on iOS
           ClampingScrollPhysics on Android
           Custom: slight rubber-band feel on both
```

---

## Motion Don'ts

1. **No decorative bouncing** — spring only for confirmations (checkbox, button)
2. **No auto-playing carousels** — user controls all movement
3. **No loading spinners longer than 200ms** — use skeleton shimmer instead
4. **No page transitions longer than 500ms** — respect user's time
5. **No motion-sickness triggers** — avoid rapid zoom, rotation, parallax >0.5x
6. **No animation on re-render** — only on state change or user action

---

## Accessibility

- Respect `MediaQuery.disableAnimations` / `AccessibilityFeatures.reduceMotion`
- When reduced motion: all durations → 0ms, all transitions → instant cut
- Keep focus indicators visible regardless of motion preference
- Timer animations (quickstart) still count but don't animate the display
