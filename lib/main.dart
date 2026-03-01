import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';
import 'theme/app_typography.dart';
import 'router.dart';
import 'providers/user_provider.dart';
import 'providers/auth_provider.dart';
import 'core/storage/local_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // System UI style — match Midnight Neon dark theme
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF141420), // warmWhite (dark)
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // Initialize local storage
  await LocalStorage.init();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const TrySomethingApp(),
    ),
  );
}

class TrySomethingApp extends ConsumerStatefulWidget {
  const TrySomethingApp({super.key});

  @override
  ConsumerState<TrySomethingApp> createState() => _TrySomethingAppState();
}

class _TrySomethingAppState extends ConsumerState<TrySomethingApp> {
  @override
  void initState() {
    super.initState();
    // Attempt to restore auth session from stored tokens
    Future.microtask(() {
      ref.read(authProvider.notifier).tryRestoreSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final authStatus = ref.watch(authProvider).status;

    return MaterialApp.router(
      title: 'TrySomething',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: router,
      builder: (context, child) {
        return Stack(
          children: [
            child!,
            // Splash overlay while session is being restored
            if (authStatus == AuthStatus.unknown)
              const _SplashOverlay(),
          ],
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════
//  SPLASH OVERLAY — shown during session restore
// ═══════════════════════════════════════════════════════

class _SplashOverlay extends StatelessWidget {
  const _SplashOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.cream,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Brand logo — same as auth screens
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.indigo, AppColors.coral],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Center(
                child: Text(
                  'T',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'TrySomething',
              style: AppTypography.serifHeading.copyWith(
                color: AppColors.nearBlack,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.coral.withAlpha(180),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
