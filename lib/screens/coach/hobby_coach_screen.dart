import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../providers/hobby_provider.dart';
import '../../providers/user_provider.dart';
import '../../components/app_background.dart';
import '../../components/app_overlays.dart';
import '../../components/glass_card.dart';
import '../../core/media/image_upload.dart';
import '../../models/hobby.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/spacing.dart';
import 'coach_bubble.dart';
import 'coach_composer.dart';
import 'coach_provider.dart';
export 'coach_provider.dart';

// ═══════════════════════════════════════════════════════
//  HOBBY COACH SCREEN — Premium Guidance Workspace
// ═══════════════════════════════════════════════════════

class HobbyCoachScreen extends ConsumerStatefulWidget {
  final String hobbyId;
  final CoachEntryContext? entryContext;

  const HobbyCoachScreen({
    super.key,
    required this.hobbyId,
    this.entryContext,
  });

  @override
  ConsumerState<HobbyCoachScreen> createState() => _HobbyCoachScreenState();
}

class _HobbyCoachScreenState extends ConsumerState<HobbyCoachScreen> {
  final _scrollController = ScrollController();
  late CoachMode _mode;

  @override
  void initState() {
    super.initState();
    _mode = widget.entryContext?.forceMode ?? _detectMode();

    final ctx = widget.entryContext;
    if (ctx?.focusEntryId != null) {
      ref.read(coachProvider(widget.hobbyId).notifier)
          .setFocusEntryId(ctx!.focusEntryId);
    }
    if (ctx?.prefilledMessage != null && ctx!.autoSend) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref
              .read(coachProvider(widget.hobbyId).notifier)
              .send(ctx.prefilledMessage!);
          _scrollToBottom();
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  CoachMode _detectMode() {
    final userHobbies = ref.read(userHobbiesProvider);
    final userHobby = userHobbies[widget.hobbyId];

    if (userHobby == null || userHobby.status == HobbyStatus.saved) {
      return CoachMode.start;
    }

    final lastActive = userHobby.lastActivityAt ?? userHobby.startedAt ?? DateTime.now();
    final daysSince = DateTime.now().difference(lastActive).inDays;
    if (daysSince >= 7) return CoachMode.rescue;

    return CoachMode.momentum;
  }

  void _switchMode(CoachMode mode) {
    if (mode == _mode) return;
    HapticFeedback.lightImpact();
    setState(() => _mode = mode);
    ref.read(coachProvider(widget.hobbyId).notifier).setMode(mode.name.toUpperCase());
  }

  void _handleSend(String text, String? imagePath) async {
    final messageText = imagePath != null && text.isEmpty
        ? 'What do you think of this photo?'
        : text.isEmpty
            ? 'What do you think?'
            : text;

    // If there's an image, upload first (notifier handles the typing indicator)
    String? imageUrl;
    if (imagePath != null) {
      // Show the message + typing indicator immediately
      final notifier = ref.read(coachProvider(widget.hobbyId).notifier);
      notifier.addPendingMessage(messageText, hasImage: true);
      _scrollToBottom();

      try {
        imageUrl = await ImageUpload.moderateAndUpload(File(imagePath));
        debugPrint('[Coach] Image uploaded: $imageUrl');
      } on ImageModerationException catch (e) {
        if (mounted) {
          notifier.removePendingMessage();
          showAppSnackbar(context,
              message: e.reason, type: AppSnackbarType.error);
        }
        return;
      }
      if (imageUrl == null) {
        if (mounted) {
          notifier.removePendingMessage();
          showAppSnackbar(context,
              message: 'Failed to upload photo',
              type: AppSnackbarType.error);
        }
        return;
      }
      // Replace pending message with the real one (includes imageUrl)
      notifier.removePendingMessage();
    }

    ref
        .read(coachProvider(widget.hobbyId).notifier)
        .send(messageText, imageUrl: imageUrl)
        .then((_) {
      final notifier = ref.read(coachProvider(widget.hobbyId).notifier);
      if (notifier.limitHit && mounted) {
        context.push('/pro');
      } else if (mounted) {
        HapticFeedback.mediumImpact();
      }
    });
    _scrollToBottom();
  }

  void _sendChip(String text) {
    HapticFeedback.lightImpact();
    // Enrich certain chips with user context for better server responses
    final enriched = _enrichChipMessage(text);
    _handleSend(enriched, null);
  }

  /// Enriches quick-action chip messages with user context so the server
  /// gives more specific, stage-aware guidance.
  String _enrichChipMessage(String chip) {
    final hobby = ref.read(hobbyByIdProvider(widget.hobbyId)).valueOrNull;
    final userHobbies = ref.read(userHobbiesProvider);
    final userHobby = userHobbies[widget.hobbyId];
    final stepsCompleted = userHobby?.completedStepIds.length ?? 0;
    final totalSteps = hobby?.roadmapSteps.length ?? 0;
    final hobbyTitle = hobby?.title ?? 'this hobby';

    switch (chip) {
      // Q.6 — Start tonight
      case 'Help me start tonight':
        return 'Help me start tonight. I want a tiny first session plan for $hobbyTitle that I can do right now.';

      // Q.5 — Make this cheaper
      case 'Make this cheaper':
        return 'Make this cheaper. What\'s the absolute minimum I need to spend to start $hobbyTitle?';

      // Q.4 — What should I do next
      case 'What should I do next?':
        if (totalSteps > 0) {
          return 'What should I do next? I\'ve completed $stepsCompleted of $totalSteps steps.';
        }
        return chip;

      // Q.3 — Continue or switch (rescue)
      case 'Maybe this hobby isn\'t for me':
        final lastActive = userHobby?.lastActivityAt ?? userHobby?.startedAt;
        final days = lastActive != null
            ? DateTime.now().difference(lastActive).inDays
            : 0;
        return 'Maybe this hobby isn\'t for me. I\'ve been doing $hobbyTitle for a while '
            '($stepsCompleted steps done) but haven\'t practiced in $days days. '
            'Help me figure out if I should continue with a simpler version or switch to something else.';

      // Momentum — losing motivation
      case 'I\'m losing motivation':
        return 'I\'m losing motivation with $hobbyTitle. '
            'I\'ve done $stepsCompleted of $totalSteps steps. What small win can I get today?';

      // Rescue — skipped days
      case 'I skipped a few days':
        final lastActive = userHobby?.lastActivityAt ?? userHobby?.startedAt;
        final days = lastActive != null
            ? DateTime.now().difference(lastActive).inDays
            : 0;
        return 'I skipped $days days of $hobbyTitle. Help me restart gently.';

      // Make this easier (momentum)
      case 'Make this easier':
        if (totalSteps > 0 && stepsCompleted < totalSteps) {
          final currentStepTitle = hobby!.roadmapSteps[stepsCompleted].title;
          return 'Make this easier. I\'m on step "$currentStepTitle" and it feels too hard.';
        }
        return chip;

      default:
        return chip;
    }
  }

  /// Handles taps on structured card action buttons.
  void _handleCardAction(String action) {
    HapticFeedback.lightImpact();
    switch (action) {
      // Plan card actions
      case 'Start this session':
        // Navigate to session screen
        context.push('/session/${widget.hobbyId}');
        return;
      case 'Adjust it':
        _sendChip('Adjust the plan — make it shorter or simpler');
        return;

      // Budget card actions
      case 'Use this version':
        _sendChip('Great, I\'ll use the cheaper version. What\'s my first step?');
        return;
      case 'Show starter kit':
        context.push('/hobby/${widget.hobbyId}');
        return;

      // Recovery card actions
      case 'Restart now':
        _sendChip('Help me start tonight');
        return;
      case 'Maybe switch':
        _sendChip('Maybe this hobby isn\'t for me');
        return;

      // Reflection card actions
      case 'Open reflection':
        context.push('/session/${widget.hobbyId}');
        return;
      case 'Skip for now':
        _sendChip('What should I do next?');
        return;

      // Week plan card actions
      case 'Apply update':
        _sendChip('Apply the updated plan. What\'s my next session?');
        return;
      case 'Keep original':
        _sendChip('I\'ll keep the original plan. What should I focus on next?');
        return;
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(coachProvider(widget.hobbyId));
    final notifier = ref.read(coachProvider(widget.hobbyId).notifier);
    final hobby = ref.watch(hobbyByIdProvider(widget.hobbyId)).valueOrNull;
    final hobbyTitle = hobby?.title ?? 'Coach';
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    // Only pass prefillText when not autoSend (autoSend is handled in initState)
    final prefill = widget.entryContext?.prefilledMessage;
    final isAutoSend = widget.entryContext?.autoSend ?? false;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Premium header
              _buildHeader(hobbyTitle),

              // Scrollable content area
              Expanded(
                child: messages.isEmpty
                    ? SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildContextHero(hobby),
                            const SizedBox(height: 16),
                            _buildModeSelector(),
                            const SizedBox(height: 12),
                            _buildRemainingBanner(),
                            _buildEmptyOrLockedState(),
                          ],
                        ),
                      )
                    : Column(
                        children: [
                          _buildRemainingBanner(),
                          Expanded(
                            child: _buildMessageList(messages, notifier),
                          ),
                          _buildQuickActionsStrip(),
                        ],
                      ),
              ),

              // Input bar
              CoachComposer(
                onSend: _handleSend,
                prefillText: isAutoSend ? null : prefill,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────

  Widget _buildHeader(String hobbyTitle) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.glassBackground,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.glassBorder, width: 0.5),
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  size: 18, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(hobbyTitle,
                    style: AppTypography.title.copyWith(fontSize: 16)),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_mode.label} Mode',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              ref.read(coachProvider(widget.hobbyId).notifier).clearConversation();
            },
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.glassBackground,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.glassBorder, width: 0.5),
              ),
              child: const Icon(Icons.delete_outline_rounded,
                  size: 16, color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }

  // ── Context Hero ────────────────────────────────────

  Widget _buildContextHero(Hobby? hobby) {
    final userHobbies = ref.watch(userHobbiesProvider);
    final userHobby = userHobbies[widget.hobbyId];
    final stepsCompleted = userHobby?.completedStepIds.length ?? 0;
    final totalSteps = hobby?.roadmapSteps.length ?? 0;

    String contextLine;
    if (_mode == CoachMode.start) {
      contextLine = 'Ready to help you begin. No experience needed.';
    } else if (_mode == CoachMode.rescue) {
      final lastActive = userHobby?.lastActivityAt ?? userHobby?.startedAt;
      final days = lastActive != null
          ? DateTime.now().difference(lastActive).inDays
          : 0;
      contextLine = 'It\'s been $days days. Let\'s find an easy way back in.';
    } else {
      contextLine = '$stepsCompleted of $totalSteps steps complete. Keep going!';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: GlassCard(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_mode.icon, size: 18, color: AppColors.accent),
                const SizedBox(width: 8),
                Text(
                  _mode.subtitle,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              contextLine,
              style: AppTypography.body.copyWith(
                color: AppColors.textPrimary,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            if (_mode == CoachMode.momentum && totalSteps > 0) ...[
              const SizedBox(height: 12),
              // Mini progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: totalSteps > 0 ? stepsCompleted / totalSteps : 0,
                  minHeight: 4,
                  backgroundColor: AppColors.surfaceElevated,
                  valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                ),
              ),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(
          begin: -0.05,
          end: 0,
          duration: 400.ms,
          curve: Curves.easeOutCubic,
        );
  }

  // ── Mode Selector ───────────────────────────────────

  Widget _buildModeSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: CoachMode.values.map((mode) {
          final isActive = _mode == mode;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: mode != CoachMode.rescue ? 8 : 0,
              ),
              child: GestureDetector(
                onTap: () => _switchMode(mode),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.accent.withValues(alpha: 0.12)
                        : AppColors.glassBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isActive
                          ? AppColors.accent.withValues(alpha: 0.4)
                          : AppColors.glassBorder,
                      width: isActive ? 1 : 0.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        mode.icon,
                        size: 16,
                        color: isActive
                            ? AppColors.accent
                            : AppColors.textMuted,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        mode.label,
                        style: AppTypography.caption.copyWith(
                          fontWeight:
                              isActive ? FontWeight.w700 : FontWeight.w500,
                          color: isActive
                              ? AppColors.accent
                              : AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ).animate(key: ValueKey(_mode)).fadeIn(duration: 200.ms),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    ).animate().fadeIn(duration: 350.ms, delay: 100.ms);
  }

  // ── Empty/Locked State Dispatcher ───────────────────

  Widget _buildEmptyOrLockedState() {
    final remaining = ref.watch(coachRemainingProvider(widget.hobbyId));
    return remaining.when(
      data: (value) => value == 0 ? _buildLockedState() : _buildGuidedActions(),
      loading: () => _buildGuidedActions(),
      error: (_, __) => _buildGuidedActions(),
    );
  }

  // ── Locked State (0 free messages) ──────────────────

  Widget _buildLockedState() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome,
                size: 24, color: AppColors.accent),
          ),
          const SizedBox(height: 16),
          Text(
            'Your coach is waiting',
            style: AppTypography.title.copyWith(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'You\'ve used your free messages this month. Upgrade to keep the momentum going.',
            style: AppTypography.body.copyWith(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              context.push('/pro');
            },
            child: Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  'Continue with Pro',
                  style: AppTypography.body.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  // ── Guided Actions (empty state) ────────────────────

  Widget _buildGuidedActions() {
    final actions = _getActionsForMode();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WHAT DO YOU NEED?',
            style: AppTypography.caption.copyWith(
              color: AppColors.textMuted,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              _mode == CoachMode.rescue
                  ? 'No judgment. Just the easiest way back in.'
                  : _mode == CoachMode.momentum
                      ? 'Guidance tied to your actual progress.'
                      : 'No experience needed. Just start small.',
              style: AppTypography.caption.copyWith(
                color: AppColors.textMuted,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ).animate().fadeIn(duration: 300.ms, delay: 50.ms),
          ...actions.asMap().entries.map((entry) {
            final action = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () => _sendChip(action.$1),
                child: GlassCard(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(action.$2,
                            size: 18, color: AppColors.accent),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              action.$1,
                              style: AppTypography.body.copyWith(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              action.$3,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textMuted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded,
                          size: 12, color: AppColors.textWhisper),
                    ],
                  ),
                ),
              ),
            )
                .animate()
                .fadeIn(duration: 350.ms, delay: (entry.key * 80).ms)
                .slideX(
                  begin: 0.03,
                  end: 0,
                  duration: 350.ms,
                  delay: (entry.key * 80).ms,
                );
          }),
        ],
      ),
    );
  }

  // (label, icon, description)
  List<(String, IconData, String)> _getActionsForMode() {
    switch (_mode) {
      case CoachMode.start:
        return [
          ('Help me start tonight', Icons.play_circle_outline_rounded,
              'A 15-min plan you can start tonight'),
          ('Make this cheaper', Icons.savings_outlined,
              'Find the lowest-cost way to begin'),
          ('What do I need to buy?', Icons.shopping_bag_outlined,
              'Essential starter kit only'),
        ];
      case CoachMode.momentum:
        return [
          ('What should I do next?', Icons.arrow_circle_right_outlined,
              'Specific to where you are now'),
          ('Make this easier', Icons.tune_rounded,
              'Simplify your current approach'),
          ('I\'m losing motivation', Icons.battery_2_bar_rounded,
              'Small wins to rebuild momentum'),
        ];
      case CoachMode.rescue:
        return [
          ('I skipped a few days', Icons.replay_rounded,
              'One tiny action to break the gap'),
          ('I\'m losing motivation', Icons.battery_2_bar_rounded,
              'Find what made it fun at first'),
          ('Maybe this hobby isn\'t for me', Icons.swap_horiz_rounded,
              'Let\'s figure out what fits better'),
        ];
    }
  }

  // ── Quick Actions Strip (during conversation) ───────

  Widget _buildQuickActionsStrip() {
    final chips = _getActionsForMode().map((a) => a.$1).toList();

    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: chips.map((chip) {
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: GestureDetector(
              onTap: () => _sendChip(chip),
              child: Container(
                alignment: Alignment.center,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.glassBackground,
                  borderRadius: BorderRadius.circular(Spacing.radiusBadge),
                  border:
                      Border.all(color: AppColors.glassBorder, width: 0.5),
                ),
                child: Text(
                  chip,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Message List ────────────────────────────────────

  Widget _buildMessageList(
      List<ChatMessage> messages, CoachNotifier notifier) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      itemCount: messages.length + (notifier.isSending ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == messages.length) return const TypingIndicator();
        return CoachBubble(
          message: messages[index],
          onCardAction: _handleCardAction,
        );
      },
    );
  }

  // ── Remaining Messages Banner ───────────────────────

  Widget _buildRemainingBanner() {
    final remaining = ref.watch(coachRemainingProvider(widget.hobbyId));
    return remaining.when(
      data: (value) {
        if (value == null) return const SizedBox.shrink();
        final isLow = value <= 1;
        return Container(
          margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isLow
                ? AppColors.accent.withValues(alpha: 0.08)
                : AppColors.glassBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isLow
                  ? AppColors.accent.withValues(alpha: 0.3)
                  : AppColors.glassBorder,
              width: 0.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                value == 0
                    ? 'Upgrade to keep your momentum going'
                    : '$value free ${value == 1 ? 'message' : 'messages'} left — Pro gives you unlimited support',
                style: AppTypography.caption.copyWith(
                  color: isLow ? AppColors.accent : AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              if (isLow && value <= 1) ...[
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => context.push('/pro'),
                  child: Text(
                    'Upgrade to Pro',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.accent,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.accent,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

}

