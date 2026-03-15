import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/hobby_provider.dart';
import '../../providers/user_provider.dart';
import '../../core/hobby_match.dart';
import '../../models/hobby.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_icons.dart';
import '../../theme/app_typography.dart';
import '../../theme/spacing.dart';
import '../../components/app_background.dart';
import '../../components/glass_card.dart';
import '../../components/spec_badge.dart';
import '../../components/share_card.dart';

// ═══════════════════════════════════════════════════════
//  DISCOVER TAB IDS
// ═══════════════════════════════════════════════════════

enum DiscoverTab {
  forYou('For You'),
  startCheap('Start Cheap'),
  startThisWeek('This Week'),
  differentVibe('Different Vibe');

  final String label;
  const DiscoverTab(this.label);
}

enum DiscoverViewMode { feed, list }

// ═══════════════════════════════════════════════════════
//  VIEW MODE PERSISTENCE
// ═══════════════════════════════════════════════════════

final discoverViewModeProvider =
    StateNotifierProvider<DiscoverViewModeNotifier, DiscoverViewMode>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return DiscoverViewModeNotifier(prefs);
});

class DiscoverViewModeNotifier extends StateNotifier<DiscoverViewMode> {
  final SharedPreferences _prefs;
  static const _key = 'discover_view_mode';

  DiscoverViewModeNotifier(this._prefs)
      : super(_prefs.getString(_key) == 'list'
            ? DiscoverViewMode.list
            : DiscoverViewMode.feed);

  void toggle() {
    state = state == DiscoverViewMode.feed
        ? DiscoverViewMode.list
        : DiscoverViewMode.feed;
    _prefs.setString(_key, state == DiscoverViewMode.list ? 'list' : 'feed');
  }
}

// ═══════════════════════════════════════════════════════
//  PREMIUM FEED DISCOVER SCREEN
// ═══════════════════════════════════════════════════════

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  DiscoverTab _activeTab = DiscoverTab.forYou;
  late PageController _feedController;
  double _currentPageValue = 0.0;

  @override
  void initState() {
    super.initState();
    _feedController = PageController();
    _feedController.addListener(_onPageScroll);
  }

  void _onPageScroll() {
    if (!_feedController.position.haveDimensions) return;
    final page = _feedController.page ?? 0.0;
    setState(() {
      _currentPageValue = page;
    });
  }

  @override
  void dispose() {
    _feedController.removeListener(_onPageScroll);
    _feedController.dispose();
    super.dispose();
  }

  void _switchTab(DiscoverTab tab) {
    if (tab == _activeTab) return;
    // Dispose old controller and create fresh one so PageView fully rebuilds
    _feedController.removeListener(_onPageScroll);
    _feedController.dispose();
    _feedController = PageController();
    _feedController.addListener(_onPageScroll);
    setState(() {
      _activeTab = tab;
      _currentPageValue = 0.0;
    });
  }

  // ── Filtering / Ranking Logic ──────────────────────

  List<Hobby> _getHobbiesForTab(
      List<Hobby> allHobbies, UserPreferences prefs) {
    switch (_activeTab) {
      case DiscoverTab.forYou:
        return _forYou(allHobbies, prefs);
      case DiscoverTab.startCheap:
        return _startCheap(allHobbies);
      case DiscoverTab.startThisWeek:
        return _startThisWeek(allHobbies);
      case DiscoverTab.differentVibe:
        return _differentVibe(allHobbies, prefs);
    }
  }

  List<Hobby> _forYou(List<Hobby> all, UserPreferences prefs) {
    final scored = all.map((h) {
      final score = computeMatchScore(
        hobby: h,
        userHours: prefs.hoursPerWeek.toDouble(),
        userBudgetLevel: prefs.budgetLevel,
        userPrefersSocial: prefs.preferSocial,
        userVibes: prefs.vibes,
      );
      return (hobby: h, score: score);
    }).toList();
    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored.map((e) => e.hobby).toList();
  }

  List<Hobby> _startCheap(List<Hobby> all) {
    // Filter by the MINIMUM starter cost — "can I start for under CHF 50?"
    // A hobby like "CHF 0–150" has min=0, so it IS cheap to start.
    // Use min cost for filtering, max cost as tiebreaker for sorting.
    final cheap = all.where((h) {
      final (min, _) = parseCostRange(h.costText);
      return min <= 50;
    }).toList();
    // Sort by minimum cost ascending, then max as tiebreaker
    cheap.sort((a, b) {
      final (aMin, aMax) = parseCostRange(a.costText);
      final (bMin, bMax) = parseCostRange(b.costText);
      final cmp = aMin.compareTo(bMin);
      return cmp != 0 ? cmp : aMax.compareTo(bMax);
    });
    return cheap;
  }

  List<Hobby> _startThisWeek(List<Hobby> all) {
    // Low friction: short time commitment AND easy or medium difficulty
    final quick = all.where((h) {
      final hours = parseWeeklyHours(h.timeText);
      final diff = h.difficultyText.toLowerCase();
      return hours <= 3 && (diff == 'easy' || diff == 'medium');
    }).toList();
    // Sort: easy before medium, then by time ascending
    quick.sort((a, b) {
      final aDiff = a.difficultyText.toLowerCase() == 'easy' ? 0 : 1;
      final bDiff = b.difficultyText.toLowerCase() == 'easy' ? 0 : 1;
      if (aDiff != bDiff) return aDiff.compareTo(bDiff);
      final aH = parseWeeklyHours(a.timeText);
      final bH = parseWeeklyHours(b.timeText);
      return aH.compareTo(bH);
    });
    return quick;
  }

  List<Hobby> _differentVibe(List<Hobby> all, UserPreferences prefs) {
    final scored = all.map((h) {
      final score = computeMatchScore(
        hobby: h,
        userHours: prefs.hoursPerWeek.toDouble(),
        userBudgetLevel: prefs.budgetLevel,
        userPrefersSocial: prefs.preferSocial,
        userVibes: prefs.vibes,
      );
      return (hobby: h, score: score);
    }).toList();
    scored.sort((a, b) => a.score.compareTo(b.score)); // lowest first
    return scored.map((e) => e.hobby).toList();
  }

  @override
  Widget build(BuildContext context) {
    final hobbiesAsync = ref.watch(hobbyListProvider);
    final prefs = ref.watch(userPreferencesProvider);
    final viewMode = ref.watch(discoverViewModeProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: hobbiesAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          ),
          error: (e, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded,
                    size: 32, color: AppColors.textMuted),
                const SizedBox(height: 12),
                Text('Something went wrong',
                    style: AppTypography.body
                        .copyWith(color: AppColors.textMuted)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => ref.invalidate(hobbyListProvider),
                  child: Text('Tap to retry',
                      style: AppTypography.body
                          .copyWith(color: AppColors.accent)),
                ),
              ],
            ),
          ),
          data: (allHobbies) {
            final hobbies = _getHobbiesForTab(allHobbies, prefs);
            return Stack(
              children: [
                // Content — feed or list
                if (viewMode == DiscoverViewMode.feed)
                  _buildFeedView(hobbies, prefs)
                else
                  _buildListView(hobbies, prefs),

                // Floating top chrome
                _buildTopChrome(),
              ],
            );
          },
        ),
      ),
    );
  }

  // ── Top Chrome ────────────────────────────────────────

  Widget _buildTopChrome() {
    final topPad = MediaQuery.of(context).padding.top;
    // Fixed height: status bar + content (~90px) + generous fade tail
    final chromeHeight = topPad + 140.0;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: chromeHeight,
      child: Stack(
        children: [
          // Gradient scrim — fills entire fixed height, fades to zero
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.black.withValues(alpha: 0.4),
                      Colors.black.withValues(alpha: 0.0),
                    ],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                ),
              ),
            ),
          ),
          // Content (pills, icons) — sits at top of the fixed area
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        'Discover',
                        style: AppTypography.title.copyWith(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                        ),
                      ),
                      const Spacer(),
                      _buildViewToggle(),
                      const SizedBox(width: 12),
                      _buildSearchButton(),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildPillTabs(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchButton() {
    return GestureDetector(
      onTap: () => context.push('/search'),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.glassBackground,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.glassBorder, width: 0.5),
        ),
        child: const Icon(
          Icons.search_rounded,
          size: 18,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildViewToggle() {
    final viewMode = ref.watch(discoverViewModeProvider);
    final isFeed = viewMode == DiscoverViewMode.feed;

    return GestureDetector(
      onTap: () => ref.read(discoverViewModeProvider.notifier).toggle(),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.glassBackground,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.glassBorder, width: 0.5),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            isFeed ? Icons.view_list_rounded : Icons.view_carousel_rounded,
            key: ValueKey(isFeed),
            size: 18,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildPillTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: DiscoverTab.values.map((tab) {
          final isActive = _activeTab == tab;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => _switchTab(tab),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.accent.withValues(alpha: 0.15)
                      : AppColors.glassBackground,
                  borderRadius: BorderRadius.circular(Spacing.radiusBadge),
                  border: Border.all(
                    color: isActive
                        ? AppColors.accent.withValues(alpha: 0.4)
                        : AppColors.glassBorder,
                    width: 0.5,
                  ),
                ),
                child: Text(
                  tab.label,
                  style: AppTypography.caption.copyWith(
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    color:
                        isActive ? AppColors.accent : AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Feed View (TikTok-style vertical PageView) ────────

  Widget _buildFeedView(List<Hobby> hobbies, UserPreferences prefs) {
    if (hobbies.isEmpty) return _buildEmpty();

    // Capture stable context for share
    final rootContext = context;

    return PageView.builder(
      key: ValueKey('feed_${_activeTab.name}'),
      controller: _feedController,
      scrollDirection: Axis.vertical,
      itemCount: hobbies.length,
      itemBuilder: (ctx, index) {
        final hobby = hobbies[index];
        final isSaved = ref.watch(isHobbySavedProvider(hobby.id));
        double parallaxOffset = 0.0;
        if (_feedController.position.haveDimensions) {
          parallaxOffset = _currentPageValue - index;
        }
        return _DiscoverFeedCard(
          hobby: hobby,
          isSaved: isSaved,
          parallaxOffset: parallaxOffset,
          userPrefs: prefs,
          onTap: () => ctx.push('/hobby/${hobby.id}'),
          onSave: () =>
              ref.read(userHobbiesProvider.notifier).toggleSave(hobby.id),
          onShare: () => shareHobby(rootContext, hobby),
        );
      },
    );
  }

  // ── List View ─────────────────────────────────────────

  Widget _buildListView(List<Hobby> hobbies, UserPreferences prefs) {
    if (hobbies.isEmpty) return _buildEmpty();

    // Account for top chrome height
    final topPad = MediaQuery.of(context).padding.top + 110;

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
          20, topPad, 20, Spacing.scrollBottom(context) + 80),
      itemCount: hobbies.length,
      itemBuilder: (ctx, index) {
        final hobby = hobbies[index];
        return _DiscoverListCard(
          hobby: hobby,
          userPrefs: prefs,
          onTap: () => ctx.push('/hobby/${hobby.id}'),
        )
            .animate()
            .fadeIn(duration: 400.ms, delay: (index * 60).ms)
            .slideY(
              begin: 0.05,
              end: 0,
              duration: 400.ms,
              delay: (index * 60).ms,
              curve: Curves.easeOutCubic,
            );
      },
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.explore_off_rounded, size: 40, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text('No hobbies here yet',
              style:
                  AppTypography.body.copyWith(color: AppColors.textMuted)),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => _switchTab(DiscoverTab.forYou),
            child: Text('Try "For You" instead',
                style:
                    AppTypography.body.copyWith(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  DISCOVER FEED CARD — Decision-focused, not social-feed
// ═══════════════════════════════════════════════════════

class _DiscoverFeedCard extends StatelessWidget {
  final Hobby hobby;
  final bool isSaved;
  final double parallaxOffset;
  final UserPreferences userPrefs;
  final VoidCallback? onTap;
  final VoidCallback? onSave;
  final VoidCallback? onShare;

  const _DiscoverFeedCard({
    required this.hobby,
    required this.isSaved,
    required this.parallaxOffset,
    required this.userPrefs,
    this.onTap,
    this.onSave,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final reasons = computeMatchReasons(
      hobby: hobby,
      userHours: userPrefs.hoursPerWeek.toDouble(),
      userBudgetLevel: userPrefs.budgetLevel,
      userPrefersSocial: userPrefs.preferSocial,
      userVibes: userPrefs.vibes,
    );

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Full-bleed background image with parallax
          Transform.translate(
            offset: Offset(0, parallaxOffset * 50),
            child: Hero(
              tag: 'hobby_image_${hobby.id}',
              child: CachedNetworkImage(
                imageUrl: hobby.imageUrl,
                fit: BoxFit.cover,
                memCacheWidth: 800,
                width: double.infinity,
                height: double.infinity,
                placeholder: (_, __) => Container(
                  color: AppColors.surfaceElevated,
                  child: Center(
                    child: Icon(AppIcons.categoryIcon(hobby.category),
                        size: 48, color: AppColors.textMuted),
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  color: AppColors.surfaceElevated,
                  child: Center(
                    child: Icon(AppIcons.categoryIcon(hobby.category),
                        size: 48, color: AppColors.textMuted),
                  ),
                ),
              ),
            ),
          ),

          // Gradient overlay — heavier at bottom for readability
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x00000000),
                  Color(0x10000000),
                  Color(0x90000000),
                  Color(0xE0000000),
                ],
                stops: [0.0, 0.30, 0.60, 1.0],
              ),
            ),
          ),

          // Top gradient for chrome readability
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 140,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x60000000),
                    Color(0x00000000),
                  ],
                ),
              ),
            ),
          ),

          // Right-side action buttons (minimal — just save + share)
          Positioned(
            right: 14,
            bottom: 220,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _FeedAction(
                  icon: isSaved
                      ? AppIcons.heartFilled
                      : AppIcons.heartOutline,
                  isActive: isSaved,
                  activeColor: AppColors.redHeart,
                  onTap: onSave,
                ),
                const SizedBox(height: 4),
                _FeedAction(
                  icon: AppIcons.share,
                  onTap: onShare,
                ),
              ],
            ),
          ),

          // Bottom content shelf — decision-focused
          Positioned(
            left: 20,
            right: 72,
            bottom: 180,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Category overline
                Text(
                  hobby.category.toUpperCase(),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 2,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 6),

                // Hobby title
                Hero(
                  tag: 'hobby_title_${hobby.id}',
                  child: Material(
                    color: Colors.transparent,
                    child: Builder(builder: (_) {
                      final words = hobby.title.split(' ');
                      final titleStyle = AppTypography.display.copyWith(
                        color: Colors.white,
                        fontSize: 28,
                        height: 1.15,
                        shadows: [
                          Shadow(
                            blurRadius: 12,
                            color: Colors.black.withValues(alpha: 0.5),
                          ),
                        ],
                      );
                      if (words.length <= 1) {
                        return Text(hobby.title, style: titleStyle);
                      }
                      return Text.rich(TextSpan(children: [
                        TextSpan(
                          text: words.first,
                          style: titleStyle.copyWith(color: AppColors.coral),
                        ),
                        TextSpan(
                          text: ' ${words.skip(1).join(' ')}',
                          style: titleStyle,
                        ),
                      ]));
                    }),
                  ),
                ),
                const SizedBox(height: 8),

                // Emotional hook
                Text(
                  hobby.hook,
                  style: AppTypography.body.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 14,
                    height: 1.4,
                    shadows: [
                      Shadow(
                        blurRadius: 8,
                        color: Colors.black.withValues(alpha: 0.4),
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Specs line
                SpecBar(
                  cost: hobby.costText,
                  time: hobby.timeText,
                  difficulty: hobby.difficultyText,
                  small: true,
                  onDark: true,
                ),

                // Why it fits — personalized reason
                if (reasons.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      reasons.first,
                      style: AppTypography.caption.copyWith(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Bottom CTA
          Positioned(
            left: 40,
            right: 40,
            bottom: 120,
            child: _buildCta(),
          ),
        ],
      ),
    );
  }

  Widget _buildCta() {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: Spacing.buttonSecondaryHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Spacing.radiusCta),
          gradient: const LinearGradient(
            colors: [AppColors.coral, Color(0xFFFF5252)],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.coral.withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Check it out',
                style: AppTypography.button.copyWith(
                  fontSize: 13,
                  letterSpacing: 0.6,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_rounded,
                  size: 16, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  FEED ACTION BUTTON (simplified from HobbyCard)
// ═══════════════════════════════════════════════════════

class _FeedAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool isActive;
  final Color? activeColor;

  const _FeedAction({
    required this.icon,
    this.onTap,
    this.isActive = false,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isActive ? (activeColor ?? Colors.white) : Colors.white;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 26,
          color: color,
          shadows: [
            Shadow(
              blurRadius: 12,
              color: Colors.black.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  DISCOVER LIST CARD — Premium vertical list item
// ═══════════════════════════════════════════════════════

class _DiscoverListCard extends StatelessWidget {
  final Hobby hobby;
  final UserPreferences userPrefs;
  final VoidCallback? onTap;

  const _DiscoverListCard({
    required this.hobby,
    required this.userPrefs,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final reasons = computeMatchReasons(
      hobby: hobby,
      userHours: userPrefs.hoursPerWeek.toDouble(),
      userBudgetLevel: userPrefs.budgetLevel,
      userPrefersSocial: userPrefs.preferSocial,
      userVibes: userPrefs.vibes,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GlassCard(
        onTap: onTap,
        padding: EdgeInsets.zero,
        borderRadius: 18,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero image
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
              child: SizedBox(
                height: 180,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: hobby.imageUrl,
                      fit: BoxFit.cover,
                      memCacheWidth: 600,
                      placeholder: (_, __) =>
                          Container(color: AppColors.surfaceElevated),
                      errorWidget: (_, __, ___) => Container(
                        color: AppColors.surfaceElevated,
                        child: Icon(AppIcons.categoryIcon(hobby.category),
                            size: 32, color: AppColors.textMuted),
                      ),
                    ),
                    // Subtle bottom gradient for text overlap
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 60,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.3),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category
                  Text(
                    hobby.category.toUpperCase(),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textMuted,
                      letterSpacing: 2,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Title
                  Text(
                    hobby.title,
                    style: AppTypography.title.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Hook
                  Text(
                    hobby.hook,
                    style: AppTypography.body.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),

                  // Specs
                  SpecBar(
                    cost: hobby.costText,
                    time: hobby.timeText,
                    difficulty: hobby.difficultyText,
                    small: true,
                  ),

                  // Why it fits
                  if (reasons.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        reasons.first,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
