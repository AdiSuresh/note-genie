import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:note_maker/models/note/model.dart';
import 'package:note_maker/models/note_collection/model.dart';

part 'state.g.dart';

@CopyWith()
class EditNoteState {
  final NoteEntity note;
  final List<NoteCollectionEntity> noteCollections;

  EditNoteState({
    required this.note,
    required this.noteCollections,
  });
}
