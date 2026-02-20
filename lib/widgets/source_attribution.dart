import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/feed_item.dart';

class SourceAttribution extends StatelessWidget {
  final FeedItem item;

  const SourceAttribution({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final url = item.authorUrl ?? item.sourceUrl;
        if (url.isNotEmpty) {
          launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        }
      },
      child: Row(
        children: [
          const Icon(Icons.forum_outlined, size: 14, color: Color(0xFFFF4500)),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              '${item.authorName} on Reddit',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
