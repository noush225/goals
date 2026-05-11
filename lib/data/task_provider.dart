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
        minutes: 215,
        date: today,
        subtasks: '6 sur 10 scènes',
      ),
      Task(
        id: 2,
        title: "Esquisser l'illustration du blog",
        type: TaskType.oneshot,
        progress: 0,
        minutes: 0,
        date: today,
      ),
      Task(
        id: 3,
        title: 'Réviser le chapitre 3 du roman',
        type: TaskType.progression,
        progress: 35,
        minutes: 142,
        date: today,
        subtasks: 'Pages 48–60',
      ),
      Task(
        id: 4,
        title: 'Enregistrer la voix off du podcast',
        type: TaskType.oneshot,
        progress: 100,
        minutes: 28,
        date: today,
      ),
      Task(
        id: 5,
        title: 'Étalonner le clip de mariage',
        type: TaskType.progression,
        progress: 15,
        minutes: 47,
        date: today.add(const Duration(days: 1)),
        subtasks: 'Acte 1 sur 3',
      ),
    ];
    notifyListeners();
  }

  List<Task> get all => List.unmodifiable(_tasks);

  /// Tâches « du jour » — on prend les 4 premières comme dans app.jsx.
  List<Task> get today => _tasks.take(4).toList(growable: false);

  /// Tâches « de la semaine » — toutes.
  List<Task> get week => List.unmodifiable(_tasks);

  int get doneCount => _tasks.where((t) => t.isDone).length;
  int get totalMinutes => _tasks.fold(0, (s, t) => s + t.minutes);

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
      minutes: 0,
      date: date,
      parentId: parentId,
    );
    _tasks = [task, ..._tasks];
    notifyListeners();
  }

  /// Ajoute la durée d'une session (en secondes) à la tâche correspondante.
  void logSession(int taskId, int seconds) {
    final addedMinutes = (seconds / 60).ceil().clamp(1, 24 * 60);
    _tasks = [
      for (final t in _tasks)
        if (t.id == taskId)
          t.copyWith(minutes: t.minutes + addedMinutes)
        else
          t,
    ];
    notifyListeners();
  }

  void remove(int id) {
    _tasks = _tasks.where((t) => t.id != id).toList(growable: false);
    notifyListeners();
  }
}
