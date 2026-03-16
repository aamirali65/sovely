import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/audio_manager.dart';
import '../constants/sound_data.dart';

enum SoundPlayState { playing, paused, stopped }

class ActiveSoundInfo {
  final double volume;
  final SoundPlayState playState;

  const ActiveSoundInfo({
    this.volume = 0.7,
    this.playState = SoundPlayState.playing,
  });

  ActiveSoundInfo copyWith({double? volume, SoundPlayState? playState}) {
    return ActiveSoundInfo(
      volume: volume ?? this.volume,
      playState: playState ?? this.playState,
    );
  }
}

class ActiveSoundsNotifier extends StateNotifier<Map<String, ActiveSoundInfo>> {
  ActiveSoundsNotifier() : super({});

  Future<void> toggleSound(SoundModel sound) async {
    if (state.containsKey(sound.id)) {
      await AudioManager.instance.stopSound(sound.id);
      final updated = Map<String, ActiveSoundInfo>.from(state);
      updated.remove(sound.id);
      state = updated;
    } else {
      await AudioManager.instance.playSound(sound.id, sound.assetPath);
      state = {
        ...state,
        sound.id: ActiveSoundInfo(
          volume: AudioManager.instance.getVolume(sound.id),
          playState: SoundPlayState.playing,
        ),
      };
    }
  }

  Future<void> pauseSound(String id) async {
    if (!state.containsKey(id)) return;
    await AudioManager.instance.pauseSound(id);
    final updated = Map<String, ActiveSoundInfo>.from(state);
    updated[id] = updated[id]!.copyWith(playState: SoundPlayState.paused);
    state = updated;
  }

  Future<void> resumeSound(String id) async {
    if (!state.containsKey(id)) return;
    await AudioManager.instance.resumeSound(id);
    final updated = Map<String, ActiveSoundInfo>.from(state);
    updated[id] = updated[id]!.copyWith(playState: SoundPlayState.playing);
    state = updated;
  }

  Future<void> stopSound(SoundModel sound) async {
    await AudioManager.instance.stopSound(sound.id);
    final updated = Map<String, ActiveSoundInfo>.from(state);
    updated.remove(sound.id);
    state = updated;
  }

  Future<void> setVolume(String id, double volume) async {
    if (!state.containsKey(id)) return;
    await AudioManager.instance.setVolume(id, volume);
    final updated = Map<String, ActiveSoundInfo>.from(state);
    updated[id] = updated[id]!.copyWith(volume: volume);
    state = updated;
  }

  Future<void> stopAll() async {
    await AudioManager.instance.stopAll();
    state = {};
  }
}

final activeSoundsProvider =
StateNotifierProvider<ActiveSoundsNotifier, Map<String, ActiveSoundInfo>>(
      (ref) => ActiveSoundsNotifier(),
);

final isProProvider = StateProvider<bool>((ref) => false);