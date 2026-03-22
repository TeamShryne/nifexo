import 'package:flutter/material.dart';

import '../core/models/note.dart';
import '../core/models/todo_item.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/notes/presentation/notes_screen.dart';
import '../features/search/presentation/search_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/todos/presentation/todos_screen.dart';
import 'theme.dart';

class NifexoApp extends StatefulWidget {
  const NifexoApp({super.key});

  @override
  State<NifexoApp> createState() => _NifexoAppState();
}

class _NifexoAppState extends State<NifexoApp> {
  ThemeMode _themeMode = ThemeMode.light;

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
        onThemeModeChanged: (enabled) {
          setState(() {
            _themeMode = enabled ? ThemeMode.dark : ThemeMode.light;
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
  final List<Note> _notes = [];
  final List<TodoItem> _todos = [];

  void _createNote(NoteDraft draft) {
    final now = DateTime.now();
    final title = draft.title.trim().isEmpty
        ? 'Untitled note'
        : draft.title.trim();
    setState(() {
      _notes.insert(
        0,
        Note(
          id: 'note-${now.microsecondsSinceEpoch}',
          title: title,
          contentMd: draft.content.trim(),
          tags: draft.tags,
          createdAt: now,
          updatedAt: now,
        ),
      );
    });
  }

  void _updateNote(String noteId, NoteDraft draft) {
    final index = _notes.indexWhere((note) => note.id == noteId);
    if (index == -1) return;

    setState(() {
      _notes[index] = _notes[index].copyWith(
        title: draft.title.trim().isEmpty
            ? 'Untitled note'
            : draft.title.trim(),
        contentMd: draft.content.trim(),
        tags: draft.tags,
        updatedAt: DateTime.now(),
      );
    });
  }

  void _deleteNote(String noteId) {
    setState(() {
      _notes.removeWhere((note) => note.id == noteId);
    });
  }

  void _toggleNotePinned(String noteId) {
    final index = _notes.indexWhere((note) => note.id == noteId);
    if (index == -1) return;

    setState(() {
      final note = _notes[index];
      _notes[index] = note.copyWith(
        isPinned: !note.isPinned,
        updatedAt: DateTime.now(),
      );
    });
  }

  void _createTodo(TodoDraft draft) {
    final now = DateTime.now();
    setState(() {
      _todos.insert(
        0,
        TodoItem(
          id: 'todo-${now.microsecondsSinceEpoch}',
          title: draft.title.trim(),
          description: draft.description.trim(),
          tags: draft.tags,
          createdAt: now,
          updatedAt: now,
          dueDate: draft.dueDate,
          priority: draft.priority,
        ),
      );
    });
  }

  void _updateTodo(String todoId, TodoDraft draft) {
    final index = _todos.indexWhere((todo) => todo.id == todoId);
    if (index == -1) return;

    setState(() {
      _todos[index] = _todos[index].copyWith(
        title: draft.title.trim(),
        description: draft.description.trim(),
        dueDate: draft.dueDate,
        tags: draft.tags,
        priority: draft.priority,
        updatedAt: DateTime.now(),
      );
    });
  }

  void _toggleTodoDone(String todoId, bool isDone) {
    final index = _todos.indexWhere((todo) => todo.id == todoId);
    if (index == -1) return;

    setState(() {
      _todos[index] = _todos[index].copyWith(
        isDone: isDone,
        updatedAt: DateTime.now(),
      );
    });
  }

  void _deleteTodo(String todoId) {
    setState(() {
      _todos.removeWhere((todo) => todo.id == todoId);
    });
  }

  void _toggleTodoPinned(String todoId) {
    final index = _todos.indexWhere((todo) => todo.id == todoId);
    if (index == -1) return;

    setState(() {
      final todo = _todos[index];
      _todos[index] = todo.copyWith(
        isPinned: !todo.isPinned,
        updatedAt: DateTime.now(),
      );
    });
  }

  Future<void> _handlePrimaryAction() async {
    if (_currentIndex == 2) {
      final draft = await showTodoEditor(context);
      if (draft != null) {
        _createTodo(draft);
      }
      return;
    }

    final draft = await openNoteEditorPage(context, startInEditMode: true);
    if (draft != null) {
      _createNote(draft);
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
