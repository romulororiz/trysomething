import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/social.dart';
import '../../providers/feature_providers.dart';
import '../../providers/hobby_provider.dart';
import '../../providers/user_provider.dart';
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.coral,
        onPressed: () => _showCreateStorySheet(context, ref),
        child: const Icon(Icons.edit_rounded, color: Colors.white),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Header ──────────────────────────────────
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
                  Text('Community Stories', style: AppTypography.serifHeading),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // ── Stories list ────────────────────────────
            Expanded(
              child: stories.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(AppIcons.heartOutline,
                              size: 48, color: AppColors.warmGray),
                          const SizedBox(height: 16),
                          Text(
                            'No stories yet',
                            style: AppTypography.sansSection
                                .copyWith(color: AppColors.warmGray),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Be the first to share your hobby journey!',
                            style: AppTypography.sansBodySmall
                                .copyWith(color: AppColors.stone),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, Spacing.scrollBottomPadding),
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

  void _showCreateStorySheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.warmWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => _CreateStorySheet(ref: ref),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  STORY CARD (provider-driven reactions)
// ═══════════════════════════════════════════════════════

class _StoryCard extends ConsumerWidget {
  final CommunityStory story;
  final Color backgroundColor;

  const _StoryCard({
    required this.story,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hobby = ref.watch(hobbyByIdProvider(story.hobbyId)).valueOrNull;
    final hobbyName = hobby?.title ?? story.hobbyId;

    final heartCount = story.reactions['heart'] ?? 0;
    final fireCount = story.reactions['fire'] ?? 0;
    final heartTapped = story.userReactions.contains('heart');
    final fireTapped = story.userReactions.contains('fire');

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: backgroundColor,
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
                  story.authorInitial,
                  style: AppTypography.sansSection.copyWith(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(story.authorName, style: AppTypography.sansSection),
            ],
          ),
          const SizedBox(height: 20),

          // ── Quote ─────────────────────────────────
          Text(
            '\u201C${story.quote}\u201D',
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
                icon: heartTapped
                    ? AppIcons.heartFilled
                    : AppIcons.heartOutline,
                count: heartCount,
                color: heartTapped ? AppColors.coral : AppColors.warmGray,
                onTap: () {
                  ref.read(storiesProvider.notifier)
                      .toggleReaction(story.id, 'heart');
                },
              ),
              const SizedBox(width: 12),

              // Fire reaction
              _ReactionChip(
                icon: AppIcons.fire,
                count: fireCount,
                color: fireTapped ? AppColors.amber : AppColors.warmGray,
                onTap: () {
                  ref.read(storiesProvider.notifier)
                      .toggleReaction(story.id, 'fire');
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

// ═══════════════════════════════════════════════════════
//  CREATE STORY BOTTOM SHEET
// ═══════════════════════════════════════════════════════

class _CreateStorySheet extends StatefulWidget {
  final WidgetRef ref;
  const _CreateStorySheet({required this.ref});

  @override
  State<_CreateStorySheet> createState() => _CreateStorySheetState();
}

class _CreateStorySheetState extends State<_CreateStorySheet> {
  final _quoteCtrl = TextEditingController();
  String? _selectedHobbyId;

  @override
  void dispose() {
    _quoteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userHobbies = widget.ref.read(userHobbiesProvider);
    final hobbyIds = userHobbies.keys.toList();

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Share Your Story', style: AppTypography.serifSubheading),
          const SizedBox(height: 8),
          Text(
            'Inspire others with your hobby journey',
            style: AppTypography.sansBodySmall
                .copyWith(color: AppColors.warmGray),
          ),
          const SizedBox(height: 20),

          // ── Hobby picker ──
          DropdownButtonFormField<String>(
            initialValue: _selectedHobbyId,
            decoration: InputDecoration(
              labelText: 'Hobby',
              labelStyle: AppTypography.sansCaption
                  .copyWith(color: AppColors.driftwood),
              filled: true,
              fillColor: AppColors.sand,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Spacing.radiusInput),
                borderSide: BorderSide.none,
              ),
            ),
            dropdownColor: AppColors.sand,
            style: AppTypography.sansBody.copyWith(color: AppColors.nearBlack),
            items: hobbyIds.map((id) {
              final hobby = widget.ref
                  .read(hobbyByIdProvider(id))
                  .valueOrNull;
              return DropdownMenuItem(
                value: id,
                child: Text(hobby?.title ?? id),
              );
            }).toList(),
            onChanged: (v) => setState(() => _selectedHobbyId = v),
          ),
          const SizedBox(height: 14),

          // ── Quote text field ──
          TextField(
            controller: _quoteCtrl,
            maxLines: 3,
            style: AppTypography.sansBody.copyWith(color: AppColors.nearBlack),
            decoration: InputDecoration(
              hintText: 'What\u2019s your hobby story?',
              hintStyle: AppTypography.sansBody
                  .copyWith(color: AppColors.stone),
              filled: true,
              fillColor: AppColors.sand,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Spacing.radiusInput),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ── Submit button ──
          GestureDetector(
            onTap: () {
              final quote = _quoteCtrl.text.trim();
              if (quote.isEmpty || _selectedHobbyId == null) return;
              widget.ref
                  .read(storiesProvider.notifier)
                  .createStory(quote, _selectedHobbyId!);
              Navigator.of(context).pop();
            },
            child: Container(
              height: Spacing.buttonPrimaryHeight,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.coral, AppColors.coralDeep],
                ),
                borderRadius: BorderRadius.circular(Spacing.radiusButton),
              ),
              child: Center(
                child: Text('Share Story', style: AppTypography.sansCta),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
