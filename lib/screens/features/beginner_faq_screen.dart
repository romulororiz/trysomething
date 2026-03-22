import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../models/features.dart';
import '../../providers/feature_providers.dart';
import '../../providers/hobby_provider.dart';
import '../../providers/repository_providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../components/shimmer_skeleton.dart';
import '../../components/app_background.dart';
import '../../components/glass_card.dart';

/// Beginner FAQ screen for a specific hobby.
/// Shows expandable Q&A cards loaded from API, with thumbs up/down voting
/// and a "X found this helpful" counter per FAQ item.
class BeginnerFaqScreen extends ConsumerWidget {
  final String hobbyId;

  const BeginnerFaqScreen({super.key, required this.hobbyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hobby = ref.watch(hobbyByIdProvider(hobbyId)).valueOrNull;
    final faqAsync = ref.watch(faqProvider(hobbyId));
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: CustomScrollView(
          slivers: [
            // ── Header ──────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: topPad + 8, left: 24, right: 24),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.glassBackground,
                          border: Border.all(
                            color: AppColors.glassBorder,
                            width: 0.5,
                          ),
                        ),
                        child: const Icon(Icons.arrow_back,
                            size: 20, color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                        child: Material(
                      color: Colors.transparent,
                      child: Builder(builder: (_) {
                        final words = hobby?.title.split(' ') ?? [];
                        if (words.length <= 1) {
                          return Text(hobby?.title ?? hobbyId,
                              style: AppTypography.serifHeading);
                        }
                        return Text.rich(TextSpan(children: [
                          TextSpan(
                            text: words.first,
                            style: AppTypography.serifHeading
                                .copyWith(color: AppColors.accent),
                          ),
                          TextSpan(
                            text: ' ${words.skip(1).join(' ')} FAQs',
                            style: AppTypography.serifHeading,
                          ),
                        ]));
                      }),
                    )),
                  ],
                ),
              ),
            ),

            // ── Subtitle ──────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                child: Text(
                  'Common questions from beginners, answered by the community.',
                  style: AppTypography.sansBodySmall,
                ),
              ),
            ),

            // ── FAQ List ────────────────────────────────────
            ...faqAsync.when(
              loading: () =>
                  [const SliverToBoxAdapter(child: FaqListSkeleton())],
              error: (err, _) => [
                SliverToBoxAdapter(
                  child: ErrorRetryWidget(
                    error: err,
                    onRetry: () => ref.invalidate(faqProvider(hobbyId)),
                  ),
                ),
              ],
              data: (faqItems) => faqItems.isEmpty
                  ? [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 40),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(MdiIcons.commentQuestionOutline,
                                    size: 44, color: AppColors.textMuted),
                                const SizedBox(height: 12),
                                Text(
                                  'No FAQs for this hobby yet.',
                                  style: AppTypography.sansBody
                                      .copyWith(color: AppColors.textSecondary),
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
                      ),
                    ]
                  : [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              // Sort by helpfulCount descending
                              final sorted = List<FaqItem>.from(faqItems)
                                ..sort((a, b) =>
                                    b.helpfulCount.compareTo(a.helpfulCount));
                              final faq = sorted[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _FaqCard(
                                  faq: faq,
                                  index: index,
                                  hobbyId: hobbyId,
                                ),
                              );
                            },
                            childCount: faqItems.length,
                          ),
                        ),
                      ),
                    ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom expandable FAQ card using GlassCard and warm cinematic design.
class _FaqCard extends ConsumerStatefulWidget {
  final FaqItem faq;
  final int index;
  final String hobbyId;

  const _FaqCard({
    required this.faq,
    required this.index,
    required this.hobbyId,
  });

  @override
  ConsumerState<_FaqCard> createState() => _FaqCardState();
}

class _FaqCardState extends ConsumerState<_FaqCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  bool _votedUp = false;
  bool _votedDown = false;

  /// Tracks FAQ IDs that have been voted on in this session.
  static final Set<String> _votedFaqIds = {};

  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  late final Animation<double> _rotationAnimation;

  // Consistent thumbs up/down colors
  static const Color _thumbsUpColor = Color(0xFF4CAF50);
  static const Color _thumbsUpBg = Color(0x264CAF50);
  static const Color _thumbsDownColor = Color(0xFFE57373);
  static const Color _thumbsDownBg = Color(0x26E57373);

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
    _rotationAnimation =
        Tween<double>(begin: 0, end: 0.5).animate(_expandAnimation);

    // Restore voted state from session-local tracking
    if (_votedFaqIds.contains('${widget.faq.id}_up')) {
      _votedUp = true;
    } else if (_votedFaqIds.contains('${widget.faq.id}_down')) {
      _votedDown = true;
    }
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

  Future<void> _vote(String direction) async {
    final faqId = widget.faq.id;
    if (faqId.isEmpty) return; // No ID = seed data, can't vote

    // If already voted in this direction, ignore
    if (direction == 'up' && _votedUp) return;
    if (direction == 'down' && _votedDown) return;

    setState(() {
      if (direction == 'up') {
        _votedUp = true;
        _votedDown = false;
        _votedFaqIds.remove('${faqId}_down');
        _votedFaqIds.add('${faqId}_up');
      } else {
        _votedDown = true;
        _votedUp = false;
        _votedFaqIds.remove('${faqId}_up');
        _votedFaqIds.add('${faqId}_down');
      }
    });

    try {
      await ref
          .read(featureRepositoryProvider)
          .voteFaq(widget.hobbyId, faqId, direction);
      // Invalidate FAQ cache so the list refreshes with new counts
      ref.invalidate(faqProvider(widget.hobbyId));
    } catch (e) {
      debugPrint('[FAQ] Vote failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: false,
      padding: EdgeInsets.zero,
      onTap: _toggle,
      child: Column(
        children: [
          // ── Question Row ──────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Question number — coral circle with white text
                Container(
                  width: 28,
                  height: 28,
                  margin: const EdgeInsets.only(top: 1),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accent,
                  ),
                  child: Center(
                    child: Text(
                      '${widget.index + 1}',
                      style: AppTypography.monoBadge.copyWith(
                        color: Colors.white,
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
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Expand chevron
                RotationTransition(
                  turns: _rotationAnimation,
                  child: const Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.textMuted,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),

          // ── Answer Section (expandable) ───────────────
          SizeTransition(
            sizeFactor: _expandAnimation,
            axisAlignment: -1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(
                  height: 1,
                  color: AppColors.glassBorder,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
                  child: Text(
                    widget.faq.answer,
                    style: AppTypography.sansBodySmall.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.7,
                    ),
                  ),
                ),

                // Helpful count display
                if (widget.faq.helpfulCount > 0)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Text(
                      '${widget.faq.helpfulCount} found this helpful',
                      style: AppTypography.sansTiny.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),

                // "Was this helpful?" row with thumbs up/down
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
                        onTap: () => _vote('up'),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: _votedUp
                                ? _thumbsUpBg
                                : AppColors.glassBackground,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _votedUp
                                  ? _thumbsUpColor.withAlpha(51)
                                  : AppColors.glassBorder,
                              width: 0.5,
                            ),
                          ),
                          child: Icon(
                            MdiIcons.thumbUp,
                            size: 16,
                            color:
                                _votedUp ? _thumbsUpColor : AppColors.textMuted,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Thumbs down
                      GestureDetector(
                        onTap: () => _vote('down'),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: _votedDown
                                ? _thumbsDownBg
                                : AppColors.glassBackground,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _votedDown
                                  ? _thumbsDownColor.withAlpha(51)
                                  : AppColors.glassBorder,
                              width: 0.5,
                            ),
                          ),
                          child: Icon(
                            MdiIcons.thumbDown,
                            size: 16,
                            color: _votedDown
                                ? _thumbsDownColor
                                : AppColors.textMuted,
                          ),
                        ),
                      ),

                      if (_votedUp || _votedDown) ...[
                        const SizedBox(width: 10),
                        Text(
                          _votedUp ? 'Helpful!' : 'Noted',
                          style: AppTypography.sansTiny.copyWith(
                            color: _votedUp ? _thumbsUpColor : _thumbsDownColor,
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
