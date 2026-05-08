import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:provider/provider.dart';
import 'package:goals/features/tasks/models/task_model.dart';
import 'package:goals/features/tasks/presentation/providers/task_provider.dart';
import 'package:goals/main.dart';

class FocusScreen extends StatefulWidget {
  final Task task;

  const FocusScreen({super.key, required this.task});

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> {
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();
    _startFocus();
  }

  Future<void> _startFocus() async {
    debugPrint('[FocusScreen] Starting focus session');
    await audioHandler.startFocus(widget.task.title);
  }

  Future<void> _stopFocus() async {
    if (_isFinished) return;
    _isFinished = true;

    final state = audioHandler.playbackState.value;
    final elapsedSeconds = state.position.inSeconds;
    
    debugPrint('[FocusScreen] Stopping focus session. Elapsed: $elapsedSeconds seconds');

    await audioHandler.stop();

    if (elapsedSeconds > 0) {
      final updatedTask = widget.task.copyWith(
        totalTimeSpent: widget.task.totalTimeSpent + elapsedSeconds,
      );
      
      try {
        debugPrint('[FocusScreen] Updating task in DB: ${updatedTask.id}');
        if (mounted) {
          await context.read<TaskProvider>().updateTask(updatedTask);
          debugPrint('[FocusScreen] Task updated successfully');
        }
      } catch (e) {
        debugPrint('[FocusScreen] Error updating task: $e');
      }
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Header
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: _stopFocus,
                        icon: const Icon(Icons.close),
                      ),
                      Text(
                        'Focus Mode',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 48), 
                    ],
                  ),
                  const SizedBox(height: 40),
                  Text(
                    widget.task.title,
                    style: theme.textTheme.displayMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),

              // Timer
              StreamBuilder<PlaybackState>(
                stream: audioHandler.playbackState,
                builder: (context, snapshot) {
                  final position = snapshot.data?.position ?? Duration.zero;
                  return Column(
                    children: [
                      Text(
                        _formatDuration(position),
                        style: theme.textTheme.displayLarge?.copyWith(
                          fontSize: 88,
                          fontWeight: FontWeight.w200,
                          letterSpacing: -2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'ELAPSED TIME',
                        style: theme.textTheme.labelSmall?.copyWith(
                          letterSpacing: 2,
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  );
                },
              ),

              // Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  StreamBuilder<PlaybackState>(
                    stream: audioHandler.playbackState,
                    builder: (context, snapshot) {
                      final playing = snapshot.data?.playing ?? false;
                      return IconButton.filledTonal(
                        onPressed: () {
                          if (playing) {
                            audioHandler.pause();
                          } else {
                            audioHandler.play();
                          }
                        },
                        iconSize: 56,
                        padding: const EdgeInsets.all(20),
                        icon: Icon(playing ? Icons.pause_rounded : Icons.play_arrow_rounded),
                      );
                    },
                  ),
                  const SizedBox(width: 24),
                  IconButton.filled(
                    onPressed: _stopFocus,
                    iconSize: 56,
                    padding: const EdgeInsets.all(20),
                    icon: const Icon(Icons.stop_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: theme.colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
