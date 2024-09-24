import 'package:flutter_quill/flutter_quill.dart';
import 'package:note_maker/models/note/model.dart';
import 'package:note_maker/models/note_collection/model.dart';

sealed class EditNoteEvent {
  const EditNoteEvent();
}

class SaveNoteEvent extends EditNoteEvent {
  final NoteEntity note;

  const SaveNoteEvent({
    required this.note,
  });
}

class UpdateTitleEvent extends EditNoteEvent {
  final String title;

  UpdateTitleEvent({
    required this.title,
  });
}

class UpdateContentEvent extends EditNoteEvent {
  final Document document;

  UpdateContentEvent({
    required this.document,
  });
}

class UpdateCollectionsEvent extends EditNoteEvent {
  final List<NoteCollectionEntity> noteCollections;

  UpdateCollectionsEvent({
    required this.noteCollections,
  });
}
