import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
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
import 'core/error/error_reporter.dart';
import 'core/error/error_provider.dart';

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

  // Global error reporter
  final reporter = ErrorReporter();

  // Capture Flutter framework errors
  FlutterError.onError = (details) {
    reporter.reportError(
      details.exception,
      details.stack,
      context: details.context?.toString(),
    );
  };

  // Capture platform-level errors (e.g. native crashes surfaced to Dart)
  PlatformDispatcher.instance.onError = (error, stack) {
    reporter.reportError(error, stack, context: 'PlatformDispatcher');
    return true;
  };

  // Run inside a guarded zone to catch uncaught async errors
  runZonedGuarded(
    () {
      runApp(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            errorReporterProvider.overrideWithValue(reporter),
          ],
          observers: [ErrorReporterObserver(reporter)],
          child: const TrySomethingApp(),
        ),
      );
    },
    (error, stack) {
      reporter.reportError(error, stack, context: 'runZonedGuarded');
    },
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
      final authState = ref.read(authProvider);
      if (authState.status == AuthStatus.authenticated) {
        if (authState.user != null) {
          ref.read(profileProvider.notifier).initFromAuth(authState.user!);
        }
        ref.read(userHobbiesProvider.notifier).syncFromServer();
        ref.read(journalProvider.notifier).loadFromServer();
        ref.read(scheduleProvider.notifier).loadFromServer();
        ref.read(storiesProvider.notifier).loadFromServer();
        ref.read(buddyProvider.notifier).loadFromServer();
        ref.read(challengeProvider.notifier).loadFromServer();
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
//  Refined Midnight Neon: gradient mesh + coral logo +
//  progress sweep + floating particles
// ═══════════════════════════════════════════════════════

class _SplashOverlay extends StatefulWidget {
  const _SplashOverlay();

  @override
  State<_SplashOverlay> createState() => _SplashOverlayState();
}

class _SplashOverlayState extends State<_SplashOverlay>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _meshController;
  late AnimationController _progressController;
  late AnimationController _particleController;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
    _meshController = AnimationController(
      duration: const Duration(milliseconds: 6000),
      vsync: this,
    )..repeat(reverse: true);
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat();
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    )..repeat();
    _fadeIn = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _meshController.dispose();
    _progressController.dispose();
    _particleController.dispose();
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
            // Animated gradient mesh background
            AnimatedBuilder(
              animation: _meshController,
              builder: (_, __) => CustomPaint(
                painter: _GradientMeshPainter(_meshController.value),
              ),
            ),

            // Floating particles
            AnimatedBuilder(
              animation: _particleController,
              builder: (_, __) => CustomPaint(
                painter: _ParticlePainter(_particleController.value),
              ),
            ),

            // Center content
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo — 80x80 coral gradient rounded square
                  AnimatedBuilder(
                    animation: _meshController,
                    builder: (_, child) => Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.coral.withValues(
                              alpha: 0.25 + _meshController.value * 0.15,
                            ),
                            blurRadius: 40,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: child,
                    ),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.coral, AppColors.coralDeep],
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Center(
                        child: Text(
                          'T',
                          style: AppTypography.serifTitle.copyWith(
                            fontSize: 42,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -1,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

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
                      color: AppColors.driftwood,
                      fontStyle: FontStyle.italic,
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Thin coral progress sweep line
                  SizedBox(
                    width: 120,
                    height: 2,
                    child: AnimatedBuilder(
                      animation: _progressController,
                      builder: (_, __) => CustomPaint(
                        painter: _ProgressSweepPainter(
                          _progressController.value,
                        ),
                      ),
                    ),
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

/// Paints soft gradient orbs that drift slowly across the background.
class _GradientMeshPainter extends CustomPainter {
  final double t;
  _GradientMeshPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Indigo orb — drifts from top-right
    _drawOrb(
      canvas,
      Offset(w * (0.75 + 0.08 * _sin(t)), h * (0.15 + 0.06 * _cos(t))),
      w * 0.5,
      AppColors.indigo.withValues(alpha: 0.07 + 0.04 * _sin(t)),
    );

    // Coral orb — drifts from bottom-left
    _drawOrb(
      canvas,
      Offset(w * (0.2 - 0.06 * _cos(t)), h * (0.78 + 0.05 * _sin(t))),
      w * 0.45,
      AppColors.coral.withValues(alpha: 0.06 + 0.03 * _cos(t)),
    );

    // Sage orb — drifts mid-right
    _drawOrb(
      canvas,
      Offset(w * (0.85 + 0.05 * _sin(t * 0.7)), h * (0.48 - 0.04 * _cos(t))),
      w * 0.3,
      AppColors.sage.withValues(alpha: 0.04 + 0.02 * _sin(t * 1.3)),
    );
  }

  void _drawOrb(Canvas canvas, Offset center, double radius, Color color) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [color, color.withValues(alpha: 0)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);
  }

  double _sin(double t) => math.sin(t * math.pi * 2);
  double _cos(double t) => math.cos(t * math.pi * 2);

  @override
  bool shouldRepaint(_GradientMeshPainter old) => old.t != t;
}

/// Paints subtle floating sparkle particles.
class _ParticlePainter extends CustomPainter {
  final double t;
  _ParticlePainter(this.t);

  // 8 particles with fixed seed positions
  static const _seeds = [
    [0.15, 0.25, 0.0],
    [0.82, 0.18, 0.12],
    [0.35, 0.72, 0.25],
    [0.68, 0.55, 0.37],
    [0.9, 0.82, 0.50],
    [0.22, 0.45, 0.62],
    [0.55, 0.12, 0.75],
    [0.78, 0.38, 0.87],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (final seed in _seeds) {
      final phase = (t + seed[2]) % 1.0;
      // Each particle fades in-out over its cycle
      final fade = phase < 0.5 ? phase * 2 : (1 - phase) * 2;
      final alpha = fade * 0.35;
      if (alpha < 0.01) continue;

      final x = size.width * (seed[0] + 0.02 * _sin(phase + seed[2]));
      final y = size.height * (seed[1] - 0.03 * phase); // drift upward
      final radius = 1.2 + fade * 1.0;

      canvas.drawCircle(
        Offset(x, y),
        radius,
        Paint()..color = AppColors.coral.withValues(alpha: alpha),
      );
    }
  }

  double _sin(double t) => math.sin(t * math.pi * 2);

  @override
  bool shouldRepaint(_ParticlePainter old) => old.t != t;
}

/// Paints a thin coral progress line that sweeps left-to-right.
class _ProgressSweepPainter extends CustomPainter {
  final double t;
  _ProgressSweepPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background track
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, w, h),
        const Radius.circular(1),
      ),
      Paint()..color = AppColors.sandDark,
    );

    // Sweep highlight — 30% width, slides across
    final sweepWidth = w * 0.3;
    final sweepStart = -sweepWidth + (w + sweepWidth) * t;
    final rect = Rect.fromLTWH(
      sweepStart.clamp(0.0, w),
      0,
      (sweepStart + sweepWidth).clamp(0.0, w) - sweepStart.clamp(0.0, w),
      h,
    );

    if (rect.width > 0) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(1)),
        Paint()
          ..shader = const LinearGradient(
            colors: [
              Color(0x00FF6B6B),
              AppColors.coral,
              Color(0x00FF6B6B),
            ],
          ).createShader(Rect.fromLTWH(sweepStart, 0, sweepWidth, h)),
      );
    }
  }

  @override
  bool shouldRepaint(_ProgressSweepPainter old) => old.t != t;
}
