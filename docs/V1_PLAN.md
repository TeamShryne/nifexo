# Nifexo V1 Plan

## Product Definition

Nifexo V1 is an offline-first Android app that combines markdown notes and personal todos in one focused mobile workflow.

Core promise:

- Fast capture
- Reliable local storage
- Markdown portability
- Clean Android UX
- Future sync without vendor lock-in

Primary users:

- Solo users
- Developers
- Students
- Writers
- Knowledge workers

## V1 Scope

Must ship:

- Notes CRUD
- Todos CRUD
- Search across notes and todos
- Tags shared across both entities
- Due dates and priorities for todos
- Pin and archive flows
- Markdown preview for notes
- Autosave
- Export and backup

Explicitly not in V1:

- Cloud sync
- Login or auth
- Collaboration
- Attachments
- Recurring tasks
- Rich text editor
- Provider-specific integrations

## Product Structure

Bottom navigation:

- Home
- Notes
- Todos
- Search
- Settings

Screen intent:

- Home: summary of open tasks, pinned notes, and quick actions
- Notes: browse and edit markdown notes
- Todos: manage open and completed tasks
- Search: global search across titles, content, descriptions, and tags
- Settings: storage, export, future sync preferences

## Canonical Storage Decision

V1 canonical storage will be a local database, not raw `.md` files on device storage.

Reasoning:

- Structured local data is easier for search, filtering, linking, and migrations
- Todos do not map cleanly to markdown files
- Android filesystem UX is weaker than desktop filesystem UX
- Sync providers are easier to build on top of a stable local schema

Markdown files still matter in V1:

- Export notes as `.md`
- Import notes from `.md`
- Use frontmatter for metadata portability

Future option:

- Add an optional markdown-file mirror or provider-based file storage mode later

## Data Model

### Note

- `id`
- `title`
- `contentMd`
- `tags`
- `isPinned`
- `isArchived`
- `createdAt`
- `updatedAt`

### Todo

- `id`
- `title`
- `description`
- `isDone`
- `priority`
- `dueDate`
- `tags`
- `linkedNoteId`
- `isPinned`
- `isArchived`
- `createdAt`
- `updatedAt`

Rules:

- `linkedNoteId` is optional
- archive is separate from delete
- markdown remains the note content format
- note title can later be inferred from content when needed

## Technical Direction

Recommended stack:

- Flutter
- Riverpod
- GoRouter
- Drift
- Freezed
- JsonSerializable

Architecture:

- `app/`
- `core/`
- `features/notes/`
- `features/todos/`
- `features/search/`
- `features/settings/`
- `features/sync/`

Layering inside features:

- `presentation`
- `application`
- `domain`
- `data`

## Sync-Ready Design

V1 will not implement cloud sync, but the architecture should reserve clear extension points:

- `SyncProvider`
- `SyncRepository`
- `SyncEngine`
- `ProviderConfig`

Rule:

- Local storage stays the source of truth
- Providers mirror and reconcile data rather than owning it

Planned future providers:

- Supabase
- Firebase
- Custom service integrations

## Milestone Order

1. Replace scaffold with alpha shell
2. Finalize domain model and local schema
3. Implement note persistence and CRUD
4. Implement todo persistence and CRUD
5. Add search, filters, tags, pin, and archive
6. Add markdown preview and export/import
7. Define sync interfaces for future providers
8. Test, polish, and prepare alpha release

## Acceptance Criteria For Alpha

- App opens into a coherent Android-first navigation shell
- Notes and todos both exist as first-class features
- Product structure matches the agreed V1 direction
- The codebase can evolve into real persistence without major restructuring
