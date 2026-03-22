import 'package:flutter/material.dart';

import '../../../core/models/note.dart';
import '../../../core/models/todo_item.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, required this.notes, required this.todos});

  final List<Note> notes;
  final List<TodoItem> todos;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final normalizedQuery = _query.trim().toLowerCase();
    final matchedNotes = widget.notes.where((note) {
      final haystack = '${note.title} ${note.contentMd} ${note.tags.join(' ')}'
          .toLowerCase();
      return normalizedQuery.isEmpty || haystack.contains(normalizedQuery);
    }).toList();
    final matchedTodos = widget.todos.where((todo) {
      final haystack =
          '${todo.title} ${todo.description} ${todo.tags.join(' ')}'
              .toLowerCase();
      return normalizedQuery.isEmpty || haystack.contains(normalizedQuery);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
        children: [
          TextField(
            decoration: const InputDecoration(
              hintText: 'Search notes, todos, tags',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _query = value;
              });
            },
          ),
          const SizedBox(height: 20),
          Text('Notes', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          ...matchedNotes.map(
            (note) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                child: ListTile(
                  title: Text(note.title),
                  subtitle: Text(
                    note.contentMd.replaceAll('\n', ' '),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text('Todos', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          ...matchedTodos.map(
            (todo) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                child: ListTile(
                  leading: Icon(
                    todo.isDone
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                  ),
                  title: Text(todo.title),
                  subtitle: Text(todo.description),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
