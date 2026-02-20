import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/screen_time_provider.dart';
import '../../providers/saved_posts_provider.dart';
import '../../providers/interests_provider.dart';
import 'widgets/screen_time_chart.dart';
import 'widgets/saved_posts_grid.dart';
import 'widgets/interest_manager.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  String _formatDuration(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todaySecondsAsync = ref.watch(todayScreenTimeProvider);
    final todaySeconds = todaySecondsAsync.valueOrNull ?? 0;
    final history = ref.watch(screenTimeHistoryProvider);
    final savedPosts = ref.watch(savedPostsProvider);
    final storage = ref.read(storageServiceProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                'Profile',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Screen Time Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            color: theme.colorScheme.secondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Screen Time',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Column(
                          children: [
                            Text(
                              _formatDuration(todaySeconds),
                              style:
                                  theme.textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            Text(
                              'today',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'This Week',
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      ScreenTimeChart(entries: history),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Daily reminder after',
                            style: theme.textTheme.bodyMedium,
                          ),
                          DropdownButton<int>(
                            value: storage.reminderThresholdMinutes,
                            items: [15, 30, 45, 60, 90, 120]
                                .map((m) => DropdownMenuItem(
                                      value: m,
                                      child: Text('$m min'),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                storage.setReminderThresholdMinutes(value);
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Interests Section
              const InterestManager(),
              const SizedBox(height: 24),

              // Saved Posts Section
              Text(
                'Saved Posts',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              SavedPostsGrid(posts: savedPosts),
            ],
          ),
        ),
      ),
    );
  }
}
