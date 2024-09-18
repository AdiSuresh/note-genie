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
          case final id when id != event.collection?.id || id == null:
            emit(
              state.copyWith(
                currentCollection: event.collection,
              ),
            );
          default:
        }
      },
    );
    on<SwitchTabEvent>(
      (event, emit) {
        final showNotes = switch (event.index) {
          0 => true,
          1 => false,
          _ => null,
        };
        switch (showNotes) {
          case final bool showNotes when showNotes != state.showNotes:
            emit(
              state.copyWith(
                showNotes: !state.showNotes,
              ),
            );
          case _:
        }
      },
    );
  }
}
