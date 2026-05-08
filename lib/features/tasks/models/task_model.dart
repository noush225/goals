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
  final int totalTimeSpent; // In seconds

  Task({
    this.id,
    required this.title,
    required this.date,
    required this.type,
    this.progressValue = 0.0,
    this.parentId,
    this.totalTimeSpent = 0,
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
      totalTimeSpent: map['totalTimeSpent'] as int,
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
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      type: type ?? this.type,
      progressValue: progressValue ?? this.progressValue,
      parentId: parentId ?? this.parentId,
      totalTimeSpent: totalTimeSpent ?? this.totalTimeSpent,
    );
  }
}
