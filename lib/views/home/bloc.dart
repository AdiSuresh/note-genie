import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_maker/views/home/event.dart';
import 'package:note_maker/views/home/state/state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc(
    super.initialState,
  ) {
    on<UpdateNoteCollectionsEvent>(
      (event, emit) {
        emit(
          state.copyWith(
            noteCollections: event.noteCollections,
          ),
        );
      },
    );
    on<UpdateNotesEvent>(
      (event, emit) {
        emit(
          state.copyWith(
            notes: event.notes,
          ),
        );
      },
    );
    on<ToggleCollectionEvent>(
      (event, emit) {
        final collection = switch (state.currentCollection?.id) {
          final int id when id == event.collection?.id => null,
          _ => event.collection,
        };
        emit(
          state.copyWith(
            currentCollection: collection,
          ),
        );
      },
    );
    on<SelectCollectionEvent>(
      (event, emit) {
        switch (state.currentCollection?.id) {
          case final int id when id != event.collection?.id:
            emit(
              state.copyWith(
                currentCollection: event.collection,
              ),
            );
          case _:
        }
      },
    );
    on<SwitchTabEvent>(
      (event, emit) {
        final showNotes = switch (event.index) {
          0 || 1 => event.index == 0,
          _ => null,
        };
        switch (showNotes) {
          case final bool showNotes when showNotes ^ state.showNotes:
            emit(
              state.copyWith(
                showNotes: showNotes,
              ),
            );
          case _:
        }
      },
    );
  }
}
