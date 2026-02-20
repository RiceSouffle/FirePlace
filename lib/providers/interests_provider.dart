import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/interest.dart';
import '../constants.dart';
import '../services/storage_service.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  throw UnimplementedError('Must be overridden in ProviderScope');
});

final selectedInterestIdsProvider =
    StateNotifierProvider<SelectedInterestsNotifier, List<String>>((ref) {
  final storage = ref.read(storageServiceProvider);
  return SelectedInterestsNotifier(storage);
});

class SelectedInterestsNotifier extends StateNotifier<List<String>> {
  final StorageService _storage;

  SelectedInterestsNotifier(this._storage)
      : super(_storage.getSelectedInterestIds());

  Future<void> toggle(String interestId) async {
    if (state.contains(interestId)) {
      state = [...state]..remove(interestId);
    } else {
      state = [...state, interestId];
    }
    await _storage.saveSelectedInterestIds(state);
  }

  Future<void> setAll(List<String> ids) async {
    state = ids;
    await _storage.saveSelectedInterestIds(ids);
  }
}

final selectedInterestsProvider = Provider<List<Interest>>((ref) {
  final ids = ref.watch(selectedInterestIdsProvider);
  return AppConstants.allInterests
      .where((i) => ids.contains(i.id))
      .toList();
});
