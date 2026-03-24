import 'package:nifexo/core/di/repository_container.dart';
import 'package:nifexo/core/models/note.dart';
import 'package:nifexo/core/models/todo_item.dart';
import 'package:nifexo/core/repositories/note_repository.dart';
import 'package:nifexo/core/repositories/todo_repository.dart';
import 'package:nifexo/core/repositories/settings_repository.dart';
import 'package:nifexo/core/services/notification_service.dart';

class MockNoteRepository implements NoteRepository {
  final List<Note> _notes = [];

  @override
  Future<List<Note>> getAllNotes() async => List.from(_notes);

  @override
  Future<void> insertNote(Note note) async {
    _notes.removeWhere((n) => n.id == note.id);
    _notes.add(note);
  }

  @override
  Future<void> updateNote(Note note) async {
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      _notes[index] = note;
    }
  }

  @override
  Future<void> deleteNote(String id) async {
    _notes.removeWhere((n) => n.id == id);
  }
}

class MockTodoRepository implements TodoRepository {
  final List<TodoItem> _todos = [];

  @override
  Future<List<TodoItem>> getAllTodos() async => List.from(_todos);

  @override
  Future<void> insertTodo(TodoItem todo) async {
    _todos.removeWhere((t) => t.id == todo.id);
    _todos.add(todo);
  }

  @override
  Future<void> updateTodo(TodoItem todo) async {
    final index = _todos.indexWhere((t) => t.id == todo.id);
    if (index != -1) {
      _todos[index] = todo;
    }
  }

  @override
  Future<void> deleteTodo(String id) async {
    _todos.removeWhere((t) => t.id == id);
  }
}

class MockSettingsRepository implements SettingsRepository {
  final Map<String, String> _settings = {};

  @override
  Future<void> setSetting(String key, String value) async {
    _settings[key] = value;
  }

  @override
  Future<String?> getSetting(String key) async {
    return _settings[key];
  }

  @override
  Future<void> deleteSetting(String key) async {
    _settings.remove(key);
  }
}

class MockNotificationService implements NotificationService {
  @override
  Future<void> init() async {}

  @override
  Future<void> scheduleTodoReminder(TodoItem todo) async {}

  @override
  Future<void> cancelTodoReminder(String todoId) async {}
}

class MockRepositoryContainer extends RepositoryContainer {
  MockRepositoryContainer({
    NoteRepository? noteRepository,
    TodoRepository? todoRepository,
    SettingsRepository? settingsRepository,
    NotificationService? notificationService,
  }) : super(
          noteRepository: noteRepository ?? MockNoteRepository(),
          todoRepository: todoRepository ?? MockTodoRepository(),
          settingsRepository: settingsRepository ?? MockSettingsRepository(),
          notificationService: notificationService ?? MockNotificationService(),
        );
}
