import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioManager {
  AudioManager._();
  static final instance = AudioManager._();

  final Map<String, AudioPlayer> _players = {};
  final Map<String, double> _volumes = {};
  final Map<String, bool> _loading = {};

  bool isLoading(String id) => _loading[id] ?? false;
  bool isReady(String id) => _players.containsKey(id);

  Future<void> precache(String id, String assetPath) async {
    if (_players.containsKey(id) || _loading[id] == true) return;
    _loading[id] = true;

    try {
      final player = AudioPlayer();
      await player.setAudioContext(
        AudioContext(
          android: AudioContextAndroid(
            isSpeakerphoneOn: false,
            stayAwake: true,
            contentType: AndroidContentType.music,
            usageType: AndroidUsageType.media,
            audioFocus: AndroidAudioFocus.gainTransientMayDuck,
          ),
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: {AVAudioSessionOptions.mixWithOthers},
          ),
        ),
      );
      await player.setReleaseMode(ReleaseMode.loop);
      await player.setSource(AssetSource(assetPath.replaceFirst('assets/', '')));
      await player.setVolume(_volumes[id] ?? 0.7);

      _players[id] = player;
      _loading[id] = false;
    } catch (e) {
      _loading[id] = false;
      debugPrint('AudioManager: failed to precache $id — $e');
    }
  }

  Future<void> playSound(String id, String assetPath) async {
    // If already loaded and paused, resume
    if (_players.containsKey(id)) {
      final player = _players[id]!;
      await player.setVolume(_volumes[id] ?? 0.7);
      await player.resume();
      return;
    }

    // Not loaded yet — load and play (pass source to play())
    await precache(id, assetPath);
    final player = _players[id];
    if (player != null) {
      final source = AssetSource(assetPath.replaceFirst('assets/', ''));
      await player.play(source);
    }
  }

  Future<void> stopSound(String id) async {
    if (_players.containsKey(id)) {
      await _players[id]!.stop();
      // Seek to start so next play starts from beginning
      await _players[id]!.seek(const Duration(seconds: 0));
    }
  }

  Future<void> pauseSound(String id) async {
    if (_players.containsKey(id)) {
      await _players[id]!.pause();
    }
  }

  Future<void> resumeSound(String id) async {
    if (_players.containsKey(id)) {
      await _players[id]!.resume();
    }
  }

  Future<void> setVolume(String id, double volume) async {
    _volumes[id] = volume;
    if (_players.containsKey(id)) {
      await _players[id]!.setVolume(volume);
    }
  }

  Future<void> stopAll() async {
    final ids = _players.keys.toList();
    for (final id in ids) {
      await stopSound(id);
    }
  }

  bool isPlaying(String id) => _players.containsKey(id);
  double getVolume(String id) => _volumes[id] ?? 0.7;

  Future<void> dispose() async {
    for (final player in _players.values) {
      await player.dispose();
    }
    _players.clear();
    _loading.clear();
  }
}
