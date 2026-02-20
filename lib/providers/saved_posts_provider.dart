import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/feed_item.dart';
import 'interests_provider.dart';

final savedPostsProvider =
    StateNotifierProvider<SavedPostsNotifier, List<FeedItem>>((ref) {
  final storage = ref.read(storageServiceProvider);
  return SavedPostsNotifier(storage);
});

class SavedPostsNotifier extends StateNotifier<List<FeedItem>> {
  final dynamic _storage;

  SavedPostsNotifier(this._storage) : super(_storage.getSavedPosts());

  Future<void> toggleSave(FeedItem item) async {
    if (_storage.isPostSaved(item.id)) {
      await _storage.unsavePost(item.id);
    } else {
      await _storage.savePost(item);
    }
    state = _storage.getSavedPosts();
  }

  bool isSaved(String id) => _storage.isPostSaved(id);
}
