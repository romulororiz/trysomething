import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../providers/hobby_provider.dart';
import '../../providers/feature_providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_icons.dart';
import '../../theme/spacing.dart';

/// Personal notes screen for a specific hobby.
/// Shows the hobby's roadmap steps as a list, each with an expandable
/// text field for personal notes. Uses notesProvider for persistence.
class PersonalNotesScreen extends ConsumerWidget {
  final String hobbyId;

  const PersonalNotesScreen({super.key, required this.hobbyId});

  /// Tracks which hobbyIds we've already triggered a load for.
  static final _loadedHobbies = <String>{};

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (_loadedHobbies.add(hobbyId)) {
      ref.read(notesProvider.notifier).loadForHobby(hobbyId);
    }
    final hobby = ref.watch(hobbyByIdProvider(hobbyId)).valueOrNull;
    final topPad = MediaQuery.of(context).padding.top;
    final hobbyName = hobby?.title ?? hobbyId;
    final steps = hobby?.roadmapSteps ?? [];

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: CustomScrollView(
        slivers: [
          // ── Header ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: topPad + 8, left: 16, right: 16),
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
                        border: Border.all(color: AppColors.sandDark),
                      ),
                      child: const Center(
                        child: Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.nearBlack),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(AppIcons.note, size: 22, color: AppColors.coral),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'My Notes',
                      style: AppTypography.sansSection,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Title ───────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 6),
              child: Text(
                'My Notes \u2014 $hobbyName',
                style: AppTypography.serifHeading,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: Text(
                'Jot down thoughts, tips, and reflections for each step.',
                style: AppTypography.sansBodySmall,
              ),
            ),
          ),

          // ── Steps with Notes ────────────────────────────
          if (steps.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: Center(
                  child: Column(
                    children: [
                      Icon(MdiIcons.noteRemoveOutline, size: 44, color: AppColors.warmGray),
                      const SizedBox(height: 12),
                      Text(
                        'No roadmap steps for this hobby.',
                        style: AppTypography.sansBody.copyWith(color: AppColors.driftwood),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final step = steps[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _StepNoteCard(
                        hobbyId: hobbyId,
                        stepId: step.id,
                        stepNumber: index + 1,
                        stepTitle: step.title,
                        stepDescription: step.description,
                        estimatedMinutes: step.estimatedMinutes,
                        milestone: step.milestone,
                      ),
                    );
                  },
                  childCount: steps.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A single roadmap step card with an expandable note editor.
class _StepNoteCard extends ConsumerStatefulWidget {
  final String hobbyId;
  final String stepId;
  final int stepNumber;
  final String stepTitle;
  final String stepDescription;
  final int estimatedMinutes;
  final String? milestone;

  const _StepNoteCard({
    required this.hobbyId,
    required this.stepId,
    required this.stepNumber,
    required this.stepTitle,
    required this.stepDescription,
    required this.estimatedMinutes,
    this.milestone,
  });

  @override
  ConsumerState<_StepNoteCard> createState() => _StepNoteCardState();
}

class _StepNoteCardState extends ConsumerState<_StepNoteCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  bool _showSaved = false;
  late final TextEditingController _textController;

  late final AnimationController _expandController;
  late final Animation<double> _expandAnimation;
  late final Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();

    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeOutCubic,
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 0.5).animate(_expandAnimation);
  }

  @override
  void dispose() {
    _textController.dispose();
    _expandController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        // Load existing note into text field
        final notes = ref.read(notesProvider);
        _textController.text = notes[widget.stepId] ?? '';
        _showSaved = false;
        _expandController.forward();
      } else {
        _expandController.reverse();
      }
    });
  }

  void _saveNote() {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ref.read(notesProvider.notifier).deleteNote(widget.hobbyId, widget.stepId);
    } else {
      ref.read(notesProvider.notifier).saveNote(widget.hobbyId, widget.stepId, text);
    }
    setState(() {
      _showSaved = true;
    });
    // Hide "Saved" confirmation after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showSaved = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final notes = ref.watch(notesProvider);
    final hasNote = (notes[widget.stepId] ?? '').isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.warmWhite,
        borderRadius: BorderRadius.circular(Spacing.radiusTile),
        border: Border.all(
          color: _expanded
              ? AppColors.coral.withValues(alpha: 0.3)
              : hasNote
                  ? AppColors.sage.withValues(alpha: 0.3)
                  : AppColors.sandDark,
        ),
        boxShadow: _expanded ? Spacing.subtleShadow : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // ── Step Header ─────────────────────────────
          GestureDetector(
            onTap: _toggle,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step number circle
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: hasNote ? AppColors.sagePale : AppColors.coralPale,
                    ),
                    child: Center(
                      child: hasNote
                          ? Icon(MdiIcons.check, size: 16, color: AppColors.sage)
                          : Text(
                              '${widget.stepNumber}',
                              style: AppTypography.monoBadge.copyWith(
                                color: AppColors.coral,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Step info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.stepTitle,
                          style: AppTypography.sansLabel.copyWith(
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(MdiIcons.clockOutline, size: 12, color: AppColors.warmGray),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.estimatedMinutes} min',
                              style: AppTypography.monoCaption,
                            ),
                            if (widget.milestone != null) ...[
                              const SizedBox(width: 10),
                              Icon(MdiIcons.flagVariantOutline, size: 12, color: AppColors.amber),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  widget.milestone!,
                                  style: AppTypography.sansTiny.copyWith(
                                    color: AppColors.amber,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (hasNote && !_expanded) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(AppIcons.note, size: 12, color: AppColors.sage),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  notes[widget.stepId]!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.sansTiny.copyWith(
                                    color: AppColors.sage,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Expand chevron
                  RotationTransition(
                    turns: _rotationAnimation,
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.driftwood,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Expandable Note Editor ──────────────────
          SizeTransition(
            sizeFactor: _expandAnimation,
            axisAlignment: -1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(height: 1, color: AppColors.sandDark),

                // Step description
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Text(
                    widget.stepDescription,
                    style: AppTypography.sansBodySmall.copyWith(
                      color: AppColors.driftwood,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),

                // Text field
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.cream,
                      borderRadius: BorderRadius.circular(Spacing.radiusInput),
                      border: Border.all(color: AppColors.sandDark),
                    ),
                    child: TextField(
                      controller: _textController,
                      maxLines: 4,
                      minLines: 2,
                      style: AppTypography.sansBody.copyWith(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Write your notes here...',
                        hintStyle: AppTypography.sansBodySmall.copyWith(
                          color: AppColors.warmGray,
                        ),
                        contentPadding: const EdgeInsets.all(12),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),

                // Save button row
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                  child: Row(
                    children: [
                      // Save button
                      GestureDetector(
                        onTap: _saveNote,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.coral,
                            borderRadius: BorderRadius.circular(Spacing.radiusButton),
                          ),
                          child: Text(
                            'Save',
                            style: AppTypography.sansLabel.copyWith(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // "Saved" confirmation
                      AnimatedOpacity(
                        opacity: _showSaved ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: Row(
                          children: [
                            Icon(MdiIcons.check, size: 16, color: AppColors.sage),
                            const SizedBox(width: 4),
                            Text(
                              'Saved \u2713',
                              style: AppTypography.sansLabel.copyWith(
                                color: AppColors.sage,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Delete note button (if note exists)
                      if (hasNote)
                        GestureDetector(
                          onTap: () {
                            ref.read(notesProvider.notifier).deleteNote(widget.hobbyId, widget.stepId);
                            _textController.clear();
                            setState(() {
                              _showSaved = false;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.rosePale,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              MdiIcons.trashCanOutline,
                              size: 16,
                              color: AppColors.rose,
                            ),
                          ),
                        ),
                    ],
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
