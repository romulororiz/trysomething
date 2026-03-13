import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../components/shared_widgets.dart';
import '../../providers/auth_provider.dart';
import '../../providers/feature_providers.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/spacing.dart';
import '../../components/app_background.dart';

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
      // New user → go through onboarding (sync fires but will be empty)
      final user = ref.read(authProvider).user;
      if (user != null) ref.read(profileProvider.notifier).initFromAuth(user);
      ref.read(userHobbiesProvider.notifier).syncFromServer();
      ref.read(journalProvider.notifier).loadFromServer();
      ref.read(scheduleProvider.notifier).loadFromServer();
      ref.read(storiesProvider.notifier).loadFromServer();
      ref.read(buddyProvider.notifier).loadFromServer();
      ref.read(challengeProvider.notifier).loadFromServer();
      context.go('/onboarding');
    }
  }

  Future<void> _googleSignUp() async {
    final success = await ref.read(authProvider.notifier).loginWithGoogle();
    if (success && mounted) _onAuthSuccess();
  }

  Future<void> _appleSignUp() async {
    final success = await ref.read(authProvider.notifier).loginWithApple();
    if (success && mounted) _onAuthSuccess();
  }

  void _onAuthSuccess() {
    final user = ref.read(authProvider).user;
    if (user != null) ref.read(profileProvider.notifier).initFromAuth(user);
    ref.read(userHobbiesProvider.notifier).syncFromServer();
    ref.read(journalProvider.notifier).loadFromServer();
    ref.read(scheduleProvider.notifier).loadFromServer();
    ref.read(storiesProvider.notifier).loadFromServer();
    ref.read(buddyProvider.notifier).loadFromServer();
    ref.read(challengeProvider.notifier).loadFromServer();
    context.go('/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.status == AuthStatus.loading;
    final isEmailLoading = isLoading && authState.loadingMethod == AuthMethod.email;
    final isGoogleLoading = isLoading && authState.loadingMethod == AuthMethod.google;
    final isAppleLoading = isLoading && authState.loadingMethod == AuthMethod.apple;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(child: SafeArea(
        child: Column(
          children: [
            // ── Top header: back + "Already have an account? Sign in" ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.glassBackground,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.arrow_back_ios_new,
                            size: 16, color: AppColors.textPrimary),
                      ),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      ref.read(authProvider.notifier).clearError();
                      context.go('/login');
                    },
                    child: Text.rich(
                      TextSpan(
                        text: 'Have an account?  ',
                        style: AppTypography.sansCaption
                            .copyWith(color: AppColors.textMuted),
                        children: [
                          TextSpan(
                            text: 'Sign in',
                            style: AppTypography.sansLabel
                                .copyWith(color: AppColors.coral),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Scrollable content ──
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── Logo ──
                        Center(
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: AppColors.coralPale,
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Center(
                              child: Icon(Icons.auto_awesome,
                                  size: 32, color: AppColors.coral),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Center(
                          child: Text('Create account',
                              style: AppTypography.display),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            'Start discovering hobbies you\u2019ll love',
                            style: AppTypography.sansBodySmall
                                .copyWith(color: AppColors.textSecondary),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // ── Error ──
                        if (authState.error != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated,
                              borderRadius:
                                  BorderRadius.circular(Spacing.radiusInput),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline_rounded,
                                    size: 18, color: AppColors.error),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    authState.error!,
                                    style: AppTypography.sansCaption
                                        .copyWith(color: AppColors.error),
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
                          hint: 'Display name',
                          leadingIcon: Icons.person_outline,
                          textInputAction: TextInputAction.next,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Name is required';
                            }
                            if (v.trim().length < 2) {
                              return 'At least 2 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // ── Email ──
                        _AuthField(
                          controller: _emailCtrl,
                          hint: 'Email address',
                          leadingIcon: Icons.mail_outline,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Email is required';
                            }
                            if (!v.contains('@')) return 'Enter a valid email';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // ── Password ──
                        _AuthField(
                          controller: _passwordCtrl,
                          hint: 'Password (8+ characters)',
                          leadingIcon: Icons.lock_outline,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.next,
                          suffix: GestureDetector(
                            onTap: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                            child: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 20,
                              color: AppColors.textMuted,
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Password is required';
                            }
                            if (v.length < 8) return 'At least 8 characters';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // ── Confirm password ──
                        _AuthField(
                          controller: _confirmCtrl,
                          hint: 'Confirm password',
                          leadingIcon: Icons.lock_outline,
                          obscureText: _obscureConfirm,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submit(),
                          suffix: GestureDetector(
                            onTap: () => setState(
                                () => _obscureConfirm = !_obscureConfirm),
                            child: Icon(
                              _obscureConfirm
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 20,
                              color: AppColors.textMuted,
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Please confirm password';
                            }
                            if (v != _passwordCtrl.text) {
                              return 'Passwords don\u2019t match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 28),

                        // ── Create account CTA ──
                        PrimaryCtaButton(
                          label: 'Create Account \u2192',
                          isLoading: isEmailLoading,
                          onTap: isLoading ? null : _submit,
                        ),
                        const SizedBox(height: 24),

                        // ── Divider ──
                        Row(
                          children: [
                            const Expanded(
                                child: Divider(color: AppColors.border)),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text('Or continue with',
                                  style: AppTypography.sansCaption
                                      .copyWith(color: AppColors.textMuted)),
                            ),
                            const Expanded(
                                child: Divider(color: AppColors.border)),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // ── Social buttons (side by side) ──
                        Row(
                          children: [
                            Expanded(
                              child: _SocialButton(
                                label: 'Google',
                                icon: Icons.g_mobiledata,
                                isLoading: isGoogleLoading,
                                onTap: isLoading ? null : _googleSignUp,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _SocialButton(
                                label: 'Apple',
                                icon: Icons.apple,
                                isLoading: isAppleLoading,
                                onTap: isLoading ? null : _appleSignUp,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // ── Terms text ──
                        Center(
                          child: Text.rich(
                            TextSpan(
                              text: 'By creating an account, you agree to our ',
                              style: AppTypography.sansTiny,
                              children: [
                                TextSpan(
                                  text: 'Terms of Service',
                                  style: AppTypography.sansTiny
                                      .copyWith(color: AppColors.coral),
                                ),
                                const TextSpan(text: ' and '),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: AppTypography.sansTiny
                                      .copyWith(color: AppColors.coral),
                                ),
                                const TextSpan(text: '.'),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      )),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  AUTH TEXT FIELD
// ═══════════════════════════════════════════════════════

class _AuthField extends StatelessWidget {
  final TextEditingController controller;
  final String? hint;
  final IconData? leadingIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Widget? suffix;
  final String? Function(String?)? validator;
  final void Function(String)? onFieldSubmitted;

  const _AuthField({
    required this.controller,
    this.hint,
    this.leadingIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.suffix,
    this.validator,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      style: AppTypography.sansBody.copyWith(color: AppColors.textPrimary),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTypography.sansBody.copyWith(color: AppColors.textWhisper),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        prefixIcon: leadingIcon != null
            ? Padding(
                padding: const EdgeInsets.only(left: 16, right: 8),
                child: Icon(leadingIcon, size: 20, color: AppColors.textMuted),
              )
            : null,
        prefixIconConstraints:
            const BoxConstraints(minHeight: 20, minWidth: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Spacing.radiusButton),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Spacing.radiusButton),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Spacing.radiusButton),
          borderSide: const BorderSide(color: AppColors.coral, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Spacing.radiusButton),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Spacing.radiusButton),
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
    );
  }
}

// ═══════════════════════════════════════════════════════
//  SOCIAL SIGN-IN BUTTON (Google / Apple)
// ═══════════════════════════════════════════════════════

class _SocialButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isLoading;
  final VoidCallback? onTap;

  const _SocialButton({
    required this.label,
    required this.icon,
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
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(Spacing.radiusButton),
          border: Border.all(color: AppColors.border),
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.textSecondary,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 20, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: AppTypography.sansButton
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
