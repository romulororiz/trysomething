import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../components/page_dots.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import 'you_hobby_cards.dart';

/// Saved tab content -- shows saved hobby swipe cards with PageView.
class SavedTabContent extends StatelessWidget {
  final List<HobbyWithMeta> entries;
  final int savedPage;
  final PageController savedPageController;
  final ValueChanged<int> onPageChanged;

  const SavedTabContent({
    super.key,
    required this.entries,
    required this.savedPage,
    required this.savedPageController,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('No saved hobbies yet',
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
                  child: Text('Browse hobbies',
                      style: AppTypography.caption
                          .copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 130,
          child: PageView.builder(
            controller: savedPageController,
            itemCount: entries.length,
            onPageChanged: onPageChanged,
            itemBuilder: (context, i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: SavedHobbySwipeCard(meta: entries[i]),
            ),
          ),
        ),
        const SizedBox(height: 8),
        PageDots(
          count: entries.length,
          current: savedPage,
        ),
      ],
    );
  }
}
