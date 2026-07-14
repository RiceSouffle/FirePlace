/// Where a category's images come from.
enum Source { met, wikimedia, cats, photo }

/// A gallery category the user can follow. [query] is the search term for the
/// [source] that needs one (Met, Wikimedia).
class Interest {
  final String id;
  final String label;
  final Source source;
  final String query;

  const Interest({
    required this.id,
    required this.label,
    required this.source,
    this.query = '',
  });
}
