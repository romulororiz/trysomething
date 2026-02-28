import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_icons.dart';
import '../../theme/app_typography.dart';

/// Settings screen — edit preferences, notifications, theme, about, reset.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkMode = false;

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
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.sand,
                      ),
                      child: Center(
                        child: Icon(AppIcons.arrowBack, size: 16, color: AppColors.driftwood),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
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
                          duration: const Duration(milliseconds: 200),
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
                      onChanged: (v) => setState(() => _notificationsEnabled = v),
                      activeColor: AppColors.coral,
                    ),
                  ),

                  _SettingsTile(
                    icon: Icons.palette_outlined,
                    title: 'Theme',
                    subtitle: _darkMode ? 'Dark mode' : 'Light mode',
                    trailing: Switch.adaptive(
                      value: _darkMode,
                      onChanged: (v) => setState(() => _darkMode = v),
                      activeColor: AppColors.indigo,
                    ),
                  ),

                  _SettingsTile(
                    icon: Icons.info_outline_rounded,
                    title: 'About',
                    subtitle: 'TrySomething v1.0',
                  ),

                  const SizedBox(height: 28),

                  // ── Danger zone ──
                  _SectionLabel(text: 'DATA'),
                  const SizedBox(height: 12),

                  GestureDetector(
                    onTap: () => _showResetDialog(context, ref),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.rosePale,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.rose.withAlpha(40)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.restart_alt_rounded, size: 20, color: AppColors.rose),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Reset all data',
                                style: AppTypography.sansLabel.copyWith(color: AppColors.rose),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Clear preferences, saved hobbies & progress',
                                style: AppTypography.sansTiny.copyWith(color: AppColors.warmGray),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 120),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Reset everything?', style: AppTypography.sansSection),
        content: Text(
          'This will clear all your saved hobbies, progress, and preferences. You\'ll go through onboarding again.',
          style: AppTypography.sansBodySmall.copyWith(color: AppColors.warmGray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: AppTypography.sansLabel.copyWith(color: AppColors.driftwood)),
          ),
          TextButton(
            onPressed: () {
              ref.read(onboardingCompleteProvider.notifier).reset();
              Navigator.of(ctx).pop();
              context.go('/onboarding');
            },
            child: Text('Reset', style: AppTypography.sansLabel.copyWith(color: AppColors.rose)),
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
            duration: const Duration(milliseconds: 200),
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
        duration: const Duration(milliseconds: 200),
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
