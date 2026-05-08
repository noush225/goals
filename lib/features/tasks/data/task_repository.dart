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
    
    // Get old task state to check if parentId changed or if time spent changed
    final oldTask = await getTaskById(task.id!);
    
    final result = await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );

    if (kDebugMode) {
      print('Task ${task.id} updated.');
    }

    // Recalculate time for old parent if it changed
    if (oldTask != null && oldTask.parentId != null && oldTask.parentId != task.parentId) {
      await _recalculateParentTime(oldTask.parentId!);
    }

    // Recalculate time for current parent
    if (task.parentId != null) {
      await _recalculateParentTime(task.parentId!);
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
  /// The parent's totalTimeSpent is its own specific time (not yet handled separately, 
  /// so currently just sum of children) + sum of children's totalTimeSpent.
  /// For this MVP, we assume a task's totalTimeSpent field in DB IS the aggregate.
  Future<void> _recalculateParentTime(int parentId) async {
    final db = await _dbService.database;
    
    // Get all direct children
    final List<Map<String, dynamic>> childrenMaps = await db.query(
      'tasks',
      where: 'parentId = ?',
      whereArgs: [parentId],
    );

    int childrenTotalTime = 0;
    for (var childMap in childrenMaps) {
      childrenTotalTime += childMap['totalTimeSpent'] as int;
    }

    // In a more complex model, the parent might have its own time spent 
    // that isn't from children. For now, we update the parent's aggregate.
    // NOTE: This logic assumes 'totalTimeSpent' stores the TOTAL (self + children).
    
    final parentTask = await getTaskById(parentId);
    if (parentTask != null) {
      // If the parent itself is a child, this will propagate up.
      // We update ONLY the aggregate part.
      await db.update(
        'tasks',
        {'totalTimeSpent': childrenTotalTime},
        where: 'id = ?',
        whereArgs: [parentId],
      );
      
      if (kDebugMode) {
        print('Recalculated time for parent $parentId: $childrenTotalTime seconds.');
      }

      if (parentTask.parentId != null) {
        await _recalculateParentTime(parentTask.parentId!);
      }
    }
  }
}
