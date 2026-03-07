import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_icons.dart';
import '../../theme/app_typography.dart';
import '../../theme/motion.dart';

/// Settings screen — edit preferences, notifications, theme, about, reset.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late bool _notificationsEnabled;

  @override
  void initState() {
    super.initState();
    final prefs = ref.read(sharedPreferencesProvider);
    _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(userPreferencesProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
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
                        color: AppColors.sand,
                      ),
                      child: const Icon(Icons.arrow_back,
                          size: 20, color: AppColors.espresso),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text('Settings', style: AppTypography.serifHeading),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Content ──
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  // ── TrySomething Pro ──
                  _ProSettingsRow(ref: ref, onTap: () => context.push('/pro')),
                  const SizedBox(height: 20),

                  // ── Preferences section ──
                  _SectionLabel(text: 'PREFERENCES'),
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
                              ? () => ref.read(userPreferencesProvider.notifier)
                                  .setHoursPerWeek(prefs.hoursPerWeek - 1)
                              : null,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            '${prefs.hoursPerWeek}',
                            style: AppTypography.monoMedium.copyWith(color: AppColors.espresso),
                          ),
                        ),
                        _StepperButton(
                          icon: Icons.add,
                          onTap: prefs.hoursPerWeek < 40
                              ? () => ref.read(userPreferencesProvider.notifier)
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
                      onChanged: (level) =>
                          ref.read(userPreferencesProvider.notifier).setBudgetLevel(level),
                    ),
                  ),

                  // Social preference
                  _SettingsTile(
                    icon: Icons.people_outline_rounded,
                    title: 'Style',
                    subtitle: prefs.preferSocial ? 'Prefer social activities' : 'Prefer solo activities',
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
                        onTap: () =>
                            ref.read(userPreferencesProvider.notifier).toggleVibe(vibe),
                        child: AnimatedContainer(
                          duration: Motion.fast,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isActive ? AppColors.indigo : AppColors.sand,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            vibe[0].toUpperCase() + vibe.substring(1),
                            style: AppTypography.sansLabel.copyWith(
                              color: isActive ? Colors.white : AppColors.driftwood,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 28),

                  // ── App section ──
                  _SectionLabel(text: 'APP'),
                  const SizedBox(height: 12),

                  _SettingsTile(
                    icon: Icons.notifications_none_rounded,
                    title: 'Notifications',
                    subtitle: _notificationsEnabled ? 'Reminders on' : 'Reminders off',
                    trailing: Switch.adaptive(
                      value: _notificationsEnabled,
                      onChanged: (v) {
                        setState(() => _notificationsEnabled = v);
                        ref.read(sharedPreferencesProvider).setBool('notifications_enabled', v);
                      },
                      activeColor: AppColors.coral,
                    ),
                  ),

                  _SettingsTile(
                    icon: Icons.info_outline_rounded,
                    title: 'About',
                    subtitle: 'TrySomething v1.0.0',
                  ),

                  // ── Debug Pro Toggle (debug builds only) ──
                  if (kDebugMode) ...[
                    const SizedBox(height: 8),
                    _SectionLabel(text: 'DEBUG'),
                    const SizedBox(height: 12),
                    _DebugProToggle(),
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
                        color: AppColors.rosePale,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.logout_rounded, size: 20, color: AppColors.rose),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Log out',
                                style: AppTypography.sansLabel.copyWith(color: AppColors.rose),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Sign out of your account',
                                style: AppTypography.sansTiny.copyWith(color: AppColors.warmGray),
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
                        color: AppColors.sand,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.warmGray),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Clear local data',
                                style: AppTypography.sansLabel.copyWith(color: AppColors.driftwood),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Reset onboarding, preferences & cached hobbies',
                                style: AppTypography.sansTiny.copyWith(color: AppColors.warmGray),
                              ),
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
                            color: AppColors.warmGray,
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
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Log out?', style: AppTypography.sansSection),
        content: Text(
          'You\'ll need to sign in again to access your data.',
          style: AppTypography.sansBodySmall.copyWith(color: AppColors.warmGray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: AppTypography.sansLabel.copyWith(color: AppColors.driftwood)),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              // Don't reset onboarding — returning users skip it on next login
              if (ctx.mounted) Navigator.of(ctx).pop();
              if (context.mounted) context.go('/login');
            },
            child: Text('Log out', style: AppTypography.sansLabel.copyWith(color: AppColors.rose)),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Clear local data?', style: AppTypography.sansSection),
        content: Text(
          'This will reset onboarding, preferences, and cached hobbies. You\'ll go through onboarding again.',
          style: AppTypography.sansBodySmall.copyWith(color: AppColors.warmGray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: AppTypography.sansLabel.copyWith(color: AppColors.driftwood)),
          ),
          TextButton(
            onPressed: () async {
              ref.read(onboardingCompleteProvider.notifier).reset();
              final prefs = ref.read(sharedPreferencesProvider);
              await prefs.remove('user_hobbies');
              await prefs.remove('user_preferences');
              if (ctx.mounted) Navigator.of(ctx).pop();
              if (context.mounted) context.go('/onboarding');
            },
            child: Text('Clear data', style: AppTypography.sansLabel.copyWith(color: AppColors.rose)),
          ),
        ],
      ),
    );
  }

  static String _budgetLabel(int level) {
    switch (level) {
      case 0: return 'Low';
      case 1: return 'Medium';
      case 2: return 'High';
      default: return 'Any';
    }
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
        color: AppColors.warmGray,
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

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.warmWhite,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.sand,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(icon, size: 16, color: AppColors.driftwood),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.sansLabel.copyWith(color: AppColors.espresso)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTypography.sansTiny.copyWith(color: AppColors.warmGray)),
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
          color: onTap != null ? AppColors.sand : AppColors.sand.withAlpha(120),
        ),
        child: Center(
          child: Icon(
            icon,
            size: 14,
            color: onTap != null ? AppColors.driftwood : AppColors.warmGray,
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
              color: isActive ? AppColors.amber : AppColors.sand,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              labels[i],
              style: AppTypography.monoBadge.copyWith(
                color: isActive ? Colors.white : AppColors.driftwood,
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
          color: isOn ? AppColors.coral : AppColors.sand,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          isOn ? onLabel : offLabel,
          style: AppTypography.sansCaption.copyWith(
            color: isOn ? Colors.white : AppColors.driftwood,
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

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warmWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.amber.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bug_report_rounded, size: 16, color: AppColors.amber),
              const SizedBox(width: 8),
              Text(
                'Subscription Override',
                style: AppTypography.sansLabel.copyWith(color: AppColors.amber),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (final tier in DebugTier.values)
                Expanded(
                  child: GestureDetector(
                    onTap: () => ref.read(proStatusProvider.notifier).setDebugTier(tier),
                    child: AnimatedContainer(
                      duration: Motion.fast,
                      margin: EdgeInsets.only(left: tier.index > 0 ? 6 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: current == tier ? AppColors.coral : AppColors.sand,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        tier == DebugTier.none ? 'Auto' : tier.name[0].toUpperCase() + tier.name.substring(1),
                        style: AppTypography.sansCaption.copyWith(
                          color: current == tier ? Colors.white : AppColors.driftwood,
                          fontWeight: current == tier ? FontWeight.w600 : FontWeight.normal,
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

// ═══════════════════════════════════════════════════════
//  PRO SETTINGS ROW
// ═══════════════════════════════════════════════════════

class _ProSettingsRow extends StatelessWidget {
  final WidgetRef ref;
  final VoidCallback onTap;

  const _ProSettingsRow({required this.ref, required this.onTap});

  String _statusLabel(ProStatus status) {
    if (status.isTrialing) return 'Trial (${status.trialDaysRemaining} days left)';
    if (status.isPro) return 'Pro';
    return 'Free Plan';
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(proStatusProvider);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.coral.withValues(alpha: 0.08),
              AppColors.indigo.withValues(alpha: 0.06),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.coral.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.coral.withValues(alpha: 0.2),
                    AppColors.indigo.withValues(alpha: 0.2),
                  ],
                ),
              ),
              child: const Icon(Icons.auto_awesome, size: 20, color: AppColors.coral),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TrySomething Pro',
                    style: AppTypography.sansLabel.copyWith(
                      color: AppColors.coral,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _statusLabel(status),
                    style: AppTypography.sansTiny.copyWith(color: AppColors.driftwood),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.coral),
          ],
        ),
      ),
    );
  }
}
