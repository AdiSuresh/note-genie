import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_maker/models/note/dao.dart';
import 'package:note_maker/views/home/event.dart';
import 'package:note_maker/views/home/state/state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  static final noteDao = NoteDao();

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
    on<SwitchViewEvent>(
      (event, emit) {
        emit(
          state.copyWith(
            showNotes: !state.showNotes,
          ),
        );
      },
    );
  }
}
