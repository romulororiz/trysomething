import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../models/feature_seed_data.dart';
import '../../models/features.dart';
import '../../providers/hobby_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_icons.dart';
import '../../theme/spacing.dart';

/// Budget alternatives screen for a specific hobby.
/// Shows a 3-column comparison (DIY / Budget / Premium) for each item
/// in the hobby's starter kit, with color-coded tiers.
class BudgetAlternativesScreen extends ConsumerWidget {
  final String hobbyId;

  const BudgetAlternativesScreen({super.key, required this.hobbyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hobby = ref.watch(hobbyByIdProvider(hobbyId)).valueOrNull;
    final alternatives = FeatureSeedData.budgetAlternatives[hobbyId] ?? [];
    final costBreakdown = FeatureSeedData.costByHobby[hobbyId];
    final topPad = MediaQuery.of(context).padding.top;
    final hobbyName = hobby?.title ?? hobbyId;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: CustomScrollView(
        slivers: [
          // ── Header ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: topPad + 8, left: 16, right: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.warmWhite,
                      ),
                      child: const Center(
                        child: Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.nearBlack),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(AppIcons.badgeCost, size: 22, color: AppColors.sage),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Budget Options',
                      style: AppTypography.sansSection,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Title ───────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 6),
              child: Text(
                'Budget Options \u2014 $hobbyName',
                style: AppTypography.serifHeading,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: Text(
                'Every price tier, so you can start at any budget.',
                style: AppTypography.sansBodySmall,
              ),
            ),
          ),

          // ── Cost Summary Card ───────────────────────────
          if (costBreakdown != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                child: _CostSummaryCard(breakdown: costBreakdown, hobbyName: hobbyName),
              ),
            ),

          // ── Tier Legend ─────────────────────────────────
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Row(
                children: [
                  _TierDot(color: AppColors.sage, label: 'DIY'),
                  SizedBox(width: 16),
                  _TierDot(color: AppColors.amber, label: 'Budget'),
                  SizedBox(width: 16),
                  _TierDot(color: AppColors.indigo, label: 'Premium'),
                ],
              ),
            ),
          ),

          // ── Alternatives List ───────────────────────────
          if (alternatives.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: Center(
                  child: Column(
                    children: [
                      Icon(MdiIcons.packageVariantClosed, size: 44, color: AppColors.warmGray),
                      const SizedBox(height: 12),
                      Text(
                        'No budget alternatives listed yet.',
                        style: AppTypography.sansBody.copyWith(color: AppColors.driftwood),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Check the starter kit on the hobby detail page.',
                        style: AppTypography.sansCaption,
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final alt = alternatives[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _AlternativeCard(alternative: alt),
                    );
                  },
                  childCount: alternatives.length,
                ),
              ),
            ),

          // ── Tips Section ────────────────────────────────
          if (costBreakdown != null && costBreakdown.tips.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
                child: Row(
                  children: [
                    Icon(AppIcons.sparkle, size: 18, color: AppColors.amber),
                    const SizedBox(width: 8),
                    Text('Money-saving tips', style: AppTypography.sansSection.copyWith(fontSize: 16)),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final tip = costBreakdown.tips[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.only(top: 7),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.amber,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              tip,
                              style: AppTypography.sansBodySmall.copyWith(
                                height: 1.5,
                                color: AppColors.espresso,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  childCount: costBreakdown.tips.length,
                ),
              ),
            ),
          ],

          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

/// Cost summary card showing starter / 3-month / 1-year breakdown.
class _CostSummaryCard extends StatelessWidget {
  final CostBreakdown breakdown;
  final String hobbyName;

  const _CostSummaryCard({required this.breakdown, required this.hobbyName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warmWhite,
        borderRadius: BorderRadius.circular(Spacing.radiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cost at a Glance',
            style: AppTypography.sansLabel.copyWith(fontSize: 14),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _CostColumn(label: 'Starter', amount: breakdown.starter, color: AppColors.sage)),
              Container(width: 1, height: 44, color: AppColors.sandDark),
              Expanded(child: _CostColumn(label: '3 months', amount: breakdown.threeMonth, color: AppColors.amber)),
              Container(width: 1, height: 44, color: AppColors.sandDark),
              Expanded(child: _CostColumn(label: '1 year', amount: breakdown.oneYear, color: AppColors.indigo)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Single cost column inside the summary card.
class _CostColumn extends StatelessWidget {
  final String label;
  final int amount;
  final Color color;

  const _CostColumn({required this.label, required this.amount, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          amount == 0 ? 'Free' : 'CHF $amount',
          style: AppTypography.monoMedium.copyWith(color: color),
        ),
        const SizedBox(height: 4),
        Text(label, style: AppTypography.sansCaption),
      ],
    );
  }
}

/// Tier legend dot with label.
class _TierDot extends StatelessWidget {
  final Color color;
  final String label;

  const _TierDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: AppTypography.sansCaption.copyWith(color: AppColors.espresso)),
      ],
    );
  }
}

/// 3-column comparison card for a single budget alternative item.
class _AlternativeCard extends StatelessWidget {
  final BudgetAlternative alternative;

  const _AlternativeCard({required this.alternative});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.warmWhite,
        borderRadius: BorderRadius.circular(Spacing.radiusCard),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item name header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColors.sand,
            ),
            child: Row(
              children: [
                Icon(MdiIcons.packageVariantClosed, size: 16, color: AppColors.espresso),
                const SizedBox(width: 8),
                Text(
                  alternative.itemName,
                  style: AppTypography.sansLabel.copyWith(fontSize: 14),
                ),
              ],
            ),
          ),

          // 3 tier columns
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _TierColumn(
                    tierLabel: 'DIY',
                    tierColor: AppColors.sage,
                    tierPaleColor: AppColors.sagePale,
                    optionName: alternative.diyOption,
                    cost: alternative.diyCost,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _TierColumn(
                    tierLabel: 'Budget',
                    tierColor: AppColors.amber,
                    tierPaleColor: AppColors.amberPale,
                    optionName: alternative.budgetOption,
                    cost: alternative.budgetCost,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _TierColumn(
                    tierLabel: 'Premium',
                    tierColor: AppColors.indigo,
                    tierPaleColor: AppColors.indigoPale,
                    optionName: alternative.premiumOption,
                    cost: alternative.premiumCost,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Single tier column inside an alternative card.
class _TierColumn extends StatelessWidget {
  final String tierLabel;
  final Color tierColor;
  final Color tierPaleColor;
  final String optionName;
  final int cost;

  const _TierColumn({
    required this.tierLabel,
    required this.tierColor,
    required this.tierPaleColor,
    required this.optionName,
    required this.cost,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: tierPaleColor,
        borderRadius: BorderRadius.circular(Spacing.radiusTile),
        border: Border.all(color: tierColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tier badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: tierColor,
              borderRadius: BorderRadius.circular(Spacing.radiusBadge),
            ),
            child: Text(
              tierLabel,
              style: AppTypography.monoBadge.copyWith(
                color: Colors.white,
                fontSize: 9,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Cost
          Text(
            cost == 0 ? 'Free' : 'CHF $cost',
            style: AppTypography.monoMedium.copyWith(
              color: tierColor,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),

          // Option name
          Text(
            optionName,
            style: AppTypography.sansBodySmall.copyWith(
              fontSize: 12,
              height: 1.35,
              color: AppColors.espresso,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
