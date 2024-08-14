import 'package:note_maker/models/note/model.dart';
import 'package:note_maker/models/note_collection/model.dart';

abstract class HomeEvent {
  const HomeEvent();
}

class UpdateNotesEvent extends HomeEvent {
  final List<Note> notes;

  const UpdateNotesEvent({
    required this.notes,
  });
}

class UpdateNoteCollectionsEvent extends HomeEvent {
  final List<NoteCollection> noteCollections;

  const UpdateNoteCollectionsEvent({
    required this.noteCollections,
  });
}

class ViewCollectionEvent extends HomeEvent {
  final NoteCollection collection;

  const ViewCollectionEvent({
    required this.collection,
  });
}

class SwithViewEvent extends HomeEvent {
  const SwithViewEvent();
}
