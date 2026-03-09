import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/hobby_provider.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/spacing.dart';

/// Quickstart bottom sheet: BEGINNER badge, roadmap preview, Start Now CTA.
class QuickstartScreen extends ConsumerWidget {
  final String hobbyId;

  const QuickstartScreen({super.key, required this.hobbyId});

  static const _stepIcons = [
    Icons.shopping_bag_outlined,
    Icons.center_focus_strong_rounded,
    Icons.trending_up_rounded,
  ];

  static const _stepColors = [
    AppColors.amber,
    AppColors.coral,
    AppColors.sage,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hobby = ref.watch(hobbyByIdProvider(hobbyId)).valueOrNull;
    if (hobby == null) return const SizedBox.shrink();

    final steps = hobby.roadmapSteps.take(3).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle + close button
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.textWhisper,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Positioned(
                    right: 16,
                    child: GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.glassBackground,
                        ),
                        child: const Icon(Icons.close_rounded,
                            size: 18, color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hobby title
                    Text(
                      hobby.title,
                      style: AppTypography.display,
                    ),
                    const SizedBox(height: 16),

                    // Info card with BEGINNER badge + description + image
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(Spacing.radiusTile),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.sage.withValues(alpha: 0.15),
                                    borderRadius:
                                        BorderRadius.circular(Spacing.radiusBadge),
                                  ),
                                  child: Text(
                                    'BEGINNER',
                                    style: AppTypography.monoBadgeSmall.copyWith(
                                      color: AppColors.sage,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  hobby.whyLove.length > 80
                                      ? '${hobby.whyLove.substring(0, 80)}...'
                                      : hobby.whyLove,
                                  style: AppTypography.sansBodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              hobby.imageUrl,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 80,
                                height: 80,
                                color: AppColors.surfaceElevated,
                                child: const Icon(Icons.image_outlined,
                                    color: AppColors.textMuted),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Roadmap section title
                    Text(
                      hobby.title,
                      style: AppTypography.title.copyWith(fontSize: 17),
                    ),
                    const SizedBox(height: 14),

                    // Roadmap preview steps
                    ...List.generate(steps.length, (i) {
                      final step = steps[i];
                      final icon = i < _stepIcons.length
                          ? _stepIcons[i]
                          : Icons.circle_outlined;
                      final color = i < _stepColors.length
                          ? _stepColors[i]
                          : AppColors.driftwood;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Step icon
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Icon(icon, size: 20, color: color),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    step.title,
                                    style: AppTypography.body.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    step.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            // Bottom CTA area
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: Spacing.buttonCtaHeight,
                    child: ElevatedButton(
                      onPressed: () {
                        ref
                            .read(userHobbiesProvider.notifier)
                            .startTrying(hobbyId);
                        context.pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.coral,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(Spacing.radiusCta),
                        ),
                      ),
                      child: Text('Start Now  \u2192',
                          style: AppTypography.sansCta),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Free for the first 3 lessons',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
