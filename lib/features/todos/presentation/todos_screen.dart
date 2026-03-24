import 'package:flutter/material.dart';

import '../../../core/models/todo_item.dart';

class TodosScreen extends StatelessWidget {
  const TodosScreen({
    super.key,
    required this.todos,
    required this.onCreate,
    required this.onUpdate,
    required this.onToggleDone,
    required this.onDelete,
    required this.onTogglePinned,
  });

  final List<TodoItem> todos;
  final Future<void> Function(TodoDraft) onCreate;
  final Future<void> Function(String todoId, TodoDraft draft) onUpdate;
  final Future<void> Function(String todoId, bool isDone) onToggleDone;
  final Future<void> Function(String todoId) onDelete;
  final Future<void> Function(String todoId) onTogglePinned;

  @override
  Widget build(BuildContext context) {
    final open = todos.where((todo) => !todo.isDone).toList();
    final done = todos.where((todo) => todo.isDone).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Todos'),
          actions: [
            IconButton(
              onPressed: () async {
                final draft = await showTodoEditor(context);
                if (draft != null) {
                  await onCreate(draft);
                }
              },
              icon: const Icon(Icons.add_rounded),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Open'),
              Tab(text: 'Done'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _TodoList(
              todos: open,
              onUpdate: onUpdate,
              onToggleDone: onToggleDone,
              onDelete: onDelete,
              onTogglePinned: onTogglePinned,
            ),
            _TodoList(
              todos: done,
              onUpdate: onUpdate,
              onToggleDone: onToggleDone,
              onDelete: onDelete,
              onTogglePinned: onTogglePinned,
            ),
          ],
        ),
      ),
    );
  }
}

class _TodoList extends StatelessWidget {
  const _TodoList({
    required this.todos,
    required this.onUpdate,
    required this.onToggleDone,
    required this.onDelete,
    required this.onTogglePinned,
  });

  final List<TodoItem> todos;
  final Future<void> Function(String todoId, TodoDraft draft) onUpdate;
  final Future<void> Function(String todoId, bool isDone) onToggleDone;
  final Future<void> Function(String todoId) onDelete;
  final Future<void> Function(String todoId) onTogglePinned;

  Color _priorityColor(TodoPriority priority) {
    switch (priority) {
      case TodoPriority.low:
        return const Color(0xFF3B82F6);
      case TodoPriority.medium:
        return const Color(0xFFF59E0B);
      case TodoPriority.high:
        return const Color(0xFFDC2626);
    }
  }

  String _priorityLabel(TodoPriority priority) {
    return switch (priority) {
      TodoPriority.low => 'Low',
      TodoPriority.medium => 'Medium',
      TodoPriority.high => 'High',
    };
  }

  @override
  Widget build(BuildContext context) {
    if (todos.isEmpty) {
      return const Center(child: Text('No todos yet'));
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
      itemBuilder: (context, index) {
        final todo = todos[index];
        final dueDate = todo.dueDate;

        return Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () async {
              final draft = await showTodoEditor(context, initial: todo);
              if (draft != null) {
                await onUpdate(todo.id, draft);
              }
            },
            child: CheckboxListTile(
              value: todo.isDone,
              onChanged: (value) async => await onToggleDone(todo.id, value ?? false),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              title: Row(
                children: [
                  Expanded(child: Text(todo.title)),
                  IconButton(
                    onPressed: () async => await onTogglePinned(todo.id),
                    icon: Icon(
                      todo.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                      size: 18,
                    ),
                  ),
                  IconButton(
                    onPressed: () async => await onDelete(todo.id),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (todo.description.trim().isNotEmpty)
                      _InfoPill(
                        label: todo.description.trim(),
                        color: const Color(0xFF64748B),
                      ),
                    _InfoPill(
                      label: _priorityLabel(todo.priority),
                      color: _priorityColor(todo.priority),
                    ),
                    if (dueDate != null)
                      _InfoPill(
                        label: 'Due ${dueDate.day}/${dueDate.month}',
                        color: const Color(0xFF0E7C66),
                      ),
                    ...todo.tags.map(
                      (tag) => _InfoPill(
                        label: '#$tag',
                        color: const Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ),
        );
      },
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemCount: todos.length,
    );
  }
}

class TodoDraft {
  const TodoDraft({
    required this.title,
    required this.description,
    required this.priority,
    required this.tags,
    this.dueDate,
  });

  final String title;
  final String description;
  final TodoPriority priority;
  final List<String> tags;
  final DateTime? dueDate;
}

Future<TodoDraft?> showTodoEditor(BuildContext context, {TodoItem? initial}) {
  final titleController = TextEditingController(text: initial?.title ?? '');
  final descriptionController = TextEditingController(
    text: initial?.description ?? '',
  );
  final tagsController = TextEditingController(
    text: initial?.tags.join(', ') ?? '',
  );
  final dueDateController = TextEditingController(
    text: initial?.dueDate == null
        ? ''
        : '${initial!.dueDate!.year}-${initial.dueDate!.month.toString().padLeft(2, '0')}-${initial.dueDate!.day.toString().padLeft(2, '0')}',
  );
  var priority = initial?.priority ?? TodoPriority.medium;
  final formKey = GlobalKey<FormState>();

  return showModalBottomSheet<TodoDraft>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    initial == null ? 'New todo' : 'Edit todo',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Title is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<TodoPriority>(
                    initialValue: priority,
                    items: const [
                      DropdownMenuItem(
                        value: TodoPriority.low,
                        child: Text('Low priority'),
                      ),
                      DropdownMenuItem(
                        value: TodoPriority.medium,
                        child: Text('Medium priority'),
                      ),
                      DropdownMenuItem(
                        value: TodoPriority.high,
                        child: Text('High priority'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setModalState(() {
                          priority = value;
                        });
                      }
                    },
                    decoration: const InputDecoration(labelText: 'Priority'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: dueDateController,
                    decoration: const InputDecoration(
                      labelText: 'Due date',
                      hintText: 'YYYY-MM-DD',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: tagsController,
                    decoration: const InputDecoration(
                      labelText: 'Tags',
                      hintText: 'work, personal',
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        if (!formKey.currentState!.validate()) return;
                        Navigator.of(context).pop(
                          TodoDraft(
                            title: titleController.text,
                            description: descriptionController.text,
                            priority: priority,
                            dueDate: _parseDate(dueDateController.text),
                            tags: _parseTodoTags(tagsController.text),
                          ),
                        );
                      },
                      child: Text(
                        initial == null ? 'Create todo' : 'Save todo',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

DateTime? _parseDate(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) return null;
  return DateTime.tryParse(trimmed);
}

List<String> _parseTodoTags(String input) {
  return input
      .split(',')
      .map((tag) => tag.trim())
      .where((tag) => tag.isNotEmpty)
      .toList();
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color),
      ),
    );
  }
}
