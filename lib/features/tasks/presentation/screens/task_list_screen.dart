import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../widgets/task_item.dart';
import 'task_form_screen.dart';
import '../../../../l10n/generated/app_localizations.dart';

enum TaskFilter { today, week }

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  TaskFilter _filter = TaskFilter.today;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<TaskProvider>().loadTasks();
      }
    });
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isSameWeek(DateTime a, DateTime b) {
    final startOfWeek = b.subtract(Duration(days: b.weekday - 1));
    final endOfWeek = b.add(Duration(days: 7 - b.weekday));
    return a.isAfter(startOfWeek.subtract(const Duration(seconds: 1))) &&
        a.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          SegmentedButton<TaskFilter>(
            segments: [
              ButtonSegment(
                value: TaskFilter.today,
                label: Text(l10n.today),
              ),
              ButtonSegment(
                value: TaskFilter.week,
                label: Text(l10n.week),
              ),
            ],
            selected: {_filter},
            onSelectionChanged: (newSelection) {
              setState(() {
                _filter = newSelection.first;
              });
            },
            showSelectedIcon: false,
            style: const ButtonStyle(
              visualDensity: VisualDensity.compact,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final now = DateTime.now();
          final filteredTasks = provider.tasks.where((task) {
            if (_filter == TaskFilter.today) {
              return _isSameDay(task.date, now);
            } else {
              return _isSameWeek(task.date, now);
            }
          }).toList();

          if (filteredTasks.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  l10n.emptyTasks,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: filteredTasks.length,
            itemBuilder: (context, index) {
              final task = filteredTasks[index];
              return TaskItem(
                task: task,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TaskFormScreen(task: task),
                  ),
                ),
                onProgressChanged: (newValue) {
                  provider.updateProgress(task, newValue);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const TaskFormScreen(),
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
