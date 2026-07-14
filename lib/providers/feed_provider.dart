import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/feed_item.dart';
import '../services/content_aggregator_service.dart';
import 'interests_provider.dart';

final contentAggregatorProvider = Provider<ContentAggregatorService>((ref) {
  throw UnimplementedError('Must be overridden in ProviderScope');
});

final feedProvider =
    StateNotifierProvider<FeedNotifier, AsyncValue<List<FeedItem>>>((ref) {
  final aggregator = ref.read(contentAggregatorProvider);
  final interests = ref.watch(selectedInterestsProvider);
  return FeedNotifier(aggregator, interests);
});

class FeedNotifier extends StateNotifier<AsyncValue<List<FeedItem>>> {
  final ContentAggregatorService _aggregator;
  final List _interests;
  int _currentPage = 1;

  FeedNotifier(this._aggregator, this._interests)
      : super(const AsyncValue.loading()) {
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    if (_interests.isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }
    try {
      final items = await _aggregator.fetchFeed(
        interests: _interests.cast(),
        page: 1,
      );
      state = AsyncValue.data(items);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadMore() async {
    if (_interests.isEmpty) return;
    _currentPage++;
    try {
      final moreItems = await _aggregator.fetchFeed(
        interests: _interests.cast(),
        page: _currentPage,
      );
      final current = state.valueOrNull ?? [];
      // De-dupe across batches: hot.json can surface the same posts, and two
      // cards sharing an id would collide on their 'feed_<id>' Hero tag.
      final ids = current.map((e) => e.id).toSet();
      final fresh = moreItems.where((m) => ids.add(m.id)).toList();
      state = AsyncValue.data([...current, ...fresh]);
    } catch (_) {
      _currentPage--;
    }
  }

  Future<void> refresh() async {
    _currentPage = 1;
    state = const AsyncValue.loading();
    await _loadInitial();
  }
}
