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

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  Future<void> startFocus(String title) async {
    if (kDebugMode) {
      print('[GoalsAudioHandler] Starting focus for: $title');
    }
    
    _elapsed = Duration.zero;

    mediaItem.add(MediaItem(
      id: 'focus_timer',
      album: 'Focus Mode',
      title: title,
      displaySubtitle: _formatDuration(_elapsed),
      artist: 'Goals App',
      duration: const Duration(hours: 100),
    ));

    _startTimer();
    
    playbackState.add(playbackState.value.copyWith(
      playing: true,
      updatePosition: Duration.zero,
      processingState: AudioProcessingState.ready,
      controls: [MediaControl.pause, MediaControl.stop],
      androidCompactActionIndices: const [0, 1],
    ));
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsed += const Duration(seconds: 1);
      
      // Update playback state for the system timer/seekbar
      playbackState.add(playbackState.value.copyWith(
        updatePosition: _elapsed,
      ));

      // Update MediaItem subtitle every second to show text timer in notification
      final currentItem = mediaItem.value;
      if (currentItem != null) {
        mediaItem.add(currentItem.copyWith(
          displaySubtitle: _formatDuration(_elapsed),
        ));
      }
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
    
    // Set mediaItem to null to dismiss the notification
    mediaItem.add(null);
    
    // Do NOT call super.stop() here as it can cause "Bad state" errors 
    // with rxdart subjects if not handled perfectly. 
    // audio_service handles the stop if mediaItem becomes null or playbackState is idle.
  }
}
