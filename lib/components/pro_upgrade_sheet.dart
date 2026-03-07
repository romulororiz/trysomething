import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../core/analytics/analytics_provider.dart';
import '../providers/subscription_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/spacing.dart';

/// Show the Pro upgrade bottom sheet from any screen.
void showProUpgrade(BuildContext context, String triggerMessage) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ProUpgradeSheet(triggerMessage: triggerMessage),
  );
}

class _ProUpgradeSheet extends ConsumerStatefulWidget {
  final String triggerMessage;

  const _ProUpgradeSheet({required this.triggerMessage});

  @override
  ConsumerState<_ProUpgradeSheet> createState() => _ProUpgradeSheetState();
}

class _ProUpgradeSheetState extends ConsumerState<_ProUpgradeSheet> {
  bool _annualSelected = true;
  bool _purchasing = false;

  static const _features = [
    _FeatureRow(icon: Icons.auto_awesome, label: 'AI Hobby Coach', free: false, pro: true),
    _FeatureRow(icon: Icons.camera_alt_outlined, label: 'Photo Journal', free: false, pro: true),
    _FeatureRow(icon: Icons.shuffle_rounded, label: '"Surprise Me" Generator', free: false, pro: true),
    _FeatureRow(icon: Icons.insights_outlined, label: 'Advanced Stats & Radar', free: false, pro: true),
    _FeatureRow(icon: Icons.people_outline, label: 'Buddy Mode', free: false, pro: true),
    _FeatureRow(icon: Icons.explore_outlined, label: '150+ Curated Hobbies', free: true, pro: true),
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(analyticsProvider).trackEvent('paywall_shown', {
        'trigger': widget.triggerMessage,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.warmWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: bottomInset + 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.driftwood.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Sparkle icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.coral.withValues(alpha: 0.2),
                    AppColors.indigo.withValues(alpha: 0.2),
                  ],
                ),
              ),
              child: const Icon(Icons.auto_awesome, color: AppColors.coral, size: 28),
            ),
            const SizedBox(height: 16),

            // Title
            Text('TrySomething Pro', style: AppTypography.serifHeading.copyWith(fontSize: 24)),
            const SizedBox(height: 8),

            // Trigger context
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                widget.triggerMessage,
                style: AppTypography.sansCaption.copyWith(color: AppColors.driftwood),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),

            // Feature comparison
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.sand,
                  borderRadius: BorderRadius.circular(Spacing.radiusTile),
                ),
                child: Column(
                  children: [
                    // Header row
                    Row(
                      children: [
                        const Expanded(child: SizedBox()),
                        SizedBox(
                          width: 48,
                          child: Text('Free', style: AppTypography.monoBadge.copyWith(
                            color: AppColors.driftwood, fontSize: 10,
                          ), textAlign: TextAlign.center),
                        ),
                        SizedBox(
                          width: 48,
                          child: Text('Pro', style: AppTypography.monoBadge.copyWith(
                            color: AppColors.coral, fontSize: 10,
                          ), textAlign: TextAlign.center),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ..._features.map((f) => _buildFeatureRow(f)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Trial callout
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.coral.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(Spacing.radiusButton),
                border: Border.all(color: AppColors.coral.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(MdiIcons.giftOutline, color: AppColors.coral, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Try Pro free for 7 days',
                      style: AppTypography.sansLabel.copyWith(color: AppColors.coral),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Plan toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(child: _buildPlanCard(
                    label: 'Monthly',
                    price: 'CHF 4.99',
                    sub: '/month',
                    selected: !_annualSelected,
                    onTap: () => setState(() => _annualSelected = false),
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _buildPlanCard(
                    label: 'Annual',
                    price: 'CHF 39.99',
                    sub: '/year · save 33%',
                    selected: _annualSelected,
                    onTap: () => setState(() => _annualSelected = true),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // CTA button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GestureDetector(
                onTap: _purchasing ? null : _handlePurchase,
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
                            'Start Free Trial',
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
            const SizedBox(height: 12),

            // Restore purchases link
            GestureDetector(
              onTap: _handleRestore,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Restore purchase',
                  style: AppTypography.sansCaption.copyWith(
                    color: AppColors.driftwood,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(_FeatureRow feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(feature.icon, size: 18, color: AppColors.driftwood),
          const SizedBox(width: 10),
          Expanded(
            child: Text(feature.label, style: AppTypography.sansBodySmall),
          ),
          SizedBox(
            width: 48,
            child: Center(
              child: feature.free
                  ? const Icon(Icons.check_circle, size: 18, color: AppColors.sage)
                  : Icon(Icons.remove, size: 18, color: AppColors.driftwood.withValues(alpha: 0.3)),
            ),
          ),
          const SizedBox(
            width: 48,
            child: Center(
              child: Icon(Icons.check_circle, size: 18, color: AppColors.coral),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard({
    required String label,
    required String price,
    required String sub,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.coral.withValues(alpha: 0.08) : AppColors.sand,
          borderRadius: BorderRadius.circular(Spacing.radiusButton),
          border: Border.all(
            color: selected ? AppColors.coral : AppColors.sandDark,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTypography.sansLabel.copyWith(
              color: selected ? AppColors.coral : AppColors.nearBlack,
              fontWeight: FontWeight.w700,
            )),
            const SizedBox(height: 4),
            Text(price, style: AppTypography.serifHeading.copyWith(
              fontSize: 20,
              color: selected ? AppColors.coral : AppColors.nearBlack,
            )),
            const SizedBox(height: 2),
            Text(sub, style: AppTypography.sansTiny.copyWith(
              color: AppColors.driftwood,
            )),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePurchase() async {
    setState(() => _purchasing = true);

    final service = ref.read(subscriptionProvider);
    final offerings = await service.getOfferings();
    final offering = offerings?.current;

    if (offering == null) {
      setState(() => _purchasing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No plans available. Try again later.')),
        );
      }
      return;
    }

    // Pick the right package based on selection
    final package = _annualSelected ? offering.annual : offering.monthly;
    if (package == null) {
      setState(() => _purchasing = false);
      return;
    }

    final success = await service.purchase(package);
    if (success) {
      ref.read(proStatusProvider.notifier).sync();
    }

    setState(() => _purchasing = false);
    if (mounted && success) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _handleRestore() async {
    final service = ref.read(subscriptionProvider);
    final success = await service.restore();
    if (success) {
      ref.read(proStatusProvider.notifier).sync();
      if (mounted) Navigator.of(context).pop();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No previous purchase found.')),
        );
      }
    }
  }
}

class _FeatureRow {
  final IconData icon;
  final String label;
  final bool free;
  final bool pro;

  const _FeatureRow({
    required this.icon,
    required this.label,
    required this.free,
    required this.pro,
  });
}
