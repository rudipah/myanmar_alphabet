import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';

class SoundService {
  static final AudioPlayer _player = AudioPlayer();
  static bool _isPlaying = false;

  static Future<void> init() async {
    if (kIsWeb) return;
    // Set audio session to not mix with other audio
    await _player.setVolume(1.0);
  }

  static Future<void> playLetter(String audioFile) async {
    if (kIsWeb) return;
    if (_isPlaying) {
      await _player.stop();
      _isPlaying = false;
      // Small gap between stops and plays
      await Future.delayed(const Duration(milliseconds: 100));
    }

    try {
      _isPlaying = true;
      debugPrint('▶️ Playing: $audioFile');

      // Load and play fresh each time
      await _player.setAsset('assets/audio/$audioFile');
      await _player.seek(Duration.zero);
      await _player.play();

      // Wait for completion
      await _player.playerStateStream.firstWhere(
        (state) => state.processingState == ProcessingState.completed,
      );
      _isPlaying = false;
      debugPrint('✅ Done: $audioFile');
    } catch (e) {
      _isPlaying = false;
      debugPrint('❌ Error: $e');
    }
  }

  static Future<void> stop() async {
    if (kIsWeb) return;
    try {
      _isPlaying = false;
      await _player.stop();
    } catch (e) {
      debugPrint('Stop error: $e');
    }
  }
}
