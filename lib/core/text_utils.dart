/// Cleans raw Reddit post titles for display.
///
/// Reddit titles are noisy: resolution stamps (`[1440x1920]`, `(1080 x 1350)`),
/// tags (`[OC]`, `[HD]`), and pasted image URLs all leak into the text. In an
/// app that treats every image like a matted print, the label has to be clean.
String cleanTitle(String? raw) {
  if (raw == null) return '';
  var t = raw;

  // Bracketed / parenthesised resolutions: [1440x1920], (1080 x 1350), {…}.
  t = t.replaceAll(
    RegExp(r'[\[\(\{]\s*\d{2,5}\s*[x×by]{1,2}\s*\d{2,5}\s*[\]\)\}]',
        caseSensitive: false),
    ' ',
  );
  // Bare resolutions: 1920x1080.
  t = t.replaceAll(
    RegExp(r'\b\d{3,5}\s*[x×]\s*\d{3,5}\b', caseSensitive: false),
    ' ',
  );
  // Common bracketed tags: [OC] (HD) [4K] [xpost] [repost] …
  t = t.replaceAll(
    RegExp(r'[\[\(]\s*(oc|hd|uhd|fhd|hdr|hq|2k|4k|8k|x-?post|re-?post|album)\s*[\]\)]',
        caseSensitive: false),
    ' ',
  );
  // Pasted image/domain leftovers.
  t = t.replaceAll(
    RegExp(r'\b(i\.redd\.it|i\.imgur\.com|imgur\.com|redd\.it|flic\.kr)\S*',
        caseSensitive: false),
    ' ',
  );
  // Empty brackets left behind by the passes above.
  t = t.replaceAll(RegExp(r'[\[\(\{]\s*[\]\)\}]'), ' ');
  // Collapse whitespace.
  t = t.replaceAll(RegExp(r'\s+'), ' ').trim();
  // Trim dangling separators at either end.
  t = t.replaceAll(RegExp(r'^[\s\-–—·•|,:;]+'), '');
  t = t.replaceAll(RegExp(r'[\s\-–—·•|,:;]+$'), '');
  return t.trim();
}

/// The museum-label attribution line, e.g. `PHOTOGRAPH · u/quan · r/carporn`.
/// [author] arrives as `u/name`; [subreddit] as the bare sub name.
String museumLabel({
  required String author,
  String? subreddit,
  String kind = 'PHOTOGRAPH',
}) {
  final parts = <String>[kind, author];
  if (subreddit != null && subreddit.isNotEmpty) {
    parts.add(subreddit.startsWith('r/') ? subreddit : 'r/$subreddit');
  }
  return parts.join('  ·  ');
}
