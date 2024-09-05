import 'package:note_maker/models/note/model.dart';

sealed class EditNoteEvent {
  const EditNoteEvent();
}

class UpdateTitleEvent extends EditNoteEvent {
  final String title;

  const UpdateTitleEvent({
    required this.title,
  });
}

class UpdateNoteEvent extends EditNoteEvent {
  final NoteEntity note;

  const UpdateNoteEvent({
    required this.note,
  });
}
