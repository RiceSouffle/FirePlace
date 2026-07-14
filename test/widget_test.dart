import 'package:flutter_test/flutter_test.dart';
import 'package:fireplace/models/feed_item.dart';

FeedItem _item({String artist = '', String? date, String source = 'The Met'}) {
  return FeedItem(
    id: 'x',
    imageUrl: '',
    thumbnailUrl: '',
    title: 'Work',
    artist: artist,
    dateText: date,
    sourceName: source,
    sourceUrl: '',
    width: 1000,
    height: 800,
    fetchedAt: DateTime(2024),
  );
}

void main() {
  group('FeedItem.byline (wall label)', () {
    test('artist and date', () {
      expect(_item(artist: 'Claude Monet', date: '1906').byline,
          'Claude Monet  ·  1906');
    });

    test('artist only', () {
      expect(_item(artist: 'Hokusai').byline, 'Hokusai');
    });

    test('empty and uncredited when anonymous and undated', () {
      final it = _item(source: 'Lorem Picsum');
      expect(it.byline, '');
      expect(it.hasCredit, false);
    });
  });

  group('FeedItem.aspectRatio', () {
    test('computes from dimensions', () {
      expect(_item().aspectRatio, closeTo(1.25, 0.001));
    });
  });
}
