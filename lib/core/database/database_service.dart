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
        version: 1,
        onCreate: _onCreate,
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
      print('Creating tables...');
    }
    
    // Example table for Phase 1
    await db.execute('''
      CREATE TABLE settings(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        key TEXT UNIQUE,
        value TEXT
      )
    ''');

    if (kDebugMode) {
      print('Database tables created successfully.');
    }
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
