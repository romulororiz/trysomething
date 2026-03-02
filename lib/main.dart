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
import 'providers/feature_providers.dart';
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
    // Attempt to restore auth session from stored tokens, then sync hobbies
    Future.microtask(() async {
      await ref.read(authProvider.notifier).tryRestoreSession();
      if (ref.read(authProvider).status == AuthStatus.authenticated) {
        ref.read(userHobbiesProvider.notifier).syncFromServer();
        ref.read(journalProvider.notifier).loadFromServer();
        ref.read(scheduleProvider.notifier).loadFromServer();
      }
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

class _SplashOverlay extends StatefulWidget {
  const _SplashOverlay();

  @override
  State<_SplashOverlay> createState() => _SplashOverlayState();
}

class _SplashOverlayState extends State<_SplashOverlay>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _glowController;
  late AnimationController _dotController;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2400),
      vsync: this,
    )..repeat(reverse: true);
    _dotController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
    _fadeIn = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _glowController.dispose();
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeIn,
      child: Container(
        color: AppColors.cream,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background glow — indigo top-right
            Positioned(
              top: -100,
              right: -80,
              child: AnimatedBuilder(
                animation: _glowController,
                builder: (_, __) => Opacity(
                  opacity: 0.08 + _glowController.value * 0.12,
                  child: Container(
                    width: 360,
                    height: 360,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.indigo,
                          AppColors.indigo.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Background glow — coral bottom-left
            Positioned(
              bottom: -80,
              left: -80,
              child: AnimatedBuilder(
                animation: _glowController,
                builder: (_, __) => Opacity(
                  opacity: 0.06 + (1 - _glowController.value) * 0.10,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.coral,
                          AppColors.coral.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Background glow — sage accent mid-right
            Positioned(
              top: 300,
              right: -60,
              child: AnimatedBuilder(
                animation: _glowController,
                builder: (_, __) => Opacity(
                  opacity: 0.03 + _glowController.value * 0.06,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.sage,
                          AppColors.sage.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Center content
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo with alternating indigo ↔ coral glow
                  AnimatedBuilder(
                    animation: _glowController,
                    builder: (_, child) => Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.indigo.withValues(
                              alpha: 0.20 + _glowController.value * 0.40,
                            ),
                            blurRadius: 32 + _glowController.value * 20,
                            spreadRadius: 4,
                          ),
                          BoxShadow(
                            color: AppColors.coral.withValues(
                              alpha: (1 - _glowController.value) * 0.25,
                            ),
                            blurRadius: 28,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: child,
                    ),
                    child: Container(
                      width: 92,
                      height: 92,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.indigo, AppColors.coral],
                        ),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: const Center(
                        child: Text(
                          'T',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -1.5,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  Text(
                    'TrySomething',
                    style: AppTypography.serifTitle.copyWith(
                      color: AppColors.nearBlack,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Discover what you love.',
                    style: AppTypography.sansBodySmall.copyWith(
                      color: AppColors.warmGray,
                      fontStyle: FontStyle.italic,
                    ),
                  ),

                  const SizedBox(height: 56),

                  // Sequentially pulsing coral dots
                  AnimatedBuilder(
                    animation: _dotController,
                    builder: (_, __) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(3, (i) {
                          final t = (_dotController.value + i / 3) % 1.0;
                          final wave = t < 0.5 ? t * 2 : (1 - t) * 2;
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color.lerp(
                                AppColors.warmGray.withValues(alpha: 0.25),
                                AppColors.coral,
                                wave,
                              ),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
