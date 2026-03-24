import '../models/todo_item.dart';

abstract class NotificationService {
  Future<void> init();
  Future<void> scheduleTodoReminder(TodoItem todo);
  Future<void> cancelTodoReminder(String todoId);
}
