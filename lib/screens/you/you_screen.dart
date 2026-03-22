import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../components/app_background.dart';
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

/// You tab — profile header + tab pills (Active / Saved / Tried).
class YouScreen extends ConsumerStatefulWidget {
  const YouScreen({super.key});

  @override
  ConsumerState<YouScreen> createState() => _YouScreenState();
}

class _YouScreenState extends ConsumerState<YouScreen> {
  late PageController _hobbyPageController;
  late PageController _savedPageController;
  int _currentHobbyPage = 0;
  int _savedPage = 0;
  int _selectedTab = 0; // 0=Active, 1=Saved, 2=Tried

  @override
  void initState() {
    super.initState();
    _hobbyPageController = PageController(viewportFraction: 0.88);
    _savedPageController = PageController(viewportFraction: 0.88);
  }

  @override
  void dispose() {
    _hobbyPageController.dispose();
    _savedPageController.dispose();
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
    if (_savedPage >= savedEntries.length && savedEntries.isNotEmpty) {
      _savedPage = savedEntries.length - 1;
    }
    if (savedEntries.isEmpty) _savedPage = 0;

    final visibleMeta = activeEntries.isNotEmpty
        ? activeEntries[_currentHobbyPage.clamp(0, activeEntries.length - 1)]
        : null;

    final allEntries = [...activeEntries, ...savedEntries, ...triedEntries];
    final totalStepsCompleted = allEntries.fold(
        0, (sum, m) => sum + m.userHobby.completedStepIds.length);
    final bestStreak = allEntries.fold(
        0, (best, m) => m.userHobby.streakDays > best ? m.userHobby.streakDays : best);
    final hobbiesExplored = allEntries.length;

    final streakDays = visibleMeta != null
        ? _computeStreak(visibleMeta.userHobby)
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
    required List<_HobbyWithMeta> activeEntries,
    required List<_HobbyWithMeta> savedEntries,
    required List<_HobbyWithMeta> triedEntries,
    required _HobbyWithMeta? visibleMeta,
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
        return _SavedTabContent(
          key: const ValueKey('saved'),
          entries: savedEntries,
          savedPage: _savedPage,
          savedPageController: _savedPageController,
          onPageChanged: (i) => setState(() => _savedPage = i),
        );
      case 2:
        return _TriedTabContent(
          key: const ValueKey('tried'),
          entries: triedEntries,
        );
      default:
        return const SizedBox.shrink(key: ValueKey('empty'));
    }
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
  final int savedCt;
  final int triedCt;

  const _TabPills({
    required this.selected,
    required this.onSelect,
    required this.activeCt,
    required this.savedCt,
    required this.triedCt,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = [
      ('Active', activeCt),
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
  final List<_HobbyWithMeta> entries;
  final _HobbyWithMeta? visibleMeta;
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
            child: _CollectorCard(meta: entries.first),
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
                  child: _CollectorCard(meta: entries[i]),
                );
                if (isPro || i == 0) return card;
                return _LockedCardOverlay(
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
            child: _StatsChipRow(meta: visibleMeta!),
          ),
      ],
    );
  }
}

// ── Locked card overlay (sits on top of a hobby card for free users) ──
class _LockedCardOverlay extends StatelessWidget {
  final int lockedCount;
  final Widget child;
  const _LockedCardOverlay({required this.lockedCount, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                color: AppColors.background.withValues(alpha: 0.85),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock_rounded,
                          color: AppColors.coral.withValues(alpha: 0.8),
                          size: 22),
                      const SizedBox(height: 8),
                      Text(
                        'Track $lockedCount more ${lockedCount == 1 ? 'hobby' : 'hobbies'} with Pro',
                        style: AppTypography.sansLabel.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () => context.push('/pro'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.coral,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text('Unlock Pro',
                              style: AppTypography.sansCaption.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              )),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Saved tab content ──
class _SavedTabContent extends StatelessWidget {
  final List<_HobbyWithMeta> entries;
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
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: _EmptyTabPrompt(
          message: 'No saved hobbies yet',
          detail: 'Heart a hobby to save it for later.',
          actionLabel: 'Browse hobbies',
          onAction: () => context.go('/discover'),
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
              child: _SavedHobbySwipeCard(meta: entries[i]),
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
  final List<_HobbyWithMeta> entries;

  const _TriedTabContent({
    super.key,
    required this.entries,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: _EmptyTabPrompt(
          message: 'Nothing tried yet',
          detail: 'Complete a hobby or mark it as done to see it here.',
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: entries
          .map((m) => Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 10),
                child: _TriedHobbyCard(meta: m),
              ))
          .toList(),
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
                          child: _CoralFirstWordTitle(
                            title: hobby.title,
                            style: AppTypography.title.copyWith(
                              fontSize: 18,
                              color: AppColors.textPrimary,
                            ),
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
                                      color: Colors.white,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '%',
                                    style: GoogleFonts.ibmPlexMono(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
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
                            Colors.white),
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
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
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

// ── Generic empty tab prompt ──
class _EmptyTabPrompt extends StatelessWidget {
  final String message;
  final String detail;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _EmptyTabPrompt({
    required this.message,
    required this.detail,
    this.actionLabel,
    this.onAction,
  });

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
          Text(message, style: AppTypography.title.copyWith(fontSize: 16)),
          const SizedBox(height: 6),
          Text(
            detail,
            textAlign: TextAlign.center,
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 14),
            GestureDetector(
              onTap: onAction,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(actionLabel!,
                      style: AppTypography.button
                          .copyWith(color: Colors.white)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Saved hobby swipe card — matches CollectorCard dimensions exactly ──
class _SavedHobbySwipeCard extends ConsumerWidget {
  final _HobbyWithMeta meta;
  const _SavedHobbySwipeCard({required this.meta});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hobby = meta.hobby;

    return GestureDetector(
      onTap: () => context.push('/hobby/${hobby.id}'),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 130,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image — same as CollectorCard
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
              // Gradient — identical to CollectorCard
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x1A0A0A0F), Color(0xF80A0A0F)],
                  ),
                ),
              ),
              // Heart unsave — top right, tapping directly unsaves
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () => ref
                      .read(userHobbiesProvider.notifier)
                      .unsaveHobby(hobby.id),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.favorite_rounded,
                      size: 18,
                      color: AppColors.accent,
                      shadows: [
                        Shadow(
                          blurRadius: 8,
                          color: AppColors.accent.withValues(alpha: 0.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Bottom content — same structure as CollectorCard
              Positioned(
                left: 14,
                right: 14,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'SAVED FOR LATER',
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
                          child: _CoralFirstWordTitle(
                            title: hobby.title,
                            style: AppTypography.title.copyWith(
                              fontSize: 18,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          hobby.costText,
                          style: AppTypography.monoTiny.copyWith(
                            color: AppColors.textPrimary.withValues(alpha: 0.45),
                            fontSize: 10,
                          ),
                        ),
                      ],
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

// ── Coral first word title ──
class _CoralFirstWordTitle extends StatelessWidget {
  final String title;
  final TextStyle style;
  const _CoralFirstWordTitle({required this.title, required this.style});

  @override
  Widget build(BuildContext context) {
    final spaceIdx = title.indexOf(' ');
    if (spaceIdx <= 0) {
      return Text(
        title,
        style: style.copyWith(color: AppColors.coral),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }
    return Text.rich(
      TextSpan(children: [
        TextSpan(
          text: '${title.substring(0, spaceIdx)} ',
          style: style.copyWith(color: AppColors.coral),
        ),
        TextSpan(
          text: title.substring(spaceIdx + 1),
          style: style,
        ),
      ]),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
