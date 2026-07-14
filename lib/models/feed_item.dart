/// A single work in the feed — a museum artwork or a photograph. The same shape
/// carries both; [sourceName] and [category] say which.
class FeedItem {
  final String id;
  final String imageUrl;
  final String thumbnailUrl;
  final String title;

  /// Artist or photographer. May be empty (e.g. "Unknown", anonymous photos).
  final String artist;

  /// Display date, e.g. "1936" or "c. 1560". Free text from the source.
  final String? dateText;

  /// Medium / description, e.g. "Oil on canvas".
  final String? medium;

  /// The category this came in under, e.g. "Painting", "Photograph".
  final String category;

  /// Human collection name, e.g. "The Met" or "Lorem Picsum".
  final String sourceName;

  /// A link to the work's page on the source.
  final String sourceUrl;

  /// The id of the interest/category used to fetch it.
  final String interestId;

  final int width;
  final int height;
  final DateTime fetchedAt;
  bool isLiked;
  bool isSaved;

  FeedItem({
    required this.id,
    required this.imageUrl,
    required this.thumbnailUrl,
    required this.title,
    this.artist = '',
    this.dateText,
    this.medium,
    this.category = '',
    required this.sourceName,
    required this.sourceUrl,
    this.interestId = '',
    required this.width,
    required this.height,
    required this.fetchedAt,
    this.isLiked = false,
    this.isSaved = false,
  });

  double get aspectRatio => width > 0 && height > 0 ? width / height : 1.0;

  /// Whether there's an artist/date to credit (vs. source-only content).
  bool get hasCredit =>
      artist.isNotEmpty || (dateText != null && dateText!.isNotEmpty);

  /// The wall-label byline, e.g. "Claude Monet · 1906". Empty when uncredited.
  String get byline {
    final parts = <String>[];
    if (artist.isNotEmpty) parts.add(artist);
    if (dateText != null && dateText!.isNotEmpty) parts.add(dateText!);
    return parts.join('  ·  ');
  }
}
