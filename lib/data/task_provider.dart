import 'package:flutter/foundation.dart';
import 'task.dart';

/// Provider in-memory pour les tâches du MVP.
///
/// Pour repeupler avec des exemples de démo, appelle [seedDemoTasks] depuis
/// `main.dart` ou un menu debug.
class TaskProvider extends ChangeNotifier {
  TaskProvider();

  List<Task> _tasks = <Task>[];

  /// Repeuple le store avec 5 tâches d'exemple (FR).
  /// Utile pour les screenshots ou la démo du Focus Mode sans avoir
  /// à créer manuellement une tâche.
  void seedDemoTasks() {
    final today = DateTime.now();
    _tasks = [
      Task(
        id: 1,
        title: "Storyboarder la séquence d'ouverture",
        type: TaskType.progression,
        progress: 60,
        seconds: 215 * 60,
        date: today,
        subtasks: '6 sur 10 scènes',
      ),
      Task(
        id: 2,
        title: "Esquisser l'illustration du blog",
        type: TaskType.oneshot,
        progress: 0,
        seconds: 0,
        date: today,
      ),
      Task(
        id: 3,
        title: 'Réviser le chapitre 3 du roman',
        type: TaskType.progression,
        progress: 35,
        seconds: 142 * 60,
        date: today,
        subtasks: 'Pages 48–60',
      ),
      Task(
        id: 4,
        title: 'Enregistrer la voix off du podcast',
        type: TaskType.oneshot,
        progress: 100,
        seconds: 28 * 60,
        date: today,
      ),
      Task(
        id: 5,
        title: 'Étalonner le clip de mariage',
        type: TaskType.progression,
        progress: 15,
        seconds: 47 * 60,
        date: today.add(const Duration(days: 1)),
        subtasks: 'Acte 1 sur 3',
      ),
    ];
    notifyListeners();
  }

  List<Task> get all => List.unmodifiable(_tasks);

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isWithinWeek(DateTime date, DateTime reference) {
    // On considère la semaine du lundi au dimanche
    final startOfWeek = reference.subtract(Duration(days: reference.weekday - 1));
    final startOfDay = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final endOfWeek = startOfDay.add(const Duration(days: 7));
    return (date.isAtSameMomentAs(startOfDay) || date.isAfter(startOfDay)) &&
        date.isBefore(endOfWeek);
  }

  /// Tâches « du jour »
  List<Task> get today {
    final now = DateTime.now();
    return _tasks.where((t) => _isSameDay(t.date, now)).toList();
  }

  /// Tâches « de la semaine »
  List<Task> get week {
    final now = DateTime.now();
    return _tasks.where((t) => _isWithinWeek(t.date, now)).toList();
  }

  int get doneCount => _tasks.where((t) => t.isDone).length;
  int get totalSeconds => _tasks.fold(0, (s, t) => s + t.seconds);

  /// Liste utilisable comme parent task (toutes sauf l'enfant lui-même).
  List<Task> candidatesAsParent({int? excludingId}) =>
      _tasks.where((t) => t.id != excludingId).toList(growable: false);

  Task? byId(int id) {
    for (final t in _tasks) {
      if (t.id == id) return t;
    }
    return null;
  }

  void add({
    required String title,
    required TaskType type,
    required int progress,
    required DateTime date,
    int? parentId,
  }) {
    final task = Task(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title.trim(),
      type: type,
      progress: type == TaskType.progression ? progress : 0,
      seconds: 0,
      date: date,
      parentId: parentId,
    );
    _tasks = [task, ..._tasks];
    notifyListeners();
  }

  void update({
    required int id,
    required String title,
    required TaskType type,
    required int progress,
    required DateTime date,
    int? parentId,
  }) {
    _tasks = [
      for (final t in _tasks)
        if (t.id == id)
          t.copyWith(
            title: title.trim(),
            type: type,
            progress: type == TaskType.progression ? progress : 0,
            date: date,
            parentId: parentId,
          )
        else
          t,
    ];
    notifyListeners();
  }

  /// Ajoute la durée d'une session (en secondes) à la tâche correspondante.
  void logSession(int taskId, int seconds) {
    _tasks = [
      for (final t in _tasks)
        if (t.id == taskId)
          t.copyWith(seconds: t.seconds + seconds)
        else
          t,
    ];
    notifyListeners();
  }

  void remove(int id) {
    _tasks = _tasks.where((t) => t.id != id).toList();
    notifyListeners();
  }
}
