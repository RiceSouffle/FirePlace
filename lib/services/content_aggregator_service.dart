import 'dart:math';
import '../models/interest.dart';
import '../models/feed_item.dart';
import 'reddit_service.dart';

class _CacheEntry {
  final List<FeedItem> items;
  final DateTime expiry;
  _CacheEntry(this.items, this.expiry);
  bool get isExpired => DateTime.now().isAfter(expiry);
}

class ContentAggregatorService {
  final RedditService _reddit;
  final Map<String, _CacheEntry> _cache = {};

  ContentAggregatorService({
    required RedditService reddit,
  }) : _reddit = reddit;

  Future<List<FeedItem>> fetchFeed({
    required List<Interest> interests,
    int page = 1,
    int perPage = 15,
  }) async {
    final random = Random();
    final List<Future<List<FeedItem>>> futures = [];

    for (final interest in interests) {
      // Pick 2 random subreddits per interest for variety
      final subs = List<String>.from(interest.subreddits)..shuffle(random);
      final picked = subs.take(2);

      for (final sub in picked) {
        futures.add(_cachedFetch(
          'reddit_${sub}_$page',
          () => _reddit.fetchSubredditImages(
            subreddit: sub,
            interestId: interest.id,
            limit: perPage,
          ),
        ));
      }
    }

    final results = await Future.wait(futures);
    final allItems = results.expand((list) => list).toList();

    allItems.shuffle(random);
    final seen = <String>{};
    return allItems.where((item) => seen.add(item.id)).toList();
  }

  Future<List<FeedItem>> _cachedFetch(
    String key,
    Future<List<FeedItem>> Function() fetcher,
  ) async {
    final cached = _cache[key];
    if (cached != null && !cached.isExpired) {
      return cached.items;
    }

    try {
      final items = await fetcher();
      _cache[key] = _CacheEntry(
        items,
        DateTime.now().add(const Duration(minutes: 10)),
      );
      return items;
    } catch (_) {
      return [];
    }
  }
}
