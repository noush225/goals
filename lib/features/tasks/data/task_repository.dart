import 'package:flutter/foundation.dart';
import '../../../core/database/database_service.dart';
import '../models/task_model.dart';

class TaskRepository {
  final DatabaseService _dbService;

  TaskRepository({DatabaseService? dbService})
      : _dbService = dbService ?? DatabaseService();

  Future<int> createTask(Task task) async {
    final db = await _dbService.database;
    final id = await db.insert('tasks', task.toMap());
    
    if (kDebugMode) {
      print('Task created with id: $id');
    }

    if (task.parentId != null) {
      await _recalculateParentTime(task.parentId!);
    }
    
    return id;
  }

  Future<List<Task>> getAllTasks() async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query('tasks');
    
    return List.generate(maps.length, (i) {
      return Task.fromMap(maps[i]);
    });
  }

  Future<Task?> getTaskById(int id) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return Task.fromMap(maps.first);
  }

  Future<int> updateTask(Task task) async {
    final db = await _dbService.database;
    
    // Get old task state to check if parentId changed
    final oldTask = await getTaskById(task.id!);
    
    // First, recalculate the totalTimeSpent for THIS task to ensure it's correct
    // (it should be its ownTimeSpent + sum of its children's totalTimeSpent)
    final List<Map<String, dynamic>> childrenMaps = await db.query(
      'tasks',
      where: 'parentId = ?',
      whereArgs: [task.id],
    );

    int childrenTotalTime = 0;
    for (var childMap in childrenMaps) {
      childrenTotalTime += childMap['totalTimeSpent'] as int;
    }

    final taskToUpdate = task.copyWith(
      totalTimeSpent: task.ownTimeSpent + childrenTotalTime,
    );

    final result = await db.update(
      'tasks',
      taskToUpdate.toMap(),
      where: 'id = ?',
      whereArgs: [taskToUpdate.id],
    );

    if (kDebugMode) {
      print('Task ${taskToUpdate.id} updated. Own: ${taskToUpdate.ownTimeSpent}, Total: ${taskToUpdate.totalTimeSpent}');
    }

    // Recalculate time for old parent if it changed
    if (oldTask != null && oldTask.parentId != null && oldTask.parentId != taskToUpdate.parentId) {
      await _recalculateParentTime(oldTask.parentId!);
    }

    // Recalculate time for current parent
    if (taskToUpdate.parentId != null) {
      await _recalculateParentTime(taskToUpdate.parentId!);
    }

    return result;
  }

  Future<int> deleteTask(int id) async {
    final db = await _dbService.database;
    
    final task = await getTaskById(id);
    
    final result = await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (kDebugMode) {
      print('Task $id deleted.');
    }

    if (task != null && task.parentId != null) {
      await _recalculateParentTime(task.parentId!);
    }

    return result;
  }

  /// Recursively recalculates and updates the totalTimeSpent of a parent task.
  Future<void> _recalculateParentTime(int parentId) async {
    final db = await _dbService.database;
    
    final parentTask = await getTaskById(parentId);
    if (parentTask == null) return;

    // Get all direct children
    final List<Map<String, dynamic>> childrenMaps = await db.query(
      'tasks',
      where: 'parentId = ?',
      whereArgs: [parentId],
    );

    int childrenTotalTime = 0;
    for (var childMap in childrenMaps) {
      childrenTotalTime += childMap['totalTimeSpent'] as int? ?? 0;
    }

    final int newTotalTime = parentTask.ownTimeSpent + childrenTotalTime;
    
    await db.update(
      'tasks',
      {'totalTimeSpent': newTotalTime},
      where: 'id = ?',
      whereArgs: [parentId],
    );
    
    if (kDebugMode) {
      print('Recalculated time for parent $parentId: Own=${parentTask.ownTimeSpent}, Children=$childrenTotalTime, Total=$newTotalTime');
    }

    if (parentTask.parentId != null) {
      await _recalculateParentTime(parentTask.parentId!);
    }
  }
}
