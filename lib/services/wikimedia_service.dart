import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/feed_item.dart';

/// Search Wikimedia Commons for freely-licensed photographs of any subject —
/// cars, watches, tech, sneakers, aircraft, food… — with real attribution.
class WikimediaService {
  WikimediaService({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  Future<List<FeedItem>> search(
    String query, {
    required String interestId,
    required String category,
    int count = 6,
    int offset = 0,
  }) async {
    final uri = Uri.parse('https://commons.wikimedia.org/w/api.php').replace(
      queryParameters: {
        'action': 'query',
        'format': 'json',
        'generator': 'search',
        'gsrsearch': 'filetype:bitmap $query',
        'gsrnamespace': '6', // File namespace
        'gsrlimit': '$count',
        'gsroffset': '$offset',
        'prop': 'imageinfo',
        'iiprop': 'url|extmetadata|mime',
        'iiurlwidth': '900',
        'origin': '*',
      },
    );

    try {
      final res = await _client.get(uri).timeout(const Duration(seconds: 12));
      if (res.statusCode != 200) return const [];
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final pages = (data['query']?['pages']) as Map<String, dynamic>?;
      if (pages == null) return const [];

      final now = DateTime.now();
      final items = <FeedItem>[];
      for (final entry in pages.values) {
        // Isolate each page so one malformed record can't discard the batch.
        try {
          final page = entry as Map<String, dynamic>;
          final iiList = page['imageinfo'] as List?;
          if (iiList == null || iiList.isEmpty) continue;
          final ii = iiList.first as Map<String, dynamic>;
          final mime = ii['mime'] as String? ?? '';
          if (!mime.startsWith('image/') || mime.contains('svg')) continue;
          final thumb = ii['thumburl'] as String?;
          if (thumb == null || thumb.isEmpty) continue;

          final em = ii['extmetadata'] as Map<String, dynamic>? ?? {};
          items.add(FeedItem(
            id: 'wiki_${page['pageid']}',
            imageUrl: thumb,
            thumbnailUrl: thumb,
            title: _cleanTitle(page['title'] as String? ?? ''),
            artist: _stripHtml(_asString(em['Artist'])),
            dateText: _year(_asString(em['DateTimeOriginal'])),
            medium: category,
            category: category,
            sourceName: 'Wikimedia Commons',
            sourceUrl:
                'https://commons.wikimedia.org/?curid=${page['pageid']}',
            interestId: interestId,
            width: (ii['thumbwidth'] as num?)?.toInt() ?? 900,
            height: (ii['thumbheight'] as num?)?.toInt() ?? 900,
            fetchedAt: now,
          ));
        } catch (_) {
          continue;
        }
      }
      return items;
    } catch (_) {
      return const [];
    }
  }

  /// "File:Porsche 911.jpg" -> "Porsche 911"; blanks camera-filename titles.
  static String _cleanTitle(String raw) {
    var t = raw.replaceFirst(RegExp(r'^File:'), '');
    t = t.replaceFirst(RegExp(r'\.\w{2,4}$'), '');
    t = t.replaceAll('_', ' ').trim();
    // Strip trailing camera-code parentheticals, e.g. "… Berlin (1X7A38B7)".
    t = t.replaceAll(RegExp(r'\s*\([A-Z0-9][A-Z0-9 _\-]{2,}\)\s*$'), '').trim();
    // Drop machine filenames (DSC 1234, IMG 4321, long digit runs).
    if (RegExp(r'\b(DSC|DSCF|IMG|IMGP|P\d{6,}|DSCN)\b', caseSensitive: false)
            .hasMatch(t) ||
        RegExp(r'^\d').hasMatch(t) ||
        !RegExp(r'[a-z]{3}').hasMatch(t)) {
      return '';
    }
    return t.length > 80 ? '${t.substring(0, 77)}…' : t;
  }

  /// Safely reads an extmetadata `{value: ...}` node that may be a non-Map or
  /// hold a non-String value.
  static String? _asString(dynamic node) {
    if (node is Map && node['value'] is String) return node['value'] as String;
    if (node is String) return node;
    return null;
  }

  static String _stripHtml(String? html) {
    if (html == null) return '';
    var s = html.replaceAll(RegExp(r'<[^>]*>'), ' ');
    s = s.replaceAll('&amp;', '&').replaceAll('&nbsp;', ' ');
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (s.toLowerCase() == 'unknown' || s.length > 40) return '';
    return s;
  }

  static String? _year(String? raw) {
    if (raw == null) return null;
    final m = RegExp(r'(1[5-9]\d{2}|20\d{2})').firstMatch(raw);
    return m?.group(0);
  }
}
