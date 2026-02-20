import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../models/screen_time_entry.dart';

class ScreenTimeChart extends StatelessWidget {
  final List<ScreenTimeEntry> entries;

  const ScreenTimeChart({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final last7Days = <String>[];
    for (int i = 6; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      last7Days.add(DateFormat('yyyy-MM-dd').format(date));
    }

    final entryMap = {for (final e in entries) e.date: e.totalSeconds};

    final bars = <BarChartGroupData>[];
    for (int i = 0; i < last7Days.length; i++) {
      final seconds = entryMap[last7Days[i]] ?? 0;
      final minutes = seconds / 60.0;
      final isToday = i == 6;
      bars.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: minutes,
              color: isToday
                  ? theme.colorScheme.primary
                  : theme.colorScheme.secondary,
              width: 20,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(6),
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: bars
                  .map((b) => b.barRods.first.toY)
                  .fold<double>(0, (a, b) => a > b ? a : b) *
              1.3,
          barGroups: bars,
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}m',
                    style: theme.textTheme.labelSmall,
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= last7Days.length) return const SizedBox();
                  final date = DateTime.parse(last7Days[idx]);
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      DateFormat('E').format(date),
                      style: theme.textTheme.labelSmall,
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}
