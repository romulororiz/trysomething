import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../core/analytics/analytics_provider.dart';
import '../providers/subscription_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

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
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: bottomInset + 16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textWhisper,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 32),

              // Headline — emotional, not feature-list
              Text(
                'Start hobbies you\nactually stick with',
                textAlign: TextAlign.center,
                style: AppTypography.hero.copyWith(fontSize: 28),
              ),
              const SizedBox(height: 12),
              Text(
                'Get step-by-step support for your first 30 days,\nplus tools to keep momentum when motivation drops.',
                textAlign: TextAlign.center,
                style: AppTypography.body
                    .copyWith(color: AppColors.textSecondary, height: 1.5),
              ),
              const SizedBox(height: 32),

              // 3 benefit blocks — not a feature checklist
              _BenefitBlock(
                icon: MdiIcons.mapMarkerPath,
                title: 'Know the next right step',
                body:
                    'Your coach suggests exactly what to do next, so you never feel stuck.',
              ),
              const SizedBox(height: 16),
              _BenefitBlock(
                icon: MdiIcons.lifebuoy,
                title: 'Get unstuck fast',
                body:
                    'Lost motivation? Skipped a few days? Your coach helps you restart gently.',
              ),
              const SizedBox(height: 16),
              _BenefitBlock(
                icon: MdiIcons.cameraOutline,
                title: 'Track real progress',
                body:
                    'Photo journal and reflections that show how far you\'ve actually come.',
              ),
              const SizedBox(height: 32),

              // Trial callout
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.accentMuted,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(MdiIcons.giftOutline,
                        color: AppColors.accent, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Try free for 7 days',
                      style: AppTypography.body.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Plan toggle
              Row(
                children: [
                  Expanded(
                      child: _buildPlanCard(
                    label: 'Monthly',
                    price: 'CHF 4.99',
                    sub: '/month',
                    selected: !_annualSelected,
                    onTap: () => setState(() => _annualSelected = false),
                  )),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _buildPlanCard(
                    label: 'Annual',
                    price: 'CHF 39.99',
                    sub: '/year · save 33%',
                    selected: _annualSelected,
                    onTap: () => setState(() => _annualSelected = true),
                  )),
                ],
              ),
              const SizedBox(height: 24),

              // Single coral CTA
              GestureDetector(
                onTap: _purchasing ? null : _handlePurchase,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withAlpha(60),
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
                            'Start free trial',
                            style: AppTypography.button
                                .copyWith(color: AppColors.background),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Restore — secondary text link
              GestureDetector(
                onTap: _handleRestore,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Restore purchase',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textMuted,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.textMuted,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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
          color: selected ? AppColors.accentMuted : AppColors.glassBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.glassBorder,
            width: selected ? 1.5 : 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: AppTypography.body.copyWith(
                  color: selected
                      ? AppColors.accent
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                )),
            const SizedBox(height: 4),
            Text(price,
                style: AppTypography.display.copyWith(
                  fontSize: 20,
                  color: selected
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                )),
            const SizedBox(height: 2),
            Text(sub,
                style: AppTypography.caption
                    .copyWith(color: AppColors.textMuted)),
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
          const SnackBar(
              content: Text('No plans available. Try again later.')),
        );
      }
      return;
    }

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

// ═══════════════════════════════════════════════════════
//  BENEFIT BLOCK — Emotional, not feature-list
// ═══════════════════════════════════════════════════════

class _BenefitBlock extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _BenefitBlock({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glassBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassBorder, width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: AppColors.textSecondary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTypography.title.copyWith(fontSize: 15)),
                const SizedBox(height: 4),
                Text(body,
                    style: AppTypography.body
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
