import 'package:hive_ce/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/feed_item.dart';
import '../models/screen_time_entry.dart';

class StorageService {
  static const String _savedPostsBox = 'saved_posts';
  static const String _screenTimeBox = 'screen_time';
  static const String _interestsKey = 'selected_interests';
  static const String _onboardingCompleteKey = 'onboarding_complete';
  static const String _reminderThresholdKey = 'reminder_threshold_minutes';

  late Box<FeedItem> _savedBox;
  late Box<ScreenTimeEntry> _screenTimeBoxRef;
  late SharedPreferences _prefs;

  Future<void> init() async {
    _savedBox = await Hive.openBox<FeedItem>(_savedPostsBox);
    _screenTimeBoxRef = await Hive.openBox<ScreenTimeEntry>(_screenTimeBox);
    _prefs = await SharedPreferences.getInstance();
  }

  List<String> getSelectedInterestIds() =>
      _prefs.getStringList(_interestsKey) ?? [];

  Future<void> saveSelectedInterestIds(List<String> ids) =>
      _prefs.setStringList(_interestsKey, ids);

  bool get isOnboardingComplete =>
      _prefs.getBool(_onboardingCompleteKey) ?? false;

  Future<void> setOnboardingComplete() =>
      _prefs.setBool(_onboardingCompleteKey, true);

  int get reminderThresholdMinutes =>
      _prefs.getInt(_reminderThresholdKey) ?? 30;

  Future<void> setReminderThresholdMinutes(int minutes) =>
      _prefs.setInt(_reminderThresholdKey, minutes);

  List<FeedItem> getSavedPosts() => _savedBox.values.toList();

  Future<void> savePost(FeedItem item) async {
    item.isSaved = true;
    await _savedBox.put(item.id, item);
  }

  Future<void> unsavePost(String id) async {
    await _savedBox.delete(id);
  }

  bool isPostSaved(String id) => _savedBox.containsKey(id);

  ScreenTimeEntry? getScreenTimeEntry(String dateKey) =>
      _screenTimeBoxRef.get(dateKey);

  Future<void> updateScreenTime(String dateKey, int totalSeconds) async {
    final entry = _screenTimeBoxRef.get(dateKey) ??
        ScreenTimeEntry(date: dateKey);
    entry.totalSeconds = totalSeconds;
    await _screenTimeBoxRef.put(dateKey, entry);
  }

  List<ScreenTimeEntry> getScreenTimeHistory(int days) {
    final entries = _screenTimeBoxRef.values.toList();
    entries.sort((a, b) => b.date.compareTo(a.date));
    return entries.take(days).toList();
  }
}
