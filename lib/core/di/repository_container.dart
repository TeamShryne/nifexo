import '../repositories/note_repository.dart';
import '../repositories/todo_repository.dart';
import '../repositories/settings_repository.dart';
import '../repositories/sql_note_repository.dart';
import '../repositories/sql_todo_repository.dart';
import '../repositories/sql_settings_repository.dart';
import '../services/notification_service.dart';
import '../services/local_notification_service.dart';

class RepositoryContainer {
  final NoteRepository noteRepository;
  final TodoRepository todoRepository;
  final SettingsRepository settingsRepository;
  final NotificationService notificationService;

  RepositoryContainer({
    required this.noteRepository,
    required this.todoRepository,
    required this.settingsRepository,
    required this.notificationService,
  });

  factory RepositoryContainer.prod() {
    return RepositoryContainer(
      noteRepository: SqlNoteRepository(),
      todoRepository: SqlTodoRepository(),
      settingsRepository: SqlSettingsRepository(),
      notificationService: LocalNotificationService(),
    );
  }
}
