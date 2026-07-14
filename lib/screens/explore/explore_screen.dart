import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
import '../../models/feed_item.dart';
import '../../providers/explore_provider.dart';
import '../../widgets/controls.dart';
import '../../widgets/plate.dart';
import '../../widgets/states.dart';
import '../detail/post_detail_screen.dart';

class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final g = context.c;
    final reduce = reduceMotion(context);
    final state = ref.watch(exploreProvider);
    final selected = ref.watch(exploreCategoryProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.lg, Gap.lg, Gap.md),
              child: Text('Explore', style: Type.displayL(g.ink)),
            ),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: Gap.lg),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: Gap.sm),
                    child: CategoryToggle(
                      label: 'All',
                      selected: selected == null,
                      onTap: () =>
                          ref.read(exploreCategoryProvider.notifier).state = null,
                    ),
                  ),
                  for (final interest in AppConstants.allInterests)
                    Padding(
                      padding: const EdgeInsets.only(right: Gap.sm),
                      child: CategoryToggle(
                        label: interest.label,
                        selected: selected == interest.id,
                        onTap: () =>
                            ref.read(exploreCategoryProvider.notifier).state =
                                selected == interest.id ? null : interest.id,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: Gap.md),
            Expanded(
              child: state.when(
                loading: () =>
                    Center(child: CircularProgressIndicator(color: g.ink)),
                error: (e, _) => EmptyView(
                  title: 'Couldn’t load',
                  subtitle: 'Try again in a moment.',
                  action: GalleryButton(
                    label: 'Try again',
                    expand: false,
                    onPressed: () =>
                        ref.read(exploreProvider.notifier).refresh(),
                  ),
                ),
                data: (items) {
                  if (items.isEmpty) {
                    return const EmptyView(
                      title: 'Empty room',
                      subtitle: 'Try another category.',
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () =>
                        ref.read(exploreProvider.notifier).refresh(),
                    color: g.ink,
                    backgroundColor: g.surface,
                    child: GridView.builder(
                      key: ValueKey(selected),
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(
                          Gap.lg, 0, Gap.lg, Gap.giant),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: Gap.sm,
                        crossAxisSpacing: Gap.sm,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, i) {
                        final tile = _Tile(item: items[i]);
                        if (reduce) return tile;
                        return tile
                            .animate(delay: (i * 18).ms)
                            .fadeIn(duration: 240.ms);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.item});
  final FeedItem item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => PostDetailScreen(
          item: item,
          heroTag: 'explore_${item.id}',
          onLikeToggle: () => item.isLiked = !item.isLiked,
        ),
      )),
      child: Plate(item: item, heroTag: 'explore_${item.id}', thumb: true),
    );
  }
}
