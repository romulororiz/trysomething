import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../components/logo_loader.dart';
import '../../models/hobby.dart';
import '../../providers/hobby_provider.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

// ===============================================
//  PAUSED HOBBY PAGE
// ===============================================

class PausedHobbyPage extends ConsumerWidget {
  final UserHobby userHobby;
  final VoidCallback? onResume;
  const PausedHobbyPage({super.key, required this.userHobby, this.onResume});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hobbyAsync = ref.watch(hobbyByIdProvider(userHobby.hobbyId));
    return hobbyAsync.when(
      data: (hobby) {
        if (hobby == null) return const SizedBox.shrink();
        final daysPaused = userHobby.pausedAt != null
            ? DateTime.now().difference(userHobby.pausedAt!).inDays
            : 0;
        // Full-screen blurred hobby image with centered pause overlay
        return Stack(
          fit: StackFit.expand,
          children: [
            // Blurred hobby image fills entire screen
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
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

            // Dark overlay
            Container(color: AppColors.background.withValues(alpha: 0.75)),

            // Centered pause info + Resume CTA
            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // "PAUSED" chip (top)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AppColors.glassBorder, width: 0.5),
                        ),
                        child: Text('PAUSED',
                            style: AppTypography.overline
                                .copyWith(color: AppColors.textMuted, letterSpacing: 2)),
                      ),
                      const SizedBox(height: 20),

                      // Hobby title
                      Text(
                        hobby.title,
                        style: AppTypography.display,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),

                      // Days counter
                      Text(
                        daysPaused == 0
                            ? 'Paused today'
                            : 'Paused for $daysPaused ${daysPaused == 1 ? "day" : "days"}',
                        style: AppTypography.body
                            .copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 8),

                      // Progress note
                      Text(
                        'Your progress is saved.',
                        style: AppTypography.sansTiny
                            .copyWith(color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 32),

                      // Coral "Resume" CTA
                      GestureDetector(
                        onTap: () {
                          ref
                              .read(userHobbiesProvider.notifier)
                              .resumeHobby(hobby.id);
                          onResume?.call();
                        },
                        child: Container(
                          width: double.infinity,
                          height: 52,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            gradient: const LinearGradient(
                              colors: [AppColors.coral, Color(0xFFFF5252)],
                            ),
                          ),
                          child: Center(
                            child: Text('Resume',
                                style: AppTypography.button
                                    .copyWith(color: Colors.white)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // View detail link
                      GestureDetector(
                        onTap: () => context.push('/hobby/${hobby.id}'),
                        child: Text(
                          'View hobby details',
                          style: AppTypography.sansTiny.copyWith(
                            color: AppColors.textSecondary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: LogoLoader()),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
