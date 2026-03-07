import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../components/hobby_card.dart';
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

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showSwipeHint = false);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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

    return Scaffold(
      backgroundColor: Colors.black,
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
          return Stack(
            children: [
              // TikTok-style vertical PageView
              PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                itemCount: hobbies.length,
                itemBuilder: (context, index) {
                  final hobby = hobbies[index];
                  final isSaved = ref.watch(isHobbySavedProvider(hobby.id));
                  return HobbyCard(
                    hobby: hobby,
                    isSaved: isSaved,
                    compactCta: true,
                    onTap: () => context.push('/hobby/${hobby.id}'),
                    onSave: () => ref
                        .read(userHobbiesProvider.notifier)
                        .toggleSave(hobby.id),
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

              // Swipe hint
              if (_showSwipeHint)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: Spacing.scrollBottomPadding,
                  child: AnimatedOpacity(
                    opacity: _showSwipeHint ? 1.0 : 0.0,
                    duration: Motion.normal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.keyboard_arrow_up_rounded,
                            size: 18, color: Colors.white70),
                        const SizedBox(width: 4),
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
