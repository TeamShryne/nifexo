import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/note.dart';
import '../models/todo_item.dart';
import '../repositories/note_repository.dart';
import '../repositories/todo_repository.dart';
import '../repositories/settings_repository.dart';

class BackupService {
  final _noteRepository = NoteRepository();
  final _todoRepository = TodoRepository();
  final _settingsRepository = SettingsRepository();

  Future<void> exportNoteAsMarkdown(Note note) async {
    final tempDir = await getTemporaryDirectory();
    final fileName = '${_sanitizeFileName(note.title)}.md';
    final file = File('${tempDir.path}/$fileName');

    final content = '''
# ${note.title}
${note.tags.isNotEmpty ? '\nTags: ${note.tags.join(', ')}\n' : ''}
${note.contentMd}
''';

    await file.writeAsString(content);
    await Share.shareXFiles([XFile(file.path)], subject: note.title);
  }

  Future<void> createBackup() async {
    final notes = await _noteRepository.getAllNotes();
    final todos = await _todoRepository.getAllTodos();
    
    // Get all settings (we'll manually list keys or we could add a method to repo)
    final themeMode = await _settingsRepository.getSetting('themeMode');
    
    final backupData = {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'notes': notes.map((n) => _noteToMap(n)).toList(),
      'todos': todos.map((t) => _todoToMap(t)).toList(),
      'settings': {
        'themeMode': themeMode,
      },
    };

    final tempDir = await getTemporaryDirectory();
    final dateStr = DateFormat('yyyy-MM-dd_HH-mm').format(DateTime.now());
    final file = File('${tempDir.path}/nifexo_backup_$dateStr.json');
    
    await file.writeAsString(jsonEncode(backupData));
    await Share.shareXFiles([XFile(file.path)], subject: 'Nifexo Backup $dateStr');
  }

  Future<bool> importBackup() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result == null || result.files.single.path == null) return false;

    final file = File(result.files.single.path!);
    final content = await file.readAsString();
    final Map<String, dynamic> data = jsonDecode(content);

    if (data['version'] != 1) {
      throw Exception('Unsupported backup version');
    }

    final notesData = data['notes'] as List;
    final todosData = data['todos'] as List;
    final settingsData = data['settings'] as Map<String, dynamic>;

    // Import notes
    for (final noteMap in notesData) {
      await _noteRepository.insertNote(_noteFromMap(noteMap));
    }

    // Import todos
    for (final todoMap in todosData) {
      await _todoRepository.insertTodo(_todoFromMap(todoMap));
    }

    // Import settings
    if (settingsData['themeMode'] != null) {
      await _settingsRepository.setSetting('themeMode', settingsData['themeMode']);
    }

    return true;
  }

  String _sanitizeFileName(String name) {
    return name.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
  }

  Map<String, dynamic> _noteToMap(Note note) {
    return {
      'id': note.id,
      'title': note.title,
      'contentMd': note.contentMd,
      'tags': note.tags,
      'createdAt': note.createdAt.toIso8601String(),
      'updatedAt': note.updatedAt.toIso8601String(),
      'isPinned': note.isPinned,
      'isArchived': note.isArchived,
    };
  }

  Note _noteFromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      contentMd: map['contentMd'],
      tags: List<String>.from(map['tags']),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      isPinned: map['isPinned'] ?? false,
      isArchived: map['isArchived'] ?? false,
    );
  }

  Map<String, dynamic> _todoToMap(TodoItem todo) {
    return {
      'id': todo.id,
      'title': todo.title,
      'description': todo.description,
      'isDone': todo.isDone,
      'isPinned': todo.isPinned,
      'isArchived': todo.isArchived,
      'priority': todo.priority.index,
      'dueDate': todo.dueDate?.toIso8601String(),
      'tags': todo.tags,
      'linkedNoteId': todo.linkedNoteId,
      'createdAt': todo.createdAt.toIso8601String(),
      'updatedAt': todo.updatedAt.toIso8601String(),
    };
  }

  TodoItem _todoFromMap(Map<String, dynamic> map) {
    return TodoItem(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      isDone: map['isDone'] ?? false,
      isPinned: map['isPinned'] ?? false,
      isArchived: map['isArchived'] ?? false,
      priority: TodoPriority.values[map['priority']],
      dueDate: map['dueDate'] == null ? null : DateTime.parse(map['dueDate']),
      tags: List<String>.from(map['tags']),
      linkedNoteId: map['linkedNoteId'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}
