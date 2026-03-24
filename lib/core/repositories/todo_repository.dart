import '../models/todo_item.dart';

abstract class TodoRepository {
  Future<List<TodoItem>> getAllTodos();
  Future<void> insertTodo(TodoItem todo);
  Future<void> updateTodo(TodoItem todo);
  Future<void> deleteTodo(String id);
}
