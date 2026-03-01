import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/social.dart';
import '../../providers/feature_providers.dart';
import '../../providers/hobby_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_icons.dart';
import '../../theme/app_typography.dart';
import '../../theme/spacing.dart';

/// Community Stories — inspiring quotes from real hobbyists.
class CommunityStoriesScreen extends ConsumerWidget {
  const CommunityStoriesScreen({super.key});

  static const _tintColors = [
    AppColors.coralPale,
    AppColors.amberPale,
    AppColors.indigoPale,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stories = ref.watch(storiesProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Header ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 24, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(AppIcons.arrowBack, color: AppColors.nearBlack),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 4),
                  Text('Community Stories', style: AppTypography.serifHeading),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // ── Stories list ────────────────────────────
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                itemCount: stories.length,
                itemBuilder: (context, index) {
                  final tint = _tintColors[index % _tintColors.length];
                  return _StoryCard(
                    story: stories[index],
                    backgroundColor: tint,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  STORY CARD (with local reaction state)
// ═══════════════════════════════════════════════════════

class _StoryCard extends ConsumerStatefulWidget {
  final CommunityStory story;
  final Color backgroundColor;

  const _StoryCard({
    required this.story,
    required this.backgroundColor,
  });

  @override
  ConsumerState<_StoryCard> createState() => _StoryCardState();
}

class _StoryCardState extends ConsumerState<_StoryCard> {
  late int _heartCount;
  late int _fireCount;
  bool _heartTapped = false;
  bool _fireTapped = false;

  @override
  void initState() {
    super.initState();
    _heartCount = widget.story.reactions['heart'] ?? 0;
    _fireCount = widget.story.reactions['fire'] ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final hobby = ref.watch(hobbyByIdProvider(widget.story.hobbyId)).valueOrNull;
    final hobbyName = hobby?.title ?? widget.story.hobbyId;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: Spacing.cardBorderRadius,
        boxShadow: Spacing.subtleShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Author row ────────────────────────────
          Row(
            children: [
              // Avatar
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.coral, AppColors.indigo],
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  widget.story.authorInitial,
                  style: AppTypography.sansSection.copyWith(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(widget.story.authorName, style: AppTypography.sansSection),
            ],
          ),
          const SizedBox(height: 20),

          // ── Quote ─────────────────────────────────
          Text(
            '\u201C${widget.story.quote}\u201D',
            style: GoogleFonts.sourceSerif4(
              fontSize: 17,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.italic,
              height: 1.6,
              color: AppColors.espresso,
            ),
          ),
          const SizedBox(height: 20),

          // ── Hobby pill + reactions ────────────────
          Row(
            children: [
              // Hobby pill
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.warmWhite,
                  borderRadius: Spacing.badgeBorderRadius,
                ),
                child: Text(
                  hobbyName,
                  style: AppTypography.monoBadgeSmall.copyWith(
                    color: AppColors.driftwood,
                  ),
                ),
              ),
              const Spacer(),

              // Heart reaction
              _ReactionChip(
                icon: _heartTapped
                    ? AppIcons.heartFilled
                    : AppIcons.heartOutline,
                count: _heartCount,
                color: _heartTapped ? AppColors.coral : AppColors.warmGray,
                onTap: () {
                  setState(() {
                    if (!_heartTapped) {
                      _heartCount++;
                      _heartTapped = true;
                    } else {
                      _heartCount--;
                      _heartTapped = false;
                    }
                  });
                },
              ),
              const SizedBox(width: 12),

              // Fire reaction
              _ReactionChip(
                icon: AppIcons.fire,
                count: _fireCount,
                color: _fireTapped ? AppColors.amber : AppColors.warmGray,
                onTap: () {
                  setState(() {
                    if (!_fireTapped) {
                      _fireCount++;
                      _fireTapped = true;
                    } else {
                      _fireCount--;
                      _fireTapped = false;
                    }
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  REACTION CHIP
// ═══════════════════════════════════════════════════════

class _ReactionChip extends StatelessWidget {
  final IconData icon;
  final int count;
  final Color color;
  final VoidCallback onTap;

  const _ReactionChip({
    required this.icon,
    required this.count,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: AppTypography.monoBadge.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
