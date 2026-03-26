import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../components/page_dots.dart';
import '../../providers/subscription_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import 'package:go_router/go_router.dart';
import 'you_hobby_cards.dart';

/// Active tab content -- shows active hobby cards with PageView and stats.
class ActiveTabContent extends ConsumerWidget {
  final List<HobbyWithMeta> entries;
  final HobbyWithMeta? visibleMeta;
  final PageController hobbyPageController;
  final int currentPage;
  final ValueChanged<int> onPageChanged;

  const ActiveTabContent({
    super.key,
    required this.entries,
    required this.visibleMeta,
    required this.hobbyPageController,
    required this.currentPage,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (entries.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: _EmptyActivePrompt(),
      );
    }

    final isPro = ref.watch(isProProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (entries.length == 1)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: CollectorCard(meta: entries.first),
          )
        else ...[
          SizedBox(
            height: 130,
            child: PageView.builder(
              controller: hobbyPageController,
              // Free users: show active card + 1 locked card only
              itemCount: isPro ? entries.length : entries.length.clamp(0, 2),
              onPageChanged: onPageChanged,
              itemBuilder: (context, i) {
                final card = Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: CollectorCard(meta: entries[i]),
                );
                if (isPro || i == 0) return card;
                return LockedCardOverlay(
                  lockedCount: entries.length - 1,
                  child: card,
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          PageDots(
            count: entries.length,
            current: currentPage,
          ),
        ],
        const SizedBox(height: 10),
        if (visibleMeta != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: StatsChipRow(meta: visibleMeta!),
          ),
      ],
    );
  }
}

// ── Empty active prompt ──
class _EmptyActivePrompt extends StatelessWidget {
  const _EmptyActivePrompt();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('No active hobbies',
                style: TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () => context.go('/discover'),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [AppColors.coral, Color(0xFFFF5252)],
                  ),
                ),
                child: Text('Discover hobbies',
                    style: AppTypography.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
