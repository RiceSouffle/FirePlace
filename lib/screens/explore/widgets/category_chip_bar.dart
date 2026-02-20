import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants.dart';
import '../../../providers/explore_provider.dart';

class CategoryChipBar extends ConsumerWidget {
  const CategoryChipBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(exploreCategoryProvider);
    final theme = Theme.of(context);

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: const Text('All'),
              selected: selected == null,
              onSelected: (_) =>
                  ref.read(exploreCategoryProvider.notifier).state = null,
              selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          ...AppConstants.allInterests.map((interest) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text('${interest.emoji} ${interest.label}'),
                selected: selected == interest.id,
                onSelected: (_) =>
                    ref.read(exploreCategoryProvider.notifier).state =
                        selected == interest.id ? null : interest.id,
                selectedColor:
                    theme.colorScheme.primary.withValues(alpha: 0.2),
              ),
            );
          }),
        ],
      ),
    );
  }
}
