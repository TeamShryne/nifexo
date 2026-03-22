# Architecture

## Purpose

This document describes how the current Flutter alpha is organized so future work can stay consistent, modular, and easy to change.

## Top-Level Structure

- `lib/app/`
  App shell, theme, and top-level state ownership.
- `lib/core/`
  Shared domain models that are not specific to one screen.
- `lib/features/`
  Feature-oriented UI code. Each feature should eventually grow into `presentation`, `application`, `domain`, and `data`.
- `docs/`
  Product and engineering documentation.

## Current App State

The app currently uses in-memory state owned by [lib/app/app.dart](/home/shrawan/nifexo/lib/app/app.dart).

This is intentionally temporary. The shell already centralizes note and todo mutations so the next persistence step can replace the in-memory lists with repositories rather than rewriting every screen.

Current responsibilities in `app.dart`:

- own the current `ThemeMode`
- own note and todo collections
- expose CRUD callbacks to feature screens
- host bottom navigation and global create actions

## Notes Feature

The notes feature is split into two layers today:

- presentation: [lib/features/notes/presentation/notes_screen.dart](/home/shrawan/nifexo/lib/features/notes/presentation/notes_screen.dart)
- markdown subsystem: `lib/features/notes/markdown/`

### Presentation Responsibilities

`notes_screen.dart` is responsible for:

- note list screen
- note editor page routing
- note editor page state
- tag modal workflow
- wiring shortcut actions to editor mutations

It should not contain markdown parsing or markdown styling rules beyond composition.

### Markdown Responsibilities

The markdown folder isolates rendering and editing concerns:

- [lib/features/notes/markdown/markdown_block.dart](/home/shrawan/nifexo/lib/features/notes/markdown/markdown_block.dart)
  Defines parsed block shapes.
- [lib/features/notes/markdown/markdown_parser.dart](/home/shrawan/nifexo/lib/features/notes/markdown/markdown_parser.dart)
  Converts raw markdown text into block models.
- [lib/features/notes/markdown/markdown_inline_parser.dart](/home/shrawan/nifexo/lib/features/notes/markdown/markdown_inline_parser.dart)
  Parses inline formatting such as bold, italic, code, strike, and links.
- [lib/features/notes/markdown/markdown_render_view.dart](/home/shrawan/nifexo/lib/features/notes/markdown/markdown_render_view.dart)
  Renders parsed blocks into a minimal, GitHub-like reading layout.
- [lib/features/notes/markdown/markdown_shortcut.dart](/home/shrawan/nifexo/lib/features/notes/markdown/markdown_shortcut.dart)
  Shortcut types and display metadata.
- [lib/features/notes/markdown/markdown_shortcuts.dart](/home/shrawan/nifexo/lib/features/notes/markdown/markdown_shortcuts.dart)
  Shortcut registry used by the toolbar.
- [lib/features/notes/markdown/markdown_editor_controller.dart](/home/shrawan/nifexo/lib/features/notes/markdown/markdown_editor_controller.dart)
  Pure editing logic that transforms text selections into markdown syntax.
- [lib/features/notes/markdown/markdown_editor_toolbar.dart](/home/shrawan/nifexo/lib/features/notes/markdown/markdown_editor_toolbar.dart)
  Stateless UI for editor actions.

This split is deliberate. It keeps parser logic, editor mutations, and rendering separate so any one part can be replaced later.

## Design Rules

When extending the app, prefer these rules:

- keep feature state close to the feature until persistence or cross-feature needs force extraction
- keep editing logic out of widgets when it can be expressed in controller-like classes
- keep rendering logic out of screens when it can be isolated behind reusable widgets
- avoid provider-specific or storage-specific assumptions in presentation code
- document architectural decisions when they affect future extension points

## Next Refactor Boundary

The next clean architectural step is:

1. introduce repositories for notes and todos
2. move app-owned mutations behind those repositories
3. back repositories with `drift`
4. keep the notes markdown subsystem independent of persistence
