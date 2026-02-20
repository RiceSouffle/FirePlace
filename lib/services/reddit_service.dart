import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/feed_item.dart';
import '../models/content_source.dart';

class RedditService {
  final String _userAgent = dotenv.env['REDDIT_USER_AGENT'] ?? 'FirePlace/1.0';

  Future<List<FeedItem>> fetchSubredditImages({
    required String subreddit,
    required String interestId,
    int limit = 25,
    String? after,
  }) async {
    final queryParams = <String, String>{
      'limit': '$limit',
      'raw_json': '1',
    };
    if (after != null) queryParams['after'] = after;

    final uri = Uri.parse(
      'https://www.reddit.com/r/$subreddit/hot.json',
    ).replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: {
      'User-Agent': _userAgent,
    });

    if (response.statusCode != 200) {
      throw Exception('Reddit API error: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    final children = data['data']['children'] as List;

    return children
        .map((child) => child['data'] as Map<String, dynamic>)
        .where(_isImagePost)
        .map((post) => FeedItem(
              id: 'reddit_${post['id']}',
              imageUrl: _extractImageUrl(post),
              thumbnailUrl: _decodeThumbnail(post['thumbnail']),
              title: post['title'] ?? '',
              source: ContentSource.reddit,
              authorName: 'u/${post['author']}',
              authorUrl: 'https://reddit.com/u/${post['author']}',
              sourceUrl: 'https://reddit.com${post['permalink']}',
              interestId: interestId,
              width: post['preview']?['images']?[0]?['source']?['width'] ?? 800,
              height: post['preview']?['images']?[0]?['source']?['height'] ?? 800,
              fetchedAt: DateTime.now(),
            ))
        .toList();
  }

  bool _isImagePost(Map<String, dynamic> post) {
    final url = post['url'] as String? ?? '';
    final hint = post['post_hint'] as String? ?? '';
    return hint == 'image' ||
        url.endsWith('.jpg') ||
        url.endsWith('.png') ||
        url.endsWith('.jpeg') ||
        url.contains('i.redd.it') ||
        url.contains('i.imgur.com');
  }

  String _extractImageUrl(Map<String, dynamic> post) {
    final preview = post['preview']?['images']?[0]?['source']?['url'];
    if (preview != null) {
      return (preview as String).replaceAll('&amp;', '&');
    }
    return post['url'] ?? '';
  }

  String _decodeThumbnail(String? thumb) {
    if (thumb == null ||
        thumb == 'self' ||
        thumb == 'default' ||
        thumb == 'nsfw' ||
        thumb.isEmpty) {
      return '';
    }
    return thumb.replaceAll('&amp;', '&');
  }
}
