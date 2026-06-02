import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

enum AudioFormat { short, long }

class PreferencesService {
  static const String _audioFormatKey = 'audio_format';
  static const String _masteredLettersKey = 'mastered_letters';

  /// Set the preferred audio format (short or long)
  static Future<void> setAudioFormat(AudioFormat format) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_audioFormatKey, format.name);
  }

  /// Get the currently preferred audio format
  static Future<AudioFormat> getAudioFormat() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_audioFormatKey);
    if (value == null) return AudioFormat.long; // Default to long

    return AudioFormat.values.firstWhere(
      (format) => format.name == value,
      orElse: () => AudioFormat.long,
    );
  }

  /// Save a letter as mastered (increments the progress count)
  static Future<void> incrementLetterProgress(String letter) async {
    final prefs = await SharedPreferences.getInstance();
    final progressMap = await getLetterProgress();

    final currentCount = progressMap[letter] ?? 0;
    progressMap[letter] = currentCount + 1;

    await prefs.setString(_masteredLettersKey, jsonEncode(progressMap));
  }

  /// Get the map of all letter progress (letter -> count)
  static Future<Map<String, int>> getLetterProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_masteredLettersKey);
    if (data == null) return {};

    try {
      final decoded = jsonDecode(data);
      if (decoded is List) {
        // Migration: Convert old Set (List) to Map
        final map = <String, int>{};
        for (var item in decoded) {
          map[item] = 1;
        }
        return map;
      } else if (decoded is Map) {
        return Map<String, int>.from(decoded.map((k, v) => MapEntry(k, v as int)));
      }
      return {};
    } catch (e) {
      debugPrint('Error decoding letter progress: $e');
      return {};
    }
  }

  /// Check if a letter has been practiced at least once
  static Future<bool> isLetterMastered(String letter) async {
    final progress = await getLetterProgress();
    return (progress[letter] ?? 0) > 0;
  }

  /// Reset all progress
  static Future<void> resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_masteredLettersKey);
  }
}
