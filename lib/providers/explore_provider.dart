import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/feed_item.dart';
import '../constants.dart';
import 'feed_provider.dart';

final exploreCategoryProvider = StateProvider<String?>((ref) => null);

final exploreProvider =
    StateNotifierProvider<ExploreNotifier, AsyncValue<List<FeedItem>>>((ref) {
  final aggregator = ref.read(contentAggregatorProvider);
  final selectedCategory = ref.watch(exploreCategoryProvider);
  return ExploreNotifier(aggregator, selectedCategory);
});

class ExploreNotifier extends StateNotifier<AsyncValue<List<FeedItem>>> {
  final dynamic _aggregator;
  final String? _selectedCategory;

  ExploreNotifier(this._aggregator, this._selectedCategory)
      : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    try {
      final interests = _selectedCategory != null
          ? AppConstants.allInterests
              .where((i) => i.id == _selectedCategory)
              .toList()
          : AppConstants.allInterests;

      final items = await _aggregator.fetchFeed(
        interests: interests,
        perPage: 5,
      );
      state = AsyncValue.data(items);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _load();
  }
}
