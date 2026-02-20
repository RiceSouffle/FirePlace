import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants.dart';
import '../../../providers/interests_provider.dart';
import '../../onboarding/widgets/interest_chip.dart';

class InterestManager extends ConsumerWidget {
  const InterestManager({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIds = ref.watch(selectedInterestIdsProvider);
    final selectedInterests = AppConstants.allInterests
        .where((i) => selectedIds.contains(i.id))
        .toList();
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your Interests',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () => _showInterestPicker(context, ref),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Edit'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: selectedInterests.map((interest) {
            return Chip(
              label: Text('${interest.emoji} ${interest.label}'),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () => ref
                  .read(selectedInterestIdsProvider.notifier)
                  .toggle(interest.id),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _showInterestPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        builder: (_, controller) {
          return Consumer(
            builder: (context, ref, _) {
              final selectedIds = ref.watch(selectedInterestIdsProvider);
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Text(
                      'Edit Interests',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: controller,
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
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
