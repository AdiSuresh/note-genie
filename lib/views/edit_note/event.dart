import 'package:note_maker/models/note/model.dart';
import 'package:note_maker/models/note_collection/model.dart';

sealed class EditNoteEvent {
  const EditNoteEvent();
}

class UpdateNoteEvent extends EditNoteEvent {
  final NoteEntity note;

  const UpdateNoteEvent({
    required this.note,
  });
}

class UpdateNoteCollectionsEvent extends EditNoteEvent {
  final List<NoteCollectionEntity> noteCollections;

  UpdateNoteCollectionsEvent({
    required this.noteCollections,
  });
}
