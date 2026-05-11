import 'package:flutter/foundation.dart';

enum TaskType { oneshot, progression }

@immutable
class Task {
  final int id;
  final String title;
  final TaskType type;
  final int progress; // 0..100
  final int seconds; // total time logged in seconds
  final int? parentId;
  final DateTime date;
  final String? subtasks; // libre, e.g. "6 sur 10 scènes"

  const Task({
    required this.id,
    required this.title,
    required this.type,
    required this.progress,
    required this.seconds,
    required this.date,
    this.parentId,
    this.subtasks,
  });

  bool get isProgression => type == TaskType.progression;
  bool get isDone => progress >= 100;

  Task copyWith({
    String? title,
    TaskType? type,
    int? progress,
    int? seconds,
    int? parentId,
    DateTime? date,
    String? subtasks,
    bool clearParent = false,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      type: type ?? this.type,
      progress: progress ?? this.progress,
      seconds: seconds ?? this.seconds,
      parentId: clearParent ? null : (parentId ?? this.parentId),
      date: date ?? this.date,
      subtasks: subtasks ?? this.subtasks,
    );
  }
}
