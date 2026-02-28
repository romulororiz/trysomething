import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/feature_providers.dart';
import '../../providers/hobby_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_icons.dart';
import '../../theme/app_typography.dart';

/// Nearby hobbyists — map placeholder + list of nearby users.
class LocalDiscoveryScreen extends ConsumerWidget {
  const LocalDiscoveryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nearbyUsers = ref.watch(nearbyUsersProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.sand,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Icon(AppIcons.arrowBack,
                              size: 18, color: AppColors.nearBlack),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Icon(AppIcons.local, size: 20, color: AppColors.indigo),
                    const SizedBox(width: 8),
                    Text('Nearby Hobbyists',
                        style: AppTypography.serifHeading),
                  ],
                ),
              ),
            ),

            // Map placeholder
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: AppColors.indigoPale,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.indigo.withAlpha(30)),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(AppIcons.local,
                            size: 36, color: AppColors.indigo.withAlpha(120)),
                        const SizedBox(height: 10),
                        Text(
                          'Map view coming soon',
                          style: AppTypography.sansLabel
                              .copyWith(color: AppColors.indigo),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Find hobby partners near you',
                          style: AppTypography.sansCaption
                              .copyWith(color: AppColors.warmGray),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Section title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 14),
                child: Row(
                  children: [
                    Text('People Nearby', style: AppTypography.sansSection),
                    const Spacer(),
                    Text(
                      '${nearbyUsers.length} found',
                      style: AppTypography.monoCaption
                          .copyWith(color: AppColors.warmGray),
                    ),
                  ],
                ),
              ),
            ),

            // Nearby user cards
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final user = nearbyUsers[index];
                    final hobby = ref.watch(hobbyByIdProvider(user.hobbyId));

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.warmWhite,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          // Avatar
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [AppColors.indigo, AppColors.indigoDeep],
                              ),
                              border: Border.all(
                                  color: AppColors.indigo.withAlpha(40)),
                            ),
                            child: Center(
                              child: Text(
                                user.avatarInitial,
                                style: AppTypography.sansSection
                                    .copyWith(color: AppColors.indigo),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          // Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(user.name,
                                    style: AppTypography.sansLabel
                                        .copyWith(fontWeight: FontWeight.w700)),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    if (hobby != null) ...[
                                      Icon(hobby.catIcon,
                                          size: 11, color: hobby.catColor),
                                      const SizedBox(width: 4),
                                      Text(
                                        hobby.title,
                                        style: AppTypography.sansCaption
                                            .copyWith(color: AppColors.driftwood),
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                    Text(
                                      user.startedText,
                                      style: AppTypography.sansTiny
                                          .copyWith(color: AppColors.warmGray),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Distance + connect
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.indigoPale,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Text(
                                  user.distance,
                                  style: AppTypography.monoBadgeSmall
                                      .copyWith(color: AppColors.indigo),
                                ),
                              ),
                              const SizedBox(height: 6),
                              GestureDetector(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Connect with ${user.name} coming soon!',
                                          style: AppTypography.sansLabel
                                              .copyWith(color: Colors.white)),
                                      backgroundColor: AppColors.coral,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Connect',
                                  style: AppTypography.sansCaption.copyWith(
                                    color: AppColors.coral,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                  childCount: nearbyUsers.length,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }
}
