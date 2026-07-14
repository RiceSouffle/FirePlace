import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
import '../../models/screen_time_entry.dart';
import '../../providers/interests_provider.dart';
import '../../providers/saved_posts_provider.dart';
import '../../providers/screen_time_provider.dart';
import '../../widgets/controls.dart';
import '../../widgets/session.dart';
import 'widgets/interest_editor.dart';
import 'widgets/saved_grid.dart';

/// "You" — the anti-doomscroll centre: today's session against a limit, the
/// week at a glance, the categories you follow, and everything you've saved.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  static const _presets = [15, 30, 45, 60];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final g = context.c;
    final seconds = ref.watch(todayScreenTimeProvider).valueOrNull ?? 0;
    final history = ref.watch(screenTimeHistoryProvider);
    final limit = ref.watch(dailyBudgetProvider);
    final saved = ref.watch(savedPostsProvider);
    final following = ref.watch(selectedInterestsProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.lg, Gap.lg, Gap.giant),
          children: [
            Text('You', style: Type.displayL(g.ink)),
            const SizedBox(height: Gap.xl),
            SessionMeter(seconds: seconds, limitMinutes: limit),
            const SizedBox(height: Gap.xxl),
            WeekBars(days: _week(history)),
            const SizedBox(height: Gap.xxxl),

            _Header('Daily limit'),
            const SizedBox(height: Gap.md),
            Wrap(
              spacing: Gap.sm,
              runSpacing: Gap.sm,
              children: [
                for (final p in _presets)
                  CategoryToggle(
                    label: '$p min',
                    selected: limit == p,
                    onTap: () =>
                        ref.read(dailyBudgetProvider.notifier).set(p),
                  ),
              ],
            ),
            const SizedBox(height: Gap.xxxl),

            Row(
              children: [
                _Header('Following'),
                const Spacer(),
                GestureDetector(
                  onTap: () => showInterestEditor(context),
                  child: Text('EDIT', style: Type.label(g.ink)),
                ),
              ],
            ),
            const SizedBox(height: Gap.md),
            Wrap(
              spacing: Gap.sm,
              runSpacing: Gap.sm,
              children: [
                for (final i in following)
                  CategoryToggle(
                    label: i.label,
                    selected: true,
                    onTap: () => ref
                        .read(selectedInterestIdsProvider.notifier)
                        .toggle(i.id),
                  ),
              ],
            ),
            const SizedBox(height: Gap.xxxl),

            _Header('Saved'),
            const SizedBox(height: Gap.md),
            SavedGrid(posts: saved),
          ],
        ),
      ),
    );
  }

  List<DayUsage> _week(List<ScreenTimeEntry> history) {
    final byDate = {for (final e in history) e.date: e.totalSeconds};
    final today = DateTime.now();
    return [
      for (var i = 6; i >= 0; i--)
        () {
          final date = today.subtract(Duration(days: i));
          final key = DateFormat('yyyy-MM-dd').format(date);
          return DayUsage(
            label: DateFormat('E').format(date).substring(0, 1),
            minutes: (byDate[key] ?? 0) / 60.0,
            isToday: i == 0,
          );
        }(),
    ];
  }
}

class _Header extends StatelessWidget {
  const _Header(this.text);
  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text.toUpperCase(), style: Type.label(context.c.dim));
}
