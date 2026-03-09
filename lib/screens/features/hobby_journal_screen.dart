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
import '../../providers/subscription_provider.dart';
import '../../components/pro_upgrade_sheet.dart';
import '../../components/glass_card.dart';

/// Hobby Journal — timestamped entries with photos, filter tabs, and timeline.
class HobbyJournalScreen extends ConsumerStatefulWidget {
  const HobbyJournalScreen({super.key});

  @override
  ConsumerState<HobbyJournalScreen> createState() => _HobbyJournalScreenState();
}

class _HobbyJournalScreenState extends ConsumerState<HobbyJournalScreen> {
  int _filterIndex = 0;
  static const _filters = ['All Entries', 'Photos', 'Notes', 'Milestones'];

  List<JournalEntry> _applyFilter(List<JournalEntry> entries) {
    switch (_filterIndex) {
      case 1: return entries.where((e) => e.photoUrl != null).toList();
      case 2: return entries.where((e) => e.photoUrl == null).toList();
      case 3: return entries.where((e) => e.text.length > 100).toList();
      default: return entries;
    }
  }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(journalProvider);
    final sortedEntries = List<JournalEntry>.from(entries)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final filtered = _applyFilter(sortedEntries);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),

            // Filter tabs
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
              child: SizedBox(
                height: 32,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 6),
                  itemBuilder: (context, i) {
                    final isSelected = i == _filterIndex;
                    return GestureDetector(
                      onTap: () => setState(() => _filterIndex = i),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.coral : AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(Spacing.radiusBadge),
                        ),
                        child: Text(
                          _filters[i],
                          style: AppTypography.caption.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Entry list
            Expanded(
              child: filtered.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        return _JournalEntryCard(entry: filtered[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEntrySheet(context, ref),
        backgroundColor: AppColors.coral,
        foregroundColor: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Spacing.radiusButton),
        ),
        child: const Icon(Icons.add, size: 28),
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
            child: const Icon(Icons.arrow_back,
                size: 20, color: AppColors.textSecondary),
          ),
          const Spacer(),
          Text('Hobby Journal', style: AppTypography.title.copyWith(fontSize: 17)),
          const Spacer(),
          GestureDetector(
            onTap: () {
              final isPro = ref.read(isProProvider);
              if (!isPro) {
                showProUpgrade(context, 'Export your journal as PDF with Pro.');
              }
              // TODO: implement PDF export for Pro users
            },
            child: Stack(
              children: [
                const Icon(Icons.ios_share_rounded, size: 20, color: AppColors.textSecondary),
                if (!ref.watch(isProProvider))
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.coral,
                        border: Border.all(color: AppColors.background, width: 1),
                      ),
                      child: const Icon(Icons.lock, size: 7, color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(AppIcons.journal, size: 48, color: AppColors.border),
          const SizedBox(height: 16),
          Text(
            'No journal entries yet',
            style: AppTypography.title.copyWith(fontSize: 17, color: AppColors.textSecondary),
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
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
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
                MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom + 24,
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
                        color: AppColors.textWhisper,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text('New Entry', style: AppTypography.title),
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
                                  : AppColors.surfaceElevated,
                              borderRadius:
                                  BorderRadius.circular(Spacing.radiusBadge),
                            ),
                            child: Text(
                              hobby.title,
                              style: AppTypography.caption.copyWith(
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textPrimary,
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
                        color: AppColors.textMuted,
                      ),
                      filled: true,
                      fillColor: AppColors.surface,
                      contentPadding: const EdgeInsets.all(14),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(Spacing.radiusInput),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(Spacing.radiusInput),
                        borderSide: const BorderSide(color: AppColors.border),
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

                  const SizedBox(height: 12),

                  // Photo button — locked for free users
                  GestureDetector(
                    onTap: () {
                      final isPro = ref.read(isProProvider);
                      if (!isPro) {
                        showProUpgrade(context, 'Add photos to your journal entries with Pro.');
                      }
                      // TODO: implement photo picker for Pro users
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(Spacing.radiusInput),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stack(
                            children: [
                              Icon(AppIcons.camera, size: 18, color: AppColors.textSecondary),
                              if (!ref.read(isProProvider))
                                Positioned(
                                  right: -2,
                                  bottom: -2,
                                  child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.coral,
                                      border: Border.all(color: AppColors.surface, width: 1),
                                    ),
                                    child: const Icon(Icons.lock, size: 7, color: Colors.white),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Add photo',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

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

    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: Spacing.radiusCard,
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
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(Spacing.radiusBadge),
                ),
                child: Text(
                  hobbyName,
                  style: AppTypography.sansTiny.copyWith(
                    color: AppColors.textSecondary,
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
            style: AppTypography.body.copyWith(
              color: AppColors.textSecondary,
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
                  color: AppColors.surfaceElevated,
                  child: Center(
                    child: Icon(AppIcons.camera, size: 28, color: AppColors.textMuted),
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  height: 160,
                  color: AppColors.surfaceElevated,
                  child: Center(
                    child: Icon(AppIcons.image, size: 28, color: AppColors.textMuted),
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
