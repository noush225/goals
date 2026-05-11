import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';

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
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'goals_database.db');

      if (kDebugMode) {
        print('Initializing database at: $path');
      }

      return await openDatabase(
        path,
        version: 3,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing database: $e');
      }
      rethrow;
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    if (kDebugMode) {
      print('Creating database version $version...');
    }
    
    await db.execute('''
      CREATE TABLE settings(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        key TEXT UNIQUE,
        value TEXT
      )
    ''');

    await _createTasksTable(db);

    if (kDebugMode) {
      print('Database tables created successfully.');
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (kDebugMode) {
      print('Upgrading database from $oldVersion to $newVersion...');
    }
    if (oldVersion < 2) {
      await _createTasksTable(db);
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE tasks ADD COLUMN ownTimeSpent INTEGER DEFAULT 0');
    }
  }

  Future<void> _createTasksTable(Database db) async {
    await db.execute('''
      CREATE TABLE tasks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        date TEXT NOT NULL,
        type TEXT NOT NULL,
        progressValue REAL DEFAULT 0.0,
        parentId INTEGER,
        totalTimeSpent INTEGER DEFAULT 0,
        ownTimeSpent INTEGER DEFAULT 0,
        FOREIGN KEY (parentId) REFERENCES tasks (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<bool> checkConnection() async {
    try {
      final db = await database;
      return db.isOpen;
    } catch (e) {
      if (kDebugMode) {
        print('Database connection check failed: $e');
      }
      return false;
    }
  }
}
