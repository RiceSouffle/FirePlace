import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../design/ember_theme.dart';
import '../../design/ember_tokens.dart';
import '../../models/feed_item.dart';
import '../../providers/feed_provider.dart';
import '../../providers/saved_posts_provider.dart';
import '../../widgets/ember_controls.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/hearth.dart';
import '../../widgets/print_card.dart';
import '../../widgets/warm_shimmer.dart';
import '../detail/post_detail_screen.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final _scrollController = ScrollController();
  bool _loadingMore = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 5) return 'Still up — the embers are low';
    if (hour < 12) return 'Good morning — the fire’s fresh';
    if (hour < 17) return 'Good afternoon — settle in';
    if (hour < 22) return 'Good evening — the fire’s warm';
    return 'Winding down — one last look';
  }

  Future<void> _loadMore() async {
    setState(() => _loadingMore = true);
    await ref.read(feedProvider.notifier).loadMore();
    if (mounted) setState(() => _loadingMore = false);
  }

  void _openDetail(FeedItem item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PostDetailScreen(
          item: item,
          heroTag: 'feed_${item.id}',
          onLikeToggle: () => setState(() => item.isLiked = !item.isLiked),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final e = context.ember;
    final reduce = reduceMotion(context);
    final feedState = ref.watch(feedProvider);
    final saved = ref.watch(savedPostsProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.read(feedProvider.notifier).refresh(),
        color: e.coral,
        backgroundColor: e.surface2,
        edgeOffset: 120,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(child: _header(context, e)),
            feedState.when(
              loading: () => const SliverToBoxAdapter(child: FeedSkeleton()),
              error: (error, _) => SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: Icons.cloud_off,
                  title: 'The fire won’t catch',
                  subtitle:
                      'We couldn’t reach the feed. Check your connection and try again.',
                  action: EmberButton(
                    label: 'Try again',
                    icon: Icons.refresh,
                    expand: false,
                    onPressed: () =>
                        ref.read(feedProvider.notifier).refresh(),
                  ),
                ),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(
                      icon: Icons.local_fire_department_outlined,
                      title: 'No kindling yet',
                      subtitle:
                          'Choose a few interests in Your Hearth and we’ll lay the fire.',
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: Insets.xl),
                  sliver: SliverList.builder(
                    itemCount: items.length + 1,
                    itemBuilder: (context, index) {
                      if (index == items.length) {
                        return _EndCard(
                          loading: _loadingMore,
                          onMore: _loadMore,
                          seen: items.length,
                        );
                      }
                      final item = items[index];
                      final card = PrintCard(
                        item: item,
                        heroTag: 'feed_${item.id}',
                        isSaved: saved.any((p) => p.id == item.id),
                        onTap: () => _openDetail(item),
                        onLike: () =>
                            setState(() => item.isLiked = !item.isLiked),
                        onSave: () => ref
                            .read(savedPostsProvider.notifier)
                            .toggleSave(item),
                      );
                      if (reduce) return card;
                      return card
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .slideY(
                            begin: 0.12,
                            duration: 400.ms,
                            curve: Motion.ember,
                          );
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

  Widget _header(BuildContext context, EmberColors e) {
    final topPad = MediaQuery.of(context).padding.top;
    return Stack(
      children: [
        const Positioned(
          top: -40,
          left: 0,
          right: 0,
          height: 240,
          child: HearthGlow(intensity: 0.75, focal: Alignment(-0.3, 0.2)),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
              Insets.xl, topPad + Insets.xxxl, Insets.xl, Insets.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.local_fire_department, color: e.coral, size: 22),
                  const SizedBox(width: Insets.sm),
                  Text('FIREPLACE',
                      style: EmberText.museum(e.textMuted)
                          .copyWith(letterSpacing: 3)),
                ],
              ),
              const SizedBox(height: Insets.md),
              Text(_greeting, style: EmberText.displayL(e.textStrong)),
            ],
          ),
        ),
      ],
    );
  }
}

/// The designed end of a curated batch — a calm, natural stopping point that
/// replaces bottomless scroll. Loading more is a deliberate choice, not a reflex.
class _EndCard extends StatelessWidget {
  const _EndCard({
    required this.loading,
    required this.onMore,
    required this.seen,
  });

  final bool loading;
  final VoidCallback onMore;
  final int seen;

  @override
  Widget build(BuildContext context) {
    final e = context.ember;
    return Padding(
      padding: const EdgeInsets.only(
          top: Insets.sm, bottom: Insets.giant),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: e.hairline),
            ),
            child: Icon(Icons.local_fire_department_outlined,
                color: e.textFaint, size: 22),
          ),
          const SizedBox(height: Insets.lg),
          Text("That’s the batch",
              style: EmberText.displayM(e.textStrong),
              textAlign: TextAlign.center),
          const SizedBox(height: Insets.sm),
          Text(
            'You’ve looked through $seen prints. A good place to pause —\nor add a log if you’d like a little more.',
            style: EmberText.body(e.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Insets.xl),
          loading
              ? SizedBox(
                  height: 32,
                  width: 32,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: e.coral),
                )
              : EmberButton(
                  label: 'Add a log to the fire',
                  icon: Icons.add,
                  expand: false,
                  glow: 0.5,
                  onPressed: onMore,
                ),
        ],
      ),
    );
  }
}
