import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Voice input widget with audio amplitude visualizer.
///
/// Shows animated bars that react to voice volume, auto-stops on silence,
/// and returns transcribed text via [onResult].
class VoiceInputOverlay extends StatefulWidget {
  final ValueChanged<String> onResult;
  final VoidCallback onCancel;

  const VoiceInputOverlay({
    super.key,
    required this.onResult,
    required this.onCancel,
  });

  @override
  State<VoiceInputOverlay> createState() => _VoiceInputOverlayState();
}

class _VoiceInputOverlayState extends State<VoiceInputOverlay>
    with TickerProviderStateMixin {
  final SpeechToText _speech = SpeechToText();
  bool _isListening = false;
  bool _hasInput = false;
  String _lastWords = '';

  // Bars state — 7 bars with independent smooth animations
  static const _barCount = 7;
  late final List<AnimationController> _barControllers;
  late final List<Animation<double>> _barAnimations;
  final _random = Random();

  // Silence detection
  Timer? _silenceTimer;
  static const _silenceTimeout = Duration(seconds: 2);

  @override
  void initState() {
    super.initState();
    _barControllers = List.generate(_barCount, (_) {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 150),
      );
    });
    _barAnimations = _barControllers.map((c) {
      return Tween<double>(begin: 0.15, end: 1.0).animate(
        CurvedAnimation(parent: c, curve: Curves.easeOutCubic),
      );
    }).toList();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    try {
      final available = await _speech.initialize(
        onStatus: (status) {
          debugPrint('[Voice] Status: $status');
          _onStatus(status);
        },
        onError: (error) {
          debugPrint('[Voice] Error: ${error.errorMsg} (permanent: ${error.permanent})');
          if (mounted && error.permanent) _finishListening();
        },
      );
      debugPrint('[Voice] Available: $available');
      if (available && mounted) {
        _startListening();
      } else if (mounted) {
        debugPrint('[Voice] Speech recognition not available');
        widget.onCancel();
      }
    } catch (e) {
      debugPrint('[Voice] Init exception: $e');
      if (mounted) widget.onCancel();
    }
  }

  void _startListening() {
    HapticFeedback.lightImpact();
    _speech.listen(
      onResult: (result) {
        setState(() {
          _lastWords = result.recognizedWords;
          if (_lastWords.isNotEmpty) _hasInput = true;
        });
        _resetSilenceTimer();
        if (result.finalResult && _lastWords.isNotEmpty) {
          _finishListening();
        }
      },
      onSoundLevelChange: (level) {
        // level ranges roughly -2 to 10 on Android
        final normalized = ((level + 2) / 12).clamp(0.0, 1.0);
        if (normalized > 0.2 && !_hasInput) {
          setState(() => _hasInput = true);
        } else if (normalized <= 0.05 && _hasInput && _lastWords.isEmpty) {
          setState(() => _hasInput = false);
        }
        _updateBars(normalized);
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: _silenceTimeout,
    );
    setState(() => _isListening = true);
    _resetSilenceTimer();
  }

  void _resetSilenceTimer() {
    _silenceTimer?.cancel();
    _silenceTimer = Timer(_silenceTimeout, () {
      if (_isListening && _lastWords.isNotEmpty) {
        _finishListening();
      }
    });
  }

  void _onStatus(String status) {
    if (status == 'done' || status == 'notListening') {
      if (_lastWords.isNotEmpty && mounted) {
        _finishListening();
      }
    }
  }

  void _finishListening() {
    _silenceTimer?.cancel();
    _speech.stop();
    setState(() => _isListening = false);
    if (_lastWords.trim().isNotEmpty) {
      HapticFeedback.mediumImpact();
      widget.onResult(_lastWords.trim());
    } else {
      widget.onCancel();
    }
  }

  void _updateBars(double level) {
    for (int i = 0; i < _barCount; i++) {
      // Each bar gets a slightly different target for organic feel
      final variance = (_random.nextDouble() * 0.4) - 0.2;
      final target = (level + variance).clamp(0.1, 1.0);
      final controller = _barControllers[i];
      final tween = Tween<double>(
        begin: _barAnimations[i].value,
        end: target,
      );
      _barAnimations[i] = tween.animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
      );
      controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _silenceTimer?.cancel();
    _speech.stop();
    for (final c in _barControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Color get _activeColor => _hasInput ? AppColors.success : AppColors.coral;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _finishListening,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        height: 48,
        decoration: BoxDecoration(
          color: _activeColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _activeColor.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            // Mic icon (pulsing)
            Padding(
              padding: const EdgeInsets.only(left: 14),
              child: _PulsingDot(isActive: _isListening, color: _activeColor),
            ),
            const SizedBox(width: 10),

            // Visualizer bars or transcribed text
            Expanded(
              child: _lastWords.isEmpty
                  ? _buildBars()
                  : Text(
                      _lastWords,
                      style: AppTypography.body.copyWith(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
            ),

            // Cancel / stop button
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: GestureDetector(
                onTap: () {
                  _speech.stop();
                  widget.onCancel();
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surfaceElevated,
                    border: Border.all(
                        color: AppColors.glassBorder, width: 0.5),
                  ),
                  child: const Icon(Icons.close_rounded,
                      size: 14, color: AppColors.textMuted),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBars() {
    return SizedBox(
      height: 24,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(_barCount, (i) {
          return AnimatedBuilder(
            animation: _barControllers[i],
            builder: (context, _) {
              final height = 4 + (_barAnimations[i].value * 20);
              return Container(
                width: 3,
                height: height,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: _activeColor,
                  borderRadius: BorderRadius.circular(1.5),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

/// Small pulsing dot indicating active recording.
class _PulsingDot extends StatefulWidget {
  final bool isActive;
  final Color color;
  const _PulsingDot({required this.isActive, required this.color});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) {
      return Icon(Icons.mic_rounded, size: 18, color: widget.color);
    }
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color
                .withValues(alpha: 0.6 + _controller.value * 0.4),
          ),
        );
      },
    );
  }
}
