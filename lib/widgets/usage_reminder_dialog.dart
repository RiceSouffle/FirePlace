import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UsageReminderDialog extends StatelessWidget {
  const UsageReminderDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(
            Icons.spa_outlined,
            color: theme.colorScheme.secondary,
          ),
          const SizedBox(width: 8),
          const Text('Time for a break?'),
        ],
      ),
      content: const Text(
        'You\'ve been browsing for a while now. '
        'Maybe step outside and enjoy the real world for a bit. '
        'Your curated feed will be here when you get back.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Keep Browsing'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop();
            SystemNavigator.pop();
          },
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.secondary,
          ),
          child: const Text('Take a Break'),
        ),
      ],
    );
  }
}
