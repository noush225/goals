import 'package:flutter/material.dart';
import '../../models/task_model.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final ValueChanged<double>? onProgressChanged;

  const TaskItem({
    super.key,
    required this.task,
    required this.onTap,
    this.onProgressChanged,
  });

  String _formatTime(int seconds) {
    if (seconds < 60) return '${seconds}s';
    if (seconds < 3600) return '${(seconds / 60).floor()}m';
    return '${(seconds / 3600).floor()}h ${(seconds % 3600 / 60).floor()}m';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    _formatTime(task.totalTimeSpent),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              if (task.type == TaskType.progression) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: task.progressValue / 100,
                        backgroundColor: theme.colorScheme.surfaceContainerLow,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${task.progressValue.toInt()}%',
                      style: theme.textTheme.labelSmall,
                    ),
                  ],
                ),
                if (onProgressChanged != null)
                  Slider(
                    value: task.progressValue,
                    min: 0,
                    max: 100,
                    divisions: 100,
                    onChanged: onProgressChanged,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
