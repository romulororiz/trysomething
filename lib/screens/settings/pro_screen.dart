import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/subscription_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/spacing.dart';
import '../../components/glass_card.dart';
import '../../components/app_overlays.dart';
import '../../components/app_background.dart';

/// TrySomething Pro — premium upgrade screen.
///
/// Design: stacked plan cards (all visible, no carousel) with the
/// recommended plan visually elevated. Based on highest-converting
/// paywall patterns from Superwall/Adapty research.
class ProScreen extends ConsumerStatefulWidget {
  const ProScreen({super.key});

  @override
  ConsumerState<ProScreen> createState() => _ProScreenState();
}

class _ProScreenState extends ConsumerState<ProScreen> {
  int _selectedPlan = 1; // 0=monthly, 1=annual, 2=lifetime
  bool _purchasing = false;

  static const _benefits = [
    _ProFeature(
      icon: Icons.route_outlined,
      title: 'Know the next right step',
      subtitle:
          'Your coach tells you exactly what to do next — no overthinking.',
    ),
    _ProFeature(
      icon: Icons.auto_awesome,
      title: 'Get unstuck fast',
      subtitle:
          'Skipped a few days? Your coach helps you restart in 10 minutes.',
    ),
    _ProFeature(
      icon: Icons.camera_alt_outlined,
      title: 'Track real progress',
      subtitle: 'Photo journal and reflections that show how far you\'ve come.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(proStatusProvider);
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppBackground(
        child: Stack(
            children: [
              // Scrollable content
              SafeArea(
                child: Column(
                  children: [
                    // Back button
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16, top: 8),
                        child: GestureDetector(
                          onTap: () => context.pop(),
                          child: const SizedBox(
                            width: 40,
                            height: 40,
                            child: Icon(Icons.arrow_back,
                                size: 20, color: AppColors.textSecondary),
                          ),
                        ),
                      ),
                    ),

                    // Debug tier toggle (debug mode + web only)
                    // if (kDebugMode && kIsWeb)
                    //   _buildDebugTierBar(),

                    // Scrollable body
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.only(bottom: bottomPad + 120),
                        child: Column(
                          children: [
                            const SizedBox(height: 8),

                            // Brand wordmark
                            RichText(
                              text: TextSpan(children: [
                                TextSpan(
                                  text: 'Try',
                                  style: AppTypography.hero.copyWith(
                                      fontSize: 30, color: AppColors.coral),
                                ),
                                TextSpan(
                                  text: 'Something ',
                                  style: AppTypography.hero.copyWith(
                                      fontSize: 30,
                                      color: AppColors.textPrimary),
                                ),
                                TextSpan(
                                  text: 'Pro',
                                  style: AppTypography.hero.copyWith(
                                    fontSize: 30,
                                    color: AppColors.textPrimary,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ]),
                            ),
                            const SizedBox(height: 16),

                            // Heading with laurel badge
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Unlock',
                                          style: AppTypography.hero.copyWith(
                                            fontSize: 24,
                                            color: AppColors.coral,
                                          ),
                                        ),
                                        TextSpan(
                                          text: ' the full\nexperience',
                                          style: AppTypography.hero
                                              .copyWith(fontSize: 24),
                                        ),
                                      ],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SvgPicture.asset(
                                  'assets/icon/pro_badge.svg',
                                  width: 64,
                                  height: 64,
                                ),
                              ],
                            ),
                            const SizedBox(height: 36),

                            // Benefit cards
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24),
                              child: Column(
                                children: _benefits
                                    .map((b) => Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 12),
                                          child: _buildFeatureCard(b),
                                        ))
                                    .toList(),
                              ),
                            ),
                            const SizedBox(height: 28),

                            // ── Plan selector ──
                            if (!status.isPro) ...[
                              Text(
                                'Choose your plan',
                                style: AppTypography.sansLabel
                                    .copyWith(color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 16),

                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 24),
                                child: Column(
                                  children: [
                                    _buildPlanTile(
                                      index: 1,
                                      label: 'Annual',
                                      price: 'CHF 39.99',
                                      period: '/year',
                                      perMonthPrice: 'CHF 3.33/mo',
                                      savingsPercent: 33,
                                      badge: 'MOST POPULAR',
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildCompactPlanTile(
                                            index: 0,
                                            label: 'Monthly',
                                            price: 'CHF 4.99',
                                            period: '/month',
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: _buildCompactPlanTile(
                                            index: 2,
                                            label: 'Lifetime',
                                            price: 'CHF 99.99',
                                            period: 'one-time',
                                            badge: 'BEST VALUE',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 24),

                              GestureDetector(
                                onTap: _handleRestore,
                                child: Text(
                                  'Restore purchase',
                                  style: AppTypography.sansCaption.copyWith(
                                    color: AppColors.textSecondary,
                                    decoration: TextDecoration.underline,
                                    decorationColor: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Subscriptions are managed by your app store.',
                                style: AppTypography.sansTiny
                                    .copyWith(color: AppColors.textMuted),
                              ),
                            ],

                            // Already Pro
                            if (status.isPro) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.sage.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Text(
                                  _statusText(status),
                                  style: AppTypography.monoBadge
                                      .copyWith(color: AppColors.sage),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Floating CTA — positioned over the gradient
              if (!status.isPro)
                Positioned(
                  left: 24,
                  right: 24,
                  bottom: bottomPad + 16,
                  child: GestureDetector(
                    onTap: _purchasing ? null : _handlePurchase,
                    child: Container(
                      width: double.infinity,
                      height: Spacing.buttonCtaHeight,
                      decoration: BoxDecoration(
                        color: AppColors.coral,
                        borderRadius:
                            BorderRadius.circular(Spacing.radiusCta),
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
                                _ctaLabel,
                                style: AppTypography.sansLabel.copyWith(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
    );
  }


  // ═══════════════════════════════════════════════════════
  //  FEATURED PLAN TILE (Annual — full width, elevated)
  // ═══════════════════════════════════════════════════════

  Widget _buildPlanTile({
    required int index,
    required String label,
    required String price,
    required String period,
    String? perMonthPrice,
    int savingsPercent = 0,
    String? badge,
  }) {
    final selected = _selectedPlan == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.coral.withValues(alpha: 0.06)
              : AppColors.glassBackground,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? AppColors.coral : AppColors.glassBorder,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? AppColors.coral.withValues(alpha: 0.12)
                  : Colors.transparent,
              blurRadius: 24,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Badge row
            if (badge != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.coral.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    badge,
                    style: AppTypography.monoBadge.copyWith(
                      color: AppColors.coral,
                      fontSize: 9,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),

            // Main content row
            Row(
              children: [
                // Radio indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeInOut,
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? AppColors.coral : AppColors.textWhisper,
                      width: 1.5,
                    ),
                  ),
                  child: selected
                      ? Center(
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.coral,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 14),

                // Plan info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: AppTypography.sansLabel.copyWith(
                          color: selected
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (perMonthPrice != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          perMonthPrice,
                          style: AppTypography.sansTiny
                              .copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ],
                  ),
                ),

                // Price + savings
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      price,
                      style: AppTypography.title.copyWith(
                        fontSize: 18,
                        color: selected
                            ? AppColors.coral
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          period,
                          style: AppTypography.sansTiny
                              .copyWith(color: AppColors.textMuted),
                        ),
                        if (savingsPercent > 0) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.sage.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '-$savingsPercent%',
                              style: AppTypography.monoBadge.copyWith(
                                color: AppColors.sage,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  //  COMPACT PLAN TILE (Monthly / Lifetime — half width)
  // ═══════════════════════════════════════════════════════

  Widget _buildCompactPlanTile({
    required int index,
    required String label,
    required String price,
    required String period,
    String? badge,
  }) {
    final selected = _selectedPlan == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.coral.withValues(alpha: 0.06)
              : AppColors.glassBackground,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? AppColors.coral : AppColors.glassBorder,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? AppColors.coral.withValues(alpha: 0.12)
                  : Colors.transparent,
              blurRadius: 24,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Badge
            if (badge != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.sage.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    badge,
                    style: AppTypography.monoBadge.copyWith(
                      color: AppColors.sage,
                      fontSize: 8,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              )
            else
              const SizedBox(height: 19),

            // Radio
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeInOut,
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.coral : AppColors.textWhisper,
                  width: 1.5,
                ),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.coral,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 10),

            // Label
            Text(
              label,
              style: AppTypography.sansLabel.copyWith(
                color:
                    selected ? AppColors.textPrimary : AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),

            // Price
            Text(
              price,
              style: AppTypography.title.copyWith(
                fontSize: 17,
                color: selected ? AppColors.coral : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),

            // Period
            Text(
              period,
              style:
                  AppTypography.sansTiny.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  //  FEATURE CARD
  // ═══════════════════════════════════════════════════════

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
              color: AppColors.coral.withValues(alpha: 0.12),
            ),
            child: Icon(feature.icon, size: 22, color: AppColors.coral),
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
                  style: AppTypography.sansTiny
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  //  HELPERS
  // ═══════════════════════════════════════════════════════

  String get _ctaLabel => switch (_selectedPlan) {
        0 => 'Start Free Trial',
        1 => 'Start Free Trial',
        2 => 'Get Lifetime Access',
        _ => 'Start Free Trial',
      };

  String _statusText(ProStatus status) {
    if (status.isTrialing) {
      return 'TRIAL · ${status.trialDaysRemaining} DAYS LEFT';
    }
    if (status.isLifetime) return 'LIFETIME PRO';
    if (status.isPro) return 'PRO ACTIVE';
    return 'FREE PLAN';
  }

  Widget _buildDebugTierBar() {
    final notifier = ref.read(proStatusProvider.notifier);
    final currentTier = notifier.debugTier;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.bug_report, size: 16, color: Colors.amber),
          const SizedBox(width: 8),
          Text('DEBUG', style: AppTypography.monoBadge.copyWith(color: Colors.amber)),
          const Spacer(),
          for (final tier in DebugTier.values)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: GestureDetector(
                onTap: () {
                  ref.read(proStatusProvider.notifier).setDebugTier(tier);
                  setState(() {});
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: currentTier == tier
                        ? Colors.amber.withValues(alpha: 0.3)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    tier.name,
                    style: AppTypography.sansTiny.copyWith(
                      color: currentTier == tier ? Colors.amber : AppColors.textMuted,
                      fontWeight: currentTier == tier ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _handlePurchase() async {
    // On web in debug mode, simulate purchase via debug tier
    if (kIsWeb && kDebugMode) {
      final tier = _selectedPlan == 2 ? DebugTier.pro : DebugTier.trial;
      ref.read(proStatusProvider.notifier).setDebugTier(tier);
      if (mounted) {
        showAppSnackbar(context,
            message: 'Debug: Activated ${tier.name} mode',
            type: AppSnackbarType.success);
        setState(() {});
      }
      return;
    }

    setState(() => _purchasing = true);
    final service = ref.read(subscriptionProvider);
    final offerings = await service.getOfferings();
    final offering = offerings?.current;

    if (offering == null) {
      setState(() => _purchasing = false);
      if (mounted) {
        showAppSnackbar(context,
            message: 'No plans available. Try again later.',
            type: AppSnackbarType.error);
      }
      return;
    }

    final package = switch (_selectedPlan) {
      0 => offering.monthly,
      1 => offering.annual,
      2 => offering.lifetime,
      _ => offering.annual,
    };

    if (package == null) {
      setState(() => _purchasing = false);
      if (mounted) {
        showAppSnackbar(context,
            message: 'This plan is not available yet.',
            type: AppSnackbarType.error);
      }
      return;
    }

    final success = await service.purchase(package);
    if (success) ref.read(proStatusProvider.notifier).sync();
    setState(() => _purchasing = false);
    if (mounted && success) context.pop();
  }

  Future<void> _handleRestore() async {
    final service = ref.read(subscriptionProvider);
    final success = await service.restore();
    if (success) {
      ref.read(proStatusProvider.notifier).sync();
      if (mounted) context.pop();
    } else {
      if (mounted) {
        showAppSnackbar(context,
            message: 'No previous purchase found.',
            type: AppSnackbarType.info);
      }
    }
  }
}

// ═══════════════════════════════════════════════════════
//  DATA CLASSES
// ═══════════════════════════════════════════════════════

class _ProFeature {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ProFeature({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}
