import 'package:note_maker/models/note/model.dart';

sealed class EditNoteEvent {
  const EditNoteEvent();
}

class UpdateNoteEvent extends EditNoteEvent {
  final NoteEntity note;

  const UpdateNoteEvent({
    required this.note,
  });
}
