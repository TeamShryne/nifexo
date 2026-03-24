import '../database/app_database.dart';
import '../models/note.dart';
import 'package:sqflite/sqflite.dart';

class NoteRepository {
  final AppDatabase _appDatabase = AppDatabase();

  Future<List<Note>> getAllNotes() async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query('notes', orderBy: 'createdAt DESC');
    return List.generate(maps.length, (i) => _fromMap(maps[i]));
  }

  Future<void> insertNote(Note note) async {
    final db = await _appDatabase.database;
    await db.insert(
      'notes',
      _toMap(note),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateNote(Note note) async {
    final db = await _appDatabase.database;
    await db.update(
      'notes',
      _toMap(note),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<void> deleteNote(String id) async {
    final db = await _appDatabase.database;
    await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Map<String, dynamic> _toMap(Note note) {
    return {
      'id': note.id,
      'title': note.title,
      'contentMd': note.contentMd,
      'tags': note.tags.join(','),
      'createdAt': note.createdAt.toIso8601String(),
      'updatedAt': note.updatedAt.toIso8601String(),
      'isPinned': note.isPinned ? 1 : 0,
      'isArchived': note.isArchived ? 1 : 0,
    };
  }

  Note _fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      contentMd: map['contentMd'],
      tags: (map['tags'] as String).isEmpty ? [] : (map['tags'] as String).split(','),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      isPinned: map['isPinned'] == 1,
      isArchived: map['isArchived'] == 1,
    );
  }
}
