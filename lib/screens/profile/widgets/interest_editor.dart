import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants.dart';
import '../../../design/theme.dart';
import '../../../design/tokens.dart';
import '../../../providers/interests_provider.dart';
import '../../../widgets/controls.dart';

Future<void> showInterestEditor(BuildContext context) {
  final g = context.c;
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: g.bg.withValues(alpha: 0.6),
    builder: (context) => const _InterestEditor(),
  );
}

class _InterestEditor extends ConsumerWidget {
  const _InterestEditor();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final g = context.c;
    final selected = ref.watch(selectedInterestIdsProvider);

    return Container(
      decoration: BoxDecoration(
        color: g.surface,
        border: Border(top: BorderSide(color: g.hairline)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(Gap.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('EDIT CATEGORIES', style: Type.label(g.dim)),
              const SizedBox(height: Gap.sm),
              Text('Follow the rooms you like.', style: Type.body(g.dim)),
              const SizedBox(height: Gap.xl),
              ConstrainedBox(
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.5),
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: Gap.sm,
                    runSpacing: Gap.sm,
                    children: [
                      for (final interest in AppConstants.allInterests)
                        CategoryToggle(
                          label: interest.label,
                          selected: selected.contains(interest.id),
                          onTap: () => ref
                              .read(selectedInterestIdsProvider.notifier)
                              .toggle(interest.id),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Gap.xl),
              GalleryButton(
                label: 'Done',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
