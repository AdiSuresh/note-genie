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

final class ViewNoteCollectionEvent extends HomeEvent {
  final NoteCollectionEntity? collection;
  final bool toggle;

  const ViewNoteCollectionEvent({
    required this.collection,
    this.toggle = false,
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

class FetchNoteCollectionsEvent extends HomeEvent {
  const FetchNoteCollectionsEvent();
}

class ResetStateEvent extends HomeEvent {
  const ResetStateEvent();
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
  final int index;

  const SelectItemEvent({
    required this.index,
  });
}

final class SelectNoteEvent extends SelectItemEvent<NoteEntity> {
  const SelectNoteEvent({
    required super.index,
  });
}

final class SelectNoteCollectionEvent
    extends SelectItemEvent<NoteCollectionEntity> {
  const SelectNoteCollectionEvent({
    required super.index,
  });
}

sealed class DeleteItemsEvent<T extends BaseEntity> extends HomeEvent {
  const DeleteItemsEvent();
}

final class DeleteNotesEvent extends DeleteItemsEvent<NoteEntity> {
  const DeleteNotesEvent();
}

final class DeleteNoteCollectionsEvent
    extends DeleteItemsEvent<NoteCollectionEntity> {
  const DeleteNoteCollectionsEvent();
}
