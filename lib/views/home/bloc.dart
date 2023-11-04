import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_maker/data/note/dao.dart';
import 'package:note_maker/data/note_collection/dao.dart';
import 'package:note_maker/views/home/event.dart';
import 'package:note_maker/views/home/state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  static final noteCollectionDao = NoteCollectionDao();
  static final noteDao = NoteDao();

  HomeBloc(
    super.initialState,
  ) {
    on<UpdatePageEvent>(
      (event, emit) {
        emit(
          HomeState(
            notes: state.notes,
            noteCollections: state.noteCollections,
          ),
        );
      },
    );
  }
}
