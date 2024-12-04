import 'package:note_maker/models/base_entity.dart';
import 'package:note_maker/models/note/model.dart';
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

class ToggleSearchEvent extends HomeEvent {
  const ToggleSearchEvent();
}

class PerformSearchEvent extends HomeEvent {
  final String query;

  const PerformSearchEvent({
    required this.query,
  });
}

sealed class SelectItemEvent<T extends BaseEntity> extends HomeEvent {
  final T item;

  const SelectItemEvent({
    required this.item,
  });
}

final class SelectNoteEvent extends SelectItemEvent<NoteEntity> {
  const SelectNoteEvent({
    required super.item,
  });
}

final class SelectNoteCollectionEvent
    extends SelectItemEvent<NoteCollectionEntity> {
  const SelectNoteCollectionEvent({
    required super.item,
  });
}
