import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/features.dart';
import '../../models/hobby.dart';
import '../../providers/feature_providers.dart';
import '../../providers/hobby_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/spacing.dart';
import '../../components/shimmer_skeleton.dart';
import '../../components/app_background.dart';
import '../../components/glass_card.dart';

// ═══════════════════════════════════════════════════════
//  COST TIER
// ═══════════════════════════════════════════════════════

enum CostTier {
  essential('Essential', 'Minimum to start'),
  bestValue('Best Value', 'Recommended setup'),
  allIn('All-in', 'Everything included');

  final String label;
  final String subtitle;
  const CostTier(this.label, this.subtitle);
}

// ═══════════════════════════════════════════════════════
//  COST CALCULATOR SCREEN
// ═══════════════════════════════════════════════════════

class CostCalculatorScreen extends ConsumerStatefulWidget {
  final String hobbyId;

  const CostCalculatorScreen({super.key, required this.hobbyId});

  @override
  ConsumerState<CostCalculatorScreen> createState() =>
      _CostCalculatorScreenState();
}

class _CostCalculatorScreenState extends ConsumerState<CostCalculatorScreen>
    with TickerProviderStateMixin {
  CostTier _selectedTier = CostTier.bestValue;
  final Set<int> _disabledItems = {};
  late AnimationController _chartController;
  late Animation<double> _chartProgress;

  @override
  void initState() {
    super.initState();
    _chartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _chartProgress = CurvedAnimation(
      parent: _chartController,
      curve: Curves.easeOutCubic,
    );
    // Start chart animation on first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chartController.forward();
    });
  }

  @override
  void dispose() {
    _chartController.dispose();
    super.dispose();
  }

  List<KitItem> _getVisibleItems(List<KitItem> allItems) {
    switch (_selectedTier) {
      case CostTier.essential:
        return allItems.where((item) => !item.isOptional).toList();
      case CostTier.bestValue:
        return allItems; // show all, but optional items can be toggled off
      case CostTier.allIn:
        return allItems;
    }
  }

  int _computeTotal(List<KitItem> allItems) {
    final visible = _getVisibleItems(allItems);
    int total = 0;
    for (int i = 0; i < allItems.length; i++) {
      final item = allItems[i];
      if (!visible.contains(item)) continue;
      if (_disabledItems.contains(i)) continue;
      // In "all-in" tier, nothing can be disabled
      if (_selectedTier == CostTier.allIn || !_disabledItems.contains(i)) {
        total += item.cost;
      }
    }
    return total;
  }

  Future<void> _openAffiliateLink(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _toggleItem(int index) {
    if (_selectedTier == CostTier.essential) return; // can't toggle essentials
    if (_selectedTier == CostTier.allIn) return; // all-in means everything
    HapticFeedback.lightImpact();
    setState(() {
      if (_disabledItems.contains(index)) {
        _disabledItems.remove(index);
      } else {
        _disabledItems.add(index);
      }
    });
    _chartController.forward(from: 0.3); // re-animate from partial
  }

  void _selectTier(CostTier tier) {
    if (tier == _selectedTier) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _selectedTier = tier;
      if (tier == CostTier.essential) {
        _disabledItems.clear(); // reset toggles
      } else if (tier == CostTier.allIn) {
        _disabledItems.clear(); // everything on
      }
    });
    _chartController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final hobby = ref.watch(hobbyByIdProvider(widget.hobbyId)).valueOrNull;
    final costAsync = ref.watch(costBreakdownProvider(widget.hobbyId));
    final hobbyName = hobby?.title ?? widget.hobbyId;
    final kitItems = hobby?.starterKit ?? [];

    final total = _computeTotal(kitItems);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, hobbyName),
              Expanded(
                child: costAsync.when(
                  loading: () => const CostCalculatorSkeleton(),
                  error: (err, _) => ErrorRetryWidget(
                    error: err,
                    onRetry: () => ref.invalidate(
                        costBreakdownProvider(widget.hobbyId)),
                  ),
                  data: (costData) => kitItems.isEmpty && costData == null
                      ? _buildEmptyState()
                      : SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(
                              20, 8, 20, Spacing.scrollBottom(context) + 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Donut chart + total
                              _buildChartSection(kitItems, total),
                              const SizedBox(height: 24),

                              // Tier selector
                              _buildTierSelector(),
                              const SizedBox(height: 20),

                              // Item breakdown
                              _buildItemBreakdown(kitItems),
                              const SizedBox(height: 24),

                              // Cost timeline
                              if (costData != null) ...[
                                _buildTimeline(costData),
                                const SizedBox(height: 24),
                              ],

                              // Tips
                              if (costData != null &&
                                  costData.tips.isNotEmpty) ...[
                                _buildTips(costData.tips),
                              ],
                            ],
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

  // ── Header ──────────────────────────────────────────

  Widget _buildHeader(BuildContext context, String hobbyName) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 20, 4),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.glassBackground,
                shape: BoxShape.circle,
                border:
                    Border.all(color: AppColors.glassBorder, width: 0.5),
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  size: 18, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cost Breakdown',
                  style: AppTypography.title.copyWith(
                    fontSize: 18,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  hobbyName,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Chart Section ───────────────────────────────────

  Widget _buildChartSection(List<KitItem> items, int total) {
    final visible = _getVisibleItems(items);
    // Build segments for the donut
    final segments = <_ChartSegment>[];
    for (int i = 0; i < items.length; i++) {
      if (!visible.contains(items[i])) continue;
      if (_disabledItems.contains(i)) continue;
      segments.add(_ChartSegment(
        label: items[i].name,
        value: items[i].cost.toDouble(),
        color: _segmentColor(i),
      ));
    }

    return GlassCard(
      blur: true,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Center(
            child: SizedBox(
              width: 200,
              height: 200,
              child: AnimatedBuilder(
                animation: _chartProgress,
                builder: (context, _) {
                  return CustomPaint(
                    size: const Size(200, 200),
                    painter: _DonutChartPainter(
                      segments: segments,
                      progress: _chartProgress.value,
                      centerText: 'CHF $total',
                      centerLabel: _selectedTier.label,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Legend
          Wrap(
            spacing: 12,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: segments.take(5).map((seg) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: seg.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    seg.label.length > 16
                        ? '${seg.label.substring(0, 14)}...'
                        : seg.label,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
          duration: 500.ms,
          curve: Curves.easeOutCubic,
        );
  }

  Color _segmentColor(int index) {
    const colors = [
      Color(0xFFFF6B6B), // coral
      Color(0xFF06D6A0), // teal
      Color(0xFF7B68EE), // purple
      Color(0xFFFFB347), // amber
      Color(0xFF87CEEB), // sky
      Color(0xFFDDA0DD), // lavender
      Color(0xFFDAA520), // golden
      Color(0xFFF5F0EB), // cream
    ];
    return colors[index % colors.length];
  }

  // ── Tier Selector ───────────────────────────────────

  Widget _buildTierSelector() {
    return Row(
      children: CostTier.values.map((tier) {
        final isActive = _selectedTier == tier;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: tier != CostTier.allIn ? 8 : 0,
            ),
            child: GestureDetector(
              onTap: () => _selectTier(tier),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.accent.withValues(alpha: 0.12)
                      : AppColors.glassBackground,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isActive
                        ? AppColors.accent.withValues(alpha: 0.4)
                        : AppColors.glassBorder,
                    width: isActive ? 1.0 : 0.5,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      tier.label,
                      style: AppTypography.caption.copyWith(
                        fontWeight:
                            isActive ? FontWeight.w700 : FontWeight.w500,
                        color: isActive
                            ? AppColors.accent
                            : AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tier.subtitle,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms);
  }

  // ── Item Breakdown ──────────────────────────────────

  Widget _buildItemBreakdown(List<KitItem> items) {
    final visible = _getVisibleItems(items);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'STARTER KIT',
              style: AppTypography.caption.copyWith(
                color: AppColors.textMuted,
                letterSpacing: 2,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              '${visible.length} items',
              style: AppTypography.caption.copyWith(
                color: AppColors.textMuted,
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...List.generate(items.length, (i) {
          final item = items[i];
          if (!visible.contains(item)) return const SizedBox.shrink();
          final isDisabled = _disabledItems.contains(i);
          final canToggle = _selectedTier == CostTier.bestValue &&
              item.isOptional;

          return _buildItemRow(item, i, isDisabled, canToggle)
              .animate()
              .fadeIn(
                duration: 350.ms,
                delay: (i * 50).ms,
              )
              .slideX(
                begin: 0.03,
                end: 0,
                duration: 350.ms,
                delay: (i * 50).ms,
                curve: Curves.easeOutCubic,
              );
        }),
      ],
    );
  }

  Widget _buildItemRow(
      KitItem item, int index, bool isDisabled, bool canToggle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: canToggle ? () => _toggleItem(index) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDisabled
                ? AppColors.glassBackground.withValues(alpha: 0.03)
                : AppColors.glassBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDisabled
                  ? AppColors.glassBorder.withValues(alpha: 0.3)
                  : AppColors.glassBorder,
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              // Item image or icon
              if (item.imageUrl != null && item.imageUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 250),
                    opacity: isDisabled ? 0.3 : 1.0,
                    child: CachedNetworkImage(
                      imageUrl: item.imageUrl!,
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                      memCacheWidth: 88,
                      errorWidget: (_, __, ___) => _itemIcon(isDisabled),
                    ),
                  ),
                )
              else
                _itemIcon(isDisabled),

              const SizedBox(width: 12),

              // Info
              Expanded(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 250),
                  opacity: isDisabled ? 0.35 : 1.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.name,
                              style: AppTypography.body.copyWith(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                                decoration: isDisabled
                                    ? TextDecoration.lineThrough
                                    : null,
                                decorationColor: AppColors.textMuted,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (item.isOptional)
                            Container(
                              margin: const EdgeInsets.only(left: 6),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.accent.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'optional',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.accent,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (item.description.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          item.description,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Cost + buy link + toggle
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Cost + buy link row
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 250),
                        style: AppTypography.data.copyWith(
                          color: isDisabled
                              ? AppColors.textMuted
                              : AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        child: Text('CHF ${item.cost}'),
                      ),
                      if (item.affiliateUrl != null &&
                          item.affiliateUrl!.isNotEmpty &&
                          !isDisabled) ...[
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => _openAffiliateLink(item.affiliateUrl!),
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.open_in_new_rounded,
                              size: 13,
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (canToggle)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: 36,
                        height: 20,
                        decoration: BoxDecoration(
                          color: isDisabled
                              ? AppColors.surfaceElevated
                              : AppColors.accent.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: AnimatedAlign(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutCubic,
                          alignment: isDisabled
                              ? Alignment.centerLeft
                              : Alignment.centerRight,
                          child: Container(
                            width: 16,
                            height: 16,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: isDisabled
                                  ? AppColors.textMuted
                                  : AppColors.accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _itemIcon(bool isDisabled) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: isDisabled ? 0.3 : 1.0,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.shopping_bag_outlined,
            size: 20, color: AppColors.textMuted),
      ),
    );
  }

  // ── Cost Timeline ───────────────────────────────────

  Widget _buildTimeline(CostBreakdown cost) {
    final maxCost = math.max(cost.oneYear, 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'COST OVER TIME',
          style: AppTypography.caption.copyWith(
            color: AppColors.textMuted,
            letterSpacing: 2,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 14),
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _timelineBar('To start', cost.starter, maxCost,
                  const Color(0xFF06D6A0), 0),
              const SizedBox(height: 14),
              _timelineBar('3 months', cost.threeMonth, maxCost,
                  const Color(0xFFFFB347), 1),
              const SizedBox(height: 14),
              _timelineBar('1 year', cost.oneYear, maxCost,
                  AppColors.accent, 2),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms);
  }

  Widget _timelineBar(
      String label, int amount, int maxAmount, Color fill, int index) {
    final fraction =
        maxAmount > 0 ? (amount / maxAmount).clamp(0.05, 1.0) : 0.05;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'CHF $amount',
              style: AppTypography.data.copyWith(
                color: AppColors.textPrimary,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 10,
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(5),
          ),
          child: AnimatedBuilder(
            animation: _chartProgress,
            builder: (context, _) {
              return FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: fraction * _chartProgress.value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        fill.withValues(alpha: 0.6),
                        fill,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Tips ─────────────────────────────────────────────

  Widget _buildTips(List<String> tips) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MONEY-SAVING TIPS',
          style: AppTypography.caption.copyWith(
            color: AppColors.textMuted,
            letterSpacing: 2,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...tips.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GlassCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${entry.key + 1}',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: AppTypography.body.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
              .animate()
              .fadeIn(duration: 350.ms, delay: (300 + entry.key * 80).ms);
        }),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.account_balance_wallet_outlined,
              size: 48, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text(
            'No cost data available',
            style: AppTypography.title.copyWith(
              color: AppColors.textSecondary,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We don\'t have cost info for this hobby yet.',
            style: AppTypography.body.copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  DONUT CHART PAINTER
// ═══════════════════════════════════════════════════════

class _ChartSegment {
  final String label;
  final double value;
  final Color color;

  const _ChartSegment({
    required this.label,
    required this.value,
    required this.color,
  });
}

class _DonutChartPainter extends CustomPainter {
  final List<_ChartSegment> segments;
  final double progress;
  final String centerText;
  final String centerLabel;

  _DonutChartPainter({
    required this.segments,
    required this.progress,
    required this.centerText,
    required this.centerLabel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 8;
    const strokeWidth = 22.0;
    const gapAngle = 0.04; // small gap between segments

    // Background ring
    final bgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = const Color(0xFF1A1A20);
    canvas.drawCircle(center, radius, bgPaint);

    if (segments.isEmpty) {
      _drawCenterText(canvas, center, size);
      return;
    }

    final total = segments.fold<double>(0, (s, seg) => s + seg.value);
    if (total <= 0) {
      _drawCenterText(canvas, center, size);
      return;
    }

    final totalGap = gapAngle * segments.length;
    final availableAngle = 2 * math.pi - totalGap;

    double startAngle = -math.pi / 2; // start from top

    for (final seg in segments) {
      final sweepAngle = (seg.value / total) * availableAngle * progress;
      final segPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = seg.color;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        segPaint,
      );

      startAngle += sweepAngle + gapAngle;
    }

    _drawCenterText(canvas, center, size);
  }

  void _drawCenterText(Canvas canvas, Offset center, Size size) {
    // Total amount
    final totalPainter = TextPainter(
      text: TextSpan(
        text: centerText,
        style: const TextStyle(
          fontFamily: 'IBM Plex Mono',
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Color(0xFFF5F0EB),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    totalPainter.paint(
      canvas,
      center - Offset(totalPainter.width / 2, totalPainter.height / 2 + 8),
    );

    // Label
    final labelPainter = TextPainter(
      text: TextSpan(
        text: centerLabel,
        style: const TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: Color(0xFF6B6360),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    labelPainter.paint(
      canvas,
      center - Offset(labelPainter.width / 2, labelPainter.height / 2 - 12),
    );
  }

  @override
  bool shouldRepaint(_DonutChartPainter old) =>
      progress != old.progress ||
      segments.length != old.segments.length ||
      centerText != old.centerText;
}
