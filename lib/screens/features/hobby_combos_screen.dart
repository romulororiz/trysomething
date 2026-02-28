import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/features.dart';
import '../../providers/feature_providers.dart';
import '../../providers/hobby_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_icons.dart';
import '../../theme/app_typography.dart';
import '../../theme/spacing.dart';

/// Hobby Combos — discover complementary hobby pairs with shared tags.
class HobbyCombosScreen extends ConsumerWidget {
  const HobbyCombosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final combos = ref.watch(combosProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────
            _buildHeader(context),

            // ── Combo list ──────────────────────────
            Expanded(
              child: combos.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                      itemCount: combos.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        return _ComboCard(combo: combos[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
          Text('Hobby Combos', style: AppTypography.serifHeading),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(AppIcons.sparkle, size: 48, color: AppColors.sandDark),
          const SizedBox(height: 16),
          Text(
            'No combos yet',
            style: AppTypography.sansSection.copyWith(color: AppColors.driftwood),
          ),
          const SizedBox(height: 8),
          Text(
            'Combos appear as you explore more hobbies.',
            style: AppTypography.sansBodySmall,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  COMBO CARD
// ═══════════════════════════════════════════════════════

class _ComboCard extends ConsumerWidget {
  final HobbyCombo combo;

  const _ComboCard({required this.combo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hobby1 = ref.watch(hobbyByIdProvider(combo.hobbyId1));
    final hobby2 = ref.watch(hobbyByIdProvider(combo.hobbyId2));

    if (hobby1 == null || hobby2 == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warmWhite,
        borderRadius: BorderRadius.circular(Spacing.radiusCard),
        boxShadow: Spacing.subtleShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hobby pair images ─────────────────
          Row(
            children: [
              // Hobby 1
              Expanded(child: _HobbyImageTile(
                imageUrl: hobby1.imageUrl,
                title: hobby1.title,
              )),

              // Plus connector
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.amberPale,
                    border: Border.all(color: AppColors.amber.withValues(alpha: 0.3)),
                  ),
                  child: const Center(
                    child: Icon(Icons.add, size: 18, color: AppColors.amber),
                  ),
                ),
              ),

              // Hobby 2
              Expanded(child: _HobbyImageTile(
                imageUrl: hobby2.imageUrl,
                title: hobby2.title,
              )),
            ],
          ),

          const SizedBox(height: 14),

          // ── Reason text ───────────────────────
          Text(
            combo.reason,
            style: AppTypography.sansBody.copyWith(
              color: AppColors.espresso,
              height: 1.55,
            ),
          ),

          const SizedBox(height: 12),

          // ── Shared tags ───────────────────────
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: combo.sharedTags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.indigoPale,
                  borderRadius: BorderRadius.circular(Spacing.radiusBadge),
                ),
                child: Text(
                  tag,
                  style: AppTypography.sansCaption.copyWith(
                    color: AppColors.indigo,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // ── Try this combo button ─────────────
          SizedBox(
            width: double.infinity,
            height: Spacing.buttonSecondaryHeight,
            child: ElevatedButton(
              onPressed: () {
                // Navigate to the first hobby's detail
                context.push('/hobby/${combo.hobbyId1}');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.coral,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Spacing.radiusButton),
                ),
              ),
              child: Text(
                'Try this combo',
                style: AppTypography.sansCta,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  HOBBY IMAGE TILE
// ═══════════════════════════════════════════════════════

class _HobbyImageTile extends StatelessWidget {
  final String imageUrl;
  final String title;

  const _HobbyImageTile({
    required this.imageUrl,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(Spacing.radiusTile),
          child: AspectRatio(
            aspectRatio: 1.2,
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: AppColors.sand),
              errorWidget: (_, __, ___) => Container(
                color: AppColors.sand,
                child: Icon(AppIcons.image, size: 28, color: AppColors.warmGray),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: AppTypography.sansLabel.copyWith(color: AppColors.nearBlack),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
