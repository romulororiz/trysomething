import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../components/hobby_card.dart';
import '../../components/share_card.dart';
import '../../core/hobby_match.dart';
import '../../models/hobby.dart';
import '../../providers/hobby_provider.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/motion.dart';
import '../../theme/spacing.dart';

/// Full-screen TikTok-style vertical feed for a specific Discover rail.
/// Shown when user taps "Explore all →" on a rail header.
class RailFeedScreen extends ConsumerStatefulWidget {
  final String
      railId; // 'for-you' | 'start-cheap' | 'start-this-week' | 'different-vibe'
  final String railTitle;

  const RailFeedScreen({
    super.key,
    required this.railId,
    required this.railTitle,
  });

  @override
  ConsumerState<RailFeedScreen> createState() => _RailFeedScreenState();
}

class _RailFeedScreenState extends ConsumerState<RailFeedScreen> {
  late PageController _pageController;
  bool _showSwipeHint = true;
  int _currentPage = 0;
  double _currentPageValue = 0.0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(_onPageScroll);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showSwipeHint = false);
    });
  }

  void _onPageScroll() {
    if (!_pageController.position.haveDimensions) return;
    final page = _pageController.page ?? 0.0;
    setState(() {
      _currentPageValue = page;
      _currentPage = page.round();
    });
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageScroll);
    _pageController.dispose();
    super.dispose();
  }

  Color _getCategoryGlowColor(String category) {
    switch (category.toLowerCase()) {
      case 'creative':
        return const Color(0xFFFF6B6B); // coral
      case 'outdoors':
        return const Color(0xFF06D6A0); // sage
      case 'fitness':
        return const Color(0xFFFFB347); // amber
      case 'music':
        return const Color(0xFF7B68EE); // indigo
      case 'food':
        return const Color(0xFFDAA520); // golden
      case 'maker':
        return const Color(0xFF87CEEB); // steel
      case 'mind':
        return const Color(0xFFDDA0DD); // lavender
      case 'collecting':
        return const Color(0xFFF5F0EB); // cream
      case 'social':
        return const Color(0xFFFFB6C1); // peach
      default:
        return const Color(0xFFF5F0EB);
    }
  }

  List<Hobby> _filterHobbies(List<Hobby> all, UserPreferences prefs) {
    switch (widget.railId) {
      case 'start-cheap':
        return all.where((h) {
          final (_, max) = parseCostRange(h.costText);
          return max <= 30;
        }).toList();

      case 'start-this-week':
        return all.where((h) {
          final hours = parseWeeklyHours(h.timeText);
          return hours <= 2 && h.difficultyText.toLowerCase() == 'easy';
        }).toList();

      case 'different-vibe':
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
        scored.sort((a, b) => a.score.compareTo(b.score));
        return scored.map((e) => e.hobby).toList();

      case 'for-you':
      default:
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
  }

  @override
  Widget build(BuildContext context) {
    final hobbiesAsync = ref.watch(hobbyListProvider);
    final prefs = ref.watch(userPreferencesProvider);
    // Capture stable context for share — itemBuilder shadows 'context' with
    // a short-lived builder context that may become stale across async gaps.
    final rootContext = context;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: hobbiesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.coral),
        ),
        error: (e, _) => Center(
          child: Text('$e',
              style:
                  AppTypography.sansBody.copyWith(color: AppColors.warmGray)),
        ),
        data: (allHobbies) {
          final hobbies = _filterHobbies(allHobbies, prefs);
          if (hobbies.isEmpty) {
            return _buildEmpty();
          }
          final currentHobby = hobbies[
              _currentPage.clamp(0, hobbies.length - 1)];
          return Stack(
            children: [
              // Category ambient glow (behind everything)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: MediaQuery.of(context).size.height * 0.4,
                child: IgnorePointer(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.bottomCenter,
                        radius: 1.2,
                        colors: [
                          _getCategoryGlowColor(currentHobby.category)
                              .withValues(alpha: 0.05),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // TikTok-style vertical PageView
              PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                itemCount: hobbies.length,
                itemBuilder: (itemCtx, index) {
                  final hobby = hobbies[index];
                  final isSaved = ref.watch(isHobbySavedProvider(hobby.id));
                  double parallaxOffset = 0.0;
                  if (_pageController.position.haveDimensions) {
                    parallaxOffset = _currentPageValue - index;
                  }
                  return HobbyCard(
                    hobby: hobby,
                    isSaved: isSaved,
                    compactCta: true,
                    parallaxOffset: parallaxOffset,
                    onTap: () => itemCtx.push('/hobby/${hobby.id}'),
                    onSave: () => ref
                        .read(userHobbiesProvider.notifier)
                        .toggleSave(hobby.id),
                    onShare: () => shareHobby(rootContext, hobby),
                  );
                },
              ),

              // Back button + title overlay
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xCC000000), Colors.transparent],
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 4, 16, 12),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_rounded,
                                color: Colors.white),
                            onPressed: () => context.pop(),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.railTitle,
                            style: AppTypography.sansLabel.copyWith(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Swipe hint — animated chevron, fades after 3s
              if (_showSwipeHint)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: Spacing.scrollBottomPadding,
                  child: AnimatedOpacity(
                    opacity: _showSwipeHint ? 1.0 : 0.0,
                    duration: Motion.slow,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.keyboard_arrow_up_rounded,
                          size: 24,
                          color: Colors.white70,
                        )
                            .animate(
                              onPlay: (c) => c.repeat(reverse: true),
                            )
                            .moveY(
                              begin: 0,
                              end: -6,
                              duration: 1500.ms,
                              curve: Curves.easeInOut,
                            ),
                        const SizedBox(height: 2),
                        Text(
                          'Swipe up to explore',
                          style: AppTypography.sansCaption.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off_rounded,
              size: 40, color: AppColors.warmGray),
          const SizedBox(height: 12),
          Text(
            'No hobbies here yet',
            style: AppTypography.sansBody.copyWith(color: AppColors.warmGray),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => context.pop(),
            child: Text('Go back',
                style:
                    AppTypography.sansLabel.copyWith(color: AppColors.coral)),
          ),
        ],
      ),
    );
  }
}
