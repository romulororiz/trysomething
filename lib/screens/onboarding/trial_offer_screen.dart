import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/spacing.dart';

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

  static const _proFeatures = [
    _ProFeature(
      icon: Icons.auto_awesome,
      color: AppColors.accent,
      title: 'AI Hobby Coach',
      subtitle: 'Personal guidance for every step of your journey',
    ),
    _ProFeature(
      icon: Icons.camera_alt_outlined,
      color: AppColors.success,
      title: 'Photo Journal',
      subtitle: 'Capture your progress with photos and notes',
    ),
    _ProFeature(
      icon: Icons.shuffle_rounded,
      color: AppColors.textSecondary,
      title: '"Surprise Me" Generator',
      subtitle: 'AI-powered hobby suggestions tailored to you',
    ),
    _ProFeature(
      icon: Icons.insights_outlined,
      color: AppColors.textMuted,
      title: 'Advanced Stats',
      subtitle: 'Skill radar, activity heatmap, and deep insights',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut),
        child: Stack(
          children: [
            // Background glow
            Positioned(
              top: -100,
              right: -80,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.coral.withValues(alpha: 0.12),
                      AppColors.coral.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -50,
              left: -60,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.textMuted.withValues(alpha: 0.1),
                      AppColors.textMuted.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),

            // Content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    SizedBox(height: topPad > 40 ? 16 : 32),

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
                          Icon(MdiIcons.starFourPoints, size: 14, color: AppColors.coral),
                          const SizedBox(width: 6),
                          Text('LIMITED OFFER', style: AppTypography.monoBadge.copyWith(
                            color: AppColors.coral, fontSize: 10, letterSpacing: 1.2,
                          )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Heading
                    Text(
                      'Unlock the full\nexperience',
                      style: AppTypography.hero.copyWith(fontSize: 32),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Get the most out of your hobby journey\nwith TrySomething Pro.',
                      style: AppTypography.sansCaption.copyWith(
                        color: AppColors.textSecondary, height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Feature list
                    Expanded(
                      child: ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: _proFeatures.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, i) => _buildFeatureCard(_proFeatures[i]),
                      ),
                    ),

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
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(_ProFeature feature) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(Spacing.radiusTile),
        border: Border.all(color: AppColors.border),
      ),
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
        ref.read(proStatusProvider.notifier).sync();
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
