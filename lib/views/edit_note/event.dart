import 'package:flutter_quill/flutter_quill.dart';
import 'package:note_maker/models/note/model.dart';
import 'package:note_maker/models/note_collection/model.dart';

sealed class EditNoteEvent {
  EditNoteEvent();
}

class SaveNoteEvent extends EditNoteEvent {
  final NoteEntity note;

  SaveNoteEvent({
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

class RemoveFromCollectionEvent extends EditNoteEvent {
  final int collectionId;

  RemoveFromCollectionEvent({
    required this.collectionId,
  });
}

class AddToCollectionEvent extends EditNoteEvent {
  final NoteCollectionEntity collection;

  AddToCollectionEvent({
    required this.collection,
  });
}
