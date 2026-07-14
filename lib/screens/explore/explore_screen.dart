import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../constants.dart';
import '../../design/ember_theme.dart';
import '../../design/ember_tokens.dart';
import '../../models/feed_item.dart';
import '../../providers/explore_provider.dart';
import '../../widgets/ember_controls.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/framed_photo.dart';
import '../../widgets/museum_label.dart';
import '../detail/post_detail_screen.dart';

class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final e = context.ember;
    final reduce = reduceMotion(context);
    final exploreState = ref.watch(exploreProvider);
    final selected = ref.watch(exploreCategoryProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  Insets.xl, Insets.lg, Insets.xl, Insets.md),
              child: Text('Explore', style: EmberText.displayL(e.textStrong)),
            ),
            _ChipBar(selected: selected),
            const SizedBox(height: Insets.md),
            Expanded(
              child: exploreState.when(
                loading: () =>
                    Center(child: CircularProgressIndicator(color: e.coral)),
                error: (error, _) => EmptyState(
                  icon: Icons.cloud_off,
                  title: 'Nothing to show',
                  subtitle: 'We couldn’t reach Reddit just now.',
                  action: EmberButton(
                    label: 'Try again',
                    icon: Icons.refresh,
                    expand: false,
                    onPressed: () =>
                        ref.read(exploreProvider.notifier).refresh(),
                  ),
                ),
                data: (items) {
                  if (items.isEmpty) {
                    return const EmptyState(
                      icon: Icons.search_off,
                      title: 'Quiet gallery',
                      subtitle: 'Try a different category.',
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () =>
                        ref.read(exploreProvider.notifier).refresh(),
                    color: e.coral,
                    backgroundColor: e.surface2,
                    child: MasonryGridView.count(
                      key: ValueKey(selected),
                      crossAxisCount: 2,
                      mainAxisSpacing: Insets.md,
                      crossAxisSpacing: Insets.md,
                      padding: const EdgeInsets.fromLTRB(
                          Insets.xl, 0, Insets.xl, Insets.xxxl),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final tile = _ExploreTile(item: items[index]);
                        if (reduce) return tile;
                        return tile
                            .animate(delay: (index * 22).ms)
                            .fadeIn(duration: 320.ms)
                            .scale(
                              begin: const Offset(0.94, 0.94),
                              curve: Motion.ember,
                            );
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

class _ChipBar extends ConsumerWidget {
  const _ChipBar({required this.selected});
  final String? selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(exploreCategoryProvider.notifier);
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: Insets.xl),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: Insets.sm),
            child: EmberChip(
              label: 'All',
              selected: selected == null,
              onTap: () => notifier.state = null,
            ),
          ),
          for (final interest in AppConstants.allInterests)
            Padding(
              padding: const EdgeInsets.only(right: Insets.sm),
              child: EmberChip(
                label: interest.label,
                emoji: interest.emoji,
                selected: selected == interest.id,
                onTap: () => notifier.state =
                    selected == interest.id ? null : interest.id,
              ),
            ),
        ],
      ),
    );
  }
}

class _ExploreTile extends StatelessWidget {
  const _ExploreTile({required this.item});
  final FeedItem item;

  @override
  Widget build(BuildContext context) {
    final e = context.ember;
    final ratio = item.aspectRatio.clamp(0.6, 1.5);
    final title = item.title ?? '';

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PostDetailScreen(
            item: item,
            heroTag: 'explore_${item.id}',
            onLikeToggle: () => item.isLiked = !item.isLiked,
          ),
        ),
      ),
      child: AspectRatio(
        aspectRatio: ratio,
        child: FramedPhoto(
          imageUrl: item.thumbnailUrl.isNotEmpty
              ? item.thumbnailUrl
              : item.imageUrl,
          heroTag: 'explore_${item.id}',
          semanticLabel: title.isNotEmpty ? title : 'Photograph',
          shadow: e.cardShadow(),
          overlay: DecoratedBox(
            decoration: BoxDecoration(gradient: e.scrim(strength: 0.82)),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(Insets.md),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title.isNotEmpty)
                      Text(
                        title,
                        style: EmberText.label(const Color(0xFFF7EFE4))
                            .copyWith(fontWeight: FontWeight.w600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (title.isNotEmpty) const SizedBox(height: Insets.xs),
                    MuseumLabel(
                      item: item,
                      color: const Color(0xFFCDBFAE),
                      tappable: false,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
