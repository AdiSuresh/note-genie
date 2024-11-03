import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:note_maker/models/base_entity.dart';
import 'package:note_maker/models/note_collection/model.dart';
import 'package:note_maker/models/note/model.dart';

part 'state.g.dart';

sealed class HomeState {
  const HomeState();
}

@CopyWith()
final class IdleState extends HomeState {
  final bool showNotes;
  final List<NoteEntity> notes;
  final List<NoteCollectionEntity> noteCollections;
  final NoteCollectionEntity? currentCollection;

  const IdleState({
    this.showNotes = true,
    required this.notes,
    required this.noteCollections,
    this.currentCollection,
  });

  String get pageTitle {
    return switch (showNotes) {
      true => 'Notes',
      _ => 'Collections',
    };
  }
}

sealed class SearchState<T extends BaseEntity> extends HomeState {
  final IdleState previousState;
  final List<T> searchResults;

  SearchState({
    required this.previousState,
    required this.searchResults,
  });
}

@CopyWith()
class SearchNotesState extends SearchState<NoteEntity> {
  SearchNotesState({
    required super.previousState,
    required super.searchResults,
  });

  factory SearchNotesState.initial(
    IdleState prevState,
  ) {
    return SearchNotesState(
      previousState: prevState,
      searchResults: prevState.notes,
    );
  }
}

@CopyWith()
class SearchNoteCollectionsState extends SearchState<NoteCollectionEntity> {
  SearchNoteCollectionsState({
    required super.previousState,
    required super.searchResults,
  });

  factory SearchNoteCollectionsState.initial(
    IdleState prevState,
  ) {
    return SearchNoteCollectionsState(
      previousState: prevState,
      searchResults: prevState.noteCollections,
    );
  }
}
