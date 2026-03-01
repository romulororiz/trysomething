import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/features.dart';
import '../../providers/feature_providers.dart';
import '../../providers/hobby_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_icons.dart';
import '../../theme/app_typography.dart';
import '../../theme/spacing.dart';

/// Cost Calculator — visual cost breakdown for a hobby over time.
class CostCalculatorScreen extends ConsumerWidget {
  final String hobbyId;

  const CostCalculatorScreen({super.key, required this.hobbyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hobby = ref.watch(hobbyByIdProvider(hobbyId)).valueOrNull;
    final costData = ref.watch(costBreakdownProvider(hobbyId)).valueOrNull;
    final hobbyName = hobby?.title ?? hobbyId;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────
            _buildHeader(context, hobbyName),

            // ── Content ─────────────────────────────
            Expanded(
              child: costData == null
                  ? _buildEmptyState()
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Cost columns
                          _buildCostColumns(costData),
                          const SizedBox(height: 28),

                          // Bar chart visual
                          _buildBarChart(costData),
                          const SizedBox(height: 32),

                          // Tips section
                          _buildTipsSection(costData),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String hobbyName) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 24, 8),
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
              child: Center(
                child: Icon(AppIcons.arrowBack, size: 20, color: AppColors.nearBlack),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Cost Calculator',
              style: AppTypography.serifHeading,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(AppIcons.badgeCost, size: 48, color: AppColors.sandDark),
          const SizedBox(height: 16),
          Text(
            'No cost data available',
            style: AppTypography.sansSection.copyWith(color: AppColors.driftwood),
          ),
          const SizedBox(height: 8),
          Text(
            'We don\'t have cost info for this hobby yet.',
            style: AppTypography.sansBodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  //  COST COLUMNS
  // ═══════════════════════════════════════════════════════

  Widget _buildCostColumns(CostBreakdown cost) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.warmWhite,
        borderRadius: BorderRadius.circular(Spacing.radiusCard),
      ),
      child: Row(
        children: [
          _costColumn('Starter', cost.starter, AppColors.sage),
          _divider(),
          _costColumn('3 Month', cost.threeMonth, AppColors.amber),
          _divider(),
          _costColumn('1 Year', cost.oneYear, AppColors.coral),
        ],
      ),
    );
  }

  Widget _costColumn(String label, int amount, Color accentColor) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            style: AppTypography.overline.copyWith(
              color: AppColors.warmGray,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'CHF $amount',
            style: AppTypography.monoLarge.copyWith(
              color: accentColor,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 44,
      color: AppColors.sandDark,
    );
  }

  // ═══════════════════════════════════════════════════════
  //  BAR CHART
  // ═══════════════════════════════════════════════════════

  Widget _buildBarChart(CostBreakdown cost) {
    final maxCost = math.max(cost.oneYear, 1);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.warmWhite,
        borderRadius: BorderRadius.circular(Spacing.radiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cost over time', style: AppTypography.sansSection),
          const SizedBox(height: 20),

          _bar('Starter', cost.starter, maxCost, AppColors.sage, AppColors.sagePale),
          const SizedBox(height: 12),
          _bar('3 Month', cost.threeMonth, maxCost, AppColors.amber, AppColors.amberPale),
          const SizedBox(height: 12),
          _bar('1 Year', cost.oneYear, maxCost, AppColors.coral, AppColors.coralPale),
        ],
      ),
    );
  }

  Widget _bar(String label, int amount, int maxAmount, Color fill, Color bg) {
    final fraction = maxAmount > 0 ? (amount / maxAmount).clamp(0.05, 1.0) : 0.05;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTypography.sansCaption),
            Text(
              'CHF $amount',
              style: AppTypography.monoBadge.copyWith(color: fill),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 20,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: fraction,
            child: Container(
              decoration: BoxDecoration(
                color: fill,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════
  //  TIPS SECTION
  // ═══════════════════════════════════════════════════════

  Widget _buildTipsSection(CostBreakdown cost) {
    if (cost.tips.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Money-saving tips', style: AppTypography.sansSection),
        const SizedBox(height: 14),
        ...cost.tips.map((tip) => _tipRow(tip)),
      ],
    );
  }

  Widget _tipRow(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.amberPale,
          borderRadius: BorderRadius.circular(Spacing.radiusTile),
          border: Border.all(color: AppColors.amber.withValues(alpha: 0.2)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.amber,
              ),
              child: const Center(
                child: Icon(Icons.lightbulb_outline, size: 15, color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                tip,
                style: AppTypography.sansBody.copyWith(
                  color: AppColors.espresso,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
