import 'package:flutter/foundation.dart';

import '../services/database_service.dart';
import 'session.dart';

/// Provider des sessions de Focus.
/// Backé par SQLite via [DatabaseService] (migration v2).
class SessionsProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  List<Session> _sessions = <Session>[];

  SessionsProvider() {
    _loadFromDb();
  }

  Future<void> _loadFromDb() async {
    _sessions = await _db.getAllSessions();
    notifyListeners();
  }

  List<Session> get all => List.unmodifiable(_sessions);

  /// Toutes les sessions d'aujourd'hui (du jour calendaire local).
  List<Session> get today {
    final now = DateTime.now();
    return _sessions.where((s) => _sameDay(s.startedAt, now)).toList();
  }

  /// Toutes les sessions de la semaine en cours (lundi 00:00 → dimanche 23:59).
  List<Session> get thisWeek {
    final now = DateTime.now();
    final monday =
        DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    final nextMonday = monday.add(const Duration(days: 7));
    return _sessions
        .where((s) =>
            !s.startedAt.isBefore(monday) && s.startedAt.isBefore(nextMonday))
        .toList();
  }

  List<Session> forTask(int taskId) =>
      _sessions.where((s) => s.taskId == taskId).toList();

  /// Sessions groupées par jour, du plus récent au plus ancien.
  /// La clé est minuit du jour local.
  Map<DateTime, List<Session>> groupedByDay({Iterable<Session>? source}) {
    final list = (source ?? _sessions).toList()
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    final map = <DateTime, List<Session>>{};
    for (final s in list) {
      final key = DateTime(s.startedAt.year, s.startedAt.month, s.startedAt.day);
      map.putIfAbsent(key, () => []).add(s);
    }
    return map;
  }

  Future<void> log({
    required int taskId,
    required DateTime startedAt,
    required int durationSeconds,
  }) async {
    final s = Session(
      id: DateTime.now().microsecondsSinceEpoch,
      taskId: taskId,
      startedAt: startedAt,
      durationSeconds: durationSeconds,
    );
    await _db.insertSession(s);
    await _loadFromDb();
  }

  Future<void> remove(int id) async {
    await _db.deleteSession(id);
    await _loadFromDb();
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
