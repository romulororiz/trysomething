import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/subscription_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

// ── Section label ──
class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTypography.overline.copyWith(color: AppColors.textMuted),
    );
  }
}

// ── Centered profile header ──
class CenteredProfileHeader extends StatelessWidget {
  final String displayName;
  final String? avatarUrl;
  final int streakDays;
  final int activeCount;

  const CenteredProfileHeader({
    super.key,
    required this.displayName,
    required this.avatarUrl,
    required this.streakDays,
    required this.activeCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Avatar — centered, circular
        Container(
          width: 84,
          height: 84,
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
                    memCacheWidth: 168,
                    placeholder: (_, __) => const SizedBox.shrink(),
                    errorWidget: (_, __, ___) => _InitialsAvatar(name: displayName),
                  )
                : _InitialsAvatar(name: displayName),
          ),
        ),
        const SizedBox(height: 12),

        // Name
        Text(
          displayName,
          style: AppTypography.title.copyWith(fontSize: 20),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),

        // Stats row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _MiniInfoChip(
              label: '$activeCount active ${activeCount == 1 ? 'hobby' : 'hobbies'}',
            ),
            const SizedBox(width: 6),
            if (streakDays > 0)
              _MiniInfoChip(
                label: '$streakDays-day streak',
                accent: true,
              )
            else
              GestureDetector(
                onTap: () => context.go('/home'),
                child: const _MiniInfoChip(
                  label: 'Start your streak \u2192',
                  tappable: true,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _InitialsAvatar extends StatelessWidget {
  final String name;
  const _InitialsAvatar({required this.name});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: AppTypography.title.copyWith(
          color: AppColors.textMuted,
          fontSize: 28,
        ),
      ),
    );
  }
}

// ── Tab pills ──
class TabPills extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelect;
  final int activeCt;
  final int pausedCt;
  final int savedCt;
  final int triedCt;

  const TabPills({
    super.key,
    required this.selected,
    required this.onSelect,
    required this.activeCt,
    required this.pausedCt,
    required this.savedCt,
    required this.triedCt,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = [
      ('Active', activeCt),
      ('Paused', pausedCt),
      ('Saved', savedCt),
      ('Tried', triedCt),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: tabs.asMap().entries.map((entry) {
        final i = entry.key;
        final label = entry.value.$1;
        final count = entry.value.$2;
        final isSelected = i == selected;

        return GestureDetector(
          onTap: () => onSelect(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: EdgeInsets.only(right: i < tabs.length - 1 ? 8 : 0),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.accent.withValues(alpha: 0.10)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isSelected
                    ? AppColors.accent.withValues(alpha: 0.40)
                    : AppColors.border,
              ),
            ),
            child: Text(
              count > 0 ? '$label ($count)' : label,
              style: AppTypography.monoTiny.copyWith(
                color: isSelected ? AppColors.accent : AppColors.textMuted,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Mini info chip (used in header) ──
class _MiniInfoChip extends StatelessWidget {
  final String label;
  final bool accent;
  final bool tappable;
  const _MiniInfoChip(
      {required this.label, this.accent = false, this.tappable = false});

  @override
  Widget build(BuildContext context) {
    final bgColor = accent
        ? AppColors.accent.withValues(alpha: 0.08)
        : tappable
            ? AppColors.accent.withValues(alpha: 0.05)
            : AppColors.surface;
    final borderColor = accent
        ? AppColors.accent.withValues(alpha: 0.18)
        : tappable
            ? AppColors.accent.withValues(alpha: 0.25)
            : AppColors.border;
    final textColor =
        accent || tappable ? AppColors.accent : AppColors.textMuted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        label,
        style: AppTypography.monoTiny.copyWith(color: textColor),
      ),
    );
  }
}

// ── Journey stats block ──
class JourneyStats extends StatelessWidget {
  final int stepsCompleted;
  final int bestStreak;
  final int hobbiesExplored;

  const JourneyStats({
    super.key,
    required this.stepsCompleted,
    required this.bestStreak,
    required this.hobbiesExplored,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          _StatTile(value: '$stepsCompleted', label: 'STEPS DONE'),
          const SizedBox(width: 8),
          _StatTile(value: '${bestStreak}d', label: 'BEST STREAK'),
          const SizedBox(width: 8),
          _StatTile(value: '$hobbiesExplored', label: 'EXPLORED'),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String value;
  final String label;
  const _StatTile({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: GoogleFonts.ibmPlexMono(
                fontSize: 26,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: 1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppTypography.overline.copyWith(
                color: AppColors.textMuted,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProNavRow extends ConsumerWidget {
  const ProNavRow({super.key});

  String _label(ProStatus s) {
    if (s.isPro && s.isTrialing) {
      return 'Trial (${s.trialDaysRemaining} days left)';
    }
    if (s.isPro) return 'Pro';
    return 'Free Plan';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(proStatusProvider);

    return GestureDetector(
      onTap: () => context.push('/pro'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.coral.withValues(alpha: 0.08),
              AppColors.textMuted.withValues(alpha: 0.06),
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
                    AppColors.textMuted.withValues(alpha: 0.2),
                  ],
                ),
              ),
              child: const Icon(Icons.auto_awesome,
                  size: 20, color: AppColors.coral),
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
                    _label(status),
                    style: AppTypography.sansTiny
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                size: 20, color: AppColors.coral),
          ],
        ),
      ),
    );
  }
}
