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
  int _elapsedSeconds = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startFocus();
  }

  Future<void> _startFocus() async {
    debugPrint('[FocusScreen] Starting focus session');
    
    // Start native chronometer notification
    await NotificationService().showFocusTimerNotification(widget.task.title);
    
    // Start UI timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _elapsedSeconds++;
        });
      }
    });
  }

  Future<void> _stopFocus() async {
    if (_isFinished) return;
    _isFinished = true;

    debugPrint('[FocusScreen] Stopping focus session. Elapsed: $_elapsedSeconds seconds');

    // Stop UI timer
    _timer?.cancel();

    // Cancel native notification
    await NotificationService().cancelFocusTimerNotification();

    if (_elapsedSeconds > 0) {
      final updatedTask = widget.task.copyWith(
        totalTimeSpent: widget.task.totalTimeSpent + _elapsedSeconds,
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
              Column(
                children: [
                  Text(
                    _formatDuration(_elapsedSeconds),
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
              ),

              // Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Play/Pause not implemented for pure Timer yet, but we could add it.
                  // For now, simple Stop as requested.
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
