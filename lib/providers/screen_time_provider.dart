import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/screen_time_entry.dart';
import '../services/screen_time_service.dart';
import 'interests_provider.dart';

final screenTimeServiceProvider = Provider<ScreenTimeService>((ref) {
  final storage = ref.read(storageServiceProvider);
  return ScreenTimeService(storage);
});

/// Streams the live screen time every 5 seconds so the UI updates.
final todayScreenTimeProvider = StreamProvider<int>((ref) {
  final service = ref.read(screenTimeServiceProvider);
  return Stream.periodic(
    const Duration(seconds: 5),
    (_) => service.todayTotalSeconds,
  ).asBroadcastStream();
});

final screenTimeHistoryProvider = Provider<List<ScreenTimeEntry>>((ref) {
  // Re-read when today's screen time changes so chart updates too
  ref.watch(todayScreenTimeProvider);
  final storage = ref.read(storageServiceProvider);
  return storage.getScreenTimeHistory(7);
});
