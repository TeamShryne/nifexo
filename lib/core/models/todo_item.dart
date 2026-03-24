enum TodoPriority { low, medium, high }

class TodoItem {
  const TodoItem({
    required this.id,
    required this.title,
    required this.description,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
    this.isDone = false,
    this.isPinned = false,
    this.isArchived = false,
    this.priority = TodoPriority.medium,
    this.dueDate,
    this.reminderAt,
    this.linkedNoteId,
  });

  final String id;
  final String title;
  final String description;
  final bool isDone;
  final bool isPinned;
  final bool isArchived;
  final TodoPriority priority;
  final DateTime? dueDate;
  final DateTime? reminderAt;
  final List<String> tags;
  final String? linkedNoteId;
  final DateTime createdAt;
  final DateTime updatedAt;

  TodoItem copyWith({
    String? id,
    String? title,
    String? description,
    bool? isDone,
    bool? isPinned,
    bool? isArchived,
    TodoPriority? priority,
    DateTime? dueDate,
    DateTime? reminderAt,
    List<String>? tags,
    String? linkedNoteId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TodoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isDone: isDone ?? this.isDone,
      isPinned: isPinned ?? this.isPinned,
      isArchived: isArchived ?? this.isArchived,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      reminderAt: reminderAt ?? this.reminderAt,
      tags: tags ?? this.tags,
      linkedNoteId: linkedNoteId ?? this.linkedNoteId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
