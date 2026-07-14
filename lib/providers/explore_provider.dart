import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/feed_item.dart';
import '../constants.dart';
import 'feed_provider.dart';

final exploreCategoryProvider = StateProvider<String?>((ref) => null);

final exploreProvider =
    StateNotifierProvider<ExploreNotifier, AsyncValue<List<FeedItem>>>((ref) {
  final gallery = ref.read(galleryServiceProvider);
  final selectedCategory = ref.watch(exploreCategoryProvider);
  return ExploreNotifier(gallery, selectedCategory);
});

class ExploreNotifier extends StateNotifier<AsyncValue<List<FeedItem>>> {
  final dynamic _gallery;
  final String? _selectedCategory;

  ExploreNotifier(this._gallery, this._selectedCategory)
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
      final items = await _gallery.fetchFeed(interests: interests, perPage: 18);
      if (!mounted) return; // category changed mid-fetch → notifier disposed
      state = AsyncValue.data(items);
    } catch (e, st) {
      if (mounted) state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _load();
  }
}
