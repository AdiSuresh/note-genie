import 'package:note_maker/models/note_collection/model.dart';

sealed class HomeEvent {
  const HomeEvent();
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

class SelectCollectionEvent extends HomeEvent {
  final NoteCollectionEntity? collection;

  const SelectCollectionEvent({
    required this.collection,
  });
}

class SwitchTabEvent extends HomeEvent {
  final int index;

  const SwitchTabEvent({
    required this.index,
  });
}

class FetchNotesEvent extends HomeEvent {
  const FetchNotesEvent();
}
