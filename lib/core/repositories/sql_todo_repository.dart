import 'package:nifexo/core/database/app_database.dart';
import 'package:nifexo/core/models/todo_item.dart';
import 'package:nifexo/core/repositories/todo_repository.dart';
import 'package:sqflite/sqflite.dart';

class SqlTodoRepository implements TodoRepository {
  AppDatabase get _appDatabase => AppDatabase();

  @override
  Future<List<TodoItem>> getAllTodos() async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query('todo_items', orderBy: 'createdAt DESC');
    return List.generate(maps.length, (i) => _fromMap(maps[i]));
  }

  @override
  Future<void> insertTodo(TodoItem todo) async {
    final db = await _appDatabase.database;
    await db.insert(
      'todo_items',
      _toMap(todo),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateTodo(TodoItem todo) async {
    final db = await _appDatabase.database;
    await db.update(
      'todo_items',
      _toMap(todo),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  @override
  Future<void> deleteTodo(String id) async {
    final db = await _appDatabase.database;
    await db.delete(
      'todo_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Map<String, dynamic> _toMap(TodoItem todo) {
    return {
      'id': todo.id,
      'title': todo.title,
      'description': todo.description,
      'isDone': todo.isDone ? 1 : 0,
      'isPinned': todo.isPinned ? 1 : 0,
      'isArchived': todo.isArchived ? 1 : 0,
      'priority': todo.priority.index,
      'dueDate': todo.dueDate?.toIso8601String(),
      'reminderAt': todo.reminderAt?.toIso8601String(),
      'tags': todo.tags.join(','),
      'linkedNoteId': todo.linkedNoteId,
      'createdAt': todo.createdAt.toIso8601String(),
      'updatedAt': todo.updatedAt.toIso8601String(),
    };
  }

  TodoItem _fromMap(Map<String, dynamic> map) {
    return TodoItem(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      isDone: map['isDone'] == 1,
      isPinned: map['isPinned'] == 1,
      isArchived: map['isArchived'] == 1,
      priority: TodoPriority.values[map['priority']],
      dueDate: map['dueDate'] == null ? null : DateTime.parse(map['dueDate']),
      reminderAt: map['reminderAt'] == null ? null : DateTime.parse(map['reminderAt']),
      tags: (map['tags'] as String).isEmpty ? [] : (map['tags'] as String).split(','),
      linkedNoteId: map['linkedNoteId'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}
