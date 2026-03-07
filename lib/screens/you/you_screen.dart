import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// You tab — profile, library, journal, settings.
/// Placeholder for B.5 implementation.
class YouScreen extends ConsumerWidget {
  const YouScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.person_rounded, size: 64, color: AppColors.coral),
                const SizedBox(height: 16),
                Text(
                  'You',
                  style: AppTypography.serifHeading.copyWith(
                    color: AppColors.nearBlack,
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your hobbies, journal, profile & settings.\nComing in B.5.',
                  textAlign: TextAlign.center,
                  style: AppTypography.sansBody.copyWith(
                    color: AppColors.driftwood,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
