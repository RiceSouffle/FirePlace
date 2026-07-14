import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design/theme.dart';
import '../design/tokens.dart';
import '../models/feed_item.dart';
import 'plate.dart';

/// The feed's unit: a framed plate over a wall label (title, byline, collection)
/// with quiet like/save actions. Double-tap likes with a crisp flash + haptic.
class GalleryCard extends StatefulWidget {
  const GalleryCard({
    super.key,
    required this.item,
    required this.heroTag,
    required this.isSaved,
    required this.onTap,
    required this.onLike,
    required this.onSave,
  });

  final FeedItem item;
  final String heroTag;
  final bool isSaved;
  final VoidCallback onTap;
  final VoidCallback onLike;
  final VoidCallback onSave;

  @override
  State<GalleryCard> createState() => _GalleryCardState();
}

class _GalleryCardState extends State<GalleryCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flash;
  bool _flashing = false;

  @override
  void initState() {
    super.initState();
    _flash = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    )..addStatusListener((s) {
        if (s == AnimationStatus.completed) {
          if (mounted) setState(() => _flashing = false);
          _flash.reset();
        }
      });
  }

  void _onDoubleTap() {
    if (!widget.item.isLiked) widget.onLike();
    HapticFeedback.selectionClick();
    setState(() => _flashing = true);
    _flash.forward(from: 0);
  }

  @override
  void dispose() {
    _flash.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final g = context.c;
    final item = widget.item;

    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.xxxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: widget.onTap,
            onDoubleTap: _onDoubleTap,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Plate(item: item, heroTag: widget.heroTag),
                if (_flashing)
                  FadeTransition(
                    opacity: Tween(begin: 1.0, end: 0.0).animate(
                      CurvedAnimation(
                          parent: _flash,
                          curve: const Interval(0.4, 1, curve: Curves.easeOut)),
                    ),
                    child: ScaleTransition(
                      scale: Tween(begin: 0.6, end: 1.0).animate(
                        CurvedAnimation(parent: _flash, curve: Move.snap),
                      ),
                      child: const Icon(Icons.favorite,
                          color: Colors.white,
                          size: 88,
                          shadows: [Shadow(blurRadius: 16, color: Colors.black54)]),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: Gap.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (item.title.isNotEmpty)
                      Text(item.title,
                          style: Type.title(g.ink),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    if (item.title.isNotEmpty) const SizedBox(height: Gap.xs),
                    if (item.hasCredit) ...[
                      Text(item.byline,
                          style: Type.mono(g.dim),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: Gap.xs),
                    ],
                    Text(item.sourceName.toUpperCase(),
                        style: Type.label(g.faint)),
                  ],
                ),
              ),
              const SizedBox(width: Gap.sm),
              _IconToggle(
                icon: item.isLiked ? Icons.favorite : Icons.favorite_border,
                active: item.isLiked,
                tooltip: item.isLiked ? 'Unlike' : 'Like',
                onTap: () {
                  HapticFeedback.selectionClick();
                  widget.onLike();
                },
              ),
              _IconToggle(
                icon: widget.isSaved ? Icons.bookmark : Icons.bookmark_border,
                active: widget.isSaved,
                tooltip: widget.isSaved ? 'Remove from saved' : 'Save',
                onTap: () {
                  HapticFeedback.selectionClick();
                  widget.onSave();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IconToggle extends StatelessWidget {
  const _IconToggle({
    required this.icon,
    required this.active,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final bool active;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final g = context.c;
    return IconButton(
      onPressed: onTap,
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      icon: AnimatedSwitcher(
        duration: Move.fast,
        transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
        child: Icon(icon,
            key: ValueKey(active), size: 22, color: active ? g.ink : g.faint),
      ),
    );
  }
}
