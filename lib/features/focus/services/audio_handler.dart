import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

class GoalsAudioHandler extends BaseAudioHandler {
  Timer? _timer;
  Duration _elapsed = Duration.zero;

  GoalsAudioHandler() {
    if (kDebugMode) {
      print('[GoalsAudioHandler] Initialized');
    }
  }

  Future<void> startFocus(String title) async {
    if (kDebugMode) {
      print('[GoalsAudioHandler] Starting focus for: $title');
    }
    
    mediaItem.add(MediaItem(
      id: 'focus_timer',
      album: 'Soft Focus',
      title: title,
      artist: 'Goals App',
      duration: const Duration(hours: 100),
    ));

    _elapsed = Duration.zero;
    _startTimer();
    
    playbackState.add(playbackState.value.copyWith(
      playing: true,
      updatePosition: Duration.zero,
      processingState: AudioProcessingState.ready,
      controls: [MediaControl.pause, MediaControl.stop],
    ));
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsed += const Duration(seconds: 1);
      playbackState.add(playbackState.value.copyWith(
        updatePosition: _elapsed,
      ));
    });
  }

  @override
  Future<void> play() async {
    if (kDebugMode) {
      print('[GoalsAudioHandler] Play pressed');
    }
    _startTimer();
    playbackState.add(playbackState.value.copyWith(
      playing: true,
      updatePosition: _elapsed,
    ));
  }

  @override
  Future<void> pause() async {
    if (kDebugMode) {
      print('[GoalsAudioHandler] Pause pressed');
    }
    _timer?.cancel();
    playbackState.add(playbackState.value.copyWith(
      playing: false,
      updatePosition: _elapsed,
    ));
  }

  @override
  Future<void> stop() async {
    if (kDebugMode) {
      print('[GoalsAudioHandler] Stop pressed. Final elapsed: ${_elapsed.inSeconds}s');
    }
    _timer?.cancel();
    _timer = null;
    
    playbackState.add(playbackState.value.copyWith(
      playing: false,
      processingState: AudioProcessingState.idle,
      updatePosition: _elapsed,
    ));
    
    // Clear media item after a small delay to allow notification to dismiss
    mediaItem.add(null);
    
    super.stop();
  }
}
