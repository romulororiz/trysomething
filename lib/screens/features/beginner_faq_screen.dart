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

/// Beginner FAQ screen for a specific hobby.
/// Shows expandable Q&A cards loaded from seed data, with upvote badges
/// and a "Was this helpful?" row at the bottom of each answer.
class BeginnerFaqScreen extends ConsumerWidget {
  final String hobbyId;

  const BeginnerFaqScreen({super.key, required this.hobbyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hobby = ref.watch(hobbyByIdProvider(hobbyId));
    final faqItems = FeatureSeedData.faqByHobby[hobbyId] ?? [];
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
                  Icon(AppIcons.faq, size: 22, color: AppColors.indigo),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '$hobbyName FAQ',
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
                '$hobbyName FAQ',
                style: AppTypography.serifHeading,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: Text(
                'Common questions from beginners, answered by the community.',
                style: AppTypography.sansBodySmall,
              ),
            ),
          ),

          // ── FAQ List ────────────────────────────────────
          if (faqItems.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: Center(
                  child: Column(
                    children: [
                      Icon(MdiIcons.commentQuestionOutline, size: 44, color: AppColors.warmGray),
                      const SizedBox(height: 12),
                      Text(
                        'No FAQs for this hobby yet.',
                        style: AppTypography.sansBody.copyWith(color: AppColors.driftwood),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Check back soon!',
                        style: AppTypography.sansCaption,
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final faq = faqItems[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _FaqCard(faq: faq, index: index),
                    );
                  },
                  childCount: faqItems.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Custom expandable FAQ card (not Material ExpansionTile).
class _FaqCard extends StatefulWidget {
  final FaqItem faq;
  final int index;

  const _FaqCard({required this.faq, required this.index});

  @override
  State<_FaqCard> createState() => _FaqCardState();
}

class _FaqCardState extends State<_FaqCard> with SingleTickerProviderStateMixin {
  bool _expanded = false;
  bool _helpfulUp = false;
  bool _helpfulDown = false;

  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  late final Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.warmWhite,
        borderRadius: BorderRadius.circular(Spacing.radiusTile),
        boxShadow: _expanded ? Spacing.subtleShadow : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // ── Question Row ──────────────────────────────
          GestureDetector(
            onTap: _toggle,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question number
                  Container(
                    width: 28,
                    height: 28,
                    margin: const EdgeInsets.only(top: 1),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.indigoPale,
                    ),
                    child: Center(
                      child: Text(
                        '${widget.index + 1}',
                        style: AppTypography.monoBadge.copyWith(
                          color: AppColors.indigo,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Question text
                  Expanded(
                    child: Text(
                      widget.faq.question,
                      style: AppTypography.sansBody.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                        color: AppColors.nearBlack,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Upvote badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.amberPale,
                      borderRadius: BorderRadius.circular(Spacing.radiusBadge),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(MdiIcons.arrowUp, size: 12, color: AppColors.amberDeep),
                        const SizedBox(width: 2),
                        Text(
                          '${widget.faq.upvotes}',
                          style: AppTypography.monoBadge.copyWith(
                            color: AppColors.amberDeep,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),

                  // Expand chevron
                  RotationTransition(
                    turns: _rotationAnimation,
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.driftwood,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Answer Section (expandable) ───────────────
          SizeTransition(
            sizeFactor: _expandAnimation,
            axisAlignment: -1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(height: 1, color: AppColors.sandDark),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                  child: Text(
                    widget.faq.answer,
                    style: AppTypography.sansBody.copyWith(
                      color: AppColors.espresso,
                      height: 1.65,
                    ),
                  ),
                ),

                // "Was this helpful?" row
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
                  child: Row(
                    children: [
                      Text(
                        'Was this helpful?',
                        style: AppTypography.sansCaption,
                      ),
                      const SizedBox(width: 12),

                      // Thumbs up
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _helpfulUp = !_helpfulUp;
                            if (_helpfulUp) _helpfulDown = false;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: _helpfulUp
                                ? AppColors.sagePale
                                : AppColors.sand,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            MdiIcons.thumbUp,
                            size: 16,
                            color: _helpfulUp ? AppColors.sage : AppColors.warmGray,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Thumbs down
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _helpfulDown = !_helpfulDown;
                            if (_helpfulDown) _helpfulUp = false;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: _helpfulDown
                                ? AppColors.rosePale
                                : AppColors.sand,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            MdiIcons.thumbDown,
                            size: 16,
                            color: _helpfulDown ? AppColors.rose : AppColors.warmGray,
                          ),
                        ),
                      ),

                      if (_helpfulUp || _helpfulDown) ...[
                        const SizedBox(width: 10),
                        Text(
                          _helpfulUp ? 'Thanks!' : 'Noted',
                          style: AppTypography.sansTiny.copyWith(
                            color: _helpfulUp ? AppColors.sage : AppColors.rose,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
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
