import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
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
  DateTime _referenceDate = DateTime.now();

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
    return (a.isAfter(startOfWeek.subtract(const Duration(seconds: 1))) || _isSameDay(a, startOfWeek)) &&
        (a.isBefore(endOfWeek.add(const Duration(days: 1))) || _isSameDay(a, endOfWeek));
  }

  void _navigate(int delta) {
    setState(() {
      if (_filter == TaskFilter.today) {
        _referenceDate = _referenceDate.add(Duration(days: delta));
      } else {
        _referenceDate = _referenceDate.add(Duration(days: delta * 7));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    String getHeaderTitle() {
      if (_filter == TaskFilter.today) {
        return DateFormat.yMMMMd(l10n.localeName).format(_referenceDate);
      } else {
        final start = _referenceDate.subtract(Duration(days: _referenceDate.weekday - 1));
        final end = _referenceDate.add(Duration(days: 7 - _referenceDate.weekday));
        return '${DateFormat.MMMd(l10n.localeName).format(start)} - ${DateFormat.yMMMMd(l10n.localeName).format(end)}';
      }
    }

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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => _navigate(-1),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      getHeaderTitle(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => _navigate(1),
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<TaskProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final filteredTasks = provider.tasks.where((task) {
                  if (_filter == TaskFilter.today) {
                    return _isSameDay(task.date, _referenceDate);
                  } else {
                    return _isSameWeek(task.date, _referenceDate);
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
                      showDate: _filter == TaskFilter.week,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TaskFormScreen(task: task),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
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
