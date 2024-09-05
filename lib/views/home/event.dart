import 'package:note_maker/models/note/model.dart';
import 'package:note_maker/models/note_collection/model.dart';

sealed class HomeEvent {
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

class ToggleCollectionEvent extends HomeEvent {
  final NoteCollectionEntity? collection;

  const ToggleCollectionEvent({
    required this.collection,
  });
}

class SelectCollectionEvent extends ToggleCollectionEvent {
  const SelectCollectionEvent({
    required super.collection,
  });
}

class SwitchViewEvent extends HomeEvent {
  const SwitchViewEvent();
}
