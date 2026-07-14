import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
import '../../models/feed_item.dart';
import '../../providers/feed_provider.dart';
import '../../providers/saved_posts_provider.dart';
import '../../widgets/controls.dart';
import '../../widgets/gallery_card.dart';
import '../../widgets/states.dart';
import '../detail/post_detail_screen.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  bool _loadingMore = false;

  Future<void> _loadMore() async {
    setState(() => _loadingMore = true);
    await ref.read(feedProvider.notifier).loadMore();
    if (mounted) setState(() => _loadingMore = false);
  }

  void _open(FeedItem item) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => PostDetailScreen(
        item: item,
        heroTag: 'feed_${item.id}',
        onLikeToggle: () => setState(() => item.isLiked = !item.isLiked),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final g = context.c;
    final reduce = reduceMotion(context);
    final feedState = ref.watch(feedProvider);
    final saved = ref.watch(savedPostsProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.read(feedProvider.notifier).refresh(),
        color: g.ink,
        backgroundColor: g.surface,
        edgeOffset: 90,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(Gap.lg,
                    MediaQuery.of(context).padding.top + Gap.lg, Gap.lg, Gap.lg),
                child: Row(
                  children: [
                    Text('FIREPLACE',
                        style: Type.label(g.ink).copyWith(letterSpacing: 3)),
                    const Spacer(),
                    Text('THE COLLECTION', style: Type.label(g.faint)),
                  ],
                ),
              ),
            ),
            feedState.when(
              loading: () => const SliverToBoxAdapter(child: FeedSkeleton()),
              error: (e, _) => SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyView(
                  title: 'Couldn’t load the gallery',
                  subtitle: 'Check your connection and try again.',
                  action: GalleryButton(
                    label: 'Try again',
                    expand: false,
                    onPressed: () => ref.read(feedProvider.notifier).refresh(),
                  ),
                ),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyView(
                      title: 'Nothing here yet',
                      subtitle: 'Pick a few categories under You.',
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: Gap.lg),
                  sliver: SliverList.builder(
                    itemCount: items.length + 1,
                    itemBuilder: (context, index) {
                      if (index == items.length) {
                        return _EndCard(
                          count: items.length,
                          loading: _loadingMore,
                          onMore: _loadMore,
                        );
                      }
                      final item = items[index];
                      final card = GalleryCard(
                        item: item,
                        heroTag: 'feed_${item.id}',
                        isSaved: saved.any((p) => p.id == item.id),
                        onTap: () => _open(item),
                        onLike: () =>
                            setState(() => item.isLiked = !item.isLiked),
                        onSave: () => ref
                            .read(savedPostsProvider.notifier)
                            .toggleSave(item),
                      );
                      if (reduce) return card;
                      return card
                          .animate()
                          .fadeIn(duration: 300.ms)
                          .slideY(begin: 0.06, duration: 300.ms, curve: Move.snap);
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _EndCard extends StatelessWidget {
  const _EndCard(
      {required this.count, required this.loading, required this.onMore});
  final int count;
  final bool loading;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    final g = context.c;
    return Padding(
      padding: const EdgeInsets.only(top: Gap.sm, bottom: Gap.giant),
      child: Column(
        children: [
          Container(width: 40, height: 1, color: g.hairline),
          const SizedBox(height: Gap.lg),
          Text('END OF THE ROLL', style: Type.label(g.dim)),
          const SizedBox(height: Gap.sm),
          Text('$count works so far — a good place to pause.',
              style: Type.body(g.faint), textAlign: TextAlign.center),
          const SizedBox(height: Gap.xl),
          loading
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child:
                      CircularProgressIndicator(strokeWidth: 2, color: g.ink))
              : GalleryButton(
                  label: 'Load more',
                  filled: false,
                  expand: false,
                  onPressed: onMore,
                ),
        ],
      ),
    );
  }
}
