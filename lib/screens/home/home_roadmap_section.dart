import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../router.dart' show rootNavigatorKey;
import '../session/hobby_completion_screen.dart';
import '../../components/app_overlays.dart';
import '../../models/hobby.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/spacing.dart';

// ═══════════════════════════════════════════════════════
//  ROADMAP JOURNEY
// ═══════════════════════════════════════════════════════

const _tealBg = Color(0x0A068BA8);
const _tealBgActive = Color(0x14068BA8);
const _tealBorder = Color(0x14068BA8);
const _tealBorderActive = Color(0x33068BA8);
const _tealText = Color(0x805CB8C9);
const _tealTextBright = Color(0xFF5CB8C9);
const _tealBar = Color(0x995CB8C9);

class RoadmapJourney extends ConsumerStatefulWidget {
  final Hobby hobby;
  final Set<String> completedStepIds;
  final String? defaultActiveStepId;

  const RoadmapJourney({
    super.key,
    required this.hobby,
    required this.completedStepIds,
    this.defaultActiveStepId,
  });

  @override
  ConsumerState<RoadmapJourney> createState() => _RoadmapJourneyState();
}

class _RoadmapJourneyState extends ConsumerState<RoadmapJourney> {
  String? _expandedTipStepId;
  String? _focusedStepId;

  @override
  void initState() {
    super.initState();
    _focusedStepId = widget.defaultActiveStepId;
  }

  @override
  void didUpdateWidget(covariant RoadmapJourney old) {
    super.didUpdateWidget(old);
    if (_focusedStepId != null &&
        widget.completedStepIds.contains(_focusedStepId) &&
        !old.completedStepIds.contains(_focusedStepId!)) {
      for (final step in widget.hobby.roadmapSteps) {
        if (!widget.completedStepIds.contains(step.id)) {
          setState(() {
            _focusedStepId = step.id;
            _expandedTipStepId = null;
          });
          return;
        }
      }
      setState(() => _focusedStepId = null);
    }
  }

  void _setFocusedStep(String stepId) {
    if (_focusedStepId == stepId) return;
    HapticFeedback.selectionClick();
    setState(() {
      _focusedStepId = stepId;
      _expandedTipStepId = null;
    });
  }

  /// Confirmation sheet before uncompleting a step.
  void _showUncompleteConfirmation(BuildContext context, RoadmapStep step) {
    showAppSheet(
      context: context,
      title: 'Mark as incomplete?',
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This will remove your progress for this step. Are you sure?',
              style: AppTypography.body.copyWith(
                color: AppColors.textMuted,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(ctx).pop(),
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.glassBackground,
                        borderRadius:
                            BorderRadius.circular(Spacing.radiusButton),
                        border: Border.all(
                            color: AppColors.glassBorder, width: 0.5),
                      ),
                      child: Center(
                        child: Text(
                          'Cancel',
                          style: AppTypography.body.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      Navigator.of(ctx).pop();
                      final hobbyCompleted = await ref
                          .read(userHobbiesProvider.notifier)
                          .toggleStep(widget.hobby.id, step.id);
                      if (hobbyCompleted && context.mounted) {
                        rootNavigatorKey.currentState?.push(
                          HobbyCompletionScreen.route(
                            hobbyId: widget.hobby.id,
                            hobbyTitle: widget.hobby.title,
                          ),
                        );
                      }
                    },
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.textMuted.withValues(alpha: 0.15),
                        borderRadius:
                            BorderRadius.circular(Spacing.radiusButton),
                        border: Border.all(
                            color: AppColors.textMuted.withValues(alpha: 0.3),
                            width: 0.5),
                      ),
                      child: Center(
                        child: Text(
                          'Mark Incomplete',
                          style: AppTypography.body.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Bottom sheet for marking an incomplete step complete without a session.
  void _showMarkCompleteSheet(BuildContext context, RoadmapStep step) {
    showAppSheet(
      context: context,
      title: 'Mark as complete?',
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step context
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.glassBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.glassBorder, width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: AppTypography.body.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    step.description,
                    style: AppTypography.body.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'You can mark this step done if you\'ve already completed it outside the app.',
              style: AppTypography.body.copyWith(
                color: AppColors.textMuted,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            // Primary CTA: Start Session (coral)
            GestureDetector(
              onTap: () {
                Navigator.of(ctx).pop();
                HapticFeedback.lightImpact();
                final i = widget.hobby.roadmapSteps
                    .indexWhere((s) => s.id == step.id);
                final followingTitle = i + 1 < widget.hobby.roadmapSteps.length
                    ? widget.hobby.roadmapSteps[i + 1].title
                    : null;
                context.push(
                  '/session/${widget.hobby.id}/${step.id}',
                  extra: <String, dynamic>{
                    'hobbyTitle': widget.hobby.title,
                    'hobbyCategory': widget.hobby.category,
                    'stepTitle': step.title,
                    'stepDescription': step.description,
                    'stepInstructions': '',
                    'whatYouNeed': '',
                    'recommendedMinutes': step.estimatedMinutes,
                    'completionMode': step.effectiveMode,
                    'nextStepTitle': followingTitle,
                    'completionMessage': step.completionMessage,
                    'coachTip': step.coachTip,
                  },
                );
              },
              child: Container(
                width: double.infinity,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(Spacing.radiusButton),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'Start Session',
                    style: AppTypography.body.copyWith(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Secondary: Mark Complete (text-style)
            GestureDetector(
              onTap: () async {
                Navigator.of(ctx).pop();
                final hobbyCompleted = await ref
                    .read(userHobbiesProvider.notifier)
                    .toggleStep(widget.hobby.id, step.id);
                if (hobbyCompleted && context.mounted) {
                  rootNavigatorKey.currentState?.push(
                    HobbyCompletionScreen.route(
                      hobbyId: widget.hobby.id,
                      hobbyTitle: widget.hobby.title,
                    ),
                  );
                }
              },
              child: Container(
                width: double.infinity,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(Spacing.radiusButton),
                ),
                child: Center(
                  child: Text(
                    'Mark Complete',
                    style: AppTypography.body.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final steps = widget.hobby.roadmapSteps;
    final completed = widget.completedStepIds;
    final total = steps.length;
    final doneCount = completed.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('YOUR JOURNEY',
                style: AppTypography.overline
                    .copyWith(color: AppColors.textMuted)),
            const Spacer(),
            Text('$doneCount / $total',
                style: AppTypography.monoBadge
                    .copyWith(color: AppColors.textMuted)),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: total > 0 ? doneCount / total : 0,
            backgroundColor: AppColors.textWhisper,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
            minHeight: 3,
          ),
        ),
        const SizedBox(height: 20),
        ...List.generate(steps.length, (i) {
          final step = steps[i];
          final isCompleted = completed.contains(step.id);
          final isFocused = step.id == _focusedStepId && !isCompleted;
          final isLast = i == steps.length - 1;
          Color lineColor = AppColors.textWhisper;
          if (!isLast && isCompleted && completed.contains(steps[i + 1].id)) {
            lineColor = AppColors.success;
          }
          return _StepItem(
            key: ValueKey('step_${step.id}'),
            step: step,
            stepNumber: i + 1,
            isCompleted: isCompleted,
            isFocused: isFocused,
            isLast: isLast,
            lineColor: lineColor,
            hobby: widget.hobby,
            tipExpanded: _expandedTipStepId == step.id,
            onToggleTip: () => setState(() {
              _expandedTipStepId =
                  _expandedTipStepId == step.id ? null : step.id;
            }),
            onTap: () {
              if (isCompleted) {
                _showUncompleteConfirmation(context, step);
              } else if (!isFocused) {
                _setFocusedStep(step.id);
              } else {
                _showMarkCompleteSheet(context, step);
              }
            },
            staggerIndex: i,
          );
        }),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════
//  STEP ITEM
//
//  Architecture:
//  - IntrinsicHeight + CrossAxisAlignment.stretch so the
//    left rail line ALWAYS fills the full row height
//  - Right side: a single Column. Each expandable section
//    uses AnimatedSize → SizedBox.shrink() when hidden.
//    NO SizedBox(width: double.infinity) — that causes
//    layout conflicts during animation.
//  - Card background: AnimatedContainer wrapping the Column,
//    transitions decoration from BoxDecoration() to the coral card.
//  - Title row: simple. No nested Rows that can overflow.
//    "UP NEXT" + milestone shown ABOVE the title when focused.
// ═══════════════════════════════════════════════════════

class _StepItem extends ConsumerWidget {
  final RoadmapStep step;
  final int stepNumber;
  final bool isCompleted;
  final bool isFocused;
  final bool isLast;
  final Color lineColor;
  final Hobby hobby;
  final bool tipExpanded;
  final VoidCallback onToggleTip;
  final VoidCallback onTap;
  final int staggerIndex;

  const _StepItem({
    super.key,
    required this.step,
    required this.stepNumber,
    required this.isCompleted,
    required this.isFocused,
    required this.isLast,
    required this.lineColor,
    required this.hobby,
    required this.tipExpanded,
    required this.onToggleTip,
    required this.onTap,
    required this.staggerIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coachTip = step.coachTip;
    final completionMessage = step.completionMessage;
    final isFuture = !isCompleted && !isFocused;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Stack(clipBehavior: Clip.none, children: [
        if (!isLast)
          Positioned(
            left: 19,
            top: (isFocused ? 4.0 : 8.0) +
                (isFocused ? 36.0 : (isCompleted ? 26.0 : 22.0)),
            bottom: 2,
            width: 2,
            child: Container(color: lineColor),
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ═══ LEFT RAIL ═══
            SizedBox(
              width: 40,
              child: Column(
                children: [
                  SizedBox(height: isFocused ? 4 : 8),
                  // Node — instant color/size change (150ms)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeOut,
                    width: isFocused ? 36 : (isCompleted ? 26 : 22),
                    height: isFocused ? 36 : (isCompleted ? 26 : 22),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppColors.success
                          : isFocused
                              ? AppColors.accent
                              : Colors.transparent,
                      border: !isCompleted && !isFocused
                          ? Border.all(color: AppColors.textWhisper, width: 1.5)
                          : null,
                      shape: BoxShape.circle,
                      boxShadow: isFocused
                          ? [
                              BoxShadow(
                                  color:
                                      AppColors.accent.withValues(alpha: 0.4),
                                  blurRadius: 12)
                            ]
                          : isCompleted
                              ? [
                                  BoxShadow(
                                      color: AppColors.success
                                          .withValues(alpha: 0.2),
                                      blurRadius: 6)
                                ]
                              : null,
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(Icons.check_rounded,
                              size: 14, color: Colors.white)
                          : Text(
                              '$stepNumber',
                              style: TextStyle(
                                fontSize: isFocused ? 14 : 10,
                                fontWeight: FontWeight.w800,
                                color: isFocused
                                    ? Colors.white
                                    : AppColors.textMuted,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // ═══ RIGHT CONTENT — single AnimatedSize wraps everything ═══
            // ═══ RIGHT CONTENT ═══
            Expanded(
              child: AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                alignment: Alignment.topLeft,
                clipBehavior: Clip.hardEdge,
                child: Container(
                  padding: isFocused
                      ? const EdgeInsets.all(16)
                      : const EdgeInsets.symmetric(vertical: 8),
                  margin: isFocused
                      ? const EdgeInsets.only(top: 4, bottom: 8)
                      : EdgeInsets.zero,
                  decoration: isFocused
                      ? BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                              color: AppColors.accent.withValues(alpha: 0.18),
                              width: 1),
                        )
                      : null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // UP NEXT (focused only)
                      if (isFocused) ...[
                        Row(
                          children: [
                            Text('UP NEXT',
                                style: AppTypography.overline
                                    .copyWith(color: AppColors.accent)),
                            if (step.milestone != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.accent.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Text(
                                  '\u{1F3C6} ${step.milestone}',
                                  style: AppTypography.monoBadge.copyWith(
                                      color: AppColors.accent, fontSize: 9),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                      ],

                      // Title (always)
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              step.title,
                              style: isCompleted
                                  ? AppTypography.body.copyWith(
                                      color: AppColors.textMuted,
                                      decoration: TextDecoration.lineThrough,
                                      decorationColor: AppColors.textWhisper)
                                  : isFocused
                                      ? AppTypography.title
                                          .copyWith(fontSize: 17)
                                      : AppTypography.body.copyWith(
                                          color: AppColors.textSecondary,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500),
                            ),
                          ),
                          if (!isFocused &&
                              !isCompleted &&
                              step.milestone != null)
                            const Padding(
                              padding: EdgeInsets.only(left: 4),
                              child: Text('\u{1F3C6}',
                                  style: TextStyle(fontSize: 12)),
                            ),
                          if (!isFocused && isFuture && coachTip != null)
                            GestureDetector(
                              onTap: onToggleTip,
                              behavior: HitTestBehavior.opaque,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(10, 8, 4, 8),
                                child: Text('\u2726',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: tipExpanded
                                          ? _tealTextBright
                                          : const Color(0x665CB8C9),
                                    )),
                              ),
                            ),
                        ],
                      ),

                      // Description (focused only)
                      if (isFocused && step.description.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(step.description,
                            style: AppTypography.sansBodySmall
                                .copyWith(color: AppColors.textSecondary)),
                      ],

                      // Coach tip (focused only)
                      if (isFocused) ...[
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: onToggleTip,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: tipExpanded ? _tealBgActive : _tealBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: tipExpanded
                                      ? _tealBorderActive
                                      : _tealBorder,
                                  width: 1),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  const Text('\u2726',
                                      style: TextStyle(
                                          fontSize: 15, color: _tealText)),
                                  const SizedBox(width: 8),
                                  Text(
                                    tipExpanded
                                        ? 'Coach tip'
                                        : (coachTip != null
                                            ? 'Tap for a coach tip'
                                            : 'Coach tip coming soon'),
                                    style: AppTypography.sansTiny.copyWith(
                                      color: _tealText,
                                      fontWeight: tipExpanded
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                    ),
                                  ),
                                ]),
                                AnimatedSize(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOutCubic,
                                  alignment: Alignment.topLeft,
                                  clipBehavior: Clip.hardEdge,
                                  child: tipExpanded && coachTip != null
                                      ? Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: 2.5,
                                                height: 40,
                                                margin: const EdgeInsets.only(
                                                    left: 6, right: 14),
                                                decoration: BoxDecoration(
                                                    color: _tealBar,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            2)),
                                              ),
                                              Expanded(
                                                child: Text(coachTip,
                                                    style: AppTypography
                                                        .sansBodySmallThinItalic
                                                        .copyWith(
                                                            color: AppColors
                                                                .textSecondary)),
                                              ),
                                            ],
                                          ),
                                        )
                                      : const SizedBox(
                                          width: double.infinity, height: 0),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      // Start session CTA (focused only)
                      if (isFocused) ...[
                        const SizedBox(height: 14),
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            final i = hobby.roadmapSteps
                                .indexWhere((s) => s.id == step.id);
                            final followingTitle =
                                i + 1 < hobby.roadmapSteps.length
                                    ? hobby.roadmapSteps[i + 1].title
                                    : null;
                            context.push(
                              '/session/${hobby.id}/${step.id}',
                              extra: <String, dynamic>{
                                'hobbyTitle': hobby.title,
                                'hobbyCategory': hobby.category,
                                'stepTitle': step.title,
                                'stepDescription': step.description,
                                'stepInstructions': '',
                                'whatYouNeed': '',
                                'recommendedMinutes': step.estimatedMinutes,
                                'completionMode': step.effectiveMode,
                                'nextStepTitle': followingTitle,
                                'completionMessage': completionMessage,
                                'coachTip': step.coachTip,
                              },
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              borderRadius: BorderRadius.circular(13),
                              boxShadow: [
                                BoxShadow(
                                    color:
                                        AppColors.accent.withValues(alpha: 0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 3)),
                              ],
                            ),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.play_arrow_rounded,
                                      size: 18, color: Colors.white),
                                  const SizedBox(width: 6),
                                  Text('Start session',
                                      style: AppTypography.sansLabel.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],

                      // Ask more (focused + tip open) — slides in smoothly
                      AnimatedSize(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutCubic,
                        alignment: Alignment.topLeft,
                        clipBehavior: Clip.hardEdge,
                        child: isFocused && tipExpanded && coachTip != null
                            ? Padding(
                                padding:
                                    const EdgeInsets.only(top: 10, bottom: 4),
                                child: GestureDetector(
                                  onTap: () => context.push(
                                    '/coach/${hobby.id}',
                                    extra: {
                                      'message':
                                          'Tell me more about "${step.title}" — any tips?',
                                      'mode': 'momentum',
                                      'autoSend': true,
                                    },
                                  ),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    decoration: BoxDecoration(
                                      color: _tealBg,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: _tealBorder, width: 1),
                                    ),
                                    child: Center(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text('\u2726',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: _tealText)),
                                          const SizedBox(width: 6),
                                          Text('Ask more about this step',
                                              style: AppTypography.sansTiny
                                                  .copyWith(color: _tealText)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox(width: double.infinity, height: 0),
                      ),

                      // Inline tip (compact future only)
                      if (isFuture &&
                          !isFocused &&
                          tipExpanded &&
                          coachTip != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 2,
                              height: 32,
                              margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                  color: _tealBar,
                                  borderRadius: BorderRadius.circular(1)),
                            ),
                            Expanded(
                              child: Text(coachTip,
                                  style: AppTypography.sansTiny.copyWith(
                                      color: AppColors.textSecondary,
                                      fontStyle: FontStyle.italic)),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ]),
    ).animate().fadeIn(
          duration: 500.ms,
          curve: Curves.easeOutCubic,
          delay: (80 * staggerIndex).ms,
        );
  }


  // ignore: unused_element, unused_element_parameter
  Widget _buildExpandedCard(
      BuildContext context, String? coachTip, String? completionMessage) {
    return Container(
      key: const ValueKey('expanded'),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(top: 4, bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: AppColors.accent.withValues(alpha: 0.18), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // UP NEXT + milestone
          Row(
            children: [
              Text('UP NEXT',
                  style:
                      AppTypography.overline.copyWith(color: AppColors.accent)),
              if (step.milestone != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    '\u{1F3C6} ${step.milestone}',
                    style: AppTypography.monoBadge
                        .copyWith(color: AppColors.accent, fontSize: 9),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          // Title
          Text(step.title, style: AppTypography.title.copyWith(fontSize: 17)),
          // Description
          if (step.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(step.description,
                style: AppTypography.sansBodySmall
                    .copyWith(color: AppColors.textSecondary)),
          ],
          // Coach tip block
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onToggleTip,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: tipExpanded ? _tealBgActive : _tealBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: tipExpanded ? _tealBorderActive : _tealBorder,
                    width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Text('\u2726',
                        style: TextStyle(fontSize: 15, color: _tealText)),
                    const SizedBox(width: 8),
                    Text(
                      tipExpanded
                          ? 'Coach tip'
                          : (coachTip != null
                              ? 'Tap for a coach tip'
                              : 'Coach tip coming soon'),
                      style: AppTypography.sansTiny.copyWith(
                        color: _tealText,
                        fontWeight:
                            tipExpanded ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ]),
                  if (tipExpanded && coachTip != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 2.5,
                          height: 40,
                          margin: const EdgeInsets.only(left: 6, right: 14),
                          decoration: BoxDecoration(
                              color: _tealBar,
                              borderRadius: BorderRadius.circular(2)),
                        ),
                        Expanded(
                          child: Text(coachTip,
                              style: AppTypography.sansBodySmall
                                  .copyWith(color: AppColors.textSecondary)),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          // Start session CTA
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              final i = hobby.roadmapSteps.indexWhere((s) => s.id == step.id);
              final followingTitle = i + 1 < hobby.roadmapSteps.length
                  ? hobby.roadmapSteps[i + 1].title
                  : null;
              context.push(
                '/session/${hobby.id}/${step.id}',
                extra: <String, dynamic>{
                  'hobbyTitle': hobby.title,
                  'hobbyCategory': hobby.category,
                  'stepTitle': step.title,
                  'stepDescription': step.description,
                  'stepInstructions': '',
                  'whatYouNeed': '',
                  'recommendedMinutes': step.estimatedMinutes,
                  'completionMode': step.effectiveMode,
                  'nextStepTitle': followingTitle,
                  'completionMessage': step.completionMessage,
                  'coachTip': step.coachTip,
                },
              );
            },
            child: Container(
              width: double.infinity,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(13),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 3)),
                ],
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.play_arrow_rounded,
                        size: 18, color: Colors.white),
                    const SizedBox(width: 6),
                    Text('Start session',
                        style: AppTypography.sansLabel.copyWith(
                            color: Colors.white, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          ),
          // Ask more link
          if (tipExpanded && coachTip != null)
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 4),
              child: GestureDetector(
                onTap: () => context.push(
                  '/coach/${hobby.id}',
                  extra: {
                    'message': 'Tell me more about "${step.title}" — any tips?',
                    'mode': 'momentum',
                    'autoSend': true,
                  },
                ),
                child: Center(
                  child: Text('Ask more about this step',
                      style: AppTypography.sansCaption.copyWith(
                        color: AppColors.textSecondary,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.textSecondary,
                      )),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ignore: unused_element, unused_element_parameter
  Widget _buildCompactRow(String? coachTip, bool isFuture) {
    return Padding(
      key: const ValueKey('compact'),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  step.title,
                  style: isCompleted
                      ? AppTypography.body.copyWith(
                          color: AppColors.textMuted,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: AppColors.textWhisper)
                      : AppTypography.body.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500),
                ),
              ),
              if (!isCompleted && step.milestone != null)
                const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Text('\u{1F3C6}', style: TextStyle(fontSize: 12)),
                ),
              if (isFuture && coachTip != null)
                GestureDetector(
                  onTap: onToggleTip,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Text('\u2726',
                        style: TextStyle(
                          fontSize: 13,
                          color: tipExpanded
                              ? _tealTextBright
                              : const Color(0x665CB8C9),
                        )),
                  ),
                ),
            ],
          ),
          // Inline tip for future steps
          if (isFuture && tipExpanded && coachTip != null) ...[
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 2,
                  height: 32,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                      color: _tealBar, borderRadius: BorderRadius.circular(1)),
                ),
                Expanded(
                  child: Text(coachTip,
                      style: AppTypography.sansTiny
                          .copyWith(color: AppColors.textSecondary)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
