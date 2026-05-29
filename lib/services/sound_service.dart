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
    if (kIsWeb || _isInitialized) return;
    await _player.setVolume(1.0);
    _isInitialized = true;
  }

  /// Dynamically preloads audio files into memory to ensure zero-latency playback.
  /// Use this when entering a letter category or starting a session.
  static Future<void> preloadAudioFiles(List<String> files) async {
    if (kIsWeb) return;

    final List<Future> preloadTasks = [];

    for (var file in files) {
      final path = file.startsWith('assets/audio/') ? file : 'assets/audio/$file';
      if (!_audioCache.containsKey(path)) {
        final source = AudioSource.asset(path);
        _audioCache[path] = source;

        // We "prime" the player by briefly loading the source.
        // This forces the asset to be cached by the underlying platform.
        preloadTasks.add(_primeSource(source));
      }
    }

    await Future.wait(preloadTasks);
    debugPrint('🔊 SoundService: Preloaded ${files.length} files.');
  }

  static Future<void> _primeSource(AudioSource source) async {
    try {
      // Setting the source without playing it often triggers the internal asset load.
      await _player.setAudioSource(source);
    } catch (e) {
      debugPrint('⚠️ SoundService Preload Error: $e');
    }
  }

  /// Play sound instantly using the cache.
  static Future<void> playLetter(String audioFile) async {
    if (kIsWeb || _isBusy) return;

    _isBusy = true;

    try {
      await _player.stop();

      final format = await PreferencesService.getAudioFormat();
      String finalFile = audioFile;

      // 1. Try to use the long version if requested and it's not already a special file
      if (format == AudioFormat.long && !audioFile.contains('_long') && !audioFile.contains('_word')) {
        finalFile = audioFile.replaceAll('.ogg', '_long.ogg');
      }

      final path = finalFile.startsWith('assets/audio/') ? finalFile : 'assets/audio/$finalFile';

      try {
        // Try loading the calculated path (could be long version)
        await _setSourceAndPlay(path);
      } catch (e) {
        // 2. Fallback: If long version failed, try the original short version
        if (finalFile != audioFile) {
          debugPrint('⚠️ SoundService: Long version not found for $audioFile, falling back to short version.');
          final fallbackPath = audioFile.startsWith('assets/audio/') ? audioFile : 'assets/audio/$audioFile';
          await _setSourceAndPlay(fallbackPath);
        } else {
          rethrow; // If short version also fails, let the outer catch handle it
        }
      }
    } catch (e) {
      debugPrint('❌ SoundService Playback Error for $audioFile: $e');
    } finally {
      _isBusy = false;
    }
  }

  /// Helper to handle source selection and playback
  static Future<void> _setSourceAndPlay(String path) async {
    final source = _audioCache[path];
    if (source != null) {
      await _player.setAudioSource(source);
    } else {
      await _player.setAsset(path);
      _audioCache[path] = AudioSource.asset(path);
    }
    await _player.play();
  }

  static Future<void> stop() async {
    if (kIsWeb) return;
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
