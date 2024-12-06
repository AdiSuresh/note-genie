import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_maker/app/router/blocs/navigation/bloc.dart';
import 'package:note_maker/app/router/blocs/navigation/state.dart';
import 'package:note_maker/models/note_collection/model.dart';
import 'package:note_maker/views/home/event.dart';
import 'package:note_maker/views/home/repository.dart';
import 'package:note_maker/views/home/state/state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final NavigationBloc _navigationBloc;

  final String path;

  final HomeRepository repository;

  StreamSubscription<List<NoteCollectionEntity>>? _noteCollectionsSub;
  StreamSubscription<NavigationState>? _navigationSub;

  HomeBloc(
    super.initialState,
    this._navigationBloc, {
    required this.repository,
    required this.path,
  }) {
    on<ResetStateEvent>(
      (event, emit) {
        if (state case NonIdleState(:final previousState)) {
          emit(
            previousState,
          );
        }
      },
    );
    on<UpdateNoteCollectionsEvent>(
      (event, emit) {
        switch (state) {
          case final IdleState state:
            emit(
              state.copyWith(
                noteCollections: event.noteCollections,
              ),
            );
          case _:
        }
      },
    );
    on<ToggleCollectionEvent>(
      (event, emit) {
        switch (state) {
          case final IdleState state:
            final collection = switch (state.currentCollection?.id) {
              final int id when id == event.collection?.id => null,
              _ => event.collection,
            };
            emit(
              state.copyWith(
                currentCollection: collection,
              ),
            );
            add(
              const FetchNotesEvent(),
            );
          case _:
        }
      },
    );
    on<SelectCollectionEvent>(
      (event, emit) async {
        switch (state) {
          case final IdleState state:
            switch (state.currentCollection?.id) {
              case final int id when id == event.collection?.id:
              // ignored
              case _:
                emit(
                  state.copyWith(
                    currentCollection: event.collection,
                  ),
                );
                add(
                  const FetchNotesEvent(),
                );
            }
          case SearchNoteCollectionsState():
            add(
              ToggleSearchEvent(),
            );
            add(
              event,
            );
          case _:
        }
      },
    );
    on<SwitchTabEvent>(
      (event, emit) {
        if (state case SelectItemsState()) {
          return;
        }
        final currentIdleState = switch (state) {
          IdleState state => state,
          SearchState(:final previousState) => previousState,
          SelectItemsState(:final previousState) => previousState,
        };
        final showNotes = switch (event.index) {
          0 || 1 => event.index == 0,
          _ => null,
        };
        if (showNotes == null || showNotes == currentIdleState.showNotes) {
          return;
        }
        final nextIdleState = currentIdleState.copyWith(
          showNotes: showNotes,
        );
        final result = switch (state) {
          IdleState() => nextIdleState,
          final SearchNotesState state => state.copyWith(
              previousState: nextIdleState,
            ),
          final SearchNoteCollectionsState state => state.copyWith(
              previousState: nextIdleState,
            ),
          _ => null,
        };
        if (result == null) {
          return;
        }
        emit(
          result,
        );
      },
    );
    on<FetchNotesEvent>(
      (event, emit) async {
        switch (state) {
          case final IdleState state:
            final notes = await repository.fetchNotes(
              currentCollection: state.currentCollection,
            );
            emit(
              state.copyWith(
                notes: notes,
              ),
            );
          case _:
        }
      },
    );
    on<ToggleSearchEvent>(
      (event, emit) {
        final nextState = switch (state) {
          final IdleState state => switch (state.showNotes) {
              true => SearchNotesState.initial,
              _ => SearchNoteCollectionsState.initial,
            }(
              state,
            ),
          SearchState(
            :final previousState,
          ) =>
            previousState,
          _ => null,
        };
        if (nextState == null) {
          return;
        }
        emit(
          nextState,
        );
      },
    );
    on<PerformSearchEvent>(
      (event, emit) async {
        switch (state) {
          case final SearchNotesState state:
            final notes = await repository.fetchNotes(
              currentCollection: state.previousState.currentCollection,
              searchQuery: event.query,
            );
            emit(
              state.copyWith(
                searchResults: notes,
              ),
            );
          case final SearchNoteCollectionsState state:
            final noteCollections = await repository.fetchNoteCollections(
              searchQuery: event.query,
            );
            emit(
              state.copyWith(
                searchResults: noteCollections,
              ),
            );
          case _:
        }
      },
    );
    on<SelectNoteEvent>(
      (event, emit) {
        switch (state) {
          case final IdleState state:
            emit(
              SelectNotesState.initial(
                state,
                event.index,
              ),
            );
          case final SelectNotesState state:
            final selected = !state.selected[event.index];
            state.selected[event.index] = selected;
            emit(
              state.copyWith(),
            );
          case _:
        }
      },
    );
    _startNavigationSub();
    _startNoteCollectionsSub();
    add(
      FetchNotesEvent(),
    );
  }

  @override
  Future<void> close() {
    _stopNavigationSub();
    _stopNoteCollectionsSub();
    return super.close();
  }

  Future<void> _startNoteCollectionsSub() async {
    _stopNoteCollectionsSub();
    if (_noteCollectionsSub == null) {
      final stream = await repository.createCollectionsStream(
        shouldSkip: () {
          final uri = Uri.parse(
            _navigationBloc.state.currentPath,
          );
          final shouldSkip = uri.path != path;
          print('shouldSkip: $shouldSkip');
          return shouldSkip;
        },
      );
      _noteCollectionsSub = stream.listen(
        (event) {
          add(
            UpdateNoteCollectionsEvent(
              noteCollections: event,
            ),
          );
        },
      );
    }
  }

  void _stopNoteCollectionsSub() {
    _noteCollectionsSub?.cancel();
    _noteCollectionsSub = null;
  }

  void _startNavigationSub() {
    _stopNavigationSub();
    _navigationSub = _navigationBloc.stream.listen(
      (state) {
        if (state.currentPath != '/') {
          return;
        }
        print('fetch notes from _navigationSub');
        add(
          FetchNotesEvent(),
        );
      },
    );
  }

  void _stopNavigationSub() {
    _navigationSub?.cancel();
    _navigationSub = null;
  }
}
