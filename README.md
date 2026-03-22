# Nifexo

Nifexo is an Android-first Flutter app for markdown notes and personal todos. The project is local-first in V1, with cloud sync planned later through optional provider integrations.

## V1 Direction

- Markdown notes and structured todos in one app
- Local-first storage as the canonical source of truth
- Export and import with markdown portability in mind
- Sync-ready architecture without shipping sync in alpha

## Alpha Status

The current alpha replaces the default Flutter demo with:

- Home, Notes, Todos, Search, and Settings screens
- Seeded note and todo models
- Android-friendly bottom navigation shell
- Product copy aligned with the agreed V1 direction

## Planned Stack

- Flutter
- Riverpod
- GoRouter
- Drift
- Freezed

The alpha shell is intentionally dependency-light while the product plan is being locked down. Persistence and state management packages are the next implementation step.

## Next Build Steps

1. Add `drift` and define note and todo tables.
2. Replace seeded data with repositories and local persistence.
3. Build create, edit, archive, delete, and search flows.
4. Add markdown preview and export/import.
5. Define sync interfaces for future provider support.

## Planning Doc

See [docs/V1_PLAN.md](docs/V1_PLAN.md) for the product scope, architecture, milestones, and non-goals.
