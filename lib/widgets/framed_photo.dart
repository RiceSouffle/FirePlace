import 'dart:ui' show lerpDouble;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../design/ember_theme.dart';
import '../design/ember_tokens.dart';

/// The rule that unifies the whole app: a photograph is never shown edge-to-edge
/// on cream. It's always matted on an [EmberColors.inkFrame] plate with a 1px
/// hairline and a warm shadow — turning unpredictable Reddit imagery into "a
/// hung print" in both light and dark themes.
///
/// When [heroTag] is set, the print lifts into the detail view with a flight that
/// eases its corner radius open (20 → 0), stepping off the wall.
class FramedPhoto extends StatelessWidget {
  const FramedPhoto({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.borderRadius = Radii.cardBorder,
    this.heroTag,
    this.shadow,
    this.overlay,
    this.semanticLabel,
  });

  final String imageUrl;
  final BoxFit fit;
  final BorderRadius borderRadius;
  final String? heroTag;
  final List<BoxShadow>? shadow;

  /// Painted above the image, inside the frame (e.g. a scrim + museum label).
  final Widget? overlay;

  /// When set, the frame is announced to screen readers as a labelled image.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final e = context.ember;

    Widget image = CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      fadeInDuration: Motion.fast,
      placeholder: (context, url) => ColoredBox(color: e.inkFrame),
      errorWidget: (context, url, error) => ColoredBox(
        color: e.inkFrame,
        child: Icon(
          Icons.local_fire_department_outlined,
          color: e.textFaint.withValues(alpha: 0.4),
          size: 40,
        ),
      ),
    );

    if (heroTag != null) {
      image = Hero(
        tag: heroTag!,
        flightShuttleBuilder: (flightContext, animation, direction,
            fromContext, toContext) {
          final t = direction == HeroFlightDirection.push
              ? animation
              : ReverseAnimation(animation);
          return AnimatedBuilder(
            animation: t,
            builder: (context, _) {
              final r = lerpDouble(
                  Radii.card, 0, Curves.easeInOut.transform(t.value))!;
              return ClipRRect(
                borderRadius: BorderRadius.circular(r),
                child: CachedNetworkImage(imageUrl: imageUrl, fit: fit),
              );
            },
          );
        },
        child: image,
      );
    }

    final content = Stack(
      fit: StackFit.passthrough,
      children: [
        Positioned.fill(child: ClipRRect(borderRadius: borderRadius, child: image)),
        if (overlay != null) Positioned.fill(child: overlay!),
      ],
    );

    final framed = Container(
      decoration: BoxDecoration(
        color: e.inkFrame,
        borderRadius: borderRadius,
        boxShadow: shadow,
      ),
      // Crisp frame edge drawn on top so it survives the image bleed.
      foregroundDecoration: BoxDecoration(
        borderRadius: borderRadius,
        border: Border.all(color: e.hairline, width: 1),
      ),
      child: content,
    );

    if (semanticLabel == null) return framed;
    return Semantics(image: true, label: semanticLabel, child: framed);
  }
}
