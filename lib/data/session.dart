import 'package:flutter/foundation.dart';

/// Une session de Focus : un créneau de travail loggé sur une tâche.
/// Chaque appui sur « Terminer la session » dans le Focus Mode en crée une.
@immutable
class Session {
  final int id;
  final int taskId;
  final DateTime startedAt;
  final int durationSeconds;

  const Session({
    required this.id,
    required this.taskId,
    required this.startedAt,
    required this.durationSeconds,
  });

  DateTime get endedAt =>
      startedAt.add(Duration(seconds: durationSeconds));

  Map<String, dynamic> toMap() => {
        'id': id,
        'taskId': taskId,
        'startedAt': startedAt.toIso8601String(),
        'durationSeconds': durationSeconds,
      };

  factory Session.fromMap(Map<String, dynamic> map) => Session(
        id: map['id'] as int,
        taskId: map['taskId'] as int,
        startedAt: DateTime.parse(map['startedAt'] as String),
        durationSeconds: map['durationSeconds'] as int,
      );
}
