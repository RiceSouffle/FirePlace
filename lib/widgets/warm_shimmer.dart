import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../design/ember_theme.dart';
import '../design/ember_tokens.dart';

/// A warm-tinted loading skeleton shaped like the print cards it precedes, so
/// the feed "warms up" rather than flashing cold grey boxes.
class FeedSkeleton extends StatelessWidget {
  const FeedSkeleton({super.key, this.count = 3});
  final int count;

  @override
  Widget build(BuildContext context) {
    final e = context.ember;
    return Shimmer.fromColors(
      baseColor: e.surface2,
      highlightColor: e.surface3,
      period: const Duration(milliseconds: 1600),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
            Insets.xl, Insets.sm, Insets.xl, Insets.sm),
        itemCount: count,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: Insets.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: index.isEven ? 4 / 5 : 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: e.surface2,
                    borderRadius: Radii.cardBorder,
                  ),
                ),
              ),
              const SizedBox(height: Insets.md),
              _bar(e, widthFactor: 0.7, height: 16),
              const SizedBox(height: Insets.sm),
              _bar(e, widthFactor: 0.4, height: 11),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bar(EmberColors e,
      {required double widthFactor, required double height}) {
    return FractionallySizedBox(
      alignment: Alignment.centerLeft,
      widthFactor: widthFactor,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: e.surface2,
          borderRadius: BorderRadius.circular(Radii.chip),
        ),
      ),
    );
  }
}
