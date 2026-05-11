import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/task_provider.dart';
import '../widgets/task_item.dart';
import 'task_form_screen.dart';
import 'package:goals/features/focus/presentation/screens/focus_screen.dart';
import 'package:goals/features/settings/presentation/screens/settings_screen.dart';
import 'package:goals/features/settings/presentation/providers/settings_provider.dart';
import 'package:goals/l10n/generated/app_localizations.dart';

enum TaskFilter { today, week }

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  TaskFilter _filter = TaskFilter.today;
  DateTime _referenceDate = DateTime.now();

  late TaskProvider _taskProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _taskProvider = context.read<TaskProvider>();
        _taskProvider.loadTasks();
        _taskProvider.addListener(_onTasksChanged);
      }
    });
  }

  void _onTasksChanged() {
    if (mounted) {
      final l10n = AppLocalizations.of(context);
      if (l10n != null) {
        context.read<SettingsProvider>().updateReminder(l10n);
      }
    }
  }

  @override
  void dispose() {
    _taskProvider.removeListener(_onTasksChanged);
    super.dispose();
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
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          l10n.appTitle,
          style: theme.textTheme.displayMedium?.copyWith(
            fontSize: 28,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.settings_outlined, size: 24),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined, size: 22),
            onPressed: () {
              setState(() {
                _filter = _filter == TaskFilter.today ? TaskFilter.week : TaskFilter.today;
              });
            },
            color: _filter == TaskFilter.week ? theme.colorScheme.primary : theme.colorScheme.outline,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                    onPressed: () => _navigate(-1),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: theme.colorScheme.primary,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        getHeaderTitle().toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onPressed: () => _navigate(1),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Consumer<TaskProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: theme.colorScheme.primary,
                      strokeWidth: 2,
                    ),
                  );
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
                      padding: const EdgeInsets.all(48.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.auto_awesome_mosaic_outlined,
                            size: 64,
                            color: theme.colorScheme.outline.withOpacity(0.3),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            l10n.emptyTasks,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.outline,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 100),
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
                      onStartFocus: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FocusScreen(task: task),
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
        elevation: 4,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: const Icon(Icons.add_rounded, size: 36),
      ),
    );
  }
}
