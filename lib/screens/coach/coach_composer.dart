import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../components/voice_input.dart';
import '../../providers/subscription_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

// ═══════════════════════════════════════════════════════
//  COACH COMPOSER — Text input, mic, attach, voice, image
// ═══════════════════════════════════════════════════════

class CoachComposer extends ConsumerStatefulWidget {
  final void Function(String text, String? imagePath) onSend;
  final String? prefillText;

  const CoachComposer({super.key, required this.onSend, this.prefillText});

  @override
  ConsumerState<CoachComposer> createState() => _CoachComposerState();
}

class _CoachComposerState extends ConsumerState<CoachComposer> {
  final _textController = TextEditingController();
  bool _voiceActive = false;
  String? _pendingImagePath;

  @override
  void initState() {
    super.initState();
    if (widget.prefillText != null) {
      _textController.text = widget.prefillText!;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _send() {
    final text = _textController.text.trim();
    final imagePath = _pendingImagePath;
    if (text.isEmpty && imagePath == null) return;
    HapticFeedback.lightImpact();
    _textController.clear();
    setState(() => _pendingImagePath = null);
    widget.onSend(text, imagePath);
  }

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

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bottomPad = MediaQuery.of(context).padding.bottom;

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
                                const Icon(Icons.add_circle_outline_rounded,
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
                                const Icon(Icons.mic_rounded,
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
