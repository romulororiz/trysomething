import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/analytics/analytics_provider.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_constants.dart';
import '../../providers/subscription_provider.dart';
import '../../models/hobby.dart';

// ═══════════════════════════════════════════════════════
//  CHAT MESSAGE MODEL
// ═══════════════════════════════════════════════════════

class ChatMessage {
  final String role; // 'user' or 'assistant'
  final String content;
  final String? imageUrl; // Cloudinary URL for attached photo
  final bool imageUploading; // True while image is being uploaded
  final String? quotedText; // Quoted journal entry (WhatsApp-style reply)
  final DateTime timestamp;

  ChatMessage({
    required this.role,
    required this.content,
    this.imageUrl,
    this.imageUploading = false,
    this.quotedText,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'role': role,
        'content': content,
        if (imageUrl != null) 'imageUrl': imageUrl,
        if (quotedText != null) 'quotedText': quotedText,
        'timestamp': timestamp.toIso8601String(),
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        role: json['role'] as String,
        content: json['content'] as String,
        imageUrl: json['imageUrl'] as String?,
        quotedText: json['quotedText'] as String?,
        timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ??
            DateTime.now(),
      );
}

// ═══════════════════════════════════════════════════════
//  COACH MODE
// ═══════════════════════════════════════════════════════

enum CoachMode {
  start('Start', 'Your first session, made simple', Icons.play_arrow_rounded),
  momentum('Momentum', 'What to do next, exactly', Icons.trending_up_rounded),
  rescue('Rescue', 'No guilt. Easy restart.', Icons.support_rounded);

  final String label;
  final String subtitle;
  final IconData icon;
  const CoachMode(this.label, this.subtitle, this.icon);
}

// ═══════════════════════════════════════════════════════
//  MESSAGE LIMIT TRACKER — per-hobby per-month in Hive
// ═══════════════════════════════════════════════════════

class CoachLimitTracker {
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

  static int limitForState(HobbyStatus? status) => 5;
}

/// Exposes remaining messages for a hobby this month.
final coachRemainingProvider =
    FutureProvider.autoDispose.family<int?, String>((ref, hobbyId) async {
  final isPro = ref.watch(isProProvider);
  if (isPro) return null;

  final limit = CoachLimitTracker.limitForState(null);
  final count = await CoachLimitTracker.getCount(hobbyId);
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

  bool _hiveLoaded = false;
  bool get hiveLoaded => _hiveLoaded;

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
    _hiveLoaded = true;
  }

  /// Wait for Hive history to load before sending (prevents race condition).
  Future<void> waitForLoad() async {
    while (!_hiveLoaded) {
      await Future.delayed(const Duration(milliseconds: 10));
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

  String? _focusEntryId;

  bool _clearingForFocus = false;

  void setFocusEntryId(String? id) {
    _focusEntryId = id;
    if (id != null) {
      // Starting a focused conversation — clear stale history so
      // the coach opens fresh for this specific journal entry.
      // Deferred to avoid modifying state during widget tree build.
      _clearingForFocus = true;
      Future.microtask(() async {
        state = [];
        await _saveToHive();
        _clearingForFocus = false;
      });
    }
  }

  Future<void> send(String message, {String? imageUrl, String? quotedText}) async {
    if (_sending || (message.trim().isEmpty && imageUrl == null)) return;

    // Wait for focus entry clear to finish (avoids Hive race)
    while (_clearingForFocus) {
      await Future.delayed(const Duration(milliseconds: 10));
    }

    _limitHit = false;

    // Rate limiting is enforced server-side via GenerationLog.
    // The server returns 429 if the user exceeds their limit.
    // No client-side pre-check — avoids mismatch between
    // client counter (per-hobby Hive) and server counter (global DB).
    _sending = true;

    final userMsg = ChatMessage(
        role: 'user', content: message.trim(), imageUrl: imageUrl, quotedText: quotedText);
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
          if (_focusEntryId != null) 'focusEntryId': _focusEntryId,
          if (imageUrl != null) 'imageUrl': imageUrl,
          'conversationHistory': state.length > 1
              ? state
                  .take(state.length - 1) // exclude the just-added user message
                  .map((m) => {'role': m.role, 'content': m.content})
                  .toList()
              : <Map<String, String>>[],
        },
        options: Options(receiveTimeout: const Duration(seconds: 30)),
      );

      final reply = response.data['response'] as String? ?? '';
      final assistantMsg = ChatMessage(role: 'assistant', content: reply);
      state = [...state, assistantMsg];

      // Clear focus entry after first use — subsequent messages are
      // regular conversation, no need to re-send the image.
      _focusEntryId = null;

      ref.read(analyticsProvider).trackEvent('coach_message_sent', {
        'hobby_id': hobbyId,
        'message_count': state.length,
      });

      // Server logs the message to GenerationLog — no client-side tracking needed
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        // Check if client already thinks user is Pro (webhook race condition).
        // RevenueCat SDK may confirm Pro before the server DB updates via webhook.
        final isPro = ref.read(isProProvider);
        if (isPro) {
          // Subscription sync delay — don't show upgrade prompt.
          // Refresh from RevenueCat to re-confirm, then suggest retry.
          ref.read(proStatusProvider.notifier).refresh();
          state = [...state, ChatMessage(role: 'assistant', content: 'Your subscription is still syncing with the server. Please wait a moment and try again.')];
        } else {
          _limitHit = true;
          state = [...state, ChatMessage(role: 'assistant', content: 'You\'ve reached your free message limit. Upgrade to Pro for unlimited coaching.')];
        }
      } else {
        final errMsg = e.response?.data?['error'] ?? 'Something went wrong';
        state = [...state, ChatMessage(role: 'assistant', content: 'Sorry, I couldn\'t respond: $errMsg')];
      }
    } catch (e, st) {
      debugPrint('[Coach] Unexpected error: $e');
      debugPrint('[Coach] Stack: $st');
      state = [...state, ChatMessage(role: 'assistant', content: 'Something went wrong. Try again?')];
    } finally {
      _sending = false;
      await _saveToHive();
    }
  }

  /// Show user message immediately while image uploads.
  void addPendingMessage(String text, {bool hasImage = false}) {
    _sending = true;
    state = [
      ...state,
      ChatMessage(role: 'user', content: text, imageUploading: hasImage),
    ];
  }

  /// Remove the last user message (upload failed).
  void removePendingMessage() {
    _sending = false;
    if (state.isNotEmpty && state.last.role == 'user') {
      state = state.sublist(0, state.length - 1);
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
//  COACH ENTRY CONTEXT — passed from entry points
// ═══════════════════════════════════════════════════════

/// Context passed when opening the coach from a specific entry point.
class CoachEntryContext {
  /// Shown in text field (autoSend=false) or auto-sent (autoSend=true).
  final String? prefilledMessage;

  /// Override the auto-detected coach mode.
  final CoachMode? forceMode;

  /// If true, the prefilled message is sent automatically after first frame.
  final bool autoSend;

  /// If set, the server highlights this journal entry in the coach's context
  /// so it knows which reflection the user is referring to.
  final String? focusEntryId;

  /// Journal entry text shown as a quoted reply in the user bubble.
  final String? quotedText;

  const CoachEntryContext({
    this.prefilledMessage,
    this.forceMode,
    this.autoSend = false,
    this.focusEntryId,
    this.quotedText,
  });
}
