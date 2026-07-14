import 'content_source.dart';

class FeedItem {
  final String id;
  final String imageUrl;
  final String thumbnailUrl;
  final String? title;
  final String? description;
  final ContentSource source;
  final String authorName;
  final String? authorUrl;
  final String sourceUrl;
  final String interestId;

  /// The bare subreddit name (e.g. `carporn`) for the museum-label attribution.
  final String subreddit;
  final int width;
  final int height;
  final String? avgColor;
  final DateTime fetchedAt;

  /// When the post was created on Reddit, for a genuine "time ago" in Detail.
  final DateTime? createdUtc;
  bool isLiked;
  bool isSaved;

  FeedItem({
    required this.id,
    required this.imageUrl,
    required this.thumbnailUrl,
    this.title,
    this.description,
    required this.source,
    required this.authorName,
    this.authorUrl,
    required this.sourceUrl,
    required this.interestId,
    this.subreddit = '',
    required this.width,
    required this.height,
    this.avgColor,
    required this.fetchedAt,
    this.createdUtc,
    this.isLiked = false,
    this.isSaved = false,
  });

  double get aspectRatio => width > 0 && height > 0 ? width / height : 1.0;
}
