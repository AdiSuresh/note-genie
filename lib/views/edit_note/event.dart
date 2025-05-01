import 'package:flutter_quill/flutter_quill.dart';
import 'package:note_maker/models/note/model.dart';
import 'package:note_maker/models/note_collection/model.dart';

sealed class EditNoteEvent {
  const EditNoteEvent();
}

final class SaveNoteEvent extends EditNoteEvent {
  final NoteEntity note;

  SaveNoteEvent({
    required this.note,
  });
}

final class UpdateTitleEvent extends EditNoteEvent {
  final String title;

  UpdateTitleEvent({
    required this.title,
  });
}

final class UpdateContentEvent extends EditNoteEvent {
  final Document document;

  UpdateContentEvent({
    required this.document,
  });
}

final class RemoveFromCollectionEvent extends EditNoteEvent {
  final int collectionId;

  RemoveFromCollectionEvent({
    required this.collectionId,
  });
}

final class AddToCollectionEvent extends EditNoteEvent {
  final NoteCollectionEntity collection;

  AddToCollectionEvent({
    required this.collection,
  });
}

final class ViewCollectionsEvent extends EditNoteEvent {
  const ViewCollectionsEvent();
}

final class ViewUnlinkedCollectionsEvent extends EditNoteEvent {
  const ViewUnlinkedCollectionsEvent();
}
