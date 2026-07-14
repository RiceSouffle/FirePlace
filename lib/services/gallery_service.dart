import 'dart:math';
import '../constants.dart';
import '../models/feed_item.dart';
import '../models/interest.dart';
import 'cat_service.dart';
import 'met_service.dart';
import 'picsum_service.dart';
import 'wikimedia_service.dart';

/// Blends works from every source into one feed, routing each followed category
/// to the right place: The Met (fine art), Wikimedia Commons (cars, watches,
/// tech…), The Cat API (cats), and Picsum (photography).
class GalleryService {
  GalleryService({
    required MetService met,
    required PicsumService picsum,
    required WikimediaService wikimedia,
    required CatService cats,
  })  : _met = met,
        _picsum = picsum,
        _wiki = wikimedia,
        _cats = cats;

  final MetService _met;
  final PicsumService _picsum;
  final WikimediaService _wiki;
  final CatService _cats;
  final Map<String, List<int>> _idCache = {};

  Future<List<FeedItem>> fetchFeed({
    required List<Interest> interests,
    int page = 1,
    int perPage = 14,
  }) async {
    final effective = interests.isEmpty
        ? AppConstants.allInterests.take(6).toList()
        : interests;
    final random = Random(page * 104729 + 17);

    // Sample up to 5 categories per page so parallel calls stay bounded.
    final pool = List<Interest>.from(effective)..shuffle(random);
    final chosen = pool.take(5).toList();
    final perInterest = max(2, (perPage / chosen.length).ceil());

    final results = await Future.wait(
      chosen.map((i) => _fetchFor(i, page, perInterest)),
    );
    var items = results.expand((e) => e).toList();

    // Never leave the feed blank (offline / all sources flaky).
    if (items.isEmpty) items = _picsum.photos(count: perPage);

    final seen = <String>{};
    final deduped = items.where((i) => seen.add(i.id)).toList();
    deduped.shuffle(random);
    return deduped;
  }

  Future<List<FeedItem>> _fetchFor(Interest i, int page, int count) async {
    try {
      switch (i.source) {
        case Source.met:
          return await _metForInterest(i, page, count);
        case Source.wikimedia:
          return await _wiki.search(i.query,
              interestId: i.id,
              category: i.label,
              count: count,
              offset: (page - 1) * count);
        case Source.cats:
          return await _cats.images(count: count);
        case Source.photo:
          return _picsum.photos(count: count);
      }
    } catch (_) {
      return const [];
    }
  }

  Future<List<FeedItem>> _metForInterest(
      Interest interest, int page, int count) async {
    final ids = await _idsFor(interest.query);
    if (ids.isEmpty) return const [];
    final start = ((page - 1) * count) % ids.length;
    final slice = [
      for (var i = 0; i < count; i++) ids[(start + i) % ids.length],
    ];
    final objs = await Future.wait(
      slice.map((id) => _met
          .fetchObject(id, interestId: interest.id, category: interest.label)
          .catchError((_) => null)),
    );
    return objs.whereType<FeedItem>().toList();
  }

  Future<List<int>> _idsFor(String query) async {
    final cached = _idCache[query];
    if (cached != null) return cached;
    final ids = await _met.searchIds(query);
    final shuffled = List<int>.from(ids)..shuffle(Random(query.hashCode));
    _idCache[query] = shuffled;
    return shuffled;
  }
}
