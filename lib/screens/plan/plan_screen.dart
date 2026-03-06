import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/features.dart';
import '../../providers/feature_providers.dart';
import '../../providers/hobby_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_icons.dart';
import '../../theme/app_typography.dart';
import '../../theme/spacing.dart';

/// Weekly Planner tab — calendar week strip with session cards.
class PlanScreen extends ConsumerWidget {
  const PlanScreen({super.key});

  static const List<String> _dayLabels = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
  ];

  static const int _startHour = 7;
  static const int _endHour = 22;
  static const double _hourHeight = 52.0;
  static const double _timeGutterWidth = 44.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(scheduleProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 8),
            _buildDayHeaders(),
            const SizedBox(height: 8),
            Expanded(
              child: _buildScrollableGrid(ref, events),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: Spacing.scrollBottomPadding),
        child: FloatingActionButton.extended(
          onPressed: () => _showAddSessionSheet(context, ref),
          backgroundColor: AppColors.coral,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Spacing.radiusButton),
          ),
          icon: Icon(AppIcons.calendar, size: 20),
          label: Text('Add session', style: AppTypography.sansCta),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: Row(
        children: [
          Text('Weekly Plan', style: AppTypography.serifHeading),
        ],
      ),
    );
  }

  Widget _buildDayHeaders() {
    final today = DateTime.now().weekday;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          const SizedBox(width: _timeGutterWidth),
          ...List.generate(7, (i) {
            final dayNum = i + 1;
            final isToday = dayNum == today;

            return Expanded(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isToday ? AppColors.coral : Colors.transparent,
                    borderRadius: BorderRadius.circular(Spacing.radiusBadge),
                  ),
                  child: Text(
                    _dayLabels[i],
                    style: AppTypography.sansLabel.copyWith(
                      color: isToday ? Colors.white : AppColors.driftwood,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildScrollableGrid(WidgetRef ref, List<ScheduleEvent> events) {
    const totalHours = _endHour - _startHour;
    const topPad = 10.0; // space so 07:00 label isn't clipped
    const gridHeight = totalHours * _hourHeight;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: Spacing.scrollBottomPadding),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: SizedBox(
          height: gridHeight + topPad,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Time gutter
              SizedBox(
                width: _timeGutterWidth,
                height: gridHeight + topPad,
                child: Stack(
                  children: List.generate(totalHours + 1, (i) {
                    final hour = _startHour + i;
                    if (hour > _endHour) return const SizedBox.shrink();
                    return Positioned(
                      top: topPad + i * _hourHeight - 7,
                      left: 0,
                      right: 4,
                      child: Text(
                        '${hour.toString().padLeft(2, '0')}:00',
                        style: AppTypography.sansTiny.copyWith(
                          fontSize: 10,
                          color: AppColors.driftwood,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    );
                  }),
                ),
              ),
              // Day columns
              ...List.generate(7, (dayIndex) {
                final dayNum = dayIndex + 1;
                final dayEvents =
                    events.where((e) => e.dayOfWeek == dayNum).toList();
                final isToday = dayNum == DateTime.now().weekday;

                return Expanded(
                  child: Container(
                    height: gridHeight,
                    margin: EdgeInsets.only(top: topPad, left: 1, right: 1),
                    decoration: BoxDecoration(
                      color: isToday
                          ? AppColors.warmWhite.withValues(alpha: 0.9)
                          : AppColors.warmWhite.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(6),
                      border: isToday
                          ? Border.all(
                              color: AppColors.coral.withValues(alpha: 0.2),
                              width: 1,
                            )
                          : null,
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Hour divider lines
                        ...List.generate(totalHours - 1, (i) {
                          return Positioned(
                            top: (i + 1) * _hourHeight,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 0.5,
                              color: AppColors.sandDark.withValues(alpha: 0.2),
                            ),
                          );
                        }),
                        // Current time indicator for today
                        if (isToday) _buildNowIndicator(),
                        // Events
                        ...dayEvents.map((event) {
                          return _PlanEventBlock(
                            event: event,
                            startHour: _startHour,
                            hourHeight: _hourHeight,
                          );
                        }),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNowIndicator() {
    final now = DateTime.now();
    final fractionalHour = now.hour + now.minute / 60.0;
    final top = (fractionalHour - _startHour) * _hourHeight;
    if (top < 0 || top > (_endHour - _startHour) * _hourHeight) {
      return const SizedBox.shrink();
    }
    return Positioned(
      top: top,
      left: 0,
      right: 0,
      child: Container(
        height: 2,
        decoration: BoxDecoration(
          color: AppColors.coral,
          borderRadius: BorderRadius.circular(1),
          boxShadow: [
            BoxShadow(
              color: AppColors.coral.withValues(alpha: 0.4),
              blurRadius: 4,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddSessionSheet(BuildContext context, WidgetRef ref) {
    final hobbies = ref.read(hobbyListProvider).valueOrNull ?? [];
    String? selectedHobbyId = hobbies.isNotEmpty ? hobbies.first.id : null;
    int selectedDay = 1;
    int selectedHour = 18;
    int selectedMinute = 0;
    int durationMinutes = 60;

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Spacing.radiusCard),
        ),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                24, 20, 24,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.sandDark,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Add Session', style: AppTypography.serifSubheading),
                  const SizedBox(height: 20),

                  Text('Hobby', style: AppTypography.sansLabel),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: hobbies.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final hobby = hobbies[index];
                        final isSelected = hobby.id == selectedHobbyId;
                        return GestureDetector(
                          onTap: () => setSheetState(() => selectedHobbyId = hobby.id),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.coral : AppColors.sand,
                              borderRadius: BorderRadius.circular(Spacing.radiusBadge),
                            ),
                            child: Text(
                              hobby.title,
                              style: AppTypography.sansCaption.copyWith(
                                color: isSelected ? Colors.white : AppColors.nearBlack,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text('Day', style: AppTypography.sansLabel),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _dayLabels.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 6),
                      itemBuilder: (context, index) {
                        final isSelected = (index + 1) == selectedDay;
                        return GestureDetector(
                          onTap: () => setSheetState(() => selectedDay = index + 1),
                          child: Container(
                            width: 44,
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.indigo : AppColors.sand,
                              borderRadius: BorderRadius.circular(Spacing.radiusBadge),
                            ),
                            child: Center(
                              child: Text(
                                _dayLabels[index],
                                style: AppTypography.sansCaption.copyWith(
                                  color: isSelected ? Colors.white : AppColors.nearBlack,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Time', style: AppTypography.sansLabel),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () async {
                                final picked = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay(hour: selectedHour, minute: selectedMinute),
                                );
                                if (picked != null) {
                                  setSheetState(() {
                                    selectedHour = picked.hour;
                                    selectedMinute = picked.minute;
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: AppColors.warmWhite,
                                  borderRadius: BorderRadius.circular(Spacing.radiusInput),
                                ),
                                child: Row(
                                  children: [
                                    Icon(AppIcons.badgeTime, size: 16, color: AppColors.driftwood),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${selectedHour.toString().padLeft(2, '0')}:${selectedMinute.toString().padLeft(2, '0')}',
                                      style: AppTypography.monoMedium.copyWith(color: AppColors.nearBlack),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Duration', style: AppTypography.sansLabel),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              decoration: BoxDecoration(
                                color: AppColors.warmWhite,
                                borderRadius: BorderRadius.circular(Spacing.radiusInput),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  value: durationMinutes,
                                  isExpanded: true,
                                  icon: const Icon(Icons.arrow_drop_down, color: AppColors.driftwood),
                                  style: AppTypography.monoMedium.copyWith(color: AppColors.nearBlack),
                                  items: const [
                                    DropdownMenuItem(value: 30, child: Text('30 min')),
                                    DropdownMenuItem(value: 45, child: Text('45 min')),
                                    DropdownMenuItem(value: 60, child: Text('60 min')),
                                    DropdownMenuItem(value: 90, child: Text('90 min')),
                                    DropdownMenuItem(value: 120, child: Text('120 min')),
                                  ],
                                  onChanged: (val) {
                                    if (val != null) setSheetState(() => durationMinutes = val);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: Spacing.buttonPrimaryHeight,
                    child: ElevatedButton(
                      onPressed: () {
                        if (selectedHobbyId == null) return;
                        final timeStr =
                            '${selectedHour.toString().padLeft(2, '0')}:${selectedMinute.toString().padLeft(2, '0')}';
                        final event = ScheduleEvent(
                          id: 'ev_${DateTime.now().millisecondsSinceEpoch}',
                          hobbyId: selectedHobbyId!,
                          dayOfWeek: selectedDay,
                          startTime: timeStr,
                          durationMinutes: durationMinutes,
                        );
                        ref.read(scheduleProvider.notifier).addEvent(event);
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.coral,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Spacing.radiusButton),
                        ),
                      ),
                      child: Text('Add to schedule', style: AppTypography.sansCta),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _PlanEventBlock extends ConsumerWidget {
  final ScheduleEvent event;
  final int startHour;
  final double hourHeight;

  const _PlanEventBlock({
    required this.event,
    required this.startHour,
    required this.hourHeight,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hobby = ref.watch(hobbyByIdProvider(event.hobbyId)).valueOrNull;
    final hobbyName = hobby?.title ?? event.hobbyId;

    final parts = event.startTime.split(':');
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;

    final topOffset = ((hour - startHour) + minute / 60.0) * hourHeight;
    final blockHeight = (event.durationMinutes / 60.0) * hourHeight;

    const accent = AppColors.coral;
    const bg = AppColors.coralPale;

    return Positioned(
      top: topOffset.clamp(0, double.infinity),
      left: 2,
      right: 2,
      height: blockHeight.clamp(20, double.infinity),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(6),
          border: Border(
            left: BorderSide(color: accent, width: 3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              hobbyName,
              style: AppTypography.sansTiny.copyWith(
                color: accent,
                fontWeight: FontWeight.w700,
                fontSize: 9,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (blockHeight > 32)
              Text(
                event.startTime,
                style: AppTypography.sansTiny.copyWith(
                  color: accent.withValues(alpha: 0.7),
                  fontSize: 8,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
