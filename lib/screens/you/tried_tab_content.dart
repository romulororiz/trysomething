import 'package:flutter/material.dart';
import '../../components/page_dots.dart';
import '../../theme/app_colors.dart';
import 'you_hobby_cards.dart';

/// Tried tab content -- shows completed/stopped hobby cards with PageView.
class TriedTabContent extends StatelessWidget {
  final List<HobbyWithMeta> entries;
  final int triedPage;
  final PageController triedPageController;
  final ValueChanged<int> onPageChanged;

  const TriedTabContent({
    super.key,
    required this.entries,
    required this.triedPage,
    required this.triedPageController,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        child: Center(
          child: Text('Nothing tried yet',
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
            child: TriedHobbyCard(meta: entries.first),
          )
        else ...[
          SizedBox(
            height: 130,
            child: PageView.builder(
              controller: triedPageController,
              itemCount: entries.length,
              onPageChanged: onPageChanged,
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: TriedHobbyCard(meta: entries[i]),
              ),
            ),
          ),
          const SizedBox(height: 8),
          PageDots(
            count: entries.length,
            current: triedPage,
          ),
        ],
      ],
    );
  }
}
