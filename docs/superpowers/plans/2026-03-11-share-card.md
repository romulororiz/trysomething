# Share Card Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Generate a "Cinematic Poster" branded image when users tap share on a hobby card and open the system share sheet.

**Architecture:** A new `lib/components/share_card.dart` exports two things: `ShareCard` (a pure layout widget for off-screen rendering) and `shareHobby()` (an async function that captures the widget as a PNG via `RepaintBoundary.toImage`, saves it to a temp file, and shares it with `share_plus`). Two existing screens wire in `shareHobby` at their share button tap handlers.

**Tech Stack:** Flutter 3.6, `share_plus ^10.1.4` (already in pubspec), `path_provider ^2.1.2` (to add), `cached_network_image` (already in pubspec), `google_fonts` (already in pubspec).

**Spec:** `docs/superpowers/specs/2026-03-11-share-card-design.md`

---

## File Map

| File | Action | Responsibility |
| ---- | ------ | -------------- |
| `lib/components/share_card.dart` | **Create** | `ShareCard` widget + `shareHobby()` pipeline |
| `lib/screens/feed/rail_feed_screen.dart` | **Modify** | Add `onShare` to `HobbyCard` call |
| `lib/screens/detail/hobby_detail_screen.dart` | **Modify** | Wire share button `onTap` |
| `pubspec.yaml` | **Modify** | Add `path_provider: ^2.1.2` |

---

## Chunk 1: Dependency + ShareCard component

### Task 1: Add path_provider dependency

**Files:**
- Modify: `pubspec.yaml:54-55`

- [ ] **Step 1: Add path_provider after the share_plus line**

Open `pubspec.yaml`. Find this block (includes the blank line and `# Firebase` comment as anchor):

```yaml
  # Sharing
  share_plus: ^10.1.4

  # Firebase
```

Change it to:

```yaml
  # Sharing
  share_plus: ^10.1.4
  path_provider: ^2.1.2

  # Firebase
```

- [ ] **Step 2: Install the dependency**

```bash
cd d:/programming/projetos/trysomething
flutter pub get
```

Expected: output ends with `Got dependencies!` and no errors.

- [ ] **Step 3: Commit**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "chore: add path_provider as direct dependency for share card"
```

---

### Task 2: Create share_card.dart

**Files:**
- Create: `lib/components/share_card.dart`

This file has two exports: `ShareCard` (the visual widget) and `shareHobby()` (the capture + share pipeline). Write the complete file in one step — both exports are tightly coupled and small enough to hold in context together.

- [ ] **Step 1: Create the file with complete content**

Create `lib/components/share_card.dart` with exactly this content:

```dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/hobby.dart';
import '../theme/app_colors.dart';

// Module-level flag prevents parallel share pipelines from rapid taps.
bool _sharing = false;

/// Generates the "Cinematic Poster" share card for [hobby] and opens the
/// system share sheet. Fire-and-forget — callers do not await this.
Future<void> shareHobby(BuildContext context, Hobby hobby) async {
  if (_sharing) return;
  _sharing = true;
  OverlayEntry? entry;
  try {
    // 1. Precache the hobby image so it renders synchronously inside the card.
    if (hobby.imageUrl.isNotEmpty) {
      await precacheImage(
        CachedNetworkImageProvider(hobby.imageUrl),
        context,
      );
    }

    // 2. Insert ShareCard off-screen inside an Offstage OverlayEntry.
    final boundaryKey = GlobalKey<RenderRepaintBoundary>();
    // NOTE: Use Overlay.maybeOf (nullable) not Overlay.of — in Flutter 3.6,
    // Overlay.of() is non-nullable and asserts rather than returning null.
    // maybeOf is the correct API for a safe null check.
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) throw Exception('No Overlay found in context');

    entry = OverlayEntry(
      builder: (_) => Offstage(
        child: SizedBox(
          width: 300,
          height: 420,
          child: RepaintBoundary(
            key: boundaryKey,
            child: ShareCard(hobby: hobby),
          ),
        ),
      ),
    );
    overlay.insert(entry);

    // 3. Wait two frames: first completes layout, second completes image decode.
    await WidgetsBinding.instance.endOfFrame;
    await WidgetsBinding.instance.endOfFrame;

    // 4. Capture the rendered boundary as a PNG at 3× pixel ratio → 900×1260px.
    final boundary = boundaryKey.currentContext!.findRenderObject()
        as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) throw Exception('toByteData returned null');

    // 5. Remove the overlay entry before sharing (keeps tree clean).
    entry.remove();
    entry = null;

    // 6. Write to a timestamped temp file to avoid collision on rapid taps.
    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/share_${DateTime.now().millisecondsSinceEpoch}.png';
    await File(path).writeAsBytes(byteData.buffer.asUint8List());

    // 7. Open the system share sheet with the image and share text.
    await Share.shareXFiles(
      [XFile(path, mimeType: 'image/png')],
      text: "I'm trying ${hobby.title} on TrySomething",
    );
  } catch (_) {
    // share_plus does NOT throw on user cancellation — only real errors land here.
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't create share card")),
      );
    }
  } finally {
    // Always clean up the overlay entry and re-enable sharing.
    entry?.remove();
    _sharing = false;
  }
}

/// Off-screen widget that renders the "Cinematic Poster" share card.
///
/// Layout at 300×420 logical pixels (900×1260px at pixelRatio 3.0):
/// - Full-bleed hobby image at 52% opacity (or solid dark fallback)
/// - Bottom-to-top gradient overlay
/// - Brushstroke T logo top-right (no background)
/// - Category / title / hook / divider / wordmark at bottom
///
/// Do NOT add the app's noise texture overlay — it looks poor in exported images.
class ShareCard extends StatelessWidget {
  final Hobby hobby;

  const ShareCard({super.key, required this.hobby});

  @override
  Widget build(BuildContext context) {
    return Material(
      // Material provides a render context for CachedNetworkImage off-screen.
      color: AppColors.background,
      child: SizedBox(
        width: 300,
        height: 420,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Background image ──────────────────────────────────────────
            if (hobby.imageUrl.isNotEmpty)
              Opacity(
                opacity: 0.52,
                child: CachedNetworkImage(
                  imageUrl: hobby.imageUrl,
                  fit: BoxFit.cover,
                  memCacheWidth: 900,
                ),
              )
            else
              // Fallback when imageUrl is empty.
              Container(color: AppColors.surfaceElevated),

            // ── Gradient overlay ──────────────────────────────────────────
            // Spec describes the gradient bottom-to-top:
            //   0% (bottom)  → 0.97 opacity
            //   55% from bottom (= 45% from top = stop 0.45) → 0.20 opacity
            //   100% (top)   → transparent
            // Flutter LinearGradient stops run top-to-bottom, hence 0.45.
            Positioned.fill(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.0, 0.45, 1.0],
                    colors: [
                      Colors.transparent,
                      Color(0x330A0A0F), // 20% opacity  (0x33 / 255 = 0.20)
                      Color(0xF70A0A0F), // 97% opacity  (0xF7 / 255 = 0.969)
                    ],
                  ),
                ),
              ),
            ),

            // ── App logo: top-right, no container ────────────────────────
            Positioned(
              top: 12,
              right: 14,
              child: Image.asset(
                'assets/images/app_logo.png',
                width: 42,
                height: 42,
              ),
            ),

            // ── Bottom content ────────────────────────────────────────────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Category label
                    Text(
                      hobby.category.toUpperCase(),
                      style: GoogleFonts.ibmPlexMono(
                        fontSize: 8,
                        fontWeight: FontWeight.w500,
                        color: AppColors.accent,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(height: 5),
                    // Hobby title
                    Text(
                      hobby.title,
                      style: GoogleFonts.sourceSerif4(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 7),
                    // Hook line
                    Text(
                      hobby.hook,
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Hairline divider (rgba 255,255,255,0.06 → 0x0F opacity)
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0x0FFFFFFF),
                    ),
                    const SizedBox(height: 9),
                    // Wordmark: "Try" coral + "Something" warm cream
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Try',
                            style: GoogleFonts.sourceSerif4(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.accent,
                            ),
                          ),
                          TextSpan(
                            text: 'Something',
                            style: GoogleFonts.sourceSerif4(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Verify no analysis errors**

```bash
dart analyze lib/components/share_card.dart
```

Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/components/share_card.dart
git commit -m "feat: add ShareCard widget and shareHobby pipeline"
```

---

## Chunk 2: Wiring

### Task 3: Wire into rail_feed_screen.dart

The TikTok-style vertical feed. `HobbyCard` already has an `onShare` field — this task just passes it.

**Files:**
- Modify: `lib/screens/feed/rail_feed_screen.dart:4` (import)
- Modify: `lib/screens/feed/rail_feed_screen.dart:126-134` (HobbyCard call)

- [ ] **Step 1: Add import**

At the top of `lib/screens/feed/rail_feed_screen.dart`, add this import after the existing `hobby_card.dart` import:

```dart
import '../../components/share_card.dart';
```

So the top of the import block looks like:

```dart
import '../../components/hobby_card.dart';
import '../../components/share_card.dart';
```

- [ ] **Step 2: Add onShare to the HobbyCard call**

Find the `HobbyCard(...)` call inside the `PageView.builder` `itemBuilder` (around line 126). It currently looks like:

```dart
return HobbyCard(
  hobby: hobby,
  isSaved: isSaved,
  compactCta: true,
  onTap: () => context.push('/hobby/${hobby.id}'),
  onSave: () => ref
      .read(userHobbiesProvider.notifier)
      .toggleSave(hobby.id),
);
```

Add one argument — `onShare`:

```dart
return HobbyCard(
  hobby: hobby,
  isSaved: isSaved,
  compactCta: true,
  onTap: () => context.push('/hobby/${hobby.id}'),
  onSave: () => ref
      .read(userHobbiesProvider.notifier)
      .toggleSave(hobby.id),
  onShare: () => shareHobby(context, hobby),
);
```

- [ ] **Step 3: Verify**

```bash
dart analyze lib/screens/feed/rail_feed_screen.dart
```

Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add lib/screens/feed/rail_feed_screen.dart
git commit -m "feat: wire shareHobby into rail feed HobbyCard"
```

---

### Task 4: Wire into hobby_detail_screen.dart

The detail screen has a share `GestureDetector` with an empty `onTap: () {}` at line 245.

**Files:**
- Modify: `lib/screens/detail/hobby_detail_screen.dart` (import + line 245)

- [ ] **Step 1: Add import**

Add this import at the top of `lib/screens/detail/hobby_detail_screen.dart`, after the existing component imports:

```dart
import '../../components/share_card.dart';
```

For example, after:

```dart
import '../../components/pro_upgrade_sheet.dart';
import '../../components/share_card.dart';  // ← add here
```

- [ ] **Step 2: Wire the share button**

Find the `GestureDetector` at approximately line 244 that has `onTap: () {}` and wraps the share icon. It looks like:

```dart
GestureDetector(
  onTap: () {},
  child: Container(
    width: 36,
    height: 36,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.black.withValues(alpha: 0.35),
    ),
    child:
        Icon(AppIcons.share, size: 18, color: Colors.white),
  ),
),
```

Replace `onTap: () {}` with:

```dart
GestureDetector(
  onTap: () => shareHobby(context, hobby),
  child: Container(
    width: 36,
    height: 36,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.black.withValues(alpha: 0.35),
    ),
    child:
        Icon(AppIcons.share, size: 18, color: Colors.white),
  ),
),
```

`hobby` is the local variable from `hobbyAsync.valueOrNull` at line 148, guaranteed non-null at this point due to the early return guard above.

- [ ] **Step 3: Verify**

```bash
dart analyze lib/screens/detail/hobby_detail_screen.dart
```

Expected: `No issues found!`

- [ ] **Step 4: Final full-project analysis**

```bash
flutter analyze
```

Expected: `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add lib/screens/detail/hobby_detail_screen.dart
git commit -m "feat: wire shareHobby into hobby detail screen share button"
```

---

## Manual Verification

After all tasks are done, run the app and verify:

1. Open the vertical feed (tap "Explore all →" on any Discover rail)
2. Tap the share icon on a hobby card → system share sheet opens with the cinematic poster image
3. Open any hobby detail screen → tap the share icon (top-right circle button) → system share sheet opens
4. Verify the share image shows: hobby hero photo, coral T logo top-right, category label, hobby title, hook, divider, TrySomething wordmark
5. Tap share twice rapidly → only one share sheet opens (re-entry guard working)
6. Verify cancelling the share sheet shows no error snackbar
