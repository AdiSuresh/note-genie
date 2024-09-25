import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:note_maker/models/note/model.dart';

part 'state.g.dart';

enum EditNoteStatus {
  initial(''),
  saving('Saving...'),
  saved('Saved');

  final String message;

  const EditNoteStatus(
    this.message,
  );
}

@CopyWith()
class EditNoteState {
  final NoteEntity note;
  final EditNoteStatus noteStatus;
  final bool viewCollections;

  const EditNoteState({
    required this.note,
    this.noteStatus = EditNoteStatus.initial,
    this.viewCollections = true,
  });
}
