import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/social.dart';
import '../../providers/feature_providers.dart';
import '../../providers/hobby_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_icons.dart';
import '../../theme/app_typography.dart';
import '../../theme/spacing.dart';

/// Hobby Journal — timestamped journal entries with optional photos and add sheet.
class HobbyJournalScreen extends ConsumerWidget {
  const HobbyJournalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(journalProvider);
    final sortedEntries = List<JournalEntry>.from(entries)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────
            _buildHeader(context),

            // ── Entry list ──────────────────────────
            Expanded(
              child: sortedEntries.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 80),
                      itemCount: sortedEntries.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        return _JournalEntryCard(entry: sortedEntries[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEntrySheet(context, ref),
        backgroundColor: AppColors.coral,
        foregroundColor: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Spacing.radiusButton),
        ),
        icon: Icon(AppIcons.edit, size: 20),
        label: Text('Add Entry', style: AppTypography.sansCta),
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
          Text('Hobby Journal', style: AppTypography.serifHeading),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(AppIcons.journal, size: 48, color: AppColors.sandDark),
          const SizedBox(height: 16),
          Text(
            'No journal entries yet',
            style: AppTypography.sansSection.copyWith(color: AppColors.driftwood),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the button below to record your first entry.',
            style: AppTypography.sansBodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  //  ADD ENTRY BOTTOM SHEET
  // ═══════════════════════════════════════════════════════

  void _showAddEntrySheet(BuildContext context, WidgetRef ref) {
    final textController = TextEditingController();
    String? selectedHobbyId;
    final hobbies = ref.read(hobbyListProvider).valueOrNull ?? [];
    if (hobbies.isNotEmpty) {
      selectedHobbyId = hobbies.first.id;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Spacing.radiusCard),
        ),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                20,
                24,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.sandDark,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text('New Entry', style: AppTypography.serifSubheading),
                  const SizedBox(height: 16),

                  // Hobby selector
                  Text('Hobby', style: AppTypography.sansLabel),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: hobbies.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final hobby = hobbies[index];
                        final isSelected = hobby.id == selectedHobbyId;
                        return GestureDetector(
                          onTap: () {
                            setSheetState(() {
                              selectedHobbyId = hobby.id;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.coral
                                  : AppColors.sand,
                              borderRadius:
                                  BorderRadius.circular(Spacing.radiusBadge),
                            ),
                            child: Text(
                              hobby.title,
                              style: AppTypography.sansCaption.copyWith(
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.nearBlack,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Text field
                  Text('What happened?', style: AppTypography.sansLabel),
                  const SizedBox(height: 8),
                  TextField(
                    controller: textController,
                    maxLines: 4,
                    style: AppTypography.sansBody,
                    decoration: InputDecoration(
                      hintText: 'Describe your session...',
                      hintStyle: AppTypography.sansBodySmall.copyWith(
                        color: AppColors.warmGray,
                      ),
                      filled: true,
                      fillColor: AppColors.warmWhite,
                      contentPadding: const EdgeInsets.all(14),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(Spacing.radiusInput),
                        borderSide: const BorderSide(color: AppColors.sandDark),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(Spacing.radiusInput),
                        borderSide: const BorderSide(color: AppColors.sandDark),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(Spacing.radiusInput),
                        borderSide: const BorderSide(
                          color: AppColors.coral,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    height: Spacing.buttonPrimaryHeight,
                    child: ElevatedButton(
                      onPressed: () {
                        final text = textController.text.trim();
                        if (text.isEmpty || selectedHobbyId == null) return;

                        final entry = JournalEntry(
                          id: 'j_${DateTime.now().millisecondsSinceEpoch}',
                          hobbyId: selectedHobbyId!,
                          text: text,
                          createdAt: DateTime.now(),
                        );
                        ref.read(journalProvider.notifier).addEntry(entry);
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.coral,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(Spacing.radiusButton),
                        ),
                      ),
                      child: Text('Save Entry', style: AppTypography.sansCta),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════
//  JOURNAL ENTRY CARD
// ═══════════════════════════════════════════════════════

class _JournalEntryCard extends ConsumerWidget {
  final JournalEntry entry;

  const _JournalEntryCard({required this.entry});

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${months[date.month - 1]} ${date.day}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hobby = ref.watch(hobbyByIdProvider(entry.hobbyId)).valueOrNull;
    final hobbyName = hobby?.title ?? entry.hobbyId;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warmWhite,
        borderRadius: BorderRadius.circular(Spacing.radiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date header + hobby pill
          Row(
            children: [
              Text(
                _formatDate(entry.createdAt),
                style: AppTypography.monoCaption,
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.sand,
                  borderRadius: BorderRadius.circular(Spacing.radiusBadge),
                ),
                child: Text(
                  hobbyName,
                  style: AppTypography.sansTiny.copyWith(
                    color: AppColors.driftwood,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Text content
          Text(
            entry.text,
            style: AppTypography.sansBody.copyWith(
              color: AppColors.espresso,
              height: 1.6,
            ),
          ),

          // Photo thumbnail
          if (entry.photoUrl != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(Spacing.radiusTile),
              child: CachedNetworkImage(
                imageUrl: entry.photoUrl!,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  height: 160,
                  color: AppColors.sand,
                  child: Center(
                    child: Icon(AppIcons.camera, size: 28, color: AppColors.warmGray),
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  height: 160,
                  color: AppColors.sand,
                  child: Center(
                    child: Icon(AppIcons.image, size: 28, color: AppColors.warmGray),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
