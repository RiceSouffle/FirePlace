import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../design/theme.dart';
import '../../../design/tokens.dart';
import '../../../models/feed_item.dart';
import '../../../providers/saved_posts_provider.dart';
import '../../../widgets/plate.dart';
import '../../detail/post_detail_screen.dart';

/// The saved wall — a tight contact sheet. Tap opens; long-press removes.
class SavedGrid extends ConsumerWidget {
  const SavedGrid({super.key, required this.posts});
  final List<FeedItem> posts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final g = context.c;
    if (posts.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(Gap.xxl),
        decoration: BoxDecoration(border: Border.all(color: g.hairline)),
        alignment: Alignment.center,
        child: Text('NOTHING SAVED YET', style: Type.label(g.faint)),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: Gap.xs,
        crossAxisSpacing: Gap.xs,
      ),
      itemCount: posts.length,
      itemBuilder: (context, i) {
        final post = posts[i];
        return GestureDetector(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => PostDetailScreen(
              item: post,
              heroTag: 'saved_${post.id}',
              onLikeToggle: () => post.isLiked = !post.isLiked,
            ),
          )),
          onLongPress: () => _confirmRemove(context, ref, post),
          child: Plate(item: post, heroTag: 'saved_${post.id}', thumb: true),
        );
      },
    );
  }

  void _confirmRemove(BuildContext context, WidgetRef ref, FeedItem post) {
    final g = context.c;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Remove?', style: Type.title(g.ink)),
        content: Text('Take this off your saved wall.', style: Type.body(g.dim)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('KEEP', style: Type.label(g.dim)),
          ),
          TextButton(
            onPressed: () {
              ref.read(savedPostsProvider.notifier).toggleSave(post);
              Navigator.pop(ctx);
            },
            child: Text('REMOVE', style: Type.label(g.ink)),
          ),
        ],
      ),
    );
  }
}
