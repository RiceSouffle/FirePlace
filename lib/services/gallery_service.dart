import 'dart:math';
import '../constants.dart';
import '../models/feed_item.dart';
import '../models/interest.dart';
import 'cat_service.dart';
import 'met_service.dart';
import 'picsum_service.dart';
import 'wikimedia_service.dart';

/// Thrown when every network source failed (offline / all down), so the UI can
/// show a real error + retry instead of a wall of broken images.
class GalleryUnavailable implements Exception {
  const GalleryUnavailable();
}

/// The result of one source fetch: its items, whether the call succeeded, and
/// whether it was a real network source (photo/Picsum is synthetic).
typedef _Res = ({List<FeedItem> items, bool ok, bool networked});

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
  final Map<int, FeedItem?> _objCache = {}; // caches hits and imageless nulls

  Future<List<FeedItem>> fetchFeed({
    required List<Interest> interests,
    int page = 1,
    int perPage = 14,
  }) async {
    final effective = interests.isEmpty
        ? AppConstants.allInterests.take(6).toList()
        : interests;
    // Fresh entropy every call so pull-to-refresh actually re-rolls.
    final random = Random(DateTime.now().microsecondsSinceEpoch ^ (page * 104729));

    final pool = List<Interest>.from(effective)..shuffle(random);
    final chosen = pool.take(5).toList();
    final perInterest = max(2, (perPage / chosen.length).ceil());

    final results = await Future.wait(
      chosen.map((i) => _fetchFor(i, perInterest, random)),
    );

    final networkAttempted = chosen.any((i) => i.source != Source.photo);
    final networkOk = results.any((r) => r.networked && r.ok);
    var items = results.expand((r) => r.items).toList();

    if (items.isEmpty) {
      // Everything failed and we were relying on the network → surface an error.
      if (networkAttempted && !networkOk) throw const GalleryUnavailable();
      // Genuinely empty results → keep the feed populated with photographs.
      items = _picsum.photos(count: perPage);
    }

    final seen = <String>{};
    final deduped = items.where((i) => seen.add(i.id)).toList();
    deduped.shuffle(random);
    return deduped;
  }

  Future<_Res> _fetchFor(Interest i, int count, Random random) async {
    final networked = i.source != Source.photo;
    try {
      switch (i.source) {
        case Source.met:
          return (
            items: await _metForInterest(i, count, random),
            ok: true,
            networked: networked
          );
        case Source.wikimedia:
          return (
            items: await _wiki.search(i.query,
                interestId: i.id,
                category: i.label,
                count: count,
                offset: random.nextInt(24)),
            ok: true,
            networked: networked
          );
        case Source.cats:
          return (items: await _cats.images(count: count), ok: true, networked: networked);
        case Source.photo:
          return (items: _picsum.photos(count: count), ok: true, networked: networked);
      }
    } catch (_) {
      return (items: const <FeedItem>[], ok: false, networked: networked);
    }
  }

  Future<List<FeedItem>> _metForInterest(
      Interest interest, int count, Random random) async {
    final ids = await _idsFor(interest.query);
    if (ids.isEmpty) return const [];
    // Distinct ids, random window, never more than we actually have.
    final n = min(count, ids.length);
    final start = random.nextInt(ids.length);
    final slice = <int>{};
    for (var k = 0; slice.length < n && k < ids.length; k++) {
      slice.add(ids[(start + k) % ids.length]);
    }
    final objs = await Future.wait(slice.map((id) => _objectFor(id, interest)));
    return objs.whereType<FeedItem>().toList();
  }

  Future<FeedItem?> _objectFor(int id, Interest interest) async {
    if (_objCache.containsKey(id)) return _objCache[id];
    try {
      final item = await _met.fetchObject(id,
          interestId: interest.id, category: interest.label);
      _objCache[id] = item; // cache hits and imageless nulls
      return item;
    } catch (_) {
      return null; // don't cache transient fetch failures
    }
  }

  Future<List<int>> _idsFor(String query) async {
    final cached = _idCache[query];
    if (cached != null) return cached;
    final ids = await _met.searchIds(query);
    // Don't cache a transient/failed (empty) search — retry it next time.
    if (ids.isEmpty) return const [];
    final shuffled = List<int>.from(ids)..shuffle(Random(query.hashCode));
    _idCache[query] = shuffled;
    return shuffled;
  }
}
