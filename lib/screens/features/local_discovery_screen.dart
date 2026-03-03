import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/feature_providers.dart';
import '../../providers/hobby_provider.dart';
import '../../theme/category_ui.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_icons.dart';
import '../../theme/app_typography.dart';

/// Similar Hobbyists — find people who share your hobbies.
class LocalDiscoveryScreen extends ConsumerStatefulWidget {
  const LocalDiscoveryScreen({super.key});

  @override
  ConsumerState<LocalDiscoveryScreen> createState() =>
      _LocalDiscoveryScreenState();
}

class _LocalDiscoveryScreenState extends ConsumerState<LocalDiscoveryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(similarUsersProvider.notifier).loadFromServer(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final users = ref.watch(similarUsersProvider);
    final buddyState = ref.watch(buddyProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.sand,
                        ),
                        child: const Icon(Icons.arrow_back,
                            size: 20, color: AppColors.espresso),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text('Similar Hobbyists',
                        style: AppTypography.serifHeading),
                  ],
                ),
              ),
            ),

            // Intro card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Container(
                  height: 100,
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
                            size: 28, color: AppColors.indigo.withAlpha(120)),
                        const SizedBox(height: 8),
                        Text(
                          'People who share your hobbies',
                          style: AppTypography.sansLabel
                              .copyWith(color: AppColors.indigo),
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
                      '${users.length} found',
                      style: AppTypography.monoCaption
                          .copyWith(color: AppColors.warmGray),
                    ),
                  ],
                ),
              ),
            ),

            // Empty state
            if (users.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(48),
                  child: Center(
                    child: Text(
                      'No similar hobbyists found yet.\nStart trying hobbies to discover others!',
                      textAlign: TextAlign.center,
                      style: AppTypography.sansBodySmall
                          .copyWith(color: AppColors.warmGray),
                    ),
                  ),
                ),
              ),

            // User cards
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final user = users[index];
                    final hobby = ref
                        .watch(hobbyByIdProvider(user.hobbyId))
                        .valueOrNull;
                    final alreadyRequested = buddyState.pendingRequests
                        .any((r) => r.userId == user.id);

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
                                colors: [
                                  AppColors.indigo,
                                  AppColors.indigoDeep
                                ],
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
                                    style: AppTypography.sansLabel.copyWith(
                                        fontWeight: FontWeight.w700)),
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
                                            .copyWith(
                                                color: AppColors.driftwood),
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
                          // Connect / Requested
                          if (alreadyRequested)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.sand,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                'Requested',
                                style: AppTypography.sansCaption
                                    .copyWith(color: AppColors.warmGray),
                              ),
                            )
                          else
                            GestureDetector(
                              onTap: () async {
                                await ref
                                    .read(buddyProvider.notifier)
                                    .sendRequest(user.id,
                                        hobbyId: user.hobbyId);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Buddy request sent to ${user.name}!',
                                          style: AppTypography.sansLabel
                                              .copyWith(color: Colors.white)),
                                      backgroundColor: AppColors.sage,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                    ),
                                  );
                                }
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
                    );
                  },
                  childCount: users.length,
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
