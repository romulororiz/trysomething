import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/social.dart';
import '../../providers/feature_providers.dart';
import '../../providers/hobby_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/hobby.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/spacing.dart';
import '../../providers/subscription_provider.dart';
import '../../components/glass_card.dart';
import '../../components/app_background.dart';

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
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
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
                        final entry = filtered[index];
                        return _DismissibleJournalCard(
                          entry: entry,
                          onDismissed: () {
                            ref.read(journalProvider.notifier).removeEntry(entry.id);
                            final messenger = ScaffoldMessenger.of(context);
                            messenger.clearSnackBars();
                            final controller = messenger.showSnackBar(
                              SnackBar(
                                content: const Text('Entry deleted',
                                    style: TextStyle(color: Colors.white)),
                                backgroundColor: AppColors.surfaceElevated,
                                behavior: SnackBarBehavior.floating,
                                dismissDirection: DismissDirection.down,
                                duration: const Duration(days: 365), // managed manually
                                action: SnackBarAction(
                                  label: 'Undo',
                                  textColor: AppColors.coral,
                                  onPressed: () {
                                    ref.read(journalProvider.notifier).addEntry(entry);
                                  },
                                ),
                              ),
                            );
                            // Force dismiss after 2 seconds
                            Future.delayed(const Duration(seconds: 2), () {
                              controller.close();
                            });
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      ),
      floatingActionButton: SizedBox(
        width: 48,
        height: 48,
        child: FloatingActionButton(
          onPressed: () => _showAddEntrySheet(context, ref),
          backgroundColor: AppColors.coral,
          foregroundColor: Colors.white,
          elevation: 3,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, size: 22),
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
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.glassBackground,
              ),
              child: const Icon(Icons.arrow_back,
                  size: 20, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text('Journal',
                style: AppTypography.display.copyWith(fontSize: 24)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.coral.withValues(alpha: 0.08),
              ),
              child: const Icon(Icons.auto_stories_rounded,
                  size: 30, color: AppColors.coral),
            ),
            const SizedBox(height: Spacing.xl),
            Text(
              'Your story starts here',
              style: AppTypography.title.copyWith(fontSize: 18),
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              'Your reflections will appear here after each session. '
              'Take a moment to notice what worked and what felt hard.',
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(
                color: AppColors.textMuted,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  //  ADD ENTRY BOTTOM SHEET
  // ═══════════════════════════════════════════════════════

  void _showAddEntrySheet(BuildContext context, WidgetRef ref) {
    final textController = TextEditingController();
    // null = general entry (no hobby attached)
    String? selectedHobbyId;

    // Only show hobbies the user is actively trying or has active
    final userHobbies = ref.read(userHobbiesProvider);
    final activeUserHobbies = userHobbies.entries.where(
      (e) => e.value.status == HobbyStatus.trying || e.value.status == HobbyStatus.active,
    ).toList();
    final allHobbies = ref.read(hobbyListProvider).valueOrNull ?? [];
    final hobbies = allHobbies.where(
      (h) => activeUserHobbies.any((uh) => uh.key == h.id),
    ).toList();

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

                  // Hobby selector (General + active hobbies)
                  Text('Hobby', style: AppTypography.sansLabel),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: hobbies.length + 1, // +1 for General
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        // First chip = General (no hobby)
                        if (index == 0) {
                          final isSelected = selectedHobbyId == null;
                          return GestureDetector(
                            onTap: () => setSheetState(() => selectedHobbyId = null),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.coral : AppColors.surfaceElevated,
                                borderRadius: BorderRadius.circular(Spacing.radiusBadge),
                              ),
                              child: Text(
                                'General',
                                style: AppTypography.caption.copyWith(
                                  color: isSelected ? Colors.white : AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        }
                        final hobby = hobbies[index - 1];
                        final isSelected = hobby.id == selectedHobbyId;
                        return GestureDetector(
                          onTap: () => setSheetState(() => selectedHobbyId = hobby.id),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.coral : AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(Spacing.radiusBadge),
                            ),
                            child: Text(
                              hobby.title,
                              style: AppTypography.caption.copyWith(
                                color: isSelected ? Colors.white : AppColors.textPrimary,
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
                        context.push('/pro');
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
                              const Icon(Icons.camera_alt_outlined, size: 18, color: AppColors.textSecondary),
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
                        if (text.isEmpty) return;

                        final entry = JournalEntry(
                          id: 'j_${DateTime.now().millisecondsSinceEpoch}',
                          hobbyId: selectedHobbyId,
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
//  SESSION REFLECTION DETECTION
// ═══════════════════════════════════════════════════════

/// Reflection emoji prefixes written by the session flow.
/// Entries whose text starts with one of these are session reflections.
const _reflectionPrefixes = [
  '\u2764\uFE0F',   // ❤️ Loved it
  '\uD83D\uDC4C',   // 👌 It was okay
  '\u2601\uFE0F',   // ☁️ Struggled
];

/// Returns the reflection emoji if [text] is a session reflection, else null.
String? _sessionReflectionEmoji(String text) {
  for (final prefix in _reflectionPrefixes) {
    if (text.startsWith(prefix)) return prefix;
  }
  return null;
}

/// Strips the reflection prefix ("❤️ Loved it — ") from the display text.
String _stripReflectionPrefix(String text) {
  // Pattern: "<emoji> <label> — <user text>"
  final dashIndex = text.indexOf('\u2014'); // em dash
  if (dashIndex != -1 && dashIndex + 2 < text.length) {
    return text.substring(dashIndex + 2); // skip " — "
  }
  return text;
}

// ═══════════════════════════════════════════════════════
//  DISMISSIBLE WRAPPER
// ═══════════════════════════════════════════════════════

/// Custom swipe-to-delete that reveals a delete button behind the card.
/// The card slides left with its right-side border radius flattening to 0,
/// creating a seamless join with the delete zone's rounded right corners.
/// Uses GestureDetector + AnimationController for full visual control.
class _DismissibleJournalCard extends ConsumerStatefulWidget {
  final JournalEntry entry;
  final VoidCallback onDismissed;

  const _DismissibleJournalCard({
    required this.entry,
    required this.onDismissed,
  });

  @override
  ConsumerState<_DismissibleJournalCard> createState() =>
      _DismissibleJournalCardState();
}

class _DismissibleJournalCardState
    extends ConsumerState<_DismissibleJournalCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  static const double _deleteWidth = 80.0;
  static const double _radius = 20.0;
  double _dragExtent = 0;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    _dragExtent += details.delta.dx;
    // Allow dragging beyond the delete width for the "pull to trigger" feel
    _dragExtent = _dragExtent.clamp(-_deleteWidth * 1.5, 0.0);
    _controller.value = (-_dragExtent / _deleteWidth).clamp(0.0, 1.0);
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;

    // If dragged far enough or fast enough → trigger delete dialog + spring back
    if (_controller.value >= 0.9 || velocity < -800) {
      // Spring back immediately
      _springBack();
      // Show delete dialog
      _onDelete();
    } else {
      // Not enough drag — spring back
      _springBack();
    }
  }

  void _springBack() {
    _controller.animateTo(0.0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic);
    _isOpen = false;
    _dragExtent = 0;
  }

  void _close() {
    _controller.animateTo(0.0, curve: Curves.easeOut);
    _isOpen = false;
    _dragExtent = 0;
  }

  void _onDelete() {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Spacing.radiusTile),
        ),
        title: Text(
          'Delete entry?',
          style: AppTypography.title.copyWith(fontSize: 18),
        ),
        content: Text(
          'This journal entry will be permanently removed.',
          style: AppTypography.body.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Cancel',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Delete',
              style: AppTypography.caption.copyWith(
                color: const Color(0xFFE57373),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        widget.onDismissed();
      } else {
        _close();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      onTap: _isOpen ? _close : null,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final slideOffset = -_controller.value * _deleteWidth;
          // Right-side radius flattens from 20 → 0 as card slides open
          final rightRadius = Radius.circular(_radius * (1 - _controller.value));
          const leftRadius = Radius.circular(_radius);

          return Stack(
            children: [
              // Delete zone — bottom layer, fixed width at right edge
              if (_controller.value > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  width: _deleteWidth,
                  child: GestureDetector(
                    onTap: _onDelete,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFE57373),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(_radius),
                          bottomRight: Radius.circular(_radius),
                        ),
                      ),
                      child: Center(
                        child: Opacity(
                          opacity: _controller.value,
                          child: const Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              // Card — top layer, slides left to reveal delete behind it
              Transform.translate(
                offset: Offset(slideOffset, 0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.only(
                      topLeft: leftRadius,
                      bottomLeft: leftRadius,
                      topRight: rightRadius,
                      bottomRight: rightRadius,
                    ),
                    border: Border.all(
                      color: AppColors.glassBorder,
                      width: 0.5,
                    ),
                  ),
                  child: _JournalEntryCard.buildContent(
                    context,
                    ref,
                    widget.entry,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  JOURNAL ENTRY CARD
// ═══════════════════════════════════════════════════════

class _JournalEntryCard extends ConsumerWidget {
  final JournalEntry entry;

  const _JournalEntryCard({required this.entry});

  static String _formatDate(DateTime date) {
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

  /// Builds the inner content column for a journal entry.
  /// Used by both the standalone GlassCard widget and the swipeable variant.
  static Widget buildContent(
    BuildContext context,
    WidgetRef ref,
    JournalEntry entry,
  ) {
    final hobbyName = entry.hobbyId != null
        ? (ref.watch(hobbyByIdProvider(entry.hobbyId!)).valueOrNull?.title ?? entry.hobbyId!)
        : 'General';

    final reflectionEmoji = _sessionReflectionEmoji(entry.text);
    final isSessionEntry = reflectionEmoji != null;
    final displayText = isSessionEntry
        ? _stripReflectionPrefix(entry.text)
        : entry.text;

    // Coach CTA is only shown when the entry has an associated hobby
    final showCoachCta = entry.hobbyId != null && entry.hobbyId!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date header + hobby pill + session badge
        Row(
          children: [
            Text(
              _formatDate(entry.createdAt),
              style: AppTypography.caption.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(width: Spacing.sm),
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
            const Spacer(),
            // Session reflection badge
            if (isSessionEntry)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.coral.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(Spacing.radiusBadge),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      reflectionEmoji,
                      style: const TextStyle(fontSize: 11),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Session',
                      style: AppTypography.sansTiny.copyWith(
                        color: AppColors.coral,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),

        const SizedBox(height: Spacing.md),

        // Text content
        Text(
          displayText,
          style: AppTypography.body.copyWith(
            color: AppColors.textSecondary,
            height: 1.6,
          ),
        ),

        // Photo thumbnail
        if (entry.photoUrl != null) ...[
          const SizedBox(height: Spacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(Spacing.radiusTile),
            child: CachedNetworkImage(
              imageUrl: entry.photoUrl!,
              height: 160,
              width: double.infinity,
              memCacheWidth: 600,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                height: 160,
                color: AppColors.surfaceElevated,
                child: const Center(
                  child: Icon(Icons.camera_alt_outlined, size: 28, color: AppColors.textMuted),
                ),
              ),
              errorWidget: (_, __, ___) => Container(
                height: 160,
                color: AppColors.surfaceElevated,
                child: const Center(
                  child: Icon(Icons.image_outlined, size: 28, color: AppColors.textMuted),
                ),
              ),
            ),
          ),
        ],

        // ── Per-entry coach CTA ──
        if (showCoachCta) ...[
          const SizedBox(height: Spacing.md),
          GestureDetector(
            onTap: () {
              context.push('/coach/${entry.hobbyId}', extra: {
                'message': 'Let\'s discuss this journal entry.',
                'mode': 'momentum',
                'autoSend': true,
                'focusEntryId': entry.id,
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.glassBackground,
                borderRadius: BorderRadius.circular(Spacing.radiusBadge),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.auto_awesome,
                      size: 12, color: AppColors.coral),
                  const SizedBox(width: 6),
                  Text(
                    'Discuss with coach',
                    style: AppTypography.sansTiny.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSessionEntry = _sessionReflectionEmoji(entry.text) != null;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: Spacing.radiusCard,
      borderColor: isSessionEntry
          ? AppColors.coral.withValues(alpha: 0.15)
          : null,
      child: buildContent(context, ref, entry),
    );
  }
}
