import 'package:flutter_test/flutter_test.dart';
import 'package:fireplace/core/text_utils.dart';

void main() {
  group('cleanTitle', () {
    test('strips bracketed resolutions', () {
      expect(cleanTitle('Audi RS5 Wagon [1784x1004]'), 'Audi RS5 Wagon');
      expect(cleanTitle('Lexus LFA Roadster (1080 x 1350)'),
          'Lexus LFA Roadster');
    });

    test('strips bare resolutions and OC/HD tags', () {
      expect(cleanTitle('Sunset 1920x1080'), 'Sunset');
      expect(cleanTitle('My shot [OC]'), 'My shot');
      expect(cleanTitle('[HD] Mountain pass'), 'Mountain pass');
    });

    test('strips pasted image domains', () {
      expect(cleanTitle('Cool cat i.redd.it/abc123.jpg'), 'Cool cat');
    });

    test('collapses whitespace and trims separators', () {
      expect(cleanTitle('  A   title —  '), 'A title');
    });

    test('leaves clean titles untouched and handles null', () {
      expect(cleanTitle('Porsche 959 a class on its own'),
          'Porsche 959 a class on its own');
      expect(cleanTitle(null), '');
    });
  });

  group('museumLabel', () {
    test('formats author and subreddit', () {
      expect(
        museumLabel(author: 'u/quan', subreddit: 'carporn'),
        'PHOTOGRAPH  ·  u/quan  ·  r/carporn',
      );
    });

    test('omits an empty subreddit', () {
      expect(museumLabel(author: 'u/quan', subreddit: ''),
          'PHOTOGRAPH  ·  u/quan');
    });
  });
}
