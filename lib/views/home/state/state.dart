import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:note_maker/models/note_collection/model.dart';
import 'package:note_maker/models/note/model.dart';

part 'state.g.dart';

@CopyWith()
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
