import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'sound_providers.dart';

class TimerState {
  final int selectedMinutes;
  final int remainingSeconds;
  final bool isRunning;

  const TimerState({
    this.selectedMinutes = 0,
    this.remainingSeconds = 0,
    this.isRunning = false,
  });

  TimerState copyWith({int? selectedMinutes, int? remainingSeconds, bool? isRunning}) {
    return TimerState(
      selectedMinutes: selectedMinutes ?? this.selectedMinutes,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isRunning: isRunning ?? this.isRunning,
    );
  }

  String get formattedTime {
    final h = remainingSeconds ~/ 3600;
    final m = (remainingSeconds % 3600) ~/ 60;
    final s = remainingSeconds % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

class TimerNotifier extends StateNotifier<TimerState> {
  final Ref ref;
  Timer? _timer;

  TimerNotifier(this.ref) : super(const TimerState());

  void startTimer(int minutes) {
    _timer?.cancel();
    state = TimerState(
      selectedMinutes: minutes,
      remainingSeconds: minutes * 60,
      isRunning: true,
    );
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    if (state.remainingSeconds <= 1) {
      _timer?.cancel();
      ref.read(activeSoundsProvider.notifier).stopAll();
      state = const TimerState();
    } else {
      state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
    }
  }

  void cancelTimer() {
    _timer?.cancel();
    state = const TimerState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final timerProvider = StateNotifierProvider<TimerNotifier, TimerState>(
      (ref) => TimerNotifier(ref),
);