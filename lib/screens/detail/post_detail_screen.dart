import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/feed_item.dart';
import '../../providers/saved_posts_provider.dart';

class PostDetailScreen extends ConsumerStatefulWidget {
  final FeedItem item;
  final VoidCallback? onLikeToggle;

  const PostDetailScreen({
    super.key,
    required this.item,
    this.onLikeToggle,
  });

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _heartController;
  late Animation<double> _heartScale;
  bool _showHeart = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _heartScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.4)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.4, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticIn)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.0),
        weight: 10,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 20,
      ),
    ]).animate(_heartController);

    _heartController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _showHeart = false);
        _heartController.reset();
      }
    });
  }

  @override
  void dispose() {
    _heartController.dispose();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    super.dispose();
  }

  void _onDoubleTap() {
    if (!widget.item.isLiked) {
      widget.onLikeToggle?.call();
      setState(() {});
    }
    setState(() => _showHeart = true);
    _heartController.forward(from: 0.0);
  }

  String _sourceName() => 'Reddit';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final item = widget.item;
    final isSaved = ref.watch(savedPostsProvider).any((p) => p.id == item.id);

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onDoubleTap: _onDoubleTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Full-screen image with interactive viewer for pinch-to-zoom
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: CachedNetworkImage(
                  imageUrl: item.imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(color: Colors.white54),
                  ),
                  errorWidget: (context, url, error) => const Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      size: 64,
                      color: Colors.white38,
                    ),
                  ),
                ),
              ),
            ),

            // Top gradient for back button visibility
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 120,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Bottom info panel
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(
                  16,
                  24,
                  16,
                  MediaQuery.of(context).padding.bottom + 16,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.85),
                      Colors.black.withValues(alpha: 0.4),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.7, 1.0],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (item.title != null && item.title!.isNotEmpty)
                      Text(
                        item.title!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        final url = item.authorUrl ?? item.sourceUrl;
                        if (url.isNotEmpty) {
                          launchUrl(Uri.parse(url),
                              mode: LaunchMode.externalApplication);
                        }
                      },
                      child: Text(
                        '${item.authorName} on ${_sourceName()}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Action buttons row
                    Row(
                      children: [
                        _ActionButton(
                          icon: item.isLiked
                              ? Icons.favorite
                              : Icons.favorite_outline,
                          label: 'Like',
                          color: item.isLiked ? Colors.red : Colors.white,
                          onTap: () {
                            widget.onLikeToggle?.call();
                            setState(() {});
                          },
                        ),
                        const SizedBox(width: 24),
                        _ActionButton(
                          icon: isSaved
                              ? Icons.bookmark
                              : Icons.bookmark_outline,
                          label: 'Save',
                          color: isSaved
                              ? theme.colorScheme.primary
                              : Colors.white,
                          onTap: () {
                            ref
                                .read(savedPostsProvider.notifier)
                                .toggleSave(item);
                          },
                        ),
                        const SizedBox(width: 24),
                        _ActionButton(
                          icon: Icons.open_in_new,
                          label: 'Source',
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
              ),
            ),

            // Back button
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 8,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black26,
                ),
              ),
            ),

            // Double-tap heart animation
            if (_showHeart)
              Center(
                child: AnimatedBuilder(
                  animation: _heartScale,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _heartScale.value,
                      child: child,
                    );
                  },
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 120,
                    shadows: [
                      Shadow(blurRadius: 30, color: Colors.black38),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color.withValues(alpha: 0.9),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
