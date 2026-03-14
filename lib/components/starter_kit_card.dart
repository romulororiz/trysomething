import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/hobby.dart';
import 'glass_card.dart';
import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import '../theme/app_typography.dart';
import '../theme/spacing.dart';
import '../theme/motion.dart';

/// Starter kit card showing essential/best-value kit items with affiliate links.
/// Shared between HobbyDetailScreen and HomeScreen.
class StarterKitCard extends StatefulWidget {
  final Hobby hobby;
  const StarterKitCard({super.key, required this.hobby});

  @override
  State<StarterKitCard> createState() => _StarterKitCardState();
}

class _StarterKitCardState extends State<StarterKitCard> {
  bool _showBestValue = false;

  Future<void> _openAffiliateLink(KitItem item) async {
    final url = item.affiliateUrl ??
        'https://www.amazon.de/s?k=${Uri.encodeComponent(item.name)}&tag=trysomething-21';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hobby = widget.hobby;
    if (hobby.starterKit.isEmpty) return const SizedBox.shrink();

    final essentialItems =
        hobby.starterKit.where((k) => !k.isOptional).toList();
    final allItems = hobby.starterKit;
    final displayItems = _showBestValue ? allItems : essentialItems;
    final total = displayItems.fold(0, (sum, item) => sum + item.cost);

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shopping_bag_outlined,
                  size: 16, color: AppColors.coral),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Starter kit',
                    style: AppTypography.sansLabel.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    )),
              ),
              if (total > 0)
                Text('~ CHF $total',
                    style: AppTypography.monoBadge
                        .copyWith(color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 12),

          // Minimum / Best Value toggle
          if (allItems.length > essentialItems.length)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  KitToggle(
                    label: 'Minimum',
                    selected: !_showBestValue,
                    onTap: () => setState(() => _showBestValue = false),
                  ),
                  const SizedBox(width: 8),
                  KitToggle(
                    label: 'Best value',
                    selected: _showBestValue,
                    onTap: () => setState(() => _showBestValue = true),
                  ),
                ],
              ),
            ),

          // Kit items
          ...displayItems.map((item) => _buildKitRow(item)),

          // Shopping checklist link
          if (hobby.starterKit.isNotEmpty) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => context.push('/shopping/${hobby.id}'),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(AppIcons.shoppingList,
                      size: 14, color: AppColors.coral),
                  const SizedBox(width: 6),
                  Text('Open Shopping Checklist',
                      style: AppTypography.sansTiny
                          .copyWith(color: AppColors.coral)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildKitRow(KitItem item) {
    return GestureDetector(
      onTap: () => _openAffiliateLink(item),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 44,
                height: 44,
                child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: item.imageUrl!,
                        fit: BoxFit.cover,
                        memCacheWidth: 88,
                        placeholder: (_, __) =>
                            Container(color: AppColors.surfaceElevated),
                        errorWidget: (_, __, ___) => Container(
                          color: AppColors.surfaceElevated,
                          child: const Icon(Icons.image_outlined,
                              size: 16, color: AppColors.textWhisper),
                        ),
                      )
                    : Container(
                        color: AppColors.surfaceElevated,
                        child: Icon(
                          item.isOptional
                              ? Icons.add_circle_outline
                              : Icons.check_circle_outline,
                          size: 18,
                          color: AppColors.textWhisper,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name,
                      style: AppTypography.sansBodySmall.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  if (item.isOptional)
                    Text('Optional',
                        style: AppTypography.sansTiny
                            .copyWith(color: AppColors.textMuted)),
                ],
              ),
            ),
            if (item.cost > 0)
              Text('CHF ${item.cost}',
                  style: AppTypography.monoBadge.copyWith(
                    color: AppColors.coral,
                    fontWeight: FontWeight.w700,
                  ))
            else
              Text('FREE',
                  style: AppTypography.monoBadge.copyWith(
                    color: AppColors.sage,
                    fontWeight: FontWeight.w700,
                  )),
            const SizedBox(width: 6),
            const Icon(Icons.open_in_new_rounded,
                size: 12, color: AppColors.textWhisper),
          ],
        ),
      ),
    );
  }
}

/// Toggle pill for Minimum / Best Value kit filter.
class KitToggle extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const KitToggle({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Motion.fast,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.coral.withValues(alpha: 0.12)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(Spacing.radiusBadge),
          border: Border.all(
            color: selected ? AppColors.coral : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.sansTiny.copyWith(
            color: selected ? AppColors.coral : AppColors.textSecondary,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
