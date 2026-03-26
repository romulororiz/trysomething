import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../components/app_background.dart';
import '../../components/glass_card.dart';
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
import 'you_hobby_cards.dart';

/// You tab — profile header + tab pills (Active / Saved / Tried).
class YouScreen extends ConsumerStatefulWidget {
  const YouScreen({super.key});

  @override
  ConsumerState<YouScreen> createState() => _YouScreenState();
}

class _YouScreenState extends ConsumerState<YouScreen> {
  final _hobbyPageController = PageController(viewportFraction: 0.88);
  final _savedPageController = PageController(viewportFraction: 0.88);
  final _triedPageController = PageController(viewportFraction: 0.88);
  final _pausedPageController = PageController(viewportFraction: 0.88);
  int _currentHobbyPage = 0;
  int _savedPage = 0;
  int _triedPage = 0;
  int _pausedPage = 0;
  int _selectedTab = 0; // 0=Active, 1=Paused, 2=Saved, 3=Tried

  @override
  void dispose() {
    _hobbyPageController.dispose();
    _savedPageController.dispose();
    _triedPageController.dispose();
    _pausedPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userHobbies = ref.watch(userHobbiesProvider);
    final allHobbiesAsync = ref.watch(hobbyListProvider);
    final authUser = ref.watch(authProvider).user;
    final profile = ref.watch(profileProvider);
    final displayName = authUser?.displayName ?? profile.username;
    final avatarUrl = authUser?.avatarUrl ?? profile.avatarUrl;

    final allHobbies = allHobbiesAsync.valueOrNull ?? [];

    final activeEntries = <HobbyWithMeta>[];
    final pausedEntries = <HobbyWithMeta>[];
    final savedEntries = <HobbyWithMeta>[];
    final triedEntries = <HobbyWithMeta>[];

    for (final entry in userHobbies.entries) {
      final uh = entry.value;
      final hobby = allHobbies.where((h) => h.id == uh.hobbyId).firstOrNull;
      if (hobby == null) continue;

      final meta = HobbyWithMeta(hobby: hobby, userHobby: uh);
      switch (uh.status) {
        case HobbyStatus.trying:
        case HobbyStatus.active:
          activeEntries.add(meta);
        case HobbyStatus.paused:
          pausedEntries.add(meta);
        case HobbyStatus.saved:
          savedEntries.add(meta);
        case HobbyStatus.done:
          triedEntries.add(meta);
      }
    }

    // Sort active hobbies the same way as Home screen:
    // most recently active first (lastActivityAt ?? startedAt, descending).
    activeEntries.sort((a, b) {
      final aTime = a.userHobby.lastActivityAt ?? a.userHobby.startedAt;
      final bTime = b.userHobby.lastActivityAt ?? b.userHobby.startedAt;
      if (aTime == null && bTime == null) return 0;
      if (aTime == null) return 1;
      if (bTime == null) return -1;
      return bTime.compareTo(aTime);
    });

    // Sort paused hobbies by pausedAt descending (most recently paused first).
    pausedEntries.sort((a, b) {
      final aTime = a.userHobby.pausedAt ?? DateTime(0);
      final bTime = b.userHobby.pausedAt ?? DateTime(0);
      return bTime.compareTo(aTime);
    });

    if (_currentHobbyPage >= activeEntries.length && activeEntries.isNotEmpty) {
      _currentHobbyPage = activeEntries.length - 1;
    }
    if (_savedPage >= savedEntries.length && savedEntries.isNotEmpty) {
      _savedPage = savedEntries.length - 1;
    }
    if (savedEntries.isEmpty) _savedPage = 0;
    if (_pausedPage >= pausedEntries.length && pausedEntries.isNotEmpty) {
      _pausedPage = pausedEntries.length - 1;
    }
    if (pausedEntries.isEmpty) _pausedPage = 0;
    if (_triedPage >= triedEntries.length && triedEntries.isNotEmpty) {
      _triedPage = triedEntries.length - 1;
    }
    if (triedEntries.isEmpty) _triedPage = 0;

    final visibleMeta = activeEntries.isNotEmpty
        ? activeEntries[_currentHobbyPage.clamp(0, activeEntries.length - 1)]
        : null;

    final allEntries = [...activeEntries, ...pausedEntries, ...savedEntries, ...triedEntries];
    final totalStepsCompleted = allEntries.fold(
        0, (sum, m) => sum + m.userHobby.completedStepIds.length);
    final bestStreak = allEntries.fold(
        0, (best, m) => m.userHobby.streakDays > best ? m.userHobby.streakDays : best);
    final hobbiesExplored = allEntries.length;

    final streakDays = visibleMeta != null
        ? computeStreak(visibleMeta.userHobby)
        : 0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: Stack(
          children: [
            SafeArea(
              bottom: false,
              child: ListView(
                padding: EdgeInsets.only(
                    top: 16, bottom: Spacing.scrollBottom(context)),
                children: [
                  // ── Centered profile header ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _CenteredProfileHeader(
                      displayName: displayName,
                      avatarUrl: avatarUrl,
                      streakDays: streakDays,
                      activeCount: activeEntries.length,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Tab pills ──
                  _TabPills(
                    selected: _selectedTab,
                    onSelect: (i) => setState(() => _selectedTab = i),
                    activeCt: activeEntries.length,
                    pausedCt: pausedEntries.length,
                    savedCt: savedEntries.length,
                    triedCt: triedEntries.length,
                  ),
                  const SizedBox(height: 20),

                  // ── Tab content — AnimatedSize so height collapses smoothly ──
                  AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    alignment: Alignment.topCenter,
                    clipBehavior: Clip.none,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                      layoutBuilder: (currentChild, previousChildren) => Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          ...previousChildren,
                          if (currentChild != null) currentChild,
                        ],
                      ),
                      child: _buildTabContent(
                        tab: _selectedTab,
                        activeEntries: activeEntries,
                        pausedEntries: pausedEntries,
                        savedEntries: savedEntries,
                        triedEntries: triedEntries,
                        visibleMeta: visibleMeta,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Journey stats ──
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

                  // ── Journal card (matches Settings tile style) ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: GlassCard(
                      onTap: () => context.push('/journal'),
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
                              child: Icon(
                                MdiIcons.bookOpenPageVariantOutline,
                                size: 16,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Journal',
                                    style: AppTypography.sansLabel.copyWith(
                                        color: AppColors.textSecondary)),
                                const SizedBox(height: 2),
                                Text(
                                  'Your session reflections',
                                  style: AppTypography.sansTiny.copyWith(
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: _ProNavRow(),
                  ),
                ],
              ),
            ),

            // ── Gear icon (top-right) ──
            Positioned(
              top: MediaQuery.of(context).padding.top + 20,
              right: 20,
              child: GestureDetector(
                onTap: () => context.push('/settings'),
                child: Icon(
                  MdiIcons.cogOutline,
                  size: 22,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent({
    required int tab,
    required List<HobbyWithMeta> activeEntries,
    required List<HobbyWithMeta> pausedEntries,
    required List<HobbyWithMeta> savedEntries,
    required List<HobbyWithMeta> triedEntries,
    required HobbyWithMeta? visibleMeta,
  }) {
    switch (tab) {
      case 0:
        return _ActiveTabContent(
          key: const ValueKey('active'),
          entries: activeEntries,
          visibleMeta: visibleMeta,
          hobbyPageController: _hobbyPageController,
          currentPage: _currentHobbyPage,
          onPageChanged: (i) => setState(() => _currentHobbyPage = i),
        );
      case 1:
        return _PausedTabContent(
          key: const ValueKey('paused'),
          entries: pausedEntries,
          pausedPage: _pausedPage,
          pausedPageController: _pausedPageController,
          onPageChanged: (i) => setState(() => _pausedPage = i),
        );
      case 2:
        return _SavedTabContent(
          key: const ValueKey('saved'),
          entries: savedEntries,
          savedPage: _savedPage,
          savedPageController: _savedPageController,
          onPageChanged: (i) => setState(() => _savedPage = i),
        );
      case 3:
        return _TriedTabContent(
          key: const ValueKey('tried'),
          entries: triedEntries,
          triedPage: _triedPage,
          triedPageController: _triedPageController,
          onPageChanged: (i) => setState(() => _triedPage = i),
        );
      default:
        return const SizedBox.shrink(key: ValueKey('empty'));
    }
  }
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

// ── Centered profile header ──
class _CenteredProfileHeader extends StatelessWidget {
  final String displayName;
  final String? avatarUrl;
  final int streakDays;
  final int activeCount;

  const _CenteredProfileHeader({
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
                  label: 'Start your streak →',
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
class _TabPills extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelect;
  final int activeCt;
  final int pausedCt;
  final int savedCt;
  final int triedCt;

  const _TabPills({
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

// ── Active tab content ──
class _ActiveTabContent extends ConsumerWidget {
  final List<HobbyWithMeta> entries;
  final HobbyWithMeta? visibleMeta;
  final PageController hobbyPageController;
  final int currentPage;
  final ValueChanged<int> onPageChanged;

  const _ActiveTabContent({
    super.key,
    required this.entries,
    required this.visibleMeta,
    required this.hobbyPageController,
    required this.currentPage,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (entries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: _EmptyActivePrompt(),
      );
    }

    final isPro = ref.watch(isProProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (entries.length == 1)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: CollectorCard(meta: entries.first),
          )
        else ...[
          SizedBox(
            height: 130,
            child: PageView.builder(
              controller: hobbyPageController,
              // Free users: show active card + 1 locked card only
              itemCount: isPro ? entries.length : entries.length.clamp(0, 2),
              onPageChanged: onPageChanged,
              itemBuilder: (context, i) {
                final card = Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: CollectorCard(meta: entries[i]),
                );
                if (isPro || i == 0) return card;
                return LockedCardOverlay(
                  lockedCount: entries.length - 1,
                  child: card,
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          PageDots(
            count: entries.length,
            current: currentPage,
          ),
        ],
        const SizedBox(height: 10),
        if (visibleMeta != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: StatsChipRow(meta: visibleMeta!),
          ),
      ],
    );
  }
}

// ── Paused tab content ──
class _PausedTabContent extends ConsumerWidget {
  final List<HobbyWithMeta> entries;
  final int pausedPage;
  final PageController pausedPageController;
  final ValueChanged<int> onPageChanged;

  const _PausedTabContent({
    super.key,
    required this.entries,
    required this.pausedPage,
    required this.pausedPageController,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (entries.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        child: Center(
          child: Text('No paused hobbies',
              style: TextStyle(color: AppColors.textMuted)),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (entries.length == 1)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: PausedHobbyCard(meta: entries.first),
          )
        else ...[
          SizedBox(
            height: 130,
            child: PageView.builder(
              controller: pausedPageController,
              itemCount: entries.length,
              onPageChanged: onPageChanged,
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: PausedHobbyCard(meta: entries[i]),
              ),
            ),
          ),
          const SizedBox(height: 8),
          PageDots(
            count: entries.length,
            current: pausedPage,
          ),
        ],
      ],
    );
  }
}

// ── Saved tab content ──
class _SavedTabContent extends StatelessWidget {
  final List<HobbyWithMeta> entries;
  final int savedPage;
  final PageController savedPageController;
  final ValueChanged<int> onPageChanged;

  const _SavedTabContent({
    super.key,
    required this.entries,
    required this.savedPage,
    required this.savedPageController,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('No saved hobbies yet',
                  style: TextStyle(color: AppColors.textMuted)),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () => context.go('/discover'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [AppColors.coral, Color(0xFFFF5252)],
                    ),
                  ),
                  child: Text('Browse hobbies',
                      style: AppTypography.caption
                          .copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 130,
          child: PageView.builder(
            controller: savedPageController,
            itemCount: entries.length,
            onPageChanged: onPageChanged,
            itemBuilder: (context, i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: SavedHobbySwipeCard(meta: entries[i]),
            ),
          ),
        ),
        const SizedBox(height: 8),
        PageDots(
          count: entries.length,
          current: savedPage,
        ),
      ],
    );
  }
}

// ── Tried tab content ──
class _TriedTabContent extends StatelessWidget {
  final List<HobbyWithMeta> entries;
  final int triedPage;
  final PageController triedPageController;
  final ValueChanged<int> onPageChanged;

  const _TriedTabContent({
    super.key,
    required this.entries,
    required this.triedPage,
    required this.triedPageController,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        child: Center(
          child: Text('Nothing tried yet',
              style: TextStyle(color: AppColors.textMuted)),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (entries.length == 1)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TriedHobbyCard(meta: entries.first),
          )
        else ...[
          SizedBox(
            height: 130,
            child: PageView.builder(
              controller: triedPageController,
              itemCount: entries.length,
              onPageChanged: onPageChanged,
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: TriedHobbyCard(meta: entries[i]),
              ),
            ),
          ),
          const SizedBox(height: 8),
          PageDots(
            count: entries.length,
            current: triedPage,
          ),
        ],
      ],
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

class _ProNavRow extends ConsumerWidget {
  const _ProNavRow();

  String _label(ProStatus s) {
    if (s.isLifetime) return 'Lifetime';
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

// ── Empty active prompt ──
class _EmptyActivePrompt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('No active hobbies',
                style: TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () => context.go('/discover'),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [AppColors.coral, Color(0xFFFF5252)],
                  ),
                ),
                child: Text('Discover hobbies',
                    style: AppTypography.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



