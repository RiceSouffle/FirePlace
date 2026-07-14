import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants.dart';
import '../../../design/ember_theme.dart';
import '../../../design/ember_tokens.dart';
import '../../../providers/interests_provider.dart';
import '../../../widgets/hearth_sheet.dart';
import '../../../widgets/ignitable_tile.dart';

/// Opens the interest editor as a hearth sheet — the same ignitable coals from
/// onboarding, so tending your fire feels identical wherever you do it.
Future<void> showInterestEditor(BuildContext context) {
  return showHearthSheet(
    context: context,
    builder: (context) => const _InterestEditor(),
  );
}

class _InterestEditor extends ConsumerWidget {
  const _InterestEditor();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final e = context.ember;
    final selectedIds = ref.watch(selectedInterestIdsProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tend your fire', style: EmberText.displayM(e.textStrong)),
        const SizedBox(height: Insets.xs),
        Text('Add or remove what you love.',
            style: EmberText.body(e.textMuted)),
        const SizedBox(height: Insets.xl),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.5,
          ),
          child: SingleChildScrollView(
            child: Wrap(
              spacing: Insets.sm + 2,
              runSpacing: Insets.sm + 2,
              children: [
                for (final interest in AppConstants.allInterests)
                  IgnitableTile(
                    emoji: interest.emoji,
                    label: interest.label,
                    selected: selectedIds.contains(interest.id),
                    onTap: () => ref
                        .read(selectedInterestIdsProvider.notifier)
                        .toggle(interest.id),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
