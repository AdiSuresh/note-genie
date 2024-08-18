import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_maker/models/note/dao.dart';
import 'package:note_maker/models/note_collection/dao.dart';
import 'package:note_maker/views/home/event.dart';
import 'package:note_maker/views/home/state/state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  static final noteCollectionDao = NoteCollectionDao();
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
    on<ViewCollectionEvent>(
      (event, emit) {
        final collection = switch (state.currentCollection?.id) {
          final id when id == event.collection.id => null,
          _ => event.collection,
        };
        emit(
          state.copyWith(
            currentCollection: collection,
          ),
        );
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
