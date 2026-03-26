import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../components/glass_card.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

// ═══════════════════════════════════════════════════════
//  JOURNAL PREVIEW CARD
// ═══════════════════════════════════════════════════════

class JournalEntryTile extends StatelessWidget {
  final dynamic entry;
  final VoidCallback onTap;

  const JournalEntryTile({super.key, required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final date = entry.createdAt as DateTime;
    final daysAgo = DateTime.now().difference(date).inDays;
    final dateLabel = daysAgo == 0
        ? 'Today'
        : (daysAgo == 1 ? 'Yesterday' : '$daysAgo days ago');
    final hasPhoto = (entry.photoUrl as String?) != null &&
        (entry.photoUrl as String).isNotEmpty;

    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo thumbnail or icon
          if (hasPhoto)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: entry.photoUrl as String,
                width: 44,
                height: 44,
                fit: BoxFit.cover,
                memCacheWidth: 88,
              ),
            )
          else
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(MdiIcons.noteEditOutline,
                  size: 18, color: AppColors.textMuted),
            ),
          const SizedBox(width: 12),

          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.text as String,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption
                      .copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(dateLabel,
                    style: AppTypography.caption.copyWith(
                        color: AppColors.textMuted, fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
