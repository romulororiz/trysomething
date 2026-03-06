import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/hobby.dart';
import '../../providers/feature_providers.dart';
import '../../providers/hobby_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_icons.dart';
import '../../theme/app_typography.dart';
import '../../theme/spacing.dart';

/// Shopping List — checklist of starter kit items with product images + affiliate links.
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
              _buildHeader(context),
              Expanded(child: _buildEmptyState('Hobby not found')),
            ],
          ),
        ),
      );
    }

    final items = hobby.starterKit;
    final checkedCount =
        items.where((item) => checkedItems.contains('${hobbyId}_${item.name}')).length;
    final allChecked = items.isNotEmpty && checkedCount == items.length;

    // Total cost of unchecked items
    final uncheckedTotal = items
        .where((item) => !checkedItems.contains('${hobbyId}_${item.name}'))
        .fold<int>(0, (sum, item) => sum + item.cost);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),

            // Hobby title + progress
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(hobby.title, style: AppTypography.serifSubheading),
                        const SizedBox(height: 4),
                        Text(
                          '$checkedCount of ${items.length} items purchased',
                          style: AppTypography.sansCaption.copyWith(
                            color: AppColors.driftwood,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Progress ring
                  SizedBox(
                    width: 44,
                    height: 44,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: items.isEmpty ? 0 : checkedCount / items.length,
                          strokeWidth: 3,
                          backgroundColor: AppColors.sand,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.sage),
                        ),
                        Text(
                          '${items.isEmpty ? 0 : (checkedCount * 100 / items.length).round()}%',
                          style: AppTypography.monoTiny.copyWith(
                            color: AppColors.driftwood,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // All done banner
            if (allChecked) _buildAllDoneBanner(),

            // Item list
            Expanded(
              child: items.isEmpty
                  ? _buildEmptyState('No starter kit items for this hobby.')
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, Spacing.scrollBottomPadding),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final key = '${hobbyId}_${item.name}';
                        final isChecked = checkedItems.contains(key);

                        return _ShoppingItemCard(
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

            // Total bar
            if (items.isNotEmpty && !allChecked)
              _buildTotalBar(uncheckedTotal),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: const Icon(Icons.arrow_back, size: 20, color: AppColors.espresso),
          ),
          const Spacer(),
          Text('Shopping List', style: AppTypography.sansSection),
          const Spacer(),
          const SizedBox(width: 20),
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
          Text(message, style: AppTypography.sansBodySmall, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildAllDoneBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.sagePale,
        borderRadius: BorderRadius.circular(14),
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
                Text('All done!',
                    style: AppTypography.sansSection.copyWith(color: AppColors.sage)),
                const SizedBox(height: 2),
                Text('You\'ve got everything you need to start.',
                    style: AppTypography.sansCaption.copyWith(color: AppColors.driftwood)),
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
        border: Border(top: BorderSide(color: AppColors.sandDark)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Remaining total',
                style: AppTypography.sansLabel.copyWith(color: AppColors.driftwood)),
            Text('CHF $total',
                style: AppTypography.monoLarge.copyWith(color: AppColors.coral, fontSize: 20)),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  SHOPPING ITEM CARD — with product image + buy link
// ═══════════════════════════════════════════════════════

class _ShoppingItemCard extends StatelessWidget {
  final KitItem item;
  final bool isChecked;
  final VoidCallback onToggle;

  const _ShoppingItemCard({
    required this.item,
    required this.isChecked,
    required this.onToggle,
  });

  Future<void> _openAffiliateLink() async {
    final url = item.affiliateUrl ??
        'https://www.amazon.de/s?k=${Uri.encodeComponent(item.name)}&tag=trysomething-21';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = item.imageUrl != null && item.imageUrl!.isNotEmpty;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isChecked
            ? AppColors.sagePale.withValues(alpha: 0.5)
            : AppColors.warmWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isChecked
              ? AppColors.sage.withValues(alpha: 0.3)
              : Colors.transparent,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image + checkbox overlay
          GestureDetector(
            onTap: onToggle,
            child: SizedBox(
              height: 100,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                    child: hasImage
                        ? Image.network(
                            item.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: AppColors.sand,
                              child: Center(
                                child: Icon(Icons.shopping_bag_outlined,
                                    size: 28, color: AppColors.warmGray),
                              ),
                            ),
                          )
                        : Container(
                            color: AppColors.sand,
                            child: Center(
                              child: Icon(Icons.shopping_bag_outlined,
                                  size: 28, color: AppColors.warmGray),
                            ),
                          ),
                  ),
                  // Checked overlay
                  if (isChecked)
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                      child: Container(
                        color: AppColors.sage.withValues(alpha: 0.3),
                        child: Center(
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.sage,
                            ),
                            child: Center(
                              child: Icon(AppIcons.check, size: 22, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Checkbox — top left
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isChecked ? AppColors.sage : Colors.black.withValues(alpha: 0.4),
                        border: Border.all(
                          color: isChecked ? AppColors.sage : Colors.white.withValues(alpha: 0.6),
                          width: 2,
                        ),
                      ),
                      child: isChecked
                          ? Center(child: Icon(AppIcons.check, size: 14, color: Colors.white))
                          : null,
                    ),
                  ),
                  // Optional badge — top right
                  if (item.isOptional)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('OPTIONAL',
                            style: AppTypography.monoBadgeSmall.copyWith(
                              color: Colors.white,
                              fontSize: 8,
                            )),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Content area
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: AppTypography.sansCaption.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isChecked ? AppColors.warmGray : AppColors.nearBlack,
                          decoration: isChecked ? TextDecoration.lineThrough : null,
                          decorationColor: AppColors.warmGray,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (item.cost > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Text(
                            'CHF ${item.cost}',
                            style: AppTypography.monoBadge.copyWith(
                              color: isChecked ? AppColors.warmGray : AppColors.coral,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Buy button
                GestureDetector(
                  onTap: isChecked ? null : _openAffiliateLink,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isChecked ? AppColors.sand : AppColors.coral,
                      borderRadius: BorderRadius.circular(Spacing.radiusButton),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 14,
                          color: isChecked ? AppColors.warmGray : Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Buy',
                          style: AppTypography.sansCaption.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isChecked ? AppColors.warmGray : Colors.white,
                          ),
                        ),
                      ],
                    ),
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
