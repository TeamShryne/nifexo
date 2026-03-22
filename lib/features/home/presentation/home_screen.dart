import 'package:flutter/material.dart';

import '../../../core/models/note.dart';
import '../../../core/models/todo_item.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.notes, required this.todos});

  final List<Note> notes;
  final List<TodoItem> todos;

  @override
  Widget build(BuildContext context) {
    final openTodos = todos.where((todo) => !todo.isDone).toList();
    final pinnedNotes = notes.where((note) => note.isPinned).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Nifexo Alpha')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _OverviewCard(
            title: 'Offline-first productivity',
            subtitle:
                'Markdown notes, focused todos, and a sync-ready architecture.',
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _StatChip(label: 'Open todos', value: '${openTodos.length}'),
                _StatChip(label: 'Notes', value: '${notes.length}'),
                _StatChip(label: 'Pinned', value: '${pinnedNotes.length}'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionTitle(title: 'Today', actionLabel: 'View all'),
          const SizedBox(height: 12),
          if (openTodos.isEmpty)
            const _EmptyCard(
              title: 'No open todos',
              subtitle:
                  'Create your first task from the Todos tab or the main action button.',
            )
          else
            ...openTodos
                .take(2)
                .map(
                  (todo) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _TodoPreviewCard(todo: todo),
                  ),
                ),
          const SizedBox(height: 16),
          _SectionTitle(title: 'Pinned notes', actionLabel: 'Open notes'),
          const SizedBox(height: 12),
          if (pinnedNotes.isEmpty)
            const _EmptyCard(
              title: 'No pinned notes',
              subtitle: 'Create a note and pin it to make it show up here.',
            )
          else
            ...pinnedNotes.map(
              (note) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _NotePreviewCard(note: note),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(subtitle),
          ],
        ),
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(subtitle, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F4EF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 2),
          Text(label),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.actionLabel});

  final String title;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        TextButton(onPressed: () {}, child: Text(actionLabel)),
      ],
    );
  }
}

class _TodoPreviewCard extends StatelessWidget {
  const _TodoPreviewCard({required this.todo});

  final TodoItem todo;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Icon(
          todo.isDone ? Icons.check_circle : Icons.radio_button_unchecked,
          color: todo.isDone
              ? Colors.green
              : Theme.of(context).colorScheme.primary,
        ),
        title: Text(todo.title),
        subtitle: Text(todo.description),
        trailing: todo.dueDate == null
            ? null
            : Text('${todo.dueDate!.day}/${todo.dueDate!.month}'),
      ),
    );
  }
}

class _NotePreviewCard extends StatelessWidget {
  const _NotePreviewCard({required this.note});

  final Note note;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        title: Text(note.title),
        subtitle: Text(
          note.contentMd.replaceAll('\n', ' ').trim(),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Wrap(
          spacing: 8,
          children: note.tags
              .take(2)
              .map((tag) => Chip(label: Text(tag)))
              .toList(),
        ),
      ),
    );
  }
}
