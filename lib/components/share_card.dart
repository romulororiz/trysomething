import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
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
  // Capture overlay and ScaffoldMessenger before any async gaps to avoid
  // using BuildContext across async boundaries.
  // NOTE: Use Overlay.maybeOf (nullable) not Overlay.of — in Flutter 3.6,
  // Overlay.of() is non-nullable and asserts rather than returning null.
  // maybeOf is the correct API for a safe null check.
  final overlay = Overlay.maybeOf(context);
  final messenger = ScaffoldMessenger.maybeOf(context);
  try {
    if (overlay == null) throw Exception('No Overlay found in context');

    // 1. Precache the hobby image so it renders synchronously inside the card.
    if (hobby.imageUrl.isNotEmpty) {
      await precacheImage(
        CachedNetworkImageProvider(hobby.imageUrl),
        context,
      );
    }

    // 2. Insert ShareCard off-screen inside an OverlayEntry.
    // GlobalKey's type parameter must be State<StatefulWidget>, not a
    // RenderObject — use an untyped GlobalKey and cast when accessing.
    final boundaryKey = GlobalKey();

    entry = OverlayEntry(
      builder: (_) => Positioned(
        // Off-screen but still painted — Offstage suppresses painting and
        // breaks RenderRepaintBoundary.toImage() (layer is never populated).
        left: -10000,
        top: 0,
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

    // 6. Share directly from memory — XFile.fromData works on all platforms
    // including web (no file system / path_provider required).
    await Share.shareXFiles(
      [
        XFile.fromData(
          byteData.buffer.asUint8List(),
          name: 'share_${DateTime.now().millisecondsSinceEpoch}.png',
          mimeType: 'image/png',
        )
      ],
      text: "I'm trying ${hobby.title} on TrySomething",
    );
  } catch (e, st) {
    // share_plus does NOT throw on user cancellation — only real errors land here.
    debugPrint('[shareHobby] ERROR: $e');
    debugPrint('[shareHobby] STACK: $st');
    messenger?.showSnackBar(
      const SnackBar(content: Text("Couldn't create share card")),
    );
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
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
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
