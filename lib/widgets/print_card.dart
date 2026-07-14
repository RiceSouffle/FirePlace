import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design/ember_theme.dart';
import '../design/ember_tokens.dart';
import '../models/feed_item.dart';
import 'ember_burst.dart';
import 'framed_photo.dart';
import 'museum_label.dart';

/// The feed's hero unit: a matted print with an Inter title, the recurring
/// museum label, and quiet like/save affordances that only take on colour once
/// touched. Double-tap fires the ember-burst like.
class PrintCard extends StatelessWidget {
  const PrintCard({
    super.key,
    required this.item,
    required this.heroTag,
    required this.onTap,
    required this.onLike,
    required this.onSave,
    required this.isSaved,
  });

  final FeedItem item;
  final String heroTag;
  final VoidCallback onTap;
  final VoidCallback onLike;
  final VoidCallback onSave;
  final bool isSaved;

  @override
  Widget build(BuildContext context) {
    final e = context.ember;
    final title = item.title ?? '';
    // Keep the single column tasteful — no extreme letterbox/pillar images.
    final ratio = item.aspectRatio.clamp(0.7, 1.4);

    return Padding(
      padding: const EdgeInsets.only(bottom: Insets.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DoubleTapEmber(
            liked: item.isLiked,
            onLikeRequested: onLike,
            onTap: onTap,
            child: AspectRatio(
              aspectRatio: ratio,
              child: FramedPhoto(
                imageUrl: item.imageUrl,
                heroTag: heroTag,
                shadow: e.cardShadow(),
              ),
            ),
          ),
          const SizedBox(height: Insets.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Insets.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (title.isNotEmpty)
                        Text(
                          title,
                          style: EmberText.title(e.textStrong),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (title.isNotEmpty) const SizedBox(height: Insets.xs),
                      MuseumLabel(item: item),
                    ],
                  ),
                ),
                const SizedBox(width: Insets.sm),
                _QuietAction(
                  icon: item.isLiked ? Icons.favorite : Icons.favorite_border,
                  label: item.isLiked ? 'Unlike' : 'Like',
                  active: item.isLiked,
                  activeColor: e.likeColor,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onLike();
                  },
                ),
                _QuietAction(
                  icon: isSaved ? Icons.bookmark : Icons.bookmark_border,
                  label: isSaved ? 'Remove from saved' : 'Save',
                  active: isSaved,
                  activeColor: e.saveColor,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onSave();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuietAction extends StatelessWidget {
  const _QuietAction({
    required this.icon,
    required this.label,
    required this.active,
    required this.activeColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final e = context.ember;
    return IconButton(
      onPressed: onTap,
      tooltip: label,
      visualDensity: VisualDensity.compact,
      icon: AnimatedSwitcher(
        duration: Motion.fast,
        transitionBuilder: (child, anim) =>
            ScaleTransition(scale: anim, child: child),
        child: Icon(
          icon,
          key: ValueKey(active),
          size: 22,
          color: active ? activeColor : e.textFaint,
        ),
      ),
    );
  }
}
