import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/feed_item.dart';
import '../models/interest.dart';
import '../services/gallery_service.dart';
import 'interests_provider.dart';

final galleryServiceProvider = Provider<GalleryService>((ref) {
  throw UnimplementedError('Must be overridden in ProviderScope');
});

final feedProvider =
    StateNotifierProvider<FeedNotifier, AsyncValue<List<FeedItem>>>((ref) {
  final gallery = ref.read(galleryServiceProvider);
  final interests = ref.watch(selectedInterestsProvider);
  return FeedNotifier(gallery, interests);
});

class FeedNotifier extends StateNotifier<AsyncValue<List<FeedItem>>> {
  final GalleryService _gallery;
  final List<Interest> _interests;
  int _currentPage = 1;

  FeedNotifier(this._gallery, this._interests)
      : super(const AsyncValue.loading()) {
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    try {
      final items = await _gallery.fetchFeed(interests: _interests, page: 1);
      if (!mounted) return; // interests changed mid-fetch → notifier disposed
      state = AsyncValue.data(items);
    } catch (e, st) {
      if (mounted) state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadMore() async {
    _currentPage++;
    try {
      final more =
          await _gallery.fetchFeed(interests: _interests, page: _currentPage);
      if (!mounted) return;
      final current = state.valueOrNull ?? [];
      final ids = current.map((e) => e.id).toSet();
      final fresh = more.where((m) => ids.add(m.id)).toList();
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
