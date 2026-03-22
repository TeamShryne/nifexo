# Codebase Guide

## What Exists Today

The current alpha has:

- bottom-navigation app shell
- in-memory notes and todos
- dark mode toggle
- functional CRUD flows
- internal markdown rendering and shortcut-based editing for notes

## Important Files

- [lib/main.dart](/home/shrawan/nifexo/lib/main.dart)
  Entry point.
- [lib/app/app.dart](/home/shrawan/nifexo/lib/app/app.dart)
  Root widget, theme mode, app shell, and current in-memory state.
- [lib/app/theme.dart](/home/shrawan/nifexo/lib/app/theme.dart)
  Theme construction for light and dark modes.
- [lib/core/models/note.dart](/home/shrawan/nifexo/lib/core/models/note.dart)
  Note model.
- [lib/core/models/todo_item.dart](/home/shrawan/nifexo/lib/core/models/todo_item.dart)
  Todo model.

Feature entry points:

- [lib/features/home/presentation/home_screen.dart](/home/shrawan/nifexo/lib/features/home/presentation/home_screen.dart)
- [lib/features/notes/presentation/notes_screen.dart](/home/shrawan/nifexo/lib/features/notes/presentation/notes_screen.dart)
- [lib/features/todos/presentation/todos_screen.dart](/home/shrawan/nifexo/lib/features/todos/presentation/todos_screen.dart)
- [lib/features/search/presentation/search_screen.dart](/home/shrawan/nifexo/lib/features/search/presentation/search_screen.dart)
- [lib/features/settings/presentation/settings_screen.dart](/home/shrawan/nifexo/lib/features/settings/presentation/settings_screen.dart)

## Development Notes

- tests currently focus on widget-level flow verification
- the notes renderer is intentionally internal and minimal
- the app is not persistent yet; in-memory state resets on restart

## Recommended Next Steps

1. add parser/controller unit tests for the markdown subsystem
2. introduce `drift` repositories for notes and todos
3. move note and todo mutations behind repository interfaces
4. add import/export flows once persistence exists
