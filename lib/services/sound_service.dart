import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';

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
      if (!_audioCache.containsKey(file)) {
        final source = AudioSource.asset('assets/audio/$file');
        _audioCache[file] = source;
        
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

      final source = _audioCache[audioFile];

      if (source != null) {
        await _player.setAudioSource(source);
      } else {
        // Fallback for missing preloads: load on the fly
        await _player.setAsset('assets/audio/$audioFile');
        // Add to cache now so next time it's instant
        _audioCache[audioFile] = AudioSource.asset('assets/audio/$audioFile');
      }

      await _player.play();
    } catch (e) {
      debugPrint('❌ SoundService Playback Error: $e');
    } finally {
      _isBusy = false;
    }
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
