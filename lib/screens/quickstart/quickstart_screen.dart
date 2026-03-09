import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/hobby_provider.dart';
import '../../providers/user_provider.dart';
import '../../components/glass_card.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/spacing.dart';
import '../../theme/motion.dart';

/// Commitment flow bottom sheet: Save vs Start → mini setup → Week 1 plan.
class QuickstartScreen extends ConsumerStatefulWidget {
  final String hobbyId;

  const QuickstartScreen({super.key, required this.hobbyId});

  @override
  ConsumerState<QuickstartScreen> createState() => _QuickstartScreenState();
}

class _QuickstartScreenState extends ConsumerState<QuickstartScreen> {
  /// 0 = choose (save/start), 1 = budget, 2 = session length,
  /// 3 = preferred day, 4 = first action summary
  int _step = 0;

  // Setup choices
  int _budgetChoice = 0; // 0 = minimum, 1 = best value
  int _sessionLength = 1; // 0=15min, 1=30min, 2=1hr
  int _preferredDay = 0; // 0-6 = Mon-Sun
  String _preferredTime = 'Evening';

  static const _sessionLabels = ['15 min', '30 min', '1 hour'];
  static const _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _timeLabels = ['Morning', 'Afternoon', 'Evening', 'Night'];

  void _saveForLater() {
    ref.read(userHobbiesProvider.notifier).saveHobby(widget.hobbyId);
    context.pop();
  }

  void _startNow() {
    setState(() => _step = 1);
  }

  void _nextStep() {
    if (_step < 4) {
      setState(() => _step++);
    }
  }

  void _prevStep() {
    if (_step > 0) {
      setState(() => _step--);
    }
  }

  void _finishSetup() {
    ref.read(userHobbiesProvider.notifier).startTrying(widget.hobbyId);
    context.pop();
    // Navigate to home tab with active hobby
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final hobby =
        ref.watch(hobbyByIdProvider(widget.hobbyId)).valueOrNull;
    if (hobby == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle + close
            _buildHandle(),

            // Progress dots (only in setup flow, steps 1-4)
            if (_step > 0) _buildProgressDots(),

            // Content
            Expanded(
              child: AnimatedSwitcher(
                duration: Motion.normal,
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: _buildStepContent(hobby),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Padding(
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
    );
  }

  Widget _buildProgressDots() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(4, (i) {
          final isActive = i < _step;
          final isCurrent = i == _step - 1;
          return Container(
            width: isCurrent ? 20 : 6,
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: isActive || isCurrent
                  ? AppColors.coral
                  : AppColors.border,
              borderRadius: BorderRadius.circular(3),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepContent(dynamic hobby) {
    switch (_step) {
      case 0:
        return _buildChooseStep(hobby);
      case 1:
        return _buildBudgetStep(hobby);
      case 2:
        return _buildSessionStep();
      case 3:
        return _buildScheduleStep();
      case 4:
        return _buildSummaryStep(hobby);
      default:
        return const SizedBox.shrink();
    }
  }

  // ═══════════════════════════════════════════════════════
  //  STEP 0: SAVE vs START
  // ═══════════════════════════════════════════════════════

  Widget _buildChooseStep(dynamic hobby) {
    return Padding(
      key: const ValueKey('choose'),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          // Hobby image + title
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  hobby.imageUrl,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 64,
                    height: 64,
                    color: AppColors.surfaceElevated,
                    child: const Icon(Icons.image_outlined,
                        color: AppColors.textMuted),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(hobby.title, style: AppTypography.display),
                    const SizedBox(height: 4),
                    Text(
                      hobby.difficultyText,
                      style: AppTypography.sansTiny
                          .copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          Text('Ready to try this?',
              style: AppTypography.title.copyWith(fontSize: 17)),
          const SizedBox(height: 8),
          Text(
            'You don\'t need the perfect moment. Just a good enough start.',
            style: AppTypography.sansBodySmall
                .copyWith(color: AppColors.textSecondary),
          ),
          const Spacer(),

          // Start Now CTA
          _CoralButton(
            label: 'Start now \u2192',
            onTap: _startNow,
          ),
          const SizedBox(height: 12),

          // Save for later
          Center(
            child: GestureDetector(
              onTap: _saveForLater,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text('Save for later',
                    style: AppTypography.sansCaption
                        .copyWith(color: AppColors.textSecondary)),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  //  STEP 1: BUDGET VERSION
  // ═══════════════════════════════════════════════════════

  Widget _buildBudgetStep(dynamic hobby) {
    final essentialCost = hobby.starterKit
        .where((k) => !k.isOptional)
        .fold(0, (int sum, k) => sum + (k.cost as int));
    final fullCost =
        hobby.starterKit.fold(0, (int sum, k) => sum + (k.cost as int));

    return Padding(
      key: const ValueKey('budget'),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text('Choose your budget',
              style: AppTypography.title.copyWith(fontSize: 17)),
          const SizedBox(height: 6),
          Text('You can always upgrade later.',
              style: AppTypography.sansTiny
                  .copyWith(color: AppColors.textMuted)),
          const SizedBox(height: 20),

          _OptionCard(
            title: 'Minimum',
            subtitle: 'Only the essentials to get started',
            trailing: essentialCost > 0 ? '~ CHF $essentialCost' : 'FREE',
            selected: _budgetChoice == 0,
            onTap: () => setState(() => _budgetChoice = 0),
          ),
          const SizedBox(height: 10),
          _OptionCard(
            title: 'Best value',
            subtitle: 'Better gear that lasts longer',
            trailing: fullCost > 0 ? '~ CHF $fullCost' : 'FREE',
            selected: _budgetChoice == 1,
            onTap: () => setState(() => _budgetChoice = 1),
          ),

          const Spacer(),
          _buildNavButtons(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  //  STEP 2: SESSION LENGTH
  // ═══════════════════════════════════════════════════════

  Widget _buildSessionStep() {
    return Padding(
      key: const ValueKey('session'),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text('First session length',
              style: AppTypography.title.copyWith(fontSize: 17)),
          const SizedBox(height: 6),
          Text('Shorter is better. You can always do more.',
              style: AppTypography.sansTiny
                  .copyWith(color: AppColors.textMuted)),
          const SizedBox(height: 20),

          ...List.generate(_sessionLabels.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _OptionCard(
                title: _sessionLabels[i],
                subtitle: i == 0
                    ? 'Quick taste — zero pressure'
                    : i == 1
                        ? 'Recommended for most people'
                        : 'For when you\'re feeling motivated',
                selected: _sessionLength == i,
                onTap: () => setState(() => _sessionLength = i),
              ),
            );
          }),

          const Spacer(),
          _buildNavButtons(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  //  STEP 3: PREFERRED DAY/TIME
  // ═══════════════════════════════════════════════════════

  Widget _buildScheduleStep() {
    return Padding(
      key: const ValueKey('schedule'),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text('When works best?',
              style: AppTypography.title.copyWith(fontSize: 17)),
          const SizedBox(height: 6),
          Text('Pick a day and time for your first session.',
              style: AppTypography.sansTiny
                  .copyWith(color: AppColors.textMuted)),
          const SizedBox(height: 20),

          // Day picker
          Text('Day',
              style: AppTypography.sansLabel
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 10),
          Row(
            children: List.generate(_dayLabels.length, (i) {
              final selected = _preferredDay == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _preferredDay = i),
                  child: AnimatedContainer(
                    duration: Motion.fast,
                    margin: EdgeInsets.only(
                        right: i < _dayLabels.length - 1 ? 6 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.coral.withValues(alpha: 0.12)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color:
                            selected ? AppColors.coral : AppColors.border,
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _dayLabels[i],
                        style: AppTypography.sansTiny.copyWith(
                          color: selected
                              ? AppColors.coral
                              : AppColors.textSecondary,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 20),

          // Time picker
          Text('Time',
              style: AppTypography.sansLabel
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _timeLabels.map((t) {
              final selected = _preferredTime == t;
              return GestureDetector(
                onTap: () => setState(() => _preferredTime = t),
                child: AnimatedContainer(
                  duration: Motion.fast,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.coral.withValues(alpha: 0.12)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color:
                          selected ? AppColors.coral : AppColors.border,
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Text(
                    t,
                    style: AppTypography.sansBodySmall.copyWith(
                      color: selected
                          ? AppColors.coral
                          : AppColors.textSecondary,
                      fontWeight:
                          selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const Spacer(),
          _buildNavButtons(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  //  STEP 4: SUMMARY
  // ═══════════════════════════════════════════════════════

  Widget _buildSummaryStep(dynamic hobby) {
    final firstStep = hobby.roadmapSteps.isNotEmpty
        ? hobby.roadmapSteps.first
        : null;

    return Padding(
      key: const ValueKey('summary'),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text('Your Week 1 plan',
              style: AppTypography.title.copyWith(fontSize: 17)),
          const SizedBox(height: 6),
          Text('Small progress counts. Here\'s your starting point.',
              style: AppTypography.sansTiny
                  .copyWith(color: AppColors.textMuted)),
          const SizedBox(height: 20),

          GlassCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // When
                _SummaryRow(
                  icon: Icons.calendar_today_rounded,
                  label: '${_dayLabels[_preferredDay]} ${_preferredTime.toLowerCase()}',
                ),
                const SizedBox(height: 12),
                // How long
                _SummaryRow(
                  icon: Icons.timer_outlined,
                  label: _sessionLabels[_sessionLength],
                ),
                const SizedBox(height: 12),
                // Budget
                _SummaryRow(
                  icon: Icons.shopping_bag_outlined,
                  label: _budgetChoice == 0 ? 'Minimum kit' : 'Best value kit',
                ),
                if (firstStep != null) ...[
                  const SizedBox(height: 12),
                  const Divider(color: AppColors.border, height: 1),
                  const SizedBox(height: 12),
                  // First action
                  Text('Your first tiny action:',
                      style: AppTypography.sansTiny
                          .copyWith(color: AppColors.textMuted)),
                  const SizedBox(height: 6),
                  Text(firstStep.title,
                      style: AppTypography.sansLabel.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      )),
                  Text('${firstStep.estimatedMinutes} min',
                      style: AppTypography.sansTiny
                          .copyWith(color: AppColors.textMuted)),
                ],
              ],
            ),
          ),

          const Spacer(),

          _CoralButton(
            label: 'Let\'s go \u2192',
            onTap: _finishSetup,
          ),
          const SizedBox(height: 8),
          Center(
            child: GestureDetector(
              onTap: _prevStep,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text('Go back',
                    style: AppTypography.sansTiny
                        .copyWith(color: AppColors.textSecondary)),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  //  SHARED: NAV BUTTONS (Back + Continue)
  // ═══════════════════════════════════════════════════════

  Widget _buildNavButtons() {
    return Row(
      children: [
        GestureDetector(
          onTap: _prevStep,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(Icons.arrow_back_rounded,
                size: 20, color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _CoralButton(
            label: 'Continue \u2192',
            onTap: _nextStep,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════
//  OPTION CARD
// ═══════════════════════════════════════════════════════

class _OptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? trailing;
  final bool selected;
  final VoidCallback onTap;

  const _OptionCard({
    required this.title,
    required this.subtitle,
    this.trailing,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Motion.fast,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.coral.withValues(alpha: 0.08)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.coral : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Radio indicator
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.coral : AppColors.textMuted,
                  width: selected ? 6 : 1.5,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTypography.sansLabel.copyWith(
                        color: selected
                            ? AppColors.coral
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      )),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: AppTypography.sansTiny
                          .copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
            if (trailing != null)
              Text(trailing!,
                  style: AppTypography.monoBadge.copyWith(
                    color: AppColors.textMuted,
                  )),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  SUMMARY ROW
// ═══════════════════════════════════════════════════════

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SummaryRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.coral),
        const SizedBox(width: 10),
        Text(label,
            style: AppTypography.sansBodySmall
                .copyWith(color: AppColors.textPrimary)),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════
//  CORAL CTA BUTTON
// ═══════════════════════════════════════════════════════

class _CoralButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _CoralButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: Spacing.buttonCtaHeight,
        decoration: BoxDecoration(
          color: AppColors.coral,
          borderRadius: BorderRadius.circular(Spacing.radiusCta),
          boxShadow: [
            BoxShadow(
              color: AppColors.coral.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(label, style: AppTypography.sansCta),
        ),
      ),
    );
  }
}
