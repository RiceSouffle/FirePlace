import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';
import '../../design/ember_theme.dart';
import '../../design/ember_tokens.dart';
import '../../models/feed_item.dart';
import '../../providers/saved_posts_provider.dart';
import '../../widgets/ember_burst.dart';
import '../../widgets/museum_label.dart';

/// The print steps off the wall: a hero-lifted, pinch-zoomable full-bleed image
/// with the title *promoted* from utilitarian Inter into a Fraunces pull-quote —
/// a small luxury that rewards tapping in.
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
    final e = context.ember;
    final item = widget.item;
    final isSaved =
        ref.watch(savedPostsProvider).any((p) => p.id == item.id);
    final title = item.title ?? '';

    return Scaffold(
      backgroundColor: e.inkFrame,
      body: Stack(
        fit: StackFit.expand,
        children: [
          DoubleTapEmber(
            liked: _liked,
            heartSize: 128,
            onLikeRequested: _toggleLike,
            child: Center(
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 4,
                child: Hero(
                  tag: widget.heroTag,
                  child: CachedNetworkImage(
                    imageUrl: item.imageUrl,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => Center(
                      child: CircularProgressIndicator(
                          color: e.coral, strokeWidth: 2),
                    ),
                    errorWidget: (context, url, error) => Icon(
                      Icons.local_fire_department_outlined,
                      color: e.textFaint,
                      size: 48,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Top scrim for the back button.
          const _TopScrim(),

          // Bottom info panel.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _InfoPanel(
              item: item,
              title: title,
              liked: _liked,
              isSaved: isSaved,
              onLike: _toggleLike,
              onSave: () =>
                  ref.read(savedPostsProvider.notifier).toggleSave(item),
            ),
          ),

          // Back button.
          Positioned(
            top: MediaQuery.of(context).padding.top + Insets.sm,
            left: Insets.sm,
            child: _CircleButton(
              icon: Icons.arrow_back,
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopScrim extends StatelessWidget {
  const _TopScrim();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black.withValues(alpha: 0.5), Colors.transparent],
          ),
        ),
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({
    required this.item,
    required this.title,
    required this.liked,
    required this.isSaved,
    required this.onLike,
    required this.onSave,
  });

  final FeedItem item;
  final String title;
  final bool liked;
  final bool isSaved;
  final VoidCallback onLike;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final e = context.ember;
    return Container(
      padding: EdgeInsets.fromLTRB(
        Insets.xxl,
        Insets.xxxl,
        Insets.xxl,
        MediaQuery.of(context).padding.bottom + Insets.xl,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withValues(alpha: 0.9),
            Colors.black.withValues(alpha: 0.55),
            Colors.transparent,
          ],
          stops: const [0, 0.7, 1],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title.isNotEmpty)
            Text(
              title,
              style: EmberText.serifQuote(const Color(0xFFF7EFE4)),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          const SizedBox(height: Insets.md),
          Row(
            children: [
              Expanded(
                child: MuseumLabel(
                  item: item,
                  color: const Color(0xFFCDBFAE),
                ),
              ),
              if (item.createdUtc != null) ...[
                const SizedBox(width: Insets.sm),
                Text(
                  timeago.format(item.createdUtc!),
                  style: EmberText.museum(const Color(0xFF93877A))
                      .copyWith(letterSpacing: 0.4),
                ),
              ],
            ],
          ),
          const SizedBox(height: Insets.lg),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.12)),
          const SizedBox(height: Insets.md),
          Row(
            children: [
              _Action(
                icon: liked ? Icons.favorite : Icons.favorite_border,
                label: 'Like',
                color: liked ? e.likeColor : Colors.white,
                onTap: onLike,
              ),
              const SizedBox(width: Insets.xxl),
              _Action(
                icon: isSaved ? Icons.bookmark : Icons.bookmark_border,
                label: 'Save',
                color: isSaved ? e.saveColor : Colors.white,
                onTap: onSave,
              ),
              const Spacer(),
              _Action(
                icon: Icons.open_in_new,
                label: 'Reddit',
                color: Colors.white,
                onTap: () {
                  if (item.sourceUrl.isNotEmpty) {
                    launchUrl(Uri.parse(item.sourceUrl),
                        mode: LaunchMode.externalApplication);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: Insets.xs + 2),
          Text(
            label.toUpperCase(),
            style: EmberText.museum(color.withValues(alpha: 0.9)),
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.35),
      shape: const CircleBorder(),
      child: Tooltip(
        message: 'Back',
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(Insets.sm + 2),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
        ),
      ),
    );
  }
}
