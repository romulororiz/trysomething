import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/spacing.dart';

/// Registration screen — display name, email, password, confirm password.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authProvider.notifier).register(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          displayName: _nameCtrl.text.trim(),
        );

    if (success && mounted) {
      // New user → go through onboarding
      context.go('/onboarding');
    }
  }

  Future<void> _googleSignUp() async {
    final success = await ref.read(authProvider.notifier).loginWithGoogle();
    if (success && mounted) {
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Brand ──
                  Center(
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.indigo, AppColors.coral],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: Text(
                          'T',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text('Create account', style: AppTypography.serifHeading),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Text(
                      'Start discovering hobbies you\u2019ll love',
                      style: AppTypography.sansBodySmall
                          .copyWith(color: AppColors.warmGray),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Error ──
                  if (authState.error != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.rosePale,
                        borderRadius:
                            BorderRadius.circular(Spacing.radiusInput),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded,
                              size: 18, color: AppColors.rose),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              authState.error!,
                              style: AppTypography.sansCaption
                                  .copyWith(color: AppColors.rose),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── Display name ──
                  _AuthField(
                    controller: _nameCtrl,
                    label: 'Display name',
                    hint: 'How should we call you?',
                    textInputAction: TextInputAction.next,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Name is required';
                      if (v.trim().length < 2) return 'At least 2 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // ── Email ──
                  _AuthField(
                    controller: _emailCtrl,
                    label: 'Email',
                    hint: 'you@example.com',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Email is required';
                      if (!v.contains('@')) return 'Enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // ── Password ──
                  _AuthField(
                    controller: _passwordCtrl,
                    label: 'Password',
                    hint: 'At least 8 characters',
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.next,
                    suffix: GestureDetector(
                      onTap: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      child: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20,
                        color: AppColors.warmGray,
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Password is required';
                      if (v.length < 8) return 'At least 8 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // ── Confirm password ──
                  _AuthField(
                    controller: _confirmCtrl,
                    label: 'Confirm password',
                    hint: 'Repeat your password',
                    obscureText: _obscureConfirm,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    suffix: GestureDetector(
                      onTap: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                      child: Icon(
                        _obscureConfirm
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20,
                        color: AppColors.warmGray,
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Please confirm password';
                      if (v != _passwordCtrl.text) return 'Passwords don\u2019t match';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // ── Create account CTA ──
                  _PrimaryButton(
                    label: 'Create account',
                    isLoading: isLoading,
                    onTap: isLoading ? null : _submit,
                  ),
                  const SizedBox(height: 16),

                  // ── Divider ──
                  Row(
                    children: [
                      const Expanded(child: Divider(color: AppColors.sandDark)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text('or',
                            style: AppTypography.sansCaption
                                .copyWith(color: AppColors.warmGray)),
                      ),
                      const Expanded(child: Divider(color: AppColors.sandDark)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Google sign-up ──
                  _OutlinedButton(
                    label: 'Sign up with Google',
                    isLoading: isLoading,
                    onTap: isLoading ? null : _googleSignUp,
                  ),
                  const SizedBox(height: 32),

                  // ── Login link ──
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        ref.read(authProvider.notifier).clearError();
                        context.go('/login');
                      },
                      child: Text.rich(
                        TextSpan(
                          text: 'Already have an account? ',
                          style: AppTypography.sansCaption
                              .copyWith(color: AppColors.warmGray),
                          children: [
                            TextSpan(
                              text: 'Sign in',
                              style: AppTypography.sansCaption
                                  .copyWith(color: AppColors.coral),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  AUTH TEXT FIELD
// ═══════════════════════════════════════════════════════

class _AuthField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Widget? suffix;
  final String? Function(String?)? validator;
  final void Function(String)? onFieldSubmitted;

  const _AuthField({
    required this.controller,
    required this.label,
    this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.suffix,
    this.validator,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTypography.sansCaption.copyWith(color: AppColors.driftwood)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          style: AppTypography.sansBody.copyWith(color: AppColors.nearBlack),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.sansBody.copyWith(color: AppColors.stone),
            filled: true,
            fillColor: AppColors.warmWhite,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Spacing.radiusInput),
              borderSide: const BorderSide(color: AppColors.sandDark),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Spacing.radiusInput),
              borderSide: const BorderSide(color: AppColors.sandDark),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Spacing.radiusInput),
              borderSide: const BorderSide(color: AppColors.indigo, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Spacing.radiusInput),
              borderSide: const BorderSide(color: AppColors.rose),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Spacing.radiusInput),
              borderSide: const BorderSide(color: AppColors.rose, width: 1.5),
            ),
            suffixIcon: suffix != null
                ? Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: suffix,
                  )
                : null,
            suffixIconConstraints:
                const BoxConstraints(minHeight: 20, minWidth: 20),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════
//  PRIMARY BUTTON (coral gradient)
// ═══════════════════════════════════════════════════════

class _PrimaryButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onTap;

  const _PrimaryButton({
    required this.label,
    this.isLoading = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: Spacing.buttonPrimaryHeight,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.coral, AppColors.coralDeep],
          ),
          borderRadius: BorderRadius.circular(Spacing.radiusButton),
          boxShadow: [
            BoxShadow(
              color: AppColors.coral.withAlpha(60),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Text(label, style: AppTypography.sansCta),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  OUTLINED BUTTON (Google / secondary)
// ═══════════════════════════════════════════════════════

class _OutlinedButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onTap;

  const _OutlinedButton({
    required this.label,
    this.isLoading = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: Spacing.buttonSecondaryHeight,
        decoration: BoxDecoration(
          color: AppColors.warmWhite,
          borderRadius: BorderRadius.circular(Spacing.radiusButton),
          border: Border.all(color: AppColors.sandDark),
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.driftwood,
                  ),
                )
              : Text(
                  label,
                  style:
                      AppTypography.sansButton.copyWith(color: AppColors.driftwood),
                ),
        ),
      ),
    );
  }
}
