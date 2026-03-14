import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/analytics/analytics_provider.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_constants.dart';
import '../../providers/hobby_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../components/pro_upgrade_sheet.dart';
import '../../components/app_background.dart';
import '../../components/glass_card.dart';
import '../../models/hobby.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/spacing.dart';
import '../../components/coach_cards.dart';

// ═══════════════════════════════════════════════════════
//  CHAT MESSAGE MODEL
// ═══════════════════════════════════════════════════════

class ChatMessage {
  final String role; // 'user' or 'assistant'
  final String content;
  final DateTime timestamp;

  ChatMessage({
    required this.role,
    required this.content,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'role': role,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        role: json['role'] as String,
        content: json['content'] as String,
        timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ??
            DateTime.now(),
      );
}

// ═══════════════════════════════════════════════════════
//  COACH MODE
// ═══════════════════════════════════════════════════════

enum CoachMode {
  start('Start', 'Begin your journey', Icons.play_arrow_rounded),
  momentum('Momentum', 'Keep going strong', Icons.trending_up_rounded),
  rescue('Rescue', 'Get back on track', Icons.support_rounded);

  final String label;
  final String subtitle;
  final IconData icon;
  const CoachMode(this.label, this.subtitle, this.icon);
}

// ═══════════════════════════════════════════════════════
//  MESSAGE LIMIT TRACKER — per-hobby per-month in Hive
// ═══════════════════════════════════════════════════════

class _CoachLimitTracker {
  static const _boxName = 'coach_limits';

  static String _key(String hobbyId) {
    final now = DateTime.now();
    final ym = '${now.year}_${now.month.toString().padLeft(2, '0')}';
    return '${hobbyId}_$ym';
  }

  static Future<int> getCount(String hobbyId) async {
    final box = await Hive.openBox(_boxName);
    return box.get(_key(hobbyId), defaultValue: 0) as int;
  }

  static Future<void> increment(String hobbyId) async {
    final box = await Hive.openBox(_boxName);
    final key = _key(hobbyId);
    final current = box.get(key, defaultValue: 0) as int;
    await box.put(key, current + 1);
  }

  static int? limitForState(HobbyStatus? status) {
    if (status == null) return 3;
    switch (status) {
      case HobbyStatus.saved:
        return 5;
      case HobbyStatus.trying:
      case HobbyStatus.active:
        return 5;
      case HobbyStatus.done:
        return 2;
    }
  }
}

/// Exposes remaining messages for a hobby this month.
final coachRemainingProvider =
    FutureProvider.autoDispose.family<int?, String>((ref, hobbyId) async {
  final isPro = ref.watch(isProProvider);
  if (isPro) return null;

  final userHobbies = ref.watch(userHobbiesProvider);
  final userHobby = userHobbies[hobbyId];
  final limit = _CoachLimitTracker.limitForState(userHobby?.status);
  if (limit == null) return null;

  final count = await _CoachLimitTracker.getCount(hobbyId);
  return (limit - count).clamp(0, limit);
});

// ═══════════════════════════════════════════════════════
//  COACH PROVIDER — per-hobby conversation in Hive
// ═══════════════════════════════════════════════════════

class CoachNotifier extends StateNotifier<List<ChatMessage>> {
  final String hobbyId;
  final Ref ref;
  bool _sending = false;
  bool get isSending => _sending;

  bool _limitHit = false;
  bool get limitHit => _limitHit;

  CoachNotifier(this.hobbyId, this.ref) : super([]) {
    _loadFromHive();
  }

  Future<void> _loadFromHive() async {
    final box = await Hive.openBox('coach_conversations');
    final list = box.get(hobbyId);
    if (list != null) {
      state = (list as List)
          .map((e) => ChatMessage.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
  }

  Future<void> _saveToHive() async {
    final box = await Hive.openBox('coach_conversations');
    await box.put(hobbyId, state.map((m) => m.toJson()).toList());
  }

  String _selectedMode = 'AUTO';

  void setMode(String mode) {
    _selectedMode = mode;
  }

  Future<void> send(String message) async {
    if (_sending || message.trim().isEmpty) return;
    _limitHit = false;

    final isPro = ref.read(isProProvider);
    if (!isPro) {
      final userHobbies = ref.read(userHobbiesProvider);
      final userHobby = userHobbies[hobbyId];
      final limit = _CoachLimitTracker.limitForState(userHobby?.status);
      if (limit != null) {
        final count = await _CoachLimitTracker.getCount(hobbyId);
        if (count >= limit) {
          _limitHit = true;
          ref.read(analyticsProvider).trackEvent('coach_limit_reached', {
            'hobby_id': hobbyId,
            'limit': limit,
          });
          state = [...state];
          return;
        }
      }
    }

    _sending = true;

    final userMsg = ChatMessage(role: 'user', content: message.trim());
    state = [...state, userMsg];
    await _saveToHive();

    try {
      final dio = ApiClient.instance;
      final response = await dio.post(
        ApiConstants.coachChat,
        data: {
          'hobbyId': hobbyId,
          'message': message.trim(),
          'modeOverride': _selectedMode,
          'conversationHistory': state
              .take(state.length - 1) // exclude the just-added user message
              .map((m) => {'role': m.role, 'content': m.content})
              .toList(),
        },
        options: Options(receiveTimeout: const Duration(seconds: 30)),
      );

      final reply = response.data['response'] as String? ?? '';
      final assistantMsg = ChatMessage(role: 'assistant', content: reply);
      state = [...state, assistantMsg];

      ref.read(analyticsProvider).trackEvent('coach_message_sent', {
        'hobby_id': hobbyId,
        'message_count': state.length,
      });

      if (!isPro) {
        await _CoachLimitTracker.increment(hobbyId);
        ref.invalidate(coachRemainingProvider(hobbyId));
      }
    } on DioException catch (e) {
      final errMsg = e.response?.data?['error'] ?? 'Something went wrong';
      state = [...state, ChatMessage(role: 'assistant', content: 'Sorry, I couldn\'t respond: $errMsg')];
    } catch (_) {
      state = [...state, ChatMessage(role: 'assistant', content: 'Something went wrong. Try again?')];
    } finally {
      _sending = false;
      await _saveToHive();
    }
  }

  void clearConversation() {
    state = [];
    _saveToHive();
  }
}

final coachProvider = StateNotifierProvider.autoDispose
    .family<CoachNotifier, List<ChatMessage>, String>(
  (ref, hobbyId) => CoachNotifier(hobbyId, ref),
);

// ═══════════════════════════════════════════════════════
//  HOBBY COACH SCREEN — Premium Guidance Workspace
// ═══════════════════════════════════════════════════════

class HobbyCoachScreen extends ConsumerStatefulWidget {
  final String hobbyId;

  const HobbyCoachScreen({super.key, required this.hobbyId});

  @override
  ConsumerState<HobbyCoachScreen> createState() => _HobbyCoachScreenState();
}

class _HobbyCoachScreenState extends ConsumerState<HobbyCoachScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  late CoachMode _mode;

  @override
  void initState() {
    super.initState();
    _mode = _detectMode();
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

  void _send() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();
    ref.read(coachProvider(widget.hobbyId).notifier).send(text).then((_) {
      final notifier = ref.read(coachProvider(widget.hobbyId).notifier);
      if (notifier.limitHit && mounted) {
        final hobby = ref.read(hobbyByIdProvider(widget.hobbyId)).valueOrNull;
        final title = hobby?.title ?? 'this hobby';
        showProUpgrade(
          context,
          'Keep getting personal guidance for $title. Pro gives you unlimited coach support to stay on track.',
        );
      }
    });
    _scrollToBottom();
  }

  void _sendChip(String text) {
    HapticFeedback.lightImpact();
    _textController.text = text;
    _send();
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

              // Context hero + mode selector (only when no messages)
              if (messages.isEmpty) ...[
                _buildContextHero(hobby),
                const SizedBox(height: 16),
                _buildModeSelector(),
                const SizedBox(height: 12),
              ],

              // Remaining messages banner
              _buildRemainingBanner(),

              // Messages or empty state
              Expanded(
                child: messages.isEmpty
                    ? _buildGuidedActions()
                    : _buildMessageList(messages, notifier),
              ),

              // Compact quick actions (when conversation active)
              if (messages.isNotEmpty) _buildQuickActionsStrip(),

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
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    ).animate().fadeIn(duration: 350.ms, delay: 100.ms);
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
            'HOW CAN I HELP?',
            style: AppTypography.caption.copyWith(
              color: AppColors.textMuted,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
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
              'Get a tiny first session plan'),
          ('Make this cheaper', Icons.savings_outlined,
              'Find the lowest-cost way to begin'),
          ('What do I need to buy?', Icons.shopping_bag_outlined,
              'Essential starter kit only'),
        ];
      case CoachMode.momentum:
        return [
          ('What should I do next?', Icons.arrow_circle_right_outlined,
              'Your next step based on progress'),
          ('Make this easier', Icons.tune_rounded,
              'Simplify your current approach'),
          ('I\'m losing motivation', Icons.battery_2_bar_rounded,
              'Small wins to rebuild momentum'),
        ];
      case CoachMode.rescue:
        return [
          ('I skipped a few days', Icons.replay_rounded,
              'Easy restart, no pressure'),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
        return _CoachBubble(message: messages[index]);
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
          child: Text(
            value == 0
                ? 'No free messages left this month'
                : '$value free message${value == 1 ? '' : 's'} remaining',
            style: AppTypography.caption.copyWith(
              color: isLow ? AppColors.accent : AppColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  // ── Composer ────────────────────────────────────────

  Widget _buildComposer(double bottomInset, double bottomPad) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 10, 10, bottomInset > 0 ? 10 : bottomPad + 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(
          top: BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(22),
                border:
                    Border.all(color: AppColors.glassBorder, width: 0.5),
              ),
              child: TextField(
                controller: _textController,
                style: AppTypography.body.copyWith(fontSize: 14),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
                decoration: InputDecoration(
                  hintText: 'Ask your coach...',
                  hintStyle: AppTypography.caption
                      .copyWith(color: AppColors.textMuted),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _send,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.coral,
              ),
              child: const Icon(Icons.arrow_upward_rounded,
                  size: 20, color: Colors.white),
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

  const _CoachBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';

    if (isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(top: 4, bottom: 4, left: 48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: AppColors.coral,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(4),
            ),
          ),
          child: Text(
            message.content,
            style: AppTypography.body.copyWith(
              color: Colors.white,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ),
      );
    }

    // Assistant — try structured cards first, fall back to plain bubble
    final cards = parseCoachResponse(message.content);
    if (cards != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 6, bottom: 6, right: 16),
        child: CoachCardList(cards: cards),
      );
    }

    // Plain text fallback
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
        child: Text(
          message.content,
          style: AppTypography.body.copyWith(
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.6,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  TYPING INDICATOR
// ═══════════════════════════════════════════════════════

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
    );
  }
}
