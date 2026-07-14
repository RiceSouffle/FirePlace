import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../design/theme.dart';
import '../design/tokens.dart';
import '../models/feed_item.dart';

/// A framed image. Photographs fill the frame (cover); artworks are shown whole
/// on a neutral mat (contain) so nothing is cropped — a wall of uniform frames.
class Plate extends StatelessWidget {
  const Plate({
    super.key,
    required this.item,
    required this.heroTag,
    this.aspectRatio = 1,
    this.thumb = false,
  });

  final FeedItem item;
  final String heroTag;
  final double aspectRatio;

  /// Use the lower-res thumbnail (grids).
  final bool thumb;

  // Fine art is matted (contain); photographs of things fill the frame (cover).
  bool get _isPhoto => item.sourceName != 'The Met';

  @override
  Widget build(BuildContext context) {
    final g = context.c;
    final url = thumb && item.thumbnailUrl.isNotEmpty
        ? item.thumbnailUrl
        : item.imageUrl;

    final image = CachedNetworkImage(
      imageUrl: url,
      httpHeaders: kImageHeaders,
      fit: _isPhoto ? BoxFit.cover : BoxFit.contain,
      fadeInDuration: Move.fast,
      placeholder: (context, _) => ColoredBox(color: g.surfaceHigh),
      errorWidget: (context, _, _) => ColoredBox(
        color: g.surfaceHigh,
        child: Center(
          child: Text('—', style: Type.mono(g.faint)),
        ),
      ),
    );

    return Container(
      color: g.surface,
      foregroundDecoration: BoxDecoration(
        border: Border.all(color: g.hairline, width: 1),
      ),
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: ClipRect(
          child: Hero(tag: heroTag, child: image),
        ),
      ),
    );
  }
}
