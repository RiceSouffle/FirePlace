import 'package:flutter/material.dart';
import '../design/ember_theme.dart';
import '../design/ember_tokens.dart';
import 'hearth.dart';

/// A warm empty/idle state — a soft living-hearth glow behind a serif line,
/// so even "nothing here" feels tended rather than broken.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final e = context.ember;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Insets.huge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const HearthGlow(intensity: 0.9, focal: Alignment.center),
                  Icon(icon, size: 44, color: e.textStrong),
                ],
              ),
            ),
            const SizedBox(height: Insets.lg),
            Text(
              title,
              style: EmberText.displayM(e.textStrong),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Insets.sm),
            Text(
              subtitle,
              style: EmberText.body(e.textMuted),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: Insets.xxl),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
