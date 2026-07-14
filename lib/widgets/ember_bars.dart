import 'package:flutter/material.dart';
import '../design/ember_theme.dart';
import '../design/ember_tokens.dart';

/// One day's worth of data for [EmberBars].
class DayUsage {
  const DayUsage({
    required this.label,
    required this.minutes,
    required this.underBudget,
    this.isToday = false,
  });

  final String label;
  final double minutes;
  final bool underBudget;
  final bool isToday;
}

/// The weekly screen-time chart, drawn as ember-gradient columns that grow up
/// from a warm base. Days spent under budget are capped in calm [sage] — a quiet
/// reward for looking less, echoing the budget ring.
class EmberBars extends StatelessWidget {
  const EmberBars({super.key, required this.days, this.height = 160});

  final List<DayUsage> days;
  final double height;

  @override
  Widget build(BuildContext context) {
    final e = context.ember;
    final growDuration =
        reduceMotion(context) ? Duration.zero : Motion.slow;
    final maxMinutes = days.fold<double>(
      1,
      (m, d) => d.minutes > m ? d.minutes : m,
    );

    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final day in days)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Insets.xs),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      day.minutes >= 1 ? '${day.minutes.round()}' : '',
                      style: EmberText.museum(e.textFaint).copyWith(
                        letterSpacing: 0,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: Insets.xs),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final ratio = (day.minutes / maxMinutes).clamp(0.0, 1.0);
                          final barHeight =
                              (constraints.maxHeight * ratio).clamp(4.0, constraints.maxHeight);
                          return Align(
                            alignment: Alignment.bottomCenter,
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: barHeight),
                              duration: growDuration,
                              curve: Motion.ember,
                              builder: (context, h, _) => Container(
                                height: h,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: day.underBudget
                                        ? [e.sage, e.sage.withValues(alpha: 0.55)]
                                        : [
                                            e.coral,
                                            e.amber.withValues(alpha: 0.7),
                                          ],
                                  ),
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(6),
                                  ),
                                  boxShadow: day.isToday
                                      ? [
                                          BoxShadow(
                                            color: e.coral.withValues(alpha: 0.4),
                                            blurRadius: 12,
                                            spreadRadius: -2,
                                          ),
                                        ]
                                      : null,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: Insets.sm),
                    Text(
                      day.label,
                      style: EmberText.museum(
                        day.isToday ? e.coral : e.textFaint,
                      ).copyWith(letterSpacing: 0.5, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
