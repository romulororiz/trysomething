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
import 'core/analytics/analytics_service.dart';
import 'core/analytics/analytics_provider.dart';
import 'core/notifications/notification_provider.dart';

void main() async {
  // Global services (created before zone so they're accessible everywhere)
  final reporter = ErrorReporter();
  final analytics = AnalyticsService();

  // Run inside a guarded zone to catch uncaught async errors.
  // Binding must be initialized inside the same zone as runApp.
  runZonedGuarded(
    () async {
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

      runApp(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            errorReporterProvider.overrideWithValue(reporter),
            analyticsProvider.overrideWithValue(analytics),
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
      // Initialize push notifications (stub until Firebase configured)
      ref.read(notificationProvider).init();
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
//  Midnight Neon: drifting gradient blobs, glass logo,
//  staggered fade-slide-up, indigo→coral progress bar
// ═══════════════════════════════════════════════════════

class _SplashOverlay extends StatefulWidget {
  const _SplashOverlay();

  @override
  State<_SplashOverlay> createState() => _SplashOverlayState();
}

class _SplashOverlayState extends State<_SplashOverlay>
    with TickerProviderStateMixin {
  // Blob drift controllers (long, looping)
  late AnimationController _blobCoralCtrl;
  late AnimationController _blobIndigoCtrl;
  late AnimationController _blobSageCtrl;

  // Staggered fade-slide-up for title / tagline
  late AnimationController _titleCtrl;
  late AnimationController _taglineCtrl;

  // One-shot progress bar (fills 0→100% then stays)
  late AnimationController _progressCtrl;

  @override
  void initState() {
    super.initState();

    // ── Blob drift (matches CSS: 15s / 18s-reverse / 20s) ──
    _blobCoralCtrl = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();
    _blobIndigoCtrl = AnimationController(
      duration: const Duration(seconds: 18),
      vsync: this,
    )..repeat(reverse: true);
    _blobSageCtrl = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    // ── Staggered fade-slide-up (1.2s each, cubic) ──
    _titleCtrl = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _taglineCtrl = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Stagger: title @ 500ms, tagline @ 800ms
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _titleCtrl.forward();
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _taglineCtrl.forward();
    });

    // ── Progress bar: 0→100% in 3.5s, one shot ──
    _progressCtrl = AnimationController(
      duration: const Duration(milliseconds: 3500),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _blobCoralCtrl.dispose();
    _blobIndigoCtrl.dispose();
    _blobSageCtrl.dispose();
    _titleCtrl.dispose();
    _taglineCtrl.dispose();
    _progressCtrl.dispose();
    super.dispose();
  }

  // CSS cubic-bezier(0.22, 1, 0.36, 1) ≈ easeOutExpo
  static const _fadeSlideUpCurve = Cubic(0.22, 1.0, 0.36, 1.0);

  Widget _fadeSlideUp({
    required AnimationController controller,
    required Widget child,
  }) {
    final curved = CurvedAnimation(
      parent: controller,
      curve: _fadeSlideUpCurve,
    );
    return AnimatedBuilder(
      animation: curved,
      builder: (_, __) {
        return Opacity(
          opacity: curved.value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - curved.value)),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: const TextStyle(decoration: TextDecoration.none),
      child: Container(
      color: AppColors.cream,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── Drifting gradient blobs ──
          _DriftingBlobs(
            coralCtrl: _blobCoralCtrl,
            indigoCtrl: _blobIndigoCtrl,
            sageCtrl: _blobSageCtrl,
          ),

          // ── Centered brand section ──
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 96),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // App name: "Try" in coral, "Something" in white
                  _fadeSlideUp(
                    controller: _titleCtrl,
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Try',
                            style: AppTypography.serifDisplay.copyWith(
                              fontSize: 38,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                              color: AppColors.coral,
                            ),
                          ),
                          TextSpan(
                            text: 'Something',
                            style: AppTypography.serifDisplay.copyWith(
                              fontSize: 38,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Tagline: "Stop scrolling." white, "Start something." coral
                  _fadeSlideUp(
                    controller: _taglineCtrl,
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Stop scrolling. ',
                            style: AppTypography.sansCaption.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.70),
                              letterSpacing: 1.2,
                            ),
                          ),
                          TextSpan(
                            text: 'Start something.',
                            style: AppTypography.sansCaption.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: AppColors.coral,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom progress bar ──
          Positioned(
            left: 0,
            right: 0,
            bottom: 64,
            child: Center(
              child: SizedBox(
                width: 240,
                height: 3,
                child: AnimatedBuilder(
                  animation: _progressCtrl,
                  builder: (_, __) {
                    final progress = Curves.easeInOut.transform(
                      _progressCtrl.value,
                    );
                    return CustomPaint(
                      painter: _ProgressBarPainter(progress),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  DRIFTING BLOBS — three color orbs that float around
//  Matches the HTML: coral top-left, indigo bottom-right,
//  sage center — each with distinct drift period
// ═══════════════════════════════════════════════════════

class _DriftingBlobs extends StatelessWidget {
  final AnimationController coralCtrl;
  final AnimationController indigoCtrl;
  final AnimationController sageCtrl;

  const _DriftingBlobs({
    required this.coralCtrl,
    required this.indigoCtrl,
    required this.sageCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([coralCtrl, indigoCtrl, sageCtrl]),
      builder: (_, __) => CustomPaint(
        painter: _BlobPainter(
          coralT: coralCtrl.value,
          indigoT: indigoCtrl.value,
          sageT: sageCtrl.value,
        ),
      ),
    );
  }
}

class _BlobPainter extends CustomPainter {
  final double coralT;
  final double indigoT;
  final double sageT;

  _BlobPainter({
    required this.coralT,
    required this.indigoT,
    required this.sageT,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Coral blob: top-1/4 left side, w-80 h-80 → ~320px radius blur
    _drawBlob(
      canvas,
      Offset(
        -80 + 30 * _driftX(coralT),
        h * 0.25 - 50 * _driftY(coralT),
      ),
      w * 0.8,
      AppColors.coral.withValues(alpha: 0.20),
    );

    // Indigo blob: bottom-1/4 right side, w-96 → ~384px radius blur
    _drawBlob(
      canvas,
      Offset(
        w + 80 + 30 * _driftX(indigoT),
        h * 0.75 - 50 * _driftY(indigoT),
      ),
      w * 0.96,
      AppColors.indigo.withValues(alpha: 0.20),
    );

    // Sage blob: center, w-64 → ~256px radius blur
    _drawBlob(
      canvas,
      Offset(
        w * 0.5 - 20 * _driftX(sageT),
        h * 0.5 + 20 * _driftY(sageT),
      ),
      w * 0.64,
      AppColors.sage.withValues(alpha: 0.10),
    );
  }

  // Emulates the CSS drift keyframes:
  // 0%: (0, 0) scale(1), 33%: (30, -50) scale(1.1), 66%: (-20, 20) scale(0.9)
  double _driftX(double t) {
    final cycle = t * math.pi * 2;
    return math.sin(cycle) + 0.3 * math.sin(cycle * 2);
  }

  double _driftY(double t) {
    final cycle = t * math.pi * 2;
    return math.cos(cycle) + 0.4 * math.cos(cycle * 1.5);
  }

  void _drawBlob(Canvas canvas, Offset center, double radius, Color color) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [color, color.withValues(alpha: 0)],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(_BlobPainter old) =>
      coralT != old.coralT ||
      indigoT != old.indigoT ||
      sageT != old.sageT;
}

// ═══════════════════════════════════════════════════════
//  PROGRESS BAR — indigo→coral gradient, fills 0→100%
// ═══════════════════════════════════════════════════════

class _ProgressBarPainter extends CustomPainter {
  final double progress; // 0.0 → 1.0

  _ProgressBarPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final radius = Radius.circular(h / 2);

    // Track: white 10% opacity
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, h), radius),
      Paint()..color = Colors.white.withValues(alpha: 0.10),
    );

    // Fill: indigo → coral gradient
    final fillWidth = w * progress;
    if (fillWidth > 0) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, fillWidth, h),
          radius,
        ),
        Paint()
          ..shader = const LinearGradient(
            colors: [AppColors.indigo, AppColors.coral],
          ).createShader(Rect.fromLTWH(0, 0, w, h)),
      );
    }
  }

  @override
  bool shouldRepaint(_ProgressBarPainter old) => progress != old.progress;
}
