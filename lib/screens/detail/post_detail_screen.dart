import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
import '../../models/feed_item.dart';
import '../../providers/saved_posts_provider.dart';

/// A single work, full width, with a museum-style wall label beneath it.
class PostDetailScreen extends ConsumerStatefulWidget {
  const PostDetailScreen({
    super.key,
    required this.item,
    required this.heroTag,
    this.onLikeToggle,
  });

  final FeedItem item;
  final String heroTag;
  final VoidCallback? onLikeToggle;

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  late bool _liked = widget.item.isLiked;

  void _toggleLike() {
    setState(() => _liked = !_liked);
    widget.item.isLiked = _liked;
    widget.onLikeToggle?.call();
  }

  @override
  Widget build(BuildContext context) {
    final g = context.c;
    final item = widget.item;
    final isSaved = ref.watch(savedPostsProvider).any((p) => p.id == item.id);
    final isPhoto = item.sourceName == 'Lorem Picsum';

    final metaLine = [
      if (item.dateText != null && item.dateText!.isNotEmpty) item.dateText!,
      if (item.medium != null && item.medium!.isNotEmpty) item.medium!,
    ].join('  ·  ');

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(Gap.md,
                  MediaQuery.of(context).padding.top + Gap.sm, Gap.lg, Gap.sm),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.arrow_back, color: g.ink),
                    tooltip: 'Back',
                  ),
                  const Spacer(),
                  Text(item.sourceName.toUpperCase(), style: Type.label(g.dim)),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: GestureDetector(
              onDoubleTap: () {
                if (!_liked) _toggleLike();
                HapticFeedback.selectionClick();
              },
              child: Container(
                color: g.surface,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.62,
                ),
                child: InteractiveViewer(
                  minScale: 1,
                  maxScale: 4,
                  child: Hero(
                    tag: widget.heroTag,
                    child: CachedNetworkImage(
                      imageUrl: item.imageUrl,
                      httpHeaders: kImageHeaders,
                      fit: isPhoto ? BoxFit.cover : BoxFit.contain,
                      placeholder: (context, _) => SizedBox(
                        height: 300,
                        child: Center(
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: g.ink),
                        ),
                      ),
                      errorWidget: (context, _, _) => SizedBox(
                        height: 300,
                        child: Center(child: Text('—', style: Type.mono(g.faint))),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(child: Divider(color: g.hairline, height: 1)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(Gap.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: Type.displayM(g.ink)),
                  if (item.artist.isNotEmpty) ...[
                    const SizedBox(height: Gap.sm),
                    Text(item.artist, style: Type.body(g.dim)),
                  ],
                  if (metaLine.isNotEmpty) ...[
                    const SizedBox(height: Gap.sm),
                    Text(metaLine, style: Type.mono(g.faint)),
                  ],
                  const SizedBox(height: Gap.xl),
                  Divider(color: g.hairline, height: 1),
                  const SizedBox(height: Gap.md),
                  Row(
                    children: [
                      _Action(
                        icon: _liked ? Icons.favorite : Icons.favorite_border,
                        label: _liked ? 'Liked' : 'Like',
                        onTap: _toggleLike,
                      ),
                      const SizedBox(width: Gap.xxl),
                      _Action(
                        icon: isSaved ? Icons.bookmark : Icons.bookmark_border,
                        label: isSaved ? 'Saved' : 'Save',
                        onTap: () => ref
                            .read(savedPostsProvider.notifier)
                            .toggleSave(item),
                      ),
                      const Spacer(),
                      _Action(
                        icon: Icons.north_east,
                        label: 'Source',
                        onTap: () {
                          if (item.sourceUrl.isNotEmpty) {
                            launchUrl(Uri.parse(item.sourceUrl),
                                mode: LaunchMode.externalApplication);
                          }
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).padding.bottom + Gap.lg),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action(
      {required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final g = context.c;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Icon(icon, size: 20, color: g.ink),
          const SizedBox(width: Gap.sm),
          Text(label.toUpperCase(), style: Type.label(g.ink)),
        ],
      ),
    );
  }
}
