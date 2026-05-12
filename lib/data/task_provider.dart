import 'package:flutter/foundation.dart';
import '../services/database_service.dart';
import 'task.dart';

/// Provider gérant les tâches avec persistance SQLite.
class TaskProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  List<Task> _tasks = <Task>[];

  TaskProvider() {
    _loadFromDb();
  }

  Future<void> _loadFromDb() async {
    _tasks = await _db.getAllTasks();
    notifyListeners();
  }

  /// Repeuple le store avec des exemples (uniquement si vide).
  Future<void> seedDemoTasks() async {
    if (_tasks.isNotEmpty) return;
    
    final today = DateTime.now();
    final demoTasks = [
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
    ];

    for (var t in demoTasks) {
      await _db.insertTask(t);
    }
    await _loadFromDb();
  }

  List<Task> get all => List.unmodifiable(_tasks);

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isWithinWeek(DateTime date, DateTime reference) {
    final startOfWeek = reference.subtract(Duration(days: reference.weekday - 1));
    final startOfDay = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final endOfWeek = startOfDay.add(const Duration(days: 7));
    return (date.isAtSameMomentAs(startOfDay) || date.isAfter(startOfDay)) &&
        date.isBefore(endOfWeek);
  }

  /// Tâches racines (sans parent) pour l'affichage principal
  List<Task> get roots => _tasks.where((t) => t.parentId == null).toList();

  /// Racines actives (non terminées).
  List<Task> get activeRoots =>
      roots.where((t) => t.status == TaskStatus.active).toList();

  /// Tâches terminées (toutes, racines ou enfants), triées par date de complétion desc.
  List<Task> get doneTasks {
    final list = _tasks.where((t) => t.status == TaskStatus.done).toList();
    list.sort((a, b) {
      final ax = a.completedAt ?? a.date;
      final bx = b.completedAt ?? b.date;
      return bx.compareTo(ax);
    });
    return list;
  }

  /// Racines terminées (pour la section repliable).
  List<Task> get doneRoots =>
      doneTasks.where((t) => t.parentId == null).toList();

  /// Tâches racines du jour
  List<Task> get today {
    final now = DateTime.now();
    return roots.where((t) => _isSameDay(t.date, now)).toList();
  }

  /// Tâches racines de la semaine
  List<Task> get week {
    final now = DateTime.now();
    return roots.where((t) => _isWithinWeek(t.date, now)).toList();
  }

  /// Retourne les enfants d'une tâche
  List<Task> childrenOf(int parentId) => 
      _tasks.where((t) => t.parentId == parentId).toList();

  /// Calcule le temps TOTAL d'une tâche (le sien + celui de ses descendants)
  int aggregateSeconds(int taskId) {
    final task = byId(taskId);
    if (task == null) return 0;
    
    int total = task.seconds;
    final children = childrenOf(taskId);
    for (var child in children) {
      total += aggregateSeconds(child.id);
    }
    return total;
  }

  /// Le dashboard ne compte que le temps "propre" total de TOUTES les tâches
  /// pour éviter de compter deux fois le temps des enfants.
  int get totalSeconds => _tasks.fold(0, (s, t) => s + t.seconds);

  int get doneCount => _tasks.where((t) => t.isDone).length;

  /// Marque (ou démarque) une tâche comme terminée.
  Future<void> setStatus(int taskId, TaskStatus status) async {
    final t = byId(taskId);
    if (t == null) return;
    final updated = t.copyWith(
      status: status,
      completedAt: status == TaskStatus.done ? DateTime.now() : null,
      clearCompletedAt: status == TaskStatus.active,
      // Pour une Progression, marquer done = pousser à 100% pour cohérence visuelle.
      progress: status == TaskStatus.done && t.isProgression
          ? 100
          : t.progress,
    );
    await _db.updateTask(updated);
    await _loadFromDb();
  }

  /// Recharge depuis la DB. Utile après un reset global du temps via
  /// [SessionsProvider.clearAll], qui modifie aussi le `seconds` des tasks
  /// directement en base.
  Future<void> reload() => _loadFromDb();

  /// Recherche full-text simple (case-insensitive, sur le titre).
  List<Task> search(String query, {bool onlyRoots = true}) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return onlyRoots ? activeRoots : _tasks;
    final pool = onlyRoots ? activeRoots : _tasks;
    return pool.where((t) => t.title.toLowerCase().contains(q)).toList();
  }

  List<Task> candidatesAsParent({int? excludingId}) =>
      _tasks.where((t) => t.id != excludingId).toList(growable: false);

  Task? byId(int id) {
    for (final t in _tasks) {
      if (t.id == id) return t;
    }
    return null;
  }

  Future<void> add({
    required String title,
    required TaskType type,
    required int progress,
    required DateTime date,
    int? parentId,
  }) async {
    final task = Task(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title.trim(),
      type: type,
      progress: type == TaskType.progression ? progress : 0,
      seconds: 0,
      date: date,
      parentId: parentId,
    );
    await _db.insertTask(task);
    await _loadFromDb();
  }

  Future<void> update({
    required int id,
    required String title,
    required TaskType type,
    required int progress,
    required DateTime date,
    int? parentId,
  }) async {
    final existing = byId(id);
    if (existing == null) return;

    final newProgress = type == TaskType.progression ? progress : 0;
    // Auto-done : si une Progression atteint 100%, on la marque terminée.
    final shouldAutoDone =
        type == TaskType.progression && newProgress >= 100;
    final newStatus = shouldAutoDone ? TaskStatus.done : existing.status;

    final updated = existing.copyWith(
      title: title.trim(),
      type: type,
      progress: newProgress,
      date: date,
      parentId: parentId,
      status: newStatus,
      completedAt: shouldAutoDone && existing.completedAt == null
          ? DateTime.now()
          : existing.completedAt,
    );

    await _db.updateTask(updated);
    await _loadFromDb();
  }

  Future<void> logSession(int taskId, int seconds) async {
    final t = byId(taskId);
    if (t != null) {
      final updated = t.copyWith(seconds: t.seconds + seconds);
      await _db.updateTask(updated);
      await _loadFromDb();
    }
  }

  Future<void> remove(int id) async {
    // Si on supprime un parent, on pourrait soit supprimer les enfants (cascade)
    // soit les "libérer". Ici on choisit la cascade pour la simplicité.
    final children = childrenOf(id);
    for (var child in children) {
      await remove(child.id);
    }
    
    await _db.deleteTask(id);
    await _loadFromDb();
  }
}
