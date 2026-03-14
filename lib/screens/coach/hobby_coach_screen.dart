import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import '../../models/hobby.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

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

  /// Returns the message limit for this hobby based on user state.
  /// null = unlimited (Pro users bypass this entirely).
  ///
  /// Strategy: free users get enough to feel value, then Pro converts
  /// at the moment of highest engagement (active + stuck).
  ///   Browsing (unsaved): 3 messages — taste the value, then save/start
  ///   Saved:              5 messages — exploring, building commitment
  ///   Active/Trying:      5 messages — enough to get hooked on support
  ///   Done:               2 messages — light check-in only
  static int? limitForState(HobbyStatus? status) {
    if (status == null) return 3; // browsing — taste value
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
  if (isPro) return null; // unlimited

  final userHobbies = ref.watch(userHobbiesProvider);
  final userHobby = userHobbies[hobbyId];
  final limit = _CoachLimitTracker.limitForState(userHobby?.status);
  if (limit == null) return null; // not saved = unlimited

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

  /// Set to true when a send was blocked by limit.
  bool _limitHit = false;
  bool get limitHit => _limitHit;

  CoachNotifier(this.hobbyId, this.ref) : super([]) {
    _loadFromHive();
  }

  static const _boxName = 'coach_conversations';

  Future<void> _loadFromHive() async {
    final box = await Hive.openBox(_boxName);
    final raw = box.get(hobbyId);
    if (raw != null && raw is List) {
      state = raw
          .cast<Map>()
          .map((m) => ChatMessage.fromJson(Map<String, dynamic>.from(m)))
          .toList();
    }
  }

  Future<void> _saveToHive() async {
    final box = await Hive.openBox(_boxName);
    await box.put(hobbyId, state.map((m) => m.toJson()).toList());
  }

  Future<void> send(String message) async {
    if (_sending || message.trim().isEmpty) return;
    _limitHit = false;

    // Check message limits for free users
    final isPro = ref.read(isProProvider);
    if (!isPro) {
      final userHobbies = ref.read(userHobbiesProvider);
      final userHobby = userHobbies[hobbyId];
      final limit = _CoachLimitTracker.limitForState(userHobby?.status);
      if (limit != null) {
        final count = await _CoachLimitTracker.getCount(hobbyId);
        if (count >= limit) {
          _limitHit = true;
          // Trigger UI rebuild so the screen can show upgrade sheet
          state = [...state];
          return;
        }
      }
    }

    _sending = true;

    // Add user message
    final userMsg = ChatMessage(role: 'user', content: message.trim());
    state = [...state, userMsg];

    try {
      final history = state
          .map((m) => {'role': m.role, 'content': m.content})
          .toList();
      // Remove the last entry (current user message) — it's sent as `message`
      if (history.isNotEmpty) history.removeLast();

      final response = await ApiClient.instance.post(
        ApiConstants.coachChat,
        data: {
          'hobbyId': hobbyId,
          'message': message.trim(),
          'conversationHistory': history,
        },
      );

      final text = response.data['response'] as String? ?? '';
      final assistantMsg = ChatMessage(role: 'assistant', content: text);
      state = [...state, assistantMsg];

      ref.read(analyticsProvider).trackEvent('coach_message_sent', {
        'hobby_id': hobbyId,
      });

      // Increment count after successful exchange (only for non-Pro)
      if (!isPro) {
        await _CoachLimitTracker.increment(hobbyId);
        ref.invalidate(coachRemainingProvider(hobbyId));
      }
    } on DioException catch (e) {
      final errMsg = e.response?.data?['error'] ?? 'Something went wrong';
      final errorResponse =
          ChatMessage(role: 'assistant', content: 'Sorry, I couldn\'t respond: $errMsg');
      state = [...state, errorResponse];
    } catch (_) {
      state = [
        ...state,
        ChatMessage(
            role: 'assistant', content: 'Something went wrong. Try again?'),
      ];
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
//  HOBBY COACH SCREEN
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

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();
    ref.read(coachProvider(widget.hobbyId).notifier).send(text).then((_) {
      final notifier = ref.read(coachProvider(widget.hobbyId).notifier);
      if (notifier.limitHit && mounted) {
        final hobby =
            ref.read(hobbyByIdProvider(widget.hobbyId)).valueOrNull;
        final title = hobby?.title ?? 'this hobby';
        showProUpgrade(
          context,
          'Keep getting personal guidance for $title. Pro gives you unlimited coach support to stay on track.',
        );
      }
    });
    _scrollToBottom();
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

    // Auto-scroll when messages change
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
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
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(hobbyTitle,
                            style: AppTypography.sansLabel
                                .copyWith(color: AppColors.textSecondary)),
                        Text('AI Coach',
                            style: AppTypography.sansTiny
                                .copyWith(color: AppColors.coral)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      notifier.clearConversation();
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.glassBackground,
                      ),
                      child: const Icon(Icons.refresh_rounded,
                          size: 18, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 24, color: AppColors.border),

            // Remaining messages indicator (free users only)
            _buildRemainingBanner(),

            // Messages
            Expanded(
              child: messages.isEmpty
                  ? _buildEmptyState(hobbyTitle)
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      itemCount: messages.length +
                          (notifier.isSending ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == messages.length) {
                          return const _TypingIndicator();
                        }
                        return _ChatBubble(message: messages[index]);
                      },
                    ),
            ),

            // Input bar
            Container(
              color: AppColors.surface,
              padding: EdgeInsets.fromLTRB(
                  16, 10, 10, bottomInset > 0 ? 10 : bottomPad + 10),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: TextField(
                        controller: _textController,
                        style: AppTypography.body,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemainingBanner() {
    final remaining = ref.watch(coachRemainingProvider(widget.hobbyId));
    return remaining.when(
      data: (value) {
        if (value == null) return const SizedBox.shrink(); // unlimited
        final color = value <= 1 ? AppColors.coral : AppColors.textSecondary;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
          color: AppColors.surface,
          child: Text(
            value == 0
                ? 'No free messages left this month'
                : '$value free message${value == 1 ? '' : 's'} left this month',
            style: AppTypography.sansTiny.copyWith(color: color),
            textAlign: TextAlign.center,
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  /// Pick starter chips based on user's hobby state (start/momentum/rescue).
  List<String> _getStarterChips() {
    final userHobbies = ref.read(userHobbiesProvider);
    final userHobby = userHobbies[widget.hobbyId];

    if (userHobby == null || userHobby.status == HobbyStatus.saved) {
      // Start mode — not started yet
      return [
        'Help me start tonight',
        'Make this cheaper',
        'What do I need to buy?',
      ];
    }

    // Check for stalled state (rescue mode): no activity in 7+ days
    final lastActive = userHobby.startedAt ?? DateTime.now();
    final daysSinceActive = DateTime.now().difference(lastActive).inDays;
    if (daysSinceActive >= 7) {
      // Rescue mode
      return [
        'I skipped a few days',
        'I\'m losing motivation',
        'Maybe this hobby isn\'t for me',
      ];
    }

    // Momentum mode — actively trying
    return [
      'What should I do next?',
      'I\'m losing motivation',
      'Make this easier',
    ];
  }

  Widget _buildEmptyState(String hobbyTitle) {
    final chips = _getStarterChips();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.coral.withValues(alpha: 0.1),
              ),
              child: const Icon(Icons.auto_awesome,
                  size: 28, color: AppColors.coral),
            ),
            const SizedBox(height: 16),
            Text(
              'Your $hobbyTitle Coach',
              style: AppTypography.title.copyWith(fontSize: 17),
            ),
            const SizedBox(height: 8),
            Text(
              'Ask questions, get tips, or share\nyour progress. I\'m here to help!',
              textAlign: TextAlign.center,
              style:
                  AppTypography.caption.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            // Starter chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: chips.map((chip) => GestureDetector(
                onTap: () {
                  _textController.text = chip;
                  _send();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.glassBackground,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: Text(
                    chip,
                    style: AppTypography.sansTiny.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  CHAT BUBBLE
// ═══════════════════════════════════════════════════════

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          top: 6,
          bottom: 6,
          left: isUser ? 48 : 0,
          right: isUser ? 0 : 48,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? AppColors.coral : AppColors.glassBackground,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 18),
          ),
        ),
        child: Text(
          message.content,
          style: AppTypography.body.copyWith(
            color: isUser ? Colors.white : AppColors.textSecondary,
            height: 1.5,
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
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                final delay = i * 0.2;
                final t = (_controller.value - delay).clamp(0.0, 1.0);
                final scale = 0.5 + 0.5 * (0.5 + 0.5 * (1 - (2 * t - 1).abs()));
                return Padding(
                  padding: EdgeInsets.only(left: i > 0 ? 4 : 0),
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.textSecondary.withValues(alpha: 0.4),
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
