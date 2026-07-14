import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/feed_item.dart';

/// Client for The Metropolitan Museum of Art's open collection API (no key).
///
/// Search returns a list of object ids; each object is fetched individually for
/// its image and wall-label metadata. Objects without an image are skipped.
class MetService {
  MetService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const _base = 'https://collectionapi.metmuseum.org/public/collection/v1';

  Future<List<int>> searchIds(String query) async {
    final uri = Uri.parse('$_base/search').replace(queryParameters: {
      'q': query,
      'hasImages': 'true',
    });
    // The Met occasionally returns an empty body under load; one quick retry.
    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        final res =
            await _client.get(uri).timeout(const Duration(seconds: 12));
        if (res.statusCode == 200 && res.body.isNotEmpty) {
          final data = jsonDecode(res.body) as Map<String, dynamic>;
          final ids = data['objectIDs'];
          if (ids is List && ids.isNotEmpty) return ids.cast<int>();
        }
      } catch (_) {
        // fall through to retry
      }
    }
    return const [];
  }

  Future<FeedItem?> fetchObject(
    int id, {
    required String interestId,
    required String category,
  }) async {
    final res = await _client
        .get(Uri.parse('$_base/objects/$id'))
        .timeout(const Duration(seconds: 12));
    if (res.statusCode != 200) return null;
    final o = jsonDecode(res.body) as Map<String, dynamic>;

    final image = (o['primaryImageSmall'] as String?) ?? '';
    if (image.isEmpty) return null;

    final title = ((o['title'] as String?) ?? '').trim();
    return FeedItem(
      id: 'met_$id',
      imageUrl: image,
      thumbnailUrl: image,
      title: title.isEmpty ? 'Untitled' : title,
      artist: ((o['artistDisplayName'] as String?) ?? '').trim(),
      dateText: ((o['objectDate'] as String?) ?? '').trim(),
      medium: ((o['medium'] as String?) ?? '').trim(),
      category: category,
      sourceName: 'The Met',
      sourceUrl: (o['objectURL'] as String?) ?? '',
      interestId: interestId,
      // The Met exposes no pixel dimensions; works are shown in uniform frames.
      width: 1000,
      height: 1000,
      fetchedAt: DateTime.now(),
    );
  }
}
