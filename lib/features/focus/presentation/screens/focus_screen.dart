import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:goals/features/tasks/models/task_model.dart';
import 'package:goals/features/tasks/presentation/providers/task_provider.dart';
import 'package:goals/core/notifications/notification_service.dart';

class FocusScreen extends StatefulWidget {
  final Task task;

  const FocusScreen({super.key, required this.task});

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> {
  bool _isFinished = false;
  bool _isPaused = false;
  int _elapsedSeconds = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startFocus();
  }

  void _startFocus() {
    debugPrint('[FocusScreen] Starting focus session');
    
    // Start native chronometer notification
    NotificationService().showFocusTimerNotification(widget.task.title);
    
    // Start UI timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && !_isPaused) {
        setState(() {
          _elapsedSeconds++;
        });
      }
    });
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
    
    if (_isPaused) {
      NotificationService().cancelFocusTimerNotification();
      // Optionally show a "Paused" notification
    } else {
      NotificationService().showFocusTimerNotification(widget.task.title);
    }
    
    debugPrint('[FocusScreen] Focus session ${_isPaused ? 'paused' : 'resumed'}');
  }

  Future<void> _stopFocus() async {
    if (_isFinished) return;
    
    // Show confirmation if significant time elapsed? Or just stop.
    // The user said "Quand on appuie sur stop ça bug", so let's be careful.
    
    setState(() {
      _isFinished = true;
      _isPaused = true;
    });

    debugPrint('[FocusScreen] Stopping focus session. Elapsed: $_elapsedSeconds seconds');

    // Stop UI timer
    _timer?.cancel();

    // Cancel native notification
    await NotificationService().cancelFocusTimerNotification();

    if (_elapsedSeconds > 0) {
      final updatedTask = widget.task.copyWith(
        ownTimeSpent: widget.task.ownTimeSpent + _elapsedSeconds,
      );
      
      try {
        debugPrint('[FocusScreen] Updating task in DB: ${updatedTask.id}');
        // Use the provider from the context before popping
        if (!mounted) return;
        final taskProvider = context.read<TaskProvider>();
        await taskProvider.updateTask(updatedTask);
        debugPrint('[FocusScreen] Task updated successfully');
      } catch (e) {
        debugPrint('[FocusScreen] Error updating task: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving time: $e')),
          );
        }
      }
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  String _formatDuration(int seconds) {
    Duration duration = Duration(seconds: seconds);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
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
                        icon: const Icon(Icons.close_rounded),
                        style: IconButton.styleFrom(
                          foregroundColor: theme.colorScheme.outline,
                        ),
                      ),
                      Text(
                        'FOCUS MODE',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(width: 48), 
                    ],
                  ),
                  const SizedBox(height: 60),
                  Text(
                    widget.task.title,
                    style: theme.textTheme.displayMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),

              // Timer
              Column(
                children: [
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: theme.textTheme.displayLarge!.copyWith(
                      fontSize: 88,
                      fontWeight: FontWeight.w200,
                      letterSpacing: -2,
                      color: _isPaused 
                          ? theme.colorScheme.outline.withOpacity(0.5)
                          : theme.colorScheme.onSurface,
                    ),
                    child: Text(_formatDuration(_elapsedSeconds)),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _isPaused ? 'PAUSED' : 'ELAPSED TIME',
                    style: theme.textTheme.labelSmall?.copyWith(
                      letterSpacing: 2,
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),

              // Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Pause/Resume Button
                  IconButton.filled(
                    onPressed: _togglePause,
                    iconSize: 32,
                    padding: const EdgeInsets.all(16),
                    icon: Icon(_isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      foregroundColor: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Stop Button
                  IconButton.filled(
                    onPressed: _stopFocus,
                    iconSize: 40,
                    padding: const EdgeInsets.all(20),
                    icon: const Icon(Icons.stop_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: theme.colorScheme.secondary,
                      foregroundColor: theme.colorScheme.onSecondary,
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
