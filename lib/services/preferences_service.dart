import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

enum AudioFormat { short, long }

class PreferencesService {
  static const String _audioFormatKey = 'audio_format';
  static const String _masteredLettersKey = 'mastered_letters';
  static const String _soundEnabledKey = 'sound_enabled';
  static const String _lastStudyDateKey = 'last_study_date';
  static const String _currentStreakKey = 'current_streak';

  // ---------------------------------------------------------------
  // Audio Format
  // ---------------------------------------------------------------

  static Future<void> setAudioFormat(AudioFormat format) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_audioFormatKey, format.name);
  }

  static Future<AudioFormat> getAudioFormat() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_audioFormatKey);
    if (value == null) return AudioFormat.long;
    return AudioFormat.values.firstWhere(
      (f) => f.name == value,
      orElse: () => AudioFormat.long,
    );
  }

  // ---------------------------------------------------------------
  // Sound On/Off Toggle
  // ---------------------------------------------------------------

  static Future<void> setSoundEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundEnabledKey, enabled);
  }

  static Future<bool> isSoundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_soundEnabledKey) ?? true;
  }

  // ---------------------------------------------------------------
  // Letter Progress
  // ---------------------------------------------------------------

  static Future<void> incrementLetterProgress(String letter) async {
    final prefs = await SharedPreferences.getInstance();
    final progressMap = await getLetterProgress();
    final currentCount = progressMap[letter] ?? 0;
    progressMap[letter] = currentCount + 1;
    await prefs.setString(_masteredLettersKey, jsonEncode(progressMap));
  }

  static Future<Map<String, int>> getLetterProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_masteredLettersKey);
    if (data == null) return {};

    try {
      final decoded = jsonDecode(data);
      if (decoded is List) {
        // Migration: convert old Set (List) format to Map
        final map = <String, int>{};
        for (var item in decoded) {
          map[item] = 1;
        }
        return map;
      } else if (decoded is Map) {
        return Map<String, int>.from(
            decoded.map((k, v) => MapEntry(k, v as int)));
      }
      return {};
    } catch (e) {
      debugPrint('Error decoding letter progress: $e');
      return {};
    }
  }

  static Future<bool> isLetterMastered(String letter) async {
    final progress = await getLetterProgress();
    return (progress[letter] ?? 0) > 0;
  }

  static Future<void> resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_masteredLettersKey);
    // Also reset streak when progress is reset
    await prefs.remove(_currentStreakKey);
    await prefs.remove(_lastStudyDateKey);
  }

  // ---------------------------------------------------------------
  // Daily Streak
  // ---------------------------------------------------------------
  // The streak counts consecutive CALENDAR days on which the child finished
  // a study activity (a tracing, a quiz round or a matching round). Days are
  // compared as plain dates (never 24h durations), so daylight-saving
  // changes cannot break a streak.

  /// Call when the child completes a tracing, quiz round or matching round.
  /// Safe to call many times a day — only the first call each day counts.
  /// Returns the updated streak.
  static Future<int> recordStudyActivity() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _dateOnly(DateTime.now());
    final last = _parseDate(prefs.getString(_lastStudyDateKey));
    int streak = prefs.getInt(_currentStreakKey) ?? 0;

    if (last == null) {
      streak = 1; // First ever study day
    } else {
      final gap = today.difference(last).inDays; // both are UTC dates
      if (gap == 0) {
        return streak < 1 ? 1 : streak; // already counted today
      } else if (gap == 1) {
        streak += 1; // consecutive day
      } else {
        streak = 1; // missed at least one day (or clock moved back)
      }
    }

    await prefs.setString(_lastStudyDateKey, _dateString(today));
    await prefs.setInt(_currentStreakKey, streak);
    return streak;
  }

  /// Read-only. Returns the streak that is still alive: 0 if the child has
  /// not studied today or yesterday.
  static Future<int> getCurrentStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final last = _parseDate(prefs.getString(_lastStudyDateKey));
    if (last == null) return 0;
    final gap = _dateOnly(DateTime.now()).difference(last).inDays;
    if (gap > 1) return 0;
    return prefs.getInt(_currentStreakKey) ?? 0;
  }

  /// Calendar date (no time) as a UTC DateTime, so differences are whole days.
  static DateTime _dateOnly(DateTime d) => DateTime.utc(d.year, d.month, d.day);

  static DateTime? _parseDate(String? s) {
    if (s == null) return null;
    final p = s.split('-');
    if (p.length != 3) return null;
    final y = int.tryParse(p[0]), m = int.tryParse(p[1]), d = int.tryParse(p[2]);
    if (y == null || m == null || d == null) return null;
    return DateTime.utc(y, m, d);
  }

  static String _dateString(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
