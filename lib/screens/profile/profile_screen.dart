import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../design/ember_theme.dart';
import '../../design/ember_tokens.dart';
import '../../models/screen_time_entry.dart';
import '../../providers/interests_provider.dart';
import '../../providers/saved_posts_provider.dart';
import '../../providers/screen_time_provider.dart';
import '../../widgets/budget_ring.dart';
import '../../widgets/ember_bars.dart';
import '../../widgets/ember_controls.dart';
import '../../widgets/hearth.dart';
import 'widgets/interest_editor.dart';
import 'widgets/saved_prints.dart';

/// "Your Hearth" — the mindful centre of the app. Today's time sits inside a
/// cooling budget ring, calm days are celebrated as ember dots, and the raw
/// "remind after N minutes" control is reframed as a friendly goal.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  static const _presets = [15, 30, 45, 60];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final e = context.ember;
    final todaySeconds = ref.watch(todayScreenTimeProvider).valueOrNull ?? 0;
    final history = ref.watch(screenTimeHistoryProvider);
    final budget = ref.watch(dailyBudgetProvider);
    final saved = ref.watch(savedPostsProvider);
    final interests = ref.watch(selectedInterestsProvider);

    final todayMinutes = todaySeconds / 60.0;
    final progress = budget > 0 ? todayMinutes / budget : 0.0;
    final week = _buildWeek(history, budget);
    final calmDays = week.where((d) => d.underBudget).length;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
              Insets.xl, Insets.lg, Insets.xl, Insets.giant),
          children: [
            Text('Your Hearth', style: EmberText.displayL(e.textStrong)),
            const SizedBox(height: Insets.xl),

            // Today's time, inside the cooling budget ring.
            _RingCard(
              todaySeconds: todaySeconds,
              progress: progress,
              underBudget: todayMinutes < budget,
            ),
            const SizedBox(height: Insets.xxl),

            // Calm-day streak.
            _StreakRow(week: week, calmDays: calmDays),
            const SizedBox(height: Insets.xxl),

            // Weekly chart.
            _SectionTitle('This week'),
            const SizedBox(height: Insets.md),
            EmberBars(days: week),
            const SizedBox(height: Insets.xxl),

            // Budget presets.
            _SectionTitle('How long feels good?'),
            const SizedBox(height: Insets.md),
            Wrap(
              spacing: Insets.sm,
              runSpacing: Insets.sm,
              children: [
                for (final p in _presets)
                  EmberChip(
                    label: '$p min',
                    selected: budget == p,
                    onTap: () =>
                        ref.read(dailyBudgetProvider.notifier).set(p),
                  ),
              ],
            ),
            const SizedBox(height: Insets.xxl),

            // Interests.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _SectionTitle('What you love'),
                TextButton.icon(
                  onPressed: () => showInterestEditor(context),
                  icon: Icon(Icons.tune, size: 18, color: e.coral),
                  label: Text('Edit', style: EmberText.label(e.textStrong)),
                ),
              ],
            ),
            const SizedBox(height: Insets.sm),
            Wrap(
              spacing: Insets.sm,
              runSpacing: Insets.sm,
              children: [
                for (final interest in interests)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Insets.md, vertical: Insets.sm),
                    decoration: BoxDecoration(
                      color: e.surface2,
                      borderRadius: BorderRadius.circular(Radii.pill),
                      border: Border.all(color: e.hairline),
                    ),
                    child: Text('${interest.emoji}  ${interest.label}',
                        style: EmberText.label(e.textMuted)),
                  ),
              ],
            ),
            const SizedBox(height: Insets.xxl),

            // Saved prints.
            _SectionTitle('Saved prints'),
            const SizedBox(height: Insets.md),
            SavedPrints(posts: saved),
          ],
        ),
      ),
    );
  }

  List<DayUsage> _buildWeek(List<ScreenTimeEntry> history, int budget) {
    final byDate = {for (final e in history) e.date: e.totalSeconds};
    final today = DateTime.now();
    final days = <DayUsage>[];
    for (var i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final key = DateFormat('yyyy-MM-dd').format(date);
      final minutes = (byDate[key] ?? 0) / 60.0;
      days.add(DayUsage(
        label: DateFormat('E').format(date).substring(0, 1),
        minutes: minutes,
        underBudget: minutes < budget,
        isToday: i == 0,
      ));
    }
    return days;
  }
}

class _RingCard extends StatelessWidget {
  const _RingCard({
    required this.todaySeconds,
    required this.progress,
    required this.underBudget,
  });

  final int todaySeconds;
  final double progress;
  final bool underBudget;

  String get _duration {
    final hours = todaySeconds ~/ 3600;
    final minutes = (todaySeconds % 3600) ~/ 60;
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }

  String get _subtitle {
    final minutes = todaySeconds ~/ 60;
    final part = DateTime.now().hour < 18 ? 'day' : 'evening';
    if (minutes < 1) return 'a fresh $part';
    return underBudget ? 'a calm $part' : 'a full $part';
  }

  @override
  Widget build(BuildContext context) {
    final e = context.ember;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: Insets.xxl),
      decoration: BoxDecoration(
        color: e.surface1,
        borderRadius: Radii.cardBorder,
        border: Border.all(color: e.hairline),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Positioned.fill(
            child: HearthGlow(intensity: 0.5, focal: Alignment.center),
          ),
          BudgetRing(
            progress: progress,
            diameter: 220,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_duration, style: EmberText.displayXL(e.textStrong)),
                const SizedBox(height: Insets.xs),
                Text('tended today  ·  $_subtitle',
                    style: EmberText.label(e.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakRow extends StatelessWidget {
  const _StreakRow({required this.week, required this.calmDays});
  final List<DayUsage> week;
  final int calmDays;

  @override
  Widget build(BuildContext context) {
    final e = context.ember;
    return Row(
      children: [
        for (final day in week)
          Padding(
            padding: const EdgeInsets.only(right: Insets.sm),
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: day.underBudget ? e.sage : e.surface3,
                border: day.isToday
                    ? Border.all(color: e.coral, width: 1.5)
                    : null,
                boxShadow: day.underBudget
                    ? [
                        BoxShadow(
                          color: e.sage.withValues(alpha: 0.5),
                          blurRadius: 8,
                        ),
                      ]
                    : null,
              ),
            ),
          ),
        const Spacer(),
        Text('$calmDays calm ${calmDays == 1 ? 'day' : 'days'}',
            style: EmberText.label(e.sage)),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: EmberText.displayM(context.ember.textStrong));
  }
}
