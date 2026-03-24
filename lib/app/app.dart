import 'package:flutter/material.dart';

import '../core/models/note.dart';
import '../core/models/todo_item.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/notes/presentation/notes_screen.dart';
import '../features/search/presentation/search_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/todos/presentation/todos_screen.dart';
import 'theme.dart';

import '../core/repositories/note_repository.dart';
import '../core/repositories/todo_repository.dart';
import '../core/repositories/settings_repository.dart';

class NifexoApp extends StatefulWidget {
  const NifexoApp({super.key});

  @override
  State<NifexoApp> createState() => _NifexoAppState();
}

class _NifexoAppState extends State<NifexoApp> {
  ThemeMode _themeMode = ThemeMode.light;
  final _settingsRepository = SettingsRepository();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final themeMode = await _settingsRepository.getSetting('themeMode');
    if (themeMode != null) {
      setState(() {
        _themeMode = themeMode == 'dark' ? ThemeMode.dark : ThemeMode.light;
      });
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
        isDarkMode: _themeMode == ThemeMode.dark,
        onThemeModeChanged: (enabled) async {
          final newMode = enabled ? ThemeMode.dark : ThemeMode.light;
          await _settingsRepository.setSetting('themeMode', enabled ? 'dark' : 'light');
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
    required this.isDarkMode,
    required this.onThemeModeChanged,
  });

  final bool isDarkMode;
  final ValueChanged<bool> onThemeModeChanged;

  @override
  State<AlphaShell> createState() => _AlphaShellState();
}

class _AlphaShellState extends State<AlphaShell> {
  int _currentIndex = 0;
  List<Note> _notes = [];
  List<TodoItem> _todos = [];

  final _noteRepository = NoteRepository();
  final _todoRepository = TodoRepository();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final notes = await _noteRepository.getAllNotes();
    final todos = await _todoRepository.getAllTodos();
    setState(() {
      _notes = notes;
      _todos = todos;
    });
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
    await _noteRepository.insertNote(note);
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
    await _noteRepository.updateNote(updatedNote);
    await _loadData();
  }

  Future<void> _deleteNote(String noteId) async {
    await _noteRepository.deleteNote(noteId);
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
    await _noteRepository.updateNote(updatedNote);
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
      priority: draft.priority,
    );
    await _todoRepository.insertTodo(todo);
    await _loadData();
  }

  Future<void> _updateTodo(String todoId, TodoDraft draft) async {
    final index = _todos.indexWhere((todo) => todo.id == todoId);
    if (index == -1) return;

    final updatedTodo = _todos[index].copyWith(
      title: draft.title.trim(),
      description: draft.description.trim(),
      dueDate: draft.dueDate,
      tags: draft.tags,
      priority: draft.priority,
      updatedAt: DateTime.now(),
    );
    await _todoRepository.updateTodo(updatedTodo);
    await _loadData();
  }

  Future<void> _toggleTodoDone(String todoId, bool isDone) async {
    final index = _todos.indexWhere((todo) => todo.id == todoId);
    if (index == -1) return;

    final updatedTodo = _todos[index].copyWith(
      isDone: isDone,
      updatedAt: DateTime.now(),
    );
    await _todoRepository.updateTodo(updatedTodo);
    await _loadData();
  }

  Future<void> _deleteTodo(String todoId) async {
    await _todoRepository.deleteTodo(todoId);
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
    await _todoRepository.updateTodo(updatedTodo);
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

    final draft = await openNoteEditorPage(context, startInEditMode: true);
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
