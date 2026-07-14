import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'storage_service.dart';

class ScreenTimeService with WidgetsBindingObserver {
  final StorageService _storage;
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _persistTimer;
  int _baseSeconds = 0;
  VoidCallback? onThresholdReached;
  bool _reminderShown = false;

  ScreenTimeService(this._storage);

  String get _todayKey => DateFormat('yyyy-MM-dd').format(DateTime.now());

  int get todayTotalSeconds {
    // While tracking, the live total is the base captured at start plus the
    // running stopwatch. Reading the *stored* entry (which _persist already
    // wrote as base + elapsed) and re-adding elapsed would double-count.
    if (_stopwatch.isRunning || _stopwatch.elapsed.inSeconds > 0) {
      return _baseSeconds + _stopwatch.elapsed.inSeconds;
    }
    return _storage.getScreenTimeEntry(_todayKey)?.totalSeconds ?? 0;
  }

  void startTracking() {
    WidgetsBinding.instance.addObserver(this);
    _baseSeconds = _storage.getScreenTimeEntry(_todayKey)?.totalSeconds ?? 0;
    _stopwatch.start();
    _persistTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _persist(),
    );
  }

  void stopTracking() {
    _stopwatch.stop();
    _persistTimer?.cancel();
    _persist();
    WidgetsBinding.instance.removeObserver(this);
  }

  void _persist() {
    final totalSeconds = _baseSeconds + _stopwatch.elapsed.inSeconds;
    _storage.updateScreenTime(_todayKey, totalSeconds);

    final totalMinutes = totalSeconds ~/ 60;
    if (!_reminderShown &&
        totalMinutes >= _storage.reminderThresholdMinutes) {
      _reminderShown = true;
      onThresholdReached?.call();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _stopwatch.stop();
      _persist();
    } else if (state == AppLifecycleState.resumed) {
      _stopwatch.start();
    }
  }
}
