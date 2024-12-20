import 'dart:collection';

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:note_maker/models/base_entity.dart';
import 'package:note_maker/models/note_collection/model.dart';
import 'package:note_maker/models/note/model.dart';

part 'state.g.dart';

sealed class HomeState {
  const HomeState();
}

sealed class DeleteItemsState<T extends BaseEntity> extends HomeState {
  final SelectItemsState<T> previousState;
  final Future<int> future;

  const DeleteItemsState({
    required this.previousState,
    required this.future,
  });
}

final class DeleteNotesState extends DeleteItemsState<NoteEntity> {
  const DeleteNotesState({
    required super.previousState,
    required super.future,
  });
}

final class DeleteNoteCollectionsState
    extends DeleteItemsState<NoteCollectionEntity> {
  const DeleteNoteCollectionsState({
    required super.previousState,
    required super.future,
  });
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
  final List<T> searchResults;

  SearchState({
    required super.previousState,
    required this.searchResults,
  });
}

@CopyWith()
final class SearchNotesState extends SearchState<NoteEntity> {
  SearchNotesState({
    required super.previousState,
    required super.searchResults,
  });

  factory SearchNotesState.initial(
    IdleState previousState,
  ) {
    return SearchNotesState(
      previousState: previousState,
      searchResults: previousState.notes,
    );
  }
}

@CopyWith()
final class SearchNoteCollectionsState
    extends SearchState<NoteCollectionEntity> {
  SearchNoteCollectionsState({
    required super.previousState,
    required super.searchResults,
  });

  factory SearchNoteCollectionsState.initial(
    IdleState previousState,
  ) {
    return SearchNoteCollectionsState(
      previousState: previousState,
      searchResults: previousState.noteCollections,
    );
  }
}

sealed class SelectItemsState<T extends BaseEntity> extends NonIdleState {
  final List<bool> selected;
  final HashSet<int> itemIds;
  final int count;

  const SelectItemsState({
    required super.previousState,
    required this.selected,
    required this.itemIds,
    required this.count,
  });

  static List<bool> createItems<T extends BaseEntity>(
    List<T> list,
  ) {
    return list
        .map(
          (e) => false,
        )
        .toList(
          growable: false,
        );
  }

  List<T> get items;

  int updateWithItem(
    int index,
  ) {
    final selected = !this.selected[index];
    this.selected[index] = selected;
    final item = items[index];
    final update = switch (selected) {
      true => itemIds.add,
      false => itemIds.remove,
    };
    update(
      item.id,
    );
    return itemIds.length;
  }
}

@CopyWith()
final class SelectNotesState extends SelectItemsState<NoteEntity> {
  const SelectNotesState({
    required super.previousState,
    required super.selected,
    required super.itemIds,
    required super.count,
  });

  factory SelectNotesState.initial(
    IdleState previousState,
  ) {
    return SelectNotesState(
      previousState: previousState,
      selected: SelectItemsState.createItems(
        previousState.notes,
      ),
      itemIds: HashSet(),
      count: 0,
    );
  }

  @override
  List<NoteEntity> get items => previousState.notes;
}

@CopyWith()
final class SelectNoteCollectionsState
    extends SelectItemsState<NoteCollectionEntity> {
  const SelectNoteCollectionsState({
    required super.previousState,
    required super.selected,
    required super.itemIds,
    required super.count,
  });

  factory SelectNoteCollectionsState.initial(
    IdleState previousState,
  ) {
    return SelectNoteCollectionsState(
      previousState: previousState,
      selected: SelectItemsState.createItems(
        previousState.noteCollections,
      ),
      itemIds: HashSet(),
      count: 0,
    );
  }

  @override
  List<NoteCollectionEntity> get items => previousState.noteCollections;
}
