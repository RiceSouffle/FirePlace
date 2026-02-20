import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/feed_item.dart';
import '../../../widgets/source_attribution.dart';
import '../../../widgets/like_save_buttons.dart';

class FeedCard extends StatefulWidget {
  final FeedItem item;
  final VoidCallback onLike;
  final VoidCallback onSave;
  final VoidCallback? onTap;

  const FeedCard({
    super.key,
    required this.item,
    required this.onLike,
    required this.onSave,
    this.onTap,
  });

  @override
  State<FeedCard> createState() => _FeedCardState();
}

class _FeedCardState extends State<FeedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _heartController;
  late Animation<double> _heartScale;
  bool _showHeart = false;

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _heartScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.4)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.4, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticIn)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.0),
        weight: 10,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 20,
      ),
    ]).animate(_heartController);

    _heartController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _showHeart = false);
        _heartController.reset();
      }
    });
  }

  @override
  void dispose() {
    _heartController.dispose();
    super.dispose();
  }

  void _onDoubleTap() {
    if (!widget.item.isLiked) {
      widget.onLike();
    }
    setState(() => _showHeart = true);
    _heartController.forward(from: 0.0);
  }

  Color? _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    try {
      final cleaned = hex.replaceFirst('#', '');
      return Color(int.parse('FF$cleaned', radix: 16));
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final placeholderColor =
        _parseColor(widget.item.avgColor) ?? Colors.grey.shade200;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: widget.onTap,
            onDoubleTap: _onDoubleTap,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AspectRatio(
                  aspectRatio: widget.item.aspectRatio.clamp(0.5, 2.0),
                  child: CachedNetworkImage(
                    imageUrl: widget.item.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Container(color: placeholderColor),
                    errorWidget: (context, url, error) => Container(
                      color: placeholderColor,
                      child: const Center(
                        child: Icon(Icons.broken_image_outlined, size: 48),
                      ),
                    ),
                  ),
                ),
                if (_showHeart)
                  AnimatedBuilder(
                    animation: _heartScale,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _heartScale.value,
                        child: child,
                      );
                    },
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 100,
                      shadows: [
                        Shadow(
                          blurRadius: 20,
                          color: Colors.black38,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.item.title ?? '',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                LikeSaveButtons(
                  isLiked: widget.item.isLiked,
                  isSaved: widget.item.isSaved,
                  onLike: widget.onLike,
                  onSave: widget.onSave,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SourceAttribution(item: widget.item),
          ),
        ],
      ),
    );
  }
}
