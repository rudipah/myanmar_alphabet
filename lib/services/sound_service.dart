import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';
import 'preferences_service.dart';

class SoundService {
  static final AudioPlayer _player = AudioPlayer();

  // Cache for preloaded audio sources
  static final Map<String, AudioSource> _audioCache = {};

  static bool _isInitialized = false;

  /// Incremented on every play request. A request that is no longer the
  /// newest one abandons itself, so the LATEST tap always wins instead of
  /// taps being ignored while a clip is still playing.
  static int _playToken = 0;

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

  /// Play a letter sound. The newest call always wins (it interrupts any
  /// clip that is playing).
  ///
  /// By default this returns as soon as playback has STARTED. Pass
  /// [waitForCompletion] to get a Future that completes when the clip ends
  /// (used by the tracing screen's speaker animation).
  static Future<void> playLetter(String audioFile,
      {bool waitForCompletion = false}) async {
    if (!await PreferencesService.isSoundEnabled()) return; // Muted
    final token = ++_playToken;

    try {
      await _player.stop();
      if (token != _playToken) return;

      final format = await PreferencesService.getAudioFormat();
      if (token != _playToken) return;

      String finalFile = audioFile;
      if (format == AudioFormat.long && !audioFile.contains('_long') && !audioFile.contains('_word')) {
        finalFile = audioFile.replaceAll('.ogg', '_long.ogg');
      }

      final path = finalFile.startsWith('assets/audio/') ? finalFile : 'assets/audio/$finalFile';

      try {
        await _setSourceAndPlay(path, token, waitForCompletion);
      } catch (e) {
        if (token != _playToken) return; // interrupted by a newer tap — not an error
        if (finalFile != audioFile) {
          debugPrint('⚠️ SoundService: Long version not found for $audioFile, falling back to short.');
          final fallbackPath = audioFile.startsWith('assets/audio/') ? audioFile : 'assets/audio/$audioFile';
          await _setSourceAndPlay(fallbackPath, token, waitForCompletion);
        } else {
          rethrow;
        }
      }
    } catch (e) {
      if (token != _playToken) return;
      debugPrint('❌ SoundService Playback Error for $audioFile: $e');
    }
  }

  /// Play letter followed by its corresponding word audio sequentially.
  static Future<void> playLetterAndWord(String letterAudio, String wordAudio) async {
    if (!await PreferencesService.isSoundEnabled()) return; // Muted
    final token = ++_playToken;

    try {
      await _player.stop();
      if (token != _playToken) return;
      await _playSequence([letterAudio, wordAudio], token);
    } catch (e) {
      if (token != _playToken) return;
      debugPrint('❌ SoundService Sequence Playback Error: $e');
    }
  }

  static Future<void> _playSequence(List<String> files, int token) async {
    for (var file in files) {
      if (token != _playToken) return; // a newer sound took over
      if (file.isEmpty) continue;

      String finalFile = file;
      final format = await PreferencesService.getAudioFormat();
      if (format == AudioFormat.long && !file.contains('_long') && !file.contains('_word')) {
        finalFile = file.replaceAll('.ogg', '_long.ogg');
      }

      final path = finalFile.startsWith('assets/audio/') ? finalFile : 'assets/audio/$finalFile';

      try {
        // Waits until this clip has finished before moving to the next one.
        await _setSourceAndPlay(path, token, true);
      } catch (e) {
        if (token != _playToken) return;
        debugPrint('⚠️ Sequence element $file failed or timed out: $e');
      }
    }
  }

  static Future<void> _setSourceAndPlay(
      String path, int token, bool waitForCompletion) async {
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

    if (token != _playToken) return; // a newer tap took over while loading

    // IMPORTANT: in just_audio, play()'s Future only completes when the clip
    // FINISHES. Awaiting it here used to keep a "busy" lock held for the whole
    // clip, so taps on the speaker buttons were silently ignored.
    if (waitForCompletion) {
      await _player.play();
    } else {
      unawaited(_player.play().catchError((Object e) {
        debugPrint('⚠️ SoundService play error: $e');
      }));
    }
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
