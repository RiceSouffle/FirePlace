import 'dart:math';
import '../models/feed_item.dart';

/// Photography via Lorem Picsum. The `list` API groups photos by shoot (page 1
/// is a dozen near-identical laptop shots), so we use the seeded-image endpoint
/// instead — each unique seed returns a different photo from the whole catalogue,
/// giving real variety. No key, no request needed to build the URLs.
class PicsumService {
  final _rng = Random();

  List<FeedItem> photos({int count = 8}) {
    final now = DateTime.now();
    return List.generate(count, (_) {
      final seed = 'fp${_rng.nextInt(1 << 32)}';
      return FeedItem(
        id: 'picsum_$seed',
        imageUrl: 'https://picsum.photos/seed/$seed/900/900',
        thumbnailUrl: 'https://picsum.photos/seed/$seed/450/450',
        title: '',
        artist: '',
        dateText: null,
        medium: 'Photograph',
        category: 'Photograph',
        sourceName: 'Lorem Picsum',
        sourceUrl: 'https://picsum.photos',
        interestId: 'photography',
        width: 900,
        height: 900,
        fetchedAt: now,
      );
    });
  }
}
