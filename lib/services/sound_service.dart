import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';
import 'preferences_service.dart';

class SoundService {
  static final AudioPlayer _player = AudioPlayer();

  // Cache for preloaded audio sources
  static final Map<String, AudioSource> _audioCache = {};

  static bool _isInitialized = false;
  static bool _isBusy = false;

  /// Call this once at app startup.
  static Future<void> init() async {
    if (_isInitialized) return;
    await _player.setVolume(1.0);
    _isInitialized = true;
  }

  /// Dynamically preloads audio files into memory to ensure zero-latency playback.
  static Future<void> preloadAudioFiles(List<String> files) async {
    final List<Future> preloadTasks = [];

    for (var file in files) {
      final path = file.startsWith('assets/audio/') ? file : 'assets/audio/$file';
      if (!_audioCache.containsKey(path)) {
        final source = AudioSource.asset(path);
        _audioCache[path] = source;
        preloadTasks.add(_primeSource(source));
      }
    }

    await Future.wait(preloadTasks);
    debugPrint('🔊 SoundService: Preloaded ${files.length} files.');
  }

  static Future<void> _primeSource(AudioSource source) async {
    try {
      await _player.setAudioSource(source);
    } catch (e) {
      debugPrint('⚠️ SoundService Preload Error: $e');
    }
  }

  /// Play sound instantly using the cache.
  static Future<void> playLetter(String audioFile) async {
    if (_isBusy) return;
    _isBusy = true;

    try {
      await _player.stop();
      final format = await PreferencesService.getAudioFormat();
      String finalFile = audioFile;

      if (format == AudioFormat.long && !audioFile.contains('_long') && !audioFile.contains('_word')) {
        finalFile = audioFile.replaceAll('.ogg', '_long.ogg');
      }

      final path = finalFile.startsWith('assets/audio/') ? finalFile : 'assets/audio/$finalFile';

      try {
        await _setSourceAndPlay(path);
      } catch (e) {
        if (finalFile != audioFile) {
          debugPrint('⚠️ SoundService: Long version not found for $audioFile, falling back to short.');
          final fallbackPath = audioFile.startsWith('assets/audio/') ? audioFile : 'assets/audio/$audioFile';
          await _setSourceAndPlay(fallbackPath);
        } else {
          rethrow;
        }
      }
    } catch (e) {
      debugPrint('❌ SoundService Playback Error for $audioFile: $e');
    } finally {
      _isBusy = false;
    }
  }

  /// Play letter followed by its corresponding word audio sequentially.
  static Future<void> playLetterAndWord(String letterAudio, String wordAudio) async {
    if (_isBusy) return;
    _isBusy = true;

    try {
      await _playSequence([letterAudio, wordAudio]);
    } catch (e) {
      debugPrint('❌ SoundService Sequence Playback Error: $e');
    } finally {
      _isBusy = false;
    }
  }

  static Future<void> _playSequence(List<String> files) async {
    for (var file in files) {
      if (file.isEmpty) continue;

      String finalFile = file;
      final format = await PreferencesService.getAudioFormat();
      if (format == AudioFormat.long && !file.contains('_long') && !file.contains('_word')) {
        finalFile = file.replaceAll('.ogg', '_long.ogg');
      }

      final path = finalFile.startsWith('assets/audio/') ? finalFile : 'assets/audio/$finalFile';

      try {
        await _setSourceAndPlay(path);
        // Wait for the current audio to finish before starting the next one
        await _player.playerStateStream.firstWhere(
          (state) => state.processingState == ProcessingState.completed
        ).timeout(const Duration(seconds: 5));
      } catch (e) {
        debugPrint('⚠️ Sequence element $file failed or timed out: $e');
      }
    }
  }

  static Future<void> _setSourceAndPlay(String path) async {
    // Remove leading 'assets/' if we are on web because the engine adds it automatically
    String finalPath = path;
    if (kIsWeb && finalPath.startsWith('assets/')) {
      finalPath = finalPath.substring(7);
    }

    final source = _audioCache[finalPath];
    if (source != null) {
      await _player.setAudioSource(source);
    } else {
      await _player.setAsset(finalPath);
      _audioCache[finalPath] = AudioSource.asset(finalPath);
    }
    await _player.play();
  }

  static Future<void> stop() async {
    try {
      await _player.stop();
    } catch (e) {
      debugPrint('Stop error: $e');
    }
  }

  static Future<void> dispose() async {
    await _player.dispose();
  }
}
