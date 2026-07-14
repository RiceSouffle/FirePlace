import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/feed_item.dart';

/// The Cat API (keyless) — a stream of cat photographs. Because everyone likes
/// cats.
class CatService {
  CatService({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  Future<List<FeedItem>> images({int count = 6}) async {
    final uri = Uri.parse('https://api.thecatapi.com/v1/images/search')
        .replace(queryParameters: {'limit': '$count'});
    try {
      final res = await _client.get(uri).timeout(const Duration(seconds: 12));
      if (res.statusCode != 200) return const [];
      // Throttled/errored responses can be a JSON object, not an array.
      final decoded = jsonDecode(res.body);
      if (decoded is! List) return const [];
      final now = DateTime.now();
      final items = <FeedItem>[];
      for (final raw in decoded) {
        if (raw is! Map<String, dynamic>) continue;
        final c = raw;
        final url = c['url'] as String? ?? '';
        if (url.isEmpty || url.toLowerCase().endsWith('.gif')) continue;
        items.add(FeedItem(
          id: 'cat_${c['id']}',
          imageUrl: url,
          thumbnailUrl: url,
          title: '',
          artist: '',
          medium: 'Cat',
          category: 'Cats',
          sourceName: 'The Cat API',
          sourceUrl: url,
          interestId: 'cats',
          width: (c['width'] as num?)?.toInt() ?? 800,
          height: (c['height'] as num?)?.toInt() ?? 800,
          fetchedAt: now,
        ));
      }
      return items;
    } catch (_) {
      return const [];
    }
  }
}
