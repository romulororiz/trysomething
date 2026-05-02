import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/media/image_upload.dart';
import '../../providers/auth_provider.dart';
import '../../components/app_overlays.dart';
import '../../components/photo_picker_overlay.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

// ── Edit profile bottom sheet ──

class EditProfileSheet extends StatefulWidget {
  final WidgetRef ref;
  final String initialName;
  final String initialBio;
  final String email;
  final String? avatarUrl;
  final bool hasPassword;

  const EditProfileSheet({
    super.key,
    required this.ref,
    required this.initialName,
    required this.initialBio,
    required this.email,
    required this.avatarUrl,
    this.hasPassword = true,
  });

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _bioCtrl;
  final _currentPwCtrl = TextEditingController();
  final _newPwCtrl = TextEditingController();
  final _confirmPwCtrl = TextEditingController();
  String? _pendingAvatarUrl;
  bool _saving = false;
  bool _picking = false;
  bool _pwExpanded = false;
  bool _pwSaving = false;
  String? _pwError;
  bool _pwObscureCurrent = true;
  bool _pwObscureNew = true;
  late final AnimationController _pwAnim;
  late final Animation<double> _pwSizeFactor;
  late final Animation<double> _pwOpacity;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialName);
    _bioCtrl = TextEditingController(text: widget.initialBio);
    _pwAnim = AnimationController(
      duration: const Duration(milliseconds: 280),
      vsync: this,
    );
    _pwSizeFactor = CurvedAnimation(
      parent: _pwAnim,
      curve: Curves.easeInOutCubic,
    );
    _pwOpacity = CurvedAnimation(
      parent: _pwAnim,
      curve: const Interval(0.0, 0.75, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    _currentPwCtrl.dispose();
    _newPwCtrl.dispose();
    _confirmPwCtrl.dispose();
    _pwAnim.dispose();
    super.dispose();
  }

  void _togglePasswordSection() {
    setState(() {
      _pwExpanded = !_pwExpanded;
      _pwError = null;
    });
    if (_pwExpanded) {
      _pwAnim.forward();
    } else {
      _pwAnim.reverse();
    }
  }

  Future<void> _changePassword() async {
    final current = _currentPwCtrl.text;
    final newPw = _newPwCtrl.text;
    final confirm = _confirmPwCtrl.text;

    if (current.isEmpty) {
      setState(() => _pwError = 'Enter your current password');
      return;
    }
    if (newPw.length < 8) {
      setState(() => _pwError = 'New password must be at least 8 characters');
      return;
    }
    if (newPw != confirm) {
      setState(() => _pwError = 'Passwords don\'t match');
      return;
    }

    setState(() {
      _pwSaving = true;
      _pwError = null;
    });

    final error = await widget.ref.read(authProvider.notifier).changePassword(
          currentPassword: current,
          newPassword: newPw,
        );

    if (!mounted) return;

    if (error != null) {
      setState(() {
        _pwSaving = false;
        _pwError = error;
      });
    } else {
      setState(() {
        _pwSaving = false;
        _pwExpanded = false;
      });
      _currentPwCtrl.clear();
      _newPwCtrl.clear();
      _confirmPwCtrl.clear();
      showAppSnackbar(context,
          message: 'Password updated', type: AppSnackbarType.success);
    }
  }

  void _pickPhoto() {
    if (_picking) return;
    _showPhotoPickerMenu(context);
  }

  void _showPhotoPickerMenu(BuildContext ctx) {
    final renderBox = ctx.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final overlay = Overlay.of(ctx);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => PhotoPickerOverlay(
        onCamera: () {
          entry.remove();
          _pickAndUpload(ImageSource.camera);
        },
        onGallery: () {
          entry.remove();
          _pickAndUpload(ImageSource.gallery);
        },
        onDismiss: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }

  Future<void> _pickAndUpload(ImageSource source) async {
    if (_picking) return;
    _picking = true;
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (picked == null) return;
      setState(() => _saving = true);
      try {
        final url = await ImageUpload.moderateAndUpload(File(picked.path));
        if (!mounted) return;
        setState(() => _saving = false);
        if (url != null) {
          setState(() => _pendingAvatarUrl = url);
        } else {
          showAppSnackbar(context,
              message: 'Failed to upload photo', type: AppSnackbarType.error);
        }
      } on ImageModerationException catch (e) {
        if (!mounted) return;
        setState(() => _saving = false);
        showAppSnackbar(context,
            message: e.reason, type: AppSnackbarType.error);
      }
    } finally {
      _picking = false;
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final name = _nameCtrl.text.trim();
    final bio = _bioCtrl.text.trim();
    await widget.ref.read(authProvider.notifier).updateProfile(
          displayName: name.isNotEmpty ? name : null,
          bio: bio.isNotEmpty ? bio : null,
          avatarUrl: _pendingAvatarUrl,
        );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveAvatar = _pendingAvatarUrl ?? widget.avatarUrl;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1C1C24), Color(0xFF131318)],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.08), width: 0.5),
      ),
      padding: EdgeInsets.fromLTRB(24, 14, 24, 28 + bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Header row — title + close
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Edit Profile', style: AppTypography.sansSection),
                      const SizedBox(height: 3),
                      Text(
                        'How you appear in TrySomething',
                        style: AppTypography.sansTiny
                            .copyWith(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.07),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: const Icon(Icons.close_rounded,
                        size: 16, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Avatar picker — centered with name below
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickPhoto,
                    child: Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF252530), Color(0xFF1A1A28)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(
                              color: AppColors.coral.withValues(alpha: 0.3),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.coral.withValues(alpha: 0.12),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: effectiveAvatar != null &&
                                    effectiveAvatar.isNotEmpty
                                ? (effectiveAvatar.startsWith('http')
                                    ? CachedNetworkImage(
                                        imageUrl: effectiveAvatar,
                                        fit: BoxFit.cover,
                                        placeholder: (_, __) =>
                                            const SizedBox.shrink(),
                                        errorWidget: (_, __, ___) =>
                                            ProfileInitials(
                                                name: _nameCtrl.text),
                                      )
                                    : Image.network(effectiveAvatar,
                                        fit: BoxFit.cover))
                                : ProfileInitials(name: _nameCtrl.text),
                          ),
                        ),
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: const Color(0xFF1C1C24), width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppColors.accent.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.camera_alt_rounded,
                                size: 13, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Change photo',
                    style: AppTypography.sansTiny.copyWith(
                      color: AppColors.coral,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Divider
            Container(
              height: 0.5,
              color: Colors.white.withValues(alpha: 0.06),
            ),
            const SizedBox(height: 24),

            // Email (read-only)
            if (widget.email.isNotEmpty) ...[
              const _FieldLabel('Email'),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.06)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_outline_rounded,
                        size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.email,
                        style: AppTypography.sansLabel
                            .copyWith(color: AppColors.textMuted),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Name
            const _FieldLabel('Display name'),
            const SizedBox(height: 8),
            _SheetTextField(controller: _nameCtrl, hint: 'Your name'),
            const SizedBox(height: 16),

            // Bio
            // _FieldLabel('Bio'),
            // const SizedBox(height: 8),
            // _SheetTextField(
            //   controller: _bioCtrl,
            //   hint: 'Tell people what you\'re into (optional)',
            //   maxLines: 3,
            // ),
            // Password change (email users only)
            if (widget.hasPassword) ...[
              const SizedBox(height: 8),
              Container(
                height: 0.5,
                color: Colors.white.withValues(alpha: 0.06),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _togglePasswordSection,
                child: Row(
                  children: [
                    Icon(
                      Icons.lock_outline_rounded,
                      size: 16,
                      color: _pwExpanded
                          ? AppColors.coral
                          : AppColors.textMuted,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Change password',
                        style: AppTypography.sansLabel.copyWith(
                          color: _pwExpanded
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: _pwExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(
                        Icons.expand_more_rounded,
                        size: 20,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              SizeTransition(
                sizeFactor: _pwSizeFactor,
                axisAlignment: -1.0,
                child: FadeTransition(
                  opacity: _pwOpacity,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _FieldLabel('Current password'),
                        const SizedBox(height: 8),
                        _PasswordField(
                          controller: _currentPwCtrl,
                          hint: 'Enter current password',
                          obscure: _pwObscureCurrent,
                          onToggle: () => setState(
                              () => _pwObscureCurrent = !_pwObscureCurrent),
                        ),
                        const SizedBox(height: 14),
                        const _FieldLabel('New password'),
                        const SizedBox(height: 8),
                        _PasswordField(
                          controller: _newPwCtrl,
                          hint: 'At least 8 characters',
                          obscure: _pwObscureNew,
                          onToggle: () =>
                              setState(() => _pwObscureNew = !_pwObscureNew),
                        ),
                        const SizedBox(height: 14),
                        const _FieldLabel('Confirm new password'),
                        const SizedBox(height: 8),
                        _SheetTextField(
                          controller: _confirmPwCtrl,
                          hint: 'Re-enter new password',
                          obscure: true,
                        ),
                        if (_pwError != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            _pwError!,
                            style: AppTypography.sansTiny.copyWith(
                              color: AppColors.coral,
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: _pwSaving ? null : _changePassword,
                          child: Container(
                            width: double.infinity,
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: _pwSaving
                                  ? AppColors.surfaceElevated
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    AppColors.coral.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Center(
                              child: _pwSaving
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.coral,
                                      ),
                                    )
                                  : Text(
                                      'Update password',
                                      style: AppTypography.sansCta.copyWith(
                                        color: AppColors.coral,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Save button
            GestureDetector(
              onTap: _saving ? null : _save,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: _saving
                      ? null
                      : const LinearGradient(
                          colors: [Color(0xFFFF6B6B), Color(0xFFE85555)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  color:
                      _saving ? AppColors.accent.withValues(alpha: 0.4) : null,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: _saving
                      ? null
                      : [
                          BoxShadow(
                            color: AppColors.coral.withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: Center(
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Save changes',
                          style: AppTypography.button.copyWith(
                            color: Colors.white,
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
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: AppTypography.overline.copyWith(
        color: AppColors.textMuted,
        letterSpacing: 1.2,
        fontSize: 10,
      ),
    );
  }
}

class _SheetTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;

  const _SheetTextField({
    required this.controller,
    required this.hint,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: 1,
      obscureText: obscure,
      style: AppTypography.sansLabel.copyWith(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTypography.sansLabel.copyWith(color: AppColors.textMuted),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: AppColors.accent.withValues(alpha: 0.6)),
        ),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final VoidCallback onToggle;

  const _PasswordField({
    required this.controller,
    required this.hint,
    required this.obscure,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: AppTypography.sansLabel.copyWith(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTypography.sansLabel.copyWith(color: AppColors.textMuted),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        suffixIcon: GestureDetector(
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Icon(
              obscure
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
              size: 18,
              color: AppColors.textMuted,
            ),
          ),
        ),
        suffixIconConstraints:
            const BoxConstraints(minHeight: 18, minWidth: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: AppColors.accent.withValues(alpha: 0.6)),
        ),
      ),
    );
  }
}

/// Initials fallback for profile avatar -- shows first letter of name.
/// Public because it is shared between EditProfileSheet and _ProfileSection
/// in settings_screen.dart.
class ProfileInitials extends StatelessWidget {
  final String name;
  const ProfileInitials({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: AppTypography.title.copyWith(
          color: AppColors.textMuted,
          fontSize: 22,
        ),
      ),
    );
  }
}
