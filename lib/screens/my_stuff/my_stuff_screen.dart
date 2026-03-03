import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/hobby.dart';
import '../../theme/category_ui.dart';
import '../../providers/hobby_provider.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_icons.dart';
import '../../theme/app_typography.dart';
import '../../theme/spacing.dart';
import '../../theme/motion.dart';
import '../../theme/scroll_physics.dart';

/// My Stuff — saved/trying/active/done hobbies with stat chips and tab bar.
class MyStuffScreen extends ConsumerStatefulWidget {
  const MyStuffScreen({super.key});

  @override
  ConsumerState<MyStuffScreen> createState() => _MyStuffScreenState();
}

class _MyStuffScreenState extends ConsumerState<MyStuffScreen> {
  int _tabIndex = 0;
  static const _tabs = ['Saved', 'Trying', 'Active', 'Done'];
  static const _statusMap = [
    HobbyStatus.saved,
    HobbyStatus.trying,
    HobbyStatus.active,
    HobbyStatus.done,
  ];

  @override
  Widget build(BuildContext context) {
    final userHobbies = ref.watch(userHobbiesProvider);
    final allHobbiesAsync = ref.watch(hobbyListProvider);

    // Current tab items
    final currentStatus = _statusMap[_tabIndex];
    final filteredUserHobbies = userHobbies.values
        .where((uh) => uh.status == currentStatus)
        .toList();

    return allHobbiesAsync.when(
      loading: () => const SafeArea(child: Center(child: CircularProgressIndicator())),
      error: (err, _) => SafeArea(child: Center(child: Text('$err'))),
      data: (allHobbies) {
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 10),
            child: Row(
              children: [
                Text('My Stuff', style: AppTypography.serifHeading),
                const Spacer(),
                GestureDetector(
                  onTap: () => context.push('/search'),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.sand,
                    ),
                    child: const Icon(Icons.search,
                        size: 20, color: AppColors.driftwood),
                  ),
                ),
              ],
            ),
          ),

          // Tab bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.sandDark, width: 1),
                ),
              ),
              child: Row(
                children: List.generate(_tabs.length, (i) {
                  final isSelected = i == _tabIndex;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _tabIndex = i),
                      child: AnimatedContainer(
                        duration: Motion.fast,
                        padding: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: isSelected ? AppColors.coral : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Text(
                          _tabs[i],
                          textAlign: TextAlign.center,
                          style: AppTypography.sansCaption.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isSelected ? AppColors.coral : AppColors.warmGray,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          // Section header with count
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
            child: Row(
              children: [
                Text(
                  'Currently ${_tabs[_tabIndex]}',
                  style: AppTypography.sansSection.copyWith(
                    color: AppColors.nearBlack,
                  ),
                ),
                const Spacer(),
                Text(
                  '${filteredUserHobbies.length} hobbies',
                  style: AppTypography.sansCaption.copyWith(
                    color: AppColors.coral,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: filteredUserHobbies.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    physics: const TryScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
                    itemCount: filteredUserHobbies.length,
                    itemBuilder: (context, index) {
                      final uh = filteredUserHobbies[index];
                      final hobby = allHobbies.firstWhere(
                        (h) => h.id == uh.hobbyId,
                        orElse: () => allHobbies.first,
                      );
                      return _HobbyListItem(
                        hobby: hobby,
                        userHobby: uh,
                        showProgress: _tabIndex > 0 && _tabIndex < 3,
                        onTap: () => context.push('/hobby/${hobby.id}'),
                        delay: index * 60,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Opacity(
            opacity: 0.4,
            child: Icon(Icons.explore_outlined, size: 44, color: AppColors.warmGray),
          ),
          const SizedBox(height: 14),
          Text(
            'Nothing here yet',
            style: AppTypography.sansBody.copyWith(color: AppColors.warmGray),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => context.go('/feed'),
            child: Text(
              'Start discovering →',
              style: AppTypography.sansCaption.copyWith(
                color: AppColors.coral,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  STAT CHIP
// ═══════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════
//  HOBBY LIST ITEM
// ═══════════════════════════════════════════════════════

class _HobbyListItem extends StatefulWidget {
  final Hobby hobby;
  final UserHobby userHobby;
  final bool showProgress;
  final VoidCallback onTap;
  final int delay;

  const _HobbyListItem({
    required this.hobby,
    required this.userHobby,
    required this.showProgress,
    required this.onTap,
    this.delay = 0,
  });

  @override
  State<_HobbyListItem> createState() => _HobbyListItemState();
}

class _HobbyListItemState extends State<_HobbyListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _entryController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      duration: Motion.normal,
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryController,
      curve: Motion.normalCurve,
    ));

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _entryController.forward();
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.userHobby.progressPercent(widget.hobby.roadmapSteps.length);
    final catColor = widget.hobby.catColor;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            height: 180,
            margin: const EdgeInsets.only(bottom: 14),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Full background image
                  Image.network(
                    widget.hobby.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: catColor.withValues(alpha: 0.2),
                      child: Center(
                        child: Icon(widget.hobby.catIcon, size: 36, color: catColor),
                      ),
                    ),
                  ),

              // Dark overlay gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.05),
                      Colors.black.withValues(alpha: 0.30),
                      Colors.black.withValues(alpha: 0.72),
                    ],
                    stops: const [0.0, 0.40, 1.0],
                  ),
                ),
              ),

              // Category badge — top left
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: catColor.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(widget.hobby.catIcon, size: 12, color: Colors.white),
                      const SizedBox(width: 5),
                      Text(
                        widget.hobby.category,
                        style: AppTypography.sansTiny.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Streak badge — top right (if trying/active)
              if (widget.showProgress && widget.userHobby.streakDays > 0)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(AppIcons.fire, size: 12, color: AppColors.amberLight),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.userHobby.streakDays}d streak',
                          style: AppTypography.monoTiny.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Content — bottom
              Positioned(
                left: 14,
                right: 14,
                bottom: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Text(
                      widget.hobby.title,
                      style: AppTypography.sansBody.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 10,
                            color: Colors.black.withValues(alpha: 0.5),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 3),

                    // Hook
                    Text(
                      widget.hobby.hook,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.sansCaption.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                        shadows: [
                          Shadow(
                            blurRadius: 6,
                            color: Colors.black.withValues(alpha: 0.4),
                          ),
                        ],
                      ),
                    ),
                    // Last activity timestamp
                    if (widget.userHobby.lastActivityAt != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Last active ${_timeAgo(widget.userHobby.lastActivityAt!)}',
                        style: AppTypography.sansTiny.copyWith(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 10,
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),

                    // Progress bar (if trying/active)
                    if (widget.showProgress) ...[
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(Spacing.radiusBadge),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 4,
                                backgroundColor: Colors.white.withValues(alpha: 0.15),
                                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.coral),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${(progress * 100).round()}%',
                            style: AppTypography.monoTiny.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],

                    // Info pills (saved/done)
                    if (!widget.showProgress) ...[
                      Row(
                        children: [
                          _InfoPill(
                            icon: AppIcons.badgeCost,
                            text: widget.hobby.costText,
                          ),
                          const SizedBox(width: 8),
                          _InfoPill(
                            icon: AppIcons.badgeTime,
                            text: widget.hobby.timeText,
                          ),
                          const SizedBox(width: 8),
                          _InfoPill(
                            icon: AppIcons.badgeDifficulty,
                            text: widget.hobby.difficultyText,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  INFO PILL (glassmorphic on image overlay)
// ═══════════════════════════════════════════════════════

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoPill({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white.withValues(alpha: 0.9)),
          const SizedBox(width: 5),
          Text(
            text,
            style: AppTypography.monoTiny.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
