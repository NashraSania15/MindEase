import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rxdart/rxdart.dart';
import '../models/stress_entry.dart';

/// Clean Local-first Stress Tracking Service.
/// 
/// Manages today's entries (Daily) and historical daily records (Weekly).
/// Stores everything in local storage as per Part 7 requirement.
class StressHistoryService {
  static const String _dailyKey = 'daily_entries_local';
  static const String _weeklyKey = 'weekly_history_local';
  static const String _lastDateKey = 'last_recorded_date';

  static final _dailySubject = BehaviorSubject<List<StressEntry>>.seeded([]);
  static final _weeklySubject = BehaviorSubject<List<WeeklyEntry>>.seeded([]);

  static Stream<List<StressEntry>> get dailyStream => _dailySubject.stream;
  static Stream<List<WeeklyEntry>> get weeklyStream => _weeklySubject.stream;

  /// Initialize and detect day change (Part 8)
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Check if we need to rotate daily -> weekly
    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);
    final lastDate = prefs.getString(_lastDateKey) ?? todayStr;

    if (lastDate != todayStr) {
      // It is a new day! (Part 8)
      await _moveToWeekly(prefs, lastDate);
      await prefs.setString(_lastDateKey, todayStr);
    }

    _loadFromPrefs(prefs);
  }

  static void _loadFromPrefs(SharedPreferences prefs) {
    // Load Daily
    final dailyJson = prefs.getString(_dailyKey);
    if (dailyJson != null) {
      final List list = jsonDecode(dailyJson);
      _dailySubject.add(list.map((e) => StressEntry.fromJson(e)).toList());
    }

    // Load Weekly
    final weeklyJson = prefs.getString(_weeklyKey);
    if (weeklyJson != null) {
      final List list = jsonDecode(weeklyJson);
      _weeklySubject.add(list.map((e) => WeeklyEntry.fromJson(e)).toList());
    }
  }

  /// Save new entry (Part 3)
  static Future<void> saveStressResult({
    required double combinedStress,
    double fatigueLevel = 0,
    String emotion = '',
    // Deprecated legacy params kept only to avoid breaking initial calls
    double faceStress = 0,
    double voiceStress = 0,
    double textStress = 0,
  }) async {
    // Part 8: Check date again before saving to ensure consistency
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);
    final lastDate = prefs.getString(_lastDateKey) ?? todayStr;

    if (lastDate != todayStr) {
      await _moveToWeekly(prefs, lastDate);
      await prefs.setString(_lastDateKey, todayStr);
    }

    // Add new entry
    final newEntry = StressEntry(
      timestamp: DateFormat('hh:mm a').format(now),
      combinedStress: combinedStress,
      fatigueLevel: fatigueLevel,
      emotion: emotion,
    );

    final updatedDaily = List<StressEntry>.from(_dailySubject.value)..add(newEntry);
    _dailySubject.add(updatedDaily);

    // Save Daily to Prefs
    await prefs.setString(_dailyKey, jsonEncode(updatedDaily.map((e) => e.toJson()).toList()));
  }

  /// Move all current daily entries to one weekly entry record (Part 4)
  static Future<void> _moveToWeekly(SharedPreferences prefs, String dateStr) async {
    final currentDaily = _dailySubject.value;
    if (currentDaily.isEmpty) return;

    // Determine Day from dateStr
    final dt = DateFormat('yyyy-MM-dd').parse(dateStr);
    final dayName = DateFormat('EEEE').format(dt); // Monday, etc.
    final formattedDate = DateFormat('MMMM dd, yyyy').format(dt);

    final newWeekly = WeeklyEntry(
      day: dayName,
      date: formattedDate,
      entries: currentDaily,
    );

    final updatedWeekly = List<WeeklyEntry>.from(_weeklySubject.value)..add(newWeekly);
    _weeklySubject.add(updatedWeekly);

    // Clear Daily
    _dailySubject.add([]);

    // Actual disk save
    await prefs.setString(_weeklyKey, jsonEncode(updatedWeekly.map((e) => e.toJson()).toList()));
    await prefs.remove(_dailyKey);
  }

  /// Helper to get the very latest combined value for dashboard (Part 6)
  static double getLatestCombined() {
    if (_dailySubject.value.isEmpty) return 0;
    return _dailySubject.value.last.combinedStress;
  }
}
