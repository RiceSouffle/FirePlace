import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/text_utils.dart';
import '../design/ember_theme.dart';
import '../models/feed_item.dart';

/// The recurring attribution fingerprint: `PHOTOGRAPH · u/name · r/sub`, set in
/// tracked all-caps Inter. Tapping opens the author on Reddit. This single motif
/// appears on every surface an image does.
class MuseumLabel extends StatelessWidget {
  const MuseumLabel({
    super.key,
    required this.item,
    this.color,
    this.kind = 'PHOTOGRAPH',
    this.tappable = true,
  });

  final FeedItem item;
  final Color? color;
  final String kind;
  final bool tappable;

  @override
  Widget build(BuildContext context) {
    final e = context.ember;
    final text = Text(
      museumLabel(
        author: item.authorName,
        subreddit: item.subreddit,
        kind: kind,
      ),
      style: EmberText.museum(color ?? e.textFaint),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    if (!tappable) return text;

    return GestureDetector(
      onTap: () {
        final url = item.authorUrl ?? item.sourceUrl;
        if (url.isNotEmpty) {
          launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        }
      },
      child: text,
    );
  }
}
