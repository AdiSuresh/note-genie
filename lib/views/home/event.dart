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

sealed class UpdateCollectionEvent extends HomeEvent {
  final NoteCollectionEntity? collection;

  const UpdateCollectionEvent({
    required this.collection,
  });
}

class ToggleCollectionEvent extends UpdateCollectionEvent {
  const ToggleCollectionEvent({
    required super.collection,
  });
}

class SelectCollectionEvent extends UpdateCollectionEvent {
  const SelectCollectionEvent({
    required super.collection,
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
