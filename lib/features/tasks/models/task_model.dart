enum TaskType {
  oneshot,
  progression,
}

class Task {
  final int? id;
  final String title;
  final DateTime date;
  final TaskType type;
  final double progressValue;
  final int? parentId;
  final int totalTimeSpent; // Aggregate time (self + children) in seconds
  final int ownTimeSpent; // Time spent directly on this task in seconds

  Task({
    this.id,
    required this.title,
    required this.date,
    required this.type,
    this.progressValue = 0.0,
    this.parentId,
    this.totalTimeSpent = 0,
    this.ownTimeSpent = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'type': type.name,
      'progressValue': progressValue,
      'parentId': parentId,
      'totalTimeSpent': totalTimeSpent,
      'ownTimeSpent': ownTimeSpent,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int?,
      title: map['title'] as String,
      date: DateTime.parse(map['date'] as String),
      type: TaskType.values.byName(map['type'] as String),
      progressValue: (map['progressValue'] as num).toDouble(),
      parentId: map['parentId'] as int?,
      totalTimeSpent: map['totalTimeSpent'] as int? ?? 0,
      ownTimeSpent: map['ownTimeSpent'] as int? ?? 0,
    );
  }

  Task copyWith({
    int? id,
    String? title,
    DateTime? date,
    TaskType? type,
    double? progressValue,
    int? parentId,
    int? totalTimeSpent,
    int? ownTimeSpent,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      type: type ?? this.type,
      progressValue: progressValue ?? this.progressValue,
      parentId: parentId ?? this.parentId,
      totalTimeSpent: totalTimeSpent ?? this.totalTimeSpent,
      ownTimeSpent: ownTimeSpent ?? this.ownTimeSpent,
    );
  }
}
