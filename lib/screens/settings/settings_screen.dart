import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../core/media/image_upload.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/feature_providers.dart';
import '../../providers/subscription_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_icons.dart';
import '../../theme/app_typography.dart';
import '../../theme/motion.dart';
import '../../theme/spacing.dart';
import '../../components/app_background.dart';
import '../../components/glass_card.dart';
import '../../components/app_overlays.dart';
import '../../components/updated_matches_sheet.dart';
import '../../core/analytics/analytics_provider.dart';
import '../../models/hobby.dart';
import 'package:url_launcher/url_launcher.dart';

/// Settings screen — edit preferences, notifications, theme, about, reset.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late bool _notificationsEnabled;
  late bool _vibrationEnabled;
  late bool _soundEnabled;
  late UserPreferences _initialPrefs;

  @override
  void initState() {
    super.initState();
    final prefs = ref.read(sharedPreferencesProvider);
    _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    _vibrationEnabled = prefs.getBool('session_vibration') ?? true;
    _soundEnabled = prefs.getBool('session_sound') ?? false;
    _initialPrefs = ref.read(userPreferencesProvider);
  }

  Future<void> _openLegalPage(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showAboutSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(28, 28, 28, 40),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: AppColors.textMuted.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // App name
            RichText(
              text: TextSpan(
                style: AppTypography.display,
                children: [
                  TextSpan(
                      text: 'Try', style: TextStyle(color: AppColors.accent)),
                  TextSpan(
                      text: 'Something',
                      style: TextStyle(color: AppColors.textPrimary)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Tagline
            Text(
              'Stop scrolling. Start something.',
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            // Description
            Text(
              'TrySomething helps you find a hobby that fits your life \u2014 '
              'your budget, your schedule, your energy \u2014 and gives you a '
              'simple plan to actually start it. No pressure. No hustle culture. '
              'Just one good hobby, tried for 30 days.',
              textAlign: TextAlign.center,
              style: AppTypography.sansBodySmall
                  .copyWith(color: AppColors.textSecondary, height: 1.6),
            ),
            const SizedBox(height: 20),
            // Version
            Text(
              'Version 1.0.0 (build 1)',
              style: AppTypography.caption.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 20),
            // Links
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _openLegalPage('https://trysomething.io/privacy');
                  },
                  child: Text('Privacy Policy',
                      style: AppTypography.caption
                          .copyWith(color: AppColors.accent)),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('\u00b7',
                      style: TextStyle(color: AppColors.textMuted)),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _openLegalPage('https://trysomething.io/terms');
                  },
                  child: Text('Terms of Service',
                      style: AppTypography.caption
                          .copyWith(color: AppColors.accent)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Made with \u2665 in Zurich',
              style: AppTypography.caption.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(userPreferencesProvider);
    final authUser = ref.watch(authProvider).user;
    final profile = ref.watch(profileProvider);

    final rawName = authUser?.displayName ?? profile.username;
    final displayName = rawName
        .split(' ')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
    final email = authUser?.email ?? '';
    final avatarUrl = authUser?.avatarUrl ?? profile.avatarUrl;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
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
                    const SizedBox(width: 16),
                    Text('Settings',
                        style: AppTypography.display.copyWith(fontSize: 24)),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Content ──
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    // ── Profile section — tap to edit ──
                    GestureDetector(
                      onTap: () => _showEditProfileSheet(
                        context,
                        ref,
                        displayName: displayName,
                        email: email,
                        avatarUrl: avatarUrl,
                      ),
                      child: _ProfileSection(
                        displayName: displayName,
                        email: email,
                        avatarUrl: avatarUrl,
                      ),
                    ),
                    if (!ref.watch(proStatusProvider).isPro) ...[
                      const SizedBox(height: 12),
                      _SettingsTile(
                        icon: Icons.restore_outlined,
                        title: 'Restore Purchases',
                        subtitle: 'Recover a previous subscription',
                        onTap: _handleRestore,
                      ),
                    ],
                    const SizedBox(height: 20),

                    // ── Preferences section ──
                    const _SectionLabel(text: 'PREFERENCES'),
                    const SizedBox(height: 12),

                    // Hours per week
                    _SettingsTile(
                      icon: AppIcons.badgeTime,
                      title: 'Weekly time',
                      subtitle: '${prefs.hoursPerWeek}h per week',
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _StepperButton(
                            icon: Icons.remove,
                            onTap: prefs.hoursPerWeek > 1
                                ? () => ref
                                    .read(userPreferencesProvider.notifier)
                                    .setHoursPerWeek(prefs.hoursPerWeek - 1)
                                : null,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              '${prefs.hoursPerWeek}',
                              style: AppTypography.monoMedium
                                  .copyWith(color: AppColors.textSecondary),
                            ),
                          ),
                          _StepperButton(
                            icon: Icons.add,
                            onTap: prefs.hoursPerWeek < 40
                                ? () => ref
                                    .read(userPreferencesProvider.notifier)
                                    .setHoursPerWeek(prefs.hoursPerWeek + 1)
                                : null,
                          ),
                        ],
                      ),
                    ),

                    // Budget level
                    _SettingsTile(
                      icon: AppIcons.badgeCost,
                      title: 'Budget level',
                      subtitle: _budgetLabel(prefs.budgetLevel),
                      trailing: _BudgetSelector(
                        current: prefs.budgetLevel,
                        onChanged: (level) => ref
                            .read(userPreferencesProvider.notifier)
                            .setBudgetLevel(level),
                      ),
                    ),

                    // Social preference
                    _SettingsTile(
                      icon: Icons.people_outline_rounded,
                      title: 'Style',
                      subtitle: prefs.preferSocial
                          ? 'Prefer social activities'
                          : 'Prefer solo activities',
                      trailing: _ToggleChip(
                        isOn: prefs.preferSocial,
                        onLabel: 'Social',
                        offLabel: 'Solo',
                        onTap: () => ref
                            .read(userPreferencesProvider.notifier)
                            .setPreferSocial(!prefs.preferSocial),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Vibes
                    _SectionLabel(text: 'YOUR VIBES'),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        'creative',
                        'physical',
                        'relaxing',
                        'technical',
                        'outdoors',
                        'competitive',
                      ].map((vibe) {
                        final isActive = prefs.vibes.contains(vibe);
                        return GestureDetector(
                          onTap: () => ref
                              .read(userPreferencesProvider.notifier)
                              .toggleVibe(vibe),
                          child: AnimatedContainer(
                            duration: Motion.fast,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AppColors.coral
                                  : AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              vibe[0].toUpperCase() + vibe.substring(1),
                              style: AppTypography.sansLabel.copyWith(
                                color: isActive
                                    ? Colors.white
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    // ── See updated matches button ──
                    if (prefs != _initialPrefs) ...[
                      const SizedBox(height: 20),
                      AnimatedOpacity(
                        opacity: prefs != _initialPrefs ? 1.0 : 0.0,
                        duration: Motion.normal,
                        child: SizedBox(
                          width: double.infinity,
                          height: Spacing.buttonPrimaryHeight,
                          child: ElevatedButton(
                            onPressed: () {
                              // 1. Sync to server
                              ref
                                  .read(authRepositoryProvider)
                                  .updatePreferences(
                                    hoursPerWeek: prefs.hoursPerWeek,
                                    budgetLevel: prefs.budgetLevel,
                                    preferSocial: prefs.preferSocial,
                                    vibes: prefs.vibes,
                                  );
                              // 2. Analytics
                              ref
                                  .read(analyticsProvider)
                                  .trackEvent('preferences_changed');
                              // 3. Show updated matches
                              showUpdatedMatchesSheet(context, ref);
                              // 4. Reset change tracking
                              setState(() => _initialPrefs = prefs);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(Spacing.radiusCta),
                              ),
                              elevation: 0,
                            ),
                            child: Text('See updated matches',
                                style: AppTypography.button
                                    .copyWith(color: Colors.white)),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 28),

                    // ── App section ──
                    _SectionLabel(text: 'APP'),
                    const SizedBox(height: 12),

                    _SettingsTile(
                      icon: Icons.notifications_none_rounded,
                      title: 'Notifications',
                      subtitle: _notificationsEnabled
                          ? 'Reminders on'
                          : 'Reminders off',
                      trailing: Switch.adaptive(
                        value: _notificationsEnabled,
                        onChanged: (v) {
                          setState(() => _notificationsEnabled = v);
                          ref
                              .read(sharedPreferencesProvider)
                              .setBool('notifications_enabled', v);
                        },
                        activeColor: AppColors.coral,
                      ),
                    ),

                    _SettingsTile(
                      icon: Icons.info_outline_rounded,
                      title: 'About',
                      subtitle: 'TrySomething v1.0.0',
                      onTap: () => _showAboutSheet(context),
                    ),

                    // ── Session ──
                    const SizedBox(height: 20),
                    const _SectionLabel(text: 'SESSION'),
                    const SizedBox(height: 12),

                    _SettingsTile(
                      icon: Icons.vibration,
                      title: 'Vibration on complete',
                      subtitle: 'Haptic feedback when session ends',
                      trailing: Switch.adaptive(
                        value: _vibrationEnabled,
                        onChanged: (v) {
                          setState(() => _vibrationEnabled = v);
                          ref
                              .read(sharedPreferencesProvider)
                              .setBool('session_vibration', v);
                        },
                        activeColor: AppColors.coral,
                      ),
                    ),

                    _SettingsTile(
                      icon: Icons.notifications_active_outlined,
                      title: 'Sound on complete',
                      subtitle: 'Play a gentle chime',
                      trailing: Switch.adaptive(
                        value: _soundEnabled,
                        onChanged: (v) {
                          setState(() => _soundEnabled = v);
                          ref
                              .read(sharedPreferencesProvider)
                              .setBool('session_sound', v);
                        },
                        activeColor: AppColors.coral,
                      ),
                    ),

                    // ── Debug Pro Toggle (debug builds only) ──
                    if (kDebugMode) ...[
                      const SizedBox(height: 8),
                      _SectionLabel(text: 'DEBUG'),
                      const SizedBox(height: 12),
                      _DebugProToggle(),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () => _showResetHobbiesDialog(context, ref),
                        child: GlassCard(
                          padding: const EdgeInsets.all(14),
                          borderRadius: 14,
                          child: Row(
                            children: [
                              const Icon(Icons.restart_alt_rounded,
                                  size: 16, color: AppColors.textMuted),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Reset hobby data',
                                        style: AppTypography.sansLabel.copyWith(
                                            color: AppColors.textMuted)),
                                    const SizedBox(height: 2),
                                    Text(
                                        'Clear saved/active hobbies (keeps onboarding)',
                                        style: AppTypography.sansTiny.copyWith(
                                            color: AppColors.textWhisper)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () async {
                          await ref
                              .read(userHobbiesProvider.notifier)
                              .syncFromServer();
                          if (context.mounted) {
                            showAppSnackbar(context,
                                message: 'Synced from server',
                                type: AppSnackbarType.success);
                          }
                        },
                        child: GlassCard(
                          padding: const EdgeInsets.all(14),
                          borderRadius: 14,
                          child: Row(
                            children: [
                              const Icon(Icons.cloud_download_outlined,
                                  size: 16, color: AppColors.textMuted),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Sync from server',
                                        style: AppTypography.sansLabel.copyWith(
                                            color: AppColors.textMuted)),
                                    const SizedBox(height: 2),
                                    Text('Replace local state with server data',
                                        style: AppTypography.sansTiny.copyWith(
                                            color: AppColors.textWhisper)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () => context.push('/trial-offer?debug'),
                        child: GlassCard(
                          padding: const EdgeInsets.all(14),
                          borderRadius: 14,
                          child: Row(
                            children: [
                              const Icon(Icons.card_giftcard_outlined,
                                  size: 16, color: AppColors.textMuted),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Show trial screen',
                                        style: AppTypography.sansLabel.copyWith(
                                            color: AppColors.textMuted)),
                                    const SizedBox(height: 2),
                                    Text('Open the trial offer screen',
                                        style: AppTypography.sansTiny.copyWith(
                                            color: AppColors.textWhisper)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () => context.push('/pro'),
                        child: GlassCard(
                          padding: const EdgeInsets.all(14),
                          borderRadius: 14,
                          child: Row(
                            children: [
                              const Icon(Icons.workspace_premium_outlined,
                                  size: 16, color: AppColors.textMuted),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Show Pro screen',
                                        style: AppTypography.sansLabel.copyWith(
                                            color: AppColors.textMuted)),
                                    const SizedBox(height: 2),
                                    Text('Open the Pro upgrade screen',
                                        style: AppTypography.sansTiny.copyWith(
                                            color: AppColors.textWhisper)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 28),

                    // ── Logout ──
                    const SizedBox(height: 8),

                    GestureDetector(
                      onTap: () => _showLogoutDialog(context, ref),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.glassBackground,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.logout_rounded,
                                size: 20, color: AppColors.rose),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Log out',
                                  style: AppTypography.sansLabel
                                      .copyWith(color: AppColors.rose),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Sign out of your account',
                                  style: AppTypography.sansTiny
                                      .copyWith(color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ── Clear data ──
                    GestureDetector(
                      onTap: () => _showClearDataDialog(context, ref),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.delete_outline_rounded,
                                size: 20, color: AppColors.textMuted),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Clear local data',
                                  style: AppTypography.sansLabel
                                      .copyWith(color: AppColors.textSecondary),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Reset onboarding, preferences & cached hobbies',
                                  style: AppTypography.sansTiny
                                      .copyWith(color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ── Delete account ──
                    GestureDetector(
                      onTap: () => _handleDeleteAccount(context, ref),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.delete_forever_outlined,
                                size: 20, color: AppColors.textMuted),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Delete account',
                                    style: AppTypography.sansLabel.copyWith(
                                        color: AppColors.textSecondary)),
                                const SizedBox(height: 2),
                                Text('Permanently delete your data',
                                    style: AppTypography.sansTiny
                                        .copyWith(color: AppColors.textMuted)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── App footer ──
                    Center(
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/app_logo.png',
                            width: 32,
                            height: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'TrySomething v1.0.0 (Build 1)',
                            style: AppTypography.sansTiny.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleRestore() async {
    final service = ref.read(subscriptionProvider);
    final success = await service.restore();
    if (!mounted) return;
    if (success) {
      ref.read(proStatusProvider.notifier).sync();
      showAppSnackbar(context,
          message: 'Pro subscription restored!', type: AppSnackbarType.success);
    } else {
      showAppSnackbar(context,
          message: 'No previous purchase found.', type: AppSnackbarType.info);
    }
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showAppConfirmDialog(
      context: context,
      title: 'Log out?',
      message: 'You\'ll need to sign in again to access your data.',
      confirmLabel: 'Log out',
      isDestructive: true,
      onConfirm: () async {
        await ref.read(authProvider.notifier).logout();
        if (context.mounted) context.go('/login');
      },
    );
  }

  void _showClearDataDialog(BuildContext context, WidgetRef ref) {
    showAppConfirmDialog(
      context: context,
      title: 'Clear local data?',
      message:
          'This will reset onboarding, preferences, and cached hobbies. You\'ll go through onboarding again.',
      confirmLabel: 'Clear data',
      isDestructive: true,
      onConfirm: () async {
        ref.read(onboardingCompleteProvider.notifier).reset();
        final prefs = ref.read(sharedPreferencesProvider);
        await prefs.remove('user_hobbies');
        await prefs.remove('user_preferences');
        if (context.mounted) context.go('/onboarding');
      },
    );
  }

  // ── Account deletion ──

  void _handleDeleteAccount(BuildContext context, WidgetRef ref) {
    final user = ref.read(authProvider).user;
    if (user == null) return;

    if (user.hasPassword) {
      _showDeleteAccountSheet(context, ref);
    } else {
      _showDeleteAccountDialog(context, ref);
    }
  }

  void _showDeleteAccountSheet(BuildContext context, WidgetRef ref) {
    showAppSheet(
      context: context,
      title: 'Delete account',
      builder: (ctx) => _DeleteAccountSheetContent(
        onDelete: (password) =>
            _executeDeleteAccount(context, ref, password: password),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    showAppSheet(
      context: context,
      title: 'Delete account',
      builder: (ctx) => _DeleteAccountDialogContent(
        onDelete: () => _executeDeleteAccount(context, ref),
      ),
    );
  }

  Future<void> _executeDeleteAccount(BuildContext context, WidgetRef ref,
      {String? password}) async {
    final success =
        await ref.read(authProvider.notifier).deleteAccount(password: password);

    if (!context.mounted) return;

    if (success) {
      // Clear SharedPreferences (superset of logout)
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.clear();

      // Reset onboarding state
      ref.read(onboardingCompleteProvider.notifier).reset();

      if (!context.mounted) return;

      // Show snackbar before navigating (avoids context issues)
      showAppSnackbar(context,
          message: 'Account scheduled for deletion',
          type: AppSnackbarType.info);

      // Navigate to login
      if (context.mounted) context.go('/login');
    } else {
      // Show error, stay on Settings
      showAppSnackbar(context,
          message: 'Failed to delete account. Please try again.',
          type: AppSnackbarType.error);
    }
  }

  void _showResetHobbiesDialog(BuildContext context, WidgetRef ref) {
    showAppConfirmDialog(
      context: context,
      title: 'Reset hobby data?',
      message:
          'This clears all saved/active hobbies locally. Onboarding stays intact.',
      confirmLabel: 'Reset',
      isDestructive: true,
      onConfirm: () async {
        final prefs = ref.read(sharedPreferencesProvider);
        await prefs.remove('user_hobbies');
        ref.invalidate(userHobbiesProvider);
        if (context.mounted) {
          showAppSnackbar(context,
              message: 'Hobby data cleared', type: AppSnackbarType.success);
        }
      },
    );
  }

  void _showEditProfileSheet(
    BuildContext context,
    WidgetRef ref, {
    required String displayName,
    required String email,
    required String? avatarUrl,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (ctx) => _EditProfileSheet(
        ref: ref,
        initialName: displayName,
        initialBio: ref.read(authProvider).user?.bio ?? '',
        email: email,
        avatarUrl: avatarUrl,
      ),
    );
  }

  static String _budgetLabel(int level) {
    switch (level) {
      case 0:
        return 'Low';
      case 1:
        return 'Medium';
      case 2:
        return 'High';
      default:
        return 'Any';
    }
  }
}

// ═══════════════════════════════════════════════════════
//  ACCOUNT DELETION HELPERS
// ═══════════════════════════════════════════════════════

Widget _buildDeletionWarning() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        'Your account will be scheduled for deletion. Your data will be permanently removed after 30 days.',
        style: AppTypography.body.copyWith(
          color: AppColors.textSecondary,
          height: 1.5,
        ),
      ),
      const SizedBox(height: 12),
      Text(
        'Active subscriptions are not automatically cancelled.',
        style: AppTypography.body.copyWith(
          color: AppColors.textSecondary,
          height: 1.5,
        ),
      ),
      const SizedBox(height: 8),
      GestureDetector(
        onTap: () => _openSubscriptionManagement(),
        child: Text(
          'Manage Subscriptions',
          style: AppTypography.body.copyWith(
            color: AppColors.accent,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ],
  );
}

Future<void> _openSubscriptionManagement() async {
  final String url;
  if (Platform.isIOS) {
    url = 'https://apps.apple.com/account/subscriptions';
  } else {
    url = 'https://play.google.com/store/account/subscriptions';
  }
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

/// Bottom sheet content for email users — includes password field.
class _DeleteAccountSheetContent extends StatefulWidget {
  final Future<void> Function(String password) onDelete;

  const _DeleteAccountSheetContent({required this.onDelete});

  @override
  State<_DeleteAccountSheetContent> createState() =>
      _DeleteAccountSheetContentState();
}

class _DeleteAccountSheetContentState
    extends State<_DeleteAccountSheetContent> {
  final _passwordController = TextEditingController();
  bool _isDeleting = false;
  String? _errorText;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDeletionWarning(),
          const SizedBox(height: 20),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            style: AppTypography.body.copyWith(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Enter your password',
              hintStyle:
                  AppTypography.body.copyWith(color: AppColors.textMuted),
              filled: true,
              fillColor: AppColors.glassBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              errorText: _errorText,
            ),
            onChanged: (_) {
              if (_errorText != null) setState(() => _errorText = null);
            },
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: GestureDetector(
              onTap: _isDeleting
                  ? null
                  : () async {
                      final password = _passwordController.text.trim();
                      if (password.isEmpty) {
                        setState(() => _errorText = 'Password is required');
                        return;
                      }
                      setState(() => _isDeleting = true);
                      Navigator.of(context).pop();
                      await widget.onDelete(password);
                    },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _isDeleting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Delete Account',
                        style:
                            AppTypography.button.copyWith(color: Colors.white),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet content for OAuth users — no password field.
class _DeleteAccountDialogContent extends StatefulWidget {
  final Future<void> Function() onDelete;

  const _DeleteAccountDialogContent({required this.onDelete});

  @override
  State<_DeleteAccountDialogContent> createState() =>
      _DeleteAccountDialogContentState();
}

class _DeleteAccountDialogContentState
    extends State<_DeleteAccountDialogContent> {
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDeletionWarning(),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.glassBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Cancel',
                      style: AppTypography.button
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: _isDeleting
                      ? null
                      : () async {
                          setState(() => _isDeleting = true);
                          Navigator.of(context).pop();
                          await widget.onDelete();
                        },
                  child: Container(
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _isDeleting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Delete Account',
                            style: AppTypography.button
                                .copyWith(color: Colors.white),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  PROFILE SECTION
// ═══════════════════════════════════════════════════════

class _ProfileSection extends StatelessWidget {
  final String displayName;
  final String email;
  final String? avatarUrl;

  const _ProfileSection({
    required this.displayName,
    required this.email,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.glassBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.glassBorder, width: 0.5),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF1A1520), Color(0xFF151A25)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: avatarUrl != null && avatarUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: avatarUrl!,
                      fit: BoxFit.cover,
                      memCacheWidth: 128,
                      placeholder: (_, __) => const SizedBox.shrink(),
                      errorWidget: (_, __, ___) =>
                          _ProfileInitials(name: displayName),
                    )
                  : _ProfileInitials(name: displayName),
            ),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: AppTypography.sansLabel.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                if (email.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    email,
                    style: AppTypography.sansTiny
                        .copyWith(color: AppColors.textMuted, fontSize: 13),
                  ),
                ],
              ],
            ),
          ),
          // Tap hint
          Icon(Icons.edit_outlined,
              size: 16, color: AppColors.textMuted.withValues(alpha: 0.5)),
        ],
      ),
    );
  }
}

// ── Edit profile bottom sheet ──
class _EditProfileSheet extends StatefulWidget {
  final WidgetRef ref;
  final String initialName;
  final String initialBio;
  final String email;
  final String? avatarUrl;

  const _EditProfileSheet({
    required this.ref,
    required this.initialName,
    required this.initialBio,
    required this.email,
    required this.avatarUrl,
  });

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _bioCtrl;
  String? _pendingAvatarUrl;
  bool _saving = false;
  bool _picking = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialName);
    _bioCtrl = TextEditingController(text: widget.initialBio);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    if (_picking) return;
    _picking = true;
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (picked == null) return;
      setState(() => _saving = true);
      final url = await ImageUpload.uploadImage(File(picked.path));
      if (!mounted) return;
      setState(() => _saving = false);
      if (url != null) {
        setState(() => _pendingAvatarUrl = url);
      } else {
        showAppSnackbar(context,
            message: 'Failed to upload photo', type: AppSnackbarType.error);
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
                                            _ProfileInitials(
                                                name: _nameCtrl.text),
                                      )
                                    : Image.network(effectiveAvatar,
                                        fit: BoxFit.cover))
                                : _ProfileInitials(name: _nameCtrl.text),
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
              _FieldLabel('Email'),
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
                    Icon(Icons.lock_outline_rounded,
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
            _FieldLabel('Display name'),
            const SizedBox(height: 8),
            _SheetTextField(controller: _nameCtrl, hint: 'Your name'),
            const SizedBox(height: 16),

            // Bio
            _FieldLabel('Bio'),
            const SizedBox(height: 8),
            _SheetTextField(
              controller: _bioCtrl,
              hint: 'Tell people what you\'re into (optional)',
              maxLines: 3,
            ),
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
  final int maxLines;

  const _SheetTextField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
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
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
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

class _ProfileInitials extends StatelessWidget {
  final String name;
  const _ProfileInitials({required this.name});

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

// ═══════════════════════════════════════════════════════
//  SECTION LABEL
// ═══════════════════════════════════════════════════════

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTypography.overline.copyWith(
        color: AppColors.textMuted,
        letterSpacing: 2,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  SETTINGS TILE
// ═══════════════════════════════════════════════════════

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        onTap: onTap,
        padding: const EdgeInsets.all(14),
        borderRadius: 14,
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(icon, size: 16, color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTypography.sansLabel
                          .copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: AppTypography.sansTiny
                          .copyWith(color: AppColors.textMuted)),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  STEPPER BUTTON
// ═══════════════════════════════════════════════════════

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _StepperButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: onTap != null
              ? AppColors.surfaceElevated
              : AppColors.surfaceElevated.withAlpha(120),
        ),
        child: Center(
          child: Icon(
            icon,
            size: 14,
            color:
                onTap != null ? AppColors.textSecondary : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  BUDGET SELECTOR
// ═══════════════════════════════════════════════════════

class _BudgetSelector extends StatelessWidget {
  final int current;
  final ValueChanged<int> onChanged;

  const _BudgetSelector({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const labels = ['\$', '\$\$', '\$\$\$'];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final isActive = i == current;
        return GestureDetector(
          onTap: () => onChanged(i),
          child: AnimatedContainer(
            duration: Motion.fast,
            margin: EdgeInsets.only(left: i > 0 ? 6 : 0),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isActive ? AppColors.coral : AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              labels[i],
              style: AppTypography.monoBadge.copyWith(
                color: isActive ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  TOGGLE CHIP
// ═══════════════════════════════════════════════════════

class _ToggleChip extends StatelessWidget {
  final bool isOn;
  final String onLabel;
  final String offLabel;
  final VoidCallback onTap;

  const _ToggleChip({
    required this.isOn,
    required this.onLabel,
    required this.offLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Motion.fast,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isOn ? AppColors.coral : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          isOn ? onLabel : offLabel,
          style: AppTypography.sansCaption.copyWith(
            color: isOn ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  DEBUG PRO TOGGLE (debug builds only)
// ═══════════════════════════════════════════════════════

class _DebugProToggle extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(proStatusProvider.notifier);
    final current = notifier.debugTier;

    return GlassCard(
      padding: const EdgeInsets.all(14),
      borderRadius: 14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bug_report_rounded,
                  size: 16, color: AppColors.textMuted),
              const SizedBox(width: 8),
              Text(
                'Subscription Override',
                style: AppTypography.sansLabel
                    .copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (final tier in DebugTier.values)
                Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        ref.read(proStatusProvider.notifier).setDebugTier(tier),
                    child: AnimatedContainer(
                      duration: Motion.fast,
                      margin: EdgeInsets.only(left: tier.index > 0 ? 6 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: current == tier
                            ? AppColors.coral
                            : AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        tier == DebugTier.none
                            ? 'Auto'
                            : tier.name[0].toUpperCase() +
                                tier.name.substring(1),
                        style: AppTypography.sansCaption.copyWith(
                          color: current == tier
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontWeight: current == tier
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

