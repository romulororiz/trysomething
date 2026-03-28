import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../components/app_background.dart';
import '../../components/app_overlays.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_constants.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/spacing.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  // Step 1: email, Step 2: code + new password
  int _step = 1;
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _codeControllers = List.generate(6, (_) => TextEditingController());
  final _codeFocusNodes = List.generate(6, (_) => FocusNode());
  bool _loading = false;
  String? _error;
  bool _obscurePassword = true;
  int _cooldown = 0;
  Timer? _cooldownTimer;

  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    for (final c in _codeControllers) {
      c.dispose();
    }
    for (final f in _codeFocusNodes) {
      f.dispose();
    }
    _shakeController.dispose();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    _cooldown = 60;
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _cooldown--);
      if (_cooldown <= 0) _cooldownTimer?.cancel();
    });
  }

  String get _code => _codeControllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    if (_error != null) setState(() => _error = null);

    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
      for (var i = 0; i < 6 && i < digits.length; i++) {
        _codeControllers[i].text = digits[i];
      }
      if (digits.length >= 6) {
        _codeFocusNodes.last.requestFocus();
      } else {
        _codeFocusNodes[digits.length.clamp(0, 5)].requestFocus();
      }
      return;
    }

    HapticFeedback.lightImpact();
    if (value.isNotEmpty && index < 5) {
      _codeFocusNodes[index + 1].requestFocus();
    }
  }

  void _onKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _codeControllers[index].text.isEmpty &&
        index > 0) {
      _codeControllers[index - 1].clear();
      _codeFocusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _sendCode() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Enter a valid email address');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await ApiClient.instance.post(
        ApiConstants.authForgotPassword,
        data: {'email': email},
      );
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      _startCooldown();
      setState(() {
        _step = 2;
        _loading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _codeFocusNodes[0].requestFocus();
      });
    } on DioException catch (e) {
      if (!mounted) return;
      final msg = e.response?.data is Map
          ? (e.response!.data['error'] ?? 'Something went wrong')
          : 'Something went wrong';
      setState(() {
        _loading = false;
        _error = msg.toString();
      });
    }
  }

  Future<void> _resetPassword() async {
    final code = _code;
    if (code.length != 6) {
      setState(() => _error = 'Enter the 6-digit code');
      return;
    }
    final password = _passwordCtrl.text;
    if (password.length < 8) {
      setState(() => _error = 'Password must be at least 8 characters');
      return;
    }
    if (password != _confirmCtrl.text) {
      setState(() => _error = 'Passwords do not match');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await ApiClient.instance.post(
        ApiConstants.authResetPassword,
        data: {
          'email': _emailCtrl.text.trim(),
          'code': code,
          'newPassword': password,
        },
      );
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      showAppSnackbar(context,
          message: 'Password reset! Sign in with your new password.',
          type: AppSnackbarType.success);
      context.go('/login');
    } on DioException catch (e) {
      if (!mounted) return;
      final msg = e.response?.data is Map
          ? (e.response!.data['error'] ?? 'Something went wrong')
          : 'Something went wrong';

      if (msg.toString().contains('Invalid') || msg.toString().contains('expired')) {
        HapticFeedback.heavyImpact();
        _shakeController.forward(from: 0);
        for (final c in _codeControllers) {
          c.clear();
        }
        _codeFocusNodes[0].requestFocus();
      }

      setState(() {
        _loading = false;
        _error = msg.toString();
      });
    }
  }

  Future<void> _resendCode() async {
    if (_cooldown > 0) return;
    await _sendCode();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Back button
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 0, 0),
                  child: GestureDetector(
                    onTap: () {
                      if (_step == 2) {
                        setState(() {
                          _step = 1;
                          _error = null;
                        });
                      } else {
                        context.pop();
                      }
                    },
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.glassBackground,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.glassBorder, width: 0.5),
                      ),
                      child: const Icon(Icons.arrow_back_rounded,
                          size: 18, color: AppColors.textSecondary),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: _step == 1 ? _buildEmailStep() : _buildCodeStep(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.coral.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.lock_reset_rounded,
              size: 30, color: AppColors.coral),
        ),
        const SizedBox(height: 28),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: AppTypography.title.copyWith(fontSize: 28),
            children: [
              const TextSpan(text: 'Reset your '),
              TextSpan(
                text: 'password',
                style: TextStyle(color: AppColors.coral),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "Enter your email and we'll send you a code to reset your password.",
          style: AppTypography.body
              .copyWith(color: AppColors.textMuted, fontSize: 14),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        TextField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          style: AppTypography.body.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Email address',
            hintStyle:
                AppTypography.body.copyWith(color: AppColors.textMuted),
            filled: true,
            fillColor: AppColors.surface,
            prefixIcon: const Icon(Icons.mail_outline_rounded,
                size: 18, color: AppColors.textMuted),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.glassBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.glassBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.coral, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildError(),
        const SizedBox(height: 12),
        _buildCta('Send reset code', _sendCode),
      ],
    );
  }

  Widget _buildCodeStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.coral.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.verified_user_outlined,
              size: 30, color: AppColors.coral),
        ),
        const SizedBox(height: 28),
        Text(
          'Enter your code',
          style: AppTypography.title.copyWith(fontSize: 28),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'We sent a code to',
          style: AppTypography.body
              .copyWith(color: AppColors.textMuted, fontSize: 14),
        ),
        const SizedBox(height: 4),
        Text(
          _emailCtrl.text.trim(),
          style: AppTypography.body.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 28),

        // 6-digit code input
        AnimatedBuilder(
          animation: _shakeController,
          builder: (context, child) {
            final dx = _shakeController.isAnimating
                ? 10 *
                    (0.5 - (_shakeController.value * 4 % 1.0)).abs() *
                    (1 - _shakeController.value)
                : 0.0;
            return Transform.translate(
                offset: Offset(dx, 0), child: child);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(6, (i) {
              return Padding(
                padding: EdgeInsets.only(right: i < 5 ? 8 : 0),
                child: SizedBox(
                  width: 48,
                  height: 56,
                  child: KeyboardListener(
                    focusNode: FocusNode(),
                    onKeyEvent: (e) => _onKeyEvent(i, e),
                    child: TextField(
                      controller: _codeControllers[i],
                      focusNode: _codeFocusNodes[i],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 6,
                      style: AppTypography.body.copyWith(
                        fontFamily: 'IBM Plex Mono',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: AppColors.surface,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: AppColors.glassBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: AppColors.glassBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: AppColors.coral, width: 1.5),
                        ),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onChanged: (v) => _onDigitChanged(i, v),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 24),

        // New password
        TextField(
          controller: _passwordCtrl,
          obscureText: _obscurePassword,
          style: AppTypography.body.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'New password (min 8 chars)',
            hintStyle:
                AppTypography.body.copyWith(color: AppColors.textMuted),
            filled: true,
            fillColor: AppColors.surface,
            prefixIcon: const Icon(Icons.lock_outline_rounded,
                size: 18, color: AppColors.textMuted),
            suffixIcon: GestureDetector(
              onTap: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
              child: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 18,
                color: AppColors.textMuted,
              ),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.glassBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.glassBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.coral, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _confirmCtrl,
          obscureText: _obscurePassword,
          style: AppTypography.body.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Confirm new password',
            hintStyle:
                AppTypography.body.copyWith(color: AppColors.textMuted),
            filled: true,
            fillColor: AppColors.surface,
            prefixIcon: const Icon(Icons.lock_outline_rounded,
                size: 18, color: AppColors.textMuted),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.glassBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.glassBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.coral, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildError(),
        const SizedBox(height: 12),
        _buildCta('Reset Password', _resetPassword),
        const SizedBox(height: 24),

        // Resend row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Didn't get the code? ",
              style: AppTypography.caption
                  .copyWith(color: AppColors.textMuted, fontSize: 13),
            ),
            if (_cooldown > 0)
              Text(
                '0:${_cooldown.toString().padLeft(2, '0')}',
                style: AppTypography.body.copyWith(
                  fontFamily: 'IBM Plex Mono',
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              )
            else
              GestureDetector(
                onTap: _resendCode,
                child: Text(
                  'Resend',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.coral,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildError() {
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      child: _error != null
          ? Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                _error!,
                style: AppTypography.caption
                    .copyWith(color: AppColors.coral, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildCta(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: _loading ? null : onTap,
      child: Container(
        width: double.infinity,
        height: Spacing.buttonCtaHeight,
        decoration: BoxDecoration(
          color: AppColors.coral,
          borderRadius: BorderRadius.circular(Spacing.radiusCta),
          boxShadow: [
            BoxShadow(
              color: AppColors.coral.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: _loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  label,
                  style: AppTypography.body.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
        ),
      ),
    );
  }
}
