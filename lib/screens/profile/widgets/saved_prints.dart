import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../design/ember_theme.dart';
import '../../../design/ember_tokens.dart';
import '../../../models/feed_item.dart';
import '../../../providers/saved_posts_provider.dart';
import '../../../widgets/framed_photo.dart';
import '../../detail/post_detail_screen.dart';

/// The saved collection as a matted masonry wall. Tap opens the print; long-press
/// offers to take it down.
class SavedPrints extends ConsumerWidget {
  const SavedPrints({super.key, required this.posts});
  final List<FeedItem> posts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final e = context.ember;
    if (posts.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(Insets.xxl),
        decoration: BoxDecoration(
          color: e.surface1,
          borderRadius: Radii.cardBorder,
          border: Border.all(color: e.hairline),
        ),
        child: Column(
          children: [
            Icon(Icons.bookmark_border, size: 32, color: e.textFaint),
            const SizedBox(height: Insets.sm),
            Text('Nothing saved yet',
                style: EmberText.label(e.textMuted)),
            const SizedBox(height: Insets.xs),
            Text('Tap the bookmark on a print to keep it here.',
                style: EmberText.body(e.textFaint),
                textAlign: TextAlign.center),
          ],
        ),
      );
    }

    return MasonryGridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: Insets.sm,
      crossAxisSpacing: Insets.sm,
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return GestureDetector(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PostDetailScreen(
                item: post,
                heroTag: 'saved_${post.id}',
                onLikeToggle: () => post.isLiked = !post.isLiked,
              ),
            ),
          ),
          onLongPress: () => _confirmRemove(context, ref, post),
          child: AspectRatio(
            aspectRatio: post.aspectRatio.clamp(0.7, 1.4),
            child: FramedPhoto(
              imageUrl: post.thumbnailUrl.isNotEmpty
                  ? post.thumbnailUrl
                  : post.imageUrl,
              heroTag: 'saved_${post.id}',
              borderRadius: BorderRadius.circular(Radii.control),
              semanticLabel: post.title?.isNotEmpty == true
                  ? post.title
                  : 'Saved photograph',
            ),
          ),
        );
      },
    );
  }

  void _confirmRemove(BuildContext context, WidgetRef ref, FeedItem post) {
    final e = context.ember;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Take it down?', style: EmberText.title(e.textStrong)),
        content: Text('Remove this print from your saved wall.',
            style: EmberText.body(e.textMuted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Keep', style: EmberText.label(e.textMuted)),
          ),
          TextButton(
            onPressed: () {
              ref.read(savedPostsProvider.notifier).toggleSave(post);
              Navigator.pop(ctx);
            },
            child: Text('Remove', style: EmberText.label(e.rose)),
          ),
        ],
      ),
    );
  }
}
