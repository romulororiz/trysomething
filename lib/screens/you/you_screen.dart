import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../components/app_background.dart';
import '../../components/glass_card.dart';
import '../../models/hobby.dart';
import '../../providers/hobby_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/feature_providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/spacing.dart';
import 'active_tab_content.dart';
import 'paused_tab_content.dart';
import 'saved_tab_content.dart';
import 'tried_tab_content.dart';
import 'you_helpers.dart';
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
                    child: CenteredProfileHeader(
                      displayName: displayName,
                      avatarUrl: avatarUrl,
                      streakDays: streakDays,
                      activeCount: activeEntries.length,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Tab pills ──
                  TabPills(
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
                    child: SectionLabel('YOUR JOURNEY'),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: JourneyStats(
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
                    child: ProNavRow(),
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
        return ActiveTabContent(
          key: const ValueKey('active'),
          entries: activeEntries,
          visibleMeta: visibleMeta,
          hobbyPageController: _hobbyPageController,
          currentPage: _currentHobbyPage,
          onPageChanged: (i) => setState(() => _currentHobbyPage = i),
        );
      case 1:
        return PausedTabContent(
          key: const ValueKey('paused'),
          entries: pausedEntries,
          pausedPage: _pausedPage,
          pausedPageController: _pausedPageController,
          onPageChanged: (i) => setState(() => _pausedPage = i),
        );
      case 2:
        return SavedTabContent(
          key: const ValueKey('saved'),
          entries: savedEntries,
          savedPage: _savedPage,
          savedPageController: _savedPageController,
          onPageChanged: (i) => setState(() => _savedPage = i),
        );
      case 3:
        return TriedTabContent(
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
