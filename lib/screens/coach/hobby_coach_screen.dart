import 'dart:math' as math;
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../providers/hobby_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../components/app_background.dart';
import '../../components/app_overlays.dart';
import '../../components/glass_card.dart';
import '../../components/voice_input.dart';
import '../../core/media/image_upload.dart';
import '../../models/hobby.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/spacing.dart';
import '../../components/coach_cards.dart';
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
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  late CoachMode _mode;
  bool _voiceActive = false;
  String? _pendingImagePath;

  @override
  void initState() {
    super.initState();
    _mode = widget.entryContext?.forceMode ?? _detectMode();

    final ctx = widget.entryContext;
    if (ctx?.focusEntryId != null) {
      ref.read(coachProvider(widget.hobbyId).notifier)
          .setFocusEntryId(ctx!.focusEntryId);
    }
    if (ctx?.prefilledMessage != null) {
      if (ctx!.autoSend) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ref
                .read(coachProvider(widget.hobbyId).notifier)
                .send(ctx.prefilledMessage!);
            _scrollToBottom();
          }
        });
      } else {
        _textController.text = ctx.prefilledMessage!;
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
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

  void _send() async {
    final text = _textController.text.trim();
    final imagePath = _pendingImagePath;
    if (text.isEmpty && imagePath == null) return;
    HapticFeedback.lightImpact();
    _textController.clear();
    setState(() => _pendingImagePath = null);

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
    _textController.text = enriched;
    _send();
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
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

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
              _buildComposer(bottomInset, bottomPad),
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
        if (index == messages.length) return const _TypingIndicator();
        return _CoachBubble(
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

  // ── Composer ────────────────────────────────────────

  void _onMicTap() {
    final isPro = ref.read(isProProvider);
    if (!isPro) {
      context.push('/pro');
      return;
    }
    setState(() => _voiceActive = true);
  }

  void _onAttachTap() {
    final isPro = ref.read(isProProvider);
    if (!isPro) {
      context.push('/pro');
      return;
    }
    _showImagePickerMenu();
  }

  void _showImagePickerMenu() {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () => entry.remove(),
              behavior: HitTestBehavior.opaque,
              child: const SizedBox.expand(),
            ),
          ),
          Positioned(
            left: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom +
                MediaQuery.of(context).padding.bottom + 70,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 200,
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.glassBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildPickerRow(
                      icon: Icons.camera_alt_rounded,
                      label: 'Take photo',
                      isFirst: true,
                      onTap: () {
                        entry.remove();
                        _pickImage(ImageSource.camera);
                      },
                    ),
                    Container(height: 0.5, color: AppColors.glassBorder),
                    _buildPickerRow(
                      icon: Icons.photo_library_rounded,
                      label: 'Choose from gallery',
                      isLast: true,
                      onTap: () {
                        entry.remove();
                        _pickImage(ImageSource.gallery);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
    overlay.insert(entry);
  }

  Widget _buildPickerRow({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(
            top: isFirst ? const Radius.circular(12) : Radius.zero,
            bottom: isLast ? const Radius.circular(12) : Radius.zero,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.textSecondary),
            const SizedBox(width: 10),
            Text(label,
                style: AppTypography.caption
                    .copyWith(color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (picked != null && mounted) {
      setState(() => _pendingImagePath = picked.path);
    }
  }

  Widget _buildComposer(double bottomInset, double bottomPad) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          16, 10, 16, bottomInset > 0 ? 10 : bottomPad + 10),
      child: _voiceActive
          ? VoiceInputOverlay(
              onResult: (text) {
                setState(() {
                  _voiceActive = false;
                  _textController.text = text;
                  // Place cursor at end
                  _textController.selection = TextSelection.collapsed(
                      offset: text.length);
                });
              },
              onCancel: () => setState(() => _voiceActive = false),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Image preview (if attached)
                if (_pendingImagePath != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    height: 80,
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(_pendingImagePath!),
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () =>
                              setState(() => _pendingImagePath = null),
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: AppColors.glassBorder, width: 0.5),
                            ),
                            child: const Icon(Icons.close_rounded,
                                size: 12, color: AppColors.textMuted),
                          ),
                        ),
                      ],
                    ),
                  ),
                // Composer row
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.glassBackground,
                    borderRadius: BorderRadius.circular(24),
                    border:
                        Border.all(color: AppColors.glassBorder, width: 0.5),
                  ),
                  child: Row(
                    children: [
                      // + button (image attach)
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: GestureDetector(
                          onTap: _onAttachTap,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(Icons.add_circle_outline_rounded,
                                    size: 20, color: AppColors.textMuted),
                                if (!ref.watch(isProProvider))
                                  Positioned(
                                    right: 2,
                                    bottom: 2,
                                    child: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.coral,
                                        border: Border.all(
                                            color: AppColors.glassBackground,
                                            width: 1),
                                      ),
                                      child: const Icon(Icons.lock,
                                          size: 5, color: Colors.white),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Text input
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          style: AppTypography.body.copyWith(fontSize: 14),
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _send(),
                          decoration: InputDecoration(
                            hintText: _pendingImagePath != null
                                ? 'Add a message...'
                                : 'Ask your coach...',
                            hintStyle: AppTypography.caption
                                .copyWith(color: AppColors.textMuted),
                            border: InputBorder.none,
                            filled: false,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                          ),
                        ),
                      ),
                      // Mic button
                      Padding(
                        padding: const EdgeInsets.only(right: 2),
                        child: GestureDetector(
                          onTap: _onMicTap,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(Icons.mic_rounded,
                                    size: 18, color: AppColors.textMuted),
                                if (!ref.watch(isProProvider))
                                  Positioned(
                                    right: 2,
                                    bottom: 2,
                                    child: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.coral,
                                        border: Border.all(
                                            color: AppColors.glassBackground,
                                            width: 1),
                                      ),
                                      child: const Icon(Icons.lock,
                                          size: 5, color: Colors.white),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Send button
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: GestureDetector(
                          onTap: _send,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.coral,
                            ),
                            child: const Icon(Icons.arrow_upward_rounded,
                                size: 16, color: Colors.white),
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

// ═══════════════════════════════════════════════════════
//  COACH BUBBLE — Premium styled message
// ═══════════════════════════════════════════════════════

class _CoachBubble extends StatelessWidget {
  final ChatMessage message;
  final void Function(String action)? onCardAction;

  const _CoachBubble({required this.message, this.onCardAction});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';

    if (isUser) {
      final hasImage = (message.imageUrl != null && message.imageUrl!.isNotEmpty) ||
          message.imageUploading;
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(top: 4, bottom: 4, left: 48),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          padding: const EdgeInsets.all(6),
          decoration: const BoxDecoration(
            color: AppColors.coral,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Photo (if attached) — rounded inside the bubble
              if (hasImage)
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: message.imageUploading
                      ? _ImageSkeleton()
                      : CachedNetworkImage(
                          imageUrl: message.imageUrl!,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          memCacheWidth: 500,
                          placeholder: (_, __) => _ImageSkeleton(),
                        ),
                ),
              // Text
              if (message.content.isNotEmpty)
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      10, hasImage ? 8 : 6, 10, 6),
                  child: Text(
                    message.content,
                    style: AppTypography.body.copyWith(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
            ],
          ),
        ),
      )
          .animate()
          .fadeIn(duration: 300.ms, delay: 30.ms)
          .slideY(begin: 0.04, end: 0, duration: 300.ms, curve: Curves.easeOutCubic);
    }

    // Assistant — try structured cards first, fall back to plain bubble
    final cards = parseCoachResponse(message.content);
    if (cards != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 6, bottom: 6, right: 16),
        child: CoachCardList(cards: cards, onAction: onCardAction),
      )
          .animate()
          .fadeIn(duration: 300.ms, delay: 30.ms)
          .slideY(begin: 0.04, end: 0, duration: 300.ms, curve: Curves.easeOutCubic);
    }

    // Plain text fallback — render with markdown support
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(top: 6, bottom: 6, right: 32),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.glassBackground,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(18),
          ),
          border: Border.all(color: AppColors.glassBorder, width: 0.5),
        ),
        child: CoachMarkdownText(
          text: message.content,
          textColor: AppColors.textSecondary,
          fontSize: 14,
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: 30.ms)
        .slideY(begin: 0.04, end: 0, duration: 300.ms, curve: Curves.easeOutCubic);
  }
}

// ═══════════════════════════════════════════════════════
//  TYPING INDICATOR
// ═══════════════════════════════════════════════════════

/// Shimmer skeleton placeholder for image while uploading.
class _ImageSkeleton extends StatefulWidget {
  @override
  State<_ImageSkeleton> createState() => _ImageSkeletonState();
}

class _ImageSkeletonState extends State<_ImageSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          width: double.infinity,
          height: 160,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1.0 + 2.0 * _controller.value, 0),
              end: Alignment(-0.5 + 2.0 * _controller.value, 0),
              colors: [
                Colors.white.withValues(alpha: 0.08),
                Colors.white.withValues(alpha: 0.18),
                Colors.white.withValues(alpha: 0.08),
              ],
            ),
          ),
          child: Center(
            child: Icon(Icons.photo_rounded,
                size: 28, color: Colors.white.withValues(alpha: 0.25)),
          ),
        );
      },
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(top: 6, bottom: 6, right: 48),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.glassBackground,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.glassBorder, width: 0.5),
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                final delay = i * 0.2;
                final t = (_controller.value - delay).clamp(0.0, 1.0);
                final y = math.sin(t * math.pi) * 4;
                return Container(
                  margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
                  child: Transform.translate(
                    offset: Offset(0, -y),
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: AppColors.textMuted
                            .withValues(alpha: 0.4 + t * 0.4),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    ).animate().fadeIn(duration: 200.ms);
  }
}
