import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../models/feature_seed_data.dart';
import '../../providers/hobby_provider.dart';
import '../../theme/category_ui.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_icons.dart';
import '../../theme/spacing.dart';

/// Seasonal hobby picks screen.
/// Auto-detects the current season and highlights it at top with coral accent.
/// All 4 seasons shown as expandable sections with hobby cards.
class SeasonalPicksScreen extends ConsumerWidget {
  const SeasonalPicksScreen({super.key});

  /// Map month to season key used in FeatureSeedData.seasonalHobbies.
  static String _currentSeasonKey(int month) {
    if (month >= 3 && month <= 5) return 'Spring Awakening';
    if (month >= 6 && month <= 8) return 'Summer Adventures';
    if (month >= 9 && month <= 11) return 'Autumn Coziness';
    return 'Winter Warmers'; // Dec, Jan, Feb
  }

  /// Season display data: key → (icon, color).
  static final Map<String, _SeasonData> _seasonMeta = {
    'Winter Warmers': _SeasonData(MdiIcons.snowflake, AppColors.indigo, AppColors.indigoPale),
    'Spring Awakening': _SeasonData(MdiIcons.flowerTulip, AppColors.sage, AppColors.sagePale),
    'Summer Adventures': _SeasonData(MdiIcons.whiteBalanceSunny, AppColors.amber, AppColors.amberPale),
    'Autumn Coziness': _SeasonData(MdiIcons.leaf, AppColors.coral, AppColors.coralPale),
  };

  /// Ordered season keys so current season appears first.
  static List<String> _orderedSeasons(String currentKey) {
    final all = FeatureSeedData.seasonalHobbies.keys.toList();
    all.remove(currentKey);
    return [currentKey, ...all];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topPad = MediaQuery.of(context).padding.top;
    final currentKey = _currentSeasonKey(DateTime.now().month);
    final orderedSeasons = _orderedSeasons(currentKey);

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
                        border: Border.all(color: AppColors.sandDark),
                      ),
                      child: const Center(
                        child: Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.nearBlack),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(AppIcons.seasonal, size: 22, color: AppColors.amber),
                  const SizedBox(width: 8),
                  Text('Seasonal Picks', style: AppTypography.sansSection),
                ],
              ),
            ),
          ),

          // ── Title ───────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Seasonal Picks', style: AppTypography.serifHeading),
                  const SizedBox(height: 6),
                  Text(
                    'Hobbies that shine each season.',
                    style: AppTypography.sansBodySmall,
                  ),
                ],
              ),
            ),
          ),

          // ── Season Sections ─────────────────────────────
          ...orderedSeasons.map((seasonKey) {
            final isCurrent = seasonKey == currentKey;
            final meta = _seasonMeta[seasonKey] ??
                _SeasonData(MdiIcons.calendarBlank, AppColors.warmGray, AppColors.sand);
            final hobbyIds = FeatureSeedData.seasonalHobbies[seasonKey] ?? [];

            return SliverToBoxAdapter(
              child: _SeasonSection(
                seasonKey: seasonKey,
                isCurrent: isCurrent,
                meta: meta,
                hobbyIds: hobbyIds,
              ),
            );
          }),

          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

/// Internal data for season display configuration.
class _SeasonData {
  final IconData icon;
  final Color color;
  final Color paleColor;

  const _SeasonData(this.icon, this.color, this.paleColor);
}

/// A single expandable season section.
class _SeasonSection extends ConsumerStatefulWidget {
  final String seasonKey;
  final bool isCurrent;
  final _SeasonData meta;
  final List<String> hobbyIds;

  const _SeasonSection({
    required this.seasonKey,
    required this.isCurrent,
    required this.meta,
    required this.hobbyIds,
  });

  @override
  ConsumerState<_SeasonSection> createState() => _SeasonSectionState();
}

class _SeasonSectionState extends ConsumerState<_SeasonSection>
    with SingleTickerProviderStateMixin {
  late bool _expanded;
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  late final Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    // Current season starts expanded, others collapsed.
    _expanded = widget.isCurrent;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      value: _expanded ? 1.0 : 0.0,
    );

    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 0.5).animate(_expandAnimation);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final meta = widget.meta;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      child: Container(
        decoration: BoxDecoration(
          color: widget.isCurrent ? meta.paleColor : AppColors.warmWhite,
          borderRadius: BorderRadius.circular(Spacing.radiusCard),
          border: Border.all(
            color: widget.isCurrent
                ? AppColors.coral.withValues(alpha: 0.35)
                : AppColors.sandDark,
            width: widget.isCurrent ? 1.5 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // Section header
            GestureDetector(
              onTap: _toggle,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    // Season icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: meta.color.withValues(alpha: 0.12),
                      ),
                      child: Center(
                        child: Icon(meta.icon, size: 20, color: meta.color),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Title + current badge
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                widget.seasonKey,
                                style: AppTypography.sansSection.copyWith(
                                  fontSize: 16,
                                ),
                              ),
                              if (widget.isCurrent) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.coral,
                                    borderRadius: BorderRadius.circular(Spacing.radiusBadge),
                                  ),
                                  child: Text(
                                    'NOW',
                                    style: AppTypography.monoBadge.copyWith(
                                      color: Colors.white,
                                      letterSpacing: 1.2,
                                      fontSize: 9,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${widget.hobbyIds.length} hobbies',
                            style: AppTypography.sansCaption,
                          ),
                        ],
                      ),
                    ),

                    // Expand/collapse chevron
                    RotationTransition(
                      turns: _rotationAnimation,
                      child: const Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.driftwood,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Expandable content
            SizeTransition(
              sizeFactor: _expandAnimation,
              axisAlignment: -1,
              child: Column(
                children: [
                  const Divider(height: 1, color: AppColors.sandDark),
                  ...widget.hobbyIds.map((id) {
                    return _SeasonHobbyCard(hobbyId: id, seasonColor: meta.color);
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual hobby row inside a season section.
class _SeasonHobbyCard extends ConsumerWidget {
  final String hobbyId;
  final Color seasonColor;

  const _SeasonHobbyCard({required this.hobbyId, required this.seasonColor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hobby = ref.watch(hobbyByIdProvider(hobbyId));
    if (hobby == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => context.push('/hobby/${hobby.id}'),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(Spacing.radiusSmall),
              child: Image.network(
                hobby.imageUrl,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 56,
                  height: 56,
                  color: AppColors.sand,
                  child: Icon(hobby.catIcon, size: 20, color: AppColors.warmGray),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(hobby.title, style: AppTypography.sansLabel),
                  const SizedBox(height: 3),
                  // Category pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.sand,
                      borderRadius: BorderRadius.circular(Spacing.radiusBadge),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(hobby.catIcon, size: 10, color: hobby.catColor),
                        const SizedBox(width: 4),
                        Text(
                          hobby.category,
                          style: AppTypography.sansTiny.copyWith(
                            color: AppColors.driftwood,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // "Try it" button
            GestureDetector(
              onTap: () => context.push('/hobby/${hobby.id}'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: seasonColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(Spacing.radiusButton),
                  border: Border.all(color: seasonColor.withValues(alpha: 0.25)),
                ),
                child: Text(
                  'Try it \u2192',
                  style: AppTypography.sansLabel.copyWith(
                    color: seasonColor,
                    fontSize: 12,
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
