import 'package:flutter/material.dart';

import 'package:nifexo/core/models/note.dart';
import 'package:nifexo/core/models/todo_item.dart';
import 'package:nifexo/features/home/presentation/home_screen.dart';
import 'package:nifexo/features/notes/presentation/notes_screen.dart';
import 'package:nifexo/features/search/presentation/search_screen.dart';
import 'package:nifexo/features/settings/presentation/settings_screen.dart';
import 'package:nifexo/features/todos/presentation/todos_screen.dart';
import 'theme.dart';

import 'package:nifexo/core/di/repository_container.dart';
import 'package:nifexo/core/services/notification_service.dart';
import 'package:nifexo/core/services/backup_service.dart';

class NifexoApp extends StatefulWidget {
  const NifexoApp({super.key, this.repositories});

  final RepositoryContainer? repositories;

  @override
  State<NifexoApp> createState() => _NifexoAppState();
}

class _NifexoAppState extends State<NifexoApp> {
  ThemeMode _themeMode = ThemeMode.light;
  late final RepositoryContainer _repositories;

  @override
  void initState() {
    super.initState();
    _repositories = widget.repositories ?? RepositoryContainer.prod();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final themeMode = await _repositories.settingsRepository.getSetting('themeMode');
      if (themeMode != null && mounted) {
        setState(() {
          _themeMode = themeMode == 'dark' ? ThemeMode.dark : ThemeMode.light;
        });
      }
    } catch (e) {
      debugPrint('Failed to load settings: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nifexo',
      debugShowCheckedModeBanner: false,
      theme: buildNifexoTheme(brightness: Brightness.light),
      darkTheme: buildNifexoTheme(brightness: Brightness.dark),
      themeMode: _themeMode,
      home: AlphaShell(
        repositories: _repositories,
        isDarkMode: _themeMode == ThemeMode.dark,
        onThemeModeChanged: (enabled) async {
          final newMode = enabled ? ThemeMode.dark : ThemeMode.light;
          await _repositories.settingsRepository.setSetting('themeMode', enabled ? 'dark' : 'light');
          setState(() {
            _themeMode = newMode;
          });
        },
      ),
    );
  }
}

class AlphaShell extends StatefulWidget {
  const AlphaShell({
    super.key,
    required this.repositories,
    required this.isDarkMode,
    required this.onThemeModeChanged,
  });

  final RepositoryContainer repositories;
  final bool isDarkMode;
  final ValueChanged<bool> onThemeModeChanged;

  @override
  State<AlphaShell> createState() => _AlphaShellState();
}

class _AlphaShellState extends State<AlphaShell> {
  int _currentIndex = 0;
  List<Note> _notes = [];
  List<TodoItem> _todos = [];
  late final BackupService _backupService;

  @override
  void initState() {
    super.initState();
    _backupService = BackupService(
      noteRepository: widget.repositories.noteRepository,
      todoRepository: widget.repositories.todoRepository,
      settingsRepository: widget.repositories.settingsRepository,
    );
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      var notes = await widget.repositories.noteRepository.getAllNotes();
      final todos = await widget.repositories.todoRepository.getAllTodos();

      if (notes.isEmpty) {
        await _insertExampleNote();
        notes = await widget.repositories.noteRepository.getAllNotes();
      }

      if (mounted) {
        setState(() {
          _notes = notes;
          _todos = todos;
        });
      }
    } catch (e) {
      debugPrint('Failed to load data: $e');
    }
  }

  Future<void> _insertExampleNote() async {
    final now = DateTime.now();
    final exampleNote = Note(
      id: 'welcome-note',
      title: 'Welcome to Nifexo! 🚀',
      contentMd: '''
# Discover Markdown Power

Nifexo supports rich markdown rendering, including **maths and stuff**.

## 1. LaTeX Math Rendering
Display complex formulas beautifully:

**Block Math:**
\$\$
x = \\frac{-b \\pm \\sqrt{b^2-4ac}}{2a}
\$\$

**Inline Math:** The area of a circle is \$A = \\pi r^2\$.

## 2. Advanced Lists
- Nested items are supported:
  - Sub-item 1
  - Sub-item 2
    - Even deeper!
- Checklist support:
  - [x] High-performance persistence
  - [x] LaTeX rendering
  - [ ] Cloud sync (coming soon)

## 3. Tables
| Feature | Status |
| :--- | :--- |
| Persistence | ✅ Done |
| Math | ✅ Done |
| Export | ✅ Done |

## 4. Images
![Nifexo Logo](https://raw.githubusercontent.com/flutter/website/master/src/assets/images/shared/brand/flutter/logo/flutter-lockup.png)

---
*Happy writing!*
''',
      tags: ['welcome', 'guide'],
      createdAt: now,
      updatedAt: now,
      isPinned: true,
    );
    await widget.repositories.noteRepository.insertNote(exampleNote);
  }

  Future<void> _createNote(NoteDraft draft) async {
    final now = DateTime.now();
    final title = draft.title.trim().isEmpty
        ? 'Untitled note'
        : draft.title.trim();
    final note = Note(
      id: 'note-${now.microsecondsSinceEpoch}',
      title: title,
      contentMd: draft.content.trim(),
      tags: draft.tags,
      createdAt: now,
      updatedAt: now,
    );
    await widget.repositories.noteRepository.insertNote(note);
    await _loadData();
  }

  Future<void> _updateNote(String noteId, NoteDraft draft) async {
    final index = _notes.indexWhere((note) => note.id == noteId);
    if (index == -1) return;

    final updatedNote = _notes[index].copyWith(
      title: draft.title.trim().isEmpty
          ? 'Untitled note'
          : draft.title.trim(),
      contentMd: draft.content.trim(),
      tags: draft.tags,
      updatedAt: DateTime.now(),
    );
    await widget.repositories.noteRepository.updateNote(updatedNote);
    await _loadData();
  }

  Future<void> _deleteNote(String noteId) async {
    await widget.repositories.noteRepository.deleteNote(noteId);
    await _loadData();
  }

  Future<void> _toggleNotePinned(String noteId) async {
    final index = _notes.indexWhere((note) => note.id == noteId);
    if (index == -1) return;

    final note = _notes[index];
    final updatedNote = note.copyWith(
      isPinned: !note.isPinned,
      updatedAt: DateTime.now(),
    );
    await widget.repositories.noteRepository.updateNote(updatedNote);
    await _loadData();
  }

  Future<void> _createTodo(TodoDraft draft) async {
    final now = DateTime.now();
    final todo = TodoItem(
      id: 'todo-${now.microsecondsSinceEpoch}',
      title: draft.title.trim(),
      description: draft.description.trim(),
      tags: draft.tags,
      createdAt: now,
      updatedAt: now,
      dueDate: draft.dueDate,
      reminderAt: draft.reminderAt,
      priority: draft.priority,
    );
    await widget.repositories.todoRepository.insertTodo(todo);
    if (todo.reminderAt != null) {
      await widget.repositories.notificationService.scheduleTodoReminder(todo);
    }
    await _loadData();
  }

  Future<void> _updateTodo(String todoId, TodoDraft draft) async {
    final index = _todos.indexWhere((todo) => todo.id == todoId);
    if (index == -1) return;

    final updatedTodo = _todos[index].copyWith(
      title: draft.title.trim(),
      description: draft.description.trim(),
      dueDate: draft.dueDate,
      reminderAt: draft.reminderAt,
      tags: draft.tags,
      priority: draft.priority,
      updatedAt: DateTime.now(),
    );
    await widget.repositories.todoRepository.updateTodo(updatedTodo);
    
    // Update notification
    await widget.repositories.notificationService.cancelTodoReminder(todoId);
    if (updatedTodo.reminderAt != null && !updatedTodo.isDone) {
      await widget.repositories.notificationService.scheduleTodoReminder(updatedTodo);
    }
    
    await _loadData();
  }

  Future<void> _toggleTodoDone(String todoId, bool isDone) async {
    final index = _todos.indexWhere((todo) => todo.id == todoId);
    if (index == -1) return;

    final updatedTodo = _todos[index].copyWith(
      isDone: isDone,
      updatedAt: DateTime.now(),
    );
    await widget.repositories.todoRepository.updateTodo(updatedTodo);
    
    if (isDone) {
      await widget.repositories.notificationService.cancelTodoReminder(todoId);
    } else if (updatedTodo.reminderAt != null) {
      await widget.repositories.notificationService.scheduleTodoReminder(updatedTodo);
    }
    
    await _loadData();
  }

  Future<void> _deleteTodo(String todoId) async {
    await widget.repositories.notificationService.cancelTodoReminder(todoId);
    await widget.repositories.todoRepository.deleteTodo(todoId);
    await _loadData();
  }

  Future<void> _toggleTodoPinned(String todoId) async {
    final index = _todos.indexWhere((todo) => todo.id == todoId);
    if (index == -1) return;

    final todo = _todos[index];
    final updatedTodo = todo.copyWith(
      isPinned: !todo.isPinned,
      updatedAt: DateTime.now(),
    );
    await widget.repositories.todoRepository.updateTodo(updatedTodo);
    await _loadData();
  }

  Future<void> _handlePrimaryAction() async {
    if (_currentIndex == 2) {
      final draft = await showTodoEditor(context);
      if (draft != null) {
        await _createTodo(draft);
      }
      return;
    }

    final draft = await openNoteEditorPage(context, startInEditMode: true, backupService: _backupService);
    if (draft != null) {
      await _createNote(draft);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(notes: _notes, todos: _todos),
      NotesScreen(
        notes: _notes,
        onCreate: _createNote,
        onUpdate: _updateNote,
        onDelete: _deleteNote,
        onTogglePinned: _toggleNotePinned,
        backupService: _backupService,
      ),
      TodosScreen(
        todos: _todos,
        onCreate: _createTodo,
        onUpdate: _updateTodo,
        onToggleDone: _toggleTodoDone,
        onDelete: _deleteTodo,
        onTogglePinned: _toggleTodoPinned,
      ),
      SearchScreen(notes: _notes, todos: _todos),
      SettingsScreen(
        isDarkMode: widget.isDarkMode,
        onDarkModeChanged: widget.onThemeModeChanged,
        onImportComplete: _loadData,
        backupService: _backupService,
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.note_outlined),
            selectedIcon: Icon(Icons.note_rounded),
            label: 'Notes',
          ),
          NavigationDestination(
            icon: Icon(Icons.check_circle_outline),
            selectedIcon: Icon(Icons.check_circle),
            label: 'Todos',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_outlined),
            selectedIcon: Icon(Icons.tune),
            label: 'Settings',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _handlePrimaryAction,
        icon: const Icon(Icons.add),
        label: Text(
          _currentIndex == 2
              ? 'New Todo'
              : _currentIndex == 4
              ? 'Quick Note'
              : 'New Note',
        ),
      ),
    );
  }
}
