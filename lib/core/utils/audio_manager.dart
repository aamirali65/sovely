import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  AudioManager._();
  static final instance = AudioManager._();

  final Map<String, AudioPlayer> _players = {};
  final Map<String, double> _volumes = {};

  Future<void> playSound(String id, String assetPath) async {
    // If already playing, do nothing
    if (_players.containsKey(id)) return;

    final player = AudioPlayer();

    // Each player gets its own audio context to allow mixing
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
    await player.setVolume(_volumes[id] ?? 0.7);
    await player.play(AssetSource(assetPath.replaceFirst('assets/', '')));

    _players[id] = player;
  }

  Future<void> stopSound(String id) async {
    if (_players.containsKey(id)) {
      await _players[id]!.stop();
      await _players[id]!.dispose();
      _players.remove(id);
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
    await stopAll();
  }
}