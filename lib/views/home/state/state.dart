import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:note_maker/models/note_collection/model.dart';
import 'package:note_maker/models/note/model.dart';

part 'state.g.dart';

@CopyWith()
class HomeState {
  final bool showNotes;
  final List<Note> notes;
  final List<NoteCollection> noteCollections;
  final NoteCollection? currentCollection;

  const HomeState({
    this.showNotes = true,
    required this.notes,
    required this.noteCollections,
    this.currentCollection,
  });
}
