import 'package:note_maker/models/note_collection/note_collection.dart';
import 'package:note_maker/models/note/note.dart';

class HomeState {
  final List<Note> notes;
  final List<NoteCollection> noteCollections;

  const HomeState({
    required this.notes,
    required this.noteCollections,
  });
}

class NotesLoaded extends HomeState {
  NotesLoaded({
    required super.notes,
    required super.noteCollections,
  });
}
