import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/task_model.dart';
import '../providers/task_provider.dart';
import '../../../../l10n/generated/app_localizations.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? task;

  const TaskFormScreen({super.key, this.task});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late DateTime _date;
  late TaskType _type;
  late double _progressValue;
  int? _parentId;

  @override
  void initState() {
    super.initState();
    _title = widget.task?.title ?? '';
    _date = widget.task?.date ?? DateTime.now();
    _type = widget.task?.type ?? TaskType.oneshot;
    _progressValue = widget.task?.progressValue ?? 0.0;
    _parentId = widget.task?.parentId;
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final provider = context.read<TaskProvider>();
      
      final task = Task(
        id: widget.task?.id,
        title: _title,
        date: _date,
        type: _type,
        parentId: _parentId,
        progressValue: _type == TaskType.progression ? _progressValue : 0.0,
        totalTimeSpent: widget.task?.totalTimeSpent ?? 0,
      );

      if (widget.task == null) {
        provider.addTask(task);
      } else {
        provider.updateTask(task);
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final provider = context.watch<TaskProvider>();

    final availableParents = provider.tasks
        .where((t) => t.id != null && t.id != widget.task?.id)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? l10n.addTask : l10n.editTask),
        actions: [
          if (widget.task != null && widget.task!.id != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                context.read<TaskProvider>().deleteTask(widget.task!.id!);
                Navigator.pop(context);
              },
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            TextFormField(
              initialValue: _title,
              decoration: InputDecoration(labelText: l10n.title),
              validator: (value) => 
                  (value == null || value.isEmpty) ? l10n.requiredField : null,
              onSaved: (value) => _title = value!,
            ),
            const SizedBox(height: 24),
            ListTile(
              title: Text(l10n.date),
              subtitle: Text(DateFormat.yMMMMd(l10n.localeName).format(_date)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() => _date = picked);
                }
              },
            ),
            const SizedBox(height: 24),
            Text(l10n.type, style: theme.textTheme.labelSmall),
            const SizedBox(height: 8),
            SegmentedButton<TaskType>(
              segments: [
                ButtonSegment(
                  value: TaskType.oneshot,
                  label: Text(l10n.oneShot),
                ),
                ButtonSegment(
                  value: TaskType.progression,
                  label: Text(l10n.progression),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (newSelection) {
                setState(() => _type = newSelection.first);
              },
              showSelectedIcon: false,
            ),
            if (_type == TaskType.progression) ...[
              const SizedBox(height: 24),
              Text(
                l10n.progress(_progressValue.toInt().toString()),
                style: theme.textTheme.labelSmall,
              ),
              Slider(
                value: _progressValue,
                min: 0,
                max: 100,
                divisions: 100,
                label: '${_progressValue.toInt()}%',
                onChanged: (value) {
                  setState(() => _progressValue = value);
                },
              ),
            ],
            const SizedBox(height: 24),
            DropdownButtonFormField<int?>(
              value: _parentId,
              decoration: InputDecoration(labelText: l10n.parentTask),
              items: [
                DropdownMenuItem<int?>(
                  value: null,
                  child: Text(l10n.none),
                ),
                ...availableParents.map((t) => DropdownMenuItem<int?>(
                  value: t.id,
                  child: Text(t.title),
                )),
              ],
              onChanged: (value) => setState(() => _parentId = value),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _saveForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }
}
