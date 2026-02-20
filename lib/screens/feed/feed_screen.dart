import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/feed_provider.dart';
import '../../providers/saved_posts_provider.dart';
import '../detail/post_detail_screen.dart';
import 'widgets/feed_card.dart';
import 'widgets/feed_shimmer.dart';
import '../../widgets/empty_state.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isLoadingMore) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 500) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    _isLoadingMore = true;
    await ref.read(feedProvider.notifier).loadMore();
    _isLoadingMore = false;
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(feedProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.read(feedProvider.notifier).refresh(),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              floating: true,
              title: Row(
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'FirePlace',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              backgroundColor: theme.scaffoldBackgroundColor,
            ),
            feedState.when(
              loading: () => const SliverFillRemaining(
                child: FeedShimmer(),
              ),
              error: (error, _) => SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'Could not load feed',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      FilledButton.tonal(
                        onPressed: () =>
                            ref.read(feedProvider.notifier).refresh(),
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return const SliverFillRemaining(
                    child: EmptyState(
                      icon: Icons.explore_outlined,
                      title: 'No content yet',
                      subtitle:
                          'Select some interests to start seeing curated content.',
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index >= items.length) {
                        return const Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      final item = items[index];
                      return FeedCard(
                        item: item,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => PostDetailScreen(
                                item: item,
                                onLikeToggle: () {
                                  setState(() {
                                    item.isLiked = !item.isLiked;
                                  });
                                },
                              ),
                            ),
                          );
                        },
                        onLike: () {
                          setState(() {
                            item.isLiked = !item.isLiked;
                          });
                        },
                        onSave: () {
                          ref
                              .read(savedPostsProvider.notifier)
                              .toggleSave(item);
                          setState(() {});
                        },
                      );
                    },
                    childCount: items.length + 1,
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
