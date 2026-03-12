import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> loadFonts() async {
  // Prevent Google Fonts from making HTTP requests during tests.
  // Fonts that are bundled under assets/fonts/ will be found via
  // AssetManifest and loaded from the asset bundle instead.
  GoogleFonts.config.allowRuntimeFetching = false;
  await loadAppFonts();
}

Widget wrap(Widget child, {Size? surfaceSize}) => MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF0A0A0F),
        body: Center(child: child),
      ),
    );

Widget wrapProvider(Widget child) => ProviderScope(child: wrap(child));
