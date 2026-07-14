import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../design/theme.dart';
import '../design/tokens.dart';

/// A monochrome loading skeleton shaped like the feed's framed plates.
class FeedSkeleton extends StatelessWidget {
  const FeedSkeleton({super.key, this.count = 3});
  final int count;

  @override
  Widget build(BuildContext context) {
    final g = context.c;
    return Shimmer.fromColors(
      baseColor: g.surface,
      highlightColor: g.surfaceHigh,
      period: const Duration(milliseconds: 1400),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: Gap.lg),
        itemCount: count,
        itemBuilder: (context, i) => Padding(
          padding: const EdgeInsets.only(bottom: Gap.xxxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(aspectRatio: 1, child: Container(color: g.surface)),
              const SizedBox(height: Gap.md),
              Container(height: 15, width: 200, color: g.surface),
              const SizedBox(height: Gap.sm),
              Container(height: 11, width: 130, color: g.surface),
            ],
          ),
        ),
      ),
    );
  }
}

/// A quiet empty / error state.
class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    required this.title,
    required this.subtitle,
    this.action,
  });

  final String title;
  final String subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final g = context.c;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Gap.huge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 1, color: g.ink),
            const SizedBox(height: Gap.xl),
            Text(title,
                style: Type.displayM(g.ink), textAlign: TextAlign.center),
            const SizedBox(height: Gap.sm),
            Text(subtitle,
                style: Type.body(g.dim), textAlign: TextAlign.center),
            if (action != null) ...[
              const SizedBox(height: Gap.xxl),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
