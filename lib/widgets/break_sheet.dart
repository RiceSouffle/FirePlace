import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design/theme.dart';
import '../design/tokens.dart';
import 'controls.dart';

/// A quiet interruption when you've browsed past your limit. No guilt, no
/// breathing gimmick — just a still moment and an easy way out.
Future<bool?> showBreakSheet(BuildContext context, int minutes) {
  final g = context.c;
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: g.bg.withValues(alpha: 0.7),
    builder: (context) => _BreakSheet(minutes: minutes),
  );
}

class _BreakSheet extends StatelessWidget {
  const _BreakSheet({required this.minutes});
  final int minutes;

  @override
  Widget build(BuildContext context) {
    final g = context.c;
    return Container(
      decoration: BoxDecoration(
        color: g.surface,
        border: Border(top: BorderSide(color: g.hairline)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Gap.xxl, Gap.xxl, Gap.xxl, Gap.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$minutes MINUTES', style: Type.label(g.dim)),
              const SizedBox(height: Gap.md),
              Text("That's a good long look.",
                  style: Type.displayM(g.ink)),
              const SizedBox(height: Gap.sm),
              Text(
                'The collection isn’t going anywhere. Step away whenever you '
                'like — it’ll be here when you come back.',
                style: Type.body(g.dim),
              ),
              const SizedBox(height: Gap.xxl),
              GalleryButton(
                label: 'Step away',
                onPressed: () {
                  Navigator.of(context).pop(true);
                  SystemNavigator.pop();
                },
              ),
              const SizedBox(height: Gap.sm),
              GalleryButton(
                label: 'A little longer',
                filled: false,
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
