import 'package:flutter/material.dart';
import '../design/theme.dart';
import '../design/tokens.dart';

/// Today's browsing against the chosen limit — a big tabular number over a thin
/// progress rule. Monochrome: the rule fills with ink; over-limit reads "OVER".
class SessionMeter extends StatelessWidget {
  const SessionMeter({
    super.key,
    required this.seconds,
    required this.limitMinutes,
  });

  final int seconds;
  final int limitMinutes;

  String get _duration {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }

  @override
  Widget build(BuildContext context) {
    final g = context.c;
    final minutes = seconds / 60.0;
    final progress =
        limitMinutes > 0 ? (minutes / limitMinutes).clamp(0.0, 1.0) : 0.0;
    final over = minutes > limitMinutes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(_duration, style: Type.number(g.ink)),
            const Spacer(),
            Text(over ? 'OVER' : 'TODAY', style: Type.label(over ? g.ink : g.dim)),
          ],
        ),
        const SizedBox(height: Gap.md),
        // Thin progress rule.
        LayoutBuilder(
          builder: (context, c) => Stack(
            children: [
              Container(height: 3, width: c.maxWidth, color: g.hairline),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progress),
                duration: Move.slow,
                curve: Move.snap,
                builder: (context, v, _) =>
                    Container(height: 3, width: c.maxWidth * v, color: g.ink),
              ),
            ],
          ),
        ),
        const SizedBox(height: Gap.sm),
        Text('LIMIT ${limitMinutes}M', style: Type.label(g.faint)),
      ],
    );
  }
}

class DayUsage {
  const DayUsage({
    required this.label,
    required this.minutes,
    required this.isToday,
  });
  final String label;
  final double minutes;
  final bool isToday;
}

/// A week of usage as thin ink columns; today reads full-strength, the rest dim.
class WeekBars extends StatelessWidget {
  const WeekBars({super.key, required this.days, this.height = 120});
  final List<DayUsage> days;
  final double height;

  @override
  Widget build(BuildContext context) {
    final g = context.c;
    final maxMinutes =
        days.fold<double>(1, (m, d) => d.minutes > m ? d.minutes : m);
    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final d in days)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, c) {
                        final ratio = (d.minutes / maxMinutes).clamp(0.0, 1.0);
                        final h = (c.maxHeight * ratio).clamp(2.0, c.maxHeight);
                        return Align(
                          alignment: Alignment.bottomCenter,
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: h),
                            duration: reduceMotion(context)
                                ? Duration.zero
                                : Move.slow,
                            curve: Move.snap,
                            builder: (context, v, _) => Container(
                              width: 3,
                              height: v,
                              color: d.isToday ? g.ink : g.faint,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: Gap.sm),
                  Text(d.label,
                      style: Type.label(d.isToday ? g.ink : g.faint)
                          .copyWith(fontSize: 10, letterSpacing: 0.5)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
