import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants.dart';
import '../../providers/interests_provider.dart';
import '../shell/app_shell.dart';
import 'widgets/interest_chip.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIds = ref.watch(selectedInterestIdsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              Icon(
                Icons.local_fire_department,
                size: 48,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Welcome to FirePlace',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose what you love. We\'ll curate a feed just for you — no algorithms, no ads, no doom-scrolling.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: AppConstants.allInterests.map((interest) {
                      return InterestChip(
                        interest: interest,
                        isSelected: selectedIds.contains(interest.id),
                        onTap: () => ref
                            .read(selectedInterestIdsProvider.notifier)
                            .toggle(interest.id),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: selectedIds.isEmpty
                      ? null
                      : () async {
                          final storage = ref.read(storageServiceProvider);
                          await storage.setOnboardingComplete();
                          if (context.mounted) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => const AppShell(),
                              ),
                            );
                          }
                        },
                  child: Text(
                    selectedIds.isEmpty
                        ? 'Select at least one interest'
                        : 'Continue (${selectedIds.length} selected)',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
