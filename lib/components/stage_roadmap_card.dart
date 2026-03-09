import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'glass_card.dart';

/// 4-stage roadmap card for the Home tab.
///
/// Shows one stage at a time based on [currentWeek]:
/// - Week 1: Try it
/// - Week 2: Repeat it
/// - Week 3: Reduce friction
/// - Week 4+: Decide
///
/// Each stage shows what to do, what to ignore, and what success looks like.
/// Includes a "Stuck?" button that routes to the AI coach.
class StageRoadmapCard extends StatelessWidget {
  final int currentWeek;
  final String hobbyId;
  final int completedSteps;
  final int totalSteps;

  const StageRoadmapCard({
    super.key,
    required this.currentWeek,
    required this.hobbyId,
    this.completedSteps = 0,
    this.totalSteps = 0,
  });

  static const _stages = [
    _Stage(
      week: 1,
      title: 'Try it',
      whatToDo: 'Do one tiny session. Just 15-30 minutes. '
          'Use only the minimum kit.',
      whatToIgnore: 'Don\'t research gear. Don\'t watch '
          'advanced tutorials. Don\'t compare yourself to anyone.',
      success: 'You did the thing once. That\'s it. That\'s success.',
      icon: Icons.play_arrow_rounded,
    ),
    _Stage(
      week: 2,
      title: 'Repeat it',
      whatToDo: 'Do the same thing again. Same setup, '
          'slightly longer. Try to do it twice this week.',
      whatToIgnore: 'Don\'t upgrade your gear yet. Don\'t try '
          'advanced techniques. Keep it simple.',
      success: 'You did it more than once and it didn\'t feel forced.',
      icon: Icons.refresh_rounded,
    ),
    _Stage(
      week: 3,
      title: 'Reduce friction',
      whatToDo: 'What annoyed you? Fix it. Simplify your setup. '
          'Make it easier to start next time.',
      whatToIgnore: 'Don\'t set ambitious goals. Don\'t add '
          'complexity. Focus on removing barriers.',
      success: 'Starting a session feels easier than last week.',
      icon: Icons.auto_fix_high_rounded,
    ),
    _Stage(
      week: 4,
      title: 'Decide',
      whatToDo: 'Reflect: do you want to keep going? '
          'Level up? Switch to something different?',
      whatToIgnore: 'Don\'t feel guilty either way. '
          'Trying and moving on is valid progress.',
      success: 'You made a clear decision about this hobby.',
      icon: Icons.flag_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final stageIndex = (currentWeek - 1).clamp(0, _stages.length - 1);
    final stage = _stages[stageIndex];
    final progress = totalSteps > 0 ? completedSteps / totalSteps : 0.0;

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.coral.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(stage.icon, size: 16, color: AppColors.coral),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WEEK ${stage.week} OF 4',
                      style: AppTypography.overline
                          .copyWith(color: AppColors.textMuted),
                    ),
                    Text(stage.title,
                        style: AppTypography.sansLabel.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        )),
                  ],
                ),
              ),
              // Stage dots
              Row(
                children: List.generate(4, (i) {
                  final done = i < stageIndex;
                  final current = i == stageIndex;
                  return Container(
                    width: current ? 16 : 6,
                    height: 6,
                    margin: const EdgeInsets.only(left: 4),
                    decoration: BoxDecoration(
                      color: done || current
                          ? AppColors.coral
                          : AppColors.border,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Progress bar
          if (totalSteps > 0) ...[
            Row(
              children: [
                Text('$completedSteps/$totalSteps steps',
                    style: AppTypography.data
                        .copyWith(color: AppColors.textMuted)),
                const SizedBox(width: 12),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      minHeight: 3,
                      backgroundColor: AppColors.textWhisper,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.coral),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // What to do
          _StageSection(
            label: 'What to do',
            text: stage.whatToDo,
            icon: Icons.check_circle_outline_rounded,
            color: AppColors.sage,
          ),
          const SizedBox(height: 12),

          // What to ignore
          _StageSection(
            label: 'What to ignore',
            text: stage.whatToIgnore,
            icon: Icons.do_not_disturb_outlined,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 12),

          // Success looks like
          _StageSection(
            label: 'Success looks like',
            text: stage.success,
            icon: Icons.emoji_events_outlined,
            color: AppColors.coral,
          ),

          const SizedBox(height: 16),

          // Stuck? button
          GestureDetector(
            onTap: () => context.push('/coach/$hobbyId'),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.auto_awesome,
                      size: 14, color: AppColors.coral),
                  const SizedBox(width: 8),
                  Text('Stuck? Ask the coach',
                      style: AppTypography.sansTiny
                          .copyWith(color: AppColors.coral)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stage {
  final int week;
  final String title;
  final String whatToDo;
  final String whatToIgnore;
  final String success;
  final IconData icon;

  const _Stage({
    required this.week,
    required this.title,
    required this.whatToDo,
    required this.whatToIgnore,
    required this.success,
    required this.icon,
  });
}

class _StageSection extends StatelessWidget {
  final String label;
  final String text;
  final IconData icon;
  final Color color;

  const _StageSection({
    required this.label,
    required this.text,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: AppTypography.sansTiny
                      .copyWith(color: AppColors.textMuted)),
              const SizedBox(height: 2),
              Text(text,
                  style: AppTypography.sansBodySmall
                      .copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }
}
