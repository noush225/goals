import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../data/session.dart';
import '../data/task.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'momentum_goals.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks(
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        type TEXT NOT NULL,
        progress INTEGER NOT NULL,
        seconds INTEGER NOT NULL,
        date TEXT NOT NULL,
        parentId INTEGER,
        subtasks TEXT,
        status TEXT NOT NULL DEFAULT 'active',
        completedAt TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE sessions(
        id INTEGER PRIMARY KEY,
        taskId INTEGER NOT NULL,
        startedAt TEXT NOT NULL,
        durationSeconds INTEGER NOT NULL
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_sessions_startedAt ON sessions(startedAt DESC)',
    );
    await db.execute(
      'CREATE INDEX idx_sessions_taskId ON sessions(taskId)',
    );
  }

  /// Migration de v1 → v2 : ajoute status + completedAt sur tasks, crée sessions.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        "ALTER TABLE tasks ADD COLUMN status TEXT NOT NULL DEFAULT 'active'",
      );
      await db.execute(
        'ALTER TABLE tasks ADD COLUMN completedAt TEXT',
      );
      await db.execute('''
        CREATE TABLE sessions(
          id INTEGER PRIMARY KEY,
          taskId INTEGER NOT NULL,
          startedAt TEXT NOT NULL,
          durationSeconds INTEGER NOT NULL
        )
      ''');
      await db.execute(
        'CREATE INDEX idx_sessions_startedAt ON sessions(startedAt DESC)',
      );
      await db.execute(
        'CREATE INDEX idx_sessions_taskId ON sessions(taskId)',
      );
    }
  }

  // ─── Tasks ────────────────────────────────────────────────────────────────

  Future<List<Task>> getAllTasks() async {
    final db = await database;
    final maps = await db.query('tasks');
    return maps.map((m) => Task.fromMap(m)).toList();
  }

  Future<void> insertTask(Task task) async {
    final db = await database;
    await db.insert(
      'tasks',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateTask(Task task) async {
    final db = await database;
    await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<void> deleteTask(int id) async {
    final db = await database;
    await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
    // On supprime aussi les sessions orphelines liées à cette tâche
    await db.delete('sessions', where: 'taskId = ?', whereArgs: [id]);
  }

  // ─── Sessions ─────────────────────────────────────────────────────────────

  Future<List<Session>> getAllSessions() async {
    final db = await database;
    final maps = await db.query('sessions', orderBy: 'startedAt DESC');
    return maps.map((m) => Session.fromMap(m)).toList();
  }

  Future<void> insertSession(Session s) async {
    final db = await database;
    await db.insert(
      'sessions',
      s.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteSession(int id) async {
    final db = await database;
    await db.delete('sessions', where: 'id = ?', whereArgs: [id]);
  }

  /// Efface toutes les sessions ET remet le compteur `seconds` de toutes les
  /// tâches à 0 (les tâches elles-mêmes ne sont PAS supprimées).
  Future<void> resetAllTime() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('sessions');
      await txn.update('tasks', {'seconds': 0});
    });
  }
}
