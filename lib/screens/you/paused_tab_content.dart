import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../components/page_dots.dart';
import '../../theme/app_colors.dart';
import 'you_hobby_cards.dart';

/// Paused tab content -- shows paused hobby cards with PageView.
class PausedTabContent extends ConsumerWidget {
  final List<HobbyWithMeta> entries;
  final int pausedPage;
  final PageController pausedPageController;
  final ValueChanged<int> onPageChanged;

  const PausedTabContent({
    super.key,
    required this.entries,
    required this.pausedPage,
    required this.pausedPageController,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (entries.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        child: Center(
          child: Text('No paused hobbies',
              style: TextStyle(color: AppColors.textMuted)),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (entries.length == 1)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: PausedHobbyCard(meta: entries.first),
          )
        else ...[
          SizedBox(
            height: 130,
            child: PageView.builder(
              controller: pausedPageController,
              itemCount: entries.length,
              onPageChanged: onPageChanged,
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: PausedHobbyCard(meta: entries[i]),
              ),
            ),
          ),
          const SizedBox(height: 8),
          PageDots(
            count: entries.length,
            current: pausedPage,
          ),
        ],
      ],
    );
  }
}
