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
  final IdleState prevState;
  final List<T> searchResults;

  SearchState({
    required this.prevState,
    required this.searchResults,
  });
}

class SearchNotesState extends SearchState<NoteEntity> {
  SearchNotesState({
    required super.prevState,
    required super.searchResults,
  });

  factory SearchNotesState.initial(
    IdleState prevState,
  ) {
    return SearchNotesState(
      prevState: prevState,
      searchResults: prevState.notes,
    );
  }
}

class SearchNoteCollectionsState extends SearchState<NoteCollectionEntity> {
  SearchNoteCollectionsState({
    required super.prevState,
    required super.searchResults,
  });

  factory SearchNoteCollectionsState.initial(
    IdleState prevState,
  ) {
    return SearchNoteCollectionsState(
      prevState: prevState,
      searchResults: prevState.noteCollections,
    );
  }
}
