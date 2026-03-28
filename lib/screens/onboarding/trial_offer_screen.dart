import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/spacing.dart';
import '../../components/glass_card.dart';
import '../../components/app_background.dart';

/// One-time trial offer screen shown after onboarding, before first feed view.
class TrialOfferScreen extends ConsumerStatefulWidget {
  const TrialOfferScreen({super.key});

  @override
  ConsumerState<TrialOfferScreen> createState() => _TrialOfferScreenState();
}

class _TrialOfferScreenState extends ConsumerState<TrialOfferScreen>
    with SingleTickerProviderStateMixin {
  bool _purchasing = false;
  late final AnimationController _fadeCtrl;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  static const _benefits = [
    _ProFeature(
      icon: Icons.route_outlined,
      color: AppColors.coral,
      title: 'Know the next right step',
      subtitle: 'Your coach tells you exactly what to do next — no overthinking, no guessing.',
    ),
    _ProFeature(
      icon: Icons.auto_awesome,
      color: AppColors.coral,
      title: 'Get unstuck fast',
      subtitle: 'Lost motivation? Skipped a few days? Your coach helps you restart in 10 minutes.',
    ),
    _ProFeature(
      icon: Icons.camera_alt_outlined,
      color: AppColors.coral,
      title: 'Track real progress',
      subtitle: 'Photo journal and reflections that show how far you\'ve come.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut),
        child: AppBackground(
          child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const Spacer(flex: 3),

                    // Sparkle badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.coral.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(Spacing.radiusBadge),
                        border: Border.all(color: AppColors.coral.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.auto_awesome, size: 14, color: AppColors.coral),
                          const SizedBox(width: 6),
                          Text('LIMITED OFFER', style: AppTypography.monoBadge.copyWith(
                            color: AppColors.coral, fontSize: 10, letterSpacing: 1.2,
                          )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Brand wordmark
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Try',
                            style: AppTypography.hero.copyWith(
                              fontSize: 20,
                              color: AppColors.coral,
                            ),
                          ),
                          TextSpan(
                            text: 'Something ',
                            style: AppTypography.hero.copyWith(
                              fontSize: 20,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          TextSpan(
                            text: 'Pro',
                            style: AppTypography.hero.copyWith(
                              fontSize: 20,
                              color: AppColors.textPrimary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Heading
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Start',
                            style: AppTypography.hero.copyWith(
                              fontSize: 32,
                              color: AppColors.coral,
                            ),
                          ),
                          TextSpan(
                            text: ' hobbies you\n',
                            style: AppTypography.hero.copyWith(fontSize: 32),
                          ),
                          TextSpan(
                            text: 'actually stick with',
                            style: AppTypography.hero.copyWith(
                              fontSize: 32,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    // Wave underline beneath "actually stick with"
                    AnimatedBuilder(
                      animation: _fadeCtrl,
                      builder: (_, __) => SizedBox(
                        width: 220,
                        height: 8,
                        child: CustomPaint(
                          painter: _WaveUnderlinePainter(
                            progress: _fadeCtrl.value,
                            color: AppColors.coral.withAlpha(160),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Get step-by-step support for your first 30 days,\nplus tools to keep momentum when it drops.',
                      style: AppTypography.sansCaption.copyWith(
                        color: AppColors.textSecondary, height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 36),

                    // Benefit blocks
                    ..._benefits.expand((b) => [
                      _buildFeatureCard(b),
                      const SizedBox(height: 12),
                    ]),

                    const Spacer(flex: 3),

                    // CTA
                    GestureDetector(
                      onTap: _purchasing ? null : _handleStartTrial,
                      child: Container(
                        width: double.infinity,
                        height: Spacing.buttonCtaHeight,
                        decoration: BoxDecoration(
                          color: AppColors.coral,
                          borderRadius: BorderRadius.circular(Spacing.radiusCta),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.coral.withValues(alpha: 0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Center(
                          child: _purchasing
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Text(
                                  'Start 7-day free trial',
                                  style: AppTypography.sansLabel.copyWith(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Skip link
                    GestureDetector(
                      onTap: _handleSkip,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Maybe later',
                          style: AppTypography.sansCaption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: bottomPad + 8),
                  ],
                ),
              ),
            ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(_ProFeature feature) {
    return GlassCard(
      blur: false,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: feature.color.withValues(alpha: 0.12),
            ),
            child: Icon(feature.icon, size: 22, color: feature.color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(feature.title, style: AppTypography.sansLabel),
                const SizedBox(height: 2),
                Text(
                  feature.subtitle,
                  style: AppTypography.sansTiny.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleStartTrial() async {
    setState(() => _purchasing = true);

    final service = ref.read(subscriptionProvider);
    final offerings = await service.getOfferings();
    final package = offerings?.current?.annual;

    if (package != null) {
      final success = await service.purchase(package);
      if (success) {
        // Use refresh() to fetch latest from RevenueCat server, not just local sync.
        // This ensures the client has verified subscription state before proceeding.
        await ref.read(proStatusProvider.notifier).refresh();
      }
    }

    await _markShownAndNavigate();
  }

  Future<void> _handleSkip() async {
    await _markShownAndNavigate();
  }

  Future<void> _markShownAndNavigate() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool('trialOfferShown', true);
    if (mounted) context.go('/home');
  }
}

class _ProFeature {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _ProFeature({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });
}

class _WaveUnderlinePainter extends CustomPainter {
  final double progress;
  final Color color;

  _WaveUnderlinePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final w = size.width;
    final h = size.height / 2;
    final path = Path()
      ..moveTo(0, h)
      ..quadraticBezierTo(w * 0.18, h - 3, w * 0.35, h + 0.5)
      ..quadraticBezierTo(w * 0.52, h + 3.5, w * 0.68, h - 1)
      ..quadraticBezierTo(w * 0.84, h - 3.5, w, h + 1);

    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;

    final drawn =
        metrics.first.extractPath(0, metrics.first.length * progress);
    canvas.drawPath(
      drawn,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_WaveUnderlinePainter old) =>
      old.progress != progress;
}
