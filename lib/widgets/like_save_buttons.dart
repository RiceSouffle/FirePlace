import 'package:flutter/material.dart';

class LikeSaveButtons extends StatelessWidget {
  final bool isLiked;
  final bool isSaved;
  final VoidCallback onLike;
  final VoidCallback onSave;

  const LikeSaveButtons({
    super.key,
    required this.isLiked,
    required this.isSaved,
    required this.onLike,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              isLiked ? Icons.favorite : Icons.favorite_outline,
              key: ValueKey(isLiked),
              color: isLiked ? Colors.red : theme.colorScheme.onSurface,
              size: 22,
            ),
          ),
          onPressed: onLike,
          visualDensity: VisualDensity.compact,
        ),
        IconButton(
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              isSaved ? Icons.bookmark : Icons.bookmark_outline,
              key: ValueKey(isSaved),
              color: isSaved
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
              size: 22,
            ),
          ),
          onPressed: onSave,
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }
}
