import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../components/page_dots.dart';
import '../../models/hobby.dart';
import '../../providers/hobby_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/feature_providers.dart';
import '../../providers/auth_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/spacing.dart';

/// You tab — Collector Card redesign (P6).
class YouScreen extends ConsumerStatefulWidget {
  const YouScreen({super.key});

  @override
  ConsumerState<YouScreen> createState() => _YouScreenState();
}

class _YouScreenState extends ConsumerState<YouScreen> {
  late PageController _hobbyPageController;
  int _currentHobbyPage = 0;
  bool _showAllSaved = false;

  @override
  void initState() {
    super.initState();
    _hobbyPageController = PageController(viewportFraction: 0.88);
  }

  @override
  void dispose() {
    _hobbyPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userHobbies = ref.watch(userHobbiesProvider);
    final allHobbiesAsync = ref.watch(hobbyListProvider);
    final authUser = ref.watch(authProvider).user;
    final profile = ref.watch(profileProvider);
    final proStatus = ref.watch(proStatusProvider);

    final displayName = authUser?.displayName ?? profile.username;
    final avatarUrl = authUser?.avatarUrl ?? profile.avatarUrl;

    final allHobbies = allHobbiesAsync.valueOrNull ?? [];

    final activeEntries = <_HobbyWithMeta>[];
    final savedEntries = <_HobbyWithMeta>[];
    final triedEntries = <_HobbyWithMeta>[];

    for (final entry in userHobbies.entries) {
      final uh = entry.value;
      final hobby = allHobbies.where((h) => h.id == uh.hobbyId).firstOrNull;
      if (hobby == null) continue;

      final meta = _HobbyWithMeta(hobby: hobby, userHobby: uh);
      switch (uh.status) {
        case HobbyStatus.trying:
        case HobbyStatus.active:
          activeEntries.add(meta);
        case HobbyStatus.saved:
          savedEntries.add(meta);
        case HobbyStatus.done:
          triedEntries.add(meta);
      }
    }

    if (_currentHobbyPage >= activeEntries.length && activeEntries.isNotEmpty) {
      _currentHobbyPage = activeEntries.length - 1;
    }

    final visibleMeta = activeEntries.isNotEmpty
        ? activeEntries[_currentHobbyPage.clamp(0, activeEntries.length - 1)]
        : null;

    final allEntries = [...activeEntries, ...savedEntries, ...triedEntries];
    final totalStepsCompleted = allEntries.fold(
        0, (sum, m) => sum + m.userHobby.completedStepIds.length);
    final bestStreak = allEntries.fold(
        0, (best, m) => m.userHobby.streakDays > best ? m.userHobby.streakDays : best);
    final hobbiesExplored = allEntries.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(
              top: 16, bottom: Spacing.scrollBottomPadding),
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _ProfileHeader(
                displayName: displayName,
                avatarUrl: avatarUrl,
                streakDays: visibleMeta != null
                    ? _computeStreak(visibleMeta.userHobby)
                    : 0,
                hobbiesExplored: hobbiesExplored,
              ),
            ),
            const SizedBox(height: 16),

            // ── ACTIVE section ──
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: _SectionLabel('ACTIVE'),
            ),
            const SizedBox(height: 10),

            if (activeEntries.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _EmptyActivePrompt(),
              )
            else ...[
              if (activeEntries.length == 1)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _CollectorCard(meta: activeEntries.first),
                )
              else ...[
                SizedBox(
                  height: 130,
                  child: PageView.builder(
                    controller: _hobbyPageController,
                    itemCount: activeEntries.length,
                    onPageChanged: (i) =>
                        setState(() => _currentHobbyPage = i),
                    itemBuilder: (context, i) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: _CollectorCard(meta: activeEntries[i]),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                PageDots(
                  count: activeEntries.length,
                  current: _currentHobbyPage,
                ),
              ],
              const SizedBox(height: 10),
              if (visibleMeta != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _StatsChipRow(meta: visibleMeta),
                ),
            ],

            const SizedBox(height: 16),

            if (savedEntries.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    const _SectionLabel('SAVED FOR LATER'),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        '${savedEntries.length}',
                        style: AppTypography.monoTiny
                            .copyWith(color: AppColors.textMuted),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              ...(_showAllSaved
                      ? savedEntries
                      : savedEntries.take(4).toList())
                  .map((m) => Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 10),
                        child: _SavedHobbyCard(meta: m),
                      )),
              if (savedEntries.length > 4)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 14),
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _showAllSaved = !_showAllSaved),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Center(
                        child: Text(
                          _showAllSaved
                              ? 'Show less'
                              : 'See ${savedEntries.length - 4} more',
                          style: AppTypography.caption
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                  ),
                )
              else
                const SizedBox(height: 14),
            ],

            if (triedEntries.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: _SectionLabel('TRIED BEFORE'),
              ),
              const SizedBox(height: 10),
              ...triedEntries.map((m) => Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 10),
                    child: _TriedHobbyCard(meta: m),
                  )),
              const SizedBox(height: 14),
            ],

            // ── Journey stats ──
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: _SectionLabel('YOUR JOURNEY'),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _JourneyStats(
                stepsCompleted: totalStepsCompleted,
                bestStreak: bestStreak,
                hobbiesExplored: hobbiesExplored,
              ),
            ),
            const SizedBox(height: 20),

            // ── Nav rows ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _NavRow(
                icon: MdiIcons.bookOpenPageVariantOutline,
                iconBg: AppColors.surface,
                iconBorder: AppColors.border,
                iconColor: AppColors.textSecondary,
                title: 'Journal',
                titleStyle: AppTypography.sansLabel,
                chevronColor: AppColors.textMuted,
                onTap: () => context.push('/journal'),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: _HairlineDivider(),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _ProNavRow(proStatus: proStatus),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: _HairlineDivider(),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _NavRow(
                icon: MdiIcons.cogOutline,
                iconBg: Colors.transparent,
                iconBorder: Colors.transparent,
                iconColor: AppColors.textMuted.withValues(alpha: 0.4),
                title: 'Settings',
                titleStyle: AppTypography.caption.copyWith(
                  color: AppColors.textMuted,
                ),
                chevronColor: AppColors.textWhisper,
                onTap: () => context.push('/settings'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Streak helper ──
int _computeStreak(UserHobby uh) => uh.streakDays;

// ── Data helper ──
class _HobbyWithMeta {
  final Hobby hobby;
  final UserHobby userHobby;
  const _HobbyWithMeta({required this.hobby, required this.userHobby});
}

// ── Section label ──
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTypography.overline.copyWith(color: AppColors.textMuted),
    );
  }
}

// ── Profile header ──
class _ProfileHeader extends StatelessWidget {
  final String displayName;
  final String? avatarUrl;
  final int streakDays;
  final int hobbiesExplored;

  const _ProfileHeader({
    required this.displayName,
    required this.avatarUrl,
    required this.streakDays,
    required this.hobbiesExplored,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Avatar
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              colors: [Color(0xFF1A1520), Color(0xFF151A25)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.07),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: avatarUrl != null && avatarUrl!.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: avatarUrl!,
                  fit: BoxFit.cover,
                  memCacheWidth: 128,
                  placeholder: (_, __) => const SizedBox.shrink(),
                  errorWidget: (_, __, ___) => const SizedBox.shrink(),
                )
              : Center(
                  child: Text(
                    displayName.isNotEmpty
                        ? displayName[0].toUpperCase()
                        : '?',
                    style: AppTypography.title.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
        ),
        const SizedBox(width: 16),
        // Name + info chips
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName,
                style: AppTypography.title,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children: [
                  _MiniInfoChip(
                    label: '$hobbiesExplored ${hobbiesExplored == 1 ? 'hobby' : 'hobbies'}',
                  ),
                  if (streakDays > 0)
                    _MiniInfoChip(
                      label: '$streakDays-day streak',
                      accent: true,
                    )
                  else
                    const _MiniInfoChip(label: 'Start your streak'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Mini info chip (used in header) ──
class _MiniInfoChip extends StatelessWidget {
  final String label;
  final bool accent;
  const _MiniInfoChip({required this.label, this.accent = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: accent
            ? AppColors.accent.withValues(alpha: 0.08)
            : AppColors.surface,
        border: Border.all(
          color: accent
              ? AppColors.accent.withValues(alpha: 0.18)
              : AppColors.border,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: AppTypography.monoTiny.copyWith(
          color: accent ? AppColors.accent : AppColors.textMuted,
        ),
      ),
    );
  }
}

// ── Journey stats block ──
class _JourneyStats extends StatelessWidget {
  final int stepsCompleted;
  final int bestStreak;
  final int hobbiesExplored;

  const _JourneyStats({
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

// ── Collector Card ──
class _CollectorCard extends StatelessWidget {
  final _HobbyWithMeta meta;
  const _CollectorCard({required this.meta});

  @override
  Widget build(BuildContext context) {
    final hobby = meta.hobby;
    final uh = meta.userHobby;

    final validStepIds = hobby.roadmapSteps.map((s) => s.id).toSet();
    final completedValid = uh.completedStepIds.intersection(validStepIds);
    final totalSteps = hobby.roadmapSteps.length;
    final progress = totalSteps > 0 ? completedValid.length / totalSteps : 0.0;

    final startedAt = uh.startedAt ?? DateTime.now();
    final weekNum =
        (DateTime.now().difference(startedAt).inDays / 7).floor() + 1;

    return GestureDetector(
      onTap: () => context.go('/home?hobby=${hobby.id}'),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 130,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Transform.scale(
                scale: 1.05,
                child: CachedNetworkImage(
                  imageUrl: hobby.imageUrl,
                  fit: BoxFit.cover,
                  memCacheWidth: 800,
                  placeholder: (_, __) =>
                      Container(color: AppColors.surfaceElevated),
                  errorWidget: (_, __, ___) =>
                      Container(color: AppColors.surfaceElevated),
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x1A0A0A0F),
                      Color(0xF80A0A0F),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 14,
                right: 14,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'WEEK ${weekNum.toString().padLeft(2, '0')} / 04',
                      style: AppTypography.overline.copyWith(
                        color: AppColors.textPrimary.withValues(alpha: 0.35),
                        fontSize: 9,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            hobby.title,
                            style: AppTypography.title.copyWith(
                              fontSize: 18,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${(progress * 100).round()}',
                                    style: GoogleFonts.ibmPlexMono(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.accent,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '%',
                                    style: GoogleFonts.ibmPlexMono(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.accent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              'COMPLETE',
                              style: AppTypography.overline.copyWith(
                                color: AppColors.textPrimary
                                    .withValues(alpha: 0.3),
                                fontSize: 8,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(1),
                      child: LinearProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        minHeight: 2,
                        backgroundColor:
                            Colors.white.withValues(alpha: 0.08),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.accent),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Stats chip row ──
class _StatsChipRow extends StatelessWidget {
  final _HobbyWithMeta meta;
  const _StatsChipRow({required this.meta});

  @override
  Widget build(BuildContext context) {
    final hobby = meta.hobby;
    final uh = meta.userHobby;

    final validStepIds = hobby.roadmapSteps.map((s) => s.id).toSet();
    final completedValid = uh.completedStepIds.intersection(validStepIds);
    final totalSteps = hobby.roadmapSteps.length;
    final sessionsProxy = uh.completedStepIds.length;
    final streakDays = _computeStreak(uh);

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        _Chip(
          label: '${completedValid.length}/$totalSteps steps',
          bg: AppColors.surface,
          border: AppColors.border,
          textColor: AppColors.textMuted,
        ),
        _Chip(
          label: '$sessionsProxy sessions',
          bg: AppColors.surface,
          border: AppColors.border,
          textColor: AppColors.textMuted,
        ),
        if (streakDays > 0)
          _Chip(
            label: '\uD83D\uDD25 $streakDays days',
            bg: AppColors.accentMuted,
            border: AppColors.accent.withValues(alpha: 0.2),
            textColor: AppColors.accent,
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color bg;
  final Color border;
  final Color textColor;
  const _Chip({
    required this.label,
    required this.bg,
    required this.border,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTypography.monoTiny.copyWith(color: textColor),
      ),
    );
  }
}

// ── Nav rows ──
class _NavRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconBorder;
  final Color iconColor;
  final String title;
  final TextStyle titleStyle;
  final Color chevronColor;
  final VoidCallback onTap;

  const _NavRow({
    required this.icon,
    required this.iconBg,
    required this.iconBorder,
    required this.iconColor,
    required this.title,
    required this.titleStyle,
    required this.chevronColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: iconBg,
                border: iconBorder != Colors.transparent
                    ? Border.all(color: iconBorder)
                    : null,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, size: 15, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: titleStyle)),
            Icon(MdiIcons.chevronRight, size: 18, color: chevronColor),
          ],
        ),
      ),
    );
  }
}

class _ProNavRow extends StatelessWidget {
  final ProStatus proStatus;
  const _ProNavRow({required this.proStatus});

  String _label(ProStatus s) {
    if (s.isPro && s.isTrialing) {
      return 'Trial (${s.trialDaysRemaining} days left)';
    }
    if (s.isPro) return 'Pro';
    return 'Free Plan';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/pro'),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.03),
          border: Border.all(
            color: AppColors.accent.withValues(alpha: 0.1),
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.accentMuted,
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.18),
                ),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(MdiIcons.starFourPointsOutline,
                  size: 15, color: AppColors.accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TrySomething Pro',
                    style: AppTypography.sansLabel,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _label(proStatus),
                    style: AppTypography.monoTiny.copyWith(
                      color: AppColors.accent.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            Icon(MdiIcons.chevronRight,
                size: 18,
                color: AppColors.accent.withValues(alpha: 0.4)),
          ],
        ),
      ),
    );
  }
}

class _HairlineDivider extends StatelessWidget {
  const _HairlineDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: const Color(0xFF0E0E13),
    );
  }
}

// ── Empty active prompt ──
class _EmptyActivePrompt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            'Start your first hobby',
            style: AppTypography.title.copyWith(fontSize: 17),
          ),
          const SizedBox(height: 6),
          Text(
            'Find something that fits your life and try it for a week.',
            textAlign: TextAlign.center,
            style:
                AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => context.go('/discover'),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text('Discover hobbies',
                    style: AppTypography.button
                        .copyWith(color: AppColors.background)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Saved hobby card ──
class _SavedHobbyCard extends StatelessWidget {
  final _HobbyWithMeta meta;
  const _SavedHobbyCard({required this.meta});

  @override
  Widget build(BuildContext context) {
    final hobby = meta.hobby;
    return GestureDetector(
      onTap: () => context.push('/hobby/${hobby.id}'),
      child: Container(
        height: 88,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            // Hobby image
            SizedBox(
              width: 88,
              child: CachedNetworkImage(
                imageUrl: hobby.imageUrl,
                fit: BoxFit.cover,
                memCacheWidth: 176,
                placeholder: (_, __) =>
                    Container(color: AppColors.surfaceElevated),
                errorWidget: (_, __, ___) => Container(
                  color: AppColors.surfaceElevated,
                  child: Center(
                    child: Icon(Icons.image_outlined,
                        color: AppColors.textMuted, size: 24),
                  ),
                ),
              ),
            ),
            // Text content
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      hobby.category.toUpperCase(),
                      style: AppTypography.overline.copyWith(
                          color: AppColors.accent, fontSize: 9),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hobby.title,
                      style: AppTypography.title.copyWith(fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${hobby.costText} · ${hobby.timeText}',
                      style: AppTypography.caption.copyWith(
                          color: AppColors.textMuted, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
            // Chevron
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Icon(Icons.chevron_right_rounded,
                  size: 18, color: AppColors.textWhisper),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tried hobby card ──
class _TriedHobbyCard extends StatelessWidget {
  final _HobbyWithMeta meta;
  const _TriedHobbyCard({required this.meta});

  @override
  Widget build(BuildContext context) {
    final hobby = meta.hobby;
    final uh = meta.userHobby;

    String triedLabel = '';
    if (uh.startedAt != null && uh.lastActivityAt != null) {
      final days = uh.lastActivityAt!.difference(uh.startedAt!).inDays;
      final weeks = (days / 7).ceil();
      triedLabel = weeks <= 1 ? '1 week' : '$weeks weeks';
      final month = _monthName(uh.lastActivityAt!.month);
      final year = uh.lastActivityAt!.year;
      triedLabel = '$triedLabel in $month $year';
    }

    return GestureDetector(
      onTap: () => context.push('/hobby/${hobby.id}'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface.withAlpha(10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(hobby.title,
                style: AppTypography.body
                    .copyWith(color: AppColors.textSecondary)),
            if (triedLabel.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(triedLabel,
                  style: AppTypography.caption
                      .copyWith(color: AppColors.textMuted)),
            ],
          ],
        ),
      ),
    );
  }

  String _monthName(int month) {
    const names = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return names[month - 1];
  }
}
