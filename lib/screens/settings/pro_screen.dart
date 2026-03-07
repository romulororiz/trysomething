import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/subscription_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/spacing.dart';

/// Dedicated TrySomething Pro screen with full feature list, plan comparison,
/// and trial/upgrade CTA.
class ProScreen extends ConsumerStatefulWidget {
  const ProScreen({super.key});

  @override
  ConsumerState<ProScreen> createState() => _ProScreenState();
}

class _ProScreenState extends ConsumerState<ProScreen> {
  bool _annualSelected = true;
  bool _purchasing = false;

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(proStatusProvider);
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.sand,
                      ),
                      child: const Icon(Icons.arrow_back,
                          size: 20, color: AppColors.espresso),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text('TrySomething Pro', style: AppTypography.serifHeading),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: ListView(
                padding: EdgeInsets.only(bottom: bottomPad + 120),
                children: [
                  // Status badge
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: status.isPro
                            ? AppColors.sage.withValues(alpha: 0.15)
                            : AppColors.sand,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        _statusText(status),
                        style: AppTypography.monoBadge.copyWith(
                          color: status.isPro ? AppColors.sage : AppColors.driftwood,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Hero
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                AppColors.coral.withValues(alpha: 0.2),
                                AppColors.indigo.withValues(alpha: 0.2),
                              ],
                            ),
                          ),
                          child: const Icon(Icons.auto_awesome,
                              size: 32, color: AppColors.coral),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Unlock the full experience',
                          style: AppTypography.serifSubheading,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'AI coaching, photo journals, buddy matching,\nand much more.',
                          style: AppTypography.sansCaption
                              .copyWith(color: AppColors.driftwood),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Feature list
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.warmWhite,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Everything in Pro',
                              style: AppTypography.sansSection),
                          const SizedBox(height: 16),
                          ..._proFeatures.map((f) => _FeatureItem(
                                icon: f.$1,
                                label: f.$2,
                                desc: f.$3,
                              )),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Plan toggle
                  if (!status.isPro) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          Expanded(
                            child: _PlanCard(
                              label: 'Monthly',
                              price: 'CHF 4.99',
                              sub: '/month',
                              selected: !_annualSelected,
                              onTap: () =>
                                  setState(() => _annualSelected = false),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _PlanCard(
                              label: 'Annual',
                              price: 'CHF 39.99',
                              sub: '/year · save 33%',
                              selected: _annualSelected,
                              onTap: () =>
                                  setState(() => _annualSelected = true),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Restore purchase
                    Center(
                      child: GestureDetector(
                        onTap: _handleRestore,
                        child: Text(
                          'Restore purchase',
                          style: AppTypography.sansCaption.copyWith(
                            color: AppColors.driftwood,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Manage subscription (for existing subscribers)
                    Center(
                      child: Text(
                        'Subscriptions are managed by your app store.',
                        style: AppTypography.sansTiny
                            .copyWith(color: AppColors.warmGray),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      // Floating CTA
      bottomSheet: status.isPro
          ? null
          : Container(
              color: AppColors.cream,
              padding: EdgeInsets.fromLTRB(24, 12, 24, bottomPad + 16),
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
    );
  }

  String _statusText(ProStatus status) {
    if (status.isTrialing) {
      return 'TRIAL · ${status.trialDaysRemaining} DAYS LEFT';
    }
    if (status.isPro) return 'PRO ACTIVE';
    return 'FREE PLAN';
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

    final package = _annualSelected ? offering.annual : offering.monthly;
    if (package == null) {
      setState(() => _purchasing = false);
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No previous purchase found.')),
        );
      }
    }
  }

  static const _proFeatures = [
    (Icons.auto_awesome, 'Unlimited AI Hobby Coach', 'Personalized guidance for every hobby'),
    (Icons.camera_alt_outlined, 'Photo Journal', 'Add photos to your journal entries'),
    (Icons.shuffle_rounded, '"Surprise Me" Generator', 'AI-generated custom hobbies from a prompt'),
    (Icons.search_rounded, 'AI Search', 'Generate hobbies when catalog doesn\'t match'),
    (Icons.insights_outlined, 'Advanced Stats & Radar', 'Detailed skill breakdowns and year-in-review'),
    (Icons.people_outline, 'Buddy Mode', 'Find and pair with hobby partners'),
    (Icons.emoji_events_outlined, 'Advanced Achievements', 'Unlock the full achievement set'),
    (Icons.ios_share_rounded, 'Export Journal as PDF', 'Share your hobby journey'),
    (Icons.card_membership_outlined, 'Hobby Passport', 'Collect stamps for completed hobbies'),
  ];
}

// ═══════════════════════════════════════════════════════
//  FEATURE ITEM
// ═══════════════════════════════════════════════════════

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String desc;

  const _FeatureItem({
    required this.icon,
    required this.label,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.coral.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: AppColors.coral),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppTypography.sansLabel
                        .copyWith(color: AppColors.espresso)),
                const SizedBox(height: 2),
                Text(desc,
                    style: AppTypography.sansTiny
                        .copyWith(color: AppColors.warmGray)),
              ],
            ),
          ),
          const Icon(Icons.check_circle, size: 18, color: AppColors.coral),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  PLAN CARD
// ═══════════════════════════════════════════════════════

class _PlanCard extends StatelessWidget {
  final String label;
  final String price;
  final String sub;
  final bool selected;
  final VoidCallback onTap;

  const _PlanCard({
    required this.label,
    required this.price,
    required this.sub,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.coral.withValues(alpha: 0.08)
              : AppColors.warmWhite,
          borderRadius: BorderRadius.circular(Spacing.radiusButton),
          border: Border.all(
            color: selected ? AppColors.coral : AppColors.sandDark,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: AppTypography.sansLabel.copyWith(
                  color: selected ? AppColors.coral : AppColors.nearBlack,
                  fontWeight: FontWeight.w700,
                )),
            const SizedBox(height: 4),
            Text(price,
                style: AppTypography.serifHeading.copyWith(
                  fontSize: 20,
                  color: selected ? AppColors.coral : AppColors.nearBlack,
                )),
            const SizedBox(height: 2),
            Text(sub,
                style: AppTypography.sansTiny
                    .copyWith(color: AppColors.driftwood)),
          ],
        ),
      ),
    );
  }
}
