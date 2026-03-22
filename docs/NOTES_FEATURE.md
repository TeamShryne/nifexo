# Notes Feature

## Goal

The notes feature should feel like a real writing tool, not a settings form.

The current implementation reflects these decisions:

- existing notes open in read mode
- editing is explicit through a top-bar action
- save lives in the app bar, not as a redundant bottom CTA
- tags are edited through a focused modal instead of taking permanent editor space
- markdown shortcuts are available as reusable editor actions
- markdown rendering is owned by the app, not outsourced to a package

## Editor UX

The editor page is built to resemble a lightweight code editor:

- large title line
- tool strip for markdown actions
- write/preview switch
- monospace body text
- line-number gutter
- bordered editor surface with minimal field chrome

Important implementation detail:

- the editor still uses `TextField` for now because it is the most reliable native text engine available in Flutter without bringing in a full code editor dependency
- the surrounding layout is what makes it feel editor-like instead of form-like

## Supported Markdown

Current block support:

- `#`, `##`, `###`
- paragraphs
- block quotes
- bullet lists
- numbered lists
- checklists
- code fences
- horizontal rules

Current inline support:

- `**bold**`
- `_italic_`
- `~~strikethrough~~`
- `` `inline code` ``
- `[label](url)` styled as a link

This is intentionally a minimal, predictable subset that is easy to maintain.

## Shortcut System

The shortcut system is designed around data and transformation layers rather than hardcoded widget callbacks.

Flow:

1. toolbar emits a `MarkdownShortcutType`
2. editor controller transforms the current `TextEditingController` selection
3. editor view updates and remains in write mode

Benefits:

- shortcuts are easy to add
- toolbar UI stays dumb
- text mutation logic can be tested independently later

## Scaling Guidance

If the notes feature grows, prefer this order:

1. add unit tests for parser and editor controller logic
2. move note page state into a dedicated controller or notifier
3. add persistence behind repositories
4. consider richer markdown syntax only if it supports real product needs

Do not:

- mix persistence code into the note page
- hardcode rendering behavior inside the list screen
- scatter markdown mutation logic across multiple widgets
