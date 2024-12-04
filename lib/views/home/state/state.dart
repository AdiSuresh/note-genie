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

sealed class NonIdleState extends HomeState {
  final IdleState previousState;

  const NonIdleState({
    required this.previousState,
  });
}

sealed class SearchState<T extends BaseEntity> extends NonIdleState {
  final String query;
  final List<T> searchResults;

  SearchState({
    required super.previousState,
    required this.query,
    required this.searchResults,
  });
}

@CopyWith()
final class SearchNotesState extends SearchState<NoteEntity> {
  SearchNotesState({
    required super.previousState,
    required super.query,
    required super.searchResults,
  });

  factory SearchNotesState.initial(
    IdleState previousState,
  ) {
    return SearchNotesState(
      previousState: previousState,
      query: '',
      searchResults: previousState.notes,
    );
  }
}

@CopyWith()
final class SearchNoteCollectionsState
    extends SearchState<NoteCollectionEntity> {
  SearchNoteCollectionsState({
    required super.previousState,
    required super.query,
    required super.searchResults,
  });

  factory SearchNoteCollectionsState.initial(
    IdleState previousState,
  ) {
    return SearchNoteCollectionsState(
      previousState: previousState,
      query: '',
      searchResults: previousState.noteCollections,
    );
  }
}

sealed class SelectItemsState<T extends BaseEntity> extends NonIdleState {
  final List<(T, bool)> items;

  const SelectItemsState({
    required super.previousState,
    required this.items,
  });

  static List<(T, bool)> createItems<T extends BaseEntity>(
    List<T> list,
  ) {
    return list
        .map(
          (e) => (e, false),
        )
        .toList(
          growable: false,
        );
  }
}

final class SelectNotesState extends SelectItemsState<NoteEntity> {
  const SelectNotesState({
    required super.previousState,
    required super.items,
  });

  factory SelectNotesState.initial(
    IdleState previousState,
  ) {
    return SelectNotesState(
      previousState: previousState,
      items: SelectItemsState.createItems(
        previousState.notes,
      ),
    );
  }
}

final class SelectNoteCollectionsState
    extends SelectItemsState<NoteCollectionEntity> {
  const SelectNoteCollectionsState({
    required super.previousState,
    required super.items,
  });

  factory SelectNoteCollectionsState.initial(
    IdleState previousState,
  ) {
    return SelectNoteCollectionsState(
      previousState: previousState,
      items: SelectItemsState.createItems(
        previousState.noteCollections,
      ),
    );
  }
}
