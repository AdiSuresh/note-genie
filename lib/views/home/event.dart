import 'package:note_maker/models/note/model.dart';
import 'package:note_maker/models/note_collection/model.dart';

abstract class HomeEvent {
  const HomeEvent();
}

class UpdateNotesEvent extends HomeEvent {
  final List<NoteEntity> notes;

  const UpdateNotesEvent({
    required this.notes,
  });
}

class UpdateNoteCollectionsEvent extends HomeEvent {
  final List<NoteCollectionEntity> noteCollections;

  const UpdateNoteCollectionsEvent({
    required this.noteCollections,
  });
}

class ViewCollectionEvent extends HomeEvent {
  final NoteCollectionEntity? collection;

  const ViewCollectionEvent({
    required this.collection,
  });
}

class SwitchViewEvent extends HomeEvent {
  const SwitchViewEvent();
}
