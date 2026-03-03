import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/hobby.dart';
import '../../providers/feature_providers.dart';
import '../../providers/hobby_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_icons.dart';
import '../../theme/app_typography.dart';
import '../../theme/spacing.dart';

/// Shopping List — checklist of starter kit items with running cost total.
class ShoppingListScreen extends ConsumerWidget {
  final String hobbyId;

  const ShoppingListScreen({super.key, required this.hobbyId});

  static final _loadedHobbies = <String>{};

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (_loadedHobbies.add(hobbyId)) {
      ref.read(shoppingListCheckedProvider.notifier).loadForHobby(hobbyId);
    }
    final hobby = ref.watch(hobbyByIdProvider(hobbyId)).valueOrNull;
    final checkedItems = ref.watch(shoppingListCheckedProvider);

    if (hobby == null) {
      return Scaffold(
        backgroundColor: AppColors.cream,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, 'Shopping List'),
              Expanded(child: _buildEmptyState('Hobby not found')),
            ],
          ),
        ),
      );
    }

    final items = hobby.starterKit;
    final allChecked = items.isNotEmpty &&
        items.every((item) => checkedItems.contains('${hobbyId}_${item.name}'));

    // Total cost of unchecked items
    final uncheckedTotal = items
        .where((item) => !checkedItems.contains('${hobbyId}_${item.name}'))
        .fold<int>(0, (sum, item) => sum + item.cost);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────
            _buildHeader(context, 'Shopping List'),

            // ── Hobby subtitle ──────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  hobby.title,
                  style: AppTypography.sansCaption.copyWith(
                    color: AppColors.driftwood,
                    fontSize: 14,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── All done banner ─────────────────────
            if (allChecked) _buildAllDoneBanner(),

            // ── Item list ───────────────────────────
            Expanded(
              child: items.isEmpty
                  ? _buildEmptyState('No starter kit items for this hobby.')
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final key = '${hobbyId}_${item.name}';
                        final isChecked = checkedItems.contains(key);

                        return _ShoppingItemTile(
                          item: item,
                          isChecked: isChecked,
                          onToggle: () {
                            ref.read(shoppingListCheckedProvider.notifier)
                                .toggle(hobbyId, item.name, !isChecked);
                          },
                        );
                      },
                    ),
            ),

            // ── Total bar ───────────────────────────
            if (items.isNotEmpty && !allChecked)
              _buildTotalBar(uncheckedTotal),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
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
          Text(title, style: AppTypography.serifHeading),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(AppIcons.shoppingList, size: 48, color: AppColors.sandDark),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTypography.sansBodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAllDoneBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 8),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.sagePale,
        borderRadius: BorderRadius.circular(Spacing.radiusTile),
        border: Border.all(color: AppColors.sage.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.sage,
            ),
            child: Center(
              child: Icon(AppIcons.check, size: 18, color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'All done!',
                  style: AppTypography.sansSection.copyWith(color: AppColors.sage),
                ),
                const SizedBox(height: 2),
                Text(
                  'You\'ve got everything you need to start.',
                  style: AppTypography.sansCaption.copyWith(color: AppColors.driftwood),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalBar(int total) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 16),
      decoration: const BoxDecoration(
        color: AppColors.warmWhite,
        border: Border(
          top: BorderSide(color: AppColors.sandDark),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Remaining total',
              style: AppTypography.sansLabel.copyWith(color: AppColors.driftwood),
            ),
            Text(
              'CHF $total',
              style: AppTypography.monoLarge.copyWith(
                color: AppColors.coral,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  SHOPPING ITEM TILE
// ═══════════════════════════════════════════════════════

class _ShoppingItemTile extends StatelessWidget {
  final KitItem item;
  final bool isChecked;
  final VoidCallback onToggle;

  const _ShoppingItemTile({
    required this.item,
    required this.isChecked,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isChecked
              ? AppColors.sagePale.withValues(alpha: 0.6)
              : AppColors.warmWhite,
          borderRadius: BorderRadius.circular(Spacing.radiusTile),
          border: Border.all(
            color: isChecked
                ? AppColors.sage.withValues(alpha: 0.3)
                : AppColors.sandDark,
          ),
        ),
        child: Row(
          children: [
            // Checkbox
            Container(
              width: Spacing.checkboxSize,
              height: Spacing.checkboxSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isChecked ? AppColors.sage : Colors.transparent,
                border: Border.all(
                  color: isChecked ? AppColors.sage : AppColors.sandDark,
                  width: 2,
                ),
              ),
              child: isChecked
                  ? Center(
                      child: Icon(AppIcons.check, size: 16, color: Colors.white),
                    )
                  : null,
            ),
            const SizedBox(width: 12),

            // Name + optional badge
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          item.name,
                          style: AppTypography.sansBody.copyWith(
                            color: isChecked ? AppColors.warmGray : AppColors.nearBlack,
                            decoration: isChecked ? TextDecoration.lineThrough : null,
                            decorationColor: AppColors.warmGray,
                          ),
                        ),
                      ),
                      if (item.isOptional) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.sand,
                            borderRadius: BorderRadius.circular(Spacing.radiusBadge),
                          ),
                          child: Text(
                            'OPTIONAL',
                            style: AppTypography.sansTiny.copyWith(
                              letterSpacing: 1,
                              fontWeight: FontWeight.w600,
                              color: AppColors.warmGray,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (item.description.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.description,
                      style: AppTypography.sansCaption.copyWith(
                        color: isChecked ? AppColors.warmGray : AppColors.driftwood,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Cost
            if (item.cost > 0) ...[
              const SizedBox(width: 8),
              Text(
                'CHF ${item.cost}',
                style: AppTypography.monoBadge.copyWith(
                  color: isChecked ? AppColors.warmGray : AppColors.coral,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
