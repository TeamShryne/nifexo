import '../models/note.dart';

abstract class NoteRepository {
  Future<List<Note>> getAllNotes();
  Future<void> insertNote(Note note);
  Future<void> updateNote(Note note);
  Future<void> deleteNote(String id);
}
