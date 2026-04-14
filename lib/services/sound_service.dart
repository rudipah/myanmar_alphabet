import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';

class SoundService {
  static final AudioPlayer _player = AudioPlayer();

  // Cache for preloaded audio
  static final Map<String, AudioSource> _audioCache = {};

  static bool _isInitialized = false;
  static bool _isBusy = false;

  /// Call this once (e.g. in main or first screen)
  static Future<void> init() async {
    if (kIsWeb || _isInitialized) return;

    await _player.setVolume(1.0);

    // 🔥 Preload your audio files here
    final audioFiles = [
      'a.wav',
      'ba.wav',
      'bha.wav',
      'da1.wav',
      'da2.wav',
      'dha1.wav',
      'dha2.wav',
      'eight.wav',
      'five.wav',
      'four.wav',
      'ga.wav',
      'gha.wav',
      'ha.wav',
      'hsa.wav',
      'hta1.wav',
      'hta2.wav',
      'ka.wav',
      'kha.wav',
      'la.wav',
      'lla.wav',
      'ma.wav',
      'na1.wav',
      'na2.wav',
      'nga.wav',
      'nine.wav',
      'nya.wav',
      'one.wav',
      'pa.wav',
      'pha.wav',
      'ra.wav',
      'sa.wav',
      'seven.wav',
      'six.wav',
      'ta1.wav',
      'ta2.wav',
      'ten.wav',
      'tha.wav',
      'three.wav',
      'two.wav',
      'wa.wav',
      'ya.wav',
      'za.wav',
      'zero.wav',
      'zha.wav',
      // 👉 ADD ALL your files here
    ];

    for (var file in audioFiles) {
      _audioCache[file] = AudioSource.asset('assets/audio/$file');
    }

    _isInitialized = true;
  }

  /// Play sound instantly
  static Future<void> playLetter(String audioFile) async {
    if (kIsWeb || _isBusy) return;

    _isBusy = true;

    try {
      // Stop current playback
      await _player.stop();

      // Use preloaded audio (⚡ fast)
      final source = _audioCache[audioFile];

      if (source != null) {
        await _player.setAudioSource(source);
      } else {
        // fallback (in case not preloaded)
        await _player.setAsset('assets/audio/$audioFile');
      }

      await _player.play();
    } catch (e) {
      debugPrint('❌ Error: $e');
    }

    _isBusy = false;
  }

  static Future<void> stop() async {
    if (kIsWeb) return;

    try {
      await _player.stop();
    } catch (e) {
      debugPrint('Stop error: $e');
    }
  }

  /// Optional: dispose when app closes
  static Future<void> dispose() async {
    await _player.dispose();
  }
}
