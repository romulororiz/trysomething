import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/hobby_provider.dart';
import '../../providers/user_provider.dart';
import '../../components/app_background.dart';
import '../../components/app_overlays.dart';
import '../../core/media/image_upload.dart';
import '../../models/hobby.dart';
import 'coach_bubble.dart';
import 'coach_composer.dart';
import 'coach_provider.dart';
import 'coach_widgets.dart';
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
              .send(ctx.prefilledMessage!, quotedText: ctx.quotedText);
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

  // ── Send Logic ──────────────────────────────────────

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

  // ── Build ───────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(coachProvider(widget.hobbyId));
    final notifier = ref.read(coachProvider(widget.hobbyId).notifier);
    final hobbyTitle =
        ref.watch(hobbyByIdProvider(widget.hobbyId)).valueOrNull?.title ??
            'Coach';
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
              CoachHeader(
                hobbyTitle: hobbyTitle,
                modeName: _mode.label,
                onBack: () => context.pop(),
                onClear: () => ref
                    .read(coachProvider(widget.hobbyId).notifier)
                    .clearConversation(),
              ),

              // Scrollable content area
              Expanded(
                child: messages.isEmpty
                    ? SingleChildScrollView(
                        child: Column(
                          children: [
                            CoachContextHero(
                                hobbyId: widget.hobbyId, mode: _mode),
                            const SizedBox(height: 16),
                            CoachModeSelector(
                                currentMode: _mode,
                                onModeChanged: _switchMode),
                            const SizedBox(height: 12),
                            CoachRemainingBanner(hobbyId: widget.hobbyId),
                            CoachEmptyState(
                              hobbyId: widget.hobbyId,
                              mode: _mode,
                              onChipTap: _sendChip,
                            ),
                          ],
                        ),
                      )
                    : Column(
                        children: [
                          CoachRemainingBanner(hobbyId: widget.hobbyId),
                          Expanded(
                            child: _buildMessageList(messages, notifier),
                          ),
                          CoachQuickActionsStrip(
                              mode: _mode, onChipTap: _sendChip),
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
}
