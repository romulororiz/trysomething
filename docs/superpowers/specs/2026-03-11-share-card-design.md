# Share Card Feature — Design Spec

**Date:** 2026-03-11
**Status:** Approved

---

## Goal

When a user taps share on a hobby card (feed or detail screen), the app generates a premium branded image — the "Cinematic Poster" — and opens the system share sheet with it.

---

## Approved Visual Design: Cinematic Poster

Locked in after visual brainstorming session.

### Layout

- **Card size**: 900×1260px (rendered off-screen at 3× logical pixels → 300×420 logical)
- **Background**: `hobby.imageUrl` full-bleed via `CachedNetworkImage`, opacity `0.52`
- **Gradient overlay**: Linear bottom-to-top — `rgba(10,10,15,0.97)` at 0% → `rgba(10,10,15,0.20)` at 55% → transparent at 100%
- **Top-right**: `assets/images/app_logo.png` (brushstroke T), 42px logical, no background, floating
- **Bottom content** (20px horizontal padding, 16px bottom padding):
  1. Category label — `hobby.category`, 8pt IBM Plex Mono, uppercase, coral `#FF6B6B`, letterSpacing 1.4
  2. Hobby name — `hobby.title`, 30pt Source Serif 4 w800, warm cream `#F5F0EB`, lineHeight 1.05
  3. Hook — `hobby.hook`, 10pt DM Sans, warm gray `#B0A89E`, lineHeight 1.45
  4. Hairline divider — 1px, `rgba(255,255,255,0.06)`
  5. Wordmark — `"Try"` in coral `#FF6B6B` + `"Something"` in warm cream `#F5F0EB`, Source Serif 4 12pt w700

---

## Architecture

### New file: `lib/components/share_card.dart`

Two exports:

**`ShareCard` widget** — pure layout widget, no state. Accepts a `Hobby`. Builds the cinematic poster layout. Used off-screen inside a `RepaintBoundary` during capture; never shown directly in the UI.

**`shareHobby(BuildContext context, Hobby hobby)` async function** — the full pipeline:

1. **Guard against re-entry** — `shareHobby` uses a module-level `bool _sharing = false`. If `_sharing` is true when called, return immediately (no-op). Set `_sharing = true` at the start, `_sharing = false` in a `finally` block. This prevents parallel invocations from rapid taps.

2. **Precache image** — if `hobby.imageUrl` is non-empty: `await precacheImage(CachedNetworkImageProvider(hobby.imageUrl), context)`. If empty, skip (card uses solid-color fallback).

3. **Insert off-screen** — Create a `GlobalKey<RenderRepaintBoundary>` (`boundaryKey`). Create an `OverlayEntry`:

   ```dart
   final entry = OverlayEntry(
     builder: (_) => Offstage(
       child: SizedBox(
         width: 300, height: 420,
         child: RepaintBoundary(
           key: boundaryKey,
           child: ShareCard(hobby: hobby),
         ),
       ),
     ),
   );
   ```

   `Overlay.of(context)` returns a nullable `OverlayState`. If null, throw an `Exception` to let the outer `try/catch` handle it. Otherwise call `.insert(entry)`.

4. **Wait two frames** — two sequential awaits ensure image decode and paint both complete:

   ```dart
   await WidgetsBinding.instance.endOfFrame;
   await WidgetsBinding.instance.endOfFrame;
   ```

5. **Capture** — Cast `boundaryKey.currentContext!.findRenderObject()` to `RenderRepaintBoundary`, call `await boundary.toImage(pixelRatio: 3.0)`, then `await image.toByteData(format: ImageByteFormat.png)`. If `toByteData` returns null, throw an `Exception('toByteData returned null')` to let the outer catch handle it.

6. **Cleanup** — `entry.remove()` immediately after capture, before any further awaits.

7. **Write to temp file** — `final dir = await getTemporaryDirectory()`, filename `share_${DateTime.now().millisecondsSinceEpoch}.png`. Write PNG bytes.

8. **Share** — `await Share.shareXFiles([XFile(path, mimeType: 'image/png')], text: "I'm trying ${hobby.title} on TrySomething")`.

9. **mounted guard before snackbar** — the catch block checks `context.mounted` before calling `ScaffoldMessenger.of(context)`. If not mounted, swallow silently.

**`ShareCard` image fallback**: if `hobby.imageUrl` is empty, use `Container(color: AppColors.surfaceElevated)` in place of `CachedNetworkImage`. Gradient and text still render correctly over it.

**Noise texture**: do NOT include the app's noise texture overlay in `ShareCard`. The noise overlay is a screen-rendering effect; it looks poor in exported images and should be omitted.

**Fonts**: Source Serif 4, DM Sans, and IBM Plex Mono are loaded at app startup via `google_fonts` and are cached by the time any user action triggers `shareHobby`. No additional font-loading step is needed. The two `endOfFrame` awaits in step 4 are sufficient to ensure fonts have rendered before capture.

### Wiring points

**`lib/screens/feed/rail_feed_screen.dart`**

Inside the existing `PageView.builder` `itemBuilder`, the existing `HobbyCard(...)` call gains one new named argument:

```dart
onShare: () => shareHobby(context, hobby),
```

`HobbyCard` already declares `onShare` as an optional field — no change to the widget itself is needed. `context` is the `BuildContext` from the `build` method of `_RailFeedScreenState`. `hobby` is the local variable declared at `final hobby = hobbies[index]` on the line immediately before the existing `HobbyCard(...)` call.

**`lib/screens/detail/hobby_detail_screen.dart`**

The share `GestureDetector` at approximately line 245 has `onTap: () {}`. Replace with:

```dart
onTap: () => shareHobby(context, hobby),
```

`hobby` is the non-null `Hobby` object resolved from the hobby provider via `ref.watch(...)` at the top of `build()` — it is `hobbyAsync.valueOrNull` guarded by an early return, so it is guaranteed non-null at line 245. No additional null-guard is needed. The `hobby` variable is local to `build()`, not a constructor parameter.

**Share button UX**: fire-and-forget. No loading indicator on the button. The system share sheet appears once ready. The gap between tap and sheet appearing is typically < 1 second (image is small, already cached). Acceptable UX; no spinner needed.

**`pubspec.yaml`**: add `path_provider: ^2.1.2` as a direct dependency. Add it verbatim — the transitive version already in `pubspec.lock` satisfies this constraint, so no version conflict will occur.

### Not in scope

- Share from `_HeroCard` / `_CompactCard` in `discover_feed_screen.dart`
- User-editable share text
- Share analytics event (handled separately via PostHog)

---

## Dependencies

| Package | Already present | Action |
| ------- | --------------- | ------ |
| `share_plus: ^10.1.4` | ✅ in pubspec.yaml | None |
| `path_provider` | ✅ in pubspec.lock (transitive) | Add as direct dep |
| `cached_network_image` | ✅ | None |

---

## Error Handling

- Entire pipeline in `try/catch`
- Check `context.mounted` before showing snackbar
- On error: `ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Couldn't create share card")))` — raw English string, no localization key needed (app has no l10n system)
- `share_plus` does **not** throw when the user cancels the share sheet — cancellation is silent and normal. The `catch` block only fires on real errors (IO failure, render failure, etc.). Do not log cancellations as errors.
- Never rethrow or crash
- `_sharing` flag reset in `finally` block regardless of success or failure

---

## Share Text

`"I'm trying ${hobby.title} on TrySomething"`

Shown in apps that accept both image + text (iMessage, WhatsApp). Apps that only accept images ignore it.
